/**
 * @last modified on  : 08-03-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
trigger ContentVersionTrigger on ContentVersion (before insert, after insert, before update, after update, before delete, after delete) {
    if (BypassTriggers__c.getInstance().ContentVersionTrigger__c) {
        System.Debug('ContentVersion Trigger ByPassed.');
        return;
    }

    Trigger_Framework.createHandler(ContentVersion.SObjectType);
   
}