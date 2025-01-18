trigger EvaluationTrigger on Evaluation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	Trigger_Framework.createHandler(Evaluation__c.sObjectType);
}