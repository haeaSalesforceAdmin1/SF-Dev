public without sharing class BatchProccessAccountContactRoleUpdates implements Database.Batchable<SObject> {

    public DateTime asOfDateTime;
    public DateTime newAsOfDateTime;
    public String query;

    private static final string GENERAL_MANAGER = 'General Manager';
    private static final string DEALER_PRINCIPAL = 'Dealer Principal';

    public BatchProccessAccountContactRoleUpdates() {
        this.asOfDateTime = DateTime.now().addDays(-1);
        this.newAsOfDateTime = DateTime.now().addSeconds(-15);
    }

    public BatchProccessAccountContactRoleUpdates(DateTime asOfDateTime) {
        this.asOfDateTime = asOfDateTime;
        this.newAsOfDateTime = DateTime.now().addSeconds(-15);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        if(query == null) {
            query = 'select AccountId, ContactId, IsActive, LastModifiedDate, CreatedDate, Roles from AccountContactRelation where LastModifiedDate > :asOfDateTime order by CreatedDate desc';
        }
        return Database.getQueryLocator(query);
    }   

    public void execute(Database.BatchableContext BC, List<AccountContactRelation> relationships) {

        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        Set<String> accountRelationshipsProcessed = new Set<String>();

        List<AccountContactRelation> accountContactRelationshipsToDelete = new List<AccountContactRelation>();

        for(AccountContactRelation relationship:relationships) {
            if(!relationship.IsActive) {
                accountContactRelationshipsToDelete.add(relationship);
            }
            else {
                Account account;
                if(accountsToUpdate.containsKey(relationship.AccountId)) {
                    account = accountsToUpdate.get(relationship.AccountId);
                }
                
                String accountDealarPrincipalAccountRole = relationship.Id + DEALER_PRINCIPAL;
                if(!String.isBlank(relationship.Roles) &&  relationship.Roles.contains(DEALER_PRINCIPAL) && !accountRelationshipsProcessed.contains(accountDealarPrincipalAccountRole)) {
                    if(account == null) {
                        account = new Account(Id = relationShip.AccountId);
                    }
                   account.DealerPrincipal__c = relationship.ContactId;
                   accountRelationshipsProcessed.add(accountDealarPrincipalAccountRole);
                }

                String accountGeneralManagerAccountRole = relationship.Id + GENERAL_MANAGER;
                if(!String.isBlank(relationship.Roles) && relationship.Roles.contains(GENERAL_MANAGER) && !accountRelationshipsProcessed.contains(accountGeneralManagerAccountRole)) {
                    if(account == null) {
                        account = new Account(Id = relationShip.AccountId);
                    }
                    account.GeneralManager__c = relationship.ContactId;
                    accountRelationshipsProcessed.add(accountGeneralManagerAccountRole);
                }  

                if(account != null) {
                    accountsToUpdate.put(account.Id, account);
                }
            }
        }

        if(!accountsToUpdate.values().isEmpty()) {
            update accountsToUpdate.values();
        }

        /*if(!accountContactRelationshipsToDelete.isEmpty()) {
            delete accountContactRelationshipsToDelete;
        }*/
    }

    public void finish(Database.BatchableContext BC){

        DateTime nextFireDateTime = DateTime.now().addMinutes(15);
        String hour = String.valueOf(nextFireDateTime.hour());
        String min = String.valueOf(nextFireDateTime.minute()); 
        String ss = String.valueOf(nextFireDateTime.second());
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        System.schedule('Process Account Contact Relationship Updates ' + nextFireDateTime, nextFireTime, new ScheduleProccessAccountContactRoleUpd(newAsOfDateTime));
    }

}