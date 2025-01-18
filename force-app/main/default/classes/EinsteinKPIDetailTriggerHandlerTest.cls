@IsTest
public with sharing class EinsteinKPIDetailTriggerHandlerTest {

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

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');

        KPI__c kpi = TestUtility.createKPI('TestKPI');
        EinsteinKPI__c einsteinKPI = TestUtility.createEinsteinKPI('TestKPI', kpi.Id);

        EinsteinKPIDetail__c einsteinKPIDetail = new EinsteinKPIDetail__c(Account__c = account.Id, KPI__c = kpi.Id, EinsteinKPI__c = einsteinKPI.Id, Label1__c = 'Test', Label1_Value_Num__c = 123, Label1_Value_Curr__c = 123, Label1_Value_Percent__c = 100, Label1_Value_Txt__c = '100');
        insert einsteinKPIDetail;
    }

    static testMethod void testEinsteinKPIDetailCreateActionPlan() {
        List<EinsteinKPIDetail__c> einsteinKPIDetails = [select Id from EinsteinKPIDetail__c];
        einsteinKPIDetails[0].CreateActionPlan__c = true;

        Test.startTest();
        update einsteinKPIDetails;
        Test.stopTest();

        List<Action_Plan__c> actionPlans = [select Id from Action_Plan__c];
        System.assertEquals(1, actionPlans.size());
    }

    static testMethod void testEinsteinKPIDetailWillNotCreateActionPlan() {

        List<Account> accounts = [select Id from Account];
        List<KPI__c> kpis = [select Id from KPI__c];

        Action_Plan__c actionPlan = new Action_Plan__c(Account__c = accounts[0].Id, KPI__c = kpis[0].Id);
        insert actionPlan;

        List<EinsteinKPIDetail__c> einsteinKPIDetails = [select Id from EinsteinKPIDetail__c];
        einsteinKPIDetails[0].CreateActionPlan__c = true;

        Test.startTest();
        update einsteinKPIDetails;
        Test.stopTest();

        List<Action_Plan__c> actionPlans = [select Id from Action_Plan__c];
        //System.assertEquals(1, actionPlans.size());
    }

    static testMethod void testEinsteinKPIDetailDelete() {
        List<EinsteinKPIDetail__c> einsteinKPIDetails = [select Id from EinsteinKPIDetail__c];
        delete einsteinKPIDetails;
    }
}