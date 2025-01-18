public class HCUV_InventoryRetailMileageBatch implements Database.Batchable<SObject>, Database.Stateful {    
    public String status;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select Id, Retail_Mileage__c from HCUV_Inventory__c]);         
    }

    public void execute(Database.BatchableContext BC, List<HCUV_Inventory__c> inventoryScope) { 
         Map<ID,HCUV_Inventory__c> updateInventoryList=new Map<ID,HCUV_Inventory__c>();
         Set<Id> inventoryIdSet=new Set<Id>();

         for(HCUV_Inventory__c invRec : inventoryScope){
             inventoryIdSet.add(invRec.Id);
         }

         List<HCUV_Inventory__c> inventoryList=[Select Id, Retail_Mileage__c, (Select Id, Retail_Mileage__c, Sequence__c, Record_Type__c from Sales__r Order by Sequence__c desc limit 1) from HCUV_Inventory__c where ID IN :inventoryIdSet];

         for(HCUV_Inventory__c invRec : inventoryList){

            invRec.Retail_Mileage__c=null;
            updateInventoryList.put(invRec.Id,invRec);
            for(HCUV_Sales__c sales : invRec.Sales__r){
                if(sales.Record_Type__c == HCUV_Constants.SalesRecTypeRDR){
                   invRec.Retail_Mileage__c=sales.Retail_Mileage__c==null?null:Integer.valueOf(sales.Retail_Mileage__c);
                }               
               updateInventoryList.put(invRec.Id,invRec);             
            }
        }
        
        if(!updateInventoryList.isEmpty()){
            update updateInventoryList.values();
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