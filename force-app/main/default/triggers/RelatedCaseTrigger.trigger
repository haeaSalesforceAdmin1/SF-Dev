trigger RelatedCaseTrigger on RelatedCase__c (before delete) {
    Trigger_Framework.createHandler(RelatedCase__c.SObjectType);
   
}