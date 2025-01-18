@isTest
public without sharing class ContactServiceTest {


    static testMethod void testContactServiceTest1() {
        Account account = new Account();
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0001';
        insert account;

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        /*contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL3', FirstName = 'TestF2', Email='test3@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL4', FirstName = 'TestF2', Email='test4@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL5', FirstName = 'TestF2', Email='test5@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL6', FirstName = 'TestF2', Email='test6@email.com'));*/
        insert contacts;

        User user1 = TestUtility.createExternalUser(contacts[0].Id, 'TestL', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_BasicExt/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        /*User user2 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user3 = TestUtility.createExternalUser(contacts[2].Id, 'TestL3', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user4 = TestUtility.createExternalUser(contacts[3].Id, 'TestL4', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user5 = TestUtility.createExternalUser(contacts[4].Id, 'TestL5', 'TestF2', 'DPM Partner Community (Hyundai)');
        User user6 = TestUtility.createExternalUser(contacts[5].Id, 'TestL6', 'TestF2', 'DPM Partner Community (Hyundai)');*/


        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Contact';
        objectShares.updateAllObjectsSharing = false;
        
        //objectShares.accountIds = new Set<String>{'0013I00000ZhcAC'};
        //objectShares.objectIds = new Set<Id> {'a0f3I000000pUnE'};
        Database.executeBatch(objectShares, 1);
        Test.stopTest();
    }

	static testMethod void testContactTriggerHandlerCallUndelete() {
        ContactTriggerHandler triggerHandler = new ContactTriggerHandler();
        triggerHandler.afterUndelete(null);
    }
    static testMethod void testContactTriggerHandlerDelete() {
		Account account = new Account();
        account.Name = 'Test Account';
        account.DealerCode__c = 'A0001';
        insert account;

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        insert contacts;

        List<Contact> contactss = [select Id from Contact];
        System.assertEquals(1, contactss.size());

        delete contacts;

        contactss = [select Id from Contact];
        System.assertEquals(0, contactss.size());
    }
    

}