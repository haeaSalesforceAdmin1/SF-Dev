@isTest
public class RegionTriggerHandlerTest {
    private static void setupTestData() {
        // Create User records
        User testUser1 = new User(
            Username = 'tsetuser1@test.com',
            Email = 'testuser1@test.com',
            Alias = 'user1',
            ProfileId = UserInfo.getProfileId(),
            EmployeeNumber = '123',
            IsActive = true,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            LastName = 'User1',  // Add LastName
            EmailEncodingKey = 'UTF-8'  // Add EmailEncodingKey
        );
        insert testUser1;

        User testUser2 = new User(
            Username = 'tsetuser2@test.com',
            Email = 'testuser2@test.com',
            Alias = 'user2',
            ProfileId = UserInfo.getProfileId(),
            EmployeeNumber = '456',
            IsActive = true,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            LastName = 'User2',  // Add LastName
            EmailEncodingKey = 'UTF-8'  // Add EmailEncodingKey
        );
        insert testUser2;
        Account account = new Account(
            Name = 'Test Account',
        	DealerCode__c = 'A0001'
        );
        insert account;


        Contact contact = new Contact(AccountId = account.Id, LastName = 'TestL11', FirstName = 'TestF11', Email='test11@email.com');
        insert contact;

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id, PrimaryContact__c = contact.Id);
        insert eval;

        //List<Contact> contacts = new List<Contact>();
        //contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL22', FirstName = 'TestF22', Email='test22@email.com'));
        //contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL33', FirstName = 'TestF33', Email='test33@email.com'));
        //insert contacts;

        // Create Region records
        Region__c region1 = new Region__c(
            Name = 'Region 1',
            GAFOMEmpNum__c = '123',
            GSFOMEmpNum__c = '456',
            RegionCode__c = 'SO' 
        );
        insert region1;

        Region__c region2 = new Region__c(
            Name = 'Region 2',
            GAFOMEmpNum__c = '456',
            GSFOMEmpNum__c = '123',
            RegionCode__c = 'R002'
        );
        insert region2;
        
        Organization__c org = new Organization__c(BrandCode__c ='G');
        insert org;

        User testUser12 = [select Id from User Limit 1];
        List<Account> accounts = [select Id from Account];
    }

   @isTest
    static void testBeforeUpdate() {
        setupTestData();

        List<Region__c> regions = [SELECT Id, GAFOMEmpNum__c, GSFOMEmpNum__c FROM Region__c WHERE RegionCode__c = 'SO' LIMIT 1];

        if (regions.isEmpty()) {
            System.debug('No Region found with RegionCode "WE"');
            return;
        }

        Region__c regionToUpdate = regions[0];
        regionToUpdate.GAFOMEmpNum__c = '456';  
        regionToUpdate.GSFOMEmpNum__c = '123';  
        update regionToUpdate;

        Test.startTest();
        
        Map<Id, Region__c> oldMap = new Map<Id, Region__c>{regionToUpdate.Id => regionToUpdate};
        Map<Id, Region__c> newMap = new Map<Id, Region__c>{regionToUpdate.Id => regionToUpdate};
        
        RegionTriggerHandler handler = new RegionTriggerHandler();
        handler.beforeUpdate(oldMap, newMap);
        
        Test.stopTest();
    }

    @isTest
    static void testAfterUpdate() {
        setupTestData();

        List<Region__c> regions = [SELECT Id, GAFOMEmpNum__c, GSFOMEmpNum__c, Aftersales_Field_Operations_Manager__c, Operations_Manager__c FROM Region__c WHERE RegionCode__c = 'SO' LIMIT 1];

        if (regions.isEmpty()) {
            System.debug('No Region found with RegionCode "WE"');
            return;
        }

        Region__c regionToUpdate = regions[0];
        regionToUpdate.GAFOMEmpNum__c = '456';  
        regionToUpdate.GSFOMEmpNum__c = '123';  
        update regionToUpdate;

        Test.startTest();

        Map<Id, Region__c> oldMap = new Map<Id, Region__c>{regionToUpdate.Id => regionToUpdate};
        Map<Id, Region__c> newMap = new Map<Id, Region__c>{regionToUpdate.Id => regionToUpdate};

        RegionTriggerHandler handler = new RegionTriggerHandler();
        handler.afterUpdate(oldMap, newMap);

        Test.stopTest();

        List<Action_Plan__c> updatedActionPlans = [SELECT Id, RegionManager__c FROM Action_Plan__c WHERE RegionCode__c = 'SO'];
    }
}