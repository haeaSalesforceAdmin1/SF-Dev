@isTest
public without sharing class ContactControllerTest {

    private static final String DEALER_NAME = 'Dealer Test';
    private static final String DISTRICT_NAME = 'SO2 - ALABAMA NORTH';
    private static final String SALES_DISTRICT_NAME = 'SO2 - ALABAMA NORTH';
    private static final String SERVICE_DISTRICT_NAME = 'SO2 - ALABAMA NORTH';
    private static final String REGION_NAME = 'SOUTHERN REGION';
    private static final String HYUNDIA_ORG = 'Hyundai';

    @TestSetup
    static void makeData(){
        
        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(HYUNDIA_ORG);
        Account account = TestUtility.createAccountForDistrictRegionOrg(DEALER_NAME, DISTRICT_NAME, REGION_NAME, HYUNDIA_ORG, 'A0001');
        Account account1 = TestUtility.createAccountForDistrictRegionOrg('Dealer Test2', 'SO2 - ALABAMA NORTH', 'SOUTHERN REGION', 'Hyundai', 'A0002');
    }
    
    public static testMethod void testgetRelatedContacts() {        
        Account acct = new Account(
            Name='HelloWorld'
        );
        insert acct;
        
        Contact con = new Contact(
            AccountId = acct.id,
            lastname = 'testdata', 
            firstname ='testdata1',
            email='test11@gmail.com',
            Active_DPM_User__c = true,
            JobCode__c='DB'
        );
        insert con; 
        
        Contact con1 = new Contact(
            AccountId = acct.id,
            lastname = 'testdata2', 
            firstname ='testdata2',
            email='test1@gmail.com',
            Active_DPM_User__c = true,
            JobCode__c='DP'
        );
        insert con1; 
       
        List<AccountContactRelation> acctcrList =[Select id,Contact.Name,Account.Name,IsDirect,Contact.Email,Contact.JobCode__c,Contact.Active_DPM_User__c,Roles,JobCode__c
            from AccountContactRelation where AccountId = :acct.Id AND Contact.Active_DPM_User__c = true];
        System.debug('Dhiraj ####### '+ acctcrList.size());
        
        ContactController.getRelatedContacts(acct.Id);
        
        
    }
    
}