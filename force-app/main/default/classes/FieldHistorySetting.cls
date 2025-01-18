/**
 * Created by baltamimi on 2022-03-14.
 */

public without sharing class FieldHistorySetting {
    @TestVisible
    private static FieldHistory FieldHistorySetting;

    public static Set<String> trackedFields(String sObjectType) {
        if (FieldHistorySetting == null) {
            getFieldHistory(sObjectType);
        }
        return FieldHistorySetting?.fields;
    }

    public static Boolean isDisabled(String sObjectType) {
        if (FieldHistorySetting == null) {
            getFieldHistory(sObjectType);
        }
        return FieldHistorySetting?.stopFieldTracking;
    }

    public static String getLookupFieldName(String sObjectType) {
        if (FieldHistorySetting == null) {
            getFieldHistory(sObjectType);
        }
        return FieldHistorySetting.lookupFieldName;
    }
    public static String getAppName(String sObjectType) {
        if (FieldHistorySetting == null) {
            getFieldHistory(sObjectType);
        }
        return FieldHistorySetting.appName;
    }

    private static void getFieldHistory(String sObjectType) {
        FieldHistorySetting = FieldHistoryCacheUtil.getFieldTrackingSetting(sObjectType);
    }

    public class FieldHistory {
        public Boolean stopFieldTracking { get; set; }
        public Set<String> fields { get; set; }
        public String lookupFieldName { get; set; }
        public String appName { get; set; }

        public FieldHistory(Boolean stopFieldTracking, Set<String> fields, String lookupFieldName, String appName) {
            this.stopFieldTracking = stopFieldTracking;
            this.fields = fields;
            this.lookupFieldName = lookupFieldName.toLowerCase();
            this.appName = appName;
        }
    }

}