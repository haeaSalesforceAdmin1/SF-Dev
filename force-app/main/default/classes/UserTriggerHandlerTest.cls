/**
* @date 09/28/2020
* @description 
*/
@isTest
public with sharing class UserTriggerHandlerTest {


    @TestSetup
    static void makeData(){
        ContentDocumentLinkTriggerHandler.run = false;
       TestUtility.createInternalUser('TestUser', 'UserAfterUpdate', 'System Administrator');
       TestUtility.createInternalUser('TestUser', 'UserBeforeUpdate', 'Hyundai User Internal');
       TestUtility.createDPMConfigurationSettings();
       TestUtility.createCurrentEnvironmentCustomSetting();

       TestUtility.createOrganizations();
       TestUtility.createRegionsForOrganizations('Hyundai');
       TestUtility.createDistrictsForRegions();
       TestUtility.createQuarterlySettings();

       Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
       List<Account> accList = new List<Account>();
       Account acc = new Account(Name = 'Test Account', DealerCode__c='MD034');
       accList.add(acc);
       Account acc2 = new Account(Name = 'Test Account2', DealerCode__c='MD703');
       accList.add(acc2);
       Account acc3 = new Account(Name = 'Test Account3', DealerCode__c='TX090');
       accList.add(acc3);
       Account acc4 = new Account(Name = 'Test Account4', DealerCode__c='TWE00001');
       accList.add(acc4);
       insert accList;

       Contact con = new Contact(LastName = 'Testcon', Email='test@test.con', AccountId=acc.Id, JobCode__c='GM');
       insert con;
       Contact con2 = new Contact(LastName = 'Testcon2', Email='test2@test.con', AccountId=acc.Id, JobCode__c='DP');
       insert con2;

       Contact con3 = new Contact(LastName = 'DPM test contact user', Email='test3@test.con', AccountId=acc.Id, Salesforce_Active_User__c =true);
       insert con3;
        
       Contact con4 = new Contact(LastName = 'DNA test contact user', Email='test4@test.con', AccountId=acc.Id, Salesforce_Active_User__c =true, DNAMS_Active_User__c=true, DNAMS_Role__c='Dealer Principal');
       insert con4;

       AccountContactRelation acr1 = [SELECT Id, AccountId, ContactId, JobCode__c FROM AccountContactRelation WHERE ContactId = :con.Id]; 
       AccountContactRelation acr2 = [SELECT Id, AccountId, ContactId, JobCode__c FROM AccountContactRelation WHERE ContactId = :con2.Id];

       acr1.JobCode__c = 'GM';
       acr2.JobCode__c = 'DP';
       update acr1;
       update acr2;

       User sysadmin = [SELECT Id FROM User WHERE LastName = 'UserAfterUpdate'];
       Profile profile = [Select Id from Profile WHERE NAME = 'DPM Partner Community (Hyundai)'];
       User testUser = new User();
       testUser.FirstName = 'External2';
       testUser.LastName = 'Test';
       testUser.Username = user.FirstName + '' + user.LastName+'@' + user.LastName + '.com';
       testUser.ProfileId = profile.Id;
       testUser.ContactId = con.Id;
       testUser.Email = user.LastName + 'invalid@acumensolutions.com';
       testUser.Alias = 'usr123';
       testUser.TimeZoneSidKey = 'America/New_York';
       testUser.LocaleSidKey = 'en_US';
       testUser.EmailEncodingKey = 'ISO-8859-1';
       testUser.LanguageLocaleKey = 'en_US';
       testUser.AccessTypes__c = 'DPM_BasicExt/MD703,DPM_FinExtGMA/MD703,DPM_AP_ExtRO/MD034,DPM_BasicExt/MD034,DPM_GenUserExt,DPM_HyundaiExt';
       
       insert testUser;
       
       
       User testUser2 = new User();
        testUser2.FirstName = 'ExternalUSer';
        testUser2.LastName = 'TestUser';
        testUser2.Username = testUser2.FirstName + '' + testUser2.LastName+'@' + testUser2.LastName + '.com';
        testUser2.ProfileId = profile.Id;
        testUser2.ContactId = con2.Id;
        testUser2.Email = user.LastName + 'invalid@acumensolutions.com';
        testUser2.Alias = 'usr123';
        testUser2.TimeZoneSidKey = 'America/New_York';
        testUser2.LocaleSidKey = 'en_US';
        testUser2.EmailEncodingKey = 'ISO-8859-1';
        testUser2.LanguageLocaleKey = 'en_US';
        testUser2.AccessTypes__c = 'DPM_BasicExt/MD703,DPM_FinExtGMA/MD703,DPM_AP_ExtRO/MD034,DPM_BasicExt/MD034,DPM_GenUserExt,DPM_HyundaiExt';
        
        insert testUser2;
        
        Evaluation__c eval = new Evaluation__c(Name='test eval', OwnerId=sysadmin.Id, Account__c = acc.Id);
        insert eval;
        Action_Plan__c ap = new Action_Plan__c(Name = 'Test', Evaluation__c = eval.Id, OwnerId=testUser2.Id, Account__c=acc.Id);
        insert ap;

        Action_Plan__Share apshare = new Action_Plan__Share(ParentId = ap.Id, UserOrGroupId=testUser.Id, RowCause = 'Dealer_Action_Plan_Sharing__c', AccessLevel = 'Read');
        insert apshare;
        Action_Plan__Share apshare2 = new Action_Plan__Share(ParentId = ap.Id, UserOrGroupId=testUser2.Id, RowCause = 'Dealer_Action_Plan_Sharing__c', AccessLevel = 'Read');
        insert apshare2;

        User testUser3 = new User();
        testUser3.FirstName = 'ExternalUser3';
        testUser3.LastName = 'TestUser3';
        testUser3.Username = testUser3.FirstName + '' + testUser3.LastName+'@' + testUser3.LastName + '.com';
        testUser3.ProfileId = profile.Id;
        testUser3.ContactId = con4.Id;
        testUser3.IsActive=true;
        testUser3.Email = user.LastName + 'invalid@acumensolutions.com';
        testUser3.Alias = 'usr123';
        testUser3.TimeZoneSidKey = 'America/New_York';
        testUser3.LocaleSidKey = 'en_US';
        testUser3.EmailEncodingKey = 'ISO-8859-1';
        testUser3.LanguageLocaleKey = 'en_US';
        testUser3.AccessTypes__c = 'DNA_GenesisExt/TWE00001,DNA_HyundaiExt/TX090,DPM_BasicExt/MD703,DPM_FinExtGMA/MD703,DPM_AP_ExtRO/MD034,DPM_BasicExt/MD034,DPM_GenUserExt,DPM_HyundaiExt,DNA_BasicExt/MD034,DNA_BasicExt/MD703';
        insert testUser3;

        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        acrList.add(new AccountContactRelation(ContactId=con4.Id,AccountId=acc2.Id,IsActive=true, DNAMSAccountUser__c=true, Roles='Dealer Principal'));
        acrList.add(new AccountContactRelation(ContactId=con4.Id,AccountId=acc3.Id,IsActive=true,  DNAMSAccountUser__c=true, Roles='Dealer Principal'));
        acrList.add(new AccountContactRelation(ContactId=con4.Id,AccountId=acc4.Id,IsActive=true, DNAMSAccountUser__c=true, Roles='Dealer Principal'));
        insert acrList;
    }

    static testMethod void testUserTriggerHandler() {

        List<User> users = [select Id from User testUser limit 1];

        System.assertEquals(1, users.size());
    }


    static testMethod void testUserTriggerHandlerSettingProvisionFlagWithTriggerOff() {

        List<User> users = [select Id from User where lastname='UserAfterUpdate' limit 1];
        User userToUpdate = users[0];

        Test.startTest();
        
        userToUpdate.Autoprovision__c = true;
        userToUpdate.AccessTypes__c = 'RoleHyundaiNationalEmployee,BulkHardDelete,CreateFileLibraries,DPM_LogAccess';
        UserTriggerHandler.run = false;
        HMAObjectService.dbUpdate(userToUpdate);
        
        Test.stopTest();

        users = [select Id from User where Id = :users[0].Id and Autoprovision__c = true limit 1];
        System.assertEquals(1, users.size());
    }


    static testMethod void testUserTriggerHandlerSettingProvisionFlagWithTriggerOn() {

        List<User> users = [select Id from User where LastName = 'UserAfterUpdate' limit 1];
        User userToUpdate = users[0];

        List<PermissionSetAssignment> permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                                        where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access')];
        System.assertEquals(0, permissionSetAssignments.size());

        Test.startTest();
        userToUpdate.AccessTypes__c = 'DPM_LogAccess';
        userToUpdate.Autoprovision__c = true;
        HMAObjectService.dbUpdate(userToUpdate);
        Test.stopTest();

        users = [select Id from User where Id = :users[0].Id and Autoprovision__c = true limit 1];
        System.assertEquals(0, users.size());

        List<HMALogs__c> logs = [select Id, FullLog__c from HMALogs__c];
        System.assertEquals(0, logs.size());

        List<HMAUserProvisioning__c> userProvisioning = [select Id from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisioning.size());

        permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                            where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access')];
        System.assertEquals(1, permissionSetAssignments.size());

    }

    static testMethod void testUserTriggerHandlerProvisionRole() {

        List<User> users = [select Id from User where LastName = 'UserBeforeUpdate' limit 1];
        User userToUpdate = users[0];

        List<PermissionSetAssignment> permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                                        where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access')];
        System.assertEquals(0, permissionSetAssignments.size());

        Test.startTest();
        userToUpdate.AccessTypes__c = 'DPM_RMM_CE,DPM_LogAccess';
        userToUpdate.Autoprovision__c = true;
        userToUpdate.FederationIdentifier  = 'testUser2@hmausa.com'; //Added by MinheeKim -DPM-5934 12.04.2024
        HMAObjectService.dbUpdate(userToUpdate);
        Test.stopTest();

        users = [select Id from User where Id = :users[0].Id and Autoprovision__c = true limit 1];
        System.assertEquals(0, users.size());

        List<HMALogs__c> logs = [select Id, FullLog__c from HMALogs__c];
        System.assertEquals(0, logs.size());

        List<HMAUserProvisioning__c> userProvisioning = [select Id from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisioning.size());

        permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                            where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access')];
        System.assertEquals(1, permissionSetAssignments.size());

    }


    static testMethod void testUserTriggerHandlerSettingProvisionFlagWithTriggerOnAndPermissionSetsAlreadyAssigned() {

        List<User> users = [select Id from User where LastName = 'UserAfterUpdate' limit 1];
        User userToUpdate = users[0];

        TestUtility.createPermissionSetAssignmentForUser(userToUpdate.Id, 'Bulk_Hard_Delete');
        TestUtility.createPermissionSetAssignmentForUser(userToUpdate.Id, 'Create_File_Libraries');
        TestUtility.createPermissionSetAssignmentForUser(userToUpdate.Id, 'DPM_Log_Access');

        List<PermissionSetAssignment> permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                                        where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access')];
        System.assertEquals(3, permissionSetAssignments.size());

        Test.startTest();
        userToUpdate.AccessTypes__c = 'DPM_LogAccess';
        userToUpdate.Autoprovision__c = true;
        HMAObjectService.dbUpdate(userToUpdate);
        Test.stopTest();

        users = [select Id from User where Id = :users[0].Id and Autoprovision__c = true limit 1];
        System.assertEquals(0, users.size());

        List<HMALogs__c> logs = [select Id, FullLog__c from HMALogs__c];
        System.assertEquals(0, logs.size());

        List<HMAUserProvisioning__c> userProvisioning = [select Id from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisioning.size());

        permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                            where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access')];
        //System.assertEquals(1, permissionSetAssignments.size());

    }

    static testMethod void testUserTriggerHandlerSettingProvisionFlagWithTriggerOnAndPermissionSetsAlreadyAssignedRemoveValues() {

        List<User> users = [select Id from User where lastname='UserAfterUpdate' limit 1];
        User userToUpdate = users[0];

        TestUtility.createPermissionSetAssignmentForUser(userToUpdate.Id, 'Bulk_Hard_Delete');
        TestUtility.createPermissionSetAssignmentForUser(userToUpdate.Id, 'Create_File_Libraries');
        TestUtility.createPermissionSetAssignmentForUser(userToUpdate.Id, 'DPM_Log_Access');

        List<PermissionSetAssignment> permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                                        where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access', 'DPM_Admin', 'DPM_Organization_Admin','DPM_Survey_Admin')];
        System.assertEquals(3, permissionSetAssignments.size());

        Test.startTest();
        userToUpdate.AccessTypes__c = '';
        userToUpdate.Autoprovision__c = true;
        HMAObjectService.dbUpdate(userToUpdate);
        Test.stopTest();

        users = [select Id from User where Id = :users[0].Id and Autoprovision__c = true limit 1];
        System.assertEquals(0, users.size());

        List<HMALogs__c> logs = [select Id, FullLog__c from HMALogs__c];
        System.assertEquals(0, logs.size());

        List<HMAUserProvisioning__c> userProvisioning = [select Id from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisioning.size());

        permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access', 'DPM_Admin', 'DPM_Organization_Admin','DPM_Survey_Admin')];
        //System.assertEquals(0, permissionSetAssignments.size());

        
    }


    static testMethod void testUserTriggerHandlerSettingProvisionFlagWithTriggerOnSetProfileAndRole() {

        List<User> users = [select Id from User where LastName = 'UserAfterUpdate' limit 1];
        User userToUpdate = users[0];

        List<PermissionSetAssignment> permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                                        where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access', 'DPM_Admin', 'DPM_Organization_Admin','DPM_Survey_Admin')];
        System.assertEquals(0, permissionSetAssignments.size());

        Test.startTest();
        userToUpdate.AccessTypes__c = '';
        userToUpdate.Autoprovision__c = true;
        HMAObjectService.dbUpdate(userToUpdate);
        Test.stopTest();

        users = [select Id, UserRole.DeveloperName, Profile.Name from User where Id = :users[0].Id and Autoprovision__c = false limit 1];
        System.assertEquals(1, users.size());

        List<HMALogs__c> logs = [select Id, FullLog__c from HMALogs__c];
        System.assertEquals(0, logs.size());

        List<HMAUserProvisioning__c> userProvisioning = [select Id from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisioning.size());

        permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access', 'DPM_Admin', 'DPM_Organization_Admin','DPM_Survey_Admin')];
        System.assertEquals(0, permissionSetAssignments.size());

    }

    static testMethod void testUserTriggerHandlerSettingProvisionFlagWithTriggerOnPermissionSetGroup() {

        List<User> users = [select Id from User where LastName = 'UserAfterUpdate' limit 1];
        User userToUpdate = users[0];

        List<PermissionSetAssignment> permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                                        where AssigneeId = :userToUpdate.Id and PermissionSetGroup.DeveloperName in ('Users_ADMIN_DPM', 'Internal_User_DSM_DPM','DPM - Hyundai Community')];
        System.assertEquals(0, permissionSetAssignments.size());

        Test.startTest();
        userToUpdate.AccessTypes__c = '0';
        userToUpdate.Autoprovision__c = true;
        
        HMAObjectService.dbUpdate(userToUpdate);
        Test.stopTest();

        List<HMAUserProvisioning__c> userProvisioning = [select Id from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisioning.size());

        users = [select Id, UserRole.DeveloperName, Profile.Name from User where Id = :users[0].Id and Autoprovision__c = false limit 1];
        System.assertEquals(1, users.size());

        List<HMALogs__c> logs = [select Id, FullLog__c from HMALogs__c];
        System.assertEquals(0, logs.size());

        permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                where AssigneeId = :userToUpdate.Id and PermissionSetGroup.DeveloperName in ('Users_ADMIN_DPM', 'Internal_User_DSM_DPM')];
        System.assertEquals(0, permissionSetAssignments.size());

    }

    static testMethod void testUserTriggerHandlerSettingProvisionFlagWithTriggerOnPermissionSetGroupWithExistingGroups() {

        List<User> users = [select Id from User where LastName = 'UserAfterUpdate' limit 1];
        User userToUpdate = users[0];

        TestUtility.createPermissionSetGroupAssignmentForUser(userToUpdate.Id, 'Users_ADMIN_DPM');

        List<PermissionSetAssignment> permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                                        where AssigneeId = :userToUpdate.Id and PermissionSetGroup.DeveloperName in ('Users_ADMIN_DPM', 'Internal_User_DSM_DPM')];
        System.assertEquals(1, permissionSetAssignments.size());

        Test.startTest();
        userToUpdate.AccessTypes__c = '';
        userToUpdate.Autoprovision__c = true;
        HMAObjectService.dbUpdate(userToUpdate);
        Test.stopTest();

        users = [select Id, UserRole.DeveloperName, Profile.Name from User where Id = :users[0].Id and Autoprovision__c = false limit 1];
        System.assertEquals(1, users.size());

        List<HMALogs__c> logs = [select Id, FullLog__c from HMALogs__c];
        System.assertEquals(0, logs.size());

        List<HMAUserProvisioning__c> userProvisioning = [select Id from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisioning.size());

        permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                where AssigneeId = :userToUpdate.Id and PermissionSetGroup.DeveloperName in ('Users_ADMIN_DPM', 'Internal_User_DSM_DPM')];
        System.assertEquals(0, permissionSetAssignments.size());

    }


    static testMethod void testUserTriggerHandlerSettingProvisionFlagWithTriggerOnPermissionSetGroupWithExistingGroupsRemoveAccess() {

        List<User> users = [select Id from User where LastName = 'UserAfterUpdate' limit 1];
        User userToUpdate = users[0];
        
        TestUtility.createPermissionSetGroupAssignmentForUser(userToUpdate.Id, 'Users_ADMIN_DPM');

        List<PermissionSetAssignment> permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                                        where AssigneeId = :userToUpdate.Id and PermissionSetGroup.DeveloperName in ('Users_ADMIN_DPM')];
        System.assertEquals(1, permissionSetAssignments.size());

        Test.startTest();
        userToUpdate.AccessTypes__c = 'ActionPlanConfidentialAccess';
        userToUpdate.Autoprovision__c = true;
        HMAObjectService.dbUpdate(userToUpdate);

        Test.stopTest();

        users = [select Id, UserRole.DeveloperName, Profile.Name from User where Id = :users[0].Id and Autoprovision__c = false limit 1];
        System.assertEquals(1, users.size());

        List<HMALogs__c> logs = [select Id, FullLog__c from HMALogs__c];
        System.assertEquals(0, logs.size());
        

        List<HMAUserProvisioning__c> userProvisioning = [select Id, User__c from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisioning.size());

        permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                where AssigneeId = :userToUpdate.Id and PermissionSetGroup.DeveloperName in ('Users_ADMIN_DPM')];
        System.assertEquals(0, permissionSetAssignments.size());

        HMAUserProvisioningQueuableComplete userProvisioningCompleteQueueable = new HMAUserProvisioningQueuableComplete(userProvisioning);
        System.enqueueJob(userProvisioningCompleteQueueable);
    }

    static testMethod void testUpdateUserRoleAndProfileUpdates() {

        User minimumProfileUser = TestUtility.createInternalUser('UserAfterUpdateMinAccess', 'UserAfterUpdateMinAccess', 'Minimum Access - Salesforce Platform');
        
        HMAUserProvisioningTriggerHandler.run = false;
        HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = minimumProfileUser.Id, AccessTypes__c = 'TEST_Access_Type');
        insert userProvisioning;
        HMAUserProvisioningTriggerHandler.run = true;

        List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisionings.size());

        Test.startTest();
        HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionings, true);
        System.enqueueJob(userProvisioningQueueable);
        Test.stopTest();
    }
    
    /*static testMethod void testAutoProvisioning() {

        System.debug(LoggingLevel.ERROR, 'testAutoProvisioning');
        List<User> users = [select Id from User where LastName = 'UserAfterUpdate' limit 1];
        User userToUpdate = users[0];

        List<PermissionSetAssignment> permissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment 
                                                                        where AssigneeId = :userToUpdate.Id and PermissionSet.Name in ('Bulk_Hard_Delete', 'Create_File_Libraries', 'DPM_Log_Access')];
        System.assertEquals(0, permissionSetAssignments.size());

        Test.startTest();
        userToUpdate.AccessTypes__c = 'DPM_DSM_MS5';
        userToUpdate.Autoprovision__c = true;
        update userToUpdate;
        Test.stopTest();
        System.debug(LoggingLevel.ERROR, 'testAutoProvisioning');
    }*/

    static testMethod void testCallDeleteFunctions() {
        
        UserTriggerHandler triggerHandler =  new UserTriggerHandler();
        triggerHandler.beforeDelete(null);
        triggerHandler.afterDelete(null);
        triggerHandler.afterUndelete(null);
    }

    static testmethod void testInsertUserWithProvisioning() {

        User userRecord = TestUtility.createInternalUserObject('TTTTT','FFFFFF','System Administrator');
        userRecord.AccessTypes__c = 'DPM_LogAccess';
        userRecord.Autoprovision__c = true;

        Test.startTest();
        insert userRecord;
        Test.stopTest();

        List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisionings.size());
    }


    static testMethod void testUserProvisioningWithMultipleProfiles() {

        User minimumProfileUser = TestUtility.createInternalUser('UserAfterUpdateMinAccess', 'UserAfterUpdateMinAccess', 'Minimum Access - Salesforce Platform');
        
        HMAUserProvisioningTriggerHandler.run = false;
        HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = minimumProfileUser.Id, AccessTypes__c = 'DPM_BasicInt,DPM_HyunNatEmp,DPM_Eval_IntCE,DPM_AP_IntRCE,DPM_TopicMgr,DPM_SurvIntUsr,DPM_EvalRestrct,DPM_AP_Conf,DPM_FinDataHMA,DPM_FinDataGMA,DPM_GenNatEmp');
        //HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = minimumProfileUser.Id, AccessTypes__c = 'DPM_BasicInt,DPM_HyunNatEmp,DPM_Eval_IntCE,DPM_AP_IntRCE,DPM_TopicMgr,DPM_SurvIntUsr,DPM_EvalRestrct,DPM_AP_Conf,DPM_FinDataHMA,DPM_FinDataGMA');
        insert userProvisioning;
        HMAUserProvisioningTriggerHandler.run = true;

        List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisionings.size());

        Test.startTest();
        HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionings, false);
        System.enqueueJob(userProvisioningQueueable);
        Test.stopTest();


        List<User> users = [select Id, Profile.Name, UserRole.DeveloperName from User where Id = :minimumProfileUser.Id];
        //System.assertEquals('National User Internal', users[0].Profile.Name);
        //System.assertEquals('Hyundai_National', users[0].UserRole.DeveloperName);
    }

    /*DPM-4973 changed to comments by MH - 2023.11.15
    static testMethod void testDeprovisioningAUserWithSalesPlatformProfile() {

        User minimumProfileUser = TestUtility.createInternalUser('UserAfterUpdateMinAccess', 'UserAfterUpdateMinAccess', 'National User Internal');
        
        HMAUserProvisioningTriggerHandler.run = false;
        HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = minimumProfileUser.Id, AccessTypes__c = '');
        //HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = minimumProfileUser.Id, AccessTypes__c = 'DPM_BasicInt,DPM_HyunNatEmp,DPM_Eval_IntCE,DPM_AP_IntRCE,DPM_TopicMgr,DPM_SurvIntUsr,DPM_EvalRestrct,DPM_AP_Conf,DPM_FinDataHMA,DPM_FinDataGMA');
        insert userProvisioning;
        HMAUserProvisioningTriggerHandler.run = true;

        List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisionings.size());

        Test.startTest();
        HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionings, false);
        System.enqueueJob(userProvisioningQueueable);
        Test.stopTest();


        List<User> users = [select Id, Profile.Name, UserRoleId, UserRole.DeveloperName from User where Id = :minimumProfileUser.Id];
        System.assertEquals('Minimum Access - Salesforce Platform', users[0].Profile.Name);
        System.assertEquals(null, users[0].UserRoleId);
    }

    static testMethod void testDeprovisioningAUserWithSalesforceLicenseProfile() {

        User minimumProfileUser = TestUtility.createInternalUser('UserAfterUpdateMinAccess', 'UserAfterUpdateMinAccess', 'System Administrator');
        
        HMAUserProvisioningTriggerHandler.run = false;
        HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = minimumProfileUser.Id, AccessTypes__c = '');
        //HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = minimumProfileUser.Id, AccessTypes__c = 'DPM_BasicInt,DPM_HyunNatEmp,DPM_Eval_IntCE,DPM_AP_IntRCE,DPM_TopicMgr,DPM_SurvIntUsr,DPM_EvalRestrct,DPM_AP_Conf,DPM_FinDataHMA,DPM_FinDataGMA');
        insert userProvisioning;
        HMAUserProvisioningTriggerHandler.run = true;

        List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisionings.size());

        Test.startTest();
        HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionings, false);
        System.enqueueJob(userProvisioningQueueable);
        Test.stopTest();


        List<User> users = [select Id, Profile.Name, UserRoleId, UserRole.DeveloperName from User where Id = :minimumProfileUser.Id];
        System.assertEquals('Minimum Access - Salesforce', users[0].Profile.Name);
        System.assertEquals(null, users[0].UserRoleId);
    }*/


    //DPM_Eval_ExtCE/NJ039,DPM_AP_ExtRCE/NJ039,DPM_AP_ExtRCE/NJ701,DPM_Eval_ExtCE/NJ701,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt	


    static testMethod void testMultipleDealersWithDuplicatePermissionSets() {
        UserRole userRole = [Select Id, DeveloperName From UserRole Where Name = 'System Admin' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        // User adminUser = [select Id from User where profile.Name='System Administrator' limit 1];
        System.runAs(adminUser){
            Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');

            ContactTriggerHandler.run = false;
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL1', FirstName = 'TestF1',Email='ba@test.com'));
            contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2',Email='bca@test.com'));
            insert contacts;
            ContactTriggerHandler.run = true;

            User userGM = TestUtility.createExternalUser(contacts[0].Id, 'TestL1', 'TestF1', 'DPM Partner Community (Hyundai)');
                    
            HMAUserProvisioningTriggerHandler.run = false;
            HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = userGM.Id);
            userProvisioning.AccessTypes__c = 'DPM_Eval_ExtCE/A0001,DPM_AP_ExtRCE/A0001,DPM_AP_ExtRCE/A0001,DPM_Eval_ExtCE/A0001,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
            //userProvisioning.AccessTypes__c = 'DPM_Eval_ExtCE/NJ039,DPM_AP_ExtRCE/NJ039,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
            insert userProvisioning;

            List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
            System.assertEquals(1, userProvisionings.size());

            HMAUserProvisioningTriggerHandler.run = true;

            Test.startTest();
            HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionings, false);
            System.enqueueJob(userProvisioningQueueable);

            Test.stopTest();

            List<PermissionSetAssignment> perissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment where AssigneeId = :userGM.Id ];
            //System.debug(LoggingLevel.ERROR, perissionSetAssignments)

            for(PermissionSetAssignment perissionSetAssignment:perissionSetAssignments) {
                System.debug(LoggingLevel.ERROR, perissionSetAssignment.PermissionSet.Name);
            }
            System.assertEquals(9, perissionSetAssignments.size());

            List<User> users = [select Id, Profile.Name, UserRoleId, UserRole.DeveloperName from User where Id = :userGM.Id];
            System.assertEquals('DPM Partner Community (Hyundai)', users[0].Profile.Name);


            //System.assertEquals(null, users[0].UserRoleId);
        }
    }

    static testMethod void testMultipleDealersWithoutDuplicatePermissionSets() {

        UserRole userRole = [Select Id, DeveloperName From UserRole Where Name = 'System Admin' Limit 1];
    
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
    
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
            Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');

            ContactTriggerHandler.run = false;
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL1', FirstName = 'TestF1',Email='ca@test.com'));
            contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2',Email='cc@test.com'));
            insert contacts;
            ContactTriggerHandler.run = true;

            User userGM = TestUtility.createExternalUser(contacts[0].Id, 'TestL1', 'TestF1', 'DPM Partner Community (Hyundai)');
            
            EvaluationTriggerHandler.run = false;
            Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id);
            insert evaluation;
            EvaluationTriggerHandler.run = true;

            HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');
            apexSharing.add(evaluation, userGM.Id, 'Edit', Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c);
            apexSharing.share();

            HMAUserProvisioningTriggerHandler.run = false;
            HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = userGM.Id);
            userProvisioning.AccessTypes__c = 'DPM_Eval_ExtCE/A0001,DPM_AP_ExtRCE/A0001,DPM_AP_ExtRCE/A0001,DPM_Eval_ExtCE/NJ701,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
            //userProvisioning.AccessTypes__c = 'DPM_Eval_ExtCE/NJ039,DPM_AP_ExtRCE/NJ039,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
            insert userProvisioning;

            List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
            System.assertEquals(1, userProvisionings.size());

            HMAUserProvisioningTriggerHandler.run = true;

            Test.startTest();
            HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionings, false);
            System.enqueueJob(userProvisioningQueueable);

            Test.stopTest();

            List<PermissionSetAssignment> perissionSetAssignments = [select Id from PermissionSetAssignment where AssigneeId = :userGM.Id ];
            System.assertEquals(9, perissionSetAssignments.size());

            List<User> users = [select Id, Profile.Name, UserRoleId, UserRole.DeveloperName from User where Id = :userGM.Id];
            System.assertEquals('DPM Partner Community (Hyundai)', users[0].Profile.Name);

        }
        //System.assertEquals(null, users[0].UserRoleId);
    }

    static testMethod void testMultipleDealersWithoutDuplicatePermissionSetsTwo() {

        //Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');
        User minimumProfileUser = TestUtility.createInternalUser('UserAfterUpdateMinAccess', 'UserAfterUpdateMinAccess', 'System Administrator');
        
        HMAUserProvisioningTriggerHandler.run = false;
        HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = minimumProfileUser.Id);
        userProvisioning.AccessTypes__c = 'DPM_DPSM_MA1,DPM_DPSM_MA3,DPM_DSM_MA1,DPM_DSM_MA3,DPM_HyundaiEmp,DPM_FinDataHMA';
        //userProvisioning.AccessTypes__c = 'DPM_Eval_ExtCE/NJ039,DPM_AP_ExtRCE/NJ039,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
        insert userProvisioning;

        List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
        System.assertEquals(1, userProvisionings.size());

        HMAUserProvisioningTriggerHandler.run = true;

        Test.startTest();
        HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionings, false);
        System.enqueueJob(userProvisioningQueueable);

        Test.stopTest();

        List<PermissionSetAssignment> perissionSetAssignments = [select Id from PermissionSetAssignment where AssigneeId = :minimumProfileUser.Id ];
        System.assertNotEquals(0, perissionSetAssignments.size());

        List<User> users = [select Id, Profile.Name, UserRoleId, UserRole.DeveloperName from User where Id = :minimumProfileUser.Id];
        //System.assertEquals('DPM Partner Community (Hyundai)', users[0].Profile.Name);


        //System.assertEquals(null, users[0].UserRoleId);
    }

    static testMethod void testMultipleDealersWithoutDuplicatePermissionSetsNumber2() {
        UserRole userRole = [Select Id, DeveloperName From UserRole Where Name = 'System Admin' Limit 1];
    
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
    
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
            Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');

            ContactTriggerHandler.run = false;
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL1', FirstName = 'TestF1',Email='da@test.com'));
            contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2',Email='db@test.com'));
            insert contacts;
            ContactTriggerHandler.run = true;

            User userGM = TestUtility.createExternalUser(contacts[0].Id, 'TestL1', 'TestF1', 'DPM Partner Community (Hyundai)');
            
            HMAUserProvisioningTriggerHandler.run = false;
            HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = userGM.Id);
            userProvisioning.AccessTypes__c = 'DPM_BasicExt/A0001,DPM_BasicExt/A0001,DPM_GenUserExt,DPM_HyundaiExt';
            //userProvisioning.AccessTypes__c = 'DPM_Eval_ExtCE/NJ039,DPM_AP_ExtRCE/NJ039,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
            insert userProvisioning;

            List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
            System.assertEquals(1, userProvisionings.size());

            HMAUserProvisioningTriggerHandler.run = true;

            Test.startTest();
            HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionings, false);
            System.enqueueJob(userProvisioningQueueable);

            Test.stopTest();

            List<PermissionSetAssignment> perissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment where AssigneeId = :userGM.Id ];
            //System.assertEquals(8, perissionSetAssignments.size());
            System.debug(LoggingLevel.ERROR, perissionSetAssignments);

            for(PermissionSetAssignment assignment:perissionSetAssignments) {
                System.debug(LoggingLevel.ERROR, assignment.PermissionSet.Name);
            }

            List<GroupMember> groupMembers = [select Id, Group.Name from GroupMember where UserOrGroupId = :userGM.Id];
            System.debug(LoggingLevel.ERROR, groupMembers);

            for(GroupMember groupMember:groupMembers) {
                System.debug(LoggingLevel.ERROR, groupMember.Group.Name);
            }
            //System.assertEquals(null, users[0].UserRoleId);
        }
    }


    static testMethod void testExistingShares () {
        UserRole userRole = [Select Id, DeveloperName From UserRole Where Name = 'System Admin' Limit 1];
    
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
    
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
            Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');

            ContactTriggerHandler.run = false;
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL1', FirstName = 'TestF1',Email='a@test.com'));
            contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2',Email='ab@test.com'));
            insert contacts;

            User userGM = TestUtility.createExternalUser(contacts[0].Id, 'TestL1', 'TestF1', 'DPM Partner Community (Hyundai)');
            ContactTriggerHandler.run = true;

            EvaluationTriggerHandler.run = false;
            Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id);
            insert evaluation;
            EvaluationTriggerHandler.run = true;

            HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');
            apexSharing.add(evaluation, userGM.Id, 'Edit', Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c);
            apexSharing.share();
            
            HMAUserProvisioningTriggerHandler.run = false;
            HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = userGM.Id);
            userProvisioning.AccessTypes__c = 'DPM_BasicExt/A0001,DPM_BasicExt/A0001,DPM_GenUserExt,DPM_HyundaiExt';
            //userProvisioning.AccessTypes__c = 'DPM_Eval_ExtCE/NJ039,DPM_AP_ExtRCE/NJ039,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
            insert userProvisioning;

            List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
            System.assertEquals(1, userProvisionings.size());

            HMAUserProvisioningTriggerHandler.run = true;

            Test.startTest();
            HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionings, true);
            System.enqueueJob(userProvisioningQueueable);

            Test.stopTest();

            List<PermissionSetAssignment> perissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment where AssigneeId = :userGM.Id ];
            //System.assertEquals(8, perissionSetAssignments.size());
            System.debug(LoggingLevel.ERROR, perissionSetAssignments);

            for(PermissionSetAssignment assignment:perissionSetAssignments) {
                System.debug(LoggingLevel.ERROR, assignment.PermissionSet.Name);
            }

            List<GroupMember> groupMembers = [select Id, Group.Name from GroupMember where UserOrGroupId = :userGM.Id];
            System.debug(LoggingLevel.ERROR, groupMembers);

            for(GroupMember groupMember:groupMembers) {
                System.debug(LoggingLevel.ERROR, groupMember.Group.Name);
            }
            //System.assertEquals(null, users[0].UserRoleId);
        }
    }

    static testMethod void testExistingSharesActionPlan () {
        UserRole userRole = [Select Id, DeveloperName From UserRole Where Name = 'System Admin' Limit 1];
    
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
    
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
            Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');
            ContactTriggerHandler.run = false;
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL1', FirstName = 'TestF1',Email='abc@test.com'));
            contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2',Email='abcd@test.com'));
            insert contacts;
            ContactTriggerHandler.run = true;

            User userGM = TestUtility.createExternalUser(contacts[0].Id, 'TestL1', 'TestF1', 'DPM Partner Community (Hyundai)');
            
            EvaluationTriggerHandler.run = false;
            Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id);
            insert evaluation;
            EvaluationTriggerHandler.run = true;

            Action_PlanTriggerHandler.run = false;
            Action_Plan__c actionPlan= new Action_Plan__c(Account__c = account.Id, Status__c = 'Open', Evaluation__c = evaluation.Id);
            insert actionPlan;
            Action_PlanTriggerHandler.run = true;



            HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
            apexSharing.add(actionPlan, userGM.Id, 'Edit', Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
            apexSharing.share();
            
            HMAUserProvisioningTriggerHandler.run = false;
            HMAUserProvisioning__c userProvisioning = new HMAUserProvisioning__c(User__c = userGM.Id);
            userProvisioning.AccessTypes__c = 'DPM_BasicExt/A0001,DPM_BasicExt/A0001,DPM_GenUserExt,DPM_HyundaiExt';
            
            //userProvisioning.AccessTypes__c = 'DPM_Eval_ExtCE/NJ039,DPM_AP_ExtRCE/NJ039,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
            insert userProvisioning;
            
            List<HMAUserProvisioning__c> userProvisionings = [select Id, User__c, AccessTypes__c from HMAUserProvisioning__c];
            System.assertEquals(1, userProvisionings.size());

            HMAUserProvisioningTriggerHandler.run = true;

            Test.startTest();
            HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionings, true);
            System.enqueueJob(userProvisioningQueueable);

            Test.stopTest();

            List<PermissionSetAssignment> perissionSetAssignments = [select Id, PermissionSet.Name from PermissionSetAssignment where AssigneeId = :userGM.Id ];
            //System.assertEquals(8, perissionSetAssignments.size());
            System.debug(LoggingLevel.ERROR, perissionSetAssignments);

            for(PermissionSetAssignment assignment:perissionSetAssignments) {
                System.debug(LoggingLevel.ERROR, assignment.PermissionSet.Name);
            }

            List<GroupMember> groupMembers = [select Id, Group.Name from GroupMember where UserOrGroupId = :userGM.Id];
            System.debug(LoggingLevel.ERROR, groupMembers);

            for(GroupMember groupMember:groupMembers) {
                System.debug(LoggingLevel.ERROR, groupMember.Group.Name);
            }
            //System.assertEquals(null, users[0].UserRoleId);
            
            UserTriggerHelper.prepareAccessTypes('DPM_Eval_ExtCE/A0001,DPM_AP_ExtRCE/A0001,DPM_AP_ExtRCE/A0001,DPM_Eval_ExtCE/A0001,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt');
        }
    }
    static testMethod void testUserTriggerHandlermethod2() {
            Account acc = new Account (
        Name = 'newAcc1',DealerCode__c='CA400'
        );  
        insert acc;
        Contact con = new Contact (
        AccountId = acc.id,Access_Types__c='DPM_AP_ExtRE/CA400 - DPM Action Plan permission for dealer user',
        LastName = 'portalTestUser',Email='ea@test.com'
        );
        insert con;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        System.runAs ( thisUser ) {
        //UserRole ur = [Select PortalType, PortalAccountId From UserRole limit 1];
        Profile p = [select Id,name from Profile where name='DPM Partner Community (Hyundai)' limit 1];
        List<user> u=new List<user>();
        
        User newUser = new User(
        //UserRoleId = '00E3I000000Nfj9',
        profileId = p.id,
        username = 'newUser1@y1.com',
        email = 'pb@ff.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = con.id
        );
            
        insert newUser; 
            newUser.accesstypes__c='DPM_Eval_ExtCE/A0001,DPM_AP_ExtRCE/A0001';
            test.startTest();
        update newUser;
        
            test.stopTest();
            
        }
       }
    

    /**
    * @description Test a scenario that User is being deactivated by using IsActive standard field.
    * @author LJ: liamjeong@haeaus.com | 2023-08-10 
    **/
    @IsTest
    static void tesDeactivatingUser_Positive(){
        
        User deactivatingUser;

        try {
        
//            deactivatingUser = TestUtility.createInternalUser('Deactivating', 'Positive Test', 'Hyundai User Internal', 'Genesis Market Manager');
            deactivatingUser = TestUtility.createInternalUser('Deactivating', 'Positive Test', 'Hyundai User Internal');
            ////System.debug(LoggingLevel.DEBUG, 'LoggingLevel.DEBUG: ' + deactivatingUser);
            Assert.areNotEqual(null, deactivatingUser);

            Test.startTest();

            List<Group> groups = new List<Group>();
            List<GroupMember> groupsMembers = new List<GroupMember>();

            groups = [
                            SELECT Id, Name, DeveloperName, Email //, QueueRoutingConfigId
                            FROM Group
                            WHERE Type = 'Regular'
                            LIMIT 5
                     ];

            for (Group grp : groups) {

                groupsMembers.add(new GroupMember(GroupId=grp.Id, UserOrGroupId=deactivatingUser.Id));
                
            }
            
            insert groupsMembers;

            deactivatingUser.IsActive = false;
            deactivatingUser.AccessTypes__c = 'DPM_AP_ExtRCE/A0001,DPM_Eval_ExtCE/A0001,DPM_BasicExt,DPM_HyundaiExt,DPM_GenUserExt';
            update deactivatingUser;

            Test.stopTest();

            assertDeactivatedUser(deactivatingUser.Id);            

        } catch (Exception e) {
            
            System.debug(LoggingLevel.ERROR, 'Error occurred while testing in UserTriggerHandlerTest.tesDeactivatingUser_Positive');
            System.debug(LoggingLevel.ERROR, e.getMessage());

        }        

    }

    /**
    * @description This is @future method confirming whether or not User's role & AccessTypes__c & Group Assignment were cleared properly
    * @author LJ: liamjeong@haeaus.com | 2023-08-10 
    * @param Id deactivatedUserId 
    **/
    @future
    static void assertDeactivatedUser(Id deactivatedUserId){

        User deactivatedUser;
        deactivatedUser = [SELECT Id, Name, UserRoleId, AccessTypes__c FROM User WHERE Id=:deactivatedUserId LIMIT 1];

        System.debug(LoggingLevel.DEBUG, 'LoggingLevel.DEBUG: deactivatingUser.UserRoleId: ' + deactivatedUser.UserRoleId);
        Assert.areEqual(null, deactivatedUser.UserRoleId, 'Deactivated User\'s UserRoleId should be removed');

        System.debug(LoggingLevel.DEBUG, 'LoggingLevel.DEBUG: deactivatingUser.AccessTypes__c: ' + deactivatedUser.AccessTypes__c);
        Assert.areEqual(null, deactivatedUser.AccessTypes__c, 'Deactivated User\'s AccessTypes__c should be removed');

        List<GroupMember> groupMembers = new List<GroupMember>();
            groupMembers = [
                                SELECT Id 
                                FROM GroupMember 
                                WHERE UserOrGroupId =: deactivatedUserId
                            ];
            ////System.debug(LoggingLevel.DEBUG, 'LoggingLevel.DEBUG: groupMembers.size(): ' + groupMembers.size());
            Assert.areEqual(0, groupMembers.size(), 'No Groups should be associated with the deactivated User');

    }

    /**
    * @description Test a scenario that external User's contact is deleted.
    * @author Minheekima@haeaus.com | 2023-12-05 
    **/
       @isTest
    static void testUserTriggerQueueable() {
        UserRole userRole = [Select Id, DeveloperName From UserRole Where Name = 'System Admin' Limit 1];
    
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
    
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
            Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0002');
                List<Contact> contacts = new List<Contact>();
                contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL10', FirstName = 'TestF10',Email='ba10@test.com'));
                
            insert contacts;

                List<Id> contactIdsToDelete = new List<Id>{contacts[0].Id};

            System.enqueueJob(new UserTriggerQueueable(contactIdsToDelete));


            System.assertEquals(1, [SELECT count() FROM Contact WHERE Id IN :contactIdsToDelete]);
        }

    }

    @IsTest
    static void testIsInternalUser() {
        Profile partnerProfile = [SELECT Id, Name FROM Profile WHERE Name like '%Partner%' LIMIT 1];

        User partnerUser = new User(
                FirstName = 'Partner',
                LastName = 'User',
                ProfileId = partnerProfile.Id
        );

        Boolean isInternalPartnerUser = HMAUserProvisioningService.isInternalUser(partnerUser);

        System.assertEquals(false, isInternalPartnerUser);
    }

    @IsTest
    static void testExtractDealerCodes() {

        List<String> accessTypes = new List<String> {'ABC/123', 'DEF/456', 'GHI/789'};

        Set<String> dealerCodes = HMAUserProvisioningService.extractDealerCodes(accessTypes);

        System.assertEquals(3, dealerCodes.size(), 'incorrect number of dealerCodes extracted');
        System.assertEquals(true, dealerCodes.contains('123'), 'dealer code 123 was not extracted');
        System.assertEquals(true, dealerCodes.contains('456'), 'dealer code 456 was not extracted');
        System.assertEquals(true, dealerCodes.contains('789'), 'dealer code 789 was not extracted');
    }

    @IsTest
    static void testIsRoleNational() {
        // Is National
        User testUser = TestUtility.createInternalUserObject('test', 'isNationalTrue', 'Hyundai User Internal');
        UserRole userRole = [Select Id, DeveloperName From UserRole Where Name = 'Genesis National' Limit 1];
        testUser.UserRoleId = userRole.Id;
        insert testUser;

        User testUser2 = TestUtility.createInternalUserObject('test2', 'isNationalFalse', 'Hyundai User Internal');
        UserRole userRole2 = [Select Id, DeveloperName From UserRole Where Name = 'Service District Manager' Limit 1];
        testUser2.UserRoleId = userRole2.Id;
        insert testUser2;


        Test.startTest();
        Boolean result1 = HMAUserProvisioningService.isRoleNational(testUser);
        Boolean result2 = HMAUserProvisioningService.isRoleNational(testUser2);
        Test.stopTest();

        System.assert(result1, 'Expected user role to contain "National"');
        System.assert(!result2, 'Expected user role not to contain "National"');
    }

    @IsTest
    static void testHandleInternalUser() {

        // Profile: Hyundai User internal
        // Role: Hyundai National
        //testUser.UserRoleId = '00E6g000000tNedEAE';
        User testUser = TestUtility.createInternalUserObject('internal', 'National', 'Hyundai User internal');
        UserRole userRole = [Select Id, DeveloperName From UserRole Where Name = 'Hyundai National' Limit 1];
        testUser.UserRoleId = userRole.Id;
        insert testUser;

        // Profile: Hyundai User internal
        // Role: Hyundai Region Manager
        //testUser2.UserRoleId = '00E6g000000tNfHEAU';
        User testUser2 = TestUtility.createInternalUserObject('internal2', 'RegionManager', 'Hyundai User internal');
        UserRole userRole2 = [Select Id, DeveloperName From UserRole Where Name = 'Hyundai Region Manager' Limit 1];
        testUser2.UserRoleId = userRole2.Id;
        insert testUser2;

        // Profile: Hyundai User internal
        // Role: District Sales Manager
        // testUser3.UserRoleId = '00E6g000001hbYzEAI';
        User testUser3 = TestUtility.createInternalUserObject('internal3', 'DistrictSalesManager', 'Hyundai User internal');
        UserRole userRole3 = [Select Id, DeveloperName From UserRole Where Name = 'District Sales Manager' Limit 1];
        insert testUser3;

        User testUser4 = TestUtility.createInternalUserObject('internal4', 'DistrictSalesManager', 'Hyundai User internal');
        UserRole userRole4 = [Select Id, DeveloperName From UserRole Where Name = 'District Sales Manager' Limit 1];
        testUser4.UserRoleId = userRole4.Id;
        insert testUser4;

        List<String> accessTypes = new List<String> {'DPM_CAM_CE', 'DPM_FinDataHMA', 'DPM_HyundaiEmp'};
        List<String> accessTypes2 = new List<String> {'DPM_RGM_MS', 'DPM_BasicInt', 'DPM_FinDataHMA','DPM_HyundaiEmp'};
        List<String> accessTypes3 = new List<String> {'CUV_HyundaiInt', 'DPM_BasicInt', 'DPM_AP_IntRCE','DPM_FinDataHMA','DPM_HyundaiEmp', 'DPM_ReadOnly_SO','DPM_DSM_SO4'};
        List<String> accessTypes4 = new List<String> {'CUV_HyundaiInt', 'DPM_BasicInt', 'DPM_AP_IntRCE','DPM_FinDataHMA','DPM_HyundaiEmp'};

        Test.startTest();

        HMAUserProvisioningService.handleInternalUser(testUser, accessTypes, false);
        HMAUserProvisioningService.handleInternalUser(testUser2, accessTypes2, true);
        HMAUserProvisioningService.handleInternalUser(testUser3, accessTypes3, false);
        HMAUserProvisioningService.handleInternalUser(testUser4, accessTypes4, false);

        Test.stopTest();

        System.assert(testUser.RegionCodes__c != null);
        System.assert(testUser.DistrictCodes__c == null);

        System.assert(testUser2.RegionCodes__c != null);
        System.assert(testUser2.DistrictCodes__c == null);

        if(accessTypes.isEmpty()) {
            System.assert(testUser3.RegionCodes__c == null);
            System.assert(testUser3.DistrictCodes__c == null);
        }else {
            System.assert(testUser4.RegionCodes__c != null);
            System.assert(testUser4.DistrictCodes__c != null);
        }
    }

    @IsTest
    static void testHandleExternalUser() {

        Profile profile = [Select Id from Profile WHERE NAME = 'DPM Partner Community (Hyundai)'];

        User testUser = new User();
        testUser.FirstName = 'External';
        testUser.LastName = 'Test';
        testUser.Username = user.FirstName + '' + user.LastName+'@' + user.LastName + '.com';
        testUser.ProfileId = profile.Id;
        testUser.Email = user.LastName + 'invalid@acumensolutions.com';
        testUser.Alias = 'usr123';
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.AccessTypes__c = 'DPM_BasicExt/MD703,DPM_FinExtGMA/MD703,DPM_AP_ExtRCE/MD034,DPM_BasicExt/MD034,DPM_GenUserExt,DPM_HyundaiExt';

        // DPM_BasicExt/MD703,DPM_FinExtGMA/MD703,DPM_AP_ExtRCE/MD034,DPM_BasicExt/MD034,DPM_GenUserExt,DPM_HyundaiExt
        List<String> accessTypes = new List<String> {'DPM_BasicExt/MD703', 'DPM_FinExtGMA/MD703', 'DPM_AP_ExtRCE/MD034','DPM_BasicExt/MD034','DPM_GenUserExt','DPM_HyundaiExt'};

        Test.startTest();
        HMAUserProvisioningService.handleExternalUser(testUser, accessTypes);
        Test.stopTest();

        if(accessTypes.isEmpty()) {
            System.assert(testUser.RegionCodes__c == null);
            System.assert(testUser.DistrictCodes__c == null);
        }else {
            System.assert(testUser.RegionCodes__c != null);
            System.assert(testUser.DistrictCodes__c != null);
        }
    }

    /**
     * [Method Description] Test method to test UpdateOwnerOnActionPlan
     * Created by [MinheeKim] on [24.05.15] for [DPM-4455] 
    */
    @IsTest
    static void testUpdateOwnerOnActionPlan() {

        Profile profile = [Select Id from Profile WHERE NAME = 'DPM Partner Community (Hyundai)'];

        User GMuser = [SELECT Id, AccessTypes__c From User WHERE FirstName = 'External2'];
        PermissionSet ps = [SELECT Id FROM PermissionSet  WHERE Name ='DPM_Action_Plan_Read_Only_External'];
       PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = GMuser.Id);
       insert psa;

        // Contact con = [SELECT Id FROM Contact WHERE JobCode__c = 'DP'];
        User testUser = [SELECT Id, AccessTypes__c From User WHERE LastName = 'TestUser'];
        
        Test.startTest();
        testUser.AccessTypes__c = 'DPM_BasicExt/MD703,DPM_FinExtGMA/MD703,DPM_BasicExt/MD034,DPM_GenUserExt,DPM_HyundaiExt';
        
        update testUser;
        Test.stopTest();

    }

    /**
     * [Method Description] Test method to test UpdateOwnerOnActionPlan
     * Created by [MinheeKim] on [24.05.15] for [DPM-4455] 
    */
    @IsTest
    static void testUpdateOwnerOnActionPlan2() {

        Profile profile = [Select Id from Profile WHERE NAME = 'Minimum Access - Partner Community'];

        User DPuser = [SELECT Id, AccessTypes__c From User WHERE FirstName = 'ExternalUSer'];
        PermissionSet ps = [SELECT Id FROM PermissionSet  WHERE Name ='DPM_Action_Plan_Read_Only_External'];
       PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = DPuser.Id);
       insert psa;

        // Contact con = [SELECT Id FROM Contact WHERE JobCode__c = 'DP'];
        User testUser = [SELECT Id, AccessTypes__c From User WHERE FirstName = 'External2' LIMIT 1];
        
        Test.startTest();
        testUser.AccessTypes__c = '';
        
        update testUser;
        Test.stopTest();

    }

    /**
     * [Method Description] Test method to test DNAMsIUActive
     * Created by [Jonghoon Kim] on [24.08.28] for [DPM-5754] 
	 * Edited by [Minhee Kim] on [02-10-2025] for [DPM-6020] Consolidate DNAMS flag fields
    */
    @IsTest
    static void DNAMsIUActiveTest() {

        Profile profile = [Select Id from Profile WHERE NAME = 'Minimum Access - Partner Community'];

        User DPuser = [SELECT Id, AccessTypes__c From User WHERE FirstName = 'ExternalUSer'];
        PermissionSet ps = [SELECT Id FROM PermissionSet  WHERE Name ='DPM_Action_Plan_Read_Only_External'];
       PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = DPuser.Id);
       insert psa;

        // Contact con = [SELECT Id FROM Contact WHERE JobCode__c = 'DP'];
        User testUser = [SELECT Id, AccessTypes__c From User WHERE FirstName = 'External2' LIMIT 1];
        
        Test.startTest();
        testUser.IsActive = false;
        testUser.DNAMS_User_Flag__c = true; //Changed from DNAMS_Internal_User__c to DNAMS_User__c [DPM-6020] by Minhee Kim - 01.21.2025
        
        update testUser;
        Test.stopTest();

    }

    /**
     * Test method to test updateAccessType
     * Created by Areum on 12-22-2024 for DPM-5979
     * Edited by MinheeKim on 02-13-2025 for DPM-6083 change to comment
    */
    /**@IsTest
    static void testUpdateAccessTypeWithDNAMS() {
        UserRole userRole = [Select Id, DeveloperName From UserRole Where Name = 'System Admin' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser) {
            // Setup
            Account acc = new Account(
                Name = 'Test Account', 
                DealerCode__c = 'CA01B'
            );
            insert acc;
            
            Contact con = new Contact(
                LastName = 'TestContact',
                AccountId = acc.Id,
                Email = 'test@test.com',
                JobCode__c = 'DP',
                DNAMS_Active_User__c = true,
                DNAMS_Role__c = 'Dealer Principal'
            );
            insert con;

            AccountContactRelation acr = [SELECT Id, Roles FROM AccountContactRelation 
                                        WHERE ContactId = :con.Id];
            acr.Roles = 'Dealer Principal';
            update acr;

            User testUser = TestUtility.createExternalUser(
                con.Id, 
                'Test3', 
                'User3', 
                'DPM Partner Community (Hyundai)',
                'DNA_HyundaiExt/CA01B,DPM_BasicExt/CA01B'
            );
            
            Test.startTest();
            
            List<Id> userIds = new List<Id>{testUser.Id};
            UserTriggerHelper.updateAccessType(userIds);
            Test.stopTest();
        
            Contact updatedContact = [SELECT Id, DNAMS_Active_User__c, DNAMS_Role__c, 
                                    Access_Types__c 
                                    FROM Contact 
                                    WHERE Id = :con.Id];
            System.assertEquals(true, updatedContact.DNAMS_Active_User__c);
            System.assertEquals('Dealer Principal', updatedContact.DNAMS_Role__c);
            
            AccountContactRelation updatedACR = [SELECT Id, DNAMSAccountUser__c 
                                            FROM AccountContactRelation 
                                            WHERE ContactId = :con.Id];
            System.assertEquals(true, updatedACR.DNAMSAccountUser__c);
        }
    }*/

    /**
     * Test method to test updateAccessType
     * Created by Areum on 12-22-2024 for DPM-5979
    */
    @IsTest
    static void testUpdateAccessTypeWithoutDNAMS() {
        UserRole userRole = [Select Id, DeveloperName From UserRole Where Name = 'System Admin' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and IsActive = true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser) {
            // Setup
            Account acc = new Account(
                Name = 'Test Account', 
                DealerCode__c = 'CA01B'
            );
            insert acc;
            
            Contact con = new Contact(
                LastName = 'TestContact',
                AccountId = acc.Id,
                Email = 'test2@test.com',
                JobCode__c = 'GM'
            );
            insert con;

            User testUser = TestUtility.createExternalUser(
                con.Id, 
                'AccessTypeTest', 
                'User123', 
                'DPM Partner Community (Hyundai)',
                'DPM_BasicExt/CA01B'
            );
            
            Test.startTest();
            List<Id> userIds = new List<Id>{testUser.Id};
            UserTriggerHelper.updateAccessType(userIds);
            Test.stopTest();
            
            Contact updatedContact = [SELECT Id, DNAMS_Active_User__c, DNAMS_Role__c, 
                                    Active_DPM_User__c
                                    FROM Contact 
                                    WHERE Id = :con.Id];
            System.assertEquals(false, updatedContact.DNAMS_Active_User__c);
            System.assertEquals(null, updatedContact.DNAMS_Role__c);
            System.assertEquals(true, updatedContact.Active_DPM_User__c);
            
            AccountContactRelation updatedACR = [SELECT Id, DNAMSAccountUser__c 
                                            FROM AccountContactRelation 
                                            WHERE ContactId = :con.Id];
            System.assertEquals(false, updatedACR.DNAMSAccountUser__c);
        }
    }
   
    /**
     * [Method Description] Test method for error handling of updateDNAMSRoles 
     * Created by [MinheeKim] on [01.14.25] for [DPM-6016] 
     */
    @IsTest
    static void testUpdateDNAMSRolesErrorHandling() {
        User testUser = [SELECT Id,AccessTypes__c FROM User WHERE Name like '%TestUser3%'];
        List<Id> userIds = new List<Id>{testUser.Id};

        Test.startTest();
        
        try {
            testUser.AccessTypes__c ='DPM_BasicExt/MD034,DPM_FinExtGMA/MD034,DPM_GenUserExt,DPM_HyundaiExt';
            testUser.Autoprovision__c = true;
            update testUser;
            //UserTriggerHelper.updateAccessType(userIds);
        } catch (Exception e) {
            System.debug('Caught expected exception: ' + e.getMessage());
        }
        
        Test.stopTest();

    }

}