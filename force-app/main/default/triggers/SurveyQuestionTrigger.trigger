/**
 * @description       : Trigger for Survey Question object
 * @author            : minheekim@haeaus.com
 * @group             : 
 * @last modified on  : 03-04-2025
 * @last modified by  : Minhee Kim
**/
trigger SurveyQuestionTrigger on Survey_Question__c (before insert, before update, after insert, after update) {
    Trigger_Framework.createHandler(Survey_Question__c.sObjectType);
}
