/**
************************************************************************************************
* @classname         : HCUV_ContestsIncentivesDataCtrl_Test; being used for Code Coverage
* @description       : Test Class for HCUV_InspectionChecklistCtrl
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       24th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_InspectionChecklistCtrl_Test {
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void testData(){
        Test.startTest();
        Organization__c nationalOrg = new Organization__c(Name = 'National');
        insert nationalOrg;
        
        Organization__c org = new Organization__c(Name = 'Hyundai', ParentOrganization__c = nationalOrg.Id);
        insert org;
        
        Region__c reg = new Region__c(Name = 'SOUTHERN REGION', Organization__c = org.Id, RegionCode__c = 'SO');
        insert reg;
        
        District__c dis = new District__c(Name = 'ATLANTA', Region__c = reg.Id, Organization__c = reg.Organization__c, DistrictCode__c = 'GS1', SalesManager__c = UserInfo.getUserId(), DistrictPartsServiceManager__c = UserInfo.getUserId());
        insert dis;    
        
        //Get Account Record Type Id
        Id hynAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HyundaiDealer').getRecordTypeId();
        
        Account accRec = new Account(Name = 'Hyundai Test Account', ServiceDistrict__c = dis.Id, SalesDistrict__c = dis.Id, Region__c = dis.Region__c, Organization__c =dis.Organization__c, DealerCode__c = 'A0001', Active__c = true, RecordTypeId = hynAccRecordTypeId);
        Insert accRec;
        
        Contact conRec = new Contact(AccountId = accRec.Id, LastName = 'TestL', FirstName = 'TestF', Email='testH@email.com');
        insert conRec;
//        HCUV_TestDataFactory.createExternalUser(conRec.Id, 'TestF', 'TestL', HCUV_Constants.communityProfile);
        
        List<HCUV_Inventory__c> invObjList = HCUV_TestDataFactory.createInventories(1);
        invObjList[0].Dealer__c = accRec.Id;
        invObjList[0].Dealer_Code__c = 'IL051';
        invObjList[0].Inventory_Status__c = 'C1';
        update invObjList;
        
        Test.stopTest();
    }
    
    /**
    * @description - Checking the Inspection Checklist URL
    * 
    */
    @isTest
    static void testGetInspectionChecklistURL(){
        Test.startTest();
        List<HCUV_Inventory__c> invList= [Select Id from HCUV_Inventory__c limit 1];
        Test.setMock(HttpCalloutMock.class, new HCUV_InspectionChecklistMockup());
        String result = HCUV_InspectionChecklistCtrl.getInspectionChecklistURL(invList[0].Id, 'https://test.com');
        system.assertEquals(true, String.isNotBlank(result), 'Checking return value');
                   
        Test.stopTest();
    }
    /**
    * @description - Checking the Inspection Checklist URL
    * 
    */
    @isTest
    static void testGetInspectionQAGMA(){
        Id gynAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GenesisRetailer').getRecordTypeId();
        Account accRec = [Select Id, RecordTypeId from Account limit 1];  
        accRec.RecordTypeId=gynAccRecordTypeId;
        update accRec;
        Test.startTest();
        List<HCUV_Inventory__c> invList= [Select Id from HCUV_Inventory__c limit 1];
        Test.setMock(HttpCalloutMock.class, new HCUV_InspectionChecklistMockup());
        String result = HCUV_InspectionChecklistCtrl.getInspectionChecklistQA(invList[0].Id, 'https://test.com');
        system.assertEquals(true, String.isNotBlank(result), 'Checking return value');
        Test.stopTest();
    }
    
    /**
    * @description - Checking the GMA Inspection Checklist
    * 
    */
    @isTest
    static void testGetInspectionQAHMA(){
        HCUV_Inventory__c invRec= [Select Id, Dealer__c from HCUV_Inventory__c limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HCUV_InspectionChecklistMockup());
        String result = HCUV_InspectionChecklistCtrl.getInspectionChecklistQA(invRec.Id, 'https://test.com');
        system.assertEquals(true, String.isNotBlank(result), 'Checking return value');
        Test.stopTest();
    }
    
    /**
    * @description - Checking the GMA Inspection Checklist
    * 
    */
    @isTest
    static void testGetInspectionError(){
        HCUV_Inventory__c invRec= [Select Id, Inventory_Status__c from HCUV_Inventory__c limit 1];
        invRec.Inventory_Status__c = 'C2';
        update invRec;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HCUV_InspectionChecklistMockup());
        try{
            HCUV_InspectionChecklistCtrl.getInspectionChecklistQA(invRec.Id, 'https://test.com');
        }
        Catch(Exception ex){
            system.assert(String.isNotBlank(ex.getMessage()), 'Checking Error');
        }
        
        Test.stopTest();
    }
}