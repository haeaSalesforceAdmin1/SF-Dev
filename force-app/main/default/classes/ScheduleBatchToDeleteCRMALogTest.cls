@IsTest
public with sharing class ScheduleBatchToDeleteCRMALogTest {

    @IsTest
    static void testScheduleBatch() {

        Integer monthsToKeep;

        HCUV_Configuration__mdt mdt = [SELECT Value__c FROM HCUV_Configuration__mdt WHERE DeveloperName = 'CRMALog_Retention_Month' LIMIT 1];
        monthsToKeep = mdt != null ? Integer.valueOf(mdt.Value__c) : 12; //default value

        // Create sample CRMALog data
        List<CRMALog__c> logs = new List<CRMALog__c>();
        for (Integer i = 0; i < 5; i++) {
            logs.add(new CRMALog__c(AppType__c = 'CUV', CreatedDate = System.now().addMonths(-13)));
        }
        insert logs;

        Test.startTest();
        ScheduleBatchToDeleteCRMALog scheduler = new ScheduleBatchToDeleteCRMALog();
        scheduler.execute(null);
        Test.stopTest();

        Datetime purgeDate = System.now().addMonths(-monthsToKeep);
        System.debug('purgeDate : '+purgeDate);

        List<CRMALog__c> oldLogs = [SELECT Id
                                    FROM CRMALog__c
                                    WHERE AppType__c = 'CUV'
                                    AND CreatedDate < :purgeDate];
        System.debug('oldLogs : '+oldLogs);
        System.assertEquals(0, oldLogs.size(), 'Expected no log records older than 12 months');
    }
}