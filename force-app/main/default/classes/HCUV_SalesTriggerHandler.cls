/**
************************************************************************************************
* @classname         : HCUV_SalesTriggerHandler; being used in HCUV_SalesTrigger
* @description       : Handler class for HCUV_SalesTrigger trigger
* @author            : Hemanth
* @Test Class        : HCUV_SalesTriggerTest
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       14th Jun 2023          Hemanth        				          Initial Version
* 2.0       26th Oct 2023          Smriti/Chaitanya        				  Added Retail Mileage logic
************************************************************************************************
**/
public class HCUV_SalesTriggerHandler {

    /**
    * @description - handle before insert logic
    * @param - List<HCUV_Sales__c>
    * @return void
    */
    public static void beforeInsert(List<HCUV_Sales__c> saObjList) {
        updateSalesDealer(null, saObjList);
    }
    
    /**
    * @description - handle before update logic
    * @param - Map<Id, HCUV_Sales__c>, List<HCUV_Sales__c>
    * @return void
    */
    public static void beforeUpdate(Map<Id, HCUV_Sales__c> oldSAObjMap, List<HCUV_Sales__c> saObjList) {
        updateSalesDealer(oldSAObjMap, saObjList);  
    }
    
    /**
    * @description - handle after insert logic
    * @param - Map<Id, HCUV_Sales__c>, List<HCUV_Sales__c>
    * @return void
    */
    public static void afterInsert(List<HCUV_Sales__c> newList) {
        Set<Id> invIds= new Set<Id>(); 
        for(HCUV_Sales__c salesRec: newList){
            invIds.add(salesRec.Inventory__c);
        }
        updateInventoryRetailMileage(invIds);
        
    }
    
    /**
    * @description - handle after update logic
    * @param - Map<Id, HCUV_Sales__c>, List<HCUV_Sales__c>
    * @return void
    */
    public static void afterUpdate(Map<Id, HCUV_Sales__c> oldSAObjMap, List<HCUV_Sales__c> newList) {
        Set<Id> invIds= new Set<Id>(); 
        for(HCUV_Sales__c salesRec: newList){
            invIds.add(salesRec.Inventory__c);
        }
        updateInventoryRetailMileage(invIds);
    }

    /**
    * @description - Update Inventory Retail Mileage based on RDR record
    * @param - inventoryIds
    * @return void
    */
    private static void updateInventoryRetailMileage(Set<Id> inventoryIds) {
        
        Map<String, Integer> invMap = new Map<String, Integer>();
        Set<Id> invIds= new Set<Id>();
        List<HCUV_Inventory__c> updateInventoryList=new List<HCUV_Inventory__c>();
        List<HCUV_Inventory__c> invList = [Select Id, Retail_Mileage__c, (Select Id, Retail_Mileage__c, Sequence__c, Record_Type__c from Sales__r Order by Sequence__c desc limit 1) from HCUV_Inventory__c where Id IN : inventoryIds];
        
        for(HCUV_Inventory__c invRec : invList){
            for(HCUV_Sales__c sales : invRec.Sales__r){
                if(sales.Record_Type__c == HCUV_Constants.SalesRecTypeRDR){
                   invRec.Retail_Mileage__c=sales.Retail_Mileage__c==null?null:Integer.valueOf(sales.Retail_Mileage__c);
                }else{
                    invRec.Retail_Mileage__c=null;
                }
                updateInventoryList.add(invRec);                
            }
        }
        
        if(!updateInventoryList.isEmpty()){
            update updateInventoryList;
        }
    }
    
    /**
    * @description - Update Dealer on HCUV_Sales from Dealer_Code
    * @param - Map<Id, HCUV_Sales__c>, List<HCUV_Sales__c>
    * @return void
    */
    public static void updateSalesDealer(Map<Id, HCUV_Sales__c> oldSAObjMap, List<HCUV_Sales__c> saObjList) {
        Set<String> dealerCodes = new Set<String> ();
        
        for(HCUV_Sales__c saObj : saObjList) {
            if(String.isNotBlank(saObj.Dealer_Code__c)) {
                dealerCodes.add(saObj.Dealer_Code__c);   
            }
        }
        
        Map<String, String> dealerCodeAccIdMap = HCUV_Utility.getDealerAccountsUsingDealerCodes(dealerCodes);
        
        if(dealerCodeAccIdMap.isEmpty())
        {
            System.debug (LoggingLevel.ERROR, 'Accounts do not exist for the dealer Codes');
			return;            
        }     
        
        for(HCUV_Sales__c saObj : saObjList) {
            if(String.isNotBlank(saObj.Dealer_Code__c) && dealerCodeAccIdMap.containsKey(saObj.Dealer_Code__c)) {
                saObj.Dealer__c = dealerCodeAccIdMap.get(saObj.Dealer_Code__c);   
            }
        }
    }
}