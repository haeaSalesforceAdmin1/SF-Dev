trigger ActionPlanTrigger on Action_Plan__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Framework.createHandler(Action_Plan__c.sObjectType);
}