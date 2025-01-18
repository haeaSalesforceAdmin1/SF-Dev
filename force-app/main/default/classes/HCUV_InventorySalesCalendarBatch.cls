public class HCUV_InventorySalesCalendarBatch implements Database.Batchable<SObject>, Database.Stateful { 
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT ID,Transaction_Date__c from HCUV_Inventory__c where Transaction_Date__c!=null and RDR_Sales_Calendar_ID__c =null]);         
    }
    
   public void execute(Database.BatchableContext BC, List<HCUV_Inventory__c> invObjList) { 

        Set<Date> inventoryDate=new Set<Date>();
        Map<ID,HCUV_Inventory__c> resultsInventoryList=new Map<ID,HCUV_Inventory__c>();
        
        for(HCUV_Inventory__c invRec : invObjList){
            if(invRec.Transaction_Date__c!=null){
                inventoryDate.add(invRec.Transaction_Date__c);
            }
        }
       
        Map<Date, String> calSalesMap = new Map<Date, String>();
        for(HCUV_Sales_Calendar__c salesCalRec : [Select ID,Calendar_Date__c From HCUV_Sales_Calendar__c where Calendar_Date__c=:inventoryDate]){
           calSalesMap.put(salesCalRec.Calendar_Date__c, salesCalRec.ID);
        }

        for(HCUV_Inventory__c invRec : invObjList){
            if(invRec.Transaction_Date__c!=null && calSalesMap.containsKey(invRec.Transaction_Date__c)){
                invRec.RDR_Sales_Calendar_ID__c=calSalesMap.get(invRec.Transaction_Date__c);
                resultsInventoryList.put(invRec.ID,invRec);
            }
        }
        
        
        if(!resultsInventoryList.isEmpty()){
            Database.update(resultsInventoryList.values(), false) ;
        }
    }
    
    public void finish(Database.BatchableContext bc){
        // Query the AsyncApexJob object to retrieve the current job's information.
   	  AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob WHERE Id =
      :BC.getJobId()];
        System.debug('ApexJobs Processed: '+a.Id);
    }
    
}