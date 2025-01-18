trigger SurveyTrigger on Survey__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Framework.createHandler(Survey__c.sObjectType);
}