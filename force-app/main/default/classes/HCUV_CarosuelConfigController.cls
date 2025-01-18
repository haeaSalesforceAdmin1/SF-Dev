/**
************************************************************************************************
* @classname         : HCUV_CarosuelConfigController; being used in lwc hcuvCarouselWrapper 
* @description       : Get the carousel records
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       25th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/

public with sharing class HCUV_CarosuelConfigController { 
    
    /**
    * @description - Fetch Carousel data
    * @param - programName, networkId
    * @return Map <String, DesktopCarouselWrapper>
    */
    @AuraEnabled(cacheable=true)
    public static Map <String, DesktopCarouselWrapper> fetchCarouselConfigInfo(String programName, String networkId) {
        List<String> recordTypeList= HCUV_Utility.getRecordTypeList(HCUV_Constants.Carosuel_Object_API_Name, networkId, '');
        HCUV_CommunityIcon__mdt hcuvMdt = [Select Label From HCUV_CommunityIcon__mdt 
                                           Where Program_Type__c=:programName limit 1];
        programName=  hcuvMdt.Label;
        Map <String, DesktopCarouselWrapper > carouselDesktopMap = new Map <String, DesktopCarouselWrapper >();
        List<HCUV_Carousel__c> lstCarousels = [SELECT Name, Id, Carousel_Image_LInk__c,Active__c,IsOpen_InSeperateTab__c FROM HCUV_Carousel__c 
                                               WHERE 
                                               Program_Name__c=:programName 
                                               AND Start_Date__c <= TODAY 
                                               AND Expiration_Date__c > TODAY 
                                               AND RecordType.DeveloperName IN:recordTypeList
                                               ORDER BY LastModifiedDate DESC LIMIT 5];            
        Set<Id> carouselIds=new Set<Id>();
        for(HCUV_Carousel__c carousel:lstCarousels){
            carouselIds.add(carousel.Id);
        }
        List<ContentDocumentLink> contentDocuments = [SELECT ContentDocumentId, LinkedEntityId  
                                                      FROM ContentDocumentLink
                                                      where LinkedEntityId IN :carouselIds];
        Map<Id,Id> mapContentDocument=new Map<Id,Id>();
        for(ContentDocumentLink cdLink:contentDocuments){
            mapContentDocument.put(cdLink.LinkedEntityId,cdLink.ContentDocumentId);
        }
        for(HCUV_Carousel__c carousel : lstCarousels){
            DesktopCarouselWrapper carouselWrap = new DesktopCarouselWrapper();
            carouselWrap.isOpenInSeperateTab = carousel.IsOpen_InSeperateTab__c;
            carouselWrap.active = carousel.Active__c;
            carouselWrap.carouselImage = carousel.Carousel_Image_LInk__c;
            carouselWrap.contentId = mapContentDocument.get(carousel.Id);
            if(String.isNotBlank(mapContentDocument.get(carousel.Id))){
                carouselDesktopMap.put(carousel.Name, carouselWrap);
            }
        }
        return carouselDesktopMap;
    }
    
    /**
    * @description - Fetch Latest Modified Image
    * @return String
    */
    @AuraEnabled(cacheable=true)
    public static String getLatestModifiedImageInfo() {
        String urlValue = '';
        try {
            StaticResource staticResource = [SELECT Id, Name, lastmodifieddate, SystemModStamp 
                                             FROM StaticResource 
                                             WHERE Name like '%hmaCarouselImage%' order by lastmodifieddate desc limit 1];
            urlValue= PageReference.forResource(staticResource.Name).getUrl();
        } catch(Exception e) {
            urlValue = e.getMessage();
        }
        return urlValue;
        
    }
    /**
    * @description - Created wrapper
    * @return Wrapper
    */
    public class DesktopCarouselWrapper{
        @AuraEnabled
        public Boolean isOpenInSeperateTab;
        @AuraEnabled
        public string contentId;
        @AuraEnabled
        public Boolean active;
        @AuraEnabled
        public String carouselImage;
    }
}