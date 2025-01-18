@isTest
public without sharing class BatchToUpdateContentDocumentLinkTest {

    static testMethod void testBatchToUpdateContentDocumentLinkTest(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Survey__c surveyTemplate = new Survey__c();
        insert surveyTemplate;

        Survey__c survey = new Survey__c(Dealer__c = account.Id, ApexJobId__c = '1', SurveyTemplate__c = surveyTemplate.Id);
        insert survey;

        Survey_Question__c surveyTemplateQuestion = new Survey_Question__c(Survey__c = surveyTemplate.Id, Table_Columns__c = 'Test1;Test2;Test3');
        insert surveyTemplateQuestion;
        
        ContentVersion contentVersion = new Contentversion(Title = 'Test', PathOnClient = 'Test.jpg', Versiondata = Blob.valueOf('Unit Test Attachment Body'));
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument];
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(LinkedEntityId = surveyTemplateQuestion.Id, Visibility = 'InternalUsers', ContentDocumentId =documents[0].Id);
        insert contentDocumentLink;
        
        Test.startTest();
        BatchToUpdateContentDocumentLink batch = new BatchToUpdateContentDocumentLink();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}