@isTest
public without sharing class LastLoginLwcPopupTest {
	
    @TestSetup
    static void makeData(){
        TestUtility.createInternalUser('TestUser', 'UserAfterUpdate', 'System Administrator');
    }

    static testmethod void TestgetLastLoginDetail(){
        Test.startTest();
        LastLoginLwcPopup.getLastLoginDetail();
        User usr = [SELECT Id, Last_Login_Count__c FROM User where FirstName = 'TestUser'];
        System.assertEquals(0,usr.Last_Login_Count__c);
        Test.stopTest();    
    }
}