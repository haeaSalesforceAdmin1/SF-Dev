/**
************************************************************************************************
* @classname         : HCUV_ContestsIncentivesDataCtrl_Test; being used for Code Coverage
* @description       : Test Class for HCUV_InventoryQAController
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       24th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_InventoryQAController_Test {
    // create test data
    @testSetup static void setup() {
        Test.startTest();
        Organization__c nationalOrg = new Organization__c(Name = 'National');
        insert nationalOrg;
        
        Organization__c org = new Organization__c(Name = 'Hyundai', ParentOrganization__c = nationalOrg.Id);
        insert org;
        
        Region__c reg = new Region__c(Name = 'SOUTHERN REGION', Organization__c = org.Id, RegionCode__c = 'SO');
        insert reg;
        
        District__c dis = new District__c(Name = 'ATLANTA', Region__c = reg.Id, Organization__c = reg.Organization__c, DistrictCode__c = 'CE1', SalesManager__c = UserInfo.getUserId(), DistrictPartsServiceManager__c = UserInfo.getUserId());
        insert dis;    
        
        //Get Account Record Type Id
        Id hynAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HyundaiDealer').getRecordTypeId();
        
        Account accRec = new Account(Name = 'Hyundai Test Account', ServiceDistrict__c = dis.Id, SalesDistrict__c = dis.Id, Region__c = dis.Region__c, Organization__c =dis.Organization__c, DealerCode__c = 'A0001', Active__c = true, RecordTypeId = hynAccRecordTypeId);
        Insert accRec;
        
        Contact conRec = new Contact(AccountId = accRec.Id, LastName = 'TestL', FirstName = 'TestF', Email='testH@email.com');
        insert conRec;
        HCUV_TestDataFactory.createExternalUser(conRec.Id, 'TestF', 'TestL', HCUV_Constants.communityProfile);
       
        List<HCUV_Inventory__c> invObjList = HCUV_TestDataFactory.createInventories(1);
        invObjList[0].Dealer__c = accRec.Id;
        invObjList[0].Inventory_Status__c = 'C1';
        update invObjList;
        Test.stopTest();
    }
    
    /**
    * @description - checking for HMA
    * 
    */
    @isTest
    static void testGetInventoryDetailHMA(){
        Test.startTest();
        HCUV_Inventory__c invRec= [Select Id from HCUV_Inventory__c limit 1];
	HCUV_Inventory__c rec = HCUV_InventoryQAController.getInventoryDetail('' + invRec.Id);
  //      System.assertEquals(true, , 'checking the inventory data' );
        Test.stopTest();
    }
    
}