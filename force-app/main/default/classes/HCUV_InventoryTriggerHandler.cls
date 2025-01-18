/**
 * [CCSOM-45] / 240316 / inhokim / update logic for  SRCEnd_Sales_Calendar_ID__c , beforeinsert,beforeupdate trigger
**/
public class HCUV_InventoryTriggerHandler {

    public static void beforeInsert(List<HCUV_Inventory__c> invObjList) {
        updateInventoryDealer(null, invObjList);
        updateCalendarDate(invObjList); 
    }
    
    public static void beforeUpdate(Map<Id, HCUV_Inventory__c> oldInvObjMap, List<HCUV_Inventory__c> invObjList) {
        updateInventoryDealer(oldInvObjMap, invObjList); 
        List<HCUV_Inventory__c> invRecList = new List<HCUV_Inventory__c>();
        // monitor and change looukup fields  -> SRC_End_Date__c(SRC End Date) , Transaction_Date__c(RDR Date)
        for(HCUV_Inventory__c invRec : invObjList){
            if(invRec.Transaction_Date__c!=oldInvObjMap.get(invRec.Id).Transaction_Date__c || invRec.SRC_End_Date__c!=oldInvObjMap.get(invRec.Id).SRC_End_Date__c){
                invRecList.add(invRec);
            }
        }
        
        if(!invRecList.isEmpty()){
          updateCalendarDate(invRecList);  
        }
    }
    
    public static void updateInventoryDealer(Map<Id, HCUV_Inventory__c> oldInvObjMap, List<HCUV_Inventory__c> invObjList) {
        Set<String> dealerCodes = new Set<String> ();
        
        for(HCUV_Inventory__c invObj : invObjList) {
            if(String.isNotBlank(invObj.Dealer_Code__c))// && (oldInvObjMap == null || oldInvObjMap.get(invObj.Id).Dealer_Code__c != invObj.Dealer_Code__c))
                dealerCodes.add(invObj.Dealer_Code__c);
        }
        
        if(!dealerCodes.isEmpty()) {
            List<Account> accObjList = [Select Id, DealerCode__c from Account Where DealerCode__c IN :dealerCodes];
            
            if(!accObjList.isEmpty()) {
                Map<String, String> dealerCodeAccIdMap = new Map<String, String> ();
                
                for(Account accObj : accObjList) {
                    dealerCodeAccIdMap.put(accObj.DealerCode__c, accObj.Id);
                }
                
                for(HCUV_Inventory__c invObj : invObjList) {
                    if(String.isNotBlank(invObj.Dealer_Code__c)// && (oldInvObjMap == null || oldInvObjMap.get(invObj.Id).Dealer_Code__c != invObj.Dealer_Code__c)
                       && dealerCodeAccIdMap.containsKey(invObj.Dealer_Code__c))
                        invObj.Dealer__c = dealerCodeAccIdMap.get(invObj.Dealer_Code__c);
                    invObj.Name=invObj.Vehicle_ID_No__c;
                }
            }
        }
    }
     
    /**
    * @description - update Calendar Date
    * @param - List<HCUV_Inventory__c>
    * @return void
    */
    public static void updateCalendarDate(List<HCUV_Inventory__c> invObjList) {
       Set<Date> inventoryDate=new Set<Date>();
        
        for(HCUV_Inventory__c invRec : invObjList){
            if(invRec.Transaction_Date__c!=null){
                inventoryDate.add(invRec.Transaction_Date__c);                
            }
            if(invRec.SRC_End_Date__c!=null){
                inventoryDate.add(invRec.SRC_End_Date__c);             
            }
        }
       
        Map<Date, String> calSalesMap = new Map<Date, String>();
        Map<Date, String> calSRCEndMap = new Map<Date, String>();
        for(HCUV_Sales_Calendar__c salesCalRec : [Select ID,Calendar_Date__c From HCUV_Sales_Calendar__c where Calendar_Date__c=:inventoryDate]){
           calSalesMap.put(salesCalRec.Calendar_Date__c, salesCalRec.ID);
        }

        for(HCUV_Inventory__c invRec : invObjList){
            if(invRec.Transaction_Date__c!=null && (calSalesMap.containsKey(invRec.Transaction_Date__c))){
                invRec.RDR_Sales_Calendar_ID__c=calSalesMap.get(invRec.Transaction_Date__c);
            }
            // CCSOM-45
            if(invRec.SRC_End_Date__c!=null && (calSalesMap.containsKey(invRec.SRC_End_Date__c))){                
                invRec.SRCEnd_Sales_Calendar_ID__c=calSalesMap.get(invRec.SRC_End_Date__c);
            }
        }    
    }
}