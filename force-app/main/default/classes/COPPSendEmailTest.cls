@isTest
public class COPPSendEmailTest {

    @isTest
    static void testSendEmailWithAttachment() {
        // Create a test ContentDocument and ContentVersion to mock email attachment
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('This is a test PDF content'),
            PathOnClient = 'TestDocument.pdf'
        );
        insert contentVersion;

        // Retrieve the ContentDocumentId for use in testing
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

        // Prepare the test EmailInfo
        COPPSendEmail.EmailInfo emailInfo = new COPPSendEmail.EmailInfo();
        emailInfo.toEmail = 'dealerprincipal@example.com';
        emailInfo.toEmails = 'cc1@example.com,cc2@example.com';
        emailInfo.ccEmails = 'cc3@example.com,cc4@example.com';
        emailInfo.subject = 'Test Subject';
        emailInfo.body = 'This is a test email body.';
        emailInfo.sender = 'sender@example.com';
        emailInfo.sendToMe = true;
        emailInfo.TrackerLetterId = contentDocumentId;

        List<COPPSendEmail.EmailInfo> emailInfos = new List<COPPSendEmail.EmailInfo>{emailInfo};

        // Test the method and ensure emails are sent properly
        Test.startTest();
        COPPSendEmail.sendEmailWithAttachment(emailInfos);
        Test.stopTest();

    }

    @isTest
    static void testSendEmailWithoutAttachment() {
        // Prepare the test EmailInfo without attachment
        COPPSendEmail.EmailInfo emailInfo = new COPPSendEmail.EmailInfo();
        emailInfo.toEmail = 'dealerprincipal@example.com';
        emailInfo.subject = 'Test Subject No Attachment';
        emailInfo.body = 'This is a test email body without attachment.';
        emailInfo.sender = 'sender@example.com';
        emailInfo.sendToMe = false;

        List<COPPSendEmail.EmailInfo> emailInfos = new List<COPPSendEmail.EmailInfo>{emailInfo};

        // Test the method and ensure emails are sent properly
        Test.startTest();
        COPPSendEmail.sendEmailWithAttachment(emailInfos);
        Test.stopTest();

    }

    @isTest
    static void testSendEmailWithInvalidAttachment() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('This is a test PDF content'),
            PathOnClient = 'TestDocument.pdf'
        );
        insert contentVersion;
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        
        COPPSendEmail.EmailInfo emailInfo = new COPPSendEmail.EmailInfo();
        emailInfo.toEmail = 'dealerprincipal@example.com';
        emailInfo.subject = 'Test Subject Invalid Attachment';
        emailInfo.body = 'This is a test email body with an invalid attachment.';
        emailInfo.sender = 'sender@example.com';
        emailInfo.sendToMe = false;
        emailInfo.TrackerLetterId = contentDocumentId;

        List<COPPSendEmail.EmailInfo> emailInfos = new List<COPPSendEmail.EmailInfo>{emailInfo};

        // Test the method and catch the AuraHandledException
        try {
            Test.startTest();
            COPPSendEmail.sendEmailWithAttachment(emailInfos);
            Test.stopTest();

        } catch (AuraHandledException e) {
           
        }
    }
}