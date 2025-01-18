/**
 * Created by baltamimi on 2022-03-03.
 */

public without sharing class FieldHistoryCacheUtil {

    private static final String CACHE_KEY = 'fieldHistory';
    private static final String TRACKED_FIELDS_KEY = 'trackedFields';

    private static Map<String, FieldHistorySetting.FieldHistory> trackedFieldsBySObjectName;

    static {
        trackedFieldsBySObjectName = new Map<String, FieldHistorySetting.FieldHistory>();
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

    public static FieldHistorySetting.FieldHistory getFieldTrackingSetting(String sObjectType) {
        FieldHistorySetting.FieldHistory fieldTrackingSetting;
        Set<String> trackedFields = new Set<String>();

        if (String.isEmpty(sObjectType)) {
            fieldTrackingSetting = new FieldHistorySetting.FieldHistory(true, trackedFields, '', '');
        } else {
            trackedFieldsBySObjectName = (Map<String, FieldHistorySetting.FieldHistory>) Cache.Org.get(TRACKED_FIELDS_KEY);

            if (trackedFieldsBySObjectName == null || !trackedFieldsBySObjectName.containsKey(sObjectType)) {

                // Get the tracked fields from the system
                // We used SOQL query instead of simply using FieldHistorySetting__mdt md = (FieldHistorySetting__mdt)FieldHistorySetting__mdt.getInstance('ABC').FieldsNames__c; since this returns the first 255 char of long text
                List<FieldHistorySetting__mdt> fieldHistorySettings = FieldHistorySelector.getFieldHistorySetting(sObjectType);
                if (fieldHistorySettings != null && fieldHistorySettings.size() > 0) {
                    String trackedFieldsString = fieldHistorySettings[0].FieldsNames__c;
                    List<String> trackedFieldsList = trackedFieldsString.split(',');
                    for (String fieldName : trackedFieldsList) {
                        trackedFields.add(fieldName.trim());
                    }
                    fieldTrackingSetting = new FieldHistorySetting.FieldHistory(fieldHistorySettings[0].DisableHistoryTracking__c, trackedFields, fieldHistorySettings[0].FieldHistoryLookupField__c, fieldHistorySettings[0].AppName__c);
                } else {
                    fieldTrackingSetting = new FieldHistorySetting.FieldHistory(true, trackedFields, '', '');
                    System.debug('FieldHistoryUtil/getTrackedFields Error:: Untracked Object type (' + sObjectType + ')');
                }
            } else {
                fieldTrackingSetting = trackedFieldsBySObjectName.get(sObjectType);
            }

            updateTrackedFields(sObjectType, fieldTrackingSetting);
        }

        return fieldTrackingSetting;
    }

    // ------------- Util methods -------------
    private static void updateTrackedFields(String sObjectName, FieldHistorySetting.FieldHistory fieldTrackingSetting) {
        if (trackedFieldsBySObjectName == null) {
            trackedFieldsBySObjectName = new Map<String, FieldHistorySetting.FieldHistory>();
        }
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