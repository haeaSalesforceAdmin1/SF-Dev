@isTest
public class ScheduleBatchToRemoveInactiveConTest {


  static User testUser;

    @TestSetup
    static void makeData(){
        UserTriggerHandler.run=false;

       TestUtility.createInternalUser('TestUser', 'UserAfterUpdate', 'System Administrator');
       TestUtility.createInternalUser('TestUser1', 'UserAfterUpdate', 'System Administrator');

       TestUtility.createDPMConfigurationSettings();
       TestUtility.createCurrentEnvironmentCustomSetting();
       TestUtility.createOrganizations();
       TestUtility.createRegionsForOrganizations('Hyundai');
       TestUtility.createDistrictsForRegions();
       TestUtility.createQuarterlySettings();
       Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);

    }
    
 static testmethod void Test1(){
        
        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');
        ContactTriggerHandler.run = false;
      
   
        // ContactTriggerHandler.run = true;
        UserTriggerHandler.run=false;
      user us1 = [SELECT Id, Name, IsActive, Contact.Name, IsPortalEnabled, ContactId from user where firstName='TestUser1' limit 1];
     
       user us = [SELECT Id, Name, IsActive, Contact.Name, IsPortalEnabled, ContactId from user where firstName='TestUser' limit 1];
     us.IsActive=false;
      System.runAs(us1){
    update us;
     }
      
       List<Contact> contacts = new List<Contact>(); 
        contacts.add(new Contact(AccountId = account.Id, LastName = 'UserAfterUpdate', FirstName = 'TestUser',Active_DPM_User__c=false, Email='test6@email.com')); //DPM-5301 changed from DPMActiveUser__c to Active_DPM_User__c by MinheeKim - 2024.05.29
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='test7@email.com'));
        
    // us.ContactId=contacts[0].id;
         
     
             insert contacts;

      Test.startTest(); 
     
      ScheduleBatchToRemoveInactiveContacts sc = new ScheduleBatchToRemoveInactiveContacts();
      sc.batchSize=200;
      system.schedule('test11', '1 0 0 ? * * *', sc);
      Test.stopTest();
    //    User userGM = TestUtility.createExternalUser(contacts[0].Id, 'TestL1', 'TestF1', 'DPM Partner Community (Hyundai)');
        
     //   HMAUserProvisioningTriggerHandler.run = false;
       // HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = userGM.Id);
      //  userProvisioning.AccessTypes__c = 'DPM_Eval_ExtCE/A0001,DPM_AP_ExtRCE/A0001,DPM_AP_ExtRCE/A0001,DPM_Eval_ExtCE/A0001,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
        //userProvisioning.AccessTypes__c = 'DPM_Eval_ExtCE/NJ039,DPM_AP_ExtRCE/NJ039,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
        //insert userProvisioning;

    }

}