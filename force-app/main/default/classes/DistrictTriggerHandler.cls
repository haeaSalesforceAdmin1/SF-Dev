public class DistrictTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = true; 
    public static Boolean isInserting = false;

    public override void beforeInsert(List<SObject> newListGeneric){
        List<District__c> newList = (List<District__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        if(!run) {
            return;
        }
        isInserting = true;
        
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){

        Map<Id, District__c> oldMap = (Map<Id, District__c>) oldMapGeneric;
        Map<Id, District__c> newMap = (Map<Id, District__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        
        if(!run) {
            return;
        }

        DistrictTriggerHelper.updateAltDistricts(newMap.values(),oldMap);

        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){

        Map<Id, District__c> oldMap = (Map<Id, District__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/
        if(!run) {
            return;
        }
        /*BEFORE DELETE METHODS END*/
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, District__c> newMap = (Map<Id, District__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        DistrictTriggerHelper.secondaryDistrictApproverAccess(newMap.values(),null);
        DistrictTriggerHelper.updateAftersalesMarketmanager(newMap.values(),null);

        /*AFTER INSERT METHODS END*/
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){


        System.debug(LoggingLevel.ERROR, '');
        System.debug(LoggingLevel.ERROR, '');
        System.debug(LoggingLevel.ERROR, '==================DistrictTriggerHandler after update======================');
        System.debug(LoggingLevel.ERROR, 'run:' + run);
        
        System.debug(LoggingLevel.ERROR, oldMapGeneric);
        System.debug(LoggingLevel.ERROR, newMapGeneric);
        
        if(!run) {
            return;
        }
        Map<Id, District__c> oldMap = (Map<Id, District__c>) oldMapGeneric;
        Map<Id, District__c> newMap = (Map<Id, District__c>) newMapGeneric;

        System.debug(LoggingLevel.ERROR, oldMap);
        System.debug(LoggingLevel.ERROR, newMap);
        /*AFTER UPDATE METHODS START*/
        
        DistrictTriggerHelper.secondaryDistrictApproverAccess(newMap.values(),oldMap);
        DistrictTriggerHelper.removeSecondaryDistrictApproverAccess(newMap.values(),oldMap);
        DistrictTriggerHelper.updateRelatedEvalAPAccount(newMap.values(),oldMap);
        DistrictTriggerHelper.updateAftersalesMarketmanager(newMap.values(),oldMap);
        

        /*AFTER UPDATE METHODS END*/
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, District__c> oldMap = (Map<Id, District__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/

        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){

        Map<Id, District__c> newMap = (Map<Id, District__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}