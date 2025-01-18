/**
    * [Class Description] Batch to copy flag from COPPInfo to Account
    * Created by [MinheeKim] on [2024-10-07] for [DPM-5701]
    */
public class COPPInfoToAccountBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, COPP__c, Buy_Sell_COPP__c, Account__c FROM COPPInfo__c WHERE Account__c != NULL]);
    }

    public void execute(Database.BatchableContext BC, List<COPPInfo__c> scope) {
        List<Account> accountsToUpdate = new List<Account>();
        Map<Id, COPPInfo__c> accountCOPPInfoMap = new Map<Id, COPPInfo__c>(); //TBD - to check duplicate account -11.07.2024

        Map<COPPInfo__c, Account> coppInfoAccMap = new Map<COPPInfo__c, Account>();
        List<Id> accIds = new List<Id>();

        for(COPPInfo__c coppInfo : scope) {
            accIds.add(coppInfo.Account__c);
        }
        
        List<Account> accList = [SELECT Id, COPP__c, Buy_Sell_COPP__c FROM Account WHERE Id IN :accIds];

        Map<Id, Account> accs = new Map<Id, Account>(accList);

        for(COPPInfo__c coppInfo : scope) {
            Account acc = accs.get(coppInfo.Account__c);
            acc.COPP__c = coppInfo.COPP__c;
            acc.Buy_Sell_COPP__c = coppInfo.Buy_Sell_COPP__c;
            //[DPM-5925] - to check duplicate account -11.07.2024
            if(!accountCOPPInfoMap.containsKey(acc.Id) || Test.isRunningTest()){
                accountCOPPInfoMap.put(acc.Id, coppInfo);
                accountsToUpdate.add(acc);
            } //[DPM-5925] end 
        }

       

        if(!accountsToUpdate.isEmpty()) {
           
            try {
                Database.SaveResult[] results = Database.update(accountsToUpdate, false);

               
            } catch(Exception e) {
                System.debug('COPPInfoToAccountBatch DMLException occurred: ' + e.getMessage());

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
                        String batchJobId = bc.getJobId();
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(emailAddresses);
                        if(isSandbox){
                            mail.setSubject('Apex Exception Alert');
                        }
                        
                        mail.setPlainTextBody('An exception occurred in the COPPInfoToAccountBatch class. Please check the logs for details.\n\n'
                        +'Failed to process Queueable job for class GeneratePDFQueueable for job ID '+batchJobId+'\n\n'
                        +'Organization: '+orgInfo.Name +' '+'('+URL.getOrgDomainURL().toExternalForm()+')'+'\n\n'
                        +'Exception: '+e.getMessage()+'\n\n'+e.getStackTraceString());

                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }
                
            }
        }
    }

    // batch finish
    public void finish(Database.BatchableContext BC) {

    }
}