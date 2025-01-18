@isTest
public class DPMHelpControllerTest {
    @testSetup private static void setupData() {
        
        Id internalProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = internalProfile, country='United States',IsActive =true,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail' + randomNumber() + '.com');
        insert user;
        
        /*user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = internalProfile, country='United States',IsActive =true,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail' + randomNumber() + '.com');*/
        
        Id commProfile = [select id from profile where name='Partner Community User'].id;
        
        Account ac = new Account(name ='Grazitti', DistrictSalesManager__c = user.Id);
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, email='test@test.com.test');
        insert con;  
        
        user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = commProfile, country='United States',IsActive =true,
                             ContactId = con.Id, AccessTypes__c='DPM_HyundaiExt',
                             timezonesidkey='America/Los_Angeles', username='tester@noemail' + randomNumber() + '.com');
        
        insert user;
    }
    
    private static Integer randomNumber() {
        return Integer.valueof((Math.random() * 100));
    }
    
    private TestMethod static void testGetDPMLinks() {
        DPMHelpController.getDPMLinks('HMACorporate');
        List<User> lstUser = [SELECT Id FROM User WHERE email='test123@noemail.com' AND Profile.Name='Partner Community User'];
        System.runAs(lstUser[0]) {
            DPMHelpController.getUserTypeAccess();
            DPMHelpController.getDSMANDDPSM();
        }
    }
}