/**
************************************************************************************************
* @classname         : HCUV_ContestsIncentivesDataCtrl; being used in lwc hCUVcontestsIncentivesData 
* @description       : Get the Contests Incentives data
* @author            : Smriti Gupta
* Test Class		 : HCUV_ContestsIncentivesDataCtrl_Test
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       24th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
* 2.0       11th Nov 2023          Smriti Gupta         HVM-214
************************************************************************************************
**/
public without sharing class HCUV_ContestsIncentivesDataCtrl {
    /**
    * @description - Fetch Contests Incentives records based on community and program
    * @return Map<String, Object>
    */
    @AuraEnabled(cacheable=true)     
    public static Map<String, Object> getcontestIncentive(String programName, String networkId) {
        //get community name
        String communityName= HCUV_Utility.getCommunityName(networkId);
        List<String> recordTypeList= HCUV_Utility.getRecordTypeList(HCUV_Constants.CI_Object_API_Name, networkId, '');
        Map<String, Object> dataMap = new Map<String, Object> ();
        String accId = HCUV_Utility.getAccountId();
        List<HCUV_Contests_Incentives__c> ciList;
        List<HCUV_Contests_Incentives__c> ciListMarketDealers;
        Account accObj = new Account();
        HCUV_CommunityIcon__mdt hcuvMdt = [Select Label From HCUV_CommunityIcon__mdt
                                           Where Program_Type__c=:programName];
        programName=  hcuvMdt.Label;
        if(String.isNotBlank(accId)) {
            accObj = [SELECT Id, MarketCodeGenesisPicklist__c, Name, Region__r.Name, region__r.RegionCode__c,
                      SalesDistrict__r.DistrictCode__c,SalesDistrictCode__c 
                      FROM Account WHERE Id =: accId];
        }
        //String district = (String.isNotBlank(accId) ? accObj.SalesDistrict__r.DistrictCode__c : '');
        String districtMarketCode = '';
        if(communityName==HCUV_Constants.HMA_COMMUNITY_NAME){
            districtMarketCode = accObj.SalesDistrict__r.DistrictCode__c;
        }
        else if(communityName==HCUV_Constants.GMA_COMMUNITY_NAME){
            districtMarketCode = accObj.MarketCodeGenesisPicklist__c;
        }
        String region = (String.isNotBlank(accId) ? accObj.region__r.RegionCode__c : '');
        //String accountName = (String.isNotBlank(accId) ? accObj.Name : '');
        
        
        String query = 'Select Id, Name, recordtype.name, Subject__c, Date__c, End_Date__c,Publish_Date__c,Expiration_Date__c, Description__c, CreatedDate, Region__c, District__c,LastModifiedDate,';
        query += ' (Select ContentDocumentId, ContentDocument.Title,ContentDocument.FileExtension FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate DESC) ';
        query += ' FROM HCUV_Contests_Incentives__c where (Publish_Date__c <= Today and Expiration_Date__c >= Today) ';
        query += ' AND Region__c INCLUDES (:region) ';
        query += ' AND Program_Name__c = :programName AND Status__c = \''+HCUV_Constants.Status_Published+'\'';
        query += ' AND RecordType.DeveloperName IN:recordTypeList';
        query += ' ORDER BY LastModifiedDate DESC';
        ciList = Database.query(query);
        
        
        //Getting list of Dealers data
        String queryDealerContests='';
        if(String.isNotBlank(accId)) {
            // HVM-214 - Retrieving Contest Incentive Ids from Junction objects for Dealer and Market
            Set<Id> ContestsIncentivesIds = new Set<Id>();
            for(HCUV_Contest_Incentive_Member__c contestIncenDlrRec : [Select Id, HCUV_Contests_Incentives__c from HCUV_Contest_Incentive_Member__c where Dealer__c = :accId]){
                ContestsIncentivesIds.add(contestIncenDlrRec.HCUV_Contests_Incentives__c);
            }
            for(HCUV_Contests_Incentives_Audience_Market__c contestIncenMarketRec : [Select Id, Contests_Incentives__c from HCUV_Contests_Incentives_Audience_Market__c where Market__r.DistrictCode__c = :districtMarketCode]){
                ContestsIncentivesIds.add(contestIncenMarketRec.Contests_Incentives__c);
            }
            
            // HVM-214 - Fetching data from Contest Incentive based on Dealer and Market Junction object   
            queryDealerContests += 'Select Id, Name, recordtype.name, Subject__c, Date__c, End_Date__c,Publish_Date__c,Expiration_Date__c, Description__c, CreatedDate, Region__c, District__c,LastModifiedDate,';
            queryDealerContests += ' (Select ContentDocumentId, ContentDocument.Title,ContentDocument.FileExtension FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate DESC) ';
            queryDealerContests += ' FROM HCUV_Contests_Incentives__c where Publish_Date__c <= Today and Expiration_Date__c >= Today ';
            queryDealerContests += ' AND Program_Name__c = :programName AND Status__c = \''+HCUV_Constants.Status_Published+'\'';
            queryDealerContests += ' AND RecordType.DeveloperName IN:recordTypeList';
            queryDealerContests += ' AND ID IN : ContestsIncentivesIds ORDER BY LastModifiedDate DESC';
            ciListMarketDealers = Database.query(queryDealerContests);
            if(ciListMarketDealers.size()>0){
                ciList.addAll(ciListMarketDealers);
            }
        }
        dataMap.put('ContestsIncentives', ciList);
        List<String> docIds = new List<String> ();
        for(HCUV_Contests_Incentives__c ci : ciList) {
            for(ContentDocumentLink cdl : ci.ContentDocumentLinks) {
                docIds.add(cdl.ContentDocumentId);
            }
        }
        List<ContentDistribution> cdObjList = [select ContentDocumentId, DistributionPublicUrl 
                                               from ContentDistribution where ContentDocumentId IN :docIds];
        Map<String, String> docMap = new Map<String, String> ();
        for(ContentDistribution cdObj : cdObjList) {
            docMap.put(cdObj.ContentDocumentId, cdObj.DistributionPublicUrl);
        }
        dataMap.put('DocMap', docMap);
        dataMap.put('VideoURL', URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/');
        return dataMap;
    }
}