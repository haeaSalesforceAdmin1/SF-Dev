/**
 * Description: [EvaluationTriggerHandler]
 * ----- Change Log -----
 * Edited by [JonghoonKim] / [10-07-2024] / [Ticket 5663] / [Created evaluationDPMRTopicChange Method] 
 * Edited by [JonghoonKim] / [11-08-2024] / [Ticket 5924] / [Created preventDuplicateEvaluation Method]
 * Edited by [MinheeKim] / [02-04-2025] / [Ticket 6017] / input the business last modified date
 * ---------------------------
 */
public class EvaluationTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = AccountTriggerHandler.run ? true : false; //DPM-4456 changed from "true" to "AccountTriggerHandler.run ? true : false"  to prevent runiing when AccountTriggerHdler is false by Minhee - 24.04.03
    public static Boolean isInserting = false;

    /**
     * [Method Description] Before insert handler
     * Edited by [MinheeKim] on [02-04-2025] for [DPM-6017] add the method to input the business last modified date, by
    */
    public override void beforeInsert(List<SObject> newListGeneric){
        List<Evaluation__c> newList = (List<Evaluation__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        if(!run) {
            return;
        }
        isInserting = true;
        EvaluationTriggerHelper.preventDuplicateEvaluation(newList); // DPM-5924 Prevent Duplicate Reocrd
        EvaluationTriggerHelper.populatePrimaryContactUserId(newList, false); //DPM-5550 added isupdate parameter to reduce CPU by MinheeKim - 24.05.11
        EvaluationTriggerHelper.populateEvaluationFromAccount(newList,null);
        EvaluationTriggerHelper.populateAssignedDealOnPartnerOwner(newList, null);
        EvaluationTriggerHelper.UpdateDealerIndicator(newList, null);
        EvaluationTriggerHelper.updateBusinessLastmodified(newList, null); //DPM-6017 method to input the business last modified date, by MinheeKim - 02.04.2025
        
        /*BEFORE INSERT METHODS END*/
    }

    /**
     * [Method Description] Before update handler
     * Edited by [MinheeKim] on [02-04-2025] for [DPM-6017] add the method to input the business last modified date, by
    */
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){

        Map<Id, Evaluation__c> oldMap = (Map<Id, Evaluation__c>) oldMapGeneric;
        Map<Id, Evaluation__c> newMap = (Map<Id, Evaluation__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        if(!run) {
            return;
        }
        List<Evaluation__c> evaluationsWithPrimaryContactChange = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), new Set<String> {'PrimaryContact__c'});
        if(!evaluationsWithPrimaryContactChange.isEmpty()) {
            EvaluationTriggerHelper.populatePrimaryContactUserId(evaluationsWithPrimaryContactChange, true); //DPM-5550 added isupdate parameter to reduce CPU by MinheeKim - 24.05.11
        }

        EvaluationTriggerHelper.evaluationDPMRTopicChange(newMap.values(), oldMap); // DPM-5663 JongHoon Kim
        EvaluationTriggerHelper.populateAssignedDealOnPartnerOwner(newMap.values(), oldMap);
        EvaluationTriggerHelper.populateDistrictApproverEmail(newMap.values(),oldMap);
        EvaluationTriggerHelper.populateEvaluationFromAccount(newMap.values(),oldMap);
        EvaluationTriggerHelper.UpdateDealerIndicator(newMap.values(), null);

        EvaluationTriggerHelper.updateGenesisEvaluation(newMap.values(), oldMap); //DPM-5633 Added for Genesis Evaluation
        EvaluationTriggerHelper.updateBusinessLastmodified(newMap.values(), oldMap); //DPM-6017 method to input the business last modified date, by MinheeKim - 02.04.2025
        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){

        Map<Id, Evaluation__c> oldMap = (Map<Id, Evaluation__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/
        if(!run) {
            return;
        }
        /*BEFORE DELETE METHODS END*/
    }

    /**
     * [Method Description] COPP Project - Attach the tracker pdf to copp evaluation
     * Created by [MinheeKim] on [2024-09-23] for [DPM-5709]
    */
    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Evaluation__c> newMap = (Map<Id, Evaluation__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        //bak EvaluationTriggerHelper.createEvaluationSharing(newMap);
        //bak EvaluationTriggerHelper.createEvaluationDealerSharing(newMap);
        EvaluationTriggerHelper.handleEvaluationSharing(newMap, false);
        /*AFTER INSERT METHODS END*/

        //DPM-5709 start
        EvaluationTriggerHelper.attachTrackerOnEval(newMap.values());
        //DPM-5709 end

    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Evaluation__c> oldMap = (Map<Id, Evaluation__c>) oldMapGeneric;
        Map<Id, Evaluation__c> newMap = (Map<Id, Evaluation__c>) newMapGeneric;

        if(!run) {
            return;
        }
        /*AFTER UPDATE METHODS START*/
        //bak EvaluationTriggerHelper.recalculateEvaluationSharing(newMap.values());
        EvaluationTriggerHelper.handleEvaluationStatusChange(newMap.values(), oldMap);
        EvaluationTriggerHelper.removeManualShareEval(newMap.values(), oldMap);
        if(!isInserting) {

        }
        if(!isInserting) {
            EvaluationTriggerHelper.handleEvaluationSharing(newMap, true);
        }
        //setAcctSharing(usrList);KillSwitchEnabled
        /*AFTER UPDATE METHODS END*/
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Evaluation__c> oldMap = (Map<Id, Evaluation__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/

        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){

        Map<Id, Evaluation__c> newMap = (Map<Id, Evaluation__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}