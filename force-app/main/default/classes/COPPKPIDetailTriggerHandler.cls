/**
     * [Class Description] Trigger Handler for COPPKPIDetail object  ​
     * Created by [MinheeKim] on [2024-10-01] for [DPM-5700] COPP Project - added to lookup COPP Info
    */  
    
    public class COPPKPIDetailTriggerHandler extends Trigger_Framework.baseHandler {

        public static Boolean run = true;
    
        public override void beforeInsert(List<SObject> newListGeneric){
            List<COPPKPIDetail__c> newList = (List<COPPKPIDetail__c>) newListGeneric;
            /*BEFORE INSERT METHODS START*/
            COPPKPIDetailTriggerHelper.handleBeforeInsertUpdate(newList, null);
            /*BEFORE INSERT METHODS END*/
        }
    
        public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
            Map<Id, COPPKPIDetail__c> oldMap = (Map<Id, COPPKPIDetail__c>) oldMapGeneric;
            Map<Id, COPPKPIDetail__c> newMap = (Map<Id, COPPKPIDetail__c>) newMapGeneric;
            /*BEFORE UPDATE METHODS START*/
            COPPKPIDetailTriggerHelper.handleBeforeInsertUpdate(newMap.values(), oldMap);
            /*BEFORE UPDATE METHODS END*/
        }
    
    
    
        public override void afterInsert(Map<Id, SObject> newMapGeneric){
            Map<Id, COPPKPIDetail__c> newMap = (Map<Id, COPPKPIDetail__c>) newMapGeneric;
            /*AFTER INSERT METHODS START*/
    
            /*AFTER INSERT METHODS END*/
        }
    
        public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
            Map<Id, COPPKPIDetail__c> oldMap = (Map<Id, COPPKPIDetail__c>) oldMapGeneric;
            Map<Id, COPPKPIDetail__c> newMap = (Map<Id, COPPKPIDetail__c>) newMapGeneric;
            /*AFTER UPDATE METHODS START*/
            /*AFTER UPDATE METHODS END*/
        }
    
    }