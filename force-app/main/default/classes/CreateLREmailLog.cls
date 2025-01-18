/**
 * Created by Hayeon Cho on 2024-06-22.
 * Catch Inbound Email and log for STIL Lab Requests.
 */
public without sharing class CreateLREmailLog implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
 
    System.debug('In Mail : '+email);

    // Create an InboundEmailResult object for returning the result of the 
    // Apex Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    // Check if email subject contains valid LRNumber
    String lrNumber = '';
    Matcher validLRNumberContains = Pattern.compile('\\bSTIL-\\d{4}-\\d{5,6}-\\d{2}\\b').matcher(email.subject);

    // If subject contains LRNumber, proceed inbound email process
    if(validLRNumberContains.find()){
        lrNumber = validLRNumberContains.group(0);
        System.debug('lrNumber : '+lrNumber);
        String emSubject = email.subject;
        if(emSubject.substring(0,4).equals('FW: ')||emSubject.substring(0,4).equals('전달: ')){
            emSubject = email.subject.substring(4);
        }
        // String toEmail = 'testLRRequestEmail@test.com';
        // Get LR record
            try {
            WorkOrder vLR = [SELECT Id, Lab_Request_Number__c
                FROM WorkOrder
                WHERE Lab_Request_Number__c = :lrNumber
                WITH USER_MODE
                LIMIT 1];
            
            
            EmailMessage em = new EmailMessage();
            em.Incoming = true;
            em.FromAddress = email.fromAddress;
            em.ToAddress = email.toAddresses[0];
            if(email.ccAddresses!=null){
                em.CCAddress = email.ccAddresses[0];
            }
            em.Subject = emSubject;
            // for escape null parsing
            em.HTMLBody = ' ';
            em.TextBody = ' ';
            if(email.binaryAttachments!=null || email.textAttachments!=null){
                em.TextBody += 'This original mail has attachments. Please check the mailbox if needed.\n\n';
                em.HTMLBody += '<span style="color:red"><b>This original mail has attachments. Please check the mailbox if needed.</b></span><br/><br/>';
            }
            em.HTMLBody += email.htmlBody;
            em.TextBody += email.plainTextBody;
            em.Status = '2';
            em.RelatedToId = vLR.Id;

            //insert message
            insert as user em;

            
            System.debug('New Email message: ' + em );   
            }
            // If an exception occurs when the query accesses 
            // the contact record, a QueryException is called.
            // The exception is written to the Apex debug log.
        catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        }
        
        // Set the result to true. No need to send an email back to the user 
        // with an error message
        result.success = true;

    }
   
   // Return the result for the Apex Email Service
   return result;
  }
}