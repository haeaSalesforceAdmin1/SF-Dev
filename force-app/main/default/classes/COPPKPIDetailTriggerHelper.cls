public with sharing class COPPKPIDetailTriggerHelper {
    /**
    * [Method Description] before insert the COPPKPIDetail obj handle fields
    * Created by [MinheeKim] on [2024-10-01] for [DPM-5700] COPP Project - added logic to handle the COPP Info lookup field
   */    
   public static void handleBeforeInsertUpdate(List<COPPKPIDetail__c> coppKpis, Map<Id, COPPKPIDetail__c> oldMap) {

        Map<COPPKPIDetail__c, Id> mapOfCoppDetailAccount = new Map<COPPKPIDetail__c, Id>();
        Map<Id, Id> mapOfAccountCOPPInfo = new Map<Id, Id>();
       for(COPPKPIDetail__c coppKpi : coppKpis) {
           if(coppKpi.Account__c != null){
                mapOfCoppDetailAccount.put(coppKpi, coppKpi.Account__c);
           }
       }
       Set<Id> setOfAccountIds = new Set<Id>(mapOfCoppDetailAccount.values());

       List<COPPInfo__c> coppInfos = [SELECT Id , Account__c FROM COPPInfo__c WHERE Account__c IN : setOfAccountIds];

       if(coppInfos.size()>0){
            for(COPPInfo__c coppInfo : coppInfos){
                mapOfAccountCOPPInfo.put(coppInfo.Account__c, coppInfo.Id);
            }
       }

       for(COPPKPIDetail__c key : mapOfCoppDetailAccount.keySet()){
            if(oldMap==null || oldMap.get(key.Id).COPPInfo__c ==null){
                Id accountId = mapOfCoppDetailAccount.get(key);
                key.COPPInfo__c = mapOfAccountCOPPInfo.get(accountId);
            }
       }
            
  
   }
}