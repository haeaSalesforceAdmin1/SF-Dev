/**
 * @description       : Trigger Class for Survey Question trigger handler
 * @author            : minheekim@haeaus.com
 * @group             : 
 * @last modified on  : 03-04-2025
 * @last modified by  : Minhee Kim
**/
@isTest
public with sharing class SurveyQuestionTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        List<Survey__c> listSurvey = new List<Survey__c>();
        Survey__c objSurvey1 = new Survey__c();
        listSurvey.add(objSurvey1);

        insert listSurvey;
        
    }

    static testMethod void testHandleQuestionNumber() {
        // Step 1: Create a RecordType for Evaluation__c
        RecordType warrantyRecordType = [SELECT Id FROM RecordType WHERE  SObjectType = 'Survey_Question__c' AND Name like 'Warranty RO Survey%' LIMIT 1];
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];
        List<Survey_Question__c> surveyQuestions = new List<Survey_Question__c>{
            new Survey_Question__c(RecordTypeId = warrantyRecordType.Id, Survey__c = survey.Id, Question_Number_Text__c = 'Q12'),
            new Survey_Question__c(RecordTypeId = warrantyRecordType.Id, Survey__c = survey.Id, Question_Number_Text__c = 'Q.34'),
            new Survey_Question__c(RecordTypeId = warrantyRecordType.Id, Survey__c = survey.Id, Question_Number_Text__c = 'Q_56'),
            new Survey_Question__c(RecordTypeId = warrantyRecordType.Id, Survey__c = survey.Id, Question_Number_Text__c = 'Question78'),
            new Survey_Question__c(RecordTypeId = warrantyRecordType.Id, Survey__c = survey.Id, Question_Number_Text__c = 'QABC')
        };
        insert surveyQuestions;

        Map<Id, Survey_Question__c> oldSurveyQuestionMap = new Map<Id, Survey_Question__c>();

        for (Survey_Question__c sq : surveyQuestions) {
            oldSurveyQuestionMap.put(sq.Id, sq);
        }

        Test.startTest();
        SurveyQuestionTriggerHelper.handleQuestionNumber(surveyQuestions, oldSurveyQuestionMap);
        surveyQuestions[0].Question_Number_Text__c = 'Q.12';
        update surveyQuestions;
        Test.stopTest();

        List<Survey_Question__c> updatedSurveyQuestions = [SELECT Id, Question_Number__c FROM Survey_Question__c];
        
        System.assertEquals(12, updatedSurveyQuestions[0].Question_Number__c, 'Q12 -> 12 failed to change');
        System.assertEquals(34, updatedSurveyQuestions[1].Question_Number__c, 'Q.34 -> 34 failed to change');
        System.assertEquals(56, updatedSurveyQuestions[2].Question_Number__c, 'Q_56 -> 56 failed to change');
        System.assertEquals(78, updatedSurveyQuestions[3].Question_Number__c, 'Question78 -> 78 failed to change');
        System.assertEquals(null, updatedSurveyQuestions[4].Question_Number__c, 'QABC -> should not be changed');
    }

    static testMethod void testGetWarrantyRecType() {
        RecordType warrantyRecordType = [SELECT Id FROM RecordType WHERE  SObjectType = 'Survey_Question__c' AND Name like 'Warranty RO Survey%' LIMIT 1];
        
        Test.startTest();
        SurveyQuestionTriggerHelper.getWarrantyRecType();
        Test.stopTest();
    }
}