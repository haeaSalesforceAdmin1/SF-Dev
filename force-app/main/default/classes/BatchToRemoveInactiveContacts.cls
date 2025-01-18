/**
* Batch Job: Clean-up Inactive Account Contact Relationships and Contact Records.
* @author Vinit [IBM]
* @creation 29th Sept 2021
*/
public with sharing class BatchToRemoveInactiveContacts implements Database.batchable<SObject>, Database.Stateful {

    String query;
    public List<Id> listContactIds = new List<Id>();

    public BatchToRemoveInactiveContacts(String query) {

        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        if (String.isBlank(query)) {
            query = 'SELECT Id, Name, IsActive, Contact.Name, IsPortalEnabled, ContactId '; 
            if(Test.isRunningTest()){
                query += ' FROM User WHERE contact.Active_DPM_User__c = FALSE AND IsActive = FALSE LIMIT 200'; //DPM-5301 changed from DPMActiveUser__c to Active_DPM_User__c by MinheeKim - 2024.05.29

            }
            else{
            query += ' FROM User WHERE contact.Active_DPM_User__c = FALSE AND IsActive = FALSE AND ContactId != NULL'; //DPM-5301 changed from DPMActiveUser__c to Active_DPM_User__c by MinheeKim - 2024.05.29
        }
    }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.batchableContext BC, List<User> listUsers){
        List<User> usersToUpdate = new List<User>();
        
        for (User usr : listUsers) {
            if(usr.IsPortalEnabled) {
                usr.IsPortalEnabled = FALSE;
              usersToUpdate.add(usr);
              }
              listContactIds.add(usr.ContactId);
        }

        if (usersToUpdate.size() > 0) {
            update usersToUpdate;
        }

      
    }

    public void finish(Database.BatchableContext BC) {
        // Added below logic in finish to avoid mixed DML error
        if (listContactIds.size() > 0) {
            List<Contact> conList = [SELECT Id FROM Contact WHERE Id IN: listContactIds];

            if (conList != NULL && conList.size() > 0) {
                delete conList;
            }
            
        }
    }

}