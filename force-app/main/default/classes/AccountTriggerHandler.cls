public class AccountTriggerHandler extends Trigger_Framework.baseHandler {
    //DPM-4456 start : When account is terminated the run is changed to false by Minhee - 24.04.03
    public static Boolean run = true;
    //DPM-4456 end

    public override void beforeInsert(List<SObject> newListGeneric){
        List<Account> newList = (List<Account>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        AccountTriggerHelper.handleBeforeInsertUpdate(newList, null);
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
        Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        AccountTriggerHelper.handleBeforeInsertUpdate(newMap.values(), oldMap);
        AccountTriggerHelper.updateEvaluationAcionPlan(newMap.values(),oldMap); //DPM-5923 changed the method name from closeEvaluationAcionPlan to updateEvaluationAcionPlan by MinheeKim - 11.20.2024
        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/

        /*BEFORE DELETE METHODS END*/
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
        /*AFTER INSERT METHODS START*/

        /*AFTER INSERT METHODS END*/
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
        Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/
        AccountTriggerHelper.handleAfterUpdate(newMap.values(),oldMap);
        /*AFTER UPDATE METHODS END*/
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/

        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}