@IsTest
public with sharing class ActionPlanServiceTest {
    @TestSetup
    static void makeData(){
        CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;

        TestUtility.createOrganizations();
        List<Region__c> regions = TestUtility.createRegionsForOrganizations(TestUtility.HYUNDIA_ORG);
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, TestUtility.DEALER_CODE);
    }

    static testMethod void testActionPlanService() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

//        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant'));
        /*actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/
        insert actionPlans;
        String tes = ActionPlanApprovalController.handleActionPlanApprovals(actionPlans[0].id, 'Submit', 'Test', 'Approved');
    }

    static testMethod void testActionPlanServiceRollup2() {
        Account account = [select id from Account limit 1];
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0001';
        update account;
        //Account account = new Account();
        //account.Name = 'Test Account';
        //account.DealerCode__c = 'A0001';
        //insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        //User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)');
        //User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
//        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
//        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;
        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;


        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        /*actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/
        insert actionPlans;
        Test.startTest();
        actionPlans[0].Is_Region_Sent_Back__c=true;
        actionPlans[0].ApprovalStatus__c='Sent Back';
        update actionPlans;
        String tes = ActionPlanApprovalController.handleActionPlanApprovals(actionPlans[0].id, 'Reject', 'Test', 'Non-Compliant');
        Test.stopTest();
    }

    /*static testMethod void testActionPlanServiceRollup3() {
        Account account = [select id from Account limit 1];
        account.Name = 'Test Account';
        update account;
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

//        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
    
        insert actionPlans;
        actionPlans[0].Is_District_Sent_Back__c=true;
        actionPlans[0].ApprovalStatus__c='District Approved';
        update actionPlans;
        String tes = ActionPlanApprovalController.handleActionPlanApprovals(actionPlans[0].id, 'Reject', 'Test', 'Completed');

    }*/

    static testMethod void testActionPlanServiceRollup4() {
        Account account = [select id from Account limit 1];
        account.Name = 'Test Account';
        account.RegionCodePicklist__c='SO';
        update account;
        //Account account = new Account();
        //account.Name = 'Test Account';
        //account.RegionCodePicklist__c='SO';
        //insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

//        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Submitted for District Approval'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/
        insert actionPlans;
        String tes = ActionPlanApprovalController.handleActionPlanApprovals(actionPlans[0].id, 'Submitted for District Approval', 'Test', 'Submitted for District Approval');

        list<string> regionCodes= new list<string>();
        regionCodes.add('SO');

        Map<String, List<ObjectAccess__mdt>> objectAcess= HMAQueryService.getObjectAccessTypes('Region', 'Evaluation__c', regionCodes);
    }

    static testMethod void testActionPlanServiceRollup5() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

//        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Submitted for Regional Approval'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/
        insert actionPlans;
        actionPlans[0].Is_District_Sent_Back__c=true;
        actionPlans[0].ApprovalStatus__c='District Approved';
        update actionPlans;
        String tes = ActionPlanApprovalController.handleActionPlanApprovals(actionPlans[0].id, 'Submitted for District Approval', 'Test', 'Submitted for District Approval');

    }

    static testMethod void testActionPlanServiceRollup6() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

//        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/
        insert actionPlans;
    }

    static testMethod void testActionPlanServiceRollup7() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

//        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));
        insert actionPlans;
    }

    static testMethod void testActionPlanService1() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

