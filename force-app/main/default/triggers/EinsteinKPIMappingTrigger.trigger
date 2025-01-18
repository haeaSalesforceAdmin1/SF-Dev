trigger EinsteinKPIMappingTrigger on EinsteinKPIMapping__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Framework.createHandler(EinsteinKPIMapping__c.sObjectType);
}