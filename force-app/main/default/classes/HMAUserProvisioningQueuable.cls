/**
* @date 09/28/2020
* @description 
*/
public with sharing class HMAUserProvisioningQueuable implements Queueable {

    private List<HMAUserProvisioning__c> listOfHMAUserProvisionings;
    public Boolean processProfileRoles;
    public Boolean processDealers;

    /**
    * @description 
    */
    public HMAUserProvisioningQueuable(List<HMAUserProvisioning__c> listOfHMAUserProvisionings, Boolean processProfileRoles) {
        this.listOfHMAUserProvisionings = listOfHMAUserProvisionings;
        this.processProfileRoles = processProfileRoles;
    }

    /**
    * @description 
    */
    public void execute(QueueableContext context) {
        try {
            HMAUserProvisioningService.provisionUsers(listOfHMAUserProvisionings, processProfileRoles);
        }
        catch(Exception e) {
            List<HMAUserProvisioning__c> errorProvisions = new List<HMAUserProvisioning__c>();
            for(HMAUserProvisioning__c provisioning:listOfHMAUserProvisionings) {
                HMAUserProvisioning__c errorProvision = new HMAUserProvisioning__c(Id = provisioning.Id);
                errorProvision.Status__c = 'Error';
                errorProvision.ErrorDescription__c = 'Error on Line Number: ' + e.getLineNumber() + '\n' + e.getMessage();
                errorProvisions.add(errorProvision);
            }
            
            HMAUserProvisioningQueuableComplete completeQueueableFailures = new HMAUserProvisioningQueuableComplete(errorProvisions, true);
            if(!Test.isRunningTest()) {
                System.enqueueJob(completeQueueableFailures);
            }
        }
    }
}