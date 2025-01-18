@isTest
private class AccountContactRelationTriggerHandlerTest {

    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            DealerCode__c = 'AL035'
        );
        insert testAccount;
        
        // Create test contact
        Contact testContact = new Contact(
                AccountId = testAccount.id,
                LastName = 'TestContact',
                FirstName ='testdata1',
                email='test11@gmail.com',
                Active_DPM_User__c = true,
                JobCode__c='DB',
                //DPM-4454 added by MinheeKim - 2023.12.14
                Access_Types__c='<p>1) DPM_BasicExt/GA999  - DPM basic access permission for dealer user</p><p>2) DPM_Eval_ExtCE/GA999  - DPM Evaluation create and edit permission for dealer user</p><p>3) DPM_HyundaiExt  - Hyundai Dealer user</p><p>4) DPM_AP_ExtRCE/CA349  - DPM Action Plan create and edit permission for dealer user</p><p>5) DPM_BasicExt/CA349  - DPM basic access permission for dealer user</p><p>6) DPM_FinExtHMA/CA349  - DPM Hyundai Dealer Financials permission for dealer user</p><p>7) DPM_Eval_ExtCE/CA349  - DPM Evaluation create and edit permission for dealer user</p>',
                DNAMS_Role__c = 'Dealer Principal',
                DNAMS_Active_User__c = true
        );
        
        insert testContact;
       
    }
    
    @IsTest
    static void testUpdateContactDNAMSRole() {
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'TestContact'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        
        AccountContactRelation acr = [SELECT Id, Roles FROM AccountContactRelation 
                                    WHERE AccountId = :testAccount.Id 
                                    AND ContactId = :testContact.Id];
        
        Test.startTest();
        acr.Roles = 'General Manager';
        update acr;
        Test.stopTest();
        
        // Verify results
        Contact updatedContact = [SELECT Id, DNAMS_Role__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals('General Manager', updatedContact.DNAMS_Role__c, 
                          'DNAMS Role should be updated to General Manager');
    }
    
    @IsTest
    static void testUpdateMultipleRoles() {
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'TestContact'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        
        AccountContactRelation acr = [SELECT Id, Roles FROM AccountContactRelation 
                                    WHERE AccountId = :testAccount.Id 
                                    AND ContactId = :testContact.Id];
        
        Test.startTest();
        acr.Roles = 'Office Manager;General Manager;Dealer Admin Support';
        update acr;
        Test.stopTest();
        
        // Verify results - should pick highest priority role
        Contact updatedContact = [SELECT Id, DNAMS_Role__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals('General Manager', updatedContact.DNAMS_Role__c, 
                          'Should assign highest priority role when multiple roles exist');
    }
    
    @IsTest
    static void testDeactivateContact() {
        Contact testContact = [SELECT Id, DNAMS_Active_User__c FROM Contact WHERE LastName = 'TestContact'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        
        AccountContactRelation acr = [SELECT Id FROM AccountContactRelation 
                                    WHERE AccountId = :testAccount.Id 
                                    AND ContactId = :testContact.Id];
        
        Test.startTest();
        testContact.DNAMS_Active_User__c = false;
        update testContact;
        
        acr = [SELECT Id, DNAMSAccountUser__c FROM AccountContactRelation 
               WHERE Id = :acr.Id];
        System.assertEquals(false, acr.DNAMSAccountUser__c, 
                          'DNAMSAccountUser__c should be false when contact is deactivated');
        Test.stopTest();
    }
}