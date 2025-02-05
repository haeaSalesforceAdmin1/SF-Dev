@isTest
public with sharing class DistrictTriggerHandlerTest {
    
    @TestSetup
    static void makeData() {
        EvaluationTriggerHandler.run = false;
        AccountTriggerHandler.run=false;
        // Create test data for the setup
        CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name = 'STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;

        // Create internal users
        User user1 = TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');
        User user2 = TestUtility.createInternalUser('TestOwnerUser2', 'TestOwnerUser2', 'System Administrator');
        User user3 = TestUtility.createInternalUser('TestOwnerUser3', 'TestOwnerUser3', 'System Administrator');

        // Create organizations and regions
        TestUtility.createOrganizations();
        List<Region__c> regions = TestUtility.createRegionsForOrganizations(TestUtility.HYUNDIA_ORG);
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);
        hyundaiOrg.BrandCode__c = 'H';
        update hyundaiOrg;
        genOrg.BrandCode__c = 'G';
        update genOrg;

        // Create an account for the district
        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, TestUtility.DEALER_CODE);
        Account account2 = TestUtility.createAccountForDistrictRegionOrg('D0002 - Dealer Test', 'SO4 - ALABAMA SOUTH', TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'D0002');
        Account account3 = TestUtility.createAccountForDistrictRegionOrg('D0003 - Dealer Test', 'GS5 - MIAMI', TestUtility.REGION_NAME, TestUtility.GENESIS_ORG, 'D0003');

        // Create a contact for testing
        ContactTriggerHandler.run = false;
        Contact contact = new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test1@email.com');
        insert contact;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='test3@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        // Associate the dealer principal with the contact and market manager with another user
        account.DealerPrincipal__c = contact.Id;
        account.MarketManager__c = user2.Id;
        HMAObjectService.dbUpdate(account);

        // Create external user for testing
        User user4 = TestUtility.createExternalUser(contacts[1].Id, 'TestF2', 'TestL2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRO/' + TestUtility.DEALER_CODE);

        // Create Hyundai Area for testing
        HyundaiArea__c hyundaiArea = TestUtility.createHyundaiArea('Test Hyundai Area', '234', hyundaiOrg.Id, regions[0].Id);
    
        // Create a district for the test to be used in assertions
        District__c district = new District__c(Name = 'ATLANTA', Organization__c = hyundaiOrg.Id, Region__c = regions[0].Id, DistrictCode__c = 'ATL01');
        insert district;

        // Set values for employee numbers
        district.DPSMEmpNum__c = 'DPSM123';
        district.DSMEmpNum__c = 'DSM123';
        district.GAMMEmpNum__c = 'GAMM123';
        district.GMMEmpNum__c = 'GMM123';
        update district;
    
        // Create users for district manager roles (if needed for testing)
        User userDPSM = TestUtility.createInternalUser('TestDPSM', 'TestDPSM', 'System Administrator');
        User userDSM = TestUtility.createInternalUser('TestDSM', 'TestDSM', 'System Administrator');
        User userGAMM = TestUtility.createInternalUser('TestGAMM', 'TestGAMM', 'System Administrator');
        User userGMM = TestUtility.createInternalUser('TestGMM', 'TestGMM', 'System Administrator');
    
        // Update the district with employee numbers and managers
        district.DPSMEmpNum__c = 'DPSM123';
        district.DSMEmpNum__c = 'DSM456';
        district.GAMMEmpNum__c = 'GAMM789';
        district.GMMEmpNum__c = 'GMM000';
        district.DistrictPartsServiceManager__c = userDPSM.Id;
        district.SalesManager__c = userDSM.Id;
        district.Aftersales_Market_Manager__c = userGAMM.Id;
        district.MarketManager__c = userGMM.Id;
        update district;

        // Create a district for the test to be used in assertions
        District__c district2 = new District__c(Name = 'ATLANTA SOUTH', Organization__c = hyundaiOrg.Id, Region__c = regions[0].Id, DistrictCode__c = 'SO4');
        insert district2;

        // Set values for employee numbers
        district2.DPSMEmpNum__c = 'DPSM120';
        district2.DSMEmpNum__c = 'DSM125';
        district2.GAMMEmpNum__c = 'GAMM125';
        district2.GMMEmpNum__c = 'GMM125';
        update district2;
    
        // Update the district with employee numbers and managers
        district2.DPSMEmpNum__c = 'DPSM125';
        district2.DSMEmpNum__c = 'DSM458';
        district2.GAMMEmpNum__c = 'GAMM791';
        district2.GMMEmpNum__c = 'GMM002';
        district2.DistrictPartsServiceManager__c = userDPSM.Id;
        district2.SalesManager__c = userDSM.Id;
        district2.Aftersales_Market_Manager__c = userGAMM.Id;
        district2.MarketManager__c = userGMM.Id;
        update district2;

        account2.SalesDistrict__c = district2.Id;
        account2.ServiceDistrict__c = district2.Id;
        update account2;

       

        //MarketCode
        District__c district3 = new District__c(Name = 'MIAMI', Organization__c = genOrg.Id, Region__c = regions[0].Id, DistrictCode__c = 'GS5');
        insert district3;

        // Set values for employee numbers
        district3.DPSMEmpNum__c = 'DPSM122';
        district3.DSMEmpNum__c = 'DSM124';
        district3.GAMMEmpNum__c = 'GAMM124';
        district3.GMMEmpNum__c = 'GMM124';
        update district3;
    
        // Update the district with employee numbers and managers
        district3.DPSMEmpNum__c = 'DPSM124';
        district3.DSMEmpNum__c = 'DSM457';
        district3.GAMMEmpNum__c = 'GAMM790';
        district3.GMMEmpNum__c = 'GMM001';
        district3.DistrictPartsServiceManager__c = userDPSM.Id;
        district3.SalesManager__c = userDSM.Id;
        district3.Aftersales_Market_Manager__c = userGAMM.Id;
        district3.MarketManager__c = userGMM.Id;
        update district3;

        account3.Market__c = district3.Id;
        update account3;

         // Create an evaluation
         List<Evaluation__c> evaluations = new List<Evaluation__c>();
         Evaluation__c eval = new Evaluation__c(OrganizationRef__c=hyundaiOrg.Id, Account__c = account.Id, OwnerId = user1.Id, Status__c='Pending', ApprovalStatus__c='Not Submitted', JDP_Evaluation__c=true);
        Evaluation__c eval2 = new Evaluation__c(OrganizationRef__c=hyundaiOrg.Id, Account__c = account2.Id, OwnerId = user1.Id, Status__c='Pending', ApprovalStatus__c='Not Submitted', JDP_Evaluation__c=true, SalesDistrictCode__c='SO4');
        Evaluation__c eval3 = new Evaluation__c(OrganizationRef__c=genOrg.Id, Account__c = account3.Id, OwnerId = user1.Id, Status__c='Pending', ApprovalStatus__c='Not Submitted', JDP_Evaluation__c=true, MarketCode__c='GS5');
        Evaluation__c eval4 = new Evaluation__c(OrganizationRef__c=genOrg.Id, Account__c = account3.Id, OwnerId = user1.Id, Status__c='Pending', ApprovalStatus__c='Not Submitted', JDP_Evaluation__c=true, MarketCode__c='GS1');
        Evaluation__c eval5 = new Evaluation__c(OrganizationRef__c=genOrg.Id, Account__c = account3.Id, OwnerId = user1.Id, Status__c='Pending', ApprovalStatus__c='Not Submitted', JDP_Evaluation__c=true, MarketCode__c='SO4');
        evaluations.add(eval);
        evaluations.add(eval2);
        evaluations.add(eval3);
        evaluations.add(eval4);
        evaluations.add(eval5);
        insert evaluations;
        // Create an action plan
        List<Action_Plan__c> actionplans = new List<Action_Plan__c>();
        Action_Plan__c actionPlan = new Action_Plan__c(OrganizationRef__c=hyundaiOrg.Id, Name = 'Test Action Plan', Account__c = account.Id, OwnerId = user1.Id, FollowUpDate__c = System.now().date(), 
        Organization__c = 'Hyundai', Division__c = 'Service', Evaluation__c = eval.Id, ApprovalStatus__c='Not Submitted',SalesDistrictCode__c='SO4');

        Action_Plan__c actionPlan2 = new Action_Plan__c(OrganizationRef__c=hyundaiOrg.Id, Name = 'Test Action Plan2', Account__c = account2.Id, OwnerId = user1.Id, FollowUpDate__c = System.now().date(), 
        Organization__c = 'Hyundai', Division__c = 'Sales', Evaluation__c = eval2.Id, ApprovalStatus__c='Not Submitted',SalesDistrictCode__c='SO4');

        Action_Plan__c actionPlan2_1 = new Action_Plan__c(OrganizationRef__c=hyundaiOrg.Id, Name = 'Test Action Plan2-1', Account__c = account2.Id, OwnerId = user1.Id, FollowUpDate__c = System.now().date(), 
        Organization__c = 'Hyundai', Division__c = 'Service', Evaluation__c = eval2.Id, ApprovalStatus__c='Not Submitted',ServiceDistrictCode__c='SO4');

        Action_Plan__c actionPlan3 = new Action_Plan__c(OrganizationRef__c=genOrg.Id, Name = 'Test Action Plan2', Account__c = account3.Id, OwnerId = user1.Id, FollowUpDate__c = System.now().date(), Organization__c = 'Genesis', Division__c = 'Service', Evaluation__c = eval3.Id, 
        ApprovalStatus__c='Not Submitted', ServiceDistrictCode__c='GS5');
        actionplans.add(actionPlan);
        actionplans.add(actionPlan2);
        actionplans.add(actionPlan2_1);
        actionplans.add(actionPlan3);
        insert actionplans;
        EvaluationTriggerHandler.run = true;
        AccountTriggerHandler.run=true;

    }

    static testMethod void testDistrictTrigger() {
        // Your test code here
        EvaluationTriggerHandler.run = false;
        AccountTriggerHandler.run=false;
        User testOwnerUser = [SELECT Id, AccessTypes__c FROM User WHERE LastName = 'TestOwnerUser'];
        System.assert(testOwnerUser != NULL);
        testOwnerUser.AccessTypes__c = 'DPM_GMM_GS1,DPM_DSM_SO2,DPM_DPSM_SO2';
        update testOwnerUser;

        District__c district = [SELECT Id, DistrictManagerAlt__c, DistrictSalesManagerAlt__c, DistrictPartsServiceManagerAlt__c, GenesisMarketManagerAlt__c, Organization__c, Region__c, DistrictCode__c FROM District__c WHERE Name = 'ATLANTA' LIMIT 1];

        district.GenesisMarketManagerAlt__c = testOwnerUser.Id;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Test.startTest();
            
            update district;

            User testOwnerUser2 = [SELECT Id, District_Codes_Alt__c, AccessTypes__c FROM User WHERE LastName = 'TestOwnerUser2'];
            System.assert(testOwnerUser2 != NULL);

            testOwnerUser2.District_Codes_Alt__c = 'DPM_GMM_GS1,DPM_DPSM_SO2';
            testOwnerUser2.AccessTypes__c = 'DPM_GMM_GS1,DPM_DPSM_SO2';
            update testOwnerUser2;
            testOwnerUser2.AccessTypes__c = '';
            update testOwnerUser2;

            district.GenesisMarketManagerAlt__c = testOwnerUser2.Id;
            update district;
            

            System.assert(district != NULL);
            Test.stopTest();
        }
        EvaluationTriggerHandler.run = true;
        AccountTriggerHandler.run=true;

        
    }


    /**
     * Description: [Method Description] 
     * test method for UpdateRelatedDMOnDistrictChangeQueueable
     * Created by [MinheeKim] on [11-25-2024] for [DPM-133]
     * Edited by [Author] on [MM-DD-YYYY] for [Ticket #]
    */
    static testMethod void testUpdateSalesmanager() {
        Id newSalesmanager = [SELECT Id FROM User WHERE Name like '%TestGMM%' Limit 1].Id;
        District__c district = [SELECT Id FROM District__c WHERE Name = 'ATLANTA SOUTH' LIMIT 1];
        district.SalesManager__c = newSalesmanager;
        Test.startTest();
        EvaluationTriggerHandler.run = false;
        AccountTriggerHandler.run=false;
        update district;
        EvaluationTriggerHandler.run = true;
        AccountTriggerHandler.run=true;
        Test.stopTest();

    }

    /**
     * Description: [Method Description] 
     * test method for UpdateRelatedDMOnDistrictChangeQueueable
     * Created by [MinheeKim] on [11-25-2024] for [DPM-133]
     * Edited by [Author] on [MM-DD-YYYY] for [Ticket #]
    */
    static testMethod void testUpdateServicemanager() {
        Id newSalesmanager = [SELECT Id FROM User WHERE Name like '%TestGMM%' Limit 1].Id;
        District__c district = [SELECT Id FROM District__c WHERE Name = 'ATLANTA SOUTH' LIMIT 1];
        district.DistrictPartsServiceManager__c = newSalesmanager;
        Test.startTest();
        EvaluationTriggerHandler.run = false;
        AccountTriggerHandler.run=false;
        update district;
        EvaluationTriggerHandler.run = true;
        AccountTriggerHandler.run=true;
        Test.stopTest();

    }

    /**
     * Description: [Method Description] 
     * test method for UpdateRelatedDMOnDistrictChangeQueueable
     * Created by [MinheeKim] on [11-25-2024] for [DPM-133]
     * Edited by [Author] on [MM-DD-YYYY] for [Ticket #]
    */
    static testMethod void testUpdateMarketmanager() {
        Id newSalesmanager = [SELECT Id FROM User WHERE Name like '%TestDSM%' Limit 1].Id;
        District__c district = [SELECT Id FROM District__c WHERE Name = 'MIAMI' LIMIT 1];
        district.MarketManager__c = newSalesmanager;
        Test.startTest();
        EvaluationTriggerHandler.run = false;
        AccountTriggerHandler.run=false;
        update district;
        EvaluationTriggerHandler.run = true;
        AccountTriggerHandler.run=true;
        Test.stopTest();

    }

        
    static testMethod void removeDistrict() {
        // Test removing the district
        District__c district = [SELECT Id FROM District__c WHERE Name = 'ATLANTA' LIMIT 1];
        System.assert(district != NULL);
        Test.startTest();
        EvaluationTriggerHandler.run = false;
        AccountTriggerHandler.run=false;
        delete district;
        EvaluationTriggerHandler.run = true;
        AccountTriggerHandler.run=true;
        Test.stopTest();
    }
}