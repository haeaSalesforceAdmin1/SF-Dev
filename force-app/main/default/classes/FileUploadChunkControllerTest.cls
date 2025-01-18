@IsTest
public with sharing class FileUploadChunkControllerTest {
    @IsTest
    static void testUploadNewChunkedFile() {
        // Create a test Account record to link the ContentDocument
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Prepare test data
        String fileName = 'TestFile.pdf';
        String fileContent = 'dGVzdA=='; // This is a sample base64 encoded content. Use a proper base64 string for a real test.
        String contentVersionId = null;

        // Test the uploadChunkedFile method for a new file
        Test.startTest();
        Id newContentVersionId = FileUploadChunkController.uploadChunkedFile(testAccount.Id, fileName, fileContent, contentVersionId);
        Test.stopTest();

        // Verify that a ContentVersion was created
        ContentVersion cv = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id = :newContentVersionId];
        System.assertEquals(fileName, cv.Title, 'ContentVersion title should match the uploaded file name.');

        // Verify that a ContentDocumentLink was created
        //ContentDocumentLink cdl = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :testAccount.Id];
        //System.assertEquals(cv.ContentDocumentId, cdl.ContentDocumentId, 'ContentDocumentId should match between ContentVersion and ContentDocumentLink.');
        //System.assertEquals(testAccount.Id, cdl.LinkedEntityId, 'ContentDocumentLink should be linked to the correct record.');
    }

    @IsTest
    static void testUploadChunkToExistingFile() {
        // Create a test Account record to link the ContentDocument
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create an initial ContentVersion
        String initialFileContent = 'dGVzdA==';
        ContentVersion initialCv = new ContentVersion(
            Title = 'TestFile.pdf',
            VersionData = EncodingUtil.base64Decode(initialFileContent),
            PathOnClient = '/TestFile.pdf',
            IsMajorVersion = false
        );
        insert initialCv;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :initialCv.Id].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Prepare additional file content to append
        String additionalFileContent = 'dGVzdA=='; // This is a sample base64 encoded content. Use a proper base64 string for a real test.

        // Test the uploadChunkedFile method for appending to an existing file
        Test.startTest();
        Id updatedContentVersionId = FileUploadChunkController.uploadChunkedFile(testAccount.Id, 'TestFile.pdf', additionalFileContent, initialCv.Id);
        Test.stopTest();

        // Verify that the ContentVersion was updated
        ContentVersion updatedCv = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :updatedContentVersionId];
        String combinedContent = EncodingUtil.base64Encode(updatedCv.VersionData);
        System.assert(combinedContent.contains(initialFileContent), 'Combined content should contain the initial file content.');
        System.assert(combinedContent.contains(additionalFileContent), 'Combined content should contain the additional file content.');
    }
}