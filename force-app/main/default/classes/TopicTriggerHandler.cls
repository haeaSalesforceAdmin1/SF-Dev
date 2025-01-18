public class TopicTriggerHandler extends Trigger_Framework.baseHandler {

    public override void beforeInsert(List<SObject> newListGeneric){
        List<Topic__c> newList = (List<Topic__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        TopicTriggerHelper.handleBeforeInsertTopic(newList);
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Topic__c> oldMap = (Map<Id, Topic__c>) oldMapGeneric;
        Map<Id, Topic__c> newMap = (Map<Id, Topic__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        List<Topic__c> updatedLastRunDateTopics = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), new Set<String> {'LastRunDate__c'});
        if(!updatedLastRunDateTopics.isEmpty()) {
            TopicTriggerHelper.handleBeforeUpdateTopic(updatedLastRunDateTopics);
        }
        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Topic__c> oldMap = (Map<Id, Topic__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/

        /*BEFORE DELETE METHODS END*/
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        Map<Id, Topic__c> newMap = (Map<Id, Topic__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/

        /*AFTER INSERT METHODS END*/
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Topic__c> oldMap = (Map<Id, Topic__c>) oldMapGeneric;
        Map<Id, Topic__c> newMap = (Map<Id, Topic__c>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/


        //setAcctSharing(usrList);KillSwitchEnabled

        /*AFTER UPDATE METHODS END*/
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Topic__c> oldMap = (Map<Id, Topic__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/

        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, Topic__c> newMap = (Map<Id, Topic__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}