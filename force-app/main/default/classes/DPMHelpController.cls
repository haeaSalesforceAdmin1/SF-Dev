public without sharing class DPMHelpController {
    @AuraEnabled
    public static Map<String, List<SubHeaderWrapper>> getDPMLinks(String typeOfHeader) {        
        Map<String, Map<String, List<DPM_Link__mdt>>> mapHeaderWithLinks = new Map<String, Map<String, List<DPM_Link__mdt>>>();
        Map<String, List<SubHeaderWrapper>> mapReturnObject = new Map<String, List<SubHeaderWrapper>>();
        system.debug('Here any result' + typeOfHeader);
        for(DPM_Link__mdt dpmLink : [SELECT Text_to_Display__c, URL__c, DPM_Header__r.Header_Name__c, DPM_Header__r.Type__c, Sub_Header__c, Sort_Order__c 
                                     FROM DPM_Link__mdt ORDER BY Sort_Order__c  ASC NULLS LAST]) {
                                         system.debug('=='+dpmLink.DPM_Header__r.Type__c);
            if(dpmLink.DPM_Header__r.Type__c == typeOfHeader) {
                String subHeader = '';
                if(String.isNotBlank(dpmLink.Sub_Header__c)) {
                    subHeader = dpmLink.Sub_Header__c;
                }
                if(mapHeaderWithLinks.containsKey(dpmLink.DPM_Header__r.Header_Name__c)) {
                    Map<String, List<DPM_Link__mdt>> mapHeaderWithSubHeader = mapHeaderWithLinks.get(dpmLink.DPM_Header__r.Header_Name__c);
                    if(mapHeaderWithSubHeader.containsKey(subHeader)) {
                        mapHeaderWithSubHeader.get(subHeader).add(dpmLink);
                    } else {
                        mapHeaderWithSubHeader.put(subHeader, new List<DPM_Link__mdt> {dpmLink});
                    }
                } else {
                    mapHeaderWithLinks.put(dpmLink.DPM_Header__r.Header_Name__c, new Map<String, List<DPM_Link__mdt>> { subHeader => new List<DPM_Link__mdt> {dpmLink} });
                }
            }
        }
        
        for(String header : mapHeaderWithLinks.keySet()) {
            List<SubHeaderWrapper> lstSubHeader = new List<SubHeaderWrapper>();
            Map<String, List<DPM_Link__mdt>> mapSubHeaderLinks = mapHeaderWithLinks.get(header);
            for(String subHeader : mapSubHeaderLinks.keySet()) {
                lstSubHeader.add(new SubHeaderWrapper(subHeader, mapSubHeaderLinks.get(subHeader)));
            }
            mapReturnObject.put(header, lstSubHeader);
        }
        system.debug('mapReturnObject==' + mapReturnObject);
        return mapReturnObject;
    }

    @AuraEnabled
    public static List<Account> getDSMANDDPSM() {
        User userDetails = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        if(String.isNotBlank(userDetails.AccountId)) {
            List<Account> lstAccount = [SELECT Id, DistrictSalesManager__c, DistrictSalesManager__r.Name, DistrictSalesManager__r.FirstName, DistrictSalesManager__r.LastName, DistrictSalesManager__r.Email,
                                        DistrictPartsServiceManager__c, DistrictPartsServiceManager__r.Name, DistrictPartsServiceManager__r.FirstName, DistrictPartsServiceManager__r.LastName, DistrictPartsServiceManager__r.Email,
                                        Aftersales_Market_Manager__c, Aftersales_Market_Manager__r.Name, Aftersales_Market_Manager__r.FirstName, Aftersales_Market_Manager__r.LastName, Aftersales_Market_Manager__r.Email,
                                        MarketManager__c, MarketManager__r.Name, MarketManager__r.FirstName, MarketManager__r.LastName, MarketManager__r.Email 
                                        FROM Account WHERE Id = :userDetails.AccountId];
            return lstAccount;
        }
        return null;
    }

    @AuraEnabled
    public static String getUserTypeAccess() {
        User u = [SELECT AccessTypes__c FROM User WHERE Id = :UserInfo.getUserId()];
        return u.AccessTypes__c;
    }
    
    public class SubHeaderWrapper {//} implements Comparable {
        @AuraEnabled public String key;
        @AuraEnabled public List<DPM_Link__mdt> value;
        public SubHeaderWrapper(String key, List<DPM_Link__mdt> value) {
            this.key = key;
            this.value = value;
			this.value.sort();            
        }
        
        /*public Integer compareTo(Object objToCompare) {
            SubHeaderWrapper subHeader = (SubHeaderWrapper)objToCompare;
            Integer icount = 1;
            for(DPM_Link__mdt link : subHeader.value) {
                if (link.Sort_Order__c == subHeader.value[icount].Sort_Order__c){
                    icount++;
                    return 0;
                }
                else if (link.Sort_Order__c > subHeader.value[icount].Sort_Order__c){
                    icount++;
                    return 1;
                }
                return -1;
            }
            return -1;
        }*/
    }
    
    /*public class DPMLink implements Comparable {
        @AuraEnabled public DPM_Link__mdt link;
        public DPMLink(DPM_Link__mdt link) {
            this.link = link;
        }
        
        public Integer compareTo(Object objToCompare) {
            DPMLink emp = (DPMLink)objToCompare;
            if (this.link.Sort_Order__c == emp.link.Sort_Order__c){
                return 0;
            }
            else if (this.link.Sort_Order__c > emp.link.Sort_Order__c){
                return 1;
            }
            else{
                return -1;        
            }
        }
    }*/
    
}