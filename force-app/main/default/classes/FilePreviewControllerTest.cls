@IsTest
public class FilePreviewControllerTest {

    @TestSetup
    static void setupTestData() {

        Evaluation__c evaluationRecord = new Evaluation__c(
            ActionPlanFileId__c = '069xxxxxxxxxxxx',  
            Action_Plan_Status__c = 'Completed'       
        );
        insert evaluationRecord;
    }

    @IsTest
    static void testDeleteContentDocument() {

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test Content')
        );
        insert contentVersion;

        ContentVersion contentDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id  LIMIT 1];


        Test.startTest();
        FilePreviewController.deleteContentDocument(contentDoc.ContentDocumentId);
        Test.stopTest();


        ContentDocument deletedDoc = [SELECT Id FROM ContentDocument WHERE Id = :contentDoc.ContentDocumentId ALL ROWS];
    }

    @IsTest
    static void testGetFileId() {

        Evaluation__c eval = [SELECT Id FROM Evaluation__c LIMIT 1];


        Test.startTest();
        String fileId = FilePreviewController.getFileId(eval.Id);
        Test.stopTest();


    }

    @IsTest
    static void testGetStatus() {

        Evaluation__c eval = [SELECT Id FROM Evaluation__c LIMIT 1];

        Test.startTest();
        String status = FilePreviewController.getStatus(eval.Id);
        Test.stopTest();


    }

    @IsTest
    static void testGetStatus_NullFileId() {
        Evaluation__c eval = new Evaluation__c(
            ActionPlanFileId__c =  '069xxxxxxxxxxxx',  
            Action_Plan_Status__c = 'Pending'
        );
        insert eval;

        Test.startTest();
        String status = FilePreviewController.getStatus(eval.Id);
        Test.stopTest();

    }
}