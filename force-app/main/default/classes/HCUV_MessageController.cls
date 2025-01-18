/**
************************************************************************************************
* @classname         : HCUV_MessageController; being used in lwc hcuvMessageCenter 
* @description       : Get the Messages Records
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       23rd Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
* 2.0       11th Nov 2023          Smriti Gupta         HVM-214
************************************************************************************************
**/
public without sharing class HCUV_MessageController {
    /**
    * @description - Fetch messages records based on community and program
    * @param - programName, networkId
    * @return List<HCUV_Dealer_Message__c>
    */
    @AuraEnabled(cacheable=true)
    public static List<HCUV_Dealer_Message__c> getMessages(String programName, String networkId){
        //get community name
        String communityName= HCUV_Utility.getCommunityName(networkId);
        List<String> recordTypeList= HCUV_Utility.getRecordTypeList(HCUV_Constants.DM_Object_API_Name, networkId, '');
        List<HCUV_Dealer_Message__c> messages = new List<HCUV_Dealer_Message__c>();
        List<HCUV_Dealer_Message__c> dealerMessages = new List<HCUV_Dealer_Message__c>();
        String accId = HCUV_Utility.getAccountId();
        
        HCUV_CommunityIcon__mdt hcuvMdt = [Select Label From HCUV_CommunityIcon__mdt Where Program_Type__c=:programName];
        programName=  hcuvMdt.Label;
        
        if(String.isNotBlank(accID)){
            Account acc = [SELECT Id, MarketCodeGenesisPicklist__c, Name, Region__r.Name, region__r.RegionCode__c, SalesDistrict__r.DistrictCode__c,SalesDistrictCode__c FROM Account WHERE Id =: accId];
            String districtMarketCode = '';
            if(communityName==HCUV_Constants.HMA_COMMUNITY_NAME){
                districtMarketCode = acc.SalesDistrict__r.DistrictCode__c;
            }
            else if(communityName==HCUV_Constants.GMA_COMMUNITY_NAME){
                districtMarketCode = acc.MarketCodeGenesisPicklist__c;
            }
            String region = (String.isNotBlank(accId) ? acc.region__r.RegionCode__c : '');
            
            messages = [SELECT Id,Name, Message__c, Priority__c,Start_Date__c,Expiration_Date__c,LastModifiedDate, Message_Subject__c 
                        FROM HCUV_Dealer_Message__c
                        WHERE Message_Type__c !=: HCUV_Constants.Message_QuickTip AND Status__c =: HCUV_Constants.Status_Published AND Program_Name__c=:programName AND Start_Date__c <= TODAY AND Expiration_Date__c >= TODAY 
                        AND Region__c INCLUDES (:region)
                        AND RecordType.DeveloperName IN:recordTypeList
                        ORDER BY LastModifiedDate DESC];
            
            // HVM-214 - Retrieving Dealer Message Ids from Junction objects for Dealer and Market
            Set<Id> messageCntrIds = new Set<Id>();
            for(HCUV_Message_Audience__c mcDlrRec : [Select Id, Message__c from HCUV_Message_Audience__c where Dealer__c = :accID]){
                messageCntrIds.add(mcDlrRec.Message__c);
            }
            for(HCUV_Message_Audience_Market__c mcMarketRec : [Select Id, Dealer_Message__c from HCUV_Message_Audience_Market__c where Market__r.DistrictCode__c = :districtMarketCode]){
                messageCntrIds.add(mcMarketRec.Dealer_Message__c);
            }
            //Getting dealer data from junction object
            // HVM-214 - Fetching data from Dealer Message based on Dealer and Market Junction object
            dealerMessages = [SELECT Id,Name, Message__c, Priority__c,Start_Date__c,Expiration_Date__c,LastModifiedDate, Message_Subject__c
                              FROM HCUV_Dealer_Message__c 
                              WHERE Message_Type__c != :HCUV_Constants.Message_QuickTip AND Status__c = :HCUV_Constants.Status_Published AND Program_Name__c=:programName AND Start_Date__c <= TODAY AND Expiration_Date__c >= TODAY  
                              AND  Id IN : messageCntrIds
                              AND RecordType.DeveloperName IN:recordTypeList
                              ORDER BY LastModifiedDate DESC];
            if(dealerMessages.size()>0){
                messages.addAll(dealerMessages);
            }
            
        }
        else{
            messages = [SELECT Id,Name, Message__c, Priority__c,Start_Date__c,Expiration_Date__c,LastModifiedDate, Message_Subject__c
                        FROM HCUV_Dealer_Message__c
                        WHERE Message_Type__c !=: HCUV_Constants.Message_QuickTip AND Status__c =: HCUV_Constants.Status_Published AND Program_Name__c=:programName AND Start_Date__c <= TODAY AND Expiration_Date__c >= TODAY 
                        AND RecordType.DeveloperName IN:recordTypeList
                        ORDER BY LastModifiedDate DESC];
        }
        return messages;
    }
    
   /**
   * @description - Fetch quick tip records based on community and program
   * @param - programName, networkId
   * @return Map<String, Object> 
   */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getQuickTip(String programName, String networkId){
        List<HCUV_Dealer_Message__c> messages = new List<HCUV_Dealer_Message__c>();
        //get community name
        String communityName= HCUV_Utility.getCommunityName(networkId);
        List<String> recordTypeList= HCUV_Utility.getRecordTypeList(HCUV_Constants.DM_Object_API_Name, networkId, '');
        HCUV_CommunityIcon__mdt hcuvMdt = [Select Label From HCUV_CommunityIcon__mdt Where Program_Type__c=:programName];
        programName=  hcuvMdt.Label;
        String accId = HCUV_Utility.getAccountId();
        if(String.isNotBlank(accID)){
            Account acc = [SELECT Id, MarketCodeGenesisPicklist__c, Name, Region__r.Name, region__r.RegionCode__c, SalesDistrict__r.DistrictCode__c,SalesDistrictCode__c FROM Account WHERE Id =: accId];
            //String district = (String.isNotBlank(accId) ? acc.SalesDistrict__r.DistrictCode__c : '');
            String districtMarketCode = '';
            if(communityName==HCUV_Constants.HMA_COMMUNITY_NAME){
                districtMarketCode = acc.SalesDistrict__r.DistrictCode__c;
            }
            else if(communityName==HCUV_Constants.GMA_COMMUNITY_NAME){
                districtMarketCode = acc.MarketCodeGenesisPicklist__c;
            }
            String region = (String.isNotBlank(accId) ? acc.region__r.RegionCode__c : '');
            //String accountName = (String.isNotBlank(accId) ? acc.Name : '');
            
            // HVM-214 - Retrieving Dealer Message Ids from Junction objects for Dealer and Market
            Set<Id> messageCntrIds = new Set<Id>();
            for(HCUV_Message_Audience__c mcDlrRec : [Select Id, Message__c from HCUV_Message_Audience__c where Dealer__c = :accID]){
                messageCntrIds.add(mcDlrRec.Message__c);
            }
            for(HCUV_Message_Audience_Market__c mcMarketRec : [Select Id, Dealer_Message__c from HCUV_Message_Audience_Market__c where Market__r.DistrictCode__c = :districtMarketCode]){
                messageCntrIds.add(mcMarketRec.Dealer_Message__c);
            }
            
            messages = [SELECT Id,Name, Message__c, Priority__c,Start_Date__c,Expiration_Date__c,LastModifiedDate 
                        FROM HCUV_Dealer_Message__c 
                        WHERE Message_Type__c =: HCUV_Constants.Message_QuickTip 
                        AND Program_Name__c=:programName 
                        AND Start_Date__c <= TODAY AND Expiration_Date__c >= TODAY 
                        AND Status__c = :HCUV_Constants.Status_Published
                        AND ((Region__c INCLUDES (:region))OR(Id IN :messageCntrIds))
                        AND RecordType.DeveloperName IN:recordTypeList
                        ORDER BY LastModifiedDate DESC LIMIT 1];
            
        }else{
            messages = [SELECT Id,Name, Message__c, Priority__c,Start_Date__c,Expiration_Date__c,LastModifiedDate 
                        FROM HCUV_Dealer_Message__c
                        WHERE Message_Type__c =: HCUV_Constants.Message_QuickTip AND Status__c =: HCUV_Constants.Status_Published AND Program_Name__c=:programName AND Start_Date__c <= TODAY AND Expiration_Date__c >= TODAY 
                        ORDER BY LastModifiedDate DESC LIMIT 1];
        }
        return new Map<String, Object> {
            'AccountId'=> accID,
                'MessageObj'=> (!messages.isEmpty() ? messages[0] : null)
                };
}
   /**
   * @description - Fetch the content document info
   * @param - recordId
   * @return Map<String, Object> 
   */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMessagesFilesInfo(String recordId){
        Map<String, Object> dataMap = new Map<String, Object> ();
        List<String> docIds = new List<String> ();
        List<ContentDocumentLink> docLinkList = [Select ContentDocumentId, ContentDocument.Title,ContentDocument.FileExtension FROM ContentDocumentLink Where LinkedEntityId =:recordId ORDER BY ContentDocument.CreatedDate DESC];
        for(ContentDocumentLink docLink :docLinkList){
            docIds.add(docLink.ContentDocumentId);
        }
        dataMap.put('ContentDocumentLink', docLinkList);
        List<ContentDistribution> cdObjList = [select ContentDocumentId, DistributionPublicUrl 
                                               from ContentDistribution where ContentDocumentId IN :docIds WITH SECURITY_ENFORCED];
        Map<String, String> docMap = new Map<String, String> ();
        for(ContentDistribution cdObj : cdObjList) {
            docMap.put(cdObj.ContentDocumentId, cdObj.DistributionPublicUrl);
        }
        dataMap.put('DocMap', docMap);
        
        return dataMap;
    }
    
}