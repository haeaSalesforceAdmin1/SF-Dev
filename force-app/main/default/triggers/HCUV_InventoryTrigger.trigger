// Test Class: HCUV_InventoryTriggerTest
trigger HCUV_InventoryTrigger on HCUV_Inventory__c (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert)
        HCUV_InventoryTriggerHandler.beforeInsert(Trigger.new);
    
    if(Trigger.isBefore && Trigger.isUpdate)
        HCUV_InventoryTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.new);
    
}