@IsTest
public without sharing class SurveyQuestionControllerTest {

    @TestSetup
    static void testSetup(){
        // CurrentEnvironment__c
        CurrentEnvironment__c objEnv = new CurrentEnvironment__c();
        objEnv.Environment__c = 'STAGE';
        insert objEnv;


        // Account
        List<Account> listAccount = new List<Account>();
        Account objAccount1 = new Account();
        objAccount1.Name = 'Test Account1';
        listAccount.add(objAccount1);

        insert listAccount;

        // Survey
        List<Survey__c> listSurvey = new List<Survey__c>();
        Survey__c objSurvey1 = new Survey__c();
        objSurvey1.Dealer__c = objAccount1.Id;
        listSurvey.add(objSurvey1);

        insert listSurvey;

        // Survey Questions
        List<Survey_Question__c> listSurveyQuestions = new List<Survey_Question__c>();

        Survey_Question__c objQuestion1 = new Survey_Question__c();
        objQuestion1.Survey__c = objSurvey1.Id;
        objQuestion1.Table_Columns__c = 'Test1;Test2;Test3';
        objQuestion1.Response__c = 'Yes';
        listSurveyQuestions.add(objQuestion1);

        Survey_Question__c objQuestion2 = objQuestion1.clone();
        objQuestion2.Response__c = 'No';
        listSurveyQuestions.add(objQuestion2);

        insert listSurveyQuestions;


        // Evaluation

        List<Evaluation__c> listEvaluations = new List<Evaluation__c>();
        Evaluation__c objEvaluation1 = new Evaluation__c();
        objEvaluation1.Account__c = objAccount1.Id;
        objEvaluation1.Survey__c = objSurvey1.Id;

        listEvaluations.add(objEvaluation1);

        Evaluation__c objEvaluation2 = new Evaluation__c();
        objEvaluation2.Account__c = objAccount1.Id;
        objEvaluation2.Survey__c = objSurvey1.Id;
        objEvaluation2.Total_of_Related_Action_Plans__c=1;

        listEvaluations.add(objEvaluation2);

        insert listEvaluations;

        
//
//        // Update Survey
//        SurveyTriggerHandler.run = false;
//        if(listSurvey != null && listSurvey.size()>0){
//            for(Survey__c obj : listSurvey){
//                obj.Evaluation__c = objEvaluation1.Id;
//            }
//
//            update listSurvey;
//        }
//        SurveyTriggerHandler.run = true;

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
        Test.startTest();
        User testuser = TestUtility.createInternalUser('Testjdp','Test','JDP Evaluator user Internal');
        System.runAs(testuser) {
            // Test for getWarrantyReviewMetadata22
            SurveyQuestionController.getWarrantyReviewMetadata22();
            // Test for checkAdminUserOrNot
            SurveyQuestionController.checkAdminUserOrNot();
            // Test for getWarrantyReviewMetadata
            SurveyQuestionController.getWarrantyReviewMetadata();
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testMethod2(){
        // Get data
        Id EvalId = [SELECT Id FROM Evaluation__c LIMIT 1].Id;
        Id QuestionsId = [SELECT Id FROM Survey_Question__c WHERE Response__c LIKE 'Yes' LIMIT 1].Id;
        Id AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id SurveyId = [SELECT Id FROM Survey__c LIMIT 1].Id;
        Id DocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title LIKE 'test content trigger%' LIMIT 1].ContentDocumentId;
        List<Id> DocIdList = new List<Id>();
        List<Survey__c> listSurvey = [SELECT Id, Evaluation__c, Status__c FROM Survey__c];
        if(listSurvey != null && listSurvey.size()>0){
            SurveyTriggerHandler.run = false;
            for(Survey__c obj : listSurvey){
                obj.Evaluation__c = EvalId;
            }

            update listSurvey;
            SurveyTriggerHandler.run = true;
        }

        // Set Data
        Test.startTest();

        PageReference pageRef = Page.EvaluationPDF;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',EvalId);
        pageRef.getParameters().put('showFinancials','true');
        pageRef.getParameters().put('showApprovals','true');

        // Test for retrieveEvaluationDetails
        SurveyQuestionController.retrieveEvaluationDetails(SurveyId, false);
        SurveyQuestionController.retrieveEvaluationDetails(EvalId, true);

        // Test for getSurveyQuestions
        SurveyQuestionController.getSurveyQuestions(SurveyId, false);
        SurveyQuestionController.getSurveyQuestions(EvalId, true);

        // Test for getSurveyQuestion
        SurveyQuestionController.getSurveyQuestion(QuestionsId);

        // Test for retrievEvaluationAccountContacts
        SurveyQuestionController.retrievEvaluationAccountContacts(AccountId);

        // Test for getNetworkId
        SurveyQuestionController.getNetworkId();

        // Test for getContentDocumentsForSurvey
        SurveyQuestionController.getContentDocumentsForSurvey(SurveyId);

        // Test for getHasEditAccessToRecord
        SurveyQuestionController.getHasEditAccessToRecord(SurveyId);



        // Test for saveQuestion
        SurveyQuestionController.saveQuestion(QuestionsId, 'Name', 'Test');

        // Test for saveEvaluationDetails
        Evaluation__c objEvaluation = [SELECT Id FROM Evaluation__c LIMIT 1];
        SurveyQuestionController.saveEvaluationDetails(JSON.serialize(objEvaluation));

        // Test for resubmitForApproval -> Error Occurred
        // System.DmlException: Update failed. First exception on row 0 with id a083I000002hmfEQAQ; first error: CANNOT_EXECUTE_FLOW_TRIGGER, We can't save this record because the “Evaluation Process Handler_1” process failed. Give your Salesforce admin these details. No applicable approval process was found.
        //No applicable approval process was found.
//        SurveyQuestionController.resubmitForApproval(objEvaluation.Id);

        // Test for updateSurveyQuestions
        List<Survey_Question__c> listQuestions = [SELECT Id, Action_Plan__c, Survey__c, Response__c FROM Survey_Question__c ];
        List<Survey_Question__c> listYes = new List<Survey_Question__c>();
        List<Survey_Question__c> listNo = new List<Survey_Question__c>();

        if(listQuestions != null && listQuestions.size()>0){
            for(Survey_Question__c obj : listQuestions){
                if('Yes'.equalsIgnoreCase(obj.Response__c)) listYes.add(obj);
                if('No'.equalsIgnoreCase(obj.Response__c)) listNo.add(obj);
            }
        }
        SurveyQuestionController.updateSurveyQuestions(JSON.serialize(listYes), true, null);
        SurveyQuestionController.updateSurveyQuestions(JSON.serialize(listNo), true, null);

        // Test for updateContentVersion
        SurveyQuestionController.updateContentVersion(new List<String>{DocId},'Warranty_CEE_RO_Review_Excel_File__c');
        SurveyQuestionController.updateContentVersion(new List<String>{DocId},'RO_Review_Action_Plan__c');
        SurveyQuestionController.updateContentVersion(new List<String>{DocId},'WOPR_Action_Plan_WOPR_score_below_avg__c');
        SurveyQuestionController.updateContentVersion(new List<String>{DocId},'Other_WOPR_Action_Plan__c');

        // Test for getContentDocuments
        SurveyQuestionController.getContentDocuments(SurveyId);


        // Test for deleteContentDocument
        DocIdList.add(DocId); //DPM-5264
        SurveyQuestionController.deleteContentDocument(DocIdList);
        Test.stopTest();
    }

    @IsTest
    static void testMethod3(){
        // Get data
        Id EvalId = [SELECT Id FROM Evaluation__c LIMIT 1].Id;
        Id QuestionsId = [SELECT Id FROM Survey_Question__c WHERE Response__c LIKE 'Yes' LIMIT 1].Id;
        Id AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id SurveyId = [SELECT Id FROM Survey__c LIMIT 1].Id;
        Id DocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title LIKE 'test content trigger%' LIMIT 1].ContentDocumentId;
        List<Survey__c> listSurvey = [SELECT Id, Evaluation__c, Status__c FROM Survey__c];
        if(listSurvey != null && listSurvey.size()>0){
            SurveyTriggerHandler.run = false;
            for(Survey__c obj : listSurvey){
                obj.Evaluation__c = EvalId;
                obj.Status__c = 'Completed';
            }

            update listSurvey;
            SurveyTriggerHandler.run = true;
        }

        // Set Data
        Test.startTest();

        PageReference pageRef = Page.EvaluationPDF;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',EvalId);
        pageRef.getParameters().put('showFinancials','true');
        pageRef.getParameters().put('showApprovals','true');

        // Test for updateSurvey
        SurveyQuestionController.updateSurvey(JSON.serialize(listSurvey[0]));
        // Test for updateWarrantySurvey
        SurveyQuestionController.updateWarrantySurvey(JSON.serialize(listSurvey));
        SurveyQuestionController.updateWarrantySurveyQuestion(JSON.serialize(listSurvey));
        
        // Test for getSurveyWarrantyReviewQuestions
        SurveyQuestionController.getSurveyWarrantyReviewQuestions(EvalId, true);
        SurveyQuestionController.getSurveyWarrantyReviewQuestions(SurveyId, false);
        SurveyQuestionController.getHasCompleteAccessToRecord(EvalId); //DPM-5399 added for test coverage by Minhee - 24.03.08
        Test.stopTest();
    }

    @IsTest
    static void testMethod4(){
        // Get data
        Id EvalId = [SELECT Id FROM Evaluation__c WHERE Total_of_Related_Action_Plans__c>0].Id;
        Id QuestionsId = [SELECT Id FROM Survey_Question__c WHERE Response__c LIKE 'Yes' LIMIT 1].Id;
        Id AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id SurveyId = [SELECT Id FROM Survey__c LIMIT 1].Id;
        Id DocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title LIKE 'test content trigger%' LIMIT 1].ContentDocumentId;
        List<Id> DocIdList = new List<Id>();
        List<Survey__c> listSurvey = [SELECT Id, Evaluation__c, Status__c FROM Survey__c];
        if(listSurvey != null && listSurvey.size()>0){
            SurveyTriggerHandler.run = false;
            for(Survey__c obj : listSurvey){
                obj.Evaluation__c = EvalId;
            }

            update listSurvey;
            SurveyTriggerHandler.run = true;
        }

        // Set Data
        Test.startTest();

        PageReference pageRef = Page.EvaluationPDF;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',EvalId);
        pageRef.getParameters().put('showFinancials','true');
        pageRef.getParameters().put('showApprovals','true');

        // Test for retrieveEvaluationDetails
        SurveyQuestionController.retrieveEvaluationDetails(SurveyId, false);
        SurveyQuestionController.retrieveEvaluationDetails(EvalId, true);

        // Test for getSurveyQuestions
        SurveyQuestionController.getSurveyQuestions(SurveyId, false);
        SurveyQuestionController.getSurveyQuestions(EvalId, true);

        // Test for getSurveyQuestion
        SurveyQuestionController.getSurveyQuestion(QuestionsId);

        // Test for retrievEvaluationAccountContacts
        SurveyQuestionController.retrievEvaluationAccountContacts(AccountId);

        // Test for getNetworkId
        SurveyQuestionController.getNetworkId();

        // Test for getContentDocumentsForSurvey
        SurveyQuestionController.getContentDocumentsForSurvey(SurveyId);

        // Test for getHasEditAccessToRecord
        SurveyQuestionController.getHasEditAccessToRecord(SurveyId);



        // Test for saveQuestion
        SurveyQuestionController.saveQuestion(QuestionsId, 'Name', 'Test');

        // Test for saveEvaluationDetails
        Evaluation__c objEvaluation = [SELECT Id FROM Evaluation__c WHERE Total_of_Related_Action_Plans__c>0];
        SurveyQuestionController.saveEvaluationDetails(JSON.serialize(objEvaluation));

        // Test for resubmitForApproval -> Error Occurred
        // System.DmlException: Update failed. First exception on row 0 with id a083I000002hmfEQAQ; first error: CANNOT_EXECUTE_FLOW_TRIGGER, We can't save this record because the “Evaluation Process Handler_1” process failed. Give your Salesforce admin these details. No applicable approval process was found.
        //No applicable approval process was found.
//        SurveyQuestionController.resubmitForApproval(objEvaluation.Id);

        // Test for updateSurveyQuestions
        List<Survey_Question__c> listQuestions = [SELECT Id, Action_Plan__c, Survey__c, Response__c FROM Survey_Question__c ];
        List<Survey_Question__c> listYes = new List<Survey_Question__c>();
        List<Survey_Question__c> listNo = new List<Survey_Question__c>();

        if(listQuestions != null && listQuestions.size()>0){
            for(Survey_Question__c obj : listQuestions){
                if('Yes'.equalsIgnoreCase(obj.Response__c)) listYes.add(obj);
                if('No'.equalsIgnoreCase(obj.Response__c)) listNo.add(obj);
            }
        }
        SurveyQuestionController.updateSurveyQuestions(JSON.serialize(listYes), true, null);
        SurveyQuestionController.updateSurveyQuestions(JSON.serialize(listNo), true, null);

        // Test for updateContentVersion
        SurveyQuestionController.updateContentVersion(new List<String>{DocId},'Warranty_CEE_RO_Review_Excel_File__c');
        SurveyQuestionController.updateContentVersion(new List<String>{DocId},'RO_Review_Action_Plan__c');
        SurveyQuestionController.updateContentVersion(new List<String>{DocId},'WOPR_Action_Plan_WOPR_score_below_avg__c');
        SurveyQuestionController.updateContentVersion(new List<String>{DocId},'Other_WOPR_Action_Plan__c');

        // Test for getContentDocuments
        SurveyQuestionController.getContentDocuments(SurveyId);

        SurveyQuestionController.updateSurveyQuestions(JSON.serialize(listYes), true, null);
        SurveyQuestionController.updateSurveyQuestions(JSON.serialize(listNo), true, null);
        // SurveyQuestionController.resubmitForApproval(objEvaluation);
        // Test for deleteContentDocument
        DocIdList.add(DocId);
        SurveyQuestionController.deleteContentDocument(DocIdList);
        Test.stopTest();
    }

    @IsTest
    static void testMethod5(){
        // Get data
        Id EvalId = [SELECT Id FROM Evaluation__c LIMIT 1].Id;
        Id QuestionsId = [SELECT Id FROM Survey_Question__c WHERE Response__c LIKE 'Yes' LIMIT 1].Id;
        List<Survey_Question__c> listQuestions = [SELECT Id, Action_Plan__c, Survey__c, Response__c FROM Survey_Question__c ];
        Id AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id SurveyId = [SELECT Id FROM Survey__c LIMIT 1].Id;
        Id DocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title LIKE 'test content trigger%' LIMIT 1].ContentDocumentId;

        Action_Plan__c ap = new Action_Plan__c(Evaluation__c = EvalId, Account__c = AccountId, Status__c = 'Non-Compliant');
        Action_PlanTriggerHandler.run = false;
        insert ap;
        Action_PlanTriggerHandler.run = true;

        List<Survey__c> listSurvey = [SELECT Id, Evaluation__c, Status__c FROM Survey__c];
        if(listSurvey != null && listSurvey.size()>0){
            SurveyTriggerHandler.run = false;
            for(Survey__c obj : listSurvey){
                obj.Evaluation__c = EvalId;
                obj.Status__c = 'Completed';
            }

            update listSurvey;
            SurveyTriggerHandler.run = true;
        }

        // Set Data
        Test.startTest();
        

        List<Survey_Question__c> listYes = new List<Survey_Question__c>();
        List<Survey_Question__c> listNo = new List<Survey_Question__c>();

        if(listQuestions != null && listQuestions.size()>0){
            for(Survey_Question__c obj : listQuestions){
                obj.Action_Plan__c = ap.Id;
                if('Yes'.equalsIgnoreCase(obj.Response__c)) listYes.add(obj);
                if('No'.equalsIgnoreCase(obj.Response__c)){
                    obj.Response__c = 'Yes';
                    update obj;
                    listYes.add(obj);
                }else if(obj.Response__c == null || obj.Response__c == ''){
                    obj.Response__c = 'Yes';
                    update obj;
                    listYes.add(obj);
                } 
            }
        }
        SurveyQuestionController.updateSurveyQuestions(JSON.serialize(listYes), true, null);


        PageReference pageRef = Page.EvaluationPDF;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',EvalId);
        pageRef.getParameters().put('showFinancials','true');
        pageRef.getParameters().put('showApprovals','true');

        // Test for updateSurvey
        SurveyQuestionController.updateSurvey(JSON.serialize(listSurvey[0]));
        // Test for updateWarrantySurvey
        SurveyQuestionController.updateWarrantySurvey(JSON.serialize(listSurvey));
        SurveyQuestionController.updateWarrantySurveyQuestion(JSON.serialize(listSurvey));
        
        // Test for getSurveyWarrantyReviewQuestions
        SurveyQuestionController.getSurveyWarrantyReviewQuestions(EvalId, true);
        SurveyQuestionController.getSurveyWarrantyReviewQuestions(SurveyId, false);
        SurveyQuestionController.getHasCompleteAccessToRecord(EvalId); //DPM-5399 added for test coverage by Minhee - 24.03.08
        Test.stopTest();
    }

