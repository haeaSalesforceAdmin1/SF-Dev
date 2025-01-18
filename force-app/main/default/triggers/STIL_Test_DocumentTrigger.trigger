trigger STIL_Test_DocumentTrigger on STIL_Test_Document__c (after insert, after update, after delete) {
    Trigger_Framework.createHandler(STIL_Test_Document__c.sObjectType);
}