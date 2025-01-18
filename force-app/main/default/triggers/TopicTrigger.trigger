trigger TopicTrigger on Topic__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	Trigger_Framework.createHandler(Topic__c.sObjectType);
}