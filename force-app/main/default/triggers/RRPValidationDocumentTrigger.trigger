trigger RRPValidationDocumentTrigger on RRPValidationDocument__c (after insert, after update, after delete) {
    Trigger_Framework.createHandler(RRPValidationDocument__c.sObjectType);
}