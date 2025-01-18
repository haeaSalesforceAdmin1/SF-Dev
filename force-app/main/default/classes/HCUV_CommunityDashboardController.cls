/**
************************************************************************************************
* @classname         : HCUV_CommunityDashboardController; being used in aura hcuvCommunityDashboardCmp 
* @description       : Get the user accountId and Dashboard Id from Custom metadata
* @author            : Smriti Gupta
* Test Class		 : HCUV_CommunityDashboardController_Test
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       24th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
public class HCUV_CommunityDashboardController {
     
    /**
    * @description - Fetch the logged In user account Id
    * @return String
    */
    @AuraEnabled
    public static String getAccountId(){		
        return HCUV_Utility.getAccountId();
    }
    
    /**
    * @description - Fetch the Dashboard information fr external user
    * @param - programType
    * @return Wrapper
    */
    @AuraEnabled
    public static Wrapper getDashboardInfo(String programType,String dashboardType){
        String dashboardId='';
        String communityType='';
        String fieldName='';
        Wrapper wrp= new Wrapper();
        String communityName= HCUV_Utility.getCommunityName(Network.getNetworkId());
        if(communityName == HCUV_Constants.HMA_COMMUNITY_NAME){
            communityType=HCUV_Constants.HMACommunityType;
        }
        else if(communityName == HCUV_Constants.GMA_COMMUNITY_NAME){
            communityType=HCUV_Constants.GMACommunityType;
        }

        if(String.isBlank(programType) && communityName == HCUV_Constants.HMA_COMMUNITY_NAME){
            programType=HCUV_Constants.HMADefaultInspectionType;
        }else if(String.isBlank(programType) && communityName == HCUV_Constants.GMA_COMMUNITY_NAME){
            programType=HCUV_Constants.GMADefaultInspectionType;
        }

        if(String.isBlank(dashboardType))
        {
            fieldName = communityType +'_'+ programType + HCUV_Constants.ExternalId_Text;
        }
        else{
            fieldName = dashboardType+'_'+communityType +'_'+ programType + HCUV_Constants.ExternalId_Text;        
        }
       	
        
        HCUV_Configuration_Settings__c custRec = HCUV_Configuration_Settings__c.getInstance(HCUV_Constants.Dashboard_Text);
        if(custRec.get(fieldName)!=null){
            dashboardId = (String)custRec.get(fieldName);
        }
        wrp.dashboardId= dashboardId;
        String accId = getAccountId();
        wrp.accId= accId;
        return wrp;
    }
    
    /**
    * @description - Created Wrapper Class
    * @return Wrapper
    */
    public class Wrapper{
        @AuraEnabled Public String accId;
        @AuraEnabled Public String dashboardId;
    }
}