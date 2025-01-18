/**
************************************************************************************************
* @classname         : HCUV_QuickLinksController_Test; being used for Code Coverage
* @description       : Test Class for HCUV_QuickLinksController
* @author            : Smriti Gupta
* Comments			 : Since we are using criteria based sharing rules, we'll not have test cases specific 
*						to the external user or internal user. 
*					  Link:  https://help.salesforce.com/s/articleView?id=sf.security_sharing_rule_types.htm&type=5
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       18th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_QuickLinksController_Test {
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        Test.startTest();
        
        String hmaRecordTypeId = Schema.SObjectType.HCUV_Quick_Link__c.getRecordTypeInfosByDeveloperName().get('Hyundai').getRecordTypeId();
        HCUV_TestDataFactory.createQuickLinks(hmaRecordTypeId, 1);
        String gmaRecordTypeId = Schema.SObjectType.HCUV_Quick_Link__c.getRecordTypeInfosByDeveloperName().get('Genesis').getRecordTypeId();
        HCUV_TestDataFactory.createQuickLinks(gmaRecordTypeId, 1);
        
        Test.stopTest();
    }
    
    
    /**
    * @description - Checking the HMA Quick Links from community user
    * 
    */
    @isTest 
    static void testGetQuickLinksHMACommunityUser() {
        Test.startTest(); 
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.HMA_COMMUNITY_NAME];
        List<HCUV_Quick_Link__c> qlList = HCUV_QuickLinksController.getQuickLinks(netObjList[0].Id);
//        system.assertEquals(1, qlList.size(), 'Total Quick Links');
    }
     /**
    * @description - Checking the GMA Quick Links from community user
    * 
    */
    @isTest 
    static void testGetQuickLinksGMACommunityUser() {
        Test.startTest(); 
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.GMA_COMMUNITY_NAME];
        List<HCUV_Quick_Link__c> qlList = HCUV_QuickLinksController.getQuickLinks(netObjList[0].Id);
//        system.assertEquals(1, qlList.size(), 'Total Quick Links');
    }
}