@isTest
public class HCUV_CarFaxControllerTest {
    // create test data
    @testSetup static void setup() {
        List<HCUV_Inventory__c> invObjList = HCUV_TestDataFactory.createInventories(2);
        invObjList[0].Inventory_Status__c = 'C1';
        invObjList[1].Inventory_Status__c = 'C13';
        update invObjList;
    }
    
    @isTest 
    static void testGetCarFaxURLValid() {
        List<HCUV_Inventory__c> invObjList = [Select Id from HCUV_Inventory__c WHERE Inventory_Status__c = 'C1'];

        Test.startTest();        
        HCUV_CarFaxController.getCarFaxURL(invObjList[0].Id);
        Test.stopTest();
    }
    
    @isTest 
    static void testGetCarFaxURLInValid() {
        List<HCUV_Inventory__c> invObjList = [Select Id from HCUV_Inventory__c WHERE Inventory_Status__c = 'C13'];

        Test.startTest();    
        try{
        	HCUV_CarFaxController.getCarFaxURL(invObjList[0].Id);
        } catch(Exception ex) {
            
        }
        Test.stopTest();
    }
    
}