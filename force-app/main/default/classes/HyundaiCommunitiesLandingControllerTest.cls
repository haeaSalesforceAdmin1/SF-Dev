@isTest
public class HyundaiCommunitiesLandingControllerTest {

    @TestSetup
    static void makeData(){
        //Internal User
        Profile profile = [Select Id from Profile WHERE NAME = 'System Administrator'];
        User user = new User();
        user.FirstName = 'TestUser';
        user.LastName = 'UserAfterUpdate';
        user.Username = 'TestUser' + '' + 'UserAfterUpdate'+'@' + 'UserAfterUpdate' + '.com';
        user.ProfileId = profile.Id;
        user.Email = 'UserAfterUpdate' + 'invalid@acumensolutions.com';
        user.Alias = 'usr123';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        
		insert user;
        DPMConfigurationSettings__c customSetting = new DPMConfigurationSettings__c();
        customSetting.Temp_Genesis_Redirect__c='https://hmausa--stage.sandbox.my.site.com/genesisdealer/login';
        customSetting.Genesis_Redirect__c='https://staging.wdcs.genesisdealerusa.com/irj/portal/iam';
        customSetting.Temp_Hyundai_Redirect__c='https://hmausa--stage.sandbox.my.site.com/hyundaidealer/login';
        customSetting.Hyundai_Redirect__c='https://staging.wdcs.hyundaidealer.com/irj/portal/iam';
        upsert customSetting;
        
        //External User
        Organization__c organization = new Organization__c(Name = 'National');
        insert organization;
        Region__c region = new Region__c(Name = 'SOUTHERN REGION', Organization__c = organization.Id, RegionCode__c = 'SO');
        insert region;
        District__c district = new District__c(Name = 'ALABAMA NORTH', Region__c = region.Id, Organization__c = region.Organization__c, DistrictCode__c = 'SO2', SalesManager__c = UserInfo.getUserId(), DistrictPartsServiceManager__c = UserInfo.getUserId());
        insert district;

        Account account = new Account(Name = 'accountName', ServiceDistrict__c = district.Id, SalesDistrict__c = district.Id, Region__c = district.Region__c, Organization__c = district.Organization__c, DealerCode__c = 'D0001', Active__c = true);
		insert account;		        
        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL1', FirstName = 'TestF1',Email='ba@test.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2',Email='bca@test.com'));
        insert contacts;
        ContactTriggerHandler.run = true;
        
        Profile extprofile = [Select Id from Profile WHERE NAME = 'DPM Partner Community (Hyundai)'];
        User extuser = new User();
        extuser.FirstName = 'TestL1';
        extuser.LastName = 'TestF1';
        extuser.Username = 'TestL1' + '' + 'TestF1'+'@' + 'TestF1' + '.com';
        extuser.ProfileId = extprofile.Id;
        extuser.ContactId=contacts[0].Id;
        extuser.Email = 'TestF1' + 'invalid@acumensolutions.com';
        extuser.Alias = 'usr123';
        extuser.TimeZoneSidKey = 'America/New_York';
        extuser.LocaleSidKey = 'en_US';
        extuser.EmailEncodingKey = 'ISO-8859-1';
        extuser.LanguageLocaleKey = 'en_US';
        extuser.FederationIdentifier='HMA001234';
        
		insert extuser;
        
        
    }
    
    static testMethod void testGenesisLandingTest1() {
		    	
        HyundaiCommunitiesLandingController landingPage = new HyundaiCommunitiesLandingController();
        List<User> users = [select Id,Name, FederationIdentifier from User where lastname='UserAfterUpdate' limit 1];
        DPMConfigurationSettings__c customSetting = DPMConfigurationSettings__c.getOrgDefaults();
        
        test.startTest();
        pageReference response = landingPage.forwardToStartPage();
        test.stopTest();
    }
    static testMethod void testGenesisLandingTest2() {
		    	
        HyundaiCommunitiesLandingController landingPage = new HyundaiCommunitiesLandingController();
        List<User> users = [select Id,Name, FederationIdentifier from User where lastname='TestF1' limit 1];
        DPMConfigurationSettings__c customSetting = DPMConfigurationSettings__c.getOrgDefaults();
        
        test.startTest();
        pageReference response = landingPage.forwardToStartPage();        
        test.stopTest();
    }
}