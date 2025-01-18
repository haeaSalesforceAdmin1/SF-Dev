/**
     * [Class Description] COPP Project - send email to Dealer Principal with attachment
     * Created by [MinheeKim] on [2024-09-09] for [DPM-5701]
    */

public with sharing class COPPSendEmail {

    @InvocableMethod(label='Send Email with Attachment' description='Sends an email with the content document as attachment')
    public static void sendEmailWithAttachment(List<EmailInfo> emailInfos) {
        
        for(EmailInfo emailInfo : emailInfos) {
            try {
                // Fetch the ContentDocument and get the corresponding ContentVersion
                List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, ContentDocumentId 
                                                       FROM ContentVersion 
                                                       WHERE ContentDocumentId = :emailInfo.TrackerLetterId 
                                                       ORDER BY IsLatest DESC LIMIT 1];
                
                // Prepare the attachment
                List<Messaging.Emailfileattachment> attachments = new List<Messaging.Emailfileattachment>();
                if(contentVersions.size()>0){
                    for(ContentVersion contentVersion : contentVersions) {
                        Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
                        attachment.setFileName(contentVersion.Title + '.pdf');
                        attachment.setBody(contentVersion.VersionData);
                        attachments.add(attachment);
                    }
                }
                
                List<String> toAddresses = new List<String>();
                toAddresses.add(emailInfo.toEmail);
           
                if(emailInfo.toEmails != null && emailInfo.toEmails != '' && emailInfo.toEmails.contains(';')){
                    emailInfo.toEmails  = emailInfo.toEmails.trim().replace(';', ',');
                }
                
                if (emailInfo.toEmails != null && emailInfo.toEmails != '' && emailInfo.toEmails.contains(',')) {
                    // Split CC addresses by semicolon and trim any spaces
                    List<String> Addresses = emailInfo.toEmails.split(',');
                    toAddresses.addAll(Addresses);
                }else if(emailInfo.toEmails != null && emailInfo.toEmails != ''){
                    toAddresses.add(emailInfo.toEmails);                
                }

                if(emailInfo.sendToMe){
                    toAddresses.add(emailInfo.sender);
                }
                
                // Create the email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSubject(emailInfo.subject);
                mail.setHtmlBody(emailInfo.body.replace('\n', '<br/>'));
                if(attachments.size()>0) mail.setFileAttachments(attachments);
                mail.setReplyTo(emailInfo.sender);

                // Add CC recipients
                List<String> ccEmails = new List<String>();
                if(emailInfo.ccEmails != null && emailInfo.ccEmails != '' && emailInfo.ccEmails.contains(';')){
                    emailInfo.ccEmails = emailInfo.ccEmails.trim().replace(';', ',');
                }
                
                if (emailInfo.ccEmails != null && emailInfo.ccEmails != '' && emailInfo.ccEmails.contains(',')) {
                    // Split CC addresses by semicolon and trim any spaces
                    List<String> ccAddresses = emailInfo.ccEmails.trim().split(',');
                    mail.setCcAddresses(ccAddresses);
                }else if(emailInfo.ccEmails != null && emailInfo.ccEmails != ''){
                    ccEmails.add(emailInfo.ccEmails);
                    mail.setCcAddresses(ccEmails);           
                }
                
                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            } catch (Exception e) {
                throw new AuraHandledException('Error while sending email: ' + e.getMessage());
            }
        }
    }
    
    // Define the EmailInfo class to receive parameters from Flow
    public class EmailInfo {
        @InvocableVariable(label='To Email' description='Recipient Email Address')
        public String toEmail;

        @InvocableVariable(label='To Emails' description='Recipient Email Addresses')
        public String toEmails;
        
        @InvocableVariable(label='Subject' description='Email Subject')
        public String subject;
        
        @InvocableVariable(label='Body' description='Email Body')
        public String body;

        @InvocableVariable(label='cc' description='Email CC')
        public String ccEmails;

        @InvocableVariable(label='sender' description='Email Sender')
        public String sender;
        
        @InvocableVariable(label='sendToMe' description='')
        public Boolean sendToMe;
        
        @InvocableVariable(label='LetterId' description='Content Document Id to attach')
        public Id LetterId;

        @InvocableVariable(label='TrackerId' description='Content Document Id to attach')
        public Id TrackerId;

        @InvocableVariable(label='TrackerLetterId' description='Content Document Id to attach')
        public Id TrackerLetterId;
    }
}