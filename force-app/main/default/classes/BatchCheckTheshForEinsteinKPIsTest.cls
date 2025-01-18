@isTest
public with sharing class BatchCheckTheshForEinsteinKPIsTest {


    @TestSetup
    static void makeData(){
		  CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;
        TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');

        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();
        
        KPI__c kpi = TestUtility.createKPI('TestKPI');
        EinsteinKPI__c einsteinKPI = TestUtility.createEinsteinKPI('TestKPI', kpi.Id, false);

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');
        update account;
    }

    static testMethod void testEinsteinService() {

        List<Account> accounts = [select Id, Region__c from Account];
        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c from EinsteinKPI__c where Active__c = true];

        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label1_Value_Num__c');
        insert mapping;
        
        KPIThreshold__c threshold = new KPIThreshold__c(KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPIMapping__c = mapping.Id, ActualObjectiveComparator__c = 'greater than', 
                                                            AbsoluteValueNumber__c = 122, EndDate__c = Date.today().addDays(30), EffectiveDate__c = Date.today().addDays(-30), 
                                                            Account__c = accounts[0].Id, AutoGenerateActionPlanForFailure__c = true);
        insert threshold;

        Evaluation__c evaluation = new Evaluation__c(Account__c = accounts[0].Id);
        insert evaluation;

        Action_Plan__c actionPlan = new Action_Plan__c(Evaluation__c = evaluation.Id, KPI__c = einsteinKPIs[0].KPI__c, Account__c = accounts[0].Id);
        insert actionPlan;
        
        TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);

        EinsteinKPIDetail__c einsteinKPIDetail = new EinsteinKPIDetail__c(Account__c = accounts[0].Id, KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPI__c = einsteinKPIs[0].Id, Label1__c = 'Test', Label1_Value_Num__c = 123, Label1_Value_Curr__c = 123, Label1_Value_Percent__c = 100, Label1_Value_Txt__c = '100');
        insert einsteinKPIDetail;

        Test.startTest();
        BatchCheckThesholdsForEinsteinKPIs batchJob = new BatchCheckThesholdsForEinsteinKPIs(einsteinKPIs[0].Id);
        Database.executeBatch(batchJob);
        Test.stopTest();
    }


    static testMethod void testEinsteinService2() {

        List<Account> accounts = [select Id, Region__c from Account];
        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c from EinsteinKPI__c where Active__c = true];

        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label1_Value_Num__c');
        insert mapping;

        Evaluation__c evaluation = new Evaluation__c(Account__c = accounts[0].Id);
        insert evaluation;

        RecordType recordType = [select Id from RecordType where DeveloperName = 'Region_Threshold'];
        
        KPIThreshold__c threshold = new KPIThreshold__c(KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPIMapping__c = mapping.Id, ActualObjectiveComparator__c = 'greater than', 
                                                            AbsoluteValueNumber__c = 122, EndDate__c = Date.today().addDays(30), EffectiveDate__c = Date.today().addDays(-30), 
                                                            Region__c = accounts[0].Region__c, AutoGenerateActionPlanForFailure__c = true, RecordTypeId = recordType.Id);
        insert threshold;
        
        TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);

        EinsteinKPIDetail__c einsteinKPIDetail = new EinsteinKPIDetail__c(Account__c = accounts[0].Id, KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPI__c = einsteinKPIs[0].Id, Label1__c = 'Test', Label1_Value_Num__c = 123, Label1_Value_Curr__c = 123, Label1_Value_Percent__c = 100, Label1_Value_Txt__c = '100');
        insert einsteinKPIDetail;

        Test.startTest();
        BatchCheckThesholdsForEinsteinKPIs batchJob = new BatchCheckThesholdsForEinsteinKPIs(einsteinKPIs[0].Id);
        Database.executeBatch(batchJob);
        Test.stopTest();
    }

    static testMethod void testEinsteinService3() {

        List<Account> accounts = [select Id, Region__c, Organization__c from Account];
        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c from EinsteinKPI__c where Active__c = true];

        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label1_Value_Num__c');
        insert mapping;

        Evaluation__c evaluation = new Evaluation__c(Account__c = accounts[0].Id);
        insert evaluation;

        RecordType recordType = [select Id from RecordType where DeveloperName = 'NationalHyundaiThreshold'];
        
        KPIThreshold__c threshold = new KPIThreshold__c(KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPIMapping__c = mapping.Id, ActualObjectiveComparator__c = 'greater than', 
                                                            AbsoluteValueNumber__c = 122, EndDate__c = Date.today().addDays(30), EffectiveDate__c = Date.today().addDays(-30), 
                                                            Organization__c = accounts[0].Organization__c, AutoGenerateActionPlanForFailure__c = true, RecordTypeId = recordType.Id);
        insert threshold;
        
        TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);

        EinsteinKPIDetail__c einsteinKPIDetail = new EinsteinKPIDetail__c(Account__c = accounts[0].Id, KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPI__c = einsteinKPIs[0].Id, Label1__c = 'Test', Label1_Value_Num__c = 123, Label1_Value_Curr__c = 123, Label1_Value_Percent__c = 100, Label1_Value_Txt__c = '100');
        insert einsteinKPIDetail;

        Test.startTest();
        BatchCheckThesholdsForEinsteinKPIs batchJob = new BatchCheckThesholdsForEinsteinKPIs(einsteinKPIs[0].Id);
        Database.executeBatch(batchJob);
        Test.stopTest();
    }


    static testMethod void testEinsteinService4() {

        List<Account> accounts = [select Id, Region__c, Organization__c from Account];
        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c from EinsteinKPI__c where Active__c = true];

        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label1_Value_Num__c');
        insert mapping;

        Evaluation__c evaluation = new Evaluation__c(Account__c = accounts[0].Id);
        insert evaluation;

        RecordType recordType = [select Id from RecordType where DeveloperName = 'NationalHyundaiThreshold'];
        
        KPIThreshold__c threshold = new KPIThreshold__c(KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPIMapping__c = mapping.Id, ActualObjectiveComparator__c = 'greater than', 
                                                            AbsoluteValueNumber__c = 122, EndDate__c = Date.today().addDays(30), EffectiveDate__c = Date.today().addDays(-30), 
                                                            Organization__c = accounts[0].Organization__c, AutoGenerateActionPlanForFailure__c = true, RecordTypeId = recordType.Id);
        insert threshold;

        KPIThreshold__c threshold2 = new KPIThreshold__c(KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPIMapping__c = mapping.Id, ActualObjectiveComparator__c = 'greater than', 
        AbsoluteValueNumber__c = 121, EndDate__c = Date.today().addDays(30), EffectiveDate__c = Date.today().addDays(-30), 
        Organization__c = accounts[0].Organization__c, AutoGenerateActionPlanForFailure__c = true, RecordTypeId = recordType.Id);
        insert threshold2;
        
        TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);

        EinsteinKPIDetail__c einsteinKPIDetail = new EinsteinKPIDetail__c(Account__c = accounts[0].Id, KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPI__c = einsteinKPIs[0].Id, Label1__c = 'Test', Label1_Value_Num__c = 123, Label1_Value_Curr__c = 123, Label1_Value_Percent__c = 100, Label1_Value_Txt__c = '100');
        insert einsteinKPIDetail;

        Test.startTest();
        BatchCheckThesholdsForEinsteinKPIs batchJob = new BatchCheckThesholdsForEinsteinKPIs(einsteinKPIs[0].Id);
        Database.executeBatch(batchJob);
        Test.stopTest();
    }


}