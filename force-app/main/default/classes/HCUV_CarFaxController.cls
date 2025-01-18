public without sharing class HCUV_CarFaxController {
    
    @AuraEnabled(cacheable=true)
    public static String getCarFaxURL(String invId) {        
        
        HCUV_Inventory__c invObjList = [Select Id,Vehicle_ID_No__c, Name,Inventory_Status__c from HCUV_Inventory__c
                                        where Id = :invId];
        if(isValidInventoryStatus(invObjList.Inventory_Status__c)){                
            String carFaxUrl = '';
            try {
                if(!Test.isRunningTest()) carFaxUrl = HCUV_CarfaxUtility.getCarfaxVehicalHistory(invObjList.Vehicle_ID_No__c);
            } catch(Exception ex) { throw new AuraHandledException(ex.getStackTraceString() + '. ' + ex.getMessage()); }
            if(carFaxUrl==null){
                String CarFax_VIN_NotAvailbule=HCUV_Constants.Inventory_CarFax_Invalid_Msg.replace('{0}', invObjList.Vehicle_ID_No__c);                
                throw new AuraHandledException(CarFax_VIN_NotAvailbule);
            }            
            else
                return carFaxUrl;            
        }else{
            String CarFax_Not_Availbule=HCUV_Constants.Inventory_CarFax_Invalid_Status;
            throw new AuraHandledException(CarFax_Not_Availbule);
        }
    }
    
    private static Boolean isValidInventoryStatus(String inventoryStatus){
        
        return HCUV_Constants.InventoryStatus_CARFax.contains(inventoryStatus);
        
    }
}