// Test Class: HCUV_UploadDealersCtrl_Test
public without sharing class HCUV_UploadDealersCtrl {
    
    @AuraEnabled
    public static Integer createDealerGroup(String recordId, String objectApi, List<Map<String, String>> data) {
        try {
            Integer count = 0;

            Set<String> dealerCodes = new Set<String> ();
            
            for(Map<String, String> dataMap : data) {
                dealerCodes.add(dataMap.get('Dealer Code').trim());               
            }
            
            Map<String, String> accNameIdMap = new Map<String, String> ();
            
            for(Account acc : [Select Id, DealerCode__c from Account where DealerCode__c IN :dealerCodes]) {
                accNameIdMap.put(acc.DealerCode__c, acc.Id);
            }
            
            if(HCUV_Constants.Contests_Incentives_API_Name == objectApi){
                List<HCUV_Contest_Incentive_Member__c> dgObjList = new List<HCUV_Contest_Incentive_Member__c> ();
                //Duplicate check
                Set<String> duplicateDealerCode = new Set<String>();
                for (HCUV_Contest_Incentive_Member__c obj: [select Dealer__r.DealerCode__c from HCUV_Contest_Incentive_Member__c where HCUV_Contests_Incentives__c  =:recordId and Dealer__r.DealerCode__c IN : dealerCodes])
                {
                    duplicateDealerCode.add(obj.Dealer__r.DealerCode__c);
                }
                
                for(Map<String, String> dataMap : data) {
                    String dealerCode = dataMap.get('Dealer Code').trim();

                    if(accNameIdMap.containsKey(dealerCode) && !duplicateDealerCode.contains(dealerCode)) {
                        dgObjList.add(
                            new HCUV_Contest_Incentive_Member__c(
                                HCUV_Contests_Incentives__c = recordId,
                                Dealer__c = accNameIdMap.get(dealerCode))
                        );
                        count++;
                    }
                }
                insert dgObjList;
                
            }else if(HCUV_Constants.Dealer_Message_API_Name == objectApi){
                List<HCUV_Message_Audience__c> dgObjList = new List<HCUV_Message_Audience__c> ();
                 //Duplicate check
                Set<String> duplicateDealerCode = new Set<String>();
                for (HCUV_Message_Audience__c obj: [select Dealer__r.DealerCode__c from HCUV_Message_Audience__c where Message__c  =:recordId and Dealer__r.DealerCode__c IN : dealerCodes])
                {
                    duplicateDealerCode.add(obj.Dealer__r.DealerCode__c);
                }
                for(Map<String, String> dataMap : data) {
                    String dealerCode = dataMap.get('Dealer Code').trim();

                    if(accNameIdMap.containsKey(dealerCode)  && !duplicateDealerCode.contains(dealerCode)) {
                        dgObjList.add(
                            new HCUV_Message_Audience__c(
                            Message__c = recordId,
                            Dealer__c = accNameIdMap.get(dealerCode))
                        );
                        count++;
                    }
                }
                insert dgObjList;
            }
            return count;
        } catch(Exception ex) { throw new AuraHandledException(ex.getStackTraceString() + '. ' + ex.getMessage()); }
        
    }
}