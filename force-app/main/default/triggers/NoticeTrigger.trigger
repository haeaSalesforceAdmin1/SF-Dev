/**
 * @description       : 
 * @author            : inhokim
 * @group             : 
 * @last modified on  : 02-15-2024
 * @last modified by  : inhokim
**/
trigger NoticeTrigger on Notice__c(before insert, before update) {
    Trigger_Framework.createHandler(Notice__c.SObjectType);   
}