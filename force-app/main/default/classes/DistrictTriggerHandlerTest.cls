@isTest
public with sharing class DistrictTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;
        User user1 = TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');
        User user2 = TestUtility.createInternalUser('TestOwnerUser2', 'TestOwnerUser2', 'System Administrator');
        User user3 = TestUtility.createInternalUser('TestOwnerUser3', 'TestOwnerUser3', 'System Administrator');

        TestUtility.createOrganizations();
        List<Region__c> regions = TestUtility.createRegionsForOrganizations(TestUtility.HYUNDIA_ORG);
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, TestUtility.DEALER_CODE);

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id, OwnerId = user1.id);
        
        insert eval;
        
        System.assert(eval != NULL); 
        
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Account__c = account.Id, OwnerId = user1.Id, FollowUpDate__c = System.now().date(), Organization__c = 'Hyundai', Division__c = 'Service', Evaluation__c = eval.Id);
        
        insert actionPlan;
        
        System.assert(actionPlan != NULL);
        
        ContactTriggerHandler.run = false;
        Contact contact = new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test1@email.com');
        insert contact;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='test3@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        //account.GenesisAreaManager__c = contact.Id;
        account.DealerPrincipal__c = contact.Id;
        account.MarketManager__c = user2.Id;
       // account.GenesisAreaManager__c = user3.Id;
        HMAObjectService.dbUpdate(account);

        User user4 = TestUtility.createExternalUser(contacts[1].Id, 'TestF2', 'TestL2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRO/' + TestUtility.DEALER_CODE);

       // GenesisArea__c genArea = TestUtility.createGenesisArea('GMA SOUTH', 'GS', user2.Id, genOrg.Id);
        HyundaiArea__c hyundaiArea = TestUtility.createHyundaiArea('Test Hyundai Area', '234', hyundaiOrg.Id, regions[0].Id);

        //District__c genesisDistrict = new District__c(Name = 'SELECT SOUTH 2', Organization__c = genOrg.Id, GenesisArea__c = genArea.Id );
       // insert genesisDistrict;
       List<AccessType__mdt> at = new List<AccessType__mdt>();
        at.add(new AccessType__mdt(AccessLevel__c='DPM_GMM_GS1',Active__c=true,PermissionSetAPINames__c='DPM_Action_Plan_ReadCreateEdit'));
        at.add(new AccessType__mdt(AccessLevel__c='DPM_DM_GS1',Active__c=true,PermissionSetAPINames__c='DPM_Action_Plan_ReadCreateEdit'));
       
 
    }
   
    static testMethod void testDistrictTrigger() {
        
            User testOwnerUser = [SELECT Id,AccessTypes__c FROM User WHERE LastName = 'TestOwnerUser'];
        
        	System.assert(testOwnerUser != NULL);
        	testOwnerUser.AccessTypes__c = 'DPM_GMM_GS1,DPM_DSM_SO2,DPM_DPSM_SO2';
        	update testOwnerUser;
        
            District__c district = [select Id,DistrictManagerAlt__c,DistrictSalesManagerAlt__c,DistrictPartsServiceManagerAlt__c,GenesisMarketManagerAlt__c, Organization__c, Region__c, DistrictCode__c from District__c where Name ='ATLANTA' limit 1];
               
        	  // district.DistrictManagerAlt__c=testOwnerUser.id;
              // district.DistrictSalesManagerAlt__c=testOwnerUser.id;
              // district.DistrictPartsServiceManagerAlt__c=testOwnerUser.id;
               district.GenesisMarketManagerAlt__c=testOwnerUser.id;
        
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       // Insert account as current user
        System.runAs (thisUser) {
        Test.startTest();
        update district;
            
         User testOwnerUser2 = [SELECT Id,District_Codes_Alt__c,AccessTypes__c FROM User WHERE LastName = 'TestOwnerUser2'];
        
        	System.assert(testOwnerUser != NULL);
            
        	testOwnerUser2.District_Codes_Alt__c = 'DPM_GMM_GS1,DPM_DPSM_SO2';
            testOwnerUser2.AccessTypes__c = 'DPM_GMM_GS1,DPM_DPSM_SO2';
        	update testOwnerUser2; 
   testOwnerUser2.AccessTypes__c = '';
        	update testOwnerUser2; 
            
              // district.DistrictManagerAlt__c=testOwnerUser2.id;
              // district.DistrictSalesManagerAlt__c=testOwnerUser2.id;
              // district.DistrictPartsServiceManagerAlt__c=testOwnerUser2.id;
               district.GenesisMarketManagerAlt__c=testOwnerUser2.id;
            
            update district;
            
            System.assert(district != NULL);
            
            
            Test.stopTest();
        }

    }
    
    static testMethod void removeDistrict(){
                
        District__c district = [SELECT Id from District__c where Name ='ATLANTA' limit 1];
        
        System.assert(district != NULL);
        
        delete district;
            
              
    }
  
}