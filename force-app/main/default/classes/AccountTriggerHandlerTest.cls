@isTest
public with sharing class AccountTriggerHandlerTest {

    private static final String DEALER_NAME = 'Dealer Test';
    private static final String DISTRICT_NAME = 'SO2 - ALABAMA NORTH';
    private static final String SALES_DISTRICT_NAME = 'SO2 - ALABAMA NORTH';
    private static final String SERVICE_DISTRICT_NAME = 'SO2 - ALABAMA NORTH';
    private static final String REGION_NAME = 'SOUTHERN REGION';
    private static final String HYUNDAI_ORG = 'Hyundai';

    private static final String DNA_DEALER_NAME_1 = 'UTOPIA MOUNTAIN HYUNDAI';
    private static final String DNA_DISTRICT_NAME_1 = 'ATLANTA';
    private static final String DNA_REGION_NAME_1 = 'SOUTHERN REGION';
    private static final String DNA_REGION_CODE_1 = 'SO';
    private static final String DNA_DEALER_CODE_1 = 'GA999';
    private static final String DNA_CONTACT_FN_1 = 'Ioniq';
    private static final String DNA_CONTACT_LN_1 = 'Palisade';
    private static final String DNA_CONTACT_EMAIL_1 = 'ionisade@hyundaidealerusa.com.test.ignore';
    private static final String DNA_USER_PROFILE_1 = 'DPM Partner Community (Hyundai)';
    private static final String DNA_ENFORCE_SSO_PERM_SET = 'DNAMS_Enforce_SSO';

    @TestSetup
    static void makeData(){
        //DPM-4456 added for test by MinheeKim - 24.04.02
        CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        //DPM-4456 end
        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(HYUNDAI_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(DEALER_NAME, DISTRICT_NAME, REGION_NAME, HYUNDAI_ORG, 'A0001');
    }

    static testMethod void testAccountTriggerHandler() {

        List<Account> accounts = [select Id from Account];
        System.assertEquals(1, accounts.size());
    }

    static testMethod void testAccountTriggerHandlerDelete() {

        List<Account> accounts = [select Id from Account];
        System.assertEquals(1, accounts.size());

        delete accounts;

        accounts = [select Id from Account];
        System.assertEquals(0, accounts.size());
    }


    static testMethod void testAccountTriggerHandlerCallUndelete() {
        AccountTriggerHandler triggerHandler = new AccountTriggerHandler();
        triggerHandler.afterUndelete(null);
    }

    static testMethod void testTempAccountTriggerInsert() {
        TempDealerCodes__c tempSetting = new TempDealerCodes__c();
        tempSetting.Name = DNA_REGION_CODE_1;
        tempSetting.LatestRunningNumber__c = 1000;
        insert tempSetting;
    
        List<Account> tempAccounts = new List<Account>();
        District__c district = TestUtility.getDistrict(DNA_DISTRICT_NAME_1, DNA_REGION_NAME_1, HYUNDAI_ORG);
        
        Test.startTest();

        Account tempAccount = new Account(Name = DNA_DEALER_NAME_1, 
                         ServiceDistrict__c = district.Id, 
                         SalesDistrict__c = district.Id, 
                         Region__c = district.Region__c, 
                         RegionCodePicklist__c = DNA_REGION_CODE_1,
                         Organization__c = district.Organization__c,
                         Is_Temp_Account__c = true,
                         Active__c = true);
        tempAccounts.add(tempAccount);
        insert tempAccounts;

        List<Account> lstAccounts = [SELECT Id, DealerCode__c, Name FROM Account WHERE Id = :tempAccounts[0].Id LIMIT 1];
        System.assertEquals('T' + DNA_REGION_CODE_1 + '0' + 1001, lstAccounts[0].DealerCode__c, 'Temp Dealer Code is getting set incorrectly.');

        lstAccounts[0].DealerCode__c = DNA_DEALER_CODE_1;
        update lstAccounts;

        lstAccounts = [SELECT Id, DealerCode__c, Name FROM Account WHERE Id = :tempAccounts[0].Id LIMIT 1];
        System.assertEquals(DNA_DEALER_CODE_1 + ' - ' + DNA_DEALER_NAME_1, lstAccounts[0].Name, 'Dealer name is getting set incorrectly.');

        Test.stopTest();
    }

    static testMethod void testDNASSOUserProvisioning() {

        List<PermissionSet> enforceSSOPermSet = [SELECT Id FROM PermissionSet WHERE Name = :DNA_ENFORCE_SSO_PERM_SET LIMIT 1];
        List<Account> lstAccounts = [SELECT Id, DealerCode__c, Is_Temp_Account__c FROM Account LIMIT 1];
        Contact con = new Contact(FirstName = DNA_CONTACT_FN_1,
                                LastName = DNA_CONTACT_LN_1,
                                Email = DNA_CONTACT_EMAIL_1,
                                AccountId = lstAccounts[0].Id,
                                DNAMS_Active_User__c = true,
                                DNAMS_Role__c = 'Dealer Principal');
        insert con;
        User dealerUser = TestUtility.createExternalUser(con.Id, DNA_CONTACT_FN_1, DNA_CONTACT_LN_1, DNA_USER_PROFILE_1);

        Test.startTest();

        //Retrieving Permission Set Assignments prior to Account dealer code getting updated
        List<PermissionSetAssignment> lstPSA = [SELECT Id FROM PermissionSetAssignment
                                                WHERE PermissionSetId = :enforceSSOPermSet[0].Id AND AssigneeId = :dealerUser.Id LIMIT 1];
        System.assertEquals(0, lstPSA.size(), 'Expecting no DNAMS Enforce SSO permission set assignments.');

        lstAccounts[0].DealerCode__c = DNA_DEALER_CODE_1;
        lstAccounts[0].Is_Temp_Account__c = false;
        update lstAccounts;

        Test.stopTest();

        //Retrieving Permission Set Assignments after Account dealer code getting updated
        lstPSA = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :enforceSSOPermSet[0].Id AND AssigneeId = :dealerUser.Id LIMIT 1];
        System.assertEquals(1, lstPSA.size(), 'Expecting DNAMS Enforce SSO permission set to be assigned.');
        
    }
    /**
     * [Method Description] test method to test closeEvaluationActionplan method 
     * Created by [MinheeKim] on [2024-04-01] for [DPM-4456]
    */
    static testMethod void testCloseEvaluationActionplan() {
        TempDealerCodes__c tempSetting = new TempDealerCodes__c();
        tempSetting.Name = DNA_REGION_CODE_1;
        tempSetting.LatestRunningNumber__c = 1000;
        insert tempSetting;
    
        List<Account> tempAccounts = new List<Account>();
        District__c district = TestUtility.getDistrict(DNA_DISTRICT_NAME_1, DNA_REGION_NAME_1, HYUNDAI_ORG);
        
        Test.startTest();

        Account tempAccount = new Account(Name = DNA_DEALER_NAME_1, 
                         ServiceDistrict__c = district.Id, 
                         SalesDistrict__c = district.Id, 
                         Region__c = district.Region__c, 
                         RegionCodePicklist__c = DNA_REGION_CODE_1,
                         Organization__c = district.Organization__c,
                         Is_Temp_Account__c = true, IsTerminated__c = false,
                         Active__c = true);
        tempAccounts.add(tempAccount);
        insert tempAccounts;

        Evaluation__c testEval = new Evaluation__c(Account__c=tempAccount.Id, Name = 'testEval', Status__c='Pending', ApprovalStatus__c='Not Submitted');
        insert testEval;
        // Action_Plan__c testAP = new Action_Plan__c(Evaluation__c= testEval.Id ,Account__c=tempAccount.Id, Name = 'testEval', Status__c='Pending', ApprovalStatus__c='Not Submitted');
        // insert testAP;
        tempAccount.IsTerminated__c = true;
        update tempAccounts;

        // System.assertEquals('Non-Compliant',testEval.Status__c);
        // System.assertEquals(testEval.ApprovalStatus__c, 'Region Approved');
        Test.stopTest();
    }
}