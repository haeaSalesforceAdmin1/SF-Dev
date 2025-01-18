trigger DistrictTrigger on District__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Framework.createHandler(District__c.sObjectType);
}