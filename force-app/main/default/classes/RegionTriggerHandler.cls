/**
************************************************************************************************
* @classname         : RegionTriggerHandler
* @description       : DPM-133 // Automate Change of Regional Manager On Region 
* @author            : JongHoon Kim
* History
* Version      Date                Author               Ticket         Modification
* 1.0       2024-09-25           JongHoon Kim           DPM-133       Initial Version
************************************************************************************************
**/
public with sharing class RegionTriggerHandler extends Trigger_Framework.baseHandler {
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){

        Map<Id, Region__c> oldMap = (Map<Id, Region__c>) oldMapGeneric;
        Map<Id, Region__c> newMap = (Map<Id, Region__c>) newMapGeneric;

        
        RegionTriggerHelper.searchUserManagerUpdate(newMap.values(),oldMap);
        
    }
    
    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Region__c> oldMap = (Map<Id, Region__c>) oldMapGeneric;
        Map<Id, Region__c> newMap = (Map<Id, Region__c>) newMapGeneric;
        // Genesis does not use AP, so it is commented out for future use and not deleted.
        //System.enqueueJob(new UpdateAPRMOnRegionChangeQueueable(newMap.values(), oldMap));
    }
}