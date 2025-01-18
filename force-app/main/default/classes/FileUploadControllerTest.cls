@isTest
public class FileUploadControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test Account record
        AccountTriggerHandler.run = false;
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        AccountTriggerHandler.run = true;

        // Create a test ContentDocument and ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test Data')
        );
        insert cv;
        
        // Retrieve the ContentDocument Id
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        // Link the ContentDocument to the Account
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = testAccount.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;
    }

    @isTest
    static void testGetFilesForRecord() {
        // Get the Account created in testSetup
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Call the getFilesForRecord method
        List<ContentDocument> files = FileUploadController.getFilesForRecord(testAccount.Id);
        
    }

    @isTest
    static void testUploadFiles() {
        // Get the Account created in testSetup
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Create a map for the file to upload
        List<Map<String, String>> files = new List<Map<String, String>>();
        Map<String, String> fileMap = new Map<String, String>();
        fileMap.put('documentId', [SELECT ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId);
        files.add(fileMap);

        // Call the uploadFiles method
        String result = FileUploadController.uploadFiles(testAccount.Id, files);

    }

    @isTest
    static void testUploadFile() {
        // Get the Account created in testSetup
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Call the uploadFile method
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        String contentDocumentId = FileUploadController.uploadFile(base64, 'NewFile.txt', testAccount.Id);

        // Verify the ContentDocument was created
        ContentDocument doc = [SELECT Id, Title FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];

    }

    @isTest
    static void testUpdateFile() {
        // Get the Account created in testSetup
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Get an existing ContentDocumentId
        String contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId;

        // Call the updateFile method
        String result = FileUploadController.updateFile(contentDocumentId, testAccount.Id);

        ContentDocumentLink cdl = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId AND LinkedEntityId = :testAccount.Id LIMIT 1];

    }
}