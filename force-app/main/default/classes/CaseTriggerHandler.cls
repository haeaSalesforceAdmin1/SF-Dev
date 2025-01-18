public without sharing class CaseTriggerHandler extends Trigger_Framework.baseHandler {

    public override void beforeInsert(List<SObject> newListGeneric){
        List<Case> newList = (List<Case>) newListGeneric;
        /*BEFORE INSERT METHODS START*/

        // 20230807 added by Bitna Seong -start-
        CaseDuplicateHelper.checkCaseDupl(newList);
        CaseSodasAlertHelper.caseForSodasAlertInsert(newList);
        // 20230807 added by Bitna Seong -end-
        
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Case> oldMap = (Map<Id, Case>) oldMapGeneric;
        Map<Id, Case> newMap = (Map<Id, Case>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/

        //20230822 added by Bitna Seong -start-
        CaseSodasAlertHelper.caseForSodasAlertUpdate(oldMap, newMap);
        //20230822 added by Bitna Seong -end-
        
        //2024-07-17
        CaseTriggerHelper.convertToUTC(newMap);
        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Case> oldMap = (Map<Id, Case>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/

        /*BEFORE DELETE METHODS END*/
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        Map<Id, Case> newMap = (Map<Id, Case>) newMapGeneric;
        
        // Field History Tracking init
        FieldHistoryUtil.initReferences(newMap.values());

        FieldHistoryUtil.setContext(
                FieldHistoryUtil.CONTEXT_TRIGGER,
                Case.getSObjectType().getDescribe().getName(),
                CaseTriggerHandler.class.getName()
        );
        
        /*AFTER INSERT METHODS START*/
        CaseTriggerHelper.handleAfterInsertUpdate(newMap);
        CaseTriggerHelper.caseInsertIncrementUserCases(newMap);
        CaseTriggerHelper.handleSafetyCaseNumberInsert(newMap);
        CaseTriggerHelper.createCaseVehicles(newMap.keySet());

        // 20230807 added by Bitna Seong -start-
        CaseForCaseVehicleTriggerHelper.caseForCaseVehicle(newMap);
        // 20230807 added by Bitna Seong -end-
        /*AFTER INSERT METHODS END*/
    
        // Field History Tracking save logs
        FieldHistoryUtil.takeSnapshots(newMap.keySet());
        FieldHistoryUtil.resetContext(FieldHistoryUtil.CONTEXT_TRIGGER);
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Case> oldMap = (Map<Id, Case>) oldMapGeneric;
        Map<Id, Case> newMap = (Map<Id, Case>) newMapGeneric;
        
        // Field History Tracking init
        FieldHistoryUtil.initReferences(oldMapGeneric.values());
        FieldHistoryUtil.trackUserChanges(newMapGeneric.values());

        FieldHistoryUtil.setContext(
                FieldHistoryUtil.CONTEXT_TRIGGER,
                Case.getSObjectType().getDescribe().getName(),
                CaseTriggerHandler.class.getName()
        );
        
        /*AFTER UPDATE METHODS START*/
        CaseTriggerHelper.UpdateSearchVin(newMap, oldMap);
        CaseTriggerHelper.handleAfterInsertUpdate(newMap);
        CaseTriggerHelper.caseUpdateTotalUserCases(newMap, oldMap);
        CaseTriggerHelper.handleSafetyCaseNumberUpdate(newMap, oldMap);
        /*AFTER UPDATE METHODS END*/
        
        // Field History Tracking save logs
        FieldHistoryUtil.takeSnapshots(newMapGeneric.keySet());
        FieldHistoryUtil.commitLogs();
        FieldHistoryUtil.resetContext(FieldHistoryUtil.CONTEXT_TRIGGER);
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Case> oldMap = (Map<Id, Case>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/
        CaseTriggerHelper.caseDeleteDecrementUserCases(oldMap);
        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, Case> newMap = (Map<Id, Case>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}