/**
 * CreateSTILLRVehiclesFromCase
 * Description: INVOKED BY FLOW ( STIL_Create_WO_Flow  ) , Create LRVehicle__c records
 * (LRVehicle__c records are displayed in Lab Request Record Detail Page. (#GOTO MultiVehicleWO_LRtoLR LWC component) )
 * ----- Change Log -----
 * Author : Hayeon Cho / [MM-DD-YYYY] / [Ticket #] / [Change Description] 
 * Author : Inho Kim / [10-07-2024] / [OU24-135] / [ADD LOGIC TO GET KASOCaseVehicle__c, to solve issue - (When creating an LR from LR app or CMT and using safety case with (E, O, or K) prefix, the Affected Vehicles is not populating.) ] 
 * ---------------------------
 */

public without sharing class CreateSTILLRVehiclesFromCase {
    @InvocableMethod(label = 'Create STIL LR Vehicles From Case')
    public static void CreateSTILLRVehiclesFromCase(List<Id> lrIds) {
        try{
            Id lrId = lrIds[0];
            List<WorkOrder> wolist = [SELECT Safety_Case_Number__c FROM WorkOrder WHERE ID = :lrId];
            String caseSCN = wolist[0].Safety_Case_Number__c;
            List<Case> caseList = [SELECT Id,Case_Own_Org__c FROM Case WHERE SCSCaseNumber__c = :caseSCN];
            Id caseId = caseList[0].Id;
            String caseOwnOrg = caseList[0].Case_Own_Org__c;
            List<LRVehicle__c> lrvlist = new List<LRVehicle__c>();     
            // ADD IF/ELSE LOGIC to cover not only NASO case affected vehicles but also KASO case affected vehicles
            if((caseSCN.startsWith('N') || caseSCN.startsWith('O')) && caseOwnOrg =='NASO' ){
                List<CaseVehicle__c> cvlist = [SELECT Id, Make__c, Model__c, VehicleYear__c, ModelCode__c FROM CaseVehicle__c WHERE Case__c = :caseId];
                for(CaseVehicle__c cv : cvlist){
                    LRVehicle__c lv = new LRVehicle__c();lv.WorkOrder__c = lrId;
                    lv.Model__c = cv.Model__c;lv.ModelCode__c = cv.ModelCode__c;
                    lv.Make__c = cv.Make__c;lv.VehicleYear__c = cv.VehicleYear__c;
                    lrvlist.add(lv);
                }
            }else if((caseSCN.startsWith('K') || caseSCN.startsWith('E') || caseSCN.startsWith('O')) && caseOwnOrg =='KASO'){
                List<KASOCaseVehicle__c> cvlist = [SELECT Id, Make__c, Model__c, VehicleYear__c, ModelCode__c FROM KASOCaseVehicle__c WHERE Case__c = :caseId];
                for(KASOCaseVehicle__c cv : cvlist){
                    LRVehicle__c lv = new LRVehicle__c();lv.WorkOrder__c = lrId;
                    lv.Model__c = cv.Model__c;lv.ModelCode__c = cv.ModelCode__c;
                    lv.Make__c = cv.Make__c;lv.VehicleYear__c = cv.VehicleYear__c;
                    lrvlist.add(lv);
                }
            }    
            insert lrvlist;
        }catch(Exception e){
            System.debug('Error in CreateSTILLRVehiclesFromCase : ' + e.getMessage());
        }
    }
}