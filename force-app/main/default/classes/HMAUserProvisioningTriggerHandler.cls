public class HMAUserProvisioningTriggerHandler extends Trigger_Framework.baseHandler {

    public static boolean run = true;

    public override void beforeInsert(List<SObject> newListGeneric){
        if(!run) {
            return;
        }

        List<HMAUserProvisioning__c> newList = (List<HMAUserProvisioning__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        HMAUserProvisioningTriggerHelper.handleBeforeInsertUserProvision(newList); 
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, HMAUserProvisioning__c> oldMap = (Map<Id, HMAUserProvisioning__c>) oldMapGeneric;
        Map<Id, HMAUserProvisioning__c> newMap = (Map<Id, HMAUserProvisioning__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/

        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, HMAUserProvisioning__c> oldMap = (Map<Id, HMAUserProvisioning__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/

        /*BEFORE DELETE METHODS END*/
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, HMAUserProvisioning__c> newMap = (Map<Id, HMAUserProvisioning__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        List<HMAUserProvisioning__c> processingUserProvisions = Trigger_DiffRecord.getRecordsWithFieldValue(newMap.values(), 'Status__c', 'Processing');
        


        if(!processingUserProvisions.isEmpty()) {
            HMAUserProvisioningTriggerHelper.handleProcessingUserProvisioning(processingUserProvisions);
        }
        /*AFTER INSERT METHODS END*/
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, HMAUserProvisioning__c> oldMap = (Map<Id, HMAUserProvisioning__c>) oldMapGeneric;
        Map<Id, HMAUserProvisioning__c> newMap = (Map<Id, HMAUserProvisioning__c>) newMapGeneric; 

        /*AFTER UPDATE METHODS START*/
        List<HMAUserProvisioning__c> completedUserProvisions = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), 'Status__c', 'Completed');
        List<HMAUserProvisioning__c> processingUserProvisionErrors = Trigger_DiffRecord.getRecordsWithFieldValue(newMap.values(), 'Status__c', 'Error');
        
        if(!processingUserProvisionErrors.isEmpty()) {
            completedUserProvisions.addAll(processingUserProvisionErrors);
        }
        if(!completedUserProvisions.isEmpty()) {
            HMAUserProvisioningTriggerHelper.handleAfterUpdateForCompletedUserProvisioning(completedUserProvisions);
        }

        List<HMAUserProvisioning__c> processingUserProvisions = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), 'Status__c', 'Processing');
        if(!processingUserProvisions.isEmpty()) {
            HMAUserProvisioningTriggerHelper.handleProcessingUserProvisioning(processingUserProvisions);
        }

        /*AFTER UPDATE METHODS END*/
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, HMAUserProvisioning__c> oldMap = (Map<Id, HMAUserProvisioning__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/

        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, HMAUserProvisioning__c> newMap = (Map<Id, HMAUserProvisioning__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}