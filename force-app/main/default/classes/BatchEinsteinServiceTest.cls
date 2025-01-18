@isTest
public with sharing class BatchEinsteinServiceTest {


    @TestSetup
    static void makeData(){

        TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');

        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();
        
        KPI__c kpi = TestUtility.createKPI('TestKPI');
        KPI__c kpi1 = TestUtility.createKPI('TestKPI1');

        EinsteinKPI__c einsteinKPI = TestUtility.createAPEinsteinKPI('TestKPI', kpi.Id);
        EinsteinKPI__c einsteinKPI1 = TestUtility.createAPEinsteinKPI('TestKPI2', kpi1.Id);

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');
        update account;
    }

    static testMethod void testEinsteinService() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];


        TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);

        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label2_Value_Num__c');
        insert mapping;

        EinsteinKPIMapping__c mapping2 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Percent', Object_Field__c = 'Label3_Value_Percent__c');
        insert mapping2;

        EinsteinKPIMapping__c mapping3 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Currency', Object_Field__c = 'Label3_Value_Curr__c');
        insert mapping3;
      

        Test.startTest();
       //  BatchEinsteinService2 batchEinsteinJob1 = new BatchEinsteinService2();
       //  batchEinsteinJob1.processAdminEinsteinKPIs(einsteinKPIs[1]);
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
       // einsteinKPIs[0].DetailKey__c='';
        BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2(einsteinKPIs[0].Id);
        batchEinsteinJob.start(null);
        batchEinsteinJob.execute(null, einsteinKPIs);
       
        //batchEinsteinJob.finish(null);
        Test.stopTest();
    }
     static testMethod void testEinsteinService1() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
         BatchEinsteinService2 batchEinsteinJob1 = new BatchEinsteinService2();
         batchEinsteinJob1.processAdminEinsteinKPIs(einsteinKPIs[0]);
         Test.stopTest();

     
     }

    static testMethod void testEinsteinServiceScheduleServiceForDailyProcess() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                            KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];
        TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);
        BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2();
        batchEinsteinJob.dailyBatchProcess = true;
        batchEinsteinJob.totalSAQL = null;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
        batchEinsteinJob.finish(null);
        Test.stopTest();
    }

    static testMethod void testEinsteinServiceCallBatchAgainWhenCurrentSAQLLesssThenTotalSAQL() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                            TotalSAQLsToExecute__c, KPI__r.Category__c, KPI__r.SubCategory__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];
        TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);

        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label2_Value_Num__c');
        insert mapping;

        BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2();
        batchEinsteinJob.dailyBatchProcess = true;
        batchEinsteinJob.currentSAQL = 1;
        batchEinsteinJob.totalSAQL = 3;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
        batchEinsteinJob.finish(null);
        Test.stopTest();
    }

    static testMethod void testEinsteinServiceCallBatchAgainWhenCurrentSAQEqualTotalSAQL2() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];
        TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);
        List<Account> accounts = [select Id from Account];
    
        EinsteinKPIDetail__c einsteinKPIDetail = new EinsteinKPIDetail__c(Account__c = accounts[0].Id,  EinsteinKPI__c = einsteinKPIs[0].Id, Label1__c = 'Test', Label1_Value_Num__c = 123, Label1_Value_Curr__c = 123, Label1_Value_Percent__c = 100, Label1_Value_Txt__c = '100');
        insert einsteinKPIDetail;

        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label2_Value_Num__c');
        insert mapping;

        BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2();
        batchEinsteinJob.dailyBatchProcess = true;
        batchEinsteinJob.currentSAQL = 3;
        batchEinsteinJob.totalSAQL = 3;
        batchEinsteinJob.einsteinKPIId = einsteinKPIs[0].Id;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
        batchEinsteinJob.finish(null);
        Test.stopTest();
    }

    static testMethod void testEinsteinServiceCallBatchAgainWhenCurrentSAQEqualTotalSAQL() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];
        TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);
        List<Account> accounts = [select Id from Account];
    
        EinsteinKPIDetail__c einsteinKPIDetail = new EinsteinKPIDetail__c(Account__c = accounts[0].Id,  EinsteinKPI__c = einsteinKPIs[0].Id, Label1__c = 'Test', Label1_Value_Num__c = 123, Label1_Value_Curr__c = 123, Label1_Value_Percent__c = 100, Label1_Value_Txt__c = '100');
        insert einsteinKPIDetail;

        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label2_Value_Num__c');
        insert mapping;

        BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2();
        batchEinsteinJob.dailyBatchProcess = true;
        batchEinsteinJob.currentSAQL = 3;
        batchEinsteinJob.totalSAQL = 3;
        batchEinsteinJob.einsteinKPIId = einsteinKPIs[0].Id;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
        batchEinsteinJob.finish(null);
        Test.stopTest();
    }
    
    static testMethod void testEinsteinService2() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];


        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label2_Value_Num__c', KPI_Field__c = 'A');
        insert mapping;

        EinsteinKPIMapping__c mapping2 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Percent', Object_Field__c = 'Label3_Value_Percent__c', KPI_Field__c = 'B');
        insert mapping2;

        EinsteinKPIMapping__c mapping3 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Currency', Object_Field__c = 'Label3_Value_Curr__c', KPI_Field__c = 'C');
        insert mapping3;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
        BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2(einsteinKPIs[0].Id);
        batchEinsteinJob.start(null);
        batchEinsteinJob.execute(null, einsteinKPIs);
        //batchEinsteinJob.finish(null);
        Test.stopTest();
    }

    static testMethod void testEinsteinService3() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];


        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Number', Object_Field__c = 'Label2_Value_Num__c', KPI_Field__c = 'A');
        insert mapping;

        EinsteinKPIMapping__c mapping2 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Percent', Object_Field__c = 'Label3_Value_Percent__c', KPI_Field__c = 'B');
        insert mapping2;

        EinsteinKPIMapping__c mapping3 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Currency', Object_Field__c = 'Label3_Value_Curr__c', KPI_Field__c = 'C');
        insert mapping3;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
        BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2(einsteinKPIs[0].Id);
        batchEinsteinJob.start(null);
        batchEinsteinJob.execute(null, einsteinKPIs);
        //batchEinsteinJob.finish(null);
        Test.stopTest();
    }

    static testMethod void testEinsteinService4() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];


        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Number', Object_Field__c = 'Label2_Value_Num__c', KPI_Field__c = 'A');
        insert mapping;

        EinsteinKPIMapping__c mapping2 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Percent', Object_Field__c = 'Label3_Value_Percent__c', KPI_Field__c = 'B');
        insert mapping2;

        EinsteinKPIMapping__c mapping3 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Currency', Object_Field__c = 'Label3_Value_Curr__c', KPI_Field__c = 'C');
        insert mapping3;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
        BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2(einsteinKPIs[0].Id);
        batchEinsteinJob.start(null);
        batchEinsteinJob.execute(null, einsteinKPIs);
        //batchEinsteinJob.finish(null);
        Test.stopTest();
    }

    static testMethod void testEinsteinService5() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];


        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Number', Object_Field__c = 'Label2_Value_Num__c', KPI_Field__c = 'A');
        insert mapping;

        EinsteinKPIMapping__c mapping2 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Percent', Object_Field__c = 'Label3_Value_Percent__c', KPI_Field__c = 'B');
        insert mapping2;

        EinsteinKPIMapping__c mapping3 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Currency', Object_Field__c = 'Label3_Value_Curr__c', KPI_Field__c = 'C');
        insert mapping3;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
        BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2(new List<String>{einsteinKPIs[0].KPI__c});
        batchEinsteinJob.start(null);
        batchEinsteinJob.execute(null, einsteinKPIs);
        batchEinsteinJob.finish(null);
        Test.stopTest();
    }

    static testMethod void testEinsteinService6() {

        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c, RecordType.DeveloperName from EinsteinKPI__c where Active__c = true];


        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Number', Object_Field__c = 'Label2_Value_Num__c', KPI_Field__c = 'A');
        insert mapping;

        EinsteinKPIMapping__c mapping2 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = false, Type__c = 'Percent', Object_Field__c = 'Label3_Value_Percent__c', KPI_Field__c = 'B');
        insert mapping2;

        EinsteinKPIMapping__c mapping3 = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Currency', Object_Field__c = 'Label3_Value_Curr__c', KPI_Field__c = 'C');
        insert mapping3;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());
        BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2(new List<String>{einsteinKPIs[0].KPI__c});
        batchEinsteinJob.currentSAQL = 5;
        batchEinsteinJob.finish(null);
        Test.stopTest();
    }
}