/**
* Created by jk_ku on 2023-08-03.
*/
@IsTest
public with sharing class ContactTriggerHandlerTest {
    private static final String HYUNDAI_ORG = 'Hyundai';
    private static final String DEALER_NAME = 'UTOPIA MOUNTAIN SUNRISE HYUNDAI';
    private static final String DISTRICT_NAME = 'ATLANTA';
    private static final String REGION_NAME = 'SOUTHERN REGION';
    private static final String REGION_CODE = 'SO';
    private static final String DEALER_CODE = 'GA999';
    private static final String CONTACT_FN_1 = 'Ioniq';
    private static final String CONTACT_LN_1 = 'Palisade';
    private static final String CONTACT_EMAIL_1 = 'ionisade@hyundaidealerusa.com.test.ignore';
    
    @TestSetup
    static void makeData() {
        ContentDocumentLinkTriggerHandler.run = false;
        Account acct = new Account(
                Name='GA999'
        );
        insert acct;
 
        Account acct2 = new Account(
                Name='CA349',
                DealerCode__c='CA349'
        );
        insert acct2;
 
        Contact con = new Contact(
                AccountId = acct.id,
                LastName = 'testdata',
                FirstName ='testdata1',
                email='test11@gmail.com',
                Active_DPM_User__c = true,
                DNAMS_Active_User__c = false,
                JobCode__c='DB',
                //DPM-4454 added by MinheeKim - 2023.12.14
                Access_Types__c='<p>1) DPM_BasicExt/GA999  - DPM basic access permission for dealer user</p><p>2) DPM_Eval_ExtCE/GA999  - DPM Evaluation create and edit permission for dealer user</p><p>3) DPM_HyundaiExt  - Hyundai Dealer user</p><p>4) DPM_AP_ExtRCE/CA349  - DPM Action Plan create and edit permission for dealer user</p><p>5) DPM_BasicExt/CA349  - DPM basic access permission for dealer user</p><p>6) DPM_FinExtHMA/CA349  - DPM Hyundai Dealer Financials permission for dealer user</p><p>7) DPM_Eval_ExtCE/CA349  - DPM Evaluation create and edit permission for dealer user</p>'
        );
        insert con;
 
        Contact contact1 = new Contact(LastName='Test5', FirstName = 'Frent5', AccountId = acct2.Id, Email='test5@email.com', Access_Types__c='1) DPM_BasicExt/CA349 - DPM basic access permission for dealer user');
        insert contact1;

        Contact contact2 = new Contact(LastName='Test6', FirstName = 'Frent6', AccountId = acct2.Id, Email='test6@email.com', Access_Types__c='1) DPM_BasicExt/CA349 - DPM basic access permission for dealer user');
        insert contact2;
 
        User user1 = new User(
            FirstName = 'TestF1',
            LastName = 'Test1L1',
            ContactId = contact2.Id,
            Username = 'TestF1' + '' + 'Test1L1'+'@' + 'Test1L1' + '.com',
            ProfileId =[Select Id from Profile WHERE NAME = 'DPM Partner Community (Hyundai)'].Id,
            Email = 'Test1L1' + 'invalid@acumensolutions.com',
            Alias = 'usr123',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        
        );
        insert user1;
        
        // User user2 = TestUtility.createExternalUser(contact1.Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/CA349,DPM_Eval_ExtRead/CA349,DPM_SurvExtUsr/CA349');
        User user2 = new User(
            FirstName = 'TestF2',
            LastName = 'Test1L2',
            ContactId = contact1.Id,
            Username = 'TestF2' + '' + 'Test1L2'+'@' + 'Test1L2' + '.com',
            ProfileId =[Select Id from Profile WHERE NAME = 'DPM Partner Community (Hyundai)'].Id,
            Email = 'Test1L2' + 'invalid@acumensolutions.com',
            Alias = 'usr123',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            IsActive = false
        
        );
        insert user2;
        // testUserUpdate();



        List<AccountContactRelation> acr = [SELECT Id, AccountId, ContactId, JobCode__c FROM AccountContactRelation WHERE AccountId=:acct2.Id];
        acr[0].JobCode__c = 'GM';
        update acr;

        Evaluation__c eval = new Evaluation__c(Account__c = acct2.Id, PrimaryContact__c = acr[1].ContactId);
        insert eval;
 
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Organization__c='Genesis',Evaluation__c = eval.Id, Account__c = acct2.Id, Status__c = 'Compliant', Division__c = 'Sales', RegionCode__c = 'SO',  Original_Partner_User_ID__c=user2.Id , OwnerId=user1.Id ));
        
        Action_PlanTriggerHandler.run = false;
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;
 
        
    }

    @future
    public static void testDelete(){
        Contact contact1 = [select Id from Contact WHERE LastName='Test5' Limit 1];
        delete contact1;

    }
 
    public static testMethod void testInsertContact() {
        Contact objContact = [SELECT Id, AccountId, LastName, FirstName, Email, Active_DPM_User__c, JobCode__c FROM Contact LIMIT 1];
        Contact objContact2 = objContact.clone(false);
        objContact2.LastName = 'testdata2';
        objContact2.FirstName ='testdata2';
        objContact2.Email='test22@gmail.com';
        Test.startTest();
        insert objContact2;
        Test.stopTest();
    }
 
    public static testMethod void testUpdateContact() {
        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations(HYUNDAI_ORG);
        TestUtility.createDistrictsForRegions();
 
        District__c district = TestUtility.getDistrict(DISTRICT_NAME, REGION_NAME, HYUNDAI_ORG);
        Account dealer = DNAMSPackageTestDataFactory.createNewDealer(DEALER_NAME, DEALER_CODE, district, REGION_CODE);
 
        Contact activeDNAContact = DNAMSPackageTestDataFactory.getNewDealerContact(CONTACT_FN_1, CONTACT_LN_1, CONTACT_EMAIL_1, dealer.Id);
        activeDNAContact.DNAMS_Active_User__c = TRUE;
        insert activeDNAContact;
        Test.startTest();
        activeDNAContact.DNAMS_Active_User__c = false;
        //DPM-4454 added by MinheeKim - 2023.12.14
        activeDNAContact.Access_Types__c='<p>3) DPM_HyundaiExt  - Hyundai Dealer user</p><p>4) DPM_AP_ExtRCE/CA349  - DPM Action Plan create and edit permission for dealer user</p><p>5) DPM_BasicExt/CA349  - DPM basic access permission for dealer user</p><p>6) DPM_FinExtHMA/CA349  - DPM Hyundai Dealer Financials permission for dealer user</p><p>7) DPM_Eval_ExtCE/CA349  - DPM Evaluation create and edit permission for dealer user</p>';
        //DPM-4454 end
        update activeDNAContact;
        Test.stopTest();
    }

    public static testMethod void testDeleteContact() {
        Contact objContact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        delete objContact;
        Test.stopTest();
    }
 
    public static testMethod void testUnDeleteContact() {
        Contact objContact = [SELECT Id FROM Contact LIMIT 1];
        delete objContact;
        Test.startTest();
        undelete objContact;
        Test.stopTest();
    }
 
    // static testMethod void testChangePrimaryContact() {
 
    //     Account account = [select Id from Account WHERE DealerCode__c='CA349' Limit 1];
 
    //     Contact contact1 = [select Id from Contact WHERE LastName='Test5' Limit 1];
 
    //     Contact contact2 = [select Id from Contact WHERE LastName='Test6' Limit 1];
    //     List<AccountContactRelation> acr = [SELECT Id, AccountId, ContactId, JobCode__c FROM AccountContactRelation WHERE AccountId=:account.Id];
        
    //     Test.startTest();
    //     testDelete();
    //     Test.stopTest();
 
    // }
 

    static testMethod void testMethodContactTriggerHelper() {
        ContentDocumentLinkTriggerHandler.run = false;
        Account testAccount = new Account(Name = 'Test Account',
                DealerCode__c='AK003');
        insert testAccount;
        
        Contact testContact1 = new Contact(LastName='Test1', FirstName = 'Frent1', AccountId = testAccount.Id, Email='test1@email.com', Access_Types__c='1) DPM_BasicExt/AK003 - DPM basic access permission for dealer user');
        insert testContact1;
        
        Contact testContact2 = new Contact(LastName='Test2', FirstName = 'Frent2', AccountId = testAccount.Id, Email='test2@email.com', Access_Types__c='1) DPM_BasicExt/AK003 - DPM basic access permission for dealer user');
        insert testContact2;
        
        Evaluation__c testEvaluation = new Evaluation__c(
            PrimaryContact__c = testContact1.Id,
            Account__c = testAccount.Id
        );
        insert testEvaluation;
        
                    
        List<AccountContactRelation> acr = [SELECT Id, AccountId, ContactId, JobCode__c FROM AccountContactRelation WHERE AccountId=:testAccount.Id];
        acr[0].JobCode__c = 'GM';
        update acr;
        
        User testUser = new User(
            ContactId = testContact2.Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'DPM Partner Community (Hyundai)' LIMIT 1].Id,
            Username = 'testuser223@test.com',
            Email = 'testuser223@test.com',
            LastName = 'TestUser223',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
		Action_Plan__c testActionPlan = new Action_Plan__c(
            Evaluation__c = testEvaluation.Id,
            Organization__c='Genesis',
            Account__c = testAccount.Id, 
            Status__c = 'Compliant', 
            Division__c = 'Sales', 
            RegionCode__c = 'SO',  
            Original_Partner_User_ID__c=testUser.Id ,
            OwnerId=testUser.Id
        );
          
        Action_PlanTriggerHandler.run = false;
        insert testActionPlan;
        Action_PlanTriggerHandler.run = true;
        
        Test.startTest();
        ContactTriggerHelper.changePrimaryContactOnEval(new List<Contact>{testContact1});
        Test.stopTest();
        

        Evaluation__c updatedEvaluation = [SELECT PrimaryContact__c FROM Evaluation__c WHERE Id = :testEvaluation.Id];
        //System.assertEquals(testContact2.Id, updatedEvaluation.PrimaryContact__c, 'PrimaryContact__c should be updated to the new contact.');
        
        Action_Plan__c updatedActionPlan = [SELECT Original_Partner_User_ID__c FROM Action_Plan__c WHERE Id = :testActionPlan.Id];
        //System.assertEquals(testUser.Id, updatedActionPlan.Original_Partner_User_ID__c, 'Original_Partner_User_ID__c should be updated to the new user.');
        ContentDocumentLinkTriggerHandler.run = true;
    }
 
}