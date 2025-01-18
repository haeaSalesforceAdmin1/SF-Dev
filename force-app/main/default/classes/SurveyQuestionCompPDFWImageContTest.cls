@isTest
public class SurveyQuestionCompPDFWImageContTest {

   static testMethod void testSurveyQuestionCompPDFController() {
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;
        
        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3');
        insert surveyQuestion;
        
        Survey_Question__c surveyQuestionChild = new Survey_Question__c(Survey__c = survey.Id, DependentQuestion__c = surveyQuestion.Id);
        insert surveyQuestionChild;
        
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;
        
        PageReference pageRef = Page.SuveyCompPDF;
        //PageReference pageRef = Page.SurveyQuestionCompWImagePDF;
		//PageReference pageRef = Page.SurveyPDF_wo_image;
        test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',survey.Id);

        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
        
        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
        insert cv;
        
        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
        
        ContentDocumentLink contentlinkeval = new ContentDocumentLink(LinkedEntityId = evaluation.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        insert contentlinkeval;
        
        ContentDocumentLink contentlinksurveyquestion = new ContentDocumentLink(LinkedEntityId = surveyQuestion.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        insert contentlinksurveyquestion;
        
        Test.startTest();
        SurveyQuestionCompPDFWImageController cs = new SurveyQuestionCompPDFWImageController();
        cs.handleLoad();
        Test.stopTest();
    }
    
    static testMethod void testSurveyQuestionCompPDFControllerLaunchQueueable() {
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;
        
        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3');
        insert surveyQuestion;
        
        Survey_Question__c surveyQuestionChild = new Survey_Question__c(Survey__c = survey.Id, DependentQuestion__c = surveyQuestion.Id);
        insert surveyQuestionChild;
        
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;
        
        Test.startTest();
        String jobId = SurveyQuestionCompPDFWImageController.launchQueueableForSurveyGeneration(survey.Id);
        SurveyQuestionCompPDFWImageController.getQueueableForSurveyGenerationStatus(jobId);
        Test.stopTest();
    }
    
    
    static testMethod void testGetSurveyDetails() {
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;
        
        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3');
        insert surveyQuestion;
        
        Survey_Question__c surveyQuestionChild = new Survey_Question__c(Survey__c = survey.Id, DependentQuestion__c = surveyQuestion.Id);
        insert surveyQuestionChild;
        
        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;
        
        Test.startTest();
        SurveyQuestionCompPDFWImageController.getSurveyDetails(survey.Id);
        Test.stopTest();
    }
}