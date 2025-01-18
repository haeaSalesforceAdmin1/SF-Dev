/**
************************************************************************************************
* @classname         : HCUV_SalesTrigger;
* @description       : HCUV_Sales__c object trigger
* @author            : Hemanth
* @Test Class        : HCUV_SalesTriggerTest
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       14th Jun 2023          Hemanth        				          Initial Version
* 2.0       26th Oct 2023          Smriti G/Chaitanya			          Included AfterInsert and AfterUpdate
************************************************************************************************
**/
trigger HCUV_SalesTrigger on HCUV_Sales__c (before insert, before update, after insert, after update ) {

    if(Trigger.isBefore && Trigger.isInsert) {
     	HCUV_SalesTriggerHandler.beforeInsert(Trigger.new);   
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
     	HCUV_SalesTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.new);   
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
     	HCUV_SalesTriggerHandler.afterInsert(Trigger.new);   
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
     	HCUV_SalesTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.new);   
    }
}