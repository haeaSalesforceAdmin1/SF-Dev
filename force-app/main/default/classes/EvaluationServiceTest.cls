@isTest
public without sharing class EvaluationServiceTest {
    @TestSetup
    static void makeData(){
       CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;
    }

    static testMethod void testEvaluationSharing1() {
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

        //User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)');
        //User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'TestL3', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'TestL4', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'TestL5', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'TestL6', 'TestF2', 'DPM Partner Community (Hyundai)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/);
        insert evaluation;
        System.runAs(user4){
            EvaluationApprovalController.handleEvaluationApprovals(evaluation.id, 'Submit', 'Hello test', 'Open');}
        
        evaluation.PrimaryContact__c=null;
            evaluation.PrimaryContactName__c=null;
            update evaluation;
         System.runAs(user4){
            EvaluationApprovalController.handleEvaluationApprovals(evaluation.id, 'Submit', 'Hello test', 'NO');}

        
        EvaluationTriggerHandler.run = true;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');
        apexSharing.add(evaluation, user1.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
        apexSharing.add(evaluation, user2.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
        apexSharing.add(evaluation, user3.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
        apexSharing.add(evaluation, user4.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
        apexSharing.add(evaluation, user5.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
        apexSharing.add(evaluation, user6.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);

        apexSharing.share();
        /*actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/
       

        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Evaluation';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }

    static testMethod void testEvaluationSharing2() {
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


        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id,SalesDistrictCode__c='CE1',MarketCode__c='CE1',RegionCode__c='CE',ServiceDistrictCode__c='CE1'/*, GenesisAreaManager__c = user4.Id*/);
        insert evaluation;
        EvaluationTriggerHandler.run = true;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');
        apexSharing.add(evaluation, user7.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
        apexSharing.share();
        /*actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/
       

        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Evaluation';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }


    static testMethod void testEvaluationSharing3() {
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


        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/);
        insert evaluation;
        EvaluationTriggerHandler.run = true;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;   

        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Evaluation';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }

    static testMethod void testEvaluationSharing4() {
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


        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        //EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user1.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/);
        insert evaluation;
        //EvaluationTriggerHandler.run = true;

        //Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user1.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/));
        insert actionPlans;
        //Action_PlanTriggerHandler.run = true;   

        HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');
        apexSharing.add(evaluation, user1.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
        apexSharing.add(evaluation, user1.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
        apexSharing.add(evaluation, user1.Id, 'Edit', Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c);
        
        apexSharing.share();

        Test.startTest();
        update evaluation;
        Test.stopTest();
    }

    static testMethod void testEvaluationSharing5() {
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


        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user1.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/);
        insert evaluation;
        EvaluationTriggerHandler.run = true;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user1.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/));
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

    static testMethod void testEvaluationSharing6() {
        Test.startTest();
        User createUser = TestUtility.createInternalUser('CreateL','CreateF','System Administrator');
        
        // ObjectAccess__mdt oba = new ObjectAccess__mdt (DeveloperName='DPM_GAMM_ALABAMA_G1S', MarketCode__c='G1S', ObjectAPINames__c	='Evaluation__c,Action_Plan__c,Survey__c', PublicGroups__c='DPM_GAMM_ALABAMA_G1S', DPMActiveUser__c='true', OrganizationName__c='Genesis');
        // insert oba;

        Account account = new Account();
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0002';        
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
        
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Genesis)', 'DPM_AP_ExtRE/A0002,DPM_Eval_ExtRead/A0002,DPM_SurvExtUsr/A0002');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Genesis)', 'DPM_AP_ExtRE/A0002,DPM_Eval_ExtRead/A0002,DPM_SurvExtUsr/A0002');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'TestL3', 'TestF2', 'DPM Partner Community (Genesis)', 'DPM_AP_ExtRE/A0002,DPM_Eval_ExtRead/A0002,DPM_SurvExtUsr/A0002');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'TestL4', 'TestF2', 'DPM Partner Community (Genesis)');
        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'TestL5', 'TestF2', 'DPM Partner Community (Genesis)');
        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'TestL6', 'TestF2', 'DPM Partner Community (Genesis)');
        User user7 = TestUtility.createExternalUser(contacts[6].Id, 'TestL7', 'TestF2', 'DPM Partner Community (Genesis)');


        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;
        System.runAs(createUser){
            EvaluationTriggerHandler.run = false;
            Evaluation__c evaluation = new Evaluation__c(OwnerId = user2.Id, Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, MarketManager__c = createUser.Id, GenesisMarketManagerAlt__c = createUser.Id, Aftersales_Market_Manager__c = createUser.Id, Type__c = 'Service', MarketCode__c='G1S');
            insert evaluation;
            Evaluation__Share evaluationShare = new Evaluation__Share (ParentId=evaluation.Id, UserOrGroupId=user2.Id, RowCause='Evaluation_Sharing__c', AccessLevel='Read');
            insert evaluationShare;
            evaluation.GenesisMarketManagerAlt__c=user2.Id;
            update evaluation;
            EvaluationTriggerHandler.run = true;

            Action_PlanTriggerHandler.run = false;
            List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
            actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  MarketManager__c = createUser.Id, GenesisMarketManagerAlt__c = createUser.Id, Aftersales_Market_Manager__c = createUser.Id, MarketCode__c='G1S'));
            insert actionPlans;
            Action_PlanTriggerHandler.run = true;   

            // Test.startTest();
            BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
            objectShares.type = 'Action Plan';
            objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};
        

            Database.executeBatch(objectShares, 1);
        }
        Test.stopTest();
    }

    static testMethod void testEvaluationSharing7() {
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

        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Genesis)');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Genesis)');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'TestL3', 'TestF2', 'DPM Partner Community (Genesis)');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'TestL4', 'TestF2', 'DPM Partner Community (Genesis)');
        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'TestL5', 'TestF2', 'DPM Partner Community (Genesis)');
        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'TestL6', 'TestF2', 'DPM Partner Community (Genesis)');
        User user7 = TestUtility.createExternalUser(contacts[6].Id, 'TestL7', 'TestF2', 'DPM Partner Community (Genesis)');


        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, GenesisMarketManagerAlt__c = user1.Id, Aftersales_Market_Manager__c = user2.Id, MarketManager__c = user3.Id,SalesDistrictCode__c='CE1',MarketCode__c='CE1',RegionCode__c='CE',ServiceDistrictCode__c='CE1', Type__c='Service');
        insert evaluation;
        EvaluationTriggerHandler.run = true;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  GenesisMarketManagerAlt__c = user1.Id, Aftersales_Market_Manager__c = user2.Id, MarketManager__c = user3.Id/*, GenesisAreaManager__c = user4.Id*/));
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');
        apexSharing.add(evaluation, user7.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
        apexSharing.share();
        /*actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Non-Compliant'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Completed'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for District Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Submitted for Regional Approval'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'Region Approved'));
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, ApprovalStatus__c = 'District Approved'));*/
       

        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Evaluation';
        objectShares.updateAllObjectsSharing = false;
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};

        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }

       static testMethod void testEvaluationSharing8() {
        
        User createUser = TestUtility.createInternalUser('CreateL','CreateF','System Administrator');

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

        //User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)');
        //User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Genesis)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRE/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Genesis)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRE/A0001,DPM_SurvExtUsr/A0001');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'TestL3', 'TestF2', 'DPM Partner Community (Genesis)');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'TestL4', 'TestF2', 'DPM Partner Community (Genesis)');
        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'TestL5', 'TestF2', 'DPM Partner Community (Genesis)');
        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'TestL6', 'TestF2', 'DPM Partner Community (Genesis)');

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        EvaluationTriggerHandler.run = false;
        Evaluation__c evaluation = new Evaluation__c(OwnerId=user4.Id, Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id, GenesisMarketManagerAlt__c = user1.Id, Aftersales_Market_Manager__c = user1.Id, DistrictManager__c=user2.Id ,MarketManager__c = user3.Id, Type__c='Service');
        System.runAs(createUser){
            insert evaluation;}
        System.debug('EvaluationTest GenesisMarketManagerAlt__c: '+evaluation.GenesisMarketManagerAlt__c);
        System.debug('EvaluationTest OwnerId: '+evaluation.OwnerId);
        System.debug('EvaluationTest .GenesisMarketManagerAlt__r.IsActive: '+evaluation.GenesisMarketManagerAlt__r.IsActive);
        System.debug('EvaluationTest Type__c: '+evaluation.Type__c);
        System.runAs(user4){
            EvaluationApprovalController.handleEvaluationApprovals(evaluation.id, 'Submit', 'Hello test', 'Open');}
        
         System.runAs(user4){
            EvaluationApprovalController.handleEvaluationApprovals(evaluation.id, 'Submit', 'Hello test', 'NO');}

        
        EvaluationTriggerHandler.run = true;
        evaluation.PrimaryContact__c=null;
        evaluation.PrimaryContactName__c=null;
        update evaluation;

        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  GenesisMarketManagerAlt__c = user1.Id, Aftersales_Market_Manager__c = user1.Id, MarketManager__c = user3.Id, DistrictManager__c=user2.Id));
        System.runAs(createUser){
            insert actionPlans;}
        Action_PlanTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Survey__Share');
        apexSharing.add(evaluation, user1.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(evaluation, user2.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(evaluation, user3.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(evaluation, user4.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(evaluation, user5.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        apexSharing.add(evaluation, user6.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);

        apexSharing.share();
    
        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Survey';
        objectShares.updateAllObjectsSharing = false;
        Database.executeBatch(objectShares, 1);
        
        Test.stopTest();
           
        
    }
    
}