/**
     * [Class Description] Trigger Handler for COPPInfo object  ​
     * Created by [MinheeKim] on [2024-09-04] for [DPM-5700] COPP Project - added field rules for COPP fields
    */  
    
public class COPPInfoTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = true;

    public override void beforeInsert(List<SObject> newListGeneric){
        List<COPPInfo__c> newList = (List<COPPInfo__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        if(!run){return;}
        COPPInfoTriggerHelper.handleBeforeInsertUpdate(newList, null);
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run){return;}
        Map<Id, COPPInfo__c> oldMap = (Map<Id, COPPInfo__c>) oldMapGeneric;
        Map<Id, COPPInfo__c> newMap = (Map<Id, COPPInfo__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        COPPInfoTriggerHelper.handleBeforeInsertUpdate(newMap.values(), oldMap);
        /*BEFORE UPDATE METHODS END*/
    }



    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        Map<Id, COPPInfo__c> newMap = (Map<Id, COPPInfo__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/

        /*AFTER INSERT METHODS END*/
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, COPPInfo__c> oldMap = (Map<Id, COPPInfo__c>) oldMapGeneric;
        Map<Id, COPPInfo__c> newMap = (Map<Id, COPPInfo__c>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/
        /*AFTER UPDATE METHODS END*/
    }

}