//        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant'));
        /*actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/
        insert actionPlans;
    }

    static testMethod void testActionPlanService2() {
        
    	//System.debug('testActionPlanService2 Action Plans: ' + TestUtility.getRecordTypeIdForSObjectDeveloperName('Action_Plan__c', 'CXNOW'));     
        Account account = [select id from Account limit 1];

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
//        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;


        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        //List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        //actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant', recordtypeId=TestUtility.getRecordTypeIdForSObjectDeveloperName('Action_Plan__c', 'CXNOW'), DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/));
        Action_Plan__c actionPlans = new Action_Plan__c(Evaluation__c = evaluation.Id, recordTypeId=TestUtility.getRecordTypeIdForSObjectDeveloperName('Action_Plan__c', 'CXB'), Account__c = account.Id, Status__c = 'Compliant', DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id);
        insert actionPlans;

        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Action Plan';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};
	
        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }


    static testMethod void testActionPlanService3() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;
       
        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant' , DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        apexSharing.add(actionPlans[0], user1.Id, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
        apexSharing.add(actionPlans[0], user2.Id, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
        apexSharing.add(actionPlans[0], user3.Id, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
        apexSharing.add(actionPlans[0], user4.Id, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
        apexSharing.add(actionPlans[0], user5.Id, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
        apexSharing.add(actionPlans[0], user6.Id, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);

        apexSharing.share();
        /*actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/


        Test.startTest();
        ActionPlanService.getUserMapFromActionPlans(actionPlans);
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Action Plan';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }


    static testMethod void testActionPlanService4() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L7', FirstName = 'TestF2', Email='test7@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
//        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user7 = TestUtility.createExternalUser(contacts[6].Id, 'Test1L7', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        apexSharing.add(actionPlans[0], user7.Id, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);

        apexSharing.share();
        /*actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/


        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Action Plan';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }

    static testMethod void testActionPlanService5() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;


        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L6', FirstName = 'TestF2', Email='test6@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L7', FirstName = 'TestF2', Email='test7@email.com'));
        insert contacts;
        ContactTriggerHandler.run = false;

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/D0001,DPM_Eval_ExtRead/D0001,DPM_SurvExtUsr/D0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/D0001,DPM_Eval_ExtRead/D0001,DPM_SurvExtUsr/D0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/D0001,DPM_Eval_ExtRead/D0001,DPM_SurvExtUsr/D0001');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/D0001,DPM_Eval_ExtRead/D0001,DPM_SurvExtUsr/D0001');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'Test1L6', 'TestF2', 'DPM Partner Community (Hyundai)');
//        User user7 = TestUtility.createExternalUser(contacts[6].Id, 'Test1L7', 'TestF2', 'DPM Partner Community (Hyundai)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id
                                            , Division__c = 'Sales', GenesisMarketManagerAlt__c = user3.Id, DistrictManager__c = User3.Id, OwnerId = user4.Id));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Action Plan';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }
    /* DPM-5814
      static testMethod void testActionPlanService6() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;


        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
        insert contacts;
        ContactTriggerHandler.run = false;

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Started';
        actionPlans[0].HasDealerSummary__c=true;
        actionPlans[0].HasActionPlanFile__c=true;
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Started';
        actionPlans[0].HasDealerSummary__c=true;
        actionPlans[0].HasActionPlanFile__c=false;
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Started';
        actionPlans[0].HasDealerSummary__c=true;
        actionPlans[0].HasActionPlanFile__c=false;
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Completed';
        actionPlans[0].Status__c='Compliant';
        Test.startTest();
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Completed';
        actionPlans[0].Status__c='Non-Compliant';

        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Completed';
        actionPlans[0].Status__c='Non-Compliant1';
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        Test.stopTest();
    } */

    static testMethod void testActionPlanService7() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;


        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));
//        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L5', FirstName = 'TestF2', Email='test5@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
//        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'Test1L5', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id
                                            , OwnerId = user4.Id, Division__c = 'Sales', GenesisMarketManagerAlt__c = user3.Id, RegionCode__c = 'SO'/*, GenesisAreaManager__c = user4.Id*/));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        Action_Plan__c objActionPlan = [SELECT Id, Organization__c, OwnerId, CreatedById, DistrictSalesManager__c, DistrictPartsServiceManager__c,
                                                Aftersales_Market_Manager__c, MarketManager__c, Division__c,
                                                RegionCode__c, ServiceDistrictCode__c, SalesDistrictCode__c, MarketCode__c,
                                                GenesisMarketManagerAlt__c, DistrictManager__c, DistrictManager__r.IsActive
                                        FROM Action_Plan__c LIMIT 1];
        List<ObjectAccess__mdt> listObjectAccesses = [select DistrictCode__c,OrganizationName__c, RegionCode__c, MarketCode__c, AccessLevel__c, PublicGroups__c, ObjectAPINames__c from ObjectAccess__mdt
                                                        where Active__c = true and RegionCode__c = 'SO'];
        Group objGroup = [select Id, DeveloperName from Group WHERE DeveloperName =: listObjectAccesses[0].PublicGroups__c limit 1];
        Action_Plan__Share objActionPlanShare = new Action_Plan__Share(ParentId = objActionPlan.Id, UserOrGroupId = objGroup.Id, AccessLevel = 'Edit', RowCause = 'Action_Plan_Sharing__c');
        insert objActionPlanShare;
        Test.startTest();

        Map<Id, Action_Plan__c> mapActionPlansByIds = new Map<Id, Action_Plan__c>();
        mapActionPlansByIds.put(objActionPlan.Id, objActionPlan);

        //DPM-5426 change to query Dealer sharing and sharing in once 
        List<String> sharingReason = new List<String>();
        sharingReason.add(Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
        sharingReason.add(Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
        Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(mapActionPlansByIds.values(), sharingReason); //DPM-5426 changed to comments by MinheeKim - 24.03.19
        //DPM-5426 devide the sharing as Dealer and internal sharing
        Map<Id, Map<String, SObject>> dealerSharesMap = new Map<Id, Map<String, SObject>>();
        Map<Id, Map<String, SObject>> internalSharesMap = new Map<Id, Map<String, SObject>>();

        for(Id parentId :existingSharesMap.keySet()){
            Map<String, SObject> sharesMap = existingSharesMap.get(parentId);
            for(String key : sharesMap.keySet()){
                if(sharesMap.get(key).get('RowCause')==Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c){
                    if(!dealerSharesMap.containsKey(parentId)) {
                        dealerSharesMap.put(parentId, new Map<String, SObject>());
                    }
                    dealerSharesMap.get(parentId).put(key, sharesMap.get(key));
                }else if(sharesMap.get(key).get('RowCause')==Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c){
                    if(!internalSharesMap.containsKey(parentId)) {
                        internalSharesMap.put(parentId, new Map<String, SObject>());
                    }
                    internalSharesMap.get(parentId).put(key, sharesMap.get(key));
                }

            }

        }
    //DPM-5426 end
        ActionPlanService.updateActionPlanSharing(mapActionPlansByIds, internalSharesMap);
        Test.stopTest();
    }

    static testMethod void testActionPlanService8() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;


        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));

        insert contacts;
        ContactTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user5 = TestUtility.createInternalUser('Test1L5', 'TestF2', 'Genesis User Internal');
        User sysUser = TestUtility.createInternalUser('System22','Admin','System Administrator');
        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        // Action_PlanTriggerHandler.run = false;
        
        // Action_PlanTriggerHandler.run = true;

       
        List<ObjectAccess__mdt> listObjectAccesses = [select DistrictCode__c,OrganizationName__c, RegionCode__c, MarketCode__c, AccessLevel__c, PublicGroups__c, ObjectAPINames__c from ObjectAccess__mdt
                                                        where Active__c = true and RegionCode__c = 'SO'];
        Group objGroup = [select Id, DeveloperName from Group WHERE DeveloperName =: listObjectAccesses[0].PublicGroups__c limit 1];
        
        Test.startTest();
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Organization__c='Genesis',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id
                                            , OwnerId = user4.Id, Division__c = 'Sales', GenesisMarketManagerAlt__c = user3.Id, RegionCode__c = 'SO'/*, GenesisAreaManager__c = user4.Id*/));
        
        actionPlans.add(new Action_Plan__c(Organization__c='Genesis',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user5.Id
                                            ,  Division__c = 'Sales', GenesisMarketManagerAlt__c = user5.Id, RegionCode__c = 'SO'/*, GenesisAreaManager__c = user4.Id*/));
        
        System.runAs(sysUser){
            insert actionPlans;
        }

        

        Map<Id, Action_Plan__c> mapActionPlansByIds = new Map<Id, Action_Plan__c>();
        mapActionPlansByIds.put(actionPlans[0].Id, actionPlans[0]);

        //DPM-5426 change to query Dealer sharing and sharing in once 
        List<String> sharingReason = new List<String>();
        sharingReason.add(Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
        sharingReason.add(Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
        Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(mapActionPlansByIds.values(), sharingReason); //DPM-5426 changed to comments by MinheeKim - 24.03.19
        //DPM-5426 devide the sharing as Dealer and internal sharing
        Map<Id, Map<String, SObject>> dealerSharesMap = new Map<Id, Map<String, SObject>>();
        Map<Id, Map<String, SObject>> internalSharesMap = new Map<Id, Map<String, SObject>>();

        for(Id parentId :existingSharesMap.keySet()){
            Map<String, SObject> sharesMap = existingSharesMap.get(parentId);
            for(String key : sharesMap.keySet()){
                if(sharesMap.get(key).get('RowCause')==Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c){
                    if(!dealerSharesMap.containsKey(parentId)) {
                        dealerSharesMap.put(parentId, new Map<String, SObject>());
                    }
                    dealerSharesMap.get(parentId).put(key, sharesMap.get(key));
                }else if(sharesMap.get(key).get('RowCause')==Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c){
                    if(!internalSharesMap.containsKey(parentId)) {
                        internalSharesMap.put(parentId, new Map<String, SObject>());
                    }
                    internalSharesMap.get(parentId).put(key, sharesMap.get(key));
                }

            }

        }
    //DPM-5426 end
        ActionPlanService.updateActionPlanSharing(mapActionPlansByIds, internalSharesMap);
        Test.stopTest();
    }

    //DPM - 5814
    static testMethod void testActionPlanService9() {
        Account account = [select id from Account limit 1];
        //Account account = new Account();
        //account.Name = 'Test Account';
        //insert account;


        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'Test1L4', FirstName = 'TestF2', Email='test4@email.com'));

        insert contacts;
        ContactTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'Test1L3', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'Test1L4', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user5 = TestUtility.createInternalUser('Test1L5', 'TestF2', 'Genesis User Internal');
        User sysUser = TestUtility.createInternalUser('System22','Admin','System Administrator');
        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;

        // Action_PlanTriggerHandler.run = false;
        
        // Action_PlanTriggerHandler.run = true;

       
        List<ObjectAccess__mdt> listObjectAccesses = [select DistrictCode__c,OrganizationName__c, RegionCode__c, MarketCode__c, AccessLevel__c, PublicGroups__c, ObjectAPINames__c from ObjectAccess__mdt
                                                        where Active__c = true and RegionCode__c = 'SO'];
        Group objGroup = [select Id, DeveloperName from Group WHERE DeveloperName =: listObjectAccesses[0].PublicGroups__c limit 1];
        
        Test.startTest();
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Organization__c='Genesis',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id
                                            , OwnerId = user4.Id, Division__c = 'Sales', GenesisMarketManagerAlt__c = user3.Id, RegionCode__c = 'SO'/*, GenesisAreaManager__c = user4.Id*/));
        
        actionPlans.add(new Action_Plan__c(Organization__c='Genesis',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user5.Id
                                            ,  Division__c = 'Sales', GenesisMarketManagerAlt__c = user5.Id, RegionCode__c = 'SO'/*, GenesisAreaManager__c = user4.Id*/));
        
        System.runAs(sysUser){
            insert actionPlans;
        }

        

        Map<Id, Action_Plan__c> mapActionPlansByIds = new Map<Id, Action_Plan__c>();
        mapActionPlansByIds.put(actionPlans[0].Id, actionPlans[0]);

        //DPM-5426 change to query Dealer sharing and sharing in once 
        List<String> sharingReason = new List<String>();
        sharingReason.add(Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
        sharingReason.add(Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
        Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(mapActionPlansByIds.values(), sharingReason); //DPM-5426 changed to comments by MinheeKim - 24.03.19
        //DPM-5426 devide the sharing as Dealer and internal sharing
        Map<Id, Map<String, SObject>> dealerSharesMap = new Map<Id, Map<String, SObject>>();
        Map<Id, Map<String, SObject>> internalSharesMap = new Map<Id, Map<String, SObject>>();

        for(Id parentId :existingSharesMap.keySet()){
            Map<String, SObject> sharesMap = existingSharesMap.get(parentId);
            for(String key : sharesMap.keySet()){
                if(sharesMap.get(key).get('RowCause')==Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c){
                    if(!dealerSharesMap.containsKey(parentId)) {
                        dealerSharesMap.put(parentId, new Map<String, SObject>());
                    }
                    dealerSharesMap.get(parentId).put(key, sharesMap.get(key));
                }else if(sharesMap.get(key).get('RowCause')==Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c){
                    if(!internalSharesMap.containsKey(parentId)) {
                        internalSharesMap.put(parentId, new Map<String, SObject>());
                    }
                    internalSharesMap.get(parentId).put(key, sharesMap.get(key));
                }

            }

        }
    //DPM-5426 end
        ActionPlanService.updateActionPlanSharing(mapActionPlansByIds, internalSharesMap);
        Test.stopTest();
    }  
    
    
    
}