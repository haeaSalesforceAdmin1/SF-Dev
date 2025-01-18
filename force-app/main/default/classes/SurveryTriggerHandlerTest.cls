@isTest
public with sharing class SurveryTriggerHandlerTest {

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
        Contact contact = new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='testContact@email.com');
        insert contact;

        Account account2 = new Account(Name='TestAccount');
        insert account2;

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='testContact1@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='testContact2@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

      //  account.GenesisAreaManager__c = contact.Id;
        account.DealerPrincipal__c = contact.Id;
        account.MarketManager__c = user2.Id;
      //  account.GenesisAreaManager__c = user3.Id;
        account.Region__c = regions[0].Id;
        HMAObjectService.dbUpdate(account);

        User user4 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');

      //  GenesisArea__c genArea = TestUtility.createGenesisArea('GMA SOUTH', 'GS', user2.Id, genOrg.Id);
      //  HyundaiArea__c hyundaiArea = TestUtility.createHyundaiArea('Test Hyundai Area', '234', hyundaiOrg.Id, regions[0].Id);

      //  District__c genesisDistrict = new District__c(Name = 'SELECT SOUTH 2', Organization__c = genOrg.Id, GenesisArea__c = genArea.Id );
      //  insert genesisDistrict;
    }

    static testMethod void testSurveyTrigger() {
        Account account = [select Id from Account limit 1];

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;
    }

    static testMethod void testSurveyTriggerUpdate() {
        Account account = [select Id from Account limit 1];

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        update survey;
    }

    static testMethod void testSurveyTriggerDelete() {
        Account account = [select Id from Account limit 1];

        Test.startTest();
        List<Survey__c> surveys = new List<Survey__c>();
        surveys.add(new Survey__c(Dealer__c = account.Id));
        surveys.add(new Survey__c(Dealer__c = account.Id));
        insert surveys;

        Test.stopTest();

        delete surveys;
    }


    static testMethod void testSurveyShareUpdates() {
        Account account = [select Id from Account limit 1];

        Test.startTest();
        List<Survey__c> surveys = new List<Survey__c>();
        surveys.add(new Survey__c(Dealer__c = account.Id));
        surveys.add(new Survey__c(Dealer__c = account.Id));
        insert surveys;

        Map<Id, Survey__c> surveyMap = new Map<Id, Survey__c>([select Id from Survey__c]);

        BatchProcessObjectShares batchObjectShares = new BatchProcessObjectShares();
        batchObjectShares.objectIds = surveyMap.keySet();
        batchObjectShares.type = 'Survey';
        Database.executeBatch(batchObjectShares, 2);
    }


    static testMethod void testSurveyTriggerUndelete() {
        SurveyTriggerHandler triggerHandler = new SurveyTriggerHandler();
        triggerHandler.afterUndelete(null);
    }

    static testMethod void testSurveyForGenesisDealer() {
        Organization__c genesisOrg = TestUtility.getOrganization('Genesis');
      //  GenesisArea__c genesisArea = new GenesisArea__c(Name = TestUtility.GENESIS_AREA, Organization__c = genesisOrg.Id);
       // insert genesisArea;

        District__c genesisDistrict = New District__c(Name = 'SELECT SOUTH 2', Organization__c = genesisOrg.Id );
        insert genesisDistrict;

        Account account = [select Id from Account where Name != 'TestAccount'];
        account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
//        account.GenesisArea__c = genesisArea.Id;
        account.Market__c = genesisDistrict.Id;
        update account;

        Test.startTest();

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;
		delete survey;
        undelete survey;
        Test.stopTest();
    }    

    static testMethod void testSurveyForRegionUpdate() {
        Organization__c genesisOrg = TestUtility.getOrganization('Genesis');
      //  GenesisArea__c genesisArea = new GenesisArea__c(Name = TestUtility.GENESIS_AREA, Organization__c = genesisOrg.Id);
       // insert genesisArea;

        Region__c genesisRegion1 = New Region__c(Name = 'EASTERN REGION', Organization__c = genesisOrg.Id, RegionCode__c='EA' );
        insert genesisRegion1;
        Region__c genesisRegion2 = New Region__c(Name = 'WASTERN REGION', Organization__c = genesisOrg.Id, RegionCode__c='WE' );
        insert genesisRegion2;

        Account account = [select Id from Account where Name = 'TestAccount'];
        account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
//        account.GenesisArea__c = genesisArea.Id;
        account.Region__c = genesisRegion1.Id;
        update account;

        Test.startTest();

        Survey__c survey = new Survey__c(Dealer__c = account.Id, RegionRef__c = genesisRegion2.Id);
        insert survey;
        SurveyTriggerHandler.run = true;
        survey.RegionRef__c = genesisRegion2.Id;
        update survey;


		delete survey;
        undelete survey;
        Test.stopTest();
    }    
}