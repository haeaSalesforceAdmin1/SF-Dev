/*
   * @class Created to test updateGenesisEvaluation() 
   * @desc DPM-5633
   * @created by Minhee Kim
   * @created date 2024-08-11
   */

  @isTest
  public with sharing class SurveyTriggerHandlerTest {
      
      @testSetup
      static void setupTestData() {
          // Create Record Types
          RecordType salesRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Survey__c' AND  DeveloperName = 'GenesisRetailerEvalSales' LIMIT 1];
          
          RecordType serviceRecordType =  [SELECT Id FROM RecordType WHERE SObjectType = 'Survey__c' AND  DeveloperName = 'GenesisRetailerEvalService' LIMIT 1];
  
          // Create Evaluation records
          List<Evaluation__c> evaluations = new List<Evaluation__c>();
          for (Integer i = 0; i < 5; i++) {
              evaluations.add(new Evaluation__c(Name = 'Evaluation ' + i, 
              GBX_Score__c = 950 + i,
                  GSX_Score__c = 910 + i,
                  Status__c = 'Not Started',
                  Action_Plan_Status__c = 'Not Started'));
          }
          insert evaluations;
  
          // Create Survey records
          List<Survey__c> surveys = new List<Survey__c>();
          for (Integer i = 0; i < 5; i++) {
              surveys.add(new Survey__c(
                  Name = 'Survey ' + i,
                  Evaluation__c = evaluations[i].Id,
                  RecordTypeId = (Math.mod( i, 2 ) == 0) ? salesRecordType.Id : serviceRecordType.Id,
                  Status__c = 'Completed',
                  //Total_Score__c = (Math.mod( i, 2 ) == 0) ? 100.0 : 75.0,
                  //GenesisEvaluationStatus__c = 'Not Started',
                  //GBX_Score__c = 950 + i,
                  //GSX_Score__c = 910 + i,
                  ActionPlanRequired__c = (Math.mod( i, 2 ) == 0) ? false : true
              ));
          }
          insert surveys;
  
          User usr = TestUtility.createInternalUser('TestforSurvey', 'Test','System Administrator');
          List<Survey__Share> surveyShare = new List<Survey__Share>();
          for(Survey__c survey : surveys){
            surveyShare.add(new Survey__Share(ParentId = survey.Id, UserOrGroupId = usr.Id,AccessLevel= 'Edit',RowCause= Schema.Survey__Share.RowCause.Survey_Sharing__c));
            surveyShare.add(new Survey__Share(ParentId = survey.Id, UserOrGroupId = usr.Id,AccessLevel= 'Edit',RowCause= Schema.Survey__Share.RowCause.Dealer_Survey_Sharing__c));
          }
          
          insert surveyShare;
         
      }
  
       /*
     * @method Created to test updateGenesisEvaluation() 
     * @desc DPM-5633
     * @created by Minhee Kim
     * @created date 2024-08-11
     */
      @isTest
      static void testUpdateGenesisEvaluationStatus() {
          // Retrieve the surveys to update
          List<Survey__c> newSurveys = [SELECT Id, Evaluation__c, RecordTypeId, Status__c, Total_Score__c, GenesisEvaluationStatus__c, GBX_Score__c, GSX_Score__c, ActionPlanRequired__c FROM Survey__c];
          
          // Create a map of old surveys
          Map<Id, Survey__c> oldSurveysMap = new Map<Id, Survey__c>(newSurveys);
          
          // Update the surveys
          Test.startTest();
          SurveyTriggerHelper.updateGenesisEvaluationStatus(newSurveys, oldSurveysMap);
          Test.stopTest();
          
          // Validate the changes
          List<Evaluation__c> updatedEvaluations = [SELECT Id, Action_Plan_Status__c, Indicator__c, DueDate__c FROM Evaluation__c];
          
          for (Evaluation__c eval : updatedEvaluations) {
              if (eval.Action_Plan_Status__c == 'Completed') {
                  System.assertEquals('Action Plan Not Required', eval.Indicator__c, 'Indicator__c should be "Action Plan Not Required" for completed evaluations.');
              } else if (eval.Action_Plan_Status__c == 'Pending') {
                  if (eval.Indicator__c == 'Action Plan Required') {
                      System.assertEquals(Date.today().addDays(30), eval.DueDate__c, 'DueDate__c should be 30 days from today for evaluations requiring an action plan.');
                  } else if (eval.Indicator__c == 'Action Plan Not Required') {
                      System.assertEquals(Date.today().addDays(30), eval.DueDate__c, 'DueDate__c should be 30 days from today for evaluations not requiring an action plan.');
                  }
              }
          }
      }
      
      @isTest
      static void testUpdatePercent() {
          // Retrieve the surveys to update
          List<Survey__c> newSurveys = [SELECT Id, Evaluation__c, RecordTypeId, Status__c, Total_Score__c, GenesisEvaluationStatus__c, GBX_Score__c, GSX_Score__c, ActionPlanRequired__c FROM Survey__c];
          
          // Create a map of old surveys
          Map<Id, Survey__c> oldSurveysMap = new Map<Id, Survey__c>(newSurveys);
          
          // Update the surveys
          Test.startTest();
          SurveyTriggerHelper.updateTotalPercent(oldSurveysMap.keySet());
          Test.stopTest();
      }
  }