//
//    static testmethod void testGetEvaluationWithSurveyAndSurveyQuestions() {
//
//        Account account = new Account();
//        account.Name = 'Test Account';
//        insert account;
//
//        Survey__c survey = new Survey__c(Dealer__c = account.Id);
//        insert survey;
//
//        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3');
//        insert surveyQuestion;
//
//        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
//        insert evaluation;
//
//        SurveyTriggerHandler.run = false;
//        survey.Evaluation__c = evaluation.Id;
//        update survey;
//        SurveyTriggerHandler.run = true;
//
//        PageReference pageRef = Page.EvaluationPDF;
//        test.setCurrentPageReference(pageRef);
//        pageRef.getParameters().put('id',evaluation.Id);
//        pageRef.getParameters().put('showFinancials','true');
//        pageRef.getParameters().put('showApprovals','true');
//
//        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
//
//        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
//        insert cv;
//
//        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
//
//        ContentDocumentLink contentlinkeval = new ContentDocumentLink(LinkedEntityId = evaluation.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinkeval;
//
//        ContentDocumentLink contentlinksurveyquestion = new ContentDocumentLink(LinkedEntityId = surveyQuestion.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinksurveyquestion;
//
//        Test.startTest();
//        SurveyQuestionController.retrieveEvaluationDetails(survey.Id, false);
//        SurveyQuestionController.getSurveyQuestions(survey.Id, false);
//        SurveyQuestionController.retrievEvaluationAccountContacts(account.Id);
//        SurveyQuestionController.getNetworkId();
//        Test.stopTest();
//    }

