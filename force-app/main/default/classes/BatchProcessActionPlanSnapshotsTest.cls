@isTest
public with sharing class BatchProcessActionPlanSnapshotsTest {


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
        EinsteinKPI__c einsteinKPI = TestUtility.createEinsteinKPI('TestKPI', kpi.Id);
        kpi.EinsteinKPI__c = einsteinKPI.Id;
        update kpi;

        TestUtility.createEinsteinKPIMappings(einsteinKPI.Id);
        //TestUtility.create

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG,'A0001' );
        update account;

        List<Account> accounts = [select Id from Account];
        List<KPI__c> kpis = [select Id from KPI__c];

        Action_PlanTriggerHandler.run = false;
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Account__c = accounts[0].Id, KPI__c = kpis[0].Id, RefreshKPI__c = true);
        insert actionPlan;
        Action_PlanTriggerHandler.run = true;

    }

    @isTest 
    static void testBatchProcessActionPlanSnapshots1() {

        List<Action_Plan__c> actionPlans = [select Id, DealerCode__c, KPI__c, CurrentKPISnapshotValue__c, PreviousKPISnapshotValue__c, InitialKPISnapshotValue__c, EinsteinKPIDetail__r.KPISummary__c from Action_Plan__c];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());

        BatchProcessActionPlanSnapshots batchProcess = new BatchProcessActionPlanSnapshots();
        batchProcess.start(null);
        batchProcess.execute(null, actionPlans);
        batchProcess.finish(null);
        Test.stopTest();

    }

    @isTest 
    static void testBatchProcessActionPlanSnapshots2() {

        List<Action_Plan__c> actionPlans = [select Id, DealerCode__c, KPI__c, CurrentKPISnapshotValue__c, PreviousKPISnapshotValue__c, InitialKPISnapshotValue__c, EinsteinKPIDetail__r.KPISummary__c from Action_Plan__c];
        actionPlans[0].InitialKPISnapshotValue__c = 'xxxxxx';
        update actionPlans;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());

        BatchProcessActionPlanSnapshots batchProcess = new BatchProcessActionPlanSnapshots(new Set<Id>{actionPlans[0].Id});
        batchProcess.start(null);
        batchProcess.execute(null, actionPlans);
        batchProcess.finish(null);
        Test.stopTest();

    }

    @isTest
    static void testBatchProcessActionPlanSnapshots3() {

        List<Action_Plan__c> actionPlans = [select Id, DealerCode__c, KPI__c, CurrentKPISnapshotValue__c, PreviousKPISnapshotValue__c, InitialKPISnapshotValue__c, EinsteinKPIDetail__r.KPISummary__c from Action_Plan__c];
        actionPlans[0].InitialKPISnapshotValue__c = 'xxxxxx';
        update actionPlans;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());

        BatchProcessActionPlanSnapshots batchProcess = new BatchProcessActionPlanSnapshots(new List<Id>{actionPlans[0].KPI__c});
        batchProcess.start(null);
        batchProcess.execute(null, actionPlans);
        batchProcess.finish(null);
        Test.stopTest();

    }

    @isTest
    static void testBatchProcessActionPlanSnapshots4() {

        List<Action_Plan__c> actionPlans = [select Id, DealerCode__c, KPI__c, CurrentKPISnapshotValue__c, PreviousKPISnapshotValue__c, InitialKPISnapshotValue__c, EinsteinKPIDetail__r.KPISummary__c, EinsteinKPIDetail__c from Action_Plan__c];
        actionPlans[0].InitialKPISnapshotValue__c = 'xxxxxx';
        update actionPlans;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EinsteinCalloutMock());

        BatchProcessActionPlanSnapshots batchProcess = new BatchProcessActionPlanSnapshots(actionPlans[0].EinsteinKPIDetail__c);
        batchProcess.start(null);
        batchProcess.execute(null, actionPlans);
        batchProcess.finish(null);
        Test.stopTest();

    }
}