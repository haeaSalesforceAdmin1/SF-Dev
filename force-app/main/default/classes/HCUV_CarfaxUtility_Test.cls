/**
************************************************************************************************
* @classname         : HCUV_CarfaxUtility_Test; being used for Code Coverage
* @description       : Test class for HCUV_CarfaxUtility, HCUV_CarFaxController
* @author            : Hemanth
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0          25 Sep 2023         Hemanth		         			      Initial Version
************************************************************************************************
**/
@IsTest
public with sharing class HCUV_CarfaxUtility_Test {
    
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        List<HCUV_Inventory__c> invObjList = HCUV_TestDataFactory.createInventories(2);
        invObjList[0].Inventory_Status__c = 'C1';
        invObjList[1].Inventory_Status__c = 'C13';
        update invObjList;
        
//        HCUV_TestDataFactory.createInternalUser('Internal_UserF', 'Internal_UserL', HCUV_Constants.internalProfile);
    }
    
    /**
    * @description - Checking CarFax URL
    * 
    */
    @isTest 
    static void testGetCarFaxURLValid() {
            List<HCUV_Inventory__c> invObjList = [Select Id from HCUV_Inventory__c WHERE Inventory_Status__c = 'C1'];
            
            Test.startTest();        
            String url = HCUV_CarFaxController.getCarFaxURL(invObjList[0].Id);
            System.assertNotEquals(null, url,'URL');
            Test.stopTest();
    }
    
    /**
    * @description - Checking CarFax Invalid URL
    * 
    */
    @isTest 
    static void testGetCarFaxURLInValid() {
            List<HCUV_Inventory__c> invObjList = [Select Id from HCUV_Inventory__c WHERE Inventory_Status__c = 'C13'];
            
            Test.startTest();    
            try{
                String url = HCUV_CarFaxController.getCarFaxURL(invObjList[0].Id);
                System.assertEquals(null, url,'URL');
            } catch(Exception ex) {
                System.assert(ex.getMessage() != null, 'Exception');
            }
            Test.stopTest();
    }
    
    /**
    * @description - Checking Access Token
    * 
    */
    @isTest
    static void testGetAccessToken() {
            
            HCUV_HTTPMockFactory mock = new HCUV_HTTPMockFactory(200, 'OK', '{"access_token":"your-access-token"}', new Map<String,String>());
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            String accessToken = HCUV_CarfaxUtility.getAccessToken();
            Test.stopTest();
            System.assertNotEquals(null, accessToken, 'Access Token');
    }

    /**
    * @description - Checking CarFax Vehicle History
    * 
    */
    @isTest
    static void testGetCarfaxVehicleHistory() {
            String vin = 'your-vin';
            
            HCUV_CarFaxVehicleHistoryWrapper wrapper = new HCUV_CarFaxVehicleHistoryWrapper();
            // Set the data property
            wrapper.data = new HCUV_CarFaxVehicleHistoryWrapper.DataClass();
            wrapper.data.icr = new HCUV_CarFaxVehicleHistoryWrapper.ICRClass();
            wrapper.data.icr.carFaxLink = new HCUV_CarFaxVehicleHistoryWrapper.CarFaxLinkClass();
            wrapper.data.icr.carFaxLink.expiresAt = new HCUV_CarFaxVehicleHistoryWrapper.ExpiresAtClass();
            wrapper.data.icr.ownerHistory = new HCUV_CarFaxVehicleHistoryWrapper.OwnerHistoryClass();
            wrapper.data.icr.carFaxLink.url = 'https://www.carfax.com/vehiclehistory/report.pdf?vin=1234567890';
            wrapper.data.icr.carFaxLink.iconUrl = 'https://www.carfax.com/images/carfax-icon.png';
            wrapper.data.icr.carFaxLink.valueBadgeAltText = 'CarFax Report';
            wrapper.data.icr.carFaxLink.expiresAt.rfc = '2023-06-15T00:00:00Z';
            wrapper.data.icr.ownerHistory.oneOwner = true;
            
            String respo = JSON.serialize(wrapper);
            
            HCUV_HTTPMockFactory mock = new HCUV_HTTPMockFactory(200, 'OK', respo, new Map<String,String>());
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            // Call getCarfaxVehicleHistory()
            String vinHistoryLink = HCUV_CarfaxUtility.getCarfaxVehicalHistory(vin);
            Test.stopTest();
            // Assert that the vinHistoryLink is not null
            System.assertNotEquals(null, vinHistoryLink, 'Link');
    }
}