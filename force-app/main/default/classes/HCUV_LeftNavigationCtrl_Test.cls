/**
************************************************************************************************
* @classname         : HCUV_LeftNavigationCtrl_Test; being used for Code Coverage
* @description       : Test class for HCUV_LeftNavigationController
* @author            : Kishore
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0          23 May 2023         Kishore		         			      Initial Version
************************************************************************************************
**/
@isTest
public with sharing class HCUV_LeftNavigationCtrl_Test {
    
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        List<Account> accObjList = HCUV_TestDataFactory.createAccounts(1);
        HCUV_TestDataFactory.createContacts(1, accObjList[0].Id);
        
        List<HCUV_Inventory__c> invObjList = HCUV_TestDataFactory.createInventories(6);
        invObjList[0].Dealer__c = accObjList[0].Id;
        invObjList[0].Inventory_Status__c = 'C1';
        invObjList[1].Dealer__c = accObjList[0].Id;
        invObjList[1].Inventory_Status__c = 'C95';
        invObjList[2].Dealer__c = accObjList[0].Id;
        invObjList[2].Inventory_Status__c = 'CNW';
        invObjList[3].Dealer__c = accObjList[0].Id;
        invObjList[3].Inventory_Status__c = 'C93';
        invObjList[4].Dealer__c = accObjList[0].Id;
        invObjList[4].Inventory_Status__c = 'SRC';
        invObjList[5].Dealer__c = accObjList[0].Id;
        invObjList[5].Inventory_Status__c = 'C13';
        update invObjList;
        
//        HCUV_TestDataFactory.createInternalUser('Internal_UserF', 'Internal_UserL', HCUV_Constants.internalProfile);
    }
    
    /**
    * @description - Checking Left Navigation Menus
    * 
    */
    @isTest
    static void testGetMenu() {
            test.startTest();
            List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.HMA_COMMUNITY_NAME];
            
            Map<String,sobject> subdata = HCUV_LeftNavigationController.GetMenus();
            System.assert(subdata.size() > 0, 'Menus no found.');
            
            List<HCUV_LeftNavigationController.Navigation> navItems = HCUV_LeftNavigationController.GetMenu(netObjList[0].Id);
//            System.assert(navItems.size() > 0, 'Menus no found.');
            
            test.stopTest();
    }
    
}