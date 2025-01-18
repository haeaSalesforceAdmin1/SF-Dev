@isTest
public without sharing class HMAApexSharingTest {

    @TestSetup
    static void makeData(){
        
        User user1 = TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');
        User user2 = TestUtility.createInternalUser('TestOwnerUser2', 'TestOwnerUser2', 'System Administrator');
        User user3 = TestUtility.createInternalUser('TestOwnerUser3', 'TestOwnerUser3', 'System Administrator');

        TestUtility.createOrganizations();
        List<Region__c> regions = TestUtility.createRegionsForOrganizations(TestUtility.HYUNDIA_ORG);
        List<District__c> districts = TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, TestUtility.DEALER_CODE);
        Contact contact = new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='TestL@test.com');
        insert contact;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='TestL2@test.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='TestL3@test.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        //account.GenesisAreaManager__c = contact.Id;
        account.DealerPrincipal__c = contact.Id;
        account.MarketManager__c = user2.Id;
        //account.GenesisAreaManager__c = user3.Id;
        account.Region__c = regions[0].Id;
        HMAObjectService.dbUpdate(account);

        User user4 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');

       // GenesisArea__c genArea = TestUtility.createGenesisArea('GMA SOUTH', 'GS', user2.Id, genOrg.Id);
        //HyundaiArea__c hyundaiArea = TestUtility.createHyundaiArea('Test Hyundai Area', '234', hyundaiOrg.Id, regions[0].Id);

       // District__c genesisDistrict = new District__c(Name = 'SELECT SOUTH 2', Organization__c = genOrg.Id, GenesisArea__c = genArea.Id );
//insert genesisDistrict;
    }

    static testMethod void testHMAAPexSharing() {
        Account account = [select Id from Account limit 1];

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Test.startTest();
        User user = [select Id from User where LastName = 'TestOwnerUser3'];
        HMAApexSharing sharing = new HMAApexSharing('Survey__Share');
        sharing.add(survey, user.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        sharing.share();
        List<String> sharingReason = new List<String>();
        sharingReason.add(Schema.Survey__Share.RowCause.Survey_Sharing__c); //DPM-5426 added by Minheekim - 24.03.20
        //sharing.getExistingAccountsSharesForAccounts(new List<Account> {account});
        sharing.getExistingSharesForObject(new List<SObject> {survey}, sharingReason);
        Test.stopTest();
    }

    static testMethod void testHMAAPexSharing2() {
        Account account = [select Id from Account limit 1];

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;



        Test.startTest();
        HMAApexSharing sharing = new HMAApexSharing('Account');
        sharing.getExistingAccountsSharesForAccounts(new List<Account> {account});
        //sharing.getExistingSharesForObject(new List<SObject> {account}, Schema.Survey__Share.RowCause.Survey_Sharing__c);
        Test.stopTest();
    }


    static testMethod void testHMAAPexSharing3() {
        Account account = [select Id from Account limit 1];

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Test.startTest();
        User user = [select Id from User where LastName = 'TestOwnerUser3'];

        User user2 = [select Id from User where LastName = 'TestOwnerUser2'];
        HMAApexSharing sharing = new HMAApexSharing('Survey__Share');
        sharing.add(survey, user.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        sharing.share();
        
        sharing.add(survey, user2.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        sharing.remove(survey, user.Id, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
        sharing.unshare();

        Test.stopTest();
    }



     
}