//    static testmethod void testGetEvaluationWithSurveyAndSurveyQuestionsFromEval() {
//
//        Account account = new Account();
//        account.Name = 'Test Account';
//        insert account;
//
//        Survey__c survey = new Survey__c(Dealer__c = account.Id);
//        insert survey;
//
//        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3');
//        insert surveyQuestion;
//
//        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
//        insert evaluation;
//
//        SurveyTriggerHandler.run = false;
//        survey.Evaluation__c = evaluation.Id;
//        update survey;
//        SurveyTriggerHandler.run = true;
//
//        PageReference pageRef = Page.EvaluationPDF;
//        test.setCurrentPageReference(pageRef);
//        pageRef.getParameters().put('id',evaluation.Id);
//        pageRef.getParameters().put('showFinancials','true');
//        pageRef.getParameters().put('showApprovals','true');
//
//        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
//
//        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
//        insert cv;
//
//        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
//
//        ContentDocumentLink contentlinkeval = new ContentDocumentLink(LinkedEntityId = evaluation.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinkeval;
//
//        ContentDocumentLink contentlinksurveyquestion = new ContentDocumentLink(LinkedEntityId = surveyQuestion.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinksurveyquestion;
//
//        Test.startTest();
//        // SurveyQuestionController.getSurveyWarrantyReviewQuestions(evaluation.Id, true);
//        SurveyQuestionController.retrieveEvaluationDetails(evaluation.Id, true);
//        SurveyQuestionController.getSurveyQuestions(evaluation.Id, true);
//        SurveyQuestionController.getContentDocumentsForSurvey(survey.Id);
//        SurveyQuestionController.getHasEditAccessToRecord(survey.Id);
//        SurveyQuestionController.getSurveyQuestion(surveyQuestion.Id);
//        Test.stopTest();
//    }
//
//    static testmethod void testSurveyQuestionController3() {
//
//        Account account = new Account();
//        account.Name = 'Test Account';
//        insert account;
//
//        Survey__c survey = new Survey__c(Dealer__c = account.Id);
//        insert survey;
//
//        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3');
//        insert surveyQuestion;
//
//        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
//        insert evaluation;
//
//        SurveyTriggerHandler.run = false;
//        survey.Evaluation__c = evaluation.Id;
//        update survey;
//        SurveyTriggerHandler.run = true;
//
//        PageReference pageRef = Page.EvaluationPDF;
//        test.setCurrentPageReference(pageRef);
//        pageRef.getParameters().put('id',evaluation.Id);
//        pageRef.getParameters().put('showFinancials','true');
//        pageRef.getParameters().put('showApprovals','true');
//
//        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
//
//        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
//        insert cv;
//
//        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
//
//        ContentDocumentLink contentlinkeval = new ContentDocumentLink(LinkedEntityId = evaluation.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinkeval;
//
//        ContentDocumentLink contentlinksurveyquestion = new ContentDocumentLink(LinkedEntityId = surveyQuestion.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinksurveyquestion;
//
//        Test.startTest();
//        SurveyQuestionController.deleteContentDocument(testContents[0].ContentDocumentId);
//        SurveyQuestionController.saveQuestion(surveyQuestion.Id, 'Name', 'Test');
//        Test.stopTest();
//    }

