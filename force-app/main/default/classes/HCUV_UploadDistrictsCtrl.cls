/**
************************************************************************************************
* @classname         : HCUV_UploadDistrictsCtrl;
* @description       : Used in HCUV_UploadDistricts LWC
* @author            : Hemanth
* @Test Class        : HCUV_UploadDistrictsCtrl_Test
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       8th Aug 2023           Hemanth        				          Initial Version
************************************************************************************************
**/
public without sharing class HCUV_UploadDistrictsCtrl {
    
    /**
    * @description - Add District to HCUV_Contests_Incentives__c/HCUV_Dealer_Message__c
    * @param - String, String, List<Map<String, String>>
    * @return Integer
    */
    @AuraEnabled
    public static Integer updateDistricts(String recordId, String objectApi, List<Map<String, String>> data) {
        try {
            Integer count = 0;
			
            Set<String> districtCodes = new Set<String> ();
            
            for(Map<String, String> dataMap : data) {
                districtCodes.add(dataMap.get('Market Code').trim());               
            }
            
            Map<String, String> districtCodeIdMap = new Map<String, String> ();
            
            for(District__c dis : [Select Id, DistrictCode__c from District__c where DistrictCode__c IN :districtCodes AND Active__c = true]) {
                districtCodeIdMap.put(dis.DistrictCode__c, dis.Id);
            }           
            if(HCUV_Constants.Contests_Incentives_API_Name == objectApi) {
                count = createContestsIncentivesAudienceMarket(recordId, data, districtCodeIdMap,districtCodes);
                
            } else if(HCUV_Constants.Dealer_Message_API_Name == objectApi){
                count = createMessageAudienceMarket(recordId, data, districtCodeIdMap,districtCodes);
            }
            return count;
        } catch(Exception ex) { throw new AuraHandledException(ex.getStackTraceString() + '. ' + ex.getMessage()); }
        
    }

    /**
    * @description - create HCUV_Contest_Incentive_Member records
    * @param - String, List<Map<String, String>>
    * @return void
    */
    public static Integer createContestsIncentivesAudienceMarket(String recordId, List<Map<String, String>> data, Map<String, String> districtCodeIdMap,Set<String> districtCodes) {
        Integer count = 0;
        List<HCUV_Contests_Incentives_Audience_Market__c> mmObjList = new List<HCUV_Contests_Incentives_Audience_Market__c> ();
        
        //Duplicate check
        Set<String> duplicateMarketCode = new Set<String>();
        for (HCUV_Contests_Incentives_Audience_Market__c obj: [select Market__r.DistrictCode__c from HCUV_Contests_Incentives_Audience_Market__c where Contests_Incentives__c =:recordId and Market__r.DistrictCode__c IN : districtCodes])
        {
               duplicateMarketCode.add(obj.Market__r.DistrictCode__c);
        }
        for(Map<String, String> dataMap : data) {
            String marketCode = dataMap.get('Market Code').trim();
            
            if(districtCodeIdMap.containsKey(marketCode) && !duplicateMarketCode.contains(marketCode)) {
                mmObjList.add(
                    new HCUV_Contests_Incentives_Audience_Market__c(
                        Contests_Incentives__c = recordId,
                        Market__c = districtCodeIdMap.get(marketCode))
                );
                count++;
            }
        }
        insert mmObjList;
        
        return count;
    }
    
    /**
    * @description - create HCUV_Message_Audience records
    * @param - String, List<Map<String, String>>
    * @return void
    */
    public static Integer createMessageAudienceMarket(String recordId, List<Map<String, String>> data, Map<String, String> districtCodeIdMap,Set<String> districtCodes) {
        Integer count = 0;
        List<HCUV_Message_Audience_Market__c> mmObjList = new List<HCUV_Message_Audience_Market__c> ();
        
        //Duplicate Check
        Set<String> duplicateMarketCode = new Set<String>();
        for (HCUV_Message_Audience_Market__c obj: [select Market__r.DistrictCode__c from HCUV_Message_Audience_Market__c where Dealer_Message__c =:recordId and Market__r.DistrictCode__c IN : districtCodes])
        {
               duplicateMarketCode.add(obj.Market__r.DistrictCode__c);
        }
        for(Map<String, String> dataMap : data) {
            String marketCode = dataMap.get('Market Code').trim();
            
            if(districtCodeIdMap.containsKey(marketCode) && !duplicateMarketCode.contains(marketCode)) {
                mmObjList.add(
                    new HCUV_Message_Audience_Market__c(
                        Dealer_Message__c = recordId,
                        Market__c = districtCodeIdMap.get(marketCode))
                );
                count++;
            }
        }
        insert mmObjList;
        
        return count;
    }

}