/**
************************************************************************************************
* @classname         : HCUV_Utility_Test; being used for Code Coverage
* @description       : Test Class for HCUV_Utility
* @author            : Smriti Gupta
* History
* Version      Date                Author                Story/Bug         Modification
* 1.0       17th Aug 2023          Smriti Gupta          Story HVM-218      Initial Version
************************************************************************************************
**/
@IsTest
public class HCUV_Utility_Test {
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
        Test.stopTest();
    }
    
    /**
    * @description - checking icons from custom data
    * 
    */
    @isTest
    static void testgetIconDetailsHMA() {
        Test.startTest();
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.HMA_COMMUNITY_NAME];
        user user = [select Id from user where lastName = 'TestL'];
        system.Runas(user){
            List<String> communityDetails = HCUV_Utility.getIconDetails(netObjList[0].Id);
            System.assertEquals(true, communityDetails.size()>0, 'checking the community metadata size' );
        }
        Test.stopTest();
    }
    
    
    /**
    * @description - checking the set account id
    * 
    */
    
    @isTest
    static void testSetUserAccountId() {
        Test.startTest();
        user user = [select Id, Contact.AccountId from user where lastName = 'TestL'];
        system.Runas(user){
            boolean res = HCUV_Utility.setUserAccountId(user.Contact.AccountId);
//            system.assertEquals(true, res, 'set the selected account id');
        }
        Test.stopTest();
    }

    /**
    * @description - gettingAccountId 
    *
    */
    @isTest
    static void testGetAccountId () {
	HCUV_Utility.getAccountId();
    }

    /**
    * @description - gettingAccountId 
    *
    */
    @isTest
    static void testGetCommunityName () {
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.HMA_COMMUNITY_NAME];
	String communityName = HCUV_Utility.getCommunityName('' + netObjList[0].Id);
	System.assertEquals (HCUV_Constants.HMA_COMMUNITY_NAME, communityName, 'Names do not match');
    }

    /**
    * @description - gettingDealerCodes 
    *
    */
    @isTest
    static void testGetMultipleDealerCodes () {
    	Set<String> dealerCodeSet = new Set<String>();
	dealerCodeSet.add('A001');
	HCUV_Utility.getDealerAccountsUsingDealerCodes(dealerCodeSet);
    }
    
}