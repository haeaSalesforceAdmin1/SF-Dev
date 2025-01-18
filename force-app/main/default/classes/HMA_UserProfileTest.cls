/* [Component Description] Test class for HMA_UserProfile
* Created by [MinheeKim] on [2024-06-17] for [DPM-4035]
*/
@isTest
public class HMA_UserProfileTest {

    @testSetup
    static void setup() {
        
        
        // Create Account and Contact
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(LastName='Test Contact', AccountId=testAccount.Id, Email='Test@test.com');
        insert testContact;
        
        // Link Contact to User
        // Create test data for User
        Profile p = [SELECT Id FROM Profile WHERE Name='DPM Partner Community (Hyundai)'];
        User testUser = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            ContactId = testContact.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser@testorg.com.test'
        );
        insert testUser;
        // Create AccountShare record
        AccountShare accountShare = new AccountShare(
            AccountId = testAccount.Id,
            UserOrGroupId = testUser.Id,
            AccountAccessLevel = 'Read',
            OpportunityAccessLevel = 'Read'
        );
        insert accountShare;
    }

    @isTest
    static void testGetDPMSiteURL() {
        Test.startTest();
        
        // Set the context user
        User testUser = [SELECT Id FROM User WHERE UserName='standarduser@testorg.com.test' LIMIT 1];
        System.runAs(testUser) {
            // Call the method and assert results
            Map<String, String> result = HMA_UserProfile.getDPMSiteURL();
            
            System.assertNotEquals(null, result.get('homeURL'));
            System.assertNotEquals(null, result.get('myProfileURL'));
            System.assertNotEquals(null, result.get('myAccountUrl'));
            System.assertNotEquals(null, result.get('logoutURL'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testGetAccountId() {
        Test.startTest();
        
        // Set the context user
        User testUser = [SELECT Id FROM User WHERE UserName='standarduser@testorg.com.test' LIMIT 1];
        System.runAs(testUser) {
            // Call the method and assert results
            List<Map<String, String>> result = HMA_UserProfile.getAccountId();
            
            System.assertEquals(1, result.size());
            System.assertNotEquals(null, result[0].get('accountURL'));
            System.assertEquals('Test Account', result[0].get('accountName'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testFetchUserDetail() {
        Test.startTest();
        
        // Set the context user
        User testUser = [SELECT Id FROM User WHERE UserName='standarduser@testorg.com.test' LIMIT 1];
        System.runAs(testUser) {
            // Call the method and assert results
            User userDetail = HMA_UserProfile.fetchUserDetail();
            
            System.assertEquals(testUser.Id, userDetail.Id);
            // System.assertEquals(testUser.Name, userDetail.Name);
            System.assertNotEquals(null, userDetail.SmallPhotoUrl);
            System.assertNotEquals(null, userDetail.FullPhotoUrl);
        }
        
        Test.stopTest();
    }
}