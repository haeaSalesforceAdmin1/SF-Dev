@isTest
public with sharing class EinsteinKPIMappingTriggerHandlTest {

    @TestSetup
    static void makeData(){
        TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');

        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();
        
        KPI__c kpi = TestUtility.createKPI('TestKPI');
        EinsteinKPI__c einsteinKPI = TestUtility.createEinsteinKPI('TestKPI', kpi.Id);

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');
        update account;
    }

    static testMethod void testEinsteinKPIMappingTriggerHandler() {
        
        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, TotalSAQLsToExecute__c from EinsteinKPI__c where Active__c = true];
        List<EinsteinKPIMapping__c> einsteinMappings = TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);
        
        Test.startTest();
        update einsteinMappings;
        Test.stopTest();
    }

    static testMethod void testEinsteinKPIMappingTriggerHandlerNoRun() {
        EinsteinKPIMappingTriggerHandler.run = false;
        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, TotalSAQLsToExecute__c from EinsteinKPI__c where Active__c = true];
        List<EinsteinKPIMapping__c> einsteinMappings = TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);
        
        Test.startTest();
        update einsteinMappings;
        Test.stopTest();
    }

    static testMethod void testEinsteinKPIMappingTriggerHandlerDelete() {
        
        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, TotalSAQLsToExecute__c from EinsteinKPI__c where Active__c = true];
        List<EinsteinKPIMapping__c> einsteinMappings = TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);
        
        Test.startTest();
        delete einsteinMappings;
        Test.stopTest();
    }

    static testMethod void testEinsteinKPIMappingTriggerHandlerDeleteNoRun() {
        
        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, TotalSAQLsToExecute__c from EinsteinKPI__c where Active__c = true];
        List<EinsteinKPIMapping__c> einsteinMappings = TestUtility.createEinsteinKPIMappings(einsteinKPIs[0].Id);
        
        Test.startTest();
        EinsteinKPIMappingTriggerHandler.run = false;
        delete einsteinMappings;
        Test.stopTest();
    }

    static testMethod void testEinsteinKPIMappingTriggerHandlerUndelete() {
        EinsteinKPIMappingTriggerHandler triggerHandler = new EinsteinKPIMappingTriggerHandler();
        triggerHandler.afterUndelete(null);
    }   
}