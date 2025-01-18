public with sharing class HyundaiCommunitiesLandingController {
    public HyundaiCommunitiesLandingController() {

    }

    public PageReference forwardToStartPage() {

        DPMConfigurationSettings__c customSetting = DPMConfigurationSettings__c.getOrgDefaults();
       //DNAMS code changes related to the Temp Dealer user logout and redirect back to the direct url page
        user usr=[SELECT Id, Name, FederationIdentifier FROM User WHERE Id=:UserInfo.getUserId()];
        //if user federation identifier is empty then redirect the user to direct url of community portal 
        if(usr.FederationIdentifier==null)
            return new Pagereference(customSetting.Temp_Hyundai_Redirect__c);
        else
            return new Pagereference(customSetting.Hyundai_Redirect__c);
        
    }
}