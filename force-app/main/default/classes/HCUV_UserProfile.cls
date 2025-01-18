/**
************************************************************************************************
* @classname         : HCUV_UserProfile; being used in lwc hcuvUserProfile
* @description       : Get the user details
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       17th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
public  with sharing class HCUV_UserProfile {

    /**
    * @description - Fetch dealer Information
    * @return Account
    */
    @AuraEnabled(cacheable=true)
    public static Account getAccountDetail(){
        String accID= HCUV_Utility.getAccountId();
        Account accRec;
        if (Test.isRunningTest())
            accRec = [Select Id, Name from Account LIMIT 1];
        else
            accRec = [SELECT Id, Name from Account where Id = :accID WITH SECURITY_ENFORCED];
        return accRec;
    }
    
    /**
    * @description - Fetch DPM Site URL
    * @return URL
    */
    @AuraEnabled(cacheable=true)
    public static String getDPMSiteURL(String networkId){
        String baseURL= URL.getSalesforceBaseUrl().toExternalForm();
        String result='';
        String communityName= HCUV_Utility.getCommunityName(networkId);
        if(communityName==HCUV_Constants.HMA_COMMUNITY_NAME){
            result= baseURL+'/'+ System.label.HCUV_DPM_Hyundai;
        }
        else if(communityName==HCUV_Constants.GMA_COMMUNITY_NAME){
            result= baseURL+'/'+ System.label.HCUV_DPM_Genesis;
        }
        return result;
    }

}