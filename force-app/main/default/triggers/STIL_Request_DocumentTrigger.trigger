trigger STIL_Request_DocumentTrigger on STIL_Request_Document__c (after insert, after update, after delete) {
    Trigger_Framework.createHandler(STIL_Request_Document__c.sObjectType);
}