public without sharing class CommunityDashboardController {


    @AuraEnabled
    public static Account getAccountDetails(String accountId){

        Account account = [select Id, Name, RecordTypeId,RecordType.Name, DealerCode__c, IsTerminated__c from Account where Id = :accountId];

        return account;
    }
    
    @AuraEnabled
    public static User getAccountId(String userId){
		Id accId = NULL;
        
        User usr = [SELECT Id, Contact.AccountId, Contact.Account.IsTerminated__c 
                    FROM User 
                    WHERE Id = :userId 
                    AND ContactId != NULL 
                    LIMIT 1];
        
        if (usr != NULL) {
            accId = usr.Contact.AccountId;
        }

        return usr;
    }

    @AuraEnabled
    public static String getDashboardIdByType(String dashboardType) {

        String currentEnvironment = HMAUtility.getCurrentEnvironment();
        String fieldName = currentEnvironment + dashboardType + 'Id__c';
        DPMConfigurationSettings__c setting = DPMConfigurationSettings__c.getInstance();
        
        return (String)setting.get(fieldName);
    }
}