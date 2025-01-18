trigger RRPTrigger on RRP__c (before update, after insert, after update) {
    Trigger_Framework.createHandler(RRP__c.sObjectType);
}