//    static testmethod void testSurveyQuestionController4() {
//
//        Account account = new Account();
//        account.Name = 'Test Account';
//        insert account;
//
//        Survey__c survey = new Survey__c(Dealer__c = account.Id);
//        insert survey;
//
//        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3', Response__c = 'No');
//        insert surveyQuestion;
//
//        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
//        insert evaluation;
//
//        SurveyTriggerHandler.run = false;
//        survey.Evaluation__c = evaluation.Id;
//        update survey;
//        SurveyTriggerHandler.run = true;
//
//        PageReference pageRef = Page.EvaluationPDF;
//        test.setCurrentPageReference(pageRef);
//        pageRef.getParameters().put('id',evaluation.Id);
//        pageRef.getParameters().put('showFinancials','true');
//        pageRef.getParameters().put('showApprovals','true');
//
//        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
//
//        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
//        insert cv;
//
//        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
//
//        ContentDocumentLink contentlinkeval = new ContentDocumentLink(LinkedEntityId = evaluation.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinkeval;
//
//        ContentDocumentLink contentlinksurveyquestion = new ContentDocumentLink(LinkedEntityId = surveyQuestion.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinksurveyquestion;
//
//        Test.startTest();
//        SurveyQuestionController.saveEvaluationDetails(JSON.serialize(evaluation));
//        SurveyQuestionController.updateSurveyQuestions(JSON.serialize(new List<Survey_Question__c>{surveyQuestion}), true);
//
//        Survey_Question__c surveyQToUpdt = new Survey_Question__c(Id = surveyQuestion.Id, Response__c = 'Yes');
//        update surveyQToUpdt;
//
//        System.assertEquals('Yes', surveyQToUpdt.Response__c);
//
//        SurveyQuestionController.updateSurveyQuestions(JSON.serialize(new List<Survey_Question__c>{surveyQToUpdt}), true);
//
//        Test.stopTest();
//    }

