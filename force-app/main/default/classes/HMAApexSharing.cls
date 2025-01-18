public without sharing class HMAApexSharing {

    public Map<String, HMAShareWrapper> records = new Map<String, HMAShareWrapper>();
    public Map<String, List<SObject>> recordsToDelete = new Map<String, List<SObject>>();

    private String objectName;

    public HMAApexSharing(String objectName) {
        this.objectName = objectName;
    }

    /**
     * builds share record based on sobject and adds to list
     * @param  shareRecord [sobject record to share]
     * @param  userOrGroup [user or group to share record with]
     * @param  shareLevel  [access level]
     * @param  cause       [sharing reason. defaults to "Manual Sharing"]
     * @return             [void]
     */
    public void add(SObject shareRecord, Id userOrGroup, String shareLevel, String cause) {
        // make sure we do not create a share for our record owner.
        if (shareRecord.get('OwnerId') == userOrGroup) {
            return;
        }
        String objName = shareRecord.getSObjectType().getDescribe().getName();
        SObject sh;
        Id parentId = (Id) shareRecord.get('Id');
        // custom objects are different than standard
        if(objName.endsWithIgnoreCase('__c')) {
            sh = Schema.getGlobalDescribe().get(objName.replace('__c','__Share')).newSObject();
            sh.put('AccessLevel', shareLevel);
            sh.put('ParentId', parentId);        }
        else {
            sh = Schema.getGlobalDescribe().get(objName + 'Share').newSObject();
            sh.put(objName + 'AccessLevel',shareLevel);
            sh.put(objName + 'Id', parentId);
            // AccountShare object has additional properties
            if(objName.equalsIgnoreCase('Account')) {
                // need to add access levels for Contacts, Opps and Cases to Account. if you
                // require EDIT for these child relationships, change here.
                //sh.put('ContactAccessLevel', 'READ');
                sh.put('CaseAccessLevel', 'READ');
                sh.put('OpportunityAccessLevel', 'READ');
            }
        }

        // general data
        sh.put('UserOrGroupId', userOrGroup);
        if(cause != null) {
            sh.put('RowCause', cause);
        }
        // add to list
        HMAShareWrapper wrapper = records.get(objName);
        if (wrapper == null) {
            wrapper = new HMAShareWrapper(objName);
            records.put(objName, wrapper);
        }
        wrapper.add(sh);
    }

    public void share() {
        try {
            for (String objName : records.keyset()) {
                System.debug(LoggingLevel.ERROR, records.get(objName).getAllShares());
                System.debug(LoggingLevel.ERROR, 'Object Name : ' + objName);
                Database.insert(records.get(objName).getAllShares(), false);
            }  
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            HMALogs__c log = new HMALogs__c(
                Type__c = 'Error',
                FullLog__c = ex.getMessage() + ex.getLineNumber(),
                Origin__c = 'EvaluationService',
                Notes__c = records.toString()
            );
            insert log;
        }
    }

    public void remove(SObject shareRecord, Id userOrGroup, String shareLevel, String cause) {
        // do not share a record with its owner - it results in an error
        if (shareRecord.get('OwnerId') == userOrGroup) {
            // do nothing
            return;
        }

        String objName = shareRecord.getSObjectType().getDescribe().getName();
        SObject sh;
        Id parentId = (Id) shareRecord.get('Id');

        // custom objects are different than standard
        if(objName.endsWithIgnoreCase('__c')) {
            sh = Schema.getGlobalDescribe().get(objName.replace('__c','__Share')).newSObject();
            sh.put('AccessLevel', shareLevel);
            sh.put('ParentId', parentId);
        }
        else {
            sh = Schema.getGlobalDescribe().get(objName + 'Share').newSObject();
            sh.put(objName + 'AccessLevel',shareLevel);
            sh.put(objName + 'Id', parentId);
            // AccountShare object has additional properties
            if(objName.equalsIgnoreCase('Account')) {
                // need to add access levels for Contacts, Opps and Cases to Account. if you 
                // require EDIT for these child relationships, change here. 
                //sh.put('ContactAccessLevel', 'READ');
                sh.put('CaseAccessLevel', 'READ');
                sh.put('OpportunityAccessLevel', 'READ');
            }
        }

        // general data
        sh.put('UserOrGroupId', userOrGroup);
        if(cause != null) {
            sh.put('RowCause', cause);
        }
        // mark record for deletion later. 
        if (recordsToDelete.get(objName) == null) {
            recordsToDelete.put(objName, new List<SObject>());
        }
        recordsToDelete.get(objName).add(sh);
    } 


    public void unshare() {
        // now we want to remove all the shares we have marked for deletion.

        Map<String, SObject> mapSharesByKey = new Map<String, SObject>();
        Map<String, HMAShareRemoveHelper> helpers = new Map<String, HMAShareRemoveHelper>();
        
        for (String objName : recordsToDelete.keyset()) {
            // create a helper for each object type
            // ShareRemoveHelper creating a unique key to be used in deleting the correct record
            // unique key is conctenation of recordToShare Id, userOrGroup Id, access level, and row cause 
            HMAShareRemoveHelper helper = new HMAShareRemoveHelper(objName);
            helpers.put(objName, helper);
            for (SObject record : recordsToDelete.get(objName)) {
                String key = helper.add(record);
                mapSharesByKey.put(key, record);
            }
        }

        // now for each object type being removed, get list of helpers and build up our
        // query string
        for (String objName : helpers.keyset()) {
            HMAShareRemoveHelper helper = helpers.get(objName);
            List<SObject> sharesToRemove = new List<SObject>();
            String soqlQuery = 'select Id, RowCause, UserOrGroupId, ';
            soqlQuery += helper.parentIdFieldName + ', ' + helper.shareLevelFieldName +
                    ' from ' + helper.shareObjectName + ' where UserOrGroupId in (' +
                    helper.getGranteeIds() + ') and ' + helper.parentIdFieldName + ' in (' +
                    helper.getParentIds() + ') and ' + helper.shareLevelFieldName + ' in (' +
                    helper.getShareLevels() + ')';
            for (SObject sobj : Database.query(soqlQuery)) {
                String key = sobj.get(helper.parentIdFieldName) + '_' + sobj.get('RowCause') +
                        '_' + sobj.get('UserOrGroupId') + '_' + sobj.get(helper.shareLevelFieldName);
                key = key.toLowerCase();
                if (mapSharesByKey.get(key) != null) {
                    sharesToRemove.add(sobj);
                }
            }
            if (!sharesToRemove.isEmpty()) {
                delete sharesToRemove;
            }
        }    
    }

    public Map<Id, AccountShare> getExistingAccountsSharesForAccounts(List<Account> accounts) {

        Map<Id, AccountShare> mapOfAccountShares = new Map<Id, AccountShare>();

        String sql = 'select Id, AccountId, UserOrGroupId, AccountAccessLevel from AccountShare where AccountId in :accounts';
        for(AccountShare accountShare:Database.query(sql)) {
            mapOfAccountShares.put(accountShare.UserOrGroupId, accountShare);
        }
        return mapOfAccountShares;
    }

    public Map<Id, ContactShare> getExistingContactSharesForContacts(List<Contact> contacts) {

        Map<Id, ContactShare> mapOfContactShares = new Map<Id, ContactShare>();

        String sql = 'select Id, ContactId, UserOrGroupId, ContactAccessLevel from ContactShare where ContactId in :contacts and RowCause = \'Manual\'';
        for(ContactShare contactShare:Database.query(sql)) {
            mapOfContactShares.put(contactShare.UserOrGroupId, contactShare);
        }
        return mapOfContactShares;
    }

     /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] changed from String to List<String> sharingReason
    */
    public  Map<Id, Map<String, SObject>> getExistingSharesForObject(List<SObject> objects, List<String> sharingReason) { //DPM-5426 changed from String to List<String> by MinheeKim - 24.03.19

        Map<Id, Map<String, SObject>> existingShareObjectMap = new Map<Id, Map<String, SObject>>();
        Map<Id, SObject> mapOfObjects = new Map<Id, SObject>();
        Set<Id> groupIds = new Set<Id>();

        String sql = 'select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from ' + this.objectName + ' where ParentId in :objects and RowCause IN :sharingReason'; //DPM-5426 added RowCause by minheekim - 24.03.19 
        for(SObject shareObject:Database.query(sql)) {
            mapOfObjects.put(shareObject.Id, shareObject);
            groupIds.add((Id)shareObject.get('UserOrGroupId'));
        }

        Map<Id, String> mapOfGroups = HMAQueryService.getPublicGroupMapById(groupIds);

        for(SObject share:mapOfObjects.values()) {
            Id parentId = (Id)share.get('ParentId');
            Id userOrGroupId = (Id)share.get('UserOrGroupId');
            String groupDeveloperName = mapOfGroups.get(userOrGroupId);

            if(groupDeveloperName != null) {
                if(!existingShareObjectMap.containsKey(parentId)) {
                    existingShareObjectMap.put(parentId, new Map<String, SObject>());
                }
                existingShareObjectMap.get(parentId).put(groupDeveloperName, share);
            }
            else if(userOrGroupId.getSObjectType() == Schema.User.getSObjectType()) {
                if(!existingShareObjectMap.containsKey(parentId)) {
                    existingShareObjectMap.put(parentId, new Map<String, SObject>());
                }
                existingShareObjectMap.get(parentId).put(userOrGroupId, share);
                System.debug('RowCause: '+share.get('RowCause'));
            }
        }

        return existingShareObjectMap;
    }
}