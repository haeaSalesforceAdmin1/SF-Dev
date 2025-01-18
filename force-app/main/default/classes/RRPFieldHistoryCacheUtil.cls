/**
 * Created by baltamimi on 2022-03-03.
 */

public without sharing class RRPFieldHistoryCacheUtil {

    private static final String CACHE_KEY = 'CMTFieldHistory';
    private static final String TRACKED_FIELDS_KEY = 'CMTtrackedFields';

    private static Map<String, RRPFieldHistorySetting.FieldHistory> trackedFieldsBySObjectName;

    static {
        trackedFieldsBySObjectName = new Map<String, RRPFieldHistorySetting.FieldHistory>();
    }

    public static void updateContext(Context ctx) {
        Cache.Org.put(CACHE_KEY, ctx, 300);
    }

    public static Context getContext() {
        return (Context) Cache.Org.get(CACHE_KEY);
    }

    public static void resetContext() {
        Context ctx = new Context();
        Cache.Org.put(CACHE_KEY, ctx, 300);
    }

    public static RRPFieldHistorySetting.FieldHistory getFieldTrackingSetting(String sObjectType) {
        RRPFieldHistorySetting.FieldHistory fieldTrackingSetting;
        Set<String> trackedFields = new Set<String>();
        System.debug('sObjectType:::::::::::::'+sObjectType);
        
        if (String.isEmpty(sObjectType) ) {
            fieldTrackingSetting = new RRPFieldHistorySetting.FieldHistory(true, trackedFields, '', '');
        } else {
            /**
            * @description : RRP Project
            * @author San, Kang : SanKang@autoeveramerica.com 
            */
            System.debug('test::::::::::::::::::::'+Cache.Org.get(TRACKED_FIELDS_KEY));
            if(sObjectType == 'RRP__c'){sObjectType = 'RRP';}
            else{sObjectType = 'WorkOrder';} // STIL Project 2024-06-06 Kang, San
                trackedFieldsBySObjectName = (Map<String, RRPFieldHistorySetting.FieldHistory>) Cache.Org.get(TRACKED_FIELDS_KEY);
            if (trackedFieldsBySObjectName == null || !trackedFieldsBySObjectName.containsKey(sObjectType)) {

                // Get the tracked fields from the system
                List<CMTFieldHistorySetting__mdt> fieldHistorySettings = RRPFieldHistorySelector.getFieldHistorySetting(sObjectType);
                if (fieldHistorySettings != null && fieldHistorySettings.size() > 0) {
                    String trackedFieldsString = fieldHistorySettings[0].FieldsNames__c;
                    List<String> trackedFieldsList = trackedFieldsString.split(',');
                    for (String fieldName : trackedFieldsList) {
                        trackedFields.add(fieldName.trim());
                    }
                    fieldTrackingSetting = new RRPFieldHistorySetting.FieldHistory(fieldHistorySettings[0].DisableHistoryTracking__c, trackedFields, fieldHistorySettings[0].FieldHistoryLookupField__c, fieldHistorySettings[0].AppName__c);
                } else {
                    fieldTrackingSetting = new RRPFieldHistorySetting.FieldHistory(true, trackedFields, '', '');
                    System.debug('CMTFieldHistoryUtil/getTrackedFields Error:: Untracked Object type (' + sObjectType + ')');
                }
            } else {
                fieldTrackingSetting = trackedFieldsBySObjectName.get(sObjectType);
            }

            updateTrackedFields(sObjectType, fieldTrackingSetting);
        }

        return fieldTrackingSetting;
    }

    // ------------- Util methods -------------
    private static void updateTrackedFields(String sObjectName, RRPFieldHistorySetting.FieldHistory fieldTrackingSetting) {
        if (trackedFieldsBySObjectName == null) {
            trackedFieldsBySObjectName = new Map<String, RRPFieldHistorySetting.FieldHistory>();
        }
        System.debug('sObject::::::::::::'+sObjectName);
        System.debug('fieldTrackingSetting::::::::::::'+fieldTrackingSetting);
        trackedFieldsBySObjectName.put(sObjectName, fieldTrackingSetting);
        Cache.Org.put(TRACKED_FIELDS_KEY, trackedFieldsBySObjectName, 300);
    }

    // ------------- Inner Classes -------------
    public class Context {
        public String sentContext;
        public String sObjectType;
        public String runBy;

        public Context(String sentContext, String sObjectType, String runBy) {
            this.sentContext = sentContext;
            this.sObjectType = sObjectType;
            this.runBy = runBy;
        }

        public Context() {
            this.sentContext = '';
            this.sObjectType = '';
            this.runBy = '';
        }
    }
}