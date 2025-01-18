/**
 * @description       : 
 * @author            : sankang@autoeveramerica.com
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
trigger LegalDocumentTrigger on LegalDocument__c (after insert, after update, after delete) {
    Trigger_Framework.createHandler(LegalDocument__c.SObjectType);
}