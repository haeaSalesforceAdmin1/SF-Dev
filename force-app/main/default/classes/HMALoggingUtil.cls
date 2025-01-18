/**
* @date 09/28/2020
* @description 
*/
public with sharing class HMALoggingUtil {

    public static List<HMALogs__c> logList;
    public static boolean success = true;
    public static boolean isInitialized = false;

    public static void initialize() {
        logList = new List<HMALogs__c>();
        isInitialized = true;
    }

    public static void addEventLogListItem(String content, String origin, String sfRecordID) {
        addItem('Event',
            new Map<String, String>{
                'content' => content,
                'origin' => origin,
                'sfRecordId' => sfRecordID
            }
        );
    }

    public static void addErrorLogListItem(String content, String origin) {
        addErrorLogListItem(content, origin, NULL);
    }

    public static void addErrorLogListItem(String content, String origin, String sourceRecordId) {
        addErrorLogListItem(content, origin, NULL, NULL);
    }

    public static void addErrorLogListItem(String eventContent, String eventSource, String sourceRecordId, Id apexJobId) {
        addItem('Error',
            new Map<String, String>{
                'content' => eventContent,
                'source' => eventSource,
                'sourceId' => sourceRecordId,
                'apexJobId' => apexJobId
            }
        );
    }

    private static void addItem(String type, Map<String, String> valuesMap) {
        if(!isInitialized) {
            System.debug(System.LoggingLevel.ERROR, 'LoggingUtil not initialized');
            return;
        }

        HMALogs__c item = new HMALogs__c(
            Type__c = type,
            FullLog__c = valuesMap.get('content'),
            Origin__c = valuesMap.get('origin'),
            SFRecordID__c = valuesMap.get('sfRecordID')
        );

        logList.add(item);
    }

    public static boolean logList() {
        System.debug(LoggingLevel.ERROR, LogList);
       boolean isSuccess = false;
        /*try {
            insert LogList;
            isSuccess = true;
            logList.clear();
        } 
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR,'Logging List Error: ' + ex.getStackTraceString());
            throw(ex);
        }*/
        
        return isSuccess;
    }
}