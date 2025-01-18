trigger STIL_Lab_Request_SecureTrigger on STIL_Lab_Request_Secure_Document__c (after insert, after update, before delete, after delete) {
    Trigger_Framework.createHandler(STIL_Lab_Request_Secure_Document__c.sObjectType);
}