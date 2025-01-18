/**
* @date 09/28/2020
* @description 
*/
public without sharing class CreateHMAUserProvisioningsQueable implements Queueable {

     private static final String CLASSNAME = 'CreateHMAUserProvisioningsQueable';
    
    private List<HMAUserProvisioning__c> userProvisions; 

    public CreateHMAUserProvisioningsQueable(List<HMAUserProvisioning__c> userProvisions) {
        this.userProvisions = userProvisions;
    }

    public void execute(QueueableContext context) {

        try {
            HMAObjectService.insertRecordsAndLogErrors(userProvisions, null, CLASSNAME);
        }
        catch(Exception e) {
            if(!HMALoggingUtil.isInitialized) {
                HMALoggingUtil.initialize();
            }
            HMALoggingUtil.addErrorLogListItem(e.getMessage(), CLASSNAME);
        }
    }
}