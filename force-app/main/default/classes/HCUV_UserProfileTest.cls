/**
************************************************************************************************
* @classname         : HCUV_UserProfileTest; being used for Code Coverage
* @description       : Test Class for HCUV_UserProfile
* @author            : Smriti Gupta
* History
* Version      Date                Author                Story/Bug         Modification
* 1.0       17th Aug 2023          Smriti Gupta          Story HVM-218      Initial Version
************************************************************************************************
**/
@isTest
public with sharing class HCUV_UserProfileTest  {
    
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void testData(){
        Test.startTest();
        Organization__c nationalOrg = new Organization__c(Name = 'National');
        insert nationalOrg;
        
        List<Organization__c> organizations = new List<Organization__c>();
        Organization__c org1 = new Organization__c(Name = 'Hyundai', ParentOrganization__c = nationalOrg.Id);
        organizations.add(org1);
        Organization__c org2 = new Organization__c(Name = 'Genesis', BrandCode__c = 'G', ParentOrganization__c = nationalOrg.Id);
        organizations.add(org2);
        insert organizations;
        
        List<Region__c> regions = new List<Region__c>();
        Region__c reg1 = new Region__c(Name = 'SOUTHERN REGION', Organization__c = org1.Id, RegionCode__c = 'SO');
        regions.add(reg1);
        Region__c reg2 = new Region__c(Name = 'CENTRAL REGION', Organization__c = org2.Id, RegionCode__c = 'CE');
        regions.add(reg2);
        insert regions;
        
        List<District__c> district = new List<District__c>();
        District__c dis1 = new District__c(Name = 'ATLANTA', Region__c = reg1.Id, Organization__c = reg1.Organization__c, DistrictCode__c = 'GS1', SalesManager__c = UserInfo.getUserId(), DistrictPartsServiceManager__c = UserInfo.getUserId());
        district.add(dis1);
        District__c dis2 = new District__c(Name = 'NO CHICAGO', Region__c = reg2.Id, Organization__c = reg2.Organization__c, DistrictCode__c = 'CE1', SalesManager__c = UserInfo.getUserId(), DistrictPartsServiceManager__c = UserInfo.getUserId());
        district.add(dis2);
        insert district;    
        
        //Get Account Record Type Id
        Id hynAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HyundaiDealer').getRecordTypeId();
        Id genAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GenesisRetailer').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(Name = 'Test Account1', ServiceDistrict__c = dis1.Id, SalesDistrict__c = dis1.Id, Region__c = dis1.Region__c, Organization__c =dis1.Organization__c, DealerCode__c = 'A0001', Active__c = true, RecordTypeId = hynAccRecordTypeId);
        accList.add(acc1);
        Account acc2 = new Account(Name = 'Test Account2', ServiceDistrict__c = dis2.Id, SalesDistrict__c = dis2.Id, Region__c = dis2.Region__c, Organization__c = dis2.Organization__c, DealerCode__c = 'OH071', Active__c = true, RecordTypeId = genAccRecordTypeId);
        accList.add(acc2);
        Insert accList;
        
        Contact conRec = new Contact(AccountId = acc1.Id, LastName = 'TestL', FirstName = 'TestF', Email='testH@email.com');
        insert conRec;
//        HCUV_TestDataFactory.createExternalUser(conRec.Id, 'Community_TestF', 'Community_TestL', HCUV_Constants.communityProfile);
        Test.stopTest();
        
    }
    /**
    * @description - Checking for Primary Account
    * 
    */
    @isTest static void testgetAccountDetail1() {
        Test.startTest();
            Account resAccRec = HCUV_UserProfile.getAccountDetail(); 
            system.assertEquals('Test Account1', resAccRec.Name, 'Checking account name');
        Test.stopTest();
    }
    
    /**
    * @description - Checking with primary and secondary account
    * 
    */
    @isTest static void testgetAccountDetail2() {
        Test.startTest();
        AccountContactRelation acrRec = new AccountContactRelation();
     //   acrRec.AccountId = [Select Id From Account where Name= 'Test Account2'].Id;
     //   acrRec.ContactId = user.ContactId;
     //   insert acrRec;
            Account accRec = HCUV_UserProfile.getAccountDetail(); 
            system.assertEquals('Test Account1', accRec.Name, 'Checking account name');
        Test.stopTest();
    }
    /**
    * @description - Checking HMA DPM Site URL 
    * 
    */
    @isTest static void testgetDPMSiteURLHMA() {
        Test.startTest();
          List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.HMA_COMMUNITY_NAME];
          HCUV_UserProfile.getDPMSiteURL(netObjList[0].Id);
          String result= HCUV_UserProfile.getDPMSiteURL(netObjList[0].Id);
          system.assertEquals(true, result.contains(System.label.HCUV_DPM_Hyundai), 'Checking Response...');
        Test.stopTest();
    }
    
    /**
    * @description - Checking GMA DPM Site URL 
    * 
    */
    @isTest static void testgetDPMSiteURLGMA() {
        Test.startTest();
          List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.GMA_COMMUNITY_NAME];
          HCUV_UserProfile.getDPMSiteURL(netObjList[0].Id);
          String result= HCUV_UserProfile.getDPMSiteURL(netObjList[0].Id);
          system.assertEquals(true, result.contains(System.label.HCUV_DPM_Genesis), 'Checking Response...');
        Test.stopTest();
    }
    
    
}