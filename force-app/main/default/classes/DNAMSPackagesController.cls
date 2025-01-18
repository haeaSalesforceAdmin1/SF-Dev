/**
 * Created by Bhavana on 2023-09-14.
 */
public with sharing class DNAMSPackagesController {
	
    public static boolean allowForTest = false;
    
    //Retrieves the Dealer Change Requests to be displayed in the LWC
    @AuraEnabled(cacheable=true)
    public static String getPackagesForRelated(String recordId) {
        Boolean isDNAMSUser=false;
        String currentUserContactId = [Select Id,ContactId From User Where Id =:UserInfo.getUserId()].ContactId;
        //String currentUserContactId = '0033I00000Rtal4QAB';
        List<Package__c> records= [
            SELECT Id,
                Name, 
                Type__c, 
                Status_2__c
            FROM 
                Package__c 
            WHERE Dealer__c =: recordId 
            AND Status_2__c IN ('Initiated','Returned','Under Review') 
            AND ScanPkg__c = FALSE
            ORDER BY Name 
            DESC
        ];
        for(AccountContactRelation acrRecord: [
            SELECT Id,
                AccountId,
                ContactId 
            FROM AccountContactRelation 
            WHERE AccountId =: recordId 
            AND DNAMSAccountUser__c = true
        ]){
            if(currentUserContactId == acrRecord.ContactId || allowForTest){
                isDNAMSUser = true;
            }
        }
        return (isDNAMSUser)?JSON.serialize(records) : 'Error';
    }

    //Retrieves the Dealer Change Requests to be displayed in the LWC
    @AuraEnabled(cacheable=false)
    public static String getPackages() {
        Boolean isDNAMSUser=false;
        String currentUserContactId = [Select Id,ContactId From User Where Id =:UserInfo.getUserId()].ContactId;
        //String currentUserContactId = '0033I00000Rtal4QAB';
        if(allowForTest){
        	currentUserContactId = System.Label.DNAMSContactId;//Contact Id
        }
        Set<Id> accountIds = new Set<Id>();
        for(AccountContactRelation acrRecord: [
            SELECT Id,
                AccountId,
                ContactId 
            FROM AccountContactRelation 
            WHERE ContactId =: currentUserContactId
            AND DNAMSAccountUser__c = true
        ]){
            accountIds.add(acrRecord.AccountId);
        }
        List<Package__c> packages= new List<Package__c>();
        if(accountIds.size() > 0){
            packages= [
                SELECT Id,
                    Name,
                    Dealer__c,
                    Dealer__r.Name,
                    Region__c,
                    Region__r.Name,
                    Type__c, 
                    Status_2__c
                FROM 
                    Package__c 
                WHERE Dealer__c IN : accountIds
                AND Status_2__c IN ('Initiated','Returned','Under Review') 
                AND ScanPkg__c = false
            ];
        }
        
        List<PackagesWrapper> packageWrapper = new List<PackagesWrapper>();
        //Generate wrapper records
        for (Package__c record : packages) {
            PackagesWrapper wrapper = new PackagesWrapper();
            wrapper.Id = record.Id;
            wrapper.DealerId = record.Dealer__c;
            wrapper.RegionId = record.Region__c;
            wrapper.Name = record.Name;
            wrapper.DealerName = record.Dealer__r.Name;
            wrapper.RegionName = record.Region__r.Name;
            wrapper.Type = record.Type__c;
            wrapper.Status = record.Status_2__c;
            packageWrapper.add(wrapper);
        }

        return JSON.serialize(packageWrapper);
    }

    // ---------------- Wrapper Classes ----------------
    public class PackagesWrapper {
        public Id Id;
        public Id DealerId;
        public Id RegionId;
        public String Name;
        public String DealerName;
        public String RegionName;
        public String Status;
        public String Type;
    }
}