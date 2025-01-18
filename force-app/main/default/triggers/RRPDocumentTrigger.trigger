trigger RRPDocumentTrigger on RRPDocument__c (after insert, after update, after delete) {
    Trigger_Framework.createHandler(RRPDocument__c.sObjectType);
}