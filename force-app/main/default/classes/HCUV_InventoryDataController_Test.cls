/**
************************************************************************************************
* @classname         : HCUV_InventoryDataController_Test; being used for Code Coverage
* @description       : Test class for HCUV_InventoryDataController
* @author            : Hemanth
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0          19 Jun 2023         Hemanth		         			      Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_InventoryDataController_Test implements HttpCalloutMock {
    
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        List<Account> accObjList = HCUV_TestDataFactory.createAccounts(1);
        List<Contact> conObjList = HCUV_TestDataFactory.createContacts(1, accObjList[0].Id);
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
        
//        HCUV_TestDataFactory.createExternalUser(conObjList[0].Id, 'Community_UserF', 'Community_UserL', HCUV_Constants.communityProfile);
//        HCUV_TestDataFactory.createInternalUser('Internal_UserF', 'Internal_UserL', HCUV_Constants.internalProfile);
    }
    
    /**
    * @description - Checking Inventories for Community user
    * 
    */
    @isTest 
    static void testGetInventoriesExternalC1() {
        Test.setMock(HttpCalloutMock.class, new HCUV_InventoryDataController_Test()); 
        
            Test.startTest();        
            Map<String, Object> dataMap = HCUV_InventoryDataCtrl.getInventories('Active Inventory', 'CUV', Network.getNetworkId());
            List<HCUV_Inventory__c> invObjList = (List<HCUV_Inventory__c>)dataMap.get('Inventories');
            System.assertEquals(1, invObjList.size(), 'Inventories not found!');
            System.assertNotEquals(null, dataMap.get('FieldMap'), 'FieldMap is null!');
            System.assertNotEquals(null, dataMap.get('SubMenus'), 'SubMenus are null!');
            Test.stopTest();   
    }
    
    /**
    * @description - Checking Inventories for Community user
    * 
    */
    @isTest 
    static void testGetInventoriesExternalC95() {
        Test.setMock(HttpCalloutMock.class, new HCUV_InventoryDataController_Test()); 
        
            Test.startTest();        
            Map<String, Object> dataMap = HCUV_InventoryDataCtrl.getInventories('Vehicles With Open Recalls', 'CUV', Network.getNetworkId());
            List<HCUV_Inventory__c> invObjList = (List<HCUV_Inventory__c>)dataMap.get('Inventories');
            System.assertEquals(1, invObjList.size(), 'Inventories not found!');
            System.assertNotEquals(null, dataMap.get('FieldMap'), 'FieldMap is null!');
            System.assertNotEquals(null, dataMap.get('SubMenus'), 'SubMenus are null!');
            Test.stopTest();   
    }
    
    /**
    * @description - Checking Inventories for Community user
    * 
    */
    @isTest 
    static void testGetInventoriesExternalCNW() {
        Test.setMock(HttpCalloutMock.class, new HCUV_InventoryDataController_Test()); 
        
            Test.startTest();        
            Map<String, Object> dataMap = HCUV_InventoryDataCtrl.getInventories('Branded Title Decertified Vehicles', 'CUV', Network.getNetworkId());
            List<HCUV_Inventory__c> invObjList = (List<HCUV_Inventory__c>)dataMap.get('Inventories');
            System.assertEquals(1, invObjList.size(), 'Inventories not found!');
            System.assertNotEquals(null, dataMap.get('FieldMap'), 'FieldMap is null!');
            System.assertNotEquals(null, dataMap.get('SubMenus'), 'SubMenus are null!');
            Test.stopTest();   
    }
    
    /**
    * @description - Checking Inventories for Community user
    * 
    */
    @isTest 
    static void testGetInventoriesExternalC93() {
        Test.setMock(HttpCalloutMock.class, new HCUV_InventoryDataController_Test()); 
        
            Test.startTest();        
            Map<String, Object> dataMap = HCUV_InventoryDataCtrl.getInventories('CARFAX Decertified Vehicles', 'CUV', Network.getNetworkId());
            List<HCUV_Inventory__c> invObjList = (List<HCUV_Inventory__c>)dataMap.get('Inventories');
            System.assertEquals(1, invObjList.size(), 'Inventories not found!');
            System.assertNotEquals(null, dataMap.get('FieldMap'), 'FieldMap is null!');
            System.assertNotEquals(null, dataMap.get('SubMenus'), 'SubMenus are null!');
            Test.stopTest();   
    }
    
    /**
    * @description - Checking Inventories for Community user
    * 
    */
    @isTest 
    static void testGetInventoriesExternalSRC() {
        Test.setMock(HttpCalloutMock.class, new HCUV_InventoryDataController_Test()); 
        
            Test.startTest();        
            Map<String, Object> dataMap = HCUV_InventoryDataCtrl.getInventories('SRCs Pending Removal', 'CUV', Network.getNetworkId());
            List<HCUV_Inventory__c> invObjList = (List<HCUV_Inventory__c>)dataMap.get('Inventories');
            System.assertEquals(1, invObjList.size(), 'Inventories not found!');
            System.assertNotEquals(null, dataMap.get('FieldMap'), 'FieldMap is null!');
            System.assertNotEquals(null, dataMap.get('SubMenus'), 'SubMenus are null!');
            Test.stopTest();   
    }
    
    /**
    * @description - Checking Inventories for Community user
    * 
    */
    @isTest 
    static void testGetInventoriesExternalC13() {
        Test.setMock(HttpCalloutMock.class, new HCUV_InventoryDataController_Test()); 
        
            Test.startTest();        
            Map<String, Object> dataMap = HCUV_InventoryDataCtrl.getInventories('Dealer Removed Inventory', 'CUV', Network.getNetworkId());
            List<HCUV_Inventory__c> invObjList = (List<HCUV_Inventory__c>)dataMap.get('Inventories');
            System.assertEquals(1, invObjList.size(), 'Inventories not found!');
            System.assertNotEquals(null, dataMap.get('FieldMap'), 'FieldMap is null!');
            System.assertNotEquals(null, dataMap.get('SubMenus'), 'SubMenus are null!');
            Test.stopTest();   
    }
    
    /**
    * @description - Checking Inventories for Internal user
    * 
    */
    @isTest 
    static void testGetInventoriesInternal() {
        Test.setMock(HttpCalloutMock.class, new HCUV_InventoryDataController_Test()); 
        
            Test.startTest();        
            Map<String, Object> dataMap = HCUV_InventoryDataCtrl.getInventories('Active Inventory', 'CUV', Network.getNetworkId());
            List<HCUV_Inventory__c> invObjList = (List<HCUV_Inventory__c>)dataMap.get('Inventories');
            System.assertEquals(1, invObjList.size(), 'Inventories not found!');
            System.assertNotEquals(null, dataMap.get('FieldMap'), 'FieldMap is null!');
            System.assertNotEquals(null, dataMap.get('SubMenus'), 'SubMenus are null!');
            Test.stopTest();   
    }
    
    /**
    * @description - Checking Inventories Negative scenarios
    * 
    */
    @isTest 
    static void testGetInventoriesNegative() {
            Test.startTest();        
            Map<String, Object> dataMap = HCUV_InventoryDataCtrl.getInventories('Test', '', Network.getNetworkId());
            List<HCUV_Inventory__c> invObjList = (List<HCUV_Inventory__c>)dataMap.get('Inventories');
            System.assertEquals(null, invObjList, 'Inventories found!');
            System.assertEquals(null, dataMap.get('FieldMap'), 'FieldMap is not null!');
            System.assertNotEquals(null, dataMap.get('SubMenus'), 'SubMenus are not null!');
            Test.stopTest();
    }
    
    /**
    * @description - Return dummy response
    * @param - HTTPRequest
    * @return HTTPResponse
    */
    public HTTPResponse respond(HTTPRequest request) {
        String endPoint = request.getEndpoint();
        endPoint = endPoint.replace('/describe', '');
        endPoint = endPoint.substringAfterLast('/');
        //System.debug('endPoint = ' +endPoint);
        
        List<ListView> lvObjList = [SELECT Id, Name, DeveloperName, SobjectType FROM ListView
                                    WHERE Id = :endPoint];
        
        String whereClause = ' WHERE Inventory_Status__c = ';
        if(lvObjList[0].DeveloperName == 'Active_Inventory_CUV') {
         	whereClause += ' \'C1\' ';   
        }
        else if(lvObjList[0].DeveloperName == 'Vehicles_With_Open_Recalls_CUV') {
            whereClause += ' \'C95\' ';
        }
        else if(lvObjList[0].DeveloperName == 'Decertified_Branded_Title_CUV') {
            whereClause += ' \'CNW\' ';
        }
        else if(lvObjList[0].DeveloperName == 'Decertified_Carfax_CUV') {
            whereClause += ' \'C93\' ';
        }
        else if(lvObjList[0].DeveloperName == 'SRC_Pending_Removal_CUV') {
            whereClause += ' \'SRC\' ';
        }
        else if(lvObjList[0].DeveloperName == 'Dealer_Removed_Inventory_CUV') {
            whereClause += ' \'C13\' ';
        }
        
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"query": "SELECT Id FROM HCUV_Inventory__c ' + whereClause + '", "columns": [{"label": "VIN", "fieldNameOrPath": "Name", "hidden": false}]}');
        response.setStatusCode(200);
        return response; 
    }
    
}