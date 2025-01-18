@isTest
public class CreateLREmailLogTest {

    @testSetup
    static void setup() {
        // Create test data that will be used in the test methods
        // Create a WorkOrder record with a specific WorkOrderNumber format
        // WorkOrder wo = new WorkOrder(
        //     Status = 'New',
        //     Subject = 'Apex Test WorkOrder'
        // );
        // insert wo;
    }
    
    @isTest
    static void testHandleInboundEmailWithValidLRNumber() {

        WorkOrder wo = new WorkOrder(
            Status = 'New',
            Subject = 'Apex Test WorkOrder'
        );
        insert wo;

        List<WorkOrder> wol = [SELECT Id, Lab_Request_Number__c, Subject FROM WorkOrder WHERE Subject='Apex Test WorkOrder'];

        System.debug(wol[0]);
        
        // Create an instance of the CreateLREmailLog class
        CreateLREmailLog handler = new CreateLREmailLog();

        // Create a mock inbound email
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = wol[0].Lab_Request_Number__c; // Valid LR number
        email.fromAddress = 'test@example.com';
        email.toAddresses = new String[] {'to@example.com'};
        email.plainTextBody = 'Test email body';
        email.ccAddresses = new String[] {'cc@example.com'};

        // Create a mock inbound envelope
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Call the handleInboundEmail method
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);
        
        // Assert that the result is successful
        System.assert(result.success, 'The email processing should be successful.');

    }

    @isTest
    static void testHandleInboundEmailWithoutValidLRNumber() {
        // Create an instance of the CreateLREmailLog class
        CreateLREmailLog handler = new CreateLREmailLog();

        // Create a mock inbound email
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Invalid Subject'; // No valid LR number
        email.fromAddress = 'test@example.com';
        email.toAddresses = new String[] {'to@example.com'};
        email.plainTextBody = 'Test email body';

        // Create a mock inbound envelope
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Call the handleInboundEmail method
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);
        
        // Assert that the result is successful (default success = true)
        System.assert(result.success, 'The email processing should be successful.');
        
        // Verify that no EmailMessage record was created
        List<EmailMessage> emailMessages = [SELECT Id FROM EmailMessage WHERE FromAddress = 'test@example.com'];
        System.assertEquals(0, emailMessages.size(), 'No EmailMessage record should have been created.');
    }
}