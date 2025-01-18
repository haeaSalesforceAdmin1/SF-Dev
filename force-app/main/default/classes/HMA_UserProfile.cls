/**
************************************************************************************************
* @classname         : HMA_UserProfile; being used in lwc hmaUserProfile
* @description       : Get the user details
* @author            : Minhee Kim
* History
* Version      Date                Author               Ticket         Modification
* 1.0       2024-06-24            Minhee Kim           DPM-4035       Initial Version
************************************************************************************************
**/
public  with sharing class HMA_UserProfile {

    @AuraEnabled
    public static Map<String, String> getDPMSiteURL(){
        try {
            String userId = UserInfo.getUserId();
            String networkId = Network.getNetworkId();
            String baseURL= URL.getSalesforceBaseUrl().toExternalForm();
            // URL 변수 세팅
            String logoutUrl = '';
            String homeURL = '';
            String myProfileURL = '';
            String myAccountUrl ='';
            String communityName= HMAUtility.getCommunityName(networkId);
            String contactId = [SELECT ContactId  FROM USER WHERE Id =: userId]?.ContactId;
            String contactAcc = '';
            Map<String, String> resultMap = new Map<String, String>();
            
            if(contactId != '') {
                contactAcc = [SELECT AccountId FROM contact WHERE id =: contactId]?.AccountId;
            }
            if(communityName==HMAConstants.HMA_COMMUNITY_NAME){
                homeURL= baseURL+'/'+ System.label.HCUV_DPM_Hyundai;
            } else {   // else if(communityName==HMAConstants.GMA_COMMUNITY_NAME){
                homeURL= baseURL+'/'+ System.label.HCUV_DPM_Genesis;
            } 

            myProfileURL = homeURL + '/s/' + 'profile' + '/' + userId; 
            logoutUrl = homeURL + '/secur/logout.jsp';
            myAccountUrl = homeURL  + '/s/' + 'account' + '/' + contactAcc;

            resultMap.put('homeURL', homeURL);
            resultMap.put('myProfileURL', myProfileURL);
            resultMap.put('myAccountUrl', myAccountUrl);
            resultMap.put('logoutURL', logoutUrl);

            return resultMap;

        }catch(Exception ex){
            throw new AuraHandledException('Error Exception happend'+ex.getMessage()); 
        }
       
    }


    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getAccountId(){
        String userId = UserInfo.getUserId();
        String contactId = [SELECT ContactId  FROM USER WHERE Id =: userId]?.ContactId;
        String contactAcc = '';
        String networkId = Network.getNetworkId();
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String communityName = HMAUtility.getCommunityName(networkId);
        String homeURL = '';
        List<Map<String, String>> result = new List<Map<String, String>>();

        
        Map<String, String> resultMap = new Map<String, String>();
            
        if(contactId != '') {
            contactAcc = [SELECT AccountId FROM contact WHERE id =: contactId]?.AccountId;
        }

        try{
            if(communityName==HMAConstants.HMA_COMMUNITY_NAME){
                homeURL= baseURL+'/'+ System.label.HCUV_DPM_Hyundai;
            }
            else if(communityName==HMAConstants.GMA_COMMUNITY_NAME){
                homeURL= baseURL+'/'+ System.label.HCUV_DPM_Genesis;
            }

            List<AccountShare> accountShares = [SELECT AccountId, Account.Name FROM AccountShare WHERE UserOrGroupId = :userId AND AccountId!=:contactAcc];
            AccountShare primaryAccountShares = [SELECT AccountId, Account.Name FROM AccountShare WHERE UserOrGroupId = :userId AND AccountId = :contactAcc LIMIT 1];
            Map<String, String> accountMap = new Map<String, String>();
            accountMap.put('accountURL', homeURL + '/s/' + 'account' + '/' + primaryAccountShares.AccountId);
            accountMap.put('accountName', primaryAccountShares.Account.Name);
            result.add(accountMap);
            
            if(accountShares.size()>0){
                for(AccountShare share : accountShares) {
                    Map<String, String> accMap = new Map<String, String>();
                    accMap.put('accountURL', homeURL + '/s/' + 'account' + '/' + share.AccountId);
                    accMap.put('accountName', share.Account.Name);
                    result.add(accMap);
                }
            }
        }catch(Exception ex){
            throw new AuraHandledException('Error Exception happend'+ex.getMessage()); 
        }
        return result;
    }

    @AuraEnabled 
        public static user fetchUserDetail(){
              return [Select id,Name,SmallPhotoUrl, FullPhotoUrl
                      From User
                      Where Id =: Userinfo.getUserId()];
    }
      
}