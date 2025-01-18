/**
    * [Class Description] Test class for COPPKPIDetailTriggerHandler
    * Created by [MinheeKim] on [2024-10-01] for [DPM-5700] 
   */    

@IsTest
private class COPPKPIDetailTriggerHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount1 = new Account(Name = 'Test Account 1');
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{ testAccount1, testAccount2 };
        
        COPPInfo__c coppInfo1 = new COPPInfo__c(Account__c = testAccount1.Id);
        insert coppInfo1;
        
        // Create test COPPKPI__c records
        List<COPPKPI__c> kpis = new List<COPPKPI__c>();
        for(Integer i = 0; i < 3; i++) {
            kpis.add(new COPPKPI__c(Name = 'KPI ' + i, Brand_Code__c = 'G', Section__c = 'Section ' + Math.mod( i, 2 ), KPI_Sequence__c = i));
        }
        insert kpis;

        // Create test COPPKPIDetail__c records
        List<COPPKPIDetail__c> kpiDetails = new List<COPPKPIDetail__c>();
        for(COPPKPI__c kpi : kpis) {
            kpiDetails.add(new COPPKPIDetail__c(Name = kpi.Name + ' Detail', COPP_KPI__c = kpi.Id, Account__c = testAccount1.Id));
            kpiDetails.add(new COPPKPIDetail__c(Name = kpi.Name + ' Detail', COPP_KPI__c = kpi.Id, Account__c = testAccount2.Id));
        }
        insert kpiDetails;
    }
    
    @IsTest
    static void testHandleBeforeInsertUpdate() {
        List<COPPKPIDetail__c> coppKpis = [SELECT Id, Account__c, COPPInfo__c FROM COPPKPIDetail__c];
        
        Map<Id, COPPKPIDetail__c> oldMap = new Map<Id, COPPKPIDetail__c>([SELECT Id, COPPInfo__c FROM COPPKPIDetail__c]);
        
        Test.startTest();
        COPPKPIDetailTriggerHelper.handleBeforeInsertUpdate(coppKpis, oldMap);
        update coppKpis;
        Test.stopTest();


    }
}