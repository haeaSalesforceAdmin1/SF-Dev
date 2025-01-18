trigger EinsteinKPIDetailTrigger on EinsteinKPIDetail__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Framework.createHandler(EinsteinKPIDetail__c.sObjectType);
}