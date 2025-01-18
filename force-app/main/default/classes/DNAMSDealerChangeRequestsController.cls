/**
 * Created by Bhavana on 2023-09-12.
 */
public without sharing class DNAMSDealerChangeRequestsController {
    
    public static boolean allowForTest = false;
    
    //Get the Dealer Request recordTypeId 
    @AuraEnabled(cacheable=true)
    public static String getRecordTypeId(String nameStr) {
        return [SELECT Id, Name FROM RecordType WHERE Name =: nameStr].Id;
    }

    //Get the Dealer Request status field picklist values
    @AuraEnabled(cacheable=false)
    public static Map<String,String> getPicklistValues(String objectName,String fieldName) {
        Map<String,String> picklistValuesMap= new Map<String,String>();
        // Get the picklist values and labels
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        // Add picklist labels to the list
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValuesMap.put(entry.getValue(),entry.getLabel());
        }
        return picklistValuesMap;
    }

//Retrieves the Dealer Change Requests to be displayed in the LWC
    @AuraEnabled(cacheable=false)
    public static String getDealerChangeRequestsForRelatedList(String recordId) {
        Boolean isDNAMSUser=false;
        String currentUserContactId = [Select Id,ContactId From User Where Id =:UserInfo.getUserId()].ContactId;
        //String currentUserContactId = '0033I00000Rtal4QAB';
        List<PackageRequest__c> dealerChangeRequests= [
            SELECT Id,
                Name, 
                RequestType__c, 
                Status__c
            FROM 
                PackageRequest__c 
            WHERE Dealer__c =: recordId 
            AND Status__c != 'Cancelled'
            ORDER BY Name 
            DESC
        ];
        System.debug('BR====dealerChangeRequests='+dealerChangeRequests);
        System.debug('BR====ACR='+[SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE AccountId =: recordId AND DNAMSAccountUser__c = true]);
        for(AccountContactRelation acrRecord: [
            SELECT Id,
                AccountId,
                ContactId 
            FROM AccountContactRelation 
            WHERE AccountId =: recordId 
            AND DNAMSAccountUser__c = true
        ]){
            System.debug('BR====acrRecord='+acrRecord);
            //if(contactsMap.containsKey(acrRecord.ContactId) && currentUserContactId == acrRecord.ContactId){
            if(currentUserContactId == acrRecord.ContactId || allowForTest){
                isDNAMSUser = true;
                System.debug('BR====Set isDNAMSUser='+isDNAMSUser);
            }
        }
        return (isDNAMSUser)?JSON.serialize(dealerChangeRequests) : 'Error';
    }

    //Retrieves the Dealer Change Requests to be displayed in the LWC
    @AuraEnabled(cacheable=false)
    public static String getDealerChangeRequests() {
        Boolean isDNAMSUser=false;
        String currentUserContactId = [Select Id,ContactId From User Where Id =:UserInfo.getUserId()].ContactId;
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

        System.debug('BR==accountIds='+accountIds);
        List<PackageRequest__c> dealerChangeRequests= new List<PackageRequest__c>();
        if(accountIds.size() > 0){
            dealerChangeRequests= [
                SELECT Id,
                    Name,
                    Dealer__c,
                    Dealer__r.Name,
                    RequestType__c, 
                    Status__c
                FROM 
                    PackageRequest__c 
                WHERE Dealer__c IN : accountIds
                AND Status__c != 'Cancelled'
            ];
        }
        System.debug('BR==dealerChangeRequests='+dealerChangeRequests);

        List<DealerChangeRequestsWrapper> requestsWrapper = new List<DealerChangeRequestsWrapper>();
        //Generate wrapper records
        for (PackageRequest__c record : dealerChangeRequests) {
            System.debug('record:: ' + JSON.serializePretty(record));

            DealerChangeRequestsWrapper viewerWrapper = new DealerChangeRequestsWrapper();
            viewerWrapper.Id = record.Id;
            viewerWrapper.DealerId = record.Dealer__c;
            viewerWrapper.Name = record.Name;
            viewerWrapper.DealerName = record.Dealer__r.Name;
            viewerWrapper.Type = record.RequestType__c;
            viewerWrapper.Status = record.Status__c;
            requestsWrapper.add(viewerWrapper);
        }

        return JSON.serialize(requestsWrapper);
    }

    // ---------------- Wrapper Classes ----------------
    public class DealerChangeRequestsWrapper {
        public Id Id;
        public Id DealerId;
        public String Name;
        public String DealerName;
        public String Status;
        public String Type;
    }
}