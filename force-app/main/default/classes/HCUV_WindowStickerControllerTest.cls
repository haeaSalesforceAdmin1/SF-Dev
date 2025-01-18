/**
************************************************************************************************
* @classname         : HCUV_WindowStickerControllerTest; being used for Code Coverage
* @description       : Test class for HCUV_WindowStickerController
* @author            : Hemanth
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0          24 Sep 2023         Hemanth		         			      Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_WindowStickerControllerTest {
    
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        List<HCUV_Inventory__c> invObjList = HCUV_TestDataFactory.createInventories(2);
        invObjList[0].Inventory_Status__c = 'C1';
        update invObjList;
        
//        HCUV_TestDataFactory.createInternalUser('Internal_UserF', 'Internal_UserL', HCUV_Constants.internalProfile);
    }
    
    /**
    * @description - Checking Window Sticker URL
    * 
    */
    @isTest 
    static void testGetWindowSticker() {
            Test.startTest();
            List<HCUV_Inventory__c> invObjList = [SELECT Id FROM HCUV_Inventory__c WHERE Inventory_Status__c = 'C1'];
            
            String url = HCUV_WindowStickerController.getWindowSticker(invObjList[0].Id);
            System.assertNotEquals(null, url, 'URL');
            Test.stopTest();
    }
    
    /**
    * @description - Checking Window Sticker Invalid URL
    * 
    */
    @isTest 
    static void testGetWindowStickerInvalid() {
            Test.startTest();
            List<HCUV_Inventory__c> invObjList = [SELECT Id FROM HCUV_Inventory__c WHERE Inventory_Status__c != 'C1'];
            try{
                String url = HCUV_WindowStickerController.getWindowSticker(invObjList[0].Id);
                System.assertEquals(null, url, 'URL');
            } catch(AuraHandledException ex) {
                System.assert(ex.getMessage() != null, 'Exception');
            }
            Test.stopTest();
    }
    
}