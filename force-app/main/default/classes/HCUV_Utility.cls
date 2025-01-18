/**
************************************************************************************************
* @classname         : HCUV_Utility; being used common code
* @description       : Get the user details
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       17th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
public without sharing class HCUV_Utility {
    static Integer defaultTTL = HCUV_Constants.DEFAULT_TTL;
    static String constPartitionkey = HCUV_Constants.CONST_PARTITIONKEY;
    
    /**
    * @description - Fetch Icon Details
    * @param - networkId
    * @return List<String>
    */
    @AuraEnabled(cacheable=true)
    public static List<String> getIconDetails(String networkId) {
        //get community name
        String communityName = getCommunityName(networkId);
        
        Map<String, String> iconDetails = new Map<String, String>();
        Map<String, String> menuProgram = new Map<String, String>();
        Map<String, String> menuURL = new Map<String, String>();
        for (HCUV_CommunityIcon__mdt s : [Select Label, Icon__c, Program_Type__c, URL_Key__c 
                                          From HCUV_CommunityIcon__mdt
                                          WHERE Site_Name__c = :communityName] ) {
            iconDetails.put(s.Label, s.Icon__c);
            menuProgram.put(s.Label, s.Program_Type__c);
            menuURL.put(s.Label, s.URL_Key__c);
        }
        String defaultPrg = (communityName.contains(HCUV_Constants.HMA_COMMUNITY_NAME) ? System.label.HCUV_Default_Program : System.label.GMA_Default_Program);
        List<String> resList = new List<String>{JSON.serialize(iconDetails), JSON.serialize(menuProgram), JSON.serialize(menuURL), defaultPrg};
            return resList;
    }
    
    /**
    * @description - Fetch account id
    * @return String
    */
    @AuraEnabled(cacheable=false)
    public static String getAccountId(){
        String userId = UserInfo.getUserId();
        String result = '';
        try{
            if(UserInfo.getSessionId() != null){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition(constPartitionkey);
                String accountId = '';
                if(sessionPart.contains(userId)){
                    accountId = (String)sessionPart.get(userId);
                }            
                if (String.isBlank(accountId)){
                    accountId = getUserAccountId();
                    if(String.isNotEmpty(accountId)){
                        sessionPart.put(userId, accountId, defaultTTL);
                    }
                }
                result = accountId;
            }
        }
        Catch(Exception ex){
            result = ex.getMessage();
        }
        return result;
    }
    
    /**
    * @description - calling from getAccountId to get current user account id
    * @return String
    */
    private static String getUserAccountId(){
        String result = '';
        try{
            Id contactId = [Select ContactId, Id from User where Id=:UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1].contactId;
            String communityName= getCommunityName(Network.getNetworkId());
            
            List<String> recordTypeList= new List<String>();
            List<HCUV_RecordType_Configuration__mdt> hcuvRecMdt = [Select Id, RecordType_Name__c From HCUV_RecordType_Configuration__mdt Where Object_API_Name__c='Account' AND Site_Name__c=:communityName];
            for(HCUV_RecordType_Configuration__mdt mdtRec: hcuvRecMdt){
                recordTypeList.add(mdtRec.RecordType_Name__c);
            }
            List<AccountContactRelation> acrRec = [Select Id, AccountId From AccountContactRelation where ContactId=:contactId And Account.RecordType.DeveloperName IN:recordTypeList And Account.Active__c = true WITH SECURITY_ENFORCED order by IsDirect DESC LIMIT 1];
            if(!acrRec.isEmpty()){
                result = acrRec[0].AccountId;
            }
        }
        Catch(Exception ex){
            result = ex.getMessage();
        }
        return result;
    }
    
    /**
    * @description - Set account id
    * @param - accountId
    * @return Boolean
    */
    @AuraEnabled(cacheable=false)
    public static Boolean setUserAccountId (Id accountId){
        Boolean isSuccess = false;
        Boolean isValidAccount = false;
        if(String.isNotEmpty(accountId)){
            //Check whether account is associated with the current user
            for(AccountContactRelation objAct: getAccountList()){
                if(objAct.Account.Id == accountId){
                    isValidAccount = true;
                    break;
                }
            }
            if(isValidAccount){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition(constPartitionkey);
                String userId = UserInfo.getUserId();
                sessionPart.put(userId, accountId, defaultTTL);
                isSuccess = true;
            }
        }
        return isSuccess;
    }
    
    /**
    * @description - Fetch all the accounts from current user
    * @return AccountContactRelation
    */
    @AuraEnabled(cacheable=true)
    public static List<AccountContactRelation> getAccountList(){
        List<AccountContactRelation> returnAct = new List<AccountContactRelation>();
        String userId = UserInfo.getUserId();
        ID contactId = [Select ContactId from User where id = :userId WITH SECURITY_ENFORCED].ContactId;
        List<String> recordTypeList = getRecordTypeList('Account', Network.getNetworkId(), '');
        returnAct = [select Account.Id,Account.Name,Account.DealerCode__c from AccountContactRelation where ContactId =:contactId and Account.Active__c = true 
                     And Account.RecordType.DeveloperName IN:recordTypeList WITH SECURITY_ENFORCED];
        return returnAct;    
    }
    
    
    /**
    * @description - Fetch the community name based on argument networkId
    * @param - networkId
    * @return String
    */
    public static String getCommunityName(String networkId){
        String communityName = '';
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Id = :networkId];
        if(!netObjList.isEmpty()){
            communityName = netObjList[0].Name;
        }
        
        if(String.isBlank(communityName) && Test.isRunningTest()){
            return HCUV_Constants.HMA_COMMUNITY_NAME;
        } 
        return communityName;
    }
    
    /**
    * @description - Fetch the recordtype name from custom metadatae
    * @param - obj, networkId
    * @return String
    */
    public static List<String> getRecordTypeList(String obj, String networkId, String typeVal){
        String communityName= getCommunityName(networkId);
        List<String> recordTypeList= new List<String>();
        if(String.isBlank(typeVal)){
            for(HCUV_RecordType_Configuration__mdt mdtRec: [Select Id, RecordType_Name__c From HCUV_RecordType_Configuration__mdt Where Object_API_Name__c=:obj AND Site_Name__c=:communityName]){
                recordTypeList.add(mdtRec.RecordType_Name__c);
            }  
        }
        else{
            for(HCUV_RecordType_Configuration__mdt mdtRec: [Select Id, RecordType_Name__c From HCUV_RecordType_Configuration__mdt Where Object_API_Name__c=:obj AND Site_Name__c=:communityName AND Type__c=:typeVal]){
                recordTypeList.add(mdtRec.RecordType_Name__c);
            }
        }
       return recordTypeList;    
    }
    
    /**
    * @description - Fetch Dealer Accounts using Dealer Codes
    * @param - Set<String>
    * @return Map<String, Id>
    */
    public static Map<String, Id> getDealerAccountsUsingDealerCodes(Set<String> dealerCodes)
    {
        Map<String, Id> dealerCodeAccIdMap = new Map<String, String> ();

        for(Account accObj : [Select Id, DealerCode__c from Account Where DealerCode__c IN :dealerCodes]) {
            dealerCodeAccIdMap.put(accObj.DealerCode__c, accObj.Id);
        }

        return dealerCodeAccIdMap;
    }
	 /**
    * @description - Fetch Dealer Codes using Account
    * @param - 
    * @return String
    */
    @Auraenabled(cacheable=false)
    public static String getDealerCode(){
        String dealerCode='';
        String accId= getAccountId();
        List<Account> accList= [Select Id, DealerCode__c from Account where Id=:accId limit 1];
        if(!accList.isEmpty()){
            dealerCode= accList[0].DealerCode__c;
        }
        return dealerCode;
    }
}