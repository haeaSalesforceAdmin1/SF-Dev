/**
* @date 09/28/2020
* @description 
*/
public with sharing class HMAUserProvisioningQueuableComplete implements Queueable {

    private List<HMAUserProvisioning__c> listOfHMAUserProvisionings;
    private static final string CLASSNAME = 'HMAUserProvisioningQueuableComplete';
    private boolean isError = false;

    /**
    * @description 
    */
    public HMAUserProvisioningQueuableComplete(List<HMAUserProvisioning__c> listOfHMAUserProvisionings) {
        this.listOfHMAUserProvisionings = listOfHMAUserProvisionings;
    }

    public HMAUserProvisioningQueuableComplete(List<HMAUserProvisioning__c> listOfHMAUserProvisionings, Boolean isError) {
        this.listOfHMAUserProvisionings = listOfHMAUserProvisionings;
        this.isError = isError;
    }

    /**
    * @description 
    */
    public void execute(QueueableContext context) {

        if(!isError) {
            List<HMAUserProvisioning__c> userProvisionsToComplete = new List<HMAUserProvisioning__c>();
            Set<String> userIdsForCompletedUserProvisions = new Set<String>();

            for(HMAUserProvisioning__c userProvisioning:listOfHMAUserProvisionings) {
                userProvisionsToComplete.add(new HMAUserProvisioning__c(Id = userProvisioning.Id, Status__c = 'Completed'));
                userIdsForCompletedUserProvisions.add(userProvisioning.User__c);
            }
            
            if(!userProvisionsToComplete.isEmpty()) {
                HMAObjectService.updateRecordsAndLogErrors(userProvisionsToComplete, null, CLASSNAME);
            }
        }
        else {
            update listOfHMAUserProvisionings;
        }
    }

    public void processSharingBatchesForProvisionedUsers(Set<String> userIdsForCompletedUserProvisions) {
        List<User> users = [select Id, AccountId, AccessTypes__c from User where Id in :userIdsForCompletedUserProvisions];

    }

    /**
    * @description 
    */
    private void handleUnprocessedProvisionsForCompletedUsers(Set<String> userIdsForCompletedUserProvisions) {

        Set<String> userIdsToUpdateProvisionsToProcessing = new Set<String>();
        List<HMAUserProvisioning__c> userProvisionsToUpdateStatus = new List<HMAUserProvisioning__c>();
        List<HMAUserProvisioning__c> pendingUserProvisions = [select Id, User__c, User__r.AccountId, User__r.AccessTypes__c from HMAUserProvisioning__c where User__c in :userIdsForCompletedUserProvisions and Status__c = 'Pending' order by AutoProvisionedTimestamp__c desc];
        Set<String> accountIds = new Set<String>();

        for(HMAUserProvisioning__c pendingUserProvision:pendingUserProvisions) {
            if(!userIdsToUpdateProvisionsToProcessing.contains(pendingUserProvision.User__c)) {
                pendingUserProvision.Status__c = 'Processing';
                userIdsToUpdateProvisionsToProcessing.add(pendingUserProvision.User__c);
            }
            else {
                pendingUserProvision.Status__c = 'Skipped';
            }
            userProvisionsToUpdateStatus.add(pendingUserProvision);

            if(pendingUserProvision.User__r.AccountId != null) {
                accountIds.add(pendingUserProvision.User__r.AccountId);
            }
        }

        if(!userProvisionsToUpdateStatus.isEmpty()) {
            HMAObjectService.updateRecordsAndLogErrors(userProvisionsToUpdateStatus, null, CLASSNAME);
        }

    }
}