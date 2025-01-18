@isTest
public with sharing class AssignToDealerControllerTest {
    @TestSetup
    static void makeData(){
       CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;
    }

    static testMethod void testEvaluationController() {

        Account account = new Account();
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0001';
        insert account;

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        insert contacts;

        //User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)');
        //User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        EvaluationTriggerHandler.run = false;
        insert evaluation;
        EvaluationTriggerHandler.run = false;

        Test.startTest();
        AssignToDealerController.getEvaluationDetails(evaluation.Id);
        AssignToDealerController.getPrimaryContactUserId(contacts[0].Id);
        AssignToDealerController.retrievEvaluationAccountContacts(account.Id);
        Test.stopTest();
    }


    static testMethod void testEvaluationController2() {

        Account account = new Account();
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0001';
        insert account;

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        insert contacts;

        //User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)');
        //User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        EvaluationTriggerHandler.run = false;
        insert evaluation;
        EvaluationTriggerHandler.run = false;

        Action_Plan__c  actionPlan = new Action_Plan__c(Evaluation__c = evaluation.Id);
        insert actionPlan;
        
        Test.startTest();
        AssignToDealerController.getActionPlansToAssignOwner(evaluation.Id);
        Test.stopTest();
    }

    static testMethod void testEvaluationController3() {

        Account account = new Account();
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0001';
        insert account;

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        insert contacts;

        //User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)');
        //User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        EvaluationTriggerHandler.run = false;
        insert evaluation;
        EvaluationTriggerHandler.run = false;

        Action_Plan__c  actionPlan = new Action_Plan__c(Evaluation__c = evaluation.Id);
        insert actionPlan;
        
        Test.startTest();
        AssignToDealerController.updateActionPlanOwnerId(JSON.serialize(actionPlan));
        Test.stopTest();
    }

    static testMethod void testEvaluationController4() {

        Account account = new Account();
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0001';
        insert account;

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        insert contacts;

        //User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)');
        //User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        EvaluationTriggerHandler.run = false;
        insert evaluation;
        EvaluationTriggerHandler.run = false;

        Action_Plan__c  actionPlan = new Action_Plan__c(Evaluation__c = evaluation.Id);
        insert actionPlan;
        
        Test.startTest();
        AssignToDealerController.updateEvaluationOwnerId(JSON.serialize(evaluation));
        Test.stopTest();
    }

    static testMethod void testEvaluationController5() {

        Account account = new Account();
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0001';
        insert account;

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        insert contacts;

        //User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)');
        //User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        EvaluationTriggerHandler.run = false;
        insert evaluation;
        EvaluationTriggerHandler.run = false;

        Action_Plan__c  actionPlan = new Action_Plan__c(Evaluation__c = evaluation.Id);
        insert actionPlan;
        
        Test.startTest();
        AssignToDealerController.updateSurveyOwnerId(JSON.serialize(survey));
        AssignToDealerController.getActionPlanDetails(actionPlan.Id);
        Test.stopTest();
    }

}