/**
* @description 
*/
public with sharing class HMAUserProvisioningTriggerHelper {

    public static final String CLASSNAME = 'HMAUserProvisioningTriggerHelper';

    /**
    * @description 
    */    
    public static void handleBeforeInsertUserProvision(List<HMAUserProvisioning__c> userProvisions) {

        List<Id> userIds = new List<Id>();
        for(HMAUserProvisioning__c userProvision:userProvisions) {
            userIds.add(userProvision.User__c);
        }

        Set<Id> userIdsWithProcessingProvisioning = getUserIdsWithProcessingProvisioning(userIds);

        if(userIdsWithProcessingProvisioning.isEmpty()) {
            userProvisions[0].Status__c = 'Processing';
            //update
            /*for(HMAUserProvisioning__c userProvision:userProvisions) {
                //if(!userIdsWithProcessingProvisioning.contains(userProvision.User__c)) {
                userProvision.Status__c = 'Processing';
                //userIdsWithProcessingProvisioning.add(userProvision.User__c);
                //}
            }*/
        }
    }

    /**
    * @description 
    */    
    public static void handleProcessingUserProvisioning(List<HMAUserProvisioning__c> userProvisions) {

        System.debug(LoggingLevel.ERROR, CLASSNAME + ' ' + userProvisions);
        HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisions, false);
        System.enqueueJob(userProvisioningQueueable);
    }

    /**
    * @description 
    */
    public static void handleAfterUpdateForCompletedUserProvisioning(List<HMAUserProvisioning__c> userProvisions) {

        Map<Id, DateTime> userProvisionLastProvisionedDateTimeMap = new Map<Id, DateTime>();

        for(HMAUserProvisioning__c userProvision:userProvisions) {
            userProvisionLastProvisionedDateTimeMap.put(userProvision.User__c, userProvision.CreatedDate);
        }

        Set<Id> userIdsMarkedAsProcessing = new Set<Id>();
        List<HMAUserProvisioning__c> pendingUserProvisions = [select Id, Name, User__c, CreatedDate from HMAUserProvisioning__c where Status__c = 'Pending' order by CreatedDate limit 1];
        for(HMAUserProvisioning__c pendingUserProvision:pendingUserProvisions) {
            //if(!userIdsMarkedAsProcessing.contains(pendingUserProvision.User__c) && userProvisionLastProvisionedDateTimeMap.get(pendingUserProvision.User__c) < pendingUserProvision.CreatedDate) {
                pendingUserProvision.Status__c = 'Processing';
                //userIdsMarkedAsProcessing.add(pendingUserProvision.User__c);
            /*}
            else {
                pendingUserProvision.Status__c = 'Skipped';
            }*/
        }

        if(!pendingUserProvisions.isEmpty()) {
            HMAObjectService.updateRecordsAndLogErrors(pendingUserProvisions, null, CLASSNAME);
        }        
    } 

    /**
    * @description 
    */
    private static Set<Id> getUserIdsWithProcessingProvisioning(List<Id> userIds) {

        Set<Id> userIdsWithProcessingProvisioning = new Set<Id>();

        for(HMAUserProvisioning__c provisioning:[select Id, User__c from HMAUserProvisioning__c where Status__c = 'Processing']) {
            userIdsWithProcessingProvisioning.add(provisioning.User__c);
        }
        return userIdsWithProcessingProvisioning;
    }
}