/**
 * [Class Description] COPP Project - Test class of COPPFileComponentController
 * Created by [Minhee Kim] on [2024-10-30] for [DPM-5893]
 */
@isTest
public class COPPFileComponentControllerTest {

    static Id contentDocId;

    @testSetup
    static void setup() {
        // Create and insert a ContentVersion record and obtain ContentDocumentId for reuse in tests
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document Version',
            PathOnClient = 'testdocument.pdf',
            VersionData = Blob.valueOf('Test Data')
        );
        insert contentVersion;

        
    }

    @isTest
    static void testGetCOPPInfos() {
        // Prepare test data
        Account testAccount = new Account(Name = 'Test Account', DealerCode__c = 'AK003');
        insert testAccount;

        COPPInfo__c coppInfo = new COPPInfo__c(
            Account__c = testAccount.Id,
            Last_Saved_Time__c = DateTime.now()
        );
        insert coppInfo;


        // Query to get the ContentDocumentId linked to this ContentVersion
        ContentVersion contentVersion = [SELECT Id , ContentDocumentId FROM ContentVersion LIMIT 1];
        // contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

        // Link ContentDocument to COPPInfo
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            LinkedEntityId = coppInfo.Id,
            ContentDocumentId = contentVersion.ContentDocumentId,
            ShareType = 'V'
        );
        insert contentDocLink;

        // Test the getCOPPInfos method
        Test.startTest();
        String resultJson = COPPFileComponentController.getCOPPInfos(testAccount.Id);
        Test.stopTest();


    }
}