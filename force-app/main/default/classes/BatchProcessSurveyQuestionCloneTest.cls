@isTest
public without sharing class BatchProcessSurveyQuestionCloneTest {

    static testMethod void testBatchProcessSurveyQuestionCloneTest1() {
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Survey__c surveyTemplate = new Survey__c();
        insert surveyTemplate;

        Survey__c survey = new Survey__c(Dealer__c = account.Id, ApexJobId__c = '1', SurveyTemplate__c = surveyTemplate.Id);
        insert survey;

        Survey_Question__c surveyTemplateQuestion = new Survey_Question__c(Survey__c = surveyTemplate.Id, Table_Columns__c = 'Test1;Test2;Test3');
        insert surveyTemplateQuestion;

        Survey_Question__c surveyTemplateQuestionChild = new Survey_Question__c(Survey__c = surveyTemplate.Id, Table_Columns__c = 'Test1;Test2;Test3', DependentQuestion__c = surveyTemplateQuestion.Id);
        insert surveyTemplateQuestionChild;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, ApexJobId__c = survey.Id);
        insert evaluation;

        SurveyTriggerHandler.run = false;
        survey.Evaluation__c = evaluation.Id;
        survey.ApexJobId__c = survey.Id;
        update survey;


        SurveyTriggerHandler.run = true;

        Test.startTest();
        BatchProcessSurveyQuestionClone batchClone = new BatchProcessSurveyQuestionClone(survey.Id);
        Database.executeBatch(batchClone);
        Test.stopTest();
    }
}