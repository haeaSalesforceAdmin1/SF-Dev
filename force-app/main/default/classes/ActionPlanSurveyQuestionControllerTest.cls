/**
 * Created by user on 2023-08-02.
 */
@IsTest
public with sharing class ActionPlanSurveyQuestionControllerTest {
    
    @TestSetup
    static void testSetup(){
        // CurrentEnvironment__c
        CurrentEnvironment__c objEnv = new CurrentEnvironment__c();
        objEnv.Environment__c = 'STAGE';
        insert objEnv;
        
        User user1 = TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');

        // Account
        List<Account> listAccount = new List<Account>();
        Account objAccount1 = new Account();
        objAccount1.Name = 'Test Account1';
        listAccount.add(objAccount1);

        insert listAccount;

        // Survey
        Survey__c objSurvey1 = new Survey__c();
        objSurvey1.Dealer__c = objAccount1.Id;

        insert objSurvey1;
        
        //User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        List<Account> accounts = [select Id from Account];
        //List<User> users = [select Id from User];
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Account__c = accounts[0].Id, OwnerId = user1.Id, FollowUpDate__c = System.now().date(), Organization__c = 'Hyundai', Division__c = 'Service');
        insert actionPlan;
        
        // Survey Questions
        Survey_Question__c objQuestion1 = new Survey_Question__c();
        objQuestion1.Survey__c = objSurvey1.Id;
        objQuestion1.Action_Plan__c = actionPlan.Id;
        objQuestion1.Table_Columns__c = 'Test1;Test2;Test3';
        objQuestion1.Question_Number_Text__c = 'Test1';
        objQuestion1.Question_Text__c = 'Test1';
        objQuestion1.Response__c = 'No';
        objQuestion1.Remarks__c = '<p>Test1<p>';
        objQuestion1.Is_Parent__c = true;
        objQuestion1.DependentQuestion__c = null;
        insert objQuestion1;
        
        Survey_Question__c objQuestion2 = objQuestion1.clone();
        objQuestion2.Survey__c = objSurvey1.Id;
        objQuestion2.Action_Plan__c = actionPlan.Id;
        objQuestion2.Question_Number_Text__c = 'Test2';
        objQuestion2.Question_Text__c = 'Test2';
        objQuestion2.Response__c = 'No';
        objQuestion2.Remarks__c = '<p>Test1<p>';
        objQuestion2.Is_Parent__c = false;
        objQuestion2.DependentQuestion__c = objQuestion1.Id;
        insert objQuestion2;

        // Evaluation
        List<Evaluation__c> listEvaluations = new List<Evaluation__c>();
        Evaluation__c objEvaluation1 = new Evaluation__c();
        objEvaluation1.Account__c = objAccount1.Id;
        objEvaluation1.Survey__c = objSurvey1.Id;

        listEvaluations.add(objEvaluation1);

        insert listEvaluations;

        Blob bData = Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion(Title = 'test content trigger', PathOnClient ='test', VersionData = bData);
        insert cv;

        List<ContentVersion> testContents = [
                SELECT  Id
                        , ContentDocumentId
                FROM    ContentVersion
                WHERE   Title LIKE 'test content trigger%'
                LIMIT 3
        ];

        List<ContentDocumentLink> listLinks = new List<ContentDocumentLink>();
        ContentDocumentLink objDoc1 = new ContentDocumentLink(LinkedEntityId = objEvaluation1.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        listLinks.add(objDoc1);

        ContentDocumentLink objDoc2 = new ContentDocumentLink(LinkedEntityId = objQuestion1.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        listLinks.add(objDoc2);

        ContentDocumentLink objDoc3 = new ContentDocumentLink(LinkedEntityId = objSurvey1.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        listLinks.add(objDoc3);

        insert listLinks;
    }

    @IsTest
    static void testMethod1(){
        Action_Plan__c actionPlan = [SELECT Id FROM Action_Plan__c LIMIT 1];
        System.debug('actionPlan.Id : '+actionPlan.Id);
        Test.startTest();
        ActionPlanSurveyQuestionController.getSurveyQuestions(actionPlan.Id);
        Test.stopTest();
    }

}