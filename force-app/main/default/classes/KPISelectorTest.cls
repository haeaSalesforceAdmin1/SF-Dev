@isTest
public without sharing class KPISelectorTest {


    @TestSetup
    static void makeData(){
        TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');

        TestUtility.createDPMConfigurationSettings();
        TestUtility.createCurrentEnvironmentCustomSetting();

        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();
        TestUtility.createQuarterlySettings();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL1', FirstName = 'TestF1'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2'));
        insert contacts;
        ContactTriggerHandler.run = true;

        User userGM = TestUtility.createExternalUser(contacts[0].Id, 'TestL1', 'TestF1', 'DPM Partner Community (Hyundai)');
        User userDP = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        
        account.GeneralManager__c = contacts[0].Id;
        account.DealerPrincipal__c = contacts[1].Id;
        account.Active__c = true;
        update account;

        List<RecordType> recordTypes = [select Id from RecordType where RecordType.DeveloperName = 'Survey_Topic'];
        List<Organization__c> organizations = [select Id, Name from Organization__c where Name = 'Hyundai'];
    }

    @IsTest
    static void testKPISelectorController(){
        
        List<Account> accounts = [select Id from Account];

        Survey__c survey = new Survey__c(Dealer__c = accounts[0].Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = accounts[0].Id, Survey__c = survey.Id, Type__c = 'Sales');
        insert evaluation;

        KPI__c kpi = new KPI__c(Name = 'Test Mandatory KPI');
        insert kpi;

        KPI__c optkpi = new KPI__c(Name = 'Test Optional KPI');
        insert optkpi;

        List<RecordType> recordTYpes = [select Id from RecordType where DeveloperName = 'Hyundai' and SObjectType = 'EinsteinKPI__c'];

        EinsteinKPI__c einsteinKPI = new EinsteinKPI__c(Name = 'Test Manadatory KPI',ranking__c=1, KPI__c = kpi.Id, ActionPlanRequirement__c = 'Mandatory', Division__c = 'Sales', Active__c = true, RecordTypeId = recordTYpes[0].Id);
        insert einsteinKPI;

        EinsteinKPI__c einsteinKPIOptional = new EinsteinKPI__c(Name = 'Test Optinal KPI',ranking__c=2, KPI__c = optkpi.Id, ActionPlanRequirement__c = 'Optional', Division__c = 'Sales', Active__c = true, RecordTypeId = recordTYpes[0].Id);
        insert einsteinKPIOptional;

        EinsteinKPIDetail__c detail = new EinsteinKPIDetail__c(Account__c = accounts[0].Id, EinsteinKPI__c = einsteinKPI.Id, KPI__c = kpi.Id);
        insert detail;

        EinsteinKPIDetail__c detail2 = new EinsteinKPIDetail__c(Account__c = accounts[0].Id, EinsteinKPI__c = einsteinKPIOptional.Id, KPI__c = optkpi.Id);
        insert detail2;

        EvaluationKPIs__c evalKPI = new EvaluationKPIs__c(Evaluation__c = evaluation.Id,  KPI__c = kpi.Id, EinsteinKPIDetail__c = detail.Id);
        insert evalKPI;

        EvaluationKPIs__c evalKPIOptional = new EvaluationKPIs__c(Evaluation__c = evaluation.Id,  KPI__c = optkpi.Id, EinsteinKPIDetail__c = detail2.Id);
        insert evalKPIOptional;

        Test.startTest();
        KPISelectorController.getEinsteinKPIDetailsForEvaluation(evaluation.Id);
        Test.stopTest();
        
    }

    static testMethod void testKPISelectorController2(){
        
        List<Account> accounts = [select Id from Account];

        Survey__c survey = new Survey__c(Dealer__c = accounts[0].Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = accounts[0].Id, Survey__c = survey.Id, Type__c = 'Sales');
        insert evaluation;

        KPI__c kpi = new KPI__c(Name = 'Test Mandatory KPI');
        insert kpi;

        KPI__c optkpi = new KPI__c(Name = 'Test Optional KPI');
        insert optkpi;

        List<RecordType> recordTYpes = [select Id from RecordType where DeveloperName = 'Hyundai' and SObjectType = 'EinsteinKPI__c'];

        EinsteinKPI__c einsteinKPI = new EinsteinKPI__c(Name = 'Test Manadatory KPI', KPI__c = kpi.Id, ActionPlanRequirement__c = 'Mandatory', Division__c = 'Sales', Active__c = true, RecordTypeId = recordTYpes[0].Id);
        insert einsteinKPI;

        EinsteinKPI__c einsteinKPIOptional = new EinsteinKPI__c(Name = 'Test Optinal KPI', KPI__c = optkpi.Id, ActionPlanRequirement__c = 'Optional', Division__c = 'Sales', Active__c = true, RecordTypeId = recordTYpes[0].Id);
        insert einsteinKPIOptional;

        EinsteinKPIDetail__c detail = new EinsteinKPIDetail__c(Account__c = accounts[0].Id, EinsteinKPI__c = einsteinKPI.Id, KPI__c = kpi.Id);
        insert detail;

        EinsteinKPIDetail__c detail2 = new EinsteinKPIDetail__c(Account__c = accounts[0].Id, EinsteinKPI__c = einsteinKPIOptional.Id, KPI__c = optkpi.Id);
        insert detail2;

        EvaluationKPIs__c evalKPI = new EvaluationKPIs__c(Evaluation__c = evaluation.Id,  KPI__c = kpi.Id, EinsteinKPIDetail__c = detail.Id);
        insert evalKPI;

        EvaluationKPIs__c evalKPIOptional = new EvaluationKPIs__c(Evaluation__c = evaluation.Id,  KPI__c = optkpi.Id, EinsteinKPIDetail__c = detail2.Id);
        insert evalKPIOptional;

        Test.startTest();
        evalKPI.ActionPlanReviewRequired__c = true;
        KPISelectorController.saveEvaluationKPIRecord(JSON.serialize(evalKPI));
        Test.stopTest();
        
    }
}