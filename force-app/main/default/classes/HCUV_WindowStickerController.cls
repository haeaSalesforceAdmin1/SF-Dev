public without sharing class HCUV_WindowStickerController {
    
    @AuraEnabled(cacheable=true)
    public static String getWindowSticker(String invId) {        
        
        HCUV_Inventory__c invObjList = [Select Id,Vehicle_ID_No__c, Name,Inventory_Status__c from HCUV_Inventory__c
                                        where Id = :invId];
        
        if(isValidInventoryStatus(invObjList.Inventory_Status__c)) {                
            String windowStickerUrl =HCUV_Constants.WindowSticker_WebDcsURL;
            return windowStickerUrl;
        } else {
            String WindowSticker_Not_Availbule=HCUV_Constants.Inventory_WindowSticker_Invalid_Status;
            throw new AuraHandledException(WindowSticker_Not_Availbule);
        }
    }
    
    private static Boolean isValidInventoryStatus(String inventoryStatus){
        return HCUV_Constants.InventoryStatus_WindowSticker.contains(inventoryStatus);
    }
}