@isTest
public with sharing class BatchRollOverActionPlansTest {

    @TestSetup
    static void makeData(){
			 CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;
        User user1 = TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');
        User user2 = TestUtility.createInternalUser('TestOwnerUser2', 'TestOwnerUser2', 'System Administrator');
        User user3 = TestUtility.createInternalUser('TestOwnerUser3', 'TestOwnerUser3', 'System Administrator');

        TestUtility.createOrganizations();
        List<Region__c> regions = TestUtility.createRegionsForOrganizations(TestUtility.HYUNDIA_ORG);
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, TestUtility.DEALER_CODE);
        Contact contact = new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF',Email='test1@email.com');
        insert contact;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2',Email='test3@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

      //  account.GenesisAreaManager__c = contact.Id;
        account.DealerPrincipal__c = contact.Id;
        account.MarketManager__c = user2.Id;
        //account.GenesisAreaManager__c = user3.Id;
        HMAObjectService.dbUpdate(account);

        User user4 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');

       // GenesisArea__c genArea = TestUtility.createGenesisArea('GMA SOUTH', 'GS', user2.Id, genOrg.Id);
        HyundaiArea__c hyundaiArea = TestUtility.createHyundaiArea('Test Hyundai Area', '234', hyundaiOrg.Id, regions[0].Id);
//  District__c genesisDistrict = new District__c(Name = 'SELECT SOUTH 2', Organization__c = genOrg.Id, GenesisArea__c = genArea.Id );
      //  insert genesisDistrict;
    }


    static testMethod void testBatchRollOverActionPlan() {
        List<RecordType> recordTypes = [select Id from RecordType where SObjectType = 'Action_Plan__c' and DeveloperName != 'Other'];

        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        List<Account> accounts = [select Id from Account];
        List<User> users = [select Id from User];
        Date yesterday = Date.today().addDays(-1);
        Date dateInitiated = Date.today().addDays(-32);
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan',  Status__c = 'Open', Account__c = accounts[0].Id, OwnerId = testOwnerUser.Id, DueDate__c = yesterday, DateInitiated__c = dateInitiated);
        actionPlan.RecordTypeId = recordTypes[0].Id;
        insert actionPlan;

        Test.startTest();
        
        BatchRollOverActionPlans batchJob = new BatchRollOverActionPlans();
        Database.executeBatch(batchJob, 1);

        Test.stopTest();
    }

    static testMethod void testBatchRollOverActionPlanSchedule() {
        List<RecordType> recordTypes = [select Id from RecordType where SObjectType = 'Action_Plan__c' and DeveloperName != 'Other'];

        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        List<Account> accounts = [select Id from Account];
        List<User> users = [select Id from User];
        Date yesterday = Date.today().addDays(-1);
        Date dateInitiated = Date.today().addDays(-32);
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan',  Status__c = 'Open',  Account__c = accounts[0].Id, OwnerId = testOwnerUser.Id, DueDate__c = yesterday, DateInitiated__c = dateInitiated);
        actionPlan.RecordTypeId = recordTypes[0].Id;
        insert actionPlan;

        Test.startTest();
        
        ScheduleRollOverActionPlans scheduleRollOver = new ScheduleRollOverActionPlans();
        scheduleRollOver.execute(null);

        Test.stopTest();
    }


    static testMethod void testBatchRollOverActionPlanRelatedToEvaluation() {
        List<RecordType> recordTypesAP = [select Id, DeveloperName from RecordType where SObjectType = 'Action_Plan__c' and DeveloperName != 'Other'];
        List<RecordType> recordTypesEval = [select Id from RecordType where SObjectType = 'Evaluation__c' and DeveloperName = :recordTypesAP[0].DeveloperName];

        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        Contact contact = [select Id from Contact where LastName = 'TestL2'];
        List<Account> accounts = [select Id from Account];
        List<User> users = [select Id from User];
        Date yesterday = Date.today().addDays(-1);
        Date dateInitiated = Date.today().addDays(-32);


        Evaluation__c evaluationClosed = new Evaluation__c(Status__c = 'Closed', Account__c = accounts[0].Id, StartDate__c = Date.today().addDays(-50), EndDate__c = Date.today().addDays(-22));
        evaluationClosed.RecordTypeId = recordTypesEval[0].Id;
        insert evaluationClosed;

        Evaluation__c evaluationOpen = new Evaluation__c(Status__c = 'Open', Account__c = accounts[0].Id, StartDate__c = Date.today(), EndDate__c = Date.today().addDays(22));
        evaluationOpen.RecordTypeId = recordTypesEval[0].Id;
        insert evaluationOpen;

        Action_PlanTriggerHandler.run = false;
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Status__c = 'In Progress', Account__c = accounts[0].Id, OwnerId = testOwnerUser.Id, DueDate__c = yesterday, DateInitiated__c = dateInitiated, Evaluation__c = evaluationClosed.Id);
        actionPlan.RecordTypeId = recordTypesAP[0].Id;
        insert actionPlan;

        actionPlan.DueDate__c = Date.today().addDays(-5);
        update actionPlan;
        Action_PlanTriggerHandler.run = true;

        Action_Plan__c ap = [select Id, Status__c, Evaluation__c, DueDate__c, DateInitiated__c, Account__c from Action_Plan__c limit 1];
        System.debug(LoggingLevel.ERROR, ap);

        Evaluation__c evaluation = [select Id, Status__c, RecordType.DeveloperName from Evaluation__c limit 1];
        System.debug(LoggingLevel.ERROR, evaluation);

        Test.startTest();
        
        BatchRollOverActionPlans batchJob = new BatchRollOverActionPlans();
        Database.executeBatch(batchJob, 1);

        Test.stopTest();
    }

}