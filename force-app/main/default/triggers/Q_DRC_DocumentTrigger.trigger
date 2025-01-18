/**
 * @description       : 
 * @author            : sankang@autoeveramerica.com
 * @group             : 
 * @last modified on  : 09-13-2024
 * @last modified by  : sankang@autoeveramerica.com
**/
trigger Q_DRC_DocumentTrigger on Q_DRC_Document__c (after insert, after update, after delete) {
    Trigger_Framework.createHandler(Q_DRC_Document__c.SObjectType);
}