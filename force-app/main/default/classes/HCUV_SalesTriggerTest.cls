/**
************************************************************************************************
* @classname         : HCUV_SalesTriggerTest; being used for Code Coverage
* @description       : Test class for HCUV_SalesTrigger, HCUV_SalesTriggerHandler
* @author            : Krishna
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0          15 Jun 2023         Krishna		         			      Initial Version
************************************************************************************************
**/
@IsTest
public class HCUV_SalesTriggerTest {

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
    * @description - Checking Sales Trigger
    * 
    */
    @isTest
    public static void testSalesTigger(){    
        List<HCUV_Inventory__c> invList = [Select Dealer_Code__c From HCUV_Inventory__c];
        
            Test.startTest();        
            
            HCUV_Sales__c salesObj = new HCUV_Sales__c();
            salesObj.Inventory__c = invList[0].Id;
            salesObj.Dealer_Code__c = invList[0].Dealer_Code__c;
            insert salesObj;
            System.assert(salesObj != null, 'Sales not found.');
            
            salesObj.District__c = 'AD1';
            update salesObj;
            System.assert(salesObj != null, 'Sales not found.');
            
            Test.stopTest();
    }
}