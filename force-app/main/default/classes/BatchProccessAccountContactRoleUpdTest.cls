@isTest
public with sharing class BatchProccessAccountContactRoleUpdTest {

    @TestSetup
    static void makeData(){
        User user1 = TestUtility.createInternalUser('TestOwnerUser1', 'TestOwnerUser1', 'System Administrator');
        User user2 = TestUtility.createInternalUser('TestOwnerUser2', 'TestOwnerUser2', 'System Administrator');
        User user3 = TestUtility.createInternalUser('TestOwnerUser3', 'TestOwnerUser3', 'System Administrator');
        User user4 = TestUtility.createInternalUser('TestOwnerUser4', 'TestOwnerUser4', 'System Administrator');
    
        TestUtility.createCurrentEnvironmentCustomSetting();
        TestUtility.createDPMConfigurationSettings();
        TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');
    
        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();
    
        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genesisOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);
    
        Account accountHyundai = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');
        accountHyundai.DistrictPartsServiceManager__c = user1.Id;
        accountHyundai.DistrictPartsServiceManager__c = user2.Id;
        accountHyundai.MarketManager__c = user3.Id;
        update accountHyundai;

        Account accountGen = TestUtility.createAccountForDistrictRegionOrg('Test Gen Account', TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.GENESIS_ORG, 'A0002');
        accountGen.DistrictPartsServiceManager__c = user1.Id;
        accountGen.DistrictPartsServiceManager__c = user2.Id;
        accountGen.MarketManager__c = user3.Id;
        update accountGen;
    }

    static testMethod void testAccountContactRelationships() {
        
        List<Account> accounts = [select Id, GeneralManager__c, DealerPrincipal__c from Account];
    
        Contact contact = new Contact(FirstName = 'First Name', LastName = 'LastName', AccountId = accounts[0].Id);
        insert contact;

        List<AccountContactRelation> relations = [select Id from AccountContactRelation];
        relations[0].Roles = 'Dealer Principal; General Manager';
        relations.add(new AccountContactRelation(AccountId = accounts[1].Id, ContactId = contact.Id, Roles = 'French Frie Maker; General Manager'));
        upsert relations;
        System.assertEquals(2, relations.size());


        Test.startTest();
        BatchProccessAccountContactRoleUpdates batchJob = new BatchProccessAccountContactRoleUpdates();
        Database.executeBatch(batchJob, 2);
        Test.stopTest();

        List<Account> dealerPrincipalAccounts = [select Id, GeneralManager__c, DealerPrincipal__c from Account where DealerPrincipal__c != null];
        System.assertEquals(1, dealerPrincipalAccounts.size());
        List<Account> generalManagerAccounts = [select Id, GeneralManager__c, DealerPrincipal__c from Account where GeneralManager__c != null];
        System.assertEquals(2, generalManagerAccounts.size());
        //AccountContactRelation 

    }

}