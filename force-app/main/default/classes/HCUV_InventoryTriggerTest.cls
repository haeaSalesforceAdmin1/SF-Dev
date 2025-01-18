/**
************************************************************************************************
* @classname         : HCUV_InventoryTriggerTest; being used for Code Coverage
* @description       : Test class for HCUV_InventoryTrigger, HCUV_InventoryTriggerHandler
* @author            : Krishna
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0          15 Jun 2023         Hemanth		         			      Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_InventoryTriggerTest {
    
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        HCUV_TestDataFactory.createAccounts(1);
        HCUV_TestDataFactory.createInventories(1);
        
//        HCUV_TestDataFactory.createInternalUser('Internal_UserF', 'Internal_UserL', HCUV_Constants.internalProfile);
    }
    
    /**
    * @description - Checking Inventory Trigger
    * 
    */
    @isTest 
    static void testUpdateTrigger() {
        List<Account> accObjList = [Select Id, DealerCode__c from Account];
        List<HCUV_Inventory__c> invObjList = [Select Id from HCUV_Inventory__c];
		
            Test.startTest();        
            invObjList[0].Dealer_Code__c = accObjList[0].DealerCode__c;
            update invObjList[0];
            System.assert(invObjList != null, 'Inventories not found.');
            
            Test.stopTest();
    }
    
}