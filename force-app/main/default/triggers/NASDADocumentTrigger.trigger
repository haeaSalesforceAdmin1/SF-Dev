/**
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
trigger NASDADocumentTrigger on NASDADocument__c (before update, before delete, after insert, after update, after delete) {
    Trigger_Framework.createHandler(NASDADocument__c.SObjectType);
}