//    static testmethod void testSurveyQuestionController5() {
//
//        Account account = new Account();
//        account.Name = 'Test Account';
//        insert account;
//
//        Survey__c survey = new Survey__c(Dealer__c = account.Id);
//        insert survey;
//
//        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3');
//        insert surveyQuestion;
//
//        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
//        insert evaluation;
//
//        SurveyTriggerHandler.run = false;
//        survey.Evaluation__c = evaluation.Id;
//        survey.Status__c = 'Completed';
//        update survey;
//        SurveyTriggerHandler.run = true;
//
//        PageReference pageRef = Page.EvaluationPDF;
//        test.setCurrentPageReference(pageRef);
//        pageRef.getParameters().put('id',evaluation.Id);
//        pageRef.getParameters().put('showFinancials','true');
//        pageRef.getParameters().put('showApprovals','true');
//
//        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
//
//        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
//        insert cv;
//
//        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
//
//        ContentDocumentLink contentlinkeval = new ContentDocumentLink(LinkedEntityId = evaluation.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinkeval;
//
//        ContentDocumentLink contentlinksurveyquestion = new ContentDocumentLink(LinkedEntityId = surveyQuestion.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinksurveyquestion;
//
//        Test.startTest();
//        SurveyQuestionController.saveEvaluationDetails(JSON.serialize(evaluation));
//        SurveyQuestionController.updateSurvey(JSON.serialize(survey));
//        Test.stopTest();
//    }

