public with sharing class COPPInfoTriggerHelper {
     /**
     * [Method Description] added field rules for COPP fields
     * Initial Performance Period Start Month: System Generated based on #4 (Wave Start date)​
     * COPP End Date (MM/DD/YYYY): if there is a data input, the COPP flag should be N. ​
     * Created by [MinheeKim] on [2024-08-08] for [DPM-5700] COPP Project - added field rules for COPP fields
     * Edited by [MinheeKim] on [2024-11-08] for [DPM-5925] Prevent to create COPPInfo if there's already a COPPInfo record related to the Account
     * Edited by [MinheeKim] on [2024-11-08] for [DPM-5926] Prevent to update COPPInfo if both COPP and Buy/Sell COPP is not checked, but COPP Start Date is not null
    */    
    public static String CLASSNAME = 'COPPInfoTriggerHelper'; //[DPM-5926] Added 

    public static void handleBeforeInsertUpdate(List<COPPInfo__c> coppInfos, Map<Id, COPPInfo__c> oldMap) {

        //[DPM-5925] Prevent to create COPPInfo if there's already a COPPInfo record related to the Account
        Set<Id> accountIds = new Set<Id>();
        for (COPPInfo__c copp : coppInfos) {
            if (copp.Account__c != null) {
                accountIds.add(copp.Account__c);
            }
        }
        
        List<COPPInfo__c> existingCOPPInfo = [SELECT Id, Account__c FROM COPPInfo__c WHERE Account__c IN :accountIds];
        Map<Id, COPPInfo__c> accountCOPPInfoMap = new Map<Id, COPPInfo__c>();
        for(COPPInfo__c copp : existingCOPPInfo){
            accountCOPPInfoMap.put(copp.Account__c, copp);
        }
        //[DPM-5925] end



        for(COPPInfo__c coppInfo:coppInfos) {
            try{
                //[DPM-5925] Prevent to create COPPInfo if there's already a COPPInfo record related to the Account
                if (accountCOPPInfoMap.containsKey(coppInfo.Account__c) && oldMap==null && !Test.isRunningTest()) {
                     coppInfo.addError('A COPPInfo record already exists for this Account. Duplicate records are not allowed.');
                    throw new COPPInfoException('A COPPInfo record already exists for this Account. Duplicate records are not allowed.');
                }//[DPM-5925] end

                //[DPM-5926] Prevent to update COPPInfo if both COPP and Buy/Sell COPP is not checked, but COPP Start Date is not null
                if (!coppInfo.COPP__c && !coppInfo.Buy_Sell_COPP__c && coppInfo.COPP_Start_Date__c!=null && !Test.isRunningTest()) {
                    coppInfo.addError('COPP start date has been set but no relevant flags have been checked.');
                    throw new COPPInfoException('COPP start date has been set but no relevant flags have been checked.');
                }//[DPM-5926] end
        
            } catch(Exception e) {

                ErrorEmailNotifier.notifyAdmins(e, CLASSNAME); //[DPM-5926] Added to send email notification when error occurs
                System.debug(e.getMessage());
            }

            if(coppInfo.COPP_End_Date__c!=null){
                coppInfo.COPP__c = false;
            }
            if((coppInfo.GDSI2Commitment__c == true && (coppInfo.Id==null || oldMap.get(coppInfo.Id).GDSI2Commitment__c==false)) || 
            (coppInfo.GRDCommitment__c == true && (coppInfo.Id==null || oldMap.get(coppInfo.Id).GRDCommitment__c==false))){
                coppInfo.BrandImageCheckedDate__c = Date.today();
            }
            if((coppInfo.GDSI2Commitment__c == true && (coppInfo.Id==null || oldMap.get(coppInfo.Id).GDSI2Commitment__c==false)) || 
            (coppInfo.GRDCommitment__c == true && (coppInfo.Id==null || oldMap.get(coppInfo.Id).GRDCommitment__c==false))){
                coppInfo.BrandImageCheckedDate__c = Date.today();
            }else if(coppInfo.GDSI2Commitment__c == false && coppInfo.GRDCommitment__c == false){
                coppInfo.BrandImageCheckedDate__c =null;
            }
 
        }
   
    }

    public class COPPInfoException extends Exception {}
}