/**
* @date 09/28/2020
* @description trigger for HMAUserProvisioning__c
*/
trigger HMAUserProvisioningTrigger on HMAUserProvisioning__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Framework.createHandler(HMAUserProvisioning__c.sObjectType);
}