//    static testmethod void testSurveyQuestionController6() {
//
//        Account account = new Account();
//        account.Name = 'Test Account';
//        insert account;
//
//        Survey__c survey = new Survey__c(Dealer__c = account.Id);
//        insert survey;
//
//        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3');
//        insert surveyQuestion;
//
//        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
//        insert evaluation;
//
//        SurveyTriggerHandler.run = false;
//        survey.Evaluation__c = evaluation.Id;
//        survey.Status__c = 'Completed';
//        update survey;
//        SurveyTriggerHandler.run = true;
//
//        PageReference pageRef = Page.EvaluationPDF;
//        test.setCurrentPageReference(pageRef);
//        pageRef.getParameters().put('id',evaluation.Id);
//        pageRef.getParameters().put('showFinancials','true');
//        pageRef.getParameters().put('showApprovals','true');
//
//        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
//
//        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
//        insert cv;
//
//        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
//
//        ContentDocumentLink contentlinkeval = new ContentDocumentLink(LinkedEntityId = evaluation.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinkeval;
//
//        ContentDocumentLink contentlinksurveyquestion = new ContentDocumentLink(LinkedEntityId = surveyQuestion.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinksurveyquestion;
//
//        Test.startTest();
//        SurveyQuestionController.updateSurvey(JSON.serialize(survey));
//        Test.stopTest();
//    }
    
//    private static testMethod void testWarrantyUpdate() {
//
//        Survey__c survey = new Survey__c();
//        survey.Name = 'Test Survey';
//        survey.PerNumberOfRosWithoutAnyDiscrepancies__c = 10;
//
//        insert survey;
//
//        survey.PerNumberOfRosWithoutAnyDiscrepancies__c = 20;
//        String surveyJSON = JSON.serialize(survey);
//
//
//        Survey__c updatedSurvey = [SELECT PerNumberOfRosWithoutAnyDiscrepancies__c FROM Survey__c WHERE Id = :survey.Id];
//
//
//
//        Test.startTest();
//        update updatedSurvey;
//        SurveyQuestionController.checkAdminUserOrNot();
//        // SurveyQuestionController.updateWarrantySurvey(JSON.serialize(surveyJSON));
//        // SurveyQuestionController.updateWarrantySurveyQuestion(JSON.serialize(surveyJSON));
//        Test.stopTest();
//    }

//    private static testMethod void testWarrantyReview() {
//
//        List<String> documentIds = new List<String>();
//
//        Account account = new Account();
//        account.Name = 'Test Account';
//        insert account;
//
//        Survey__c survey = new Survey__c(Dealer__c = account.Id);
//        insert survey;
//
//        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
//
//        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
//        insert cv;
//
//        System.assert(cv != NULL);
//
//        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
//
//        System.assert(testContents[0].ContentDocumentId != NULL);
//
//        ContentDocumentLink contentlinkeval = new ContentDocumentLink(LinkedEntityId = survey.Id, ContentDocumentId = testContents[0].ContentDocumentId);
//        insert contentlinkeval;
//
//          System.assert(contentlinkeval != NULL);
//
//        documentIds.add(testContents[0].ContentDocumentId);
//
//        SurveyQuestionController.updateContentVersion(documentIds,'Warranty_CEE_RO_Review_Excel_File__c');
//         SurveyQuestionController.updateContentVersion(documentIds,'RO_Review_Action_Plan__c');
//         SurveyQuestionController.updateContentVersion(documentIds,'WOPR_Action_Plan_WOPR_score_below_avg__c');
//         SurveyQuestionController.updateContentVersion(documentIds,'Other_WOPR_Action_Plan__c');
//
//        SurveyQuestionController.getContentDocuments(survey.Id);
//        SurveyQuestionController.getWarrantyReviewMetadata();
//    }
}