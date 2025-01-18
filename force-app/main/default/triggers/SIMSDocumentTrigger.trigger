/**
 * @description       : 
 * @author            : sankang@autoeveramerica.com
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/

trigger SIMSDocumentTrigger on SIMS_Document__c (after insert, after update, after delete) {
    Trigger_Framework.createHandler(SIMS_Document__c.SObjectType);
}