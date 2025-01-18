/**
 * Created by baltamimi on 2022-03-01.
 */

 public without sharing class RRPFieldHistoryUtil {

    public static final String CONTEXT_FLOW = 'Flow';
    public static final String CONTEXT_TRIGGER = 'Trigger';
    public static final String CONTEXT_USER = 'User';

    public static final String SOURCE_UI_API = 'UI/API Update';

    public static Boolean isDisabled {
        get {
            return RRPFieldHistorySetting.isDisabled(sObjectAPIName);
        }
    }
    private static Set<String> trackedFields {
        get {
            return RRPFieldHistorySetting.trackedFields(sObjectAPIName);
        }
    }
    public static String lookupFieldName {
        get {
            return RRPFieldHistorySetting.getLookupFieldName(sObjectAPIName);
        }
    }

    public static String appName {
        get {
            return RRPFieldHistorySetting.getAppName(sObjectAPIName);
        }
    }

    private static String sObjectAPIName;
    @TestVisible
    private static String context;
    private static String runBy;

    private static Map<String, Map<String, Schema.SObjectField>> fieldsByObjectAPIName;

    @TestVisible
    private static Map<Id, List<SnapshotObject>> recordVersionsMap;

    @TestVisible
    private static List<FieldHistory> historyToInsert;

    private static Stack contextStack;
    static {
        fieldsByObjectAPIName = new Map<String, Map<String, Schema.SObjectField>>();
        recordVersionsMap = new Map<Id, List<SnapshotObject>>();
        historyToInsert = new List<FieldHistory>();
        contextStack = new Stack();
    }

    public static void setContext(String sentContext, String sObjectType, String runBy) {
        if (contextStack.size() > 0) {
            RRPFieldHistoryCacheUtil.Context currentContext = (RRPFieldHistoryCacheUtil.Context) contextStack.peek();
            if (currentContext.sentContext.equalsIgnoreCase(CONTEXT_FLOW)) {
                if (sentContext.equalsIgnoreCase(CONTEXT_FLOW)) { // Run tracked subflow
                    updateContext(sentContext, sObjectType, runBy);
                } else {
                    System.debug('FieldHistoryUtil/setContext context already set to FLOW');
                }
            } else if (currentContext.sentContext.equalsIgnoreCase(CONTEXT_TRIGGER)) {
                if (sentContext.equalsIgnoreCase(CONTEXT_USER)) { // Run tracked subflow
                    System.debug('FieldHistoryUtil/setContext context already set to TRIGGER');
                } else {
                    updateContext(sentContext, sObjectType, runBy);
                }
            } else {
                updateContext(sentContext, sObjectType, runBy);
            }
        } else {
            updateContext(sentContext, sObjectType, runBy);
        }

        System.debug('FieldHistoryUtil/setContext Stack:: ' + contextStack.toString());
        refreshContext();
    }

    public static void setContext(String sObjectType) {
        setContext('', sObjectType, '');
    }

    public static void resetContext(String source) {
        if (contextStack.size() > 0) { // Delete the exited context
            RRPFieldHistoryCacheUtil.Context currentContext = (RRPFieldHistoryCacheUtil.Context) contextStack.peek();
            if (!currentContext.sentContext.equalsIgnoreCase(source)) { // Prevent deleting the FLOW context outside of the Invocable call
                System.debug('FieldHistoryUtil/resetContext Ignored:: unmatched context (current: ' + currentContext.sentContext + ',source: ' + source);
                return;
            }
            contextStack.pop();
        }
        if (contextStack.size() > 0) { // return to previous context
            RRPFieldHistoryCacheUtil.Context previousContext = (RRPFieldHistoryCacheUtil.Context) contextStack.peek();
            RRPFieldHistoryCacheUtil.Context newContext = new RRPFieldHistoryCacheUtil.Context(previousContext.sentContext, previousContext.sObjectType, previousContext.runBy);
            RRPFieldHistoryCacheUtil.updateContext(newContext);
        } else {
            resetContextCache();
        }
        System.debug('FieldHistoryUtil/resetContext Stack:: ' + contextStack.toString());
        refreshContext();
    }

    private static void refreshContext() {
        RRPFieldHistoryCacheUtil.Context ctx = RRPFieldHistoryCacheUtil.getContext();
        if (ctx != null) {
            sObjectAPIName = ctx.sObjectType;
            context = ctx.sentContext;
            runBy = ctx.runBy;
        } else {
            System.debug('FieldHistoryUtil/refreshContext Error:: No context were found');
        }
    }

    public static void initReferences(List<SObject> records) {
        // check if context has already been set (By Flow)
        System.debug('rrprecords:::::::::::::::::'+records);
        refreshContext();

        if (String.isEmpty(context) || !context.equalsIgnoreCase(CONTEXT_FLOW)) {
            setContext(CONTEXT_USER, getSObjectType(records[0]), SOURCE_UI_API);
        }

        if (isDisabled) {
            System.debug('FieldHistoryUtil/initReferences Field History Tracking is Disabled for (' + sObjectAPIName + ') Object');
            if (context.equalsIgnoreCase(CONTEXT_USER)) {
                resetContext(CONTEXT_USER);
            }
            return;
        }

        for (SObject record : records) {
            takeSnapshot(record);
        }

        if (context.equalsIgnoreCase(CONTEXT_USER)) {
            resetContext(CONTEXT_USER);
        }
    }

    public static void trackUserChanges(List<SObject> updatedRecords) {
        initReferences(updatedRecords);
    }

    public static void takeSnapshots(Set<Id> recordsIds) {
        List<Id> recordsIdsList = new List<Id>(recordsIds);
        takeSnapshots(recordsIdsList);
    }

    public static void takeSnapshots(List<Id> recordsIds) {
        if (isDisabled) {
            System.debug('FieldHistoryUtil/takeSnapshots(List) Field History Tracking is Disabled for (' + sObjectAPIName + ') Object');
            return;
        }

        System.debug('FieldHistoryUtil/takeSnapshots(List):: Records Ids (' + recordsIds.size() + '):: ' + JSON.serialize(recordsIds));
        if (!String.isEmpty(sObjectAPIName)) {
            List<SObject> sourceRecords = RRPFieldHistorySelector.getSObjects(sObjectAPIName, new List<String>(trackedFields), recordsIds)?.values();

            for (SObject record : sourceRecords) {
                takeSnapshot(record);
            }
        } else {
            System.debug('FieldHistoryUtil/takeSnapshots(List) Info:: Skip taking snapshot (Missing Context Values)');
        }
    }

    /**
     * Create Field History records based on the versions captured previously. Call this method at the very end before leave
     * the Trigger context.
     */
    public static void commitLogs() {
        if (isDisabled) {
            System.debug('FieldHistoryUtil/commitLogs Field History Tracking is Disabled for (' + sObjectAPIName + ') Object');
            return;
        }

        System.debug('FieldHistoryUtil/commitLogs:: Context Stack: ' + contextStack.toString());
        processValueChanges();
        Set<String> fieldHistoryFields = getFieldHistoryFields();
        List<FieldHistory__c> histories = new List<FieldHistory__c>();
        // RRP Project Oh, janghun 2024-05-23 Start : Field History
        Set<String> userIds = new Set<String>(); 
        Map<String,String> fieldhistoryMap = new Map<String,String>();
        System.debug('Start:::::');
        for (FieldHistory fh : historyToInsert) {
            if(fh.fieldName == 'Owner ID' || fh.fieldName == 'ISEQC Engineer' || fh.fieldName == 'Safety Assurance Engineer (RRP Owner)' || fh.fieldName == 'Content Approver'
               || fh.fieldName == 'Contact Back-up Name_lookup' || fh.fieldName == 'Requestor_lookup'){
                userIds.add((String)fh.originalValue);
                userIds.add((String)fh.newValue);
            }
        }
        System.debug('userIds:::::'+userIds);

        List<User> userList = [SELECT Id, Name FROM User WHERE Id IN : userIds];

        for(User userObj : userList){
            fieldhistoryMap.put(userObj.Id,userObj.Name);
        }
        // RRP Project Oh, janghun 2024-05-23 End : Field History
        System.debug('fieldhistoryMap:::::'+fieldhistoryMap);
        System.debug('historyToInsert:::::::::' + historyToInsert);
        for (FieldHistory fh : historyToInsert) {
            System.debug('fh:::::::::::::'+fh);
            String lookupFieldName = lookupFieldName;
            System.debug('FieldHistoryUtil/commitLogs:: lookup field name: ' + lookupFieldName);

            if (Test.isRunningTest() || fieldHistoryFields.contains(lookupFieldName)) {
                System.debug('lookupFieldName :::::' + lookupFieldName);
                FieldHistory__c fieldHistoryToInsert = new FieldHistory__c();
                    fieldHistoryToInsert.FieldName__c = fh.fieldName;
                    fieldHistoryToInsert.RunningContext__c = fh.runningContext;
                    fieldHistoryToInsert.Timestamp__c = fh.timestamp;
                    fieldHistoryToInsert.UpdatedByContext__c = fh.updatedBy_Context;
                    fieldHistoryToInsert.TrackedByAppName__c = appName;
                    fieldHistoryToInsert.OriginalValue__c = String.valueOf(fh.originalValue);
                    fieldHistoryToInsert.NewValue__c = String.valueOf(fh.newValue);
                if(fh.fieldName == 'Owner ID' || fh.fieldName == 'ISEQC Engineer' || fh.fieldName == 'Safety Assurance Engineer (RRP Owner)' || fh.fieldName == 'Content Approver' || fh.fieldName == 'Contact Back-up Name_lookup' || fh.fieldName == 'Requestor_lookup'){
                    fieldHistoryToInsert.OriginalValue__c = fieldhistoryMap.get((String)fh.originalValue);    // RRP Project Oh, janghun 2024-05-23 : Field History
                    fieldHistoryToInsert.NewValue__c = fieldhistoryMap.get((String)fh.newValue);              // RRP Project Oh, janghun 2024-05-23 : Field History
                }
                if (!Test.isRunningTest()) {
                    fieldHistoryToInsert.put(lookupFieldName, fh.recordId);
                }

                histories.add(fieldHistoryToInsert);
                System.debug('histories::::::::' + histories);
            } else {
                System.debug('FieldHistoryUtil/commitLogs ERROR:: could not find a lookup field with api name = "' + lookupFieldName + '" in "' + fieldHistoryFields + '" object');
            }
        }        

        System.debug('FieldHistoryUtil/commitLogs:: Field Histories (' + histories.size() + ') To Insert: ' + JSON.serializePretty(histories));

        if (histories.size() > 0) {
            System.debug(String.format('FieldHistoryUtil/commitLogs Info:: ready to save {0} history records!', new List<String>{
                    String.valueOf(histories.size())
            }));

            List<Database.SaveResult> saveResults = Database.insert(histories, false);
            List<Id> insertedFieldHistoryIds = new List<Id>();
            Integer numberSuccess = 0, numberError = 0;
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    insertedFieldHistoryIds.add(sr.getId());
                    numberSuccess += 1;
                } else {
                    System.debug('CMTFieldHistoryUtil/commitLogs Error:: while saving new log record: ' + sr.errors[0].getMessage());
                    numberError += 1;
                }
            }

            System.debug(String.format('CMTFieldHistoryUtil/commitLogs Commit Results::\nNumber of Successes: {0}\nNumber of Errors: {1}', new List<String>{
                    String.valueOf(numberSuccess), String.valueOf(numberError)
            }));

            if (insertedFieldHistoryIds.size() > 0) {
                replaceIdsWithName(insertedFieldHistoryIds);
            }
        } else {
            System.debug('CMTFieldHistoryUtil/commitLogs Info:: No history records to commit!');
        }

        flushLogs();
    }

    // ---------------- Util methods ----------------
    private static Set<String> getFieldHistoryFields() {
        System.debug('test'+toLower(Schema.SObjectType.FieldHistory__c.fields.getMap().keySet()));
        return toLower(Schema.SObjectType.FieldHistory__c.fields.getMap().keySet());
    }

    private static Set<String> toLower(Set<String> oldSet) {
        Set<String> updatedSet = new Set<String>();
        for (String s : oldSet) {
            updatedSet.add(s.toLowerCase());
        }

        return updatedSet;
    }

    private static String getSObjectType(Id recordId) {
        return recordId.getSobjectType().getDescribe().getName();
    }

    private static String getSObjectType(SObject record) {
        return record.getSObjectType().getDescribe().getName();
    }

    /**
     * Call this method to save a version of the updated record. It's best to take the first snapshot at the beginning of the
     * method, then call it right after each update statement
     * @param record current state of the record
     */
    @TestVisible
    private static void takeSnapshot(SObject record) {
        System.debug('FieldHistoryUnit/takeSnapshot (Record):: context: ' + context + ', RunBy: ' + runBy);
        SnapshotObject newSnapshot = new SnapshotObject(context, runBy, record.clone(true));

        if (recordVersionsMap.containsKey(record.Id)) {
            List<SnapshotObject> exitingVersions = recordVersionsMap.get(record.Id);
            exitingVersions.add(newSnapshot);
            recordVersionsMap.put(record.Id, exitingVersions);
        } else {
            recordVersionsMap.put(record.Id, new List<SnapshotObject>{
                    newSnapshot
            });
        }
    }

    private static void log(Id recordId, String field, Object originalValue, Object newValue, String updateContext, String runBy) {
        FieldHistory fh = new FieldHistory();
        fh.recordId = recordId;
        fh.fieldName = getFieldLabel(field);
        fh.originalValue = originalValue;
        fh.newValue = newValue;

        fh.runningContext = updateContext;
        fh.updatedBy_Context = runBy;

        fh.timestamp = System.now();
        System.debug('FieldHistoryUtil/log:: FieldHistory Log: ' + JSON.serialize(fh));

        historyToInsert.add(fh);
    }

    private static void processValueChanges() {
        for (Id recordId : recordVersionsMap.keySet()) {
            List<SnapshotObject> recordVersions = recordVersionsMap.get(recordId);
            for (Integer i = 0; i < recordVersions.size() - 1; i++) {
                detectValueChanges(recordVersions[i], recordVersions[i + 1]);
            }
        }
    }

    private static void updateContext(String sentContext, String sObjectType, String runBy) {
        RRPFieldHistoryCacheUtil.Context newContext = new RRPFieldHistoryCacheUtil.Context(sentContext, sObjectType, runBy);
        RRPFieldHistoryCacheUtil.updateContext(newContext);
        contextStack.push(newContext);
    }

    private static void detectValueChanges(SnapshotObject oldSnapshot, SnapshotObject newSnapshot) {
        System.debug('FieldHistoryUtil/detectValueChanges:: Old Context: ' + oldSnapshot.context + ', Old RunBy: ' + oldSnapshot.runBy);
        System.debug('FieldHistoryUtil/detectValueChanges:: New Context: ' + newSnapshot.context + ', New RunBy: ' + newSnapshot.runBy);
        SObject oldRecord = oldSnapshot.record;
        SObject newRecord = newSnapshot.record;
        if (oldRecord.getSObjectType().getDescribe().getName() == newRecord.getSObjectType().getDescribe().getName()) {
            for (String trackedField : trackedFields) {
                if (hasChanged(oldRecord.get(trackedField), newRecord.get(trackedField))) {
                    log(
                            oldRecord.Id,
                            trackedField,
                            oldRecord.get(trackedField),
                            newRecord.get(trackedField),
                            newSnapshot.context,
                            newSnapshot.runBy
                    );
                    System.debug(oldRecord+ '::::@::::' + newRecord);
                }
            }
        } else {
            System.debug('FieldHistoryUtil/detectValueChanges Error:: Unknown Object type');
        }
    }

    private static void flushLogs() {
        // Reset the log list for the next step
        historyToInsert = new List<FieldHistory>();
        recordVersionsMap = new Map<Id, List<SnapshotObject>>();
        context = '';
        runBy = '';
        sObjectAPIName = '';
        contextStack.empty();
        resetContextCache();
    }

    private static void resetContextCache() {
        RRPFieldHistoryCacheUtil.resetContext();
    }

    private static Boolean hasChanged(Object originalValue, Object updatedValue) {
        return originalValue != updatedValue;
    }

    private static String getFieldLabel(String apiName) {
        Map<String, Schema.SObjectField> fieldMap;
        if (fieldsByObjectAPIName.containsKey(sObjectAPIName)) {
            fieldMap = fieldsByObjectAPIName.get(sObjectAPIName);
        } else {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(sObjectAPIName);
            fieldMap = leadSchema.getDescribe().fields.getMap();

            fieldsByObjectAPIName.put(sObjectAPIName, fieldMap);
        }

        return fieldMap.get(apiName).getDescribe().getLabel();
    }

    // ---------------- Invocable Method ----------------
    @InvocableMethod(Label='Manage CMT Field History Tracking' Description='Enable/Disable Logging context to the selected Flow')
    public static void manageTracking(List<FieldHistoryInvocableRequest> requests) {
        FieldHistoryInvocableRequest request = requests[0];
        if (request != null) {
            if (request.stopTracking != null && request.stopTracking) {
                resetContext(CONTEXT_FLOW);
            } else {
                setContext(CONTEXT_FLOW, request.SObjectType, request.flowName);
            }
        } else {
            System.debug('FieldHistoryUtil/manageTracking Error:: Unknown record SObject Type');
        }
    }
    public class FieldHistoryInvocableRequest {
        @InvocableVariable
        public String flowName;

        @InvocableVariable
        public String SObjectType;

        @InvocableVariable
        public Boolean stopTracking;
    }

    // ---------------- Future Method ----------------
    @TestVisible
    private static List<FieldHistory__c> fieldHistoriesToUpdate { get; set; }

    @Future
    public static void replaceIdsWithName(List<Id> fieldHistoriesIds) {
        List<FieldHistory__c> fieldHistories = RRPFieldHistorySelector.getFieldHistories(fieldHistoriesIds);
        System.debug('FieldHistoryUtil/replaceIdsWithName FieldHistory to update:: ' + JSON.serializePretty(fieldHistories));

        Map<String, Set<Id>> idsBySObjectName = new Map<String, Set<Id>>();
        for (FieldHistory__c fh : fieldHistories) {
            if (fh.OriginalValue__c instanceof Id) {
                addToMap(idsBySObjectName, fh.OriginalValue__c);
            }
            if (fh.NewValue__c instanceof Id) {
                addToMap(idsBySObjectName, fh.NewValue__c);
            }
        }

        // Get Records Names
        Map<String, Map<Id, SObject>> recordsBySObjectName = new Map<String, Map<Id, SObject>>();
        for (String sObjectName : idsBySObjectName.keySet()) {
            List<Id> recordIds = new List<Id>(idsBySObjectName.get(sObjectName));

            Map<Id, SObject> results;
           
            /**
            * @description : RRP Project
            * @author San, Kang : SanKang@autoeveramerica.com 
            */
            if(sObjectName == 'RRP__c'){
                results = RRPFieldHistorySelector.getSObjects(sObjectName, new List<String>{
                    'Id', 'Name'
            }, recordIds);
            }else if(sObjectName == 'Lab Request'){ // STIL Project 2024-06-06 Kang, San
                results = RRPFieldHistorySelector.getSObjects(sObjectName, new List<String>{
                    'Id', 'WorkOrderNumber'
            }, recordIds);
            }
            System.debug('sObjectName::::'+sObjectName);
            recordsBySObjectName.put(sObjectName, results);
        }

        // replace the ids with records names
        fieldHistoriesToUpdate = new List<FieldHistory__c>();
        for (FieldHistory__c fh : fieldHistories) {
            Boolean needUpdate = false;
            System.debug('Test:::::::::' + fh.OriginalValue__c + ' and ' + fh.OriginalValue__c instanceof Id);
            if (!String.isEmpty(fh.OriginalValue__c) && fh.OriginalValue__c instanceof Id) {
                String sObjectType = getSObjectType(fh.OriginalValue__c);

                String recordName;
                if((sObjectType.equalsIgnoreCase('RRP__c'))) {
                    recordName = (String) recordsBySObjectName.get(sObjectType)?.get(fh.OriginalValue__c)?.get('Name');
                } else if(sObjectType.equalsIgnoreCase('Lab Request')) { // STIL Project 2024-06-06 Kang, San
                    recordName = (String) recordsBySObjectName.get(sObjectType)?.get(fh.OriginalValue__c)?.get('WorkOrderNumber');
                }
                if (!String.isEmpty(recordName)) {
                    fh.OriginalValue__c = recordName;
                    needUpdate = true;
                }
                
            }
            if (!String.isEmpty(fh.NewValue__c) && fh.NewValue__c instanceof Id) {
                String sObjectType = getSObjectType(fh.NewValue__c);

                String recordName;
                if (sObjectType.equalsIgnoreCase('RRP__c')) {
                    recordName = (String) recordsBySObjectName.get(sObjectType)?.get(fh.NewValue__c)?.get('Name');
                } else if(sObjectType.equalsIgnoreCase('Lab Request')) { // STIL Project 2024-06-06 Kang, San
                    recordName = (String) recordsBySObjectName.get(sObjectType)?.get(fh.OriginalValue__c)?.get('WorkOrderNumber');
                }

                if (!String.isEmpty(recordName)) {
                    fh.NewValue__c = recordName;
                    needUpdate = true;
                }
                
            }

            if (needUpdate) {
                fieldHistoriesToUpdate.add(fh);
            }
        }
        
        System.debug('FieldHistoryUtil/replaceIdsWithName FieldHistory To Be Updated:: ' + JSON.serializePretty(fieldHistoriesToUpdate));

        List<Database.SaveResult> saveResults = Database.update(fieldHistoriesToUpdate, false);
        Integer numberSuccess = 0, numberError = 0;
        for (Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                numberSuccess += 1;
            } else {
                System.debug('FieldHistoryUtil/replaceIdsWithName Error:: while updating log record: ' + sr.errors[0].getMessage());
                numberError += 1;
            }
        }

        System.debug(String.format('FieldHistoryUtil/replaceIdsWithName Update Results::\nNumber of Successes: {0}\nNumber of Errors: {1}', new List<String>{
                String.valueOf(numberSuccess), String.valueOf(numberError)
        }));
    }

    private static Map<String, Set<Id>> addToMap(Map<String, Set<Id>> originalMap, Id recordId) {
        String sObjectName = getSObjectType(recordId);

        if (originalMap.containsKey(sObjectName)) {
            Set<Id> existingIds = originalMap.get(sObjectName);
            existingIds.add(recordId);
            originalMap.put(sObjectName, existingIds);
        } else {
            originalMap.put(sObjectName, new Set<Id>{
                    recordId
            });
        }
        return originalMap;
    }
    // ---------------- Wrapper class ----------------

    public class SnapshotObject {
        public String context { get; set; }
        public String runBy { get; set; }
        public SObject record { get; set; }

        public SnapshotObject(String context, String runBy, SObject record) {
            this.context = context;
            this.runBy = runBy;
            this.record = record;
        }
    }

    public class FieldHistory {
        public Id recordId { get; set; }
        public String fieldName { get; set; }
        public Object originalValue { get; set; }
        public Object newValue { get; set; }
        public String runningContext { get; set; }
        public Datetime timestamp { get; set; }
        public String updatedBy_Context { get; set; }
    }
}