/**
************************************************************************************************
* @classname         : HCUV_CommunityDashboardController_Test; being used for Code Coverage
* @description       : Test Class for HCUV_CommunityDashboardController
* @author            : Smriti Gupta
* History
* Version      Date                Author                Story/Bug         Modification
* 1.0       21st Sep 2023          Smriti Gupta                Initial Version
************************************************************************************************
**/
@IsTest
public class HCUV_CommunityDashboardController_Test {
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
        HCUV_TestDataFactory.createExternalUser(conRec.Id, 'TestF', 'TestL', HCUV_Constants.communityProfile);
        
        HCUV_Configuration_Settings__c hcSettings = new HCUV_Configuration_Settings__c(Name = 'Dashboard', HMA_CUV_External_ID__c	='Test', HMA_HSU_External_ID__c='Test', GMA_CPO_External_ID__c='Test',HOME_HMA_CUV_External_ID__c='Test',HOME_HMA_HSU_External_ID__c='Test');
        insert hcSettings;
                
        Test.stopTest();
    }
    
    /**
    * @description - checking Dashboard Info
    * 
    */
    @isTest
    static void testGetDashboardInfo(){
        Test.startTest();
        user user = [select Id from user where lastName = 'TestL'];
        system.Runas(user){
            HCUV_CommunityDashboardController.Wrapper wrp = new HCUV_CommunityDashboardController.Wrapper();
            wrp = HCUV_CommunityDashboardController.getDashboardInfo('CUV','');
            system.assert(wrp!=null, 'Checking not null');
        }
        Test.stopTest();
    }

     /**
    * @description - checking Dashboard Info
    * 
    */
    @isTest
    static void testHomePageDashboardInfo(){
        Test.startTest();
        user user = [select Id from user where lastName = 'TestL'];
        system.Runas(user){
            HCUV_CommunityDashboardController.Wrapper wrp = new HCUV_CommunityDashboardController.Wrapper();
            wrp = HCUV_CommunityDashboardController.getDashboardInfo('CUV','HOME');
            system.assert(wrp!=null, 'Checking not null');
        }
        Test.stopTest();
    }
    
}