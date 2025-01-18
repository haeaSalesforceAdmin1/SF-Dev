/**
 * Created by baltamimi on 2022-03-14.
 */

public without sharing class RRPFieldHistorySetting {
    @TestVisible
    private static FieldHistory RRPFieldHistorySetting;

    public static Set<String> trackedFields(String sObjectType) {
        if (RRPFieldHistorySetting == null) {
            getFieldHistory(sObjectType);
        }
        return RRPFieldHistorySetting?.fields;
    }

    public static Boolean isDisabled(String sObjectType) {
        System.debug('test:::::::::::::'+RRPFieldHistorySetting);
        if (RRPFieldHistorySetting == null) {
            getFieldHistory(sObjectType);
        }
        return RRPFieldHistorySetting?.stopFieldTracking;
}

    public static String getLookupFieldName(String sObjectType) {
        if (RRPFieldHistorySetting == null) {
            getFieldHistory(sObjectType);
        }
        return RRPFieldHistorySetting.lookupFieldName;
    }
    public static String getAppName(String sObjectType) {
        if (RRPFieldHistorySetting == null) {
            getFieldHistory(sObjectType);
        }
        return RRPFieldHistorySetting.appName;
    }

    private static void getFieldHistory(String sObjectType) {
        RRPFieldHistorySetting = RRPFieldHistoryCacheUtil.getFieldTrackingSetting(sObjectType);
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