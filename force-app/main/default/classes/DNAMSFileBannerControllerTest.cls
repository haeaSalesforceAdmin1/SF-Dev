@isTest
public without sharing class DNAMSFileBannerControllerTest{
    static testMethod void fetchFieldsTest() {

        Account account = new Account(Name = 'Test Account');
        insert account;
        

        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
        insert cv;
        
        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
        List<sobject> testContents2 = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];

        ContentDocumentLink contentlink = new ContentDocumentLink(LinkedEntityId = account.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        insert contentlink;
       
        Test.StartTest();  
        DNAMSFileBannerController.ReturnWP test2 = DNAMSFileBannerController.fetchfields(String.valueof(testContents[0].ContentDocumentId), 'ContentDocument');
        DNAMSFileBannerController.ReturnWP test3 = DNAMSFileBannerController.fetchfields('', 'ContentDocument');  
        Test.StopTest();
        
    }
}