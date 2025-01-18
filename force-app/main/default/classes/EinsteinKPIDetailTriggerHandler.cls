public class EinsteinKPIDetailTriggerHandler extends Trigger_Framework.baseHandler {

    public override void beforeInsert(List<SObject> newListGeneric){
        List<EinsteinKPIDetail__c> newList = (List<EinsteinKPIDetail__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        EinsteinKPIDetailTriggerHelper.handleBeforeInsertUpdate(newList);
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, EinsteinKPIDetail__c> oldMap = (Map<Id, EinsteinKPIDetail__c>) oldMapGeneric;
        Map<Id, EinsteinKPIDetail__c> newMap = (Map<Id, EinsteinKPIDetail__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        EinsteinKPIDetailTriggerHelper.handleBeforeInsertUpdate(newMap.values());
        EinsteinKPIDetailTriggerHelper.handleBeforeUpdateCheckCreateActionPlans(newMap.values(), oldMap);
        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, EinsteinKPIDetail__c> oldMap = (Map<Id, EinsteinKPIDetail__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/

        /*BEFORE DELETE METHODS END*/
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        Map<Id, EinsteinKPIDetail__c> newMap = (Map<Id, EinsteinKPIDetail__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        List<EinsteinKPIDetail__c> details = Trigger_DiffRecord.getRecordsWithFieldValue(newMap.values(), 'EinsteinKPIName__c', 'Get Reporting Period');

        if(!details.isEmpty()) {
            EinsteinKPIDetailTriggerHelper.handleUpldatingReportingPeriod(details);
        }
        /*AFTER INSERT METHODS END*/
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, EinsteinKPIDetail__c> oldMap = (Map<Id, EinsteinKPIDetail__c>) oldMapGeneric;
        Map<Id, EinsteinKPIDetail__c> newMap = (Map<Id, EinsteinKPIDetail__c>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/
        EinsteinKPIDetailTriggerHelper.handleAfterUpdateCreateActionPlans();
        System.debug(LoggingLevel.ERROR, 'newMap ' + newMap);
        List<EinsteinKPIDetail__c> details = Trigger_DiffRecord.getRecordsWithFieldValue(newMap.values(), 'EinsteinKPIName__c', 'Get Reporting Period');
        System.debug(LoggingLevel.ERROR, 'details ' + details);
        if(!details.isEmpty()) {    
            EinsteinKPIDetailTriggerHelper.handleUpldatingReportingPeriod(details);
        }
        //setAcctSharing(usrList);KillSwitchEnabled

        /*AFTER UPDATE METHODS END*/
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, EinsteinKPIDetail__c> oldMap = (Map<Id, EinsteinKPIDetail__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/

        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, EinsteinKPIDetail__c> newMap = (Map<Id, EinsteinKPIDetail__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}