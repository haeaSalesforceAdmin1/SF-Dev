/**
************************************************************************************************
* @classname         : HCUV_InventoryRetailMileageBatch_Test; being used for Code Coverage
* @description       : Test class for HCUV_InventoryRetailMileageBatch
* @author            : Smriti
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0          10 Oct 2023         Smriti		         			      Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_InventoryRetailMileageBatch_Test {
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        List<Account> objAccount = HCUV_TestDataFactory.createAccounts(1);
        List<HCUV_Inventory__c> objList = HCUV_TestDataFactory.createInventories(1);
        objList[0].Dealer_Code__c = objAccount[0].DealerCode__c;
        update objList;
    }
    
    /**
    * @description - Test Method to test Retail Mileage
    * 
    */
    @isTest 
    static void testRetailMileage() {
        List<HCUV_Inventory__c> invList = [Select Dealer_Code__c From HCUV_Inventory__c];
            Test.startTest();
            HCUV_Sales__c salesObj = new HCUV_Sales__c();
            salesObj.Inventory__c = invList[0].Id;
            salesObj.Dealer_Code__c = invList[0].Dealer_Code__c;
            salesObj.Record_Type__c= HCUV_Constants.SalesRecTypeRDR;
            insert salesObj;
            
            HCUV_InventoryRetailMileageBatch invBatch = new HCUV_InventoryRetailMileageBatch();
            DataBase.executeBatch(invBatch); 
            system.assertEquals(1, [Select count() From HCUV_Inventory__c], 'count should be one.');
            Test.stopTest();
    }
}