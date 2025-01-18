/**
     * [Class Description] Send email when error occurs
     * Created by [MinheeKim] on [2024-11-08] for [DPM-5925, 5926] To send email notification when error occurs
    */    

    public with sharing class ErrorEmailNotifier {

        public static void notifyAdmins(Exception e, String className) {
            System.debug('ExceptionNotifier: Exception occurred: ' + e.getMessage());
            
            Boolean isSandbox = System.Url.getSalesforceBaseUrl().getHost().contains('sandbox');
            Organization orgInfo = [SELECT Name, InstanceName, OrganizationType FROM Organization LIMIT 1];
            List<User> usersToNotify = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator'];
    
            List<String> emailAddresses = new List<String>();
            for (User u : usersToNotify) {
                if (u.Email != null) {
                    emailAddresses.add(u.Email);
                }
            }
    
            if (!emailAddresses.isEmpty()) {
    
                OrgWideEmailAddress[] oweaList = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'DPM Support' LIMIT 1];
                OrgWideEmailAddress owea = oweaList[0];
                String userId = UserInfo.getUserId();
                String orgId = orgInfo.Id;
    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emailAddresses);
    
                if (isSandbox) {
                    mail.setSubject('Apex Exception Alert (Sandbox)');
                } else {
                    mail.setSubject('Apex Exception Alert');
                }
                mail.setOrgWideEmailAddressId(owea.Id);
                mail.setPlainTextBody(
                    'An exception occurred in the ' + className + ' class. Please check the logs for details.\n\n' +
                    'Apex script unhandled exception by user/organization: ' + userId + '/' + orgId + '\n\n' +
                    'Organization: ' + orgInfo.Name + ' (' + URL.getOrgDomainURL().toExternalForm() + ')\n\n' +
                    'Exception: ' + e.getMessage() + '\n\n' +
                    e.getStackTraceString()
                );
    
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                for (Messaging.SendEmailResult result : results) {
                    if (result.isSuccess()) {
                        System.debug('Email sent successfully.');
                    } else {
                        System.debug('Failed to send email. Errors:');
                        for (Messaging.SendEmailError error : result.getErrors()) {
                            System.debug('Error: ' + error.getMessage());
                        }
                    }
                }
            }
        }
    }