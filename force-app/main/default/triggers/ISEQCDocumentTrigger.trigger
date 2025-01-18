trigger ISEQCDocumentTrigger on ISEQCDocument__c(after insert, after update, after delete) {
    Trigger_Framework.createHandler(ISEQCDocument__c.sObjectType);
}