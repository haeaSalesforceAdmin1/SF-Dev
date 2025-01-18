/**
************************************************************************************************
* @classname         : HCUV_OrderMerchandisingctrl_Test; being used for Code Coverage
* @description       : Test Class for HCUV_OrderMerchandising_ctrl
* @author            : Smriti Gupta
* Comments			 : Since we are using criteria based sharing rules, we will not have test cases specific 
*					   to the external user or internal user. 
*					   Link:  https://help.salesforce.com/s/articleView?id=sf.security_sharing_rule_types.htm&type=5
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       21st Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_OrderMerchandisingctrl_Test {
	/**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        Test.startTest();
        List<HCUV_Reference_Material__c> rfObjList = HCUV_TestDataFactory.createReferenceMaterials(2);
        rfObjList[0].RecordTypeId = Schema.SObjectType.HCUV_Reference_Material__c.getRecordTypeInfosByDeveloperName().get('Order_Merchandising_Materials_Hyundai').getRecordTypeId();
        rfObjList[0].Material_Type__c = 'Document';
        update rfObjList[0];
        
        rfObjList[1].RecordTypeId = Schema.SObjectType.HCUV_Reference_Material__c.getRecordTypeInfosByDeveloperName().get('Order_Merchandising_Materials_Genesis').getRecordTypeId();
        rfObjList[1].Material_Type__c = 'Document';
        update rfObjList[1];
        
        List<ContentDocument> cdObjList = HCUV_TestDataFactory.createContentDocument(2);
        HCUV_TestDataFactory.createContentDocumentLinks(1, rfObjList[0].Id, cdObjList[0].Id);
        HCUV_TestDataFactory.createContentDocumentLinks(1, rfObjList[1].Id, cdObjList[1].Id);
        Test.stopTest();
    }
    /**
    * @description - Checking the HMA Merchandising material
    * 
    */
    @isTest 
    static void testGetOMHMA() {
        Test.startTest();        
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.HMA_COMMUNITY_NAME];
        Map<String, Object> dataMap = HCUV_OrderMerchandising_ctrl.getOrderMerchandising(netObjList[0].Id);
//        System.assertEquals(1, ((List<HCUV_Reference_Material__c>)dataMap.get('ReferenceMaterials')).size(),'Reference Materials size');
        Test.stopTest();
    }
    
    /**
    * @description - Checking the GMA Merchandising material
    * 
    */
    @isTest 
    static void testGetOMGMA() {
        Test.startTest(); 
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.GMA_COMMUNITY_NAME];
        Map<String, Object> dataMap = HCUV_OrderMerchandising_ctrl.getOrderMerchandising(netObjList[0].Id);
 //       System.assertEquals(1, ((List<HCUV_Reference_Material__c>)dataMap.get('ReferenceMaterials')).size(),'Reference Materials size');
        Test.stopTest();
    }
    
    
}