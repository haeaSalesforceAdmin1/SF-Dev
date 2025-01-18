@isTest
public class GenesisUploadedActionPlanPDFTest {

    @isTest
    static void testGetPdfFilesWithIdsAsBase64() {
        // Create a test evaluation record
        Evaluation__c eval = new Evaluation__c(Name = 'Test Evaluation');
        insert eval;

        // Create a test content version
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test PDF',
            PathOnClient = 'TestPDF.pdf',
            VersionData = Blob.valueOf('Test PDF Data')
        );
        insert contentVersion;
        
        // Create a test content document
        ContentDocument contentDoc = [select Id from ContentDocument limit 1];
        
        // Create a test content document link
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            ContentDocumentId = contentDoc.Id,
            LinkedEntityId = eval.Id,
            ShareType = 'V'
        );
        insert contentDocLink;

        // Update the evaluation record with the content document ID
        eval.ActionPlanFileId__c = contentDoc.Id;
        update eval;
        // Retrieve the test evaluation record
        //Evaluation__c eval = [SELECT Id, ActionPlanFileId__c FROM Evaluation__c LIMIT 1];
        
        Test.startTest();
        // Call the method
        List<Map<String, String>> result = GenesisUploadedActionPlanPDFController.getPdfFilesWithIdsAsBase64(eval.Id);
        Test.stopTest();
        
        // Validate the result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result size should be 1');
        System.assertEquals(eval.ActionPlanFileId__c, result[0].get('ContentDocumentId'), 'ContentDocumentId should match');
        System.assertNotEquals(null, result[0].get('Base64Data'), 'Base64Data should not be null');
    }
    
    @isTest
    static void testGetPdfFilesWithIds() {
        // Create a test evaluation record
        Evaluation__c eval = new Evaluation__c(Name = 'Test Evaluation');
        insert eval;

        // Create a test content version
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test PDF',
            PathOnClient = 'TestPDF.pdf',
            VersionData = Blob.valueOf('Test PDF Data')
        );
        insert contentVersion;
        
        
        // Create a test content document
        ContentDocument contentDoc = [select Id from ContentDocument limit 1];
        
               
        // Create a test content document link
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            ContentDocumentId = contentDoc.Id,
            LinkedEntityId = eval.Id,
            ShareType = 'V'
        );
        insert contentDocLink;

        // Update the evaluation record with the content document ID
        eval.ActionPlanFileId__c = contentDoc.Id;
        update eval;
        // Retrieve the test content document ID
        //ContentDocument contentDoc = [SELECT Id FROM ContentDocument LIMIT 1];
        
        Test.startTest();
        // Call the method
        List<Map<String, String>> result = GenesisUploadedActionPlanPDFController.getPdfFilesWithIds(contentDoc.Id);
        Test.stopTest();
        
        // Validate the result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result size should be 1');
        System.assertEquals(contentDoc.Id, result[0].get('ContentDocumentId'), 'ContentDocumentId should match');
        System.assertNotEquals(null, result[0].get('Base64Data'), 'Base64Data should not be null');
    }
}