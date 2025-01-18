public with sharing class EinsteinKPIMappingTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = true;

    public override void beforeInsert(List<SObject> newListGeneric){

        if(!run) {
            return;
        }

        List<EinsteinKPIMapping__c> newList = (List<EinsteinKPIMapping__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        EinsteinKPIMappingTriggerHelper.handlePopulateName(newList);
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }

        Map<Id, EinsteinKPIMapping__c> oldMap = (Map<Id, EinsteinKPIMapping__c>) oldMapGeneric;
        Map<Id, EinsteinKPIMapping__c> newMap = (Map<Id, EinsteinKPIMapping__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        EinsteinKPIMappingTriggerHelper.handlePopulateName(newMap.values());
        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, EinsteinKPIMapping__c> oldMap = (Map<Id, EinsteinKPIMapping__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/

        /*BEFORE DELETE METHODS END*/
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, EinsteinKPIMapping__c> newMap = (Map<Id, EinsteinKPIMapping__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/

        /*AFTER INSERT METHODS END*/
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, EinsteinKPIMapping__c> oldMap = (Map<Id, EinsteinKPIMapping__c>) oldMapGeneric;
        Map<Id, EinsteinKPIMapping__c> newMap = (Map<Id, EinsteinKPIMapping__c>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/

        /*AFTER UPDATE METHODS END*/
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, EinsteinKPIMapping__c> oldMap = (Map<Id, EinsteinKPIMapping__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/

        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, EinsteinKPIMapping__c> newMap = (Map<Id, EinsteinKPIMapping__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}