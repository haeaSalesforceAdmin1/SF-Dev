@IsTest(seeAllData = false)
public with sharing class DNAMSUserProvisioningServiceTest {
    private static final String HYUNDAI_ORG = 'Hyundai';
    private static final String DEALER_NAME = 'UTOPIA MOUNTAIN SUNRISE HYUNDAI';
    private static final String DISTRICT_NAME = 'ATLANTA';
    private static final String REGION_NAME = 'SOUTHERN REGION';
    private static final String REGION_CODE = 'SO';
    private static final String DEALER_CODE = 'GA999';
    private static final String CONTACT_FN_1 = 'Ioniq';
    private static final String CONTACT_LN_1 = 'Palisade';
    private static final String CONTACT_EMAIL_1 = 'ionisade@hyundaidealerusa.com.test.ignore';
    private static final String CONTACT_FN_2 = 'Kona';
    private static final String CONTACT_LN_2 = 'Nexo';
    private static final String CONTACT_EMAIL_2 = 'konexo@hyundaidealerusa.com.test.ignore';
    private static final String USER_PROFILE = 'DPM Partner Community (Hyundai)';
    private static final String DNA_EXTERNAL_PS = 'DNAMSBasicExternal';

    @TestSetup
    static void makeData() {
        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations(HYUNDAI_ORG);
        TestUtility.createDistrictsForRegions();

        District__c district = TestUtility.getDistrict(DISTRICT_NAME, REGION_NAME, HYUNDAI_ORG);
        Account dealer = DNAMSPackageTestDataFactory.createNewDealer(DEALER_NAME, DEALER_CODE, district, REGION_CODE);

        Contact activeDNAContact = DNAMSPackageTestDataFactory.getNewDealerContact(CONTACT_FN_1, CONTACT_LN_1, CONTACT_EMAIL_1, dealer.Id);
        activeDNAContact.DNAMS_Active_User__c = TRUE;
        insert activeDNAContact;

        Contact dnaContact = DNAMSPackageTestDataFactory.createNewDealerContact(CONTACT_FN_2, CONTACT_FN_2, CONTACT_EMAIL_2, dealer.Id);
    }
    
    @IsTest
    static void dnaProvisioningDuringUserCreate() {
        List<Contact> lstContacts = [SELECT Id, FirstName, LastName FROM Contact WHERE DNAMS_Active_User__c = TRUE LIMIT 1];

        Test.startTest();

        User dealerUser = TestUtility.createExternalUser(lstContacts[0].Id, lstContacts[0].FirstName, lstContacts[0].LastName, USER_PROFILE);
        
        Test.stopTest();

        //When Contact was created, DNAMS Active User flag is set to TRUE. Hence DNAMS User flag on User should be set to TRUE.
        List<User> lstUsers = [SELECT Id, DNAMS_User__c FROM User WHERE Id = :dealerUser.Id LIMIT 1];
        System.assertEquals(TRUE, lstUsers[0].DNAMS_User__c, 'DNAMS User flag is expected to be TRUE.');

        //DNAMSBasicExternal permission set is assigned automatically during DNAMS Partner User provisioning.
        List<PermissionSetAssignment> lstPSAs = [SELECT Id, PermissionSet.Name
                                                    FROM PermissionSetAssignment
                                                    WHERE AssigneeId = : lstUsers[0].Id
                                                        AND PermissionSet.Name = :DNA_EXTERNAL_PS
                                                    LIMIT 1];
        System.assertEquals(TRUE, !lstPSAs.isEmpty(), 'DNAMS Basic External Permission Set was not assigned during user provisioning.');
    }

    @IsTest
    static void dnaProvisioningDuringContactUpdate() {
        List<Contact> lstContacts = [SELECT Id, FirstName, LastName, DNAMS_Active_User__c FROM Contact WHERE DNAMS_Active_User__c = FALSE LIMIT 1];
        User dealerUser = TestUtility.createExternalUser(lstContacts[0].Id, lstContacts[0].FirstName, lstContacts[0].LastName, USER_PROFILE);

        Test.startTest();

        lstContacts[0].DNAMS_Active_User__c = TRUE;
        update lstContacts;
        
        Test.stopTest();

        //When Contact was updated, DNAMS Active User flag is set to TRUE. Hence DNAMS User flag on User should be updated to TRUE.
        List<User> lstUsers = [SELECT Id, DNAMS_User__c FROM User WHERE Id = :dealerUser.Id LIMIT 1];
        System.assertEquals(TRUE, lstUsers[0].DNAMS_User__c, 'DNAMS User flag is expected to be TRUE.');

        //DNAMSBasicExternal permission set is assigned automatically when DNAMS Active User flag gets updated to TRUE.
        List<PermissionSetAssignment> lstPSAs = [SELECT Id, PermissionSet.Name
                                                    FROM PermissionSetAssignment
                                                    WHERE AssigneeId = : lstUsers[0].Id
                                                        AND PermissionSet.Name = :DNA_EXTERNAL_PS
                                                    LIMIT 1];
        System.assertEquals(TRUE, !lstPSAs.isEmpty(), 'DNAMS Basic External Permission Set was not assigned during contact update.');
    }

    @IsTest
    static void dnaRevokeDuringContactUpdate() {
        List<Contact> lstContacts = [SELECT Id, FirstName, LastName, DNAMS_Active_User__c FROM Contact WHERE DNAMS_Active_User__c = TRUE LIMIT 1];
        User dealerUser = TestUtility.createExternalUser(lstContacts[0].Id, lstContacts[0].FirstName, lstContacts[0].LastName, USER_PROFILE);

        Test.startTest();

        lstContacts[0].DNAMS_Active_User__c = FALSE;
        update lstContacts;
        
        Test.stopTest();

        //When Contact was updated, DNAMS Active User flag is set to FALSE. Hence DNAMS User flag on User should be updated to FALSE.
        List<User> lstUsers = [SELECT Id, DNAMS_User__c FROM User WHERE Id = :dealerUser.Id LIMIT 1];
        System.assertEquals(FALSE, lstUsers[0].DNAMS_User__c, 'DNAMS User flag is expected to be FALSE.');

        //DNAMSBasicExternal permission set is removed automatically when DNAMS Active User flag gets updated to FALSE.
        List<PermissionSetAssignment> lstPSAs = [SELECT Id, PermissionSet.Name
                                                    FROM PermissionSetAssignment
                                                    WHERE AssigneeId = : lstUsers[0].Id
                                                        AND PermissionSet.Name = :DNA_EXTERNAL_PS
                                                    LIMIT 1];
        System.assertEquals(TRUE, lstPSAs.isEmpty(), 'DNAMS Basic External Permission Set was not revoked during contact update.');
    }
}