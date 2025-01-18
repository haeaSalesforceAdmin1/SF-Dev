@isTest
public class DNAMSUserPermissionsetCheckTest {
    @isTest static void testCheckPermissionSet() {
        // Create a test user
        User u = new User(Alias = 'sthms', Email='standarduserhmsua@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserhmusa1@testorg.com');
        //insert u;

        // Run as this user for testing
        System.runAs(u) {
            // Test without permission set assignment
            Boolean result = DNAMSUserPermissionsetCheck.checkPermissionSet();
            System.assertEquals(false, result);

            // Create PermissionSet
            PermissionSet ps = [Select id from PermissionSet where name = 'DNAMS_National_User_DND1'];

            // Assign PermissionSet to user
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = u.Id);
            insert psa;

            // Test with permission set assignment
            result = DNAMSUserPermissionsetCheck.checkPermissionSet();
            System.assertEquals(true, result);
        }
    }
    
    @isTest
    public static void handleDeleteRMRGroupTest(){
        
        
        Account acc= new Account();
        acc.name = 'test dealer';
        
        insert acc;
        
        
        // Create a test user
        User u = new User(Alias = 'sthms', Email='standarduserhmsua@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='Hyundai User Internal'].Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserhmusa1@testorg.com');
        insert u;
        
        PackageRequest__share shareObj = new PackageRequest__share();
        //shareObj.parentId = dcr.id;
        shareObj.userorGroupId = u.Id;
        shareObj.accesslevel = 'Edit';
        //insert shareObj;
        // Run as this user for testing
        System.runAs(u) {
            
            // Test without permission set assignment
            Boolean result = DNAMSUserPermissionsetCheck.checkPermissionSet();
            System.assertEquals(false, result);
            
            // Create PermissionSet
            PermissionSet psRMR = [Select id from PermissionSet where name = 'Internal_User_RMR_DNAMS'];
            // Create PermissionSet
            PermissionSet ps = [Select id from PermissionSet where name = 'DNAMS_National_User_DND1'];
            
            // Assign PermissionSet to user
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = psRMR.Id, AssigneeId = u.Id);
            insert psa2;
            
            // Test with permission set assignment
            result = DNAMSUserPermissionsetCheck.checkPermissionSet();
            System.assertEquals(true, result);
        }
    }
    @isTest
    public static void handleDeleteDND1GroupTest(){
        
        
        Account acc= new Account();
        acc.name = 'test dealer';
        
        insert acc;
        
        
        // Create a test user
        User u = new User(Alias = 'sthms', Email='standarduserhmsua@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='Hyundai User Internal'].Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserhmusa1@testorg.com');
        insert u;
        
        PackageRequest__share shareObj = new PackageRequest__share();
        //shareObj.parentId = dcr.id;
        shareObj.userorGroupId = u.Id;
        shareObj.accesslevel = 'Edit';
        //insert shareObj;
        // Run as this user for testing
        System.runAs(u) {
            
            // Test without permission set assignment
            Boolean result = DNAMSUserPermissionsetCheck.checkPermissionSet();
            System.assertEquals(false, result);
            
            // Create PermissionSet
            PermissionSet psRMR = [Select id from PermissionSet where name = 'Internal_User_DND1_DNAMS'];
            
            // Assign PermissionSet to user
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = psRMR.Id, AssigneeId = u.Id);
            insert psa2;
            
            // Test with permission set assignment
            result = DNAMSUserPermissionsetCheck.checkPermissionSet();
            System.assertEquals(true, result);
            
        }
    }
}