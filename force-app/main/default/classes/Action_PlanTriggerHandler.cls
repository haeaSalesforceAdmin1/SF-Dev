public class Action_PlanTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = AccountTriggerHandler.run ? true : false; //DPM-4456 changed from "true" to "AccountTriggerHandler.run ? true : false"  to prevent runiing when AccountTriggerHdler is false by Minhee - 24.04.03
    public static Boolean isInserting = false;

    public override void beforeInsert(List<SObject> newListGeneric){

        if(!run) {
            return;
        }
        isInserting = true;
        List<Action_Plan__c> newList = (List<Action_Plan__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        
        ActionPlanTriggerHelper.populateAccountForActionsPlansCreatedFromEinsteinKPI(newList);
        ActionPlanTriggerHelper.populateActionPlanFromAccount(newList,null);
        ActionPlanTriggerHelper.populateOwnerFromPrimaryContactUser(newList);
        ActionPlanTriggerHelper.populateAssignedDealOnPartnerOwner(newList, null);
        ActionPlanTriggerHelper.updateFollowUpDate(newList);
        ActionPlanTriggerHelper.validateCarryOverLogic(newList, null);
        ActionPlanTriggerHelper.UpdateDealerIndicator(newList, null);
        ActionPlanTriggerHelper.insertRegionManager(newList, null); //DPM-5120 added by Minhee - 2024.01.11 //DPM-5426 added null - 24.03.18

        /*BEFORE INSERT METHODS END*/
    }

    /**
     * [Method Description] Added condition to check whether it is processing for 'Send back'
     * Edited by [MinheeKim] on [2023-12-04] for [DPM-5173]
     * Edited by [MinheeKim] on [2024-02-07] for [DPM-5340]
     * Edited by [MinheeKim] on [2024-04-30] for [DPM-5400] Added try catch at ActionPlanTriggerHelper.populateAssignedDealOnPartnerOwner to publish event to aura component when error occurs.
    */
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        
        Map<Id, Action_Plan__c> oldMap = (Map<Id, Action_Plan__c>) oldMapGeneric;
        Map<Id, Action_Plan__c> newMap = (Map<Id, Action_Plan__c>) newMapGeneric;
        //DPM-5173 added to check whether it is processing for 'Send back' by MH - 2023.12.01
        for(Id key:newMap.keySet()){
            if((newMap.get(key).ApprovalStatus__c).contains('Sent Back') && (newMap.get(key).ApprovalStatus__c != oldMap.get(key).ApprovalStatus__c)){ //DPM-5340 Added to run when status changed to "sent back" 24.02.06
                run=true;
            }
        }//DPM-5173 End

        if(!run) {
            return;
        } 

        
        /*BEFORE UPDATE METHODS START*/

        //List<Action_Plan__c> accountUpdateActionPlans = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), new Set<String> {'Account__c'});
        //List<Action_Plan__c> RegionUpdateActionPlans = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), new Set<String> {'RegionRef__c'});

        //if(!accountUpdateActionPlans.isEmpty() || !RegionUpdateActionPlans.isEmpty()|| true) {
        // DPM-4754
        //ActionPlanTriggerHelper.populateActionPlanFromAccount(newMapGeneric.values(), oldMap);
        //}
        // DPM-4548
        
            if(!isInserting || test.isRunningTest()){
                List<Action_Plan__c> primaryContactUpdateActionPlans = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), new Set<String>{
                        'EvaluationPrimaryContactId__c'
                });
                if (!primaryContactUpdateActionPlans.isEmpty()) {
                    ActionPlanTriggerHelper.populateOwnerFromPrimaryContactUser(primaryContactUpdateActionPlans);
                }
                //DPM-5400 added try catch exception to publish error to aura controller by MinheeKim - 24.05.01
                try{    
                    ActionPlanTriggerHelper.populateAssignedDealOnPartnerOwner(newMap.values(), oldMap);
                }catch(Exception e){
                    
                    ErrorMessageController.getEventData(e.getMessage());
                    System.debug('Original_Partner_User_ID__c is inactive user');
                    
                }
                System.debug('I did populateAssignedDealOnPartnerOwner');
                ActionPlanTriggerHelper.UpdateDealerIndicator(newMap.values(), oldMap);
            }
            ActionPlanTriggerHelper.updateFollowUpDate(newMap.values());
            ActionPlanTriggerHelper.validateCarryOverLogic(newMap.values(), oldMap);
            ActionPlanTriggerHelper.insertRegionManager(newMap.values(), oldMap); //DPM-5120 added by Minhee - 2024.01.11 //DPM-5426 added oldMap - 24.03.18
        
        /*BEFORE UPDATE METHODS END*/ 
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Action_Plan__c> oldMap = (Map<Id, Action_Plan__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/

        /*BEFORE DELETE METHODS END*/
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Action_Plan__c> newMap = (Map<Id, Action_Plan__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        ActionPlanTriggerHelper.handleActionPlanSharing(newMap, false);
        ActionPlanTriggerHelper.handleActionPlanRollupForEvaluation(newMap.values(), null);

        /*AFTER INSERT METHODS END*/
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
       /* try{
            
        }catch(Exception e){
            throw new AuraHandledException('Error Exception happend'+e.getMessage());
        }*/
        Map<Id, Action_Plan__c> oldMap = (Map<Id, Action_Plan__c>) oldMapGeneric;
        Map<Id, Action_Plan__c> newMap = (Map<Id, Action_Plan__c>) newMapGeneric;
        if(!run) {
            /* DPM-4754 */
            ActionPlanTriggerHelper.handleActionPlanRollupForEvaluationApprovalStatus(newMap.values(), oldMap);
            return;
        }
        /*AFTER UPDATE METHODS START*/
        //ActionPlanTriggerHelper.processRefreshKPICalculationsForActionsPlans(newMap, oldMap);
        if(!isInserting) {
            ActionPlanTriggerHelper.handleActionPlanSharing(newMap, true);
        }

        /* DPM-4548 in if(!isInserting) */
        ActionPlanTriggerHelper.handleActionPlanRollupForEvaluation(newMap.values(), oldMap);
        ActionPlanTriggerHelper.carryOverAPSurveyUpdate(newMap.values(), oldMap);
        ActionPlanTriggerHelper.removeManualShareAP(newMap.values(), oldMap);
        // DPM-4548
        run = false; 
        /*AFTER UPDATE METHODS END*/
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Action_Plan__c> oldMap = (Map<Id, Action_Plan__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/
        ActionPlanTriggerHelper.handleActionPlanRollupForEvaluation(oldMap.values(), null);
        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, Action_Plan__c> newMap = (Map<Id, Action_Plan__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}