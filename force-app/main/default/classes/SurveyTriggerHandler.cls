public class SurveyTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = true;
    public static Boolean isInserting = false;

    public override void beforeInsert(List<SObject> newListGeneric){

        if(!run) {
            return;
        }
        isInserting = true;
        List<Survey__c> newList = (List<Survey__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        
        SurveyTriggerHelper.populateSurveyFromAccount(newList,null);
        SurveyTriggerHelper.populateAssignedDealOnPartnerOwner(newList, null);
        
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Survey__c> oldMap = (Map<Id, Survey__c>) oldMapGeneric;
        Map<Id, Survey__c> newMap = (Map<Id, Survey__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        SurveyTriggerHelper.populateSurveyFromAccount(newMap.values(),oldMap);
        SurveyTriggerHelper.populateAssignedDealOnPartnerOwner(newMap.values(), oldMap);
        SurveyTriggerHelper.updateGenesisEvaluationStatus(newMap.values(), oldMap); //DPM-5633 Added for Genesis Evaluation
        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Survey__c> oldMap = (Map<Id, Survey__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/

        /*BEFORE DELETE METHODS END*/
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Survey__c> newMap = (Map<Id, Survey__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        //EvaluationTriggerHelper.createEvaluationSharing(newMap);
        SurveyTriggerHelper.handleSurveySharing(newMap, false);
        /*AFTER INSERT METHODS END*/
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Survey__c> oldMap = (Map<Id, Survey__c>) oldMapGeneric;
        Map<Id, Survey__c> newMap = (Map<Id, Survey__c>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/
        SurveyTriggerHelper.handleCompletedSurveyUpdate(newMap.values(), oldMap);
        if(!isInserting) {
            SurveyTriggerHelper.handleSurveySharing(newMap, true);
        }
        //EvaluationTriggerHelper.recalculateEvaluationSharing(newMap.values());
        //EvaluationTriggerHelper.createEvaluationDealerSharing(newMap.values());

        //setAcctSharing(usrList);KillSwitchEnabled
        // DPM-4548
        run = false;
        /*AFTER UPDATE METHODS END*/
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Survey__c> oldMap = (Map<Id, Survey__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/

        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Survey__c> newMap = (Map<Id, Survey__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}