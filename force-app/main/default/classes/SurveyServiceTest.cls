@isTest
public with sharing class SurveyServiceTest {
  @TestSetup
    static void makeData(){
       CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;
    }
    static testMethod void testSurveySharing1() {
        Account account = new Account();
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0001';
        insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;
        
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'TestL3', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'TestL4', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'TestL5', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'TestL6', 'TestF2', 'DPM Partner Community (Hyundai)');

        SurveyTriggerHandler.run = false;
        Survey__c survey = new Survey__c(Dealer__c = account.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id,  OwnerId = user6.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id);
        insert evaluation;
        EvaluationTriggerHandler.run = true;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Survey__Share');
        apexSharing.add(survey, user1.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user2.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user3.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user4.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user5.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user6.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user1.Id, 'Edit', Schema.Survey__Share.RowCause.Dealer_Survey_Sharing__c);
        
        apexSharing.share();

        SurveyTriggerHandler.run = true;
        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Survey';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }

    static testMethod void testSurveySharing2() {
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL6', FirstName = 'TestF2', Email='test6@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL7', FirstName = 'TestF2', Email='test7@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;
        
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'TestL3', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'TestL4', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'TestL5', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'TestL6', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user7 = TestUtility.createExternalUser(contacts[6].Id, 'TestL7', 'TestF2', 'DPM Partner Community (Hyundai)');

        SurveyTriggerHandler.run = false;
        Survey__c survey = new Survey__c(Dealer__c = account.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id, OwnerId = user6.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id);
        insert evaluation;
        EvaluationTriggerHandler.run = true;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Survey__Share');
        //apexSharing.add(survey, user1.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        //apexSharing.add(survey, user2.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        //apexSharing.add(survey, user3.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        //apexSharing.add(survey, user4.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        //apexSharing.add(survey, user5.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user7.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);

        apexSharing.share();

        SurveyTriggerHandler.run = true;
        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Survey';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }

    static testMethod void testSurveySharing3() {
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL6', FirstName = 'TestF2', Email='test6@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL7', FirstName = 'TestF2', Email='test7@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;
        
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'TestL3', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'TestL4', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'TestL5', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'TestL6', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user7 = TestUtility.createExternalUser(contacts[6].Id, 'TestL7', 'TestF2', 'DPM Partner Community (Hyundai)');

        SurveyTriggerHandler.run = false;
        Survey__c survey = new Survey__c(Dealer__c = account.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id, OwnerId = user6.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id);
        insert evaluation;
        EvaluationTriggerHandler.run = true;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        //HMAApexSharing apexSharing = new HMAApexSharing('Survey__Share');
        //apexSharing.add(survey, user1.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        //apexSharing.add(survey, user2.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        //apexSharing.add(survey, user3.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        //apexSharing.add(survey, user4.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        //apexSharing.add(survey, user5.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        //apexSharing.add(survey, user7.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);

        //apexSharing.share();

        SurveyTriggerHandler.run = true;
        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Survey';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }

    static testMethod void testSurveySharing4() {
        Account account = new Account();
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0001';
        insert account;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL6', FirstName = 'TestF2', Email='test6@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;
        
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'TestL3', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'TestL4', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'TestL5', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'TestL6', 'TestF2', 'DPM Partner Community (Hyundai)');

        SurveyTriggerHandler.run = false;
        Survey__c survey = new Survey__c(Dealer__c = account.Id, PrimaryContact__c = contacts[0].Id, 
        DistrictPartsServiceManager__c = user1.Id, DistrictPartsServiceManagerAlt__c=user1.Id, DistrictSalesManager__c = user2.Id, DistrictSalesManagerAlt__c=user1.Id,
        GenesisMarketManagerAlt__c=user1.Id, MarketManager__c = user3.Id,  OwnerId = user6.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(OwnerId=user2.Id,Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, 
        DistrictPartsServiceManager__c = user1.Id, DistrictPartsServiceManagerAlt__c=user1.Id, DistrictSalesManager__c = user2.Id, DistrictSalesManagerAlt__c=user1.Id,
        GenesisMarketManagerAlt__c=user1.Id, MarketManager__c = user3.Id);
        insert evaluation;
        EvaluationTriggerHandler.run = true;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(OwnerId=user2.Id,Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  
        DistrictPartsServiceManager__c = user1.Id, DistrictPartsServiceManagerAlt__c=user1.Id, DistrictSalesManager__c = user2.Id, DistrictSalesManagerAlt__c=user1.Id,
        GenesisMarketManagerAlt__c=user1.Id, MarketManager__c = user3.Id));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Survey__Share');
        apexSharing.add(survey, user1.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user2.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user3.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user4.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user5.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user6.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(survey, user1.Id, 'Edit', Schema.Survey__Share.RowCause.Dealer_Survey_Sharing__c);
        
        apexSharing.share();

        SurveyTriggerHandler.run = true;
        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Survey';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }
}