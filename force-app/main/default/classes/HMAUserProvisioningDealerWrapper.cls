public class HMAUserProvisioningDealerWrapper {

    public HMAUserProvisioning__c userProvision {get; set;}
    public List<HMADealerObjectAccessWrapper> objectAccessTypes {get; set;}

    public HMAUserProvisioningDealerWrapper(HMAUserProvisioning__c userProvision) {
        this.userProvision = userProvision;
        this.objectAccessTypes = new List<HMADealerObjectAccessWrapper>();
    }
}