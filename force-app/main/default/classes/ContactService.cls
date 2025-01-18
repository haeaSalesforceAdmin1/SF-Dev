public without sharing class ContactService {

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-05-29] for [DPM-5301] changed from DPMActiveUser__c to Active_DPM_User__c to combine in one field
    */
    public static void createContactDealerSharing(Map<Id, Contact> newContactsMap ) {

        Map<Id, List<Contact>> accountContactMap = new  Map<Id, List<Contact>>();

        for(Contact contact:newContactsMap.values()) {
            if(!accountContactMap.containsKey(contact.AccountId)) {
                accountContactMap.put(contact.AccountId, new List<Contact>());
            }
            accountContactMap.get(contact.AccountId).add(contact);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>([select Id, DealerCode__c from Account where Id in :accountContactMap.keyset()]);
        Map<Id, List<User>> accountUserMap = getAccountContactsMap(accountContactMap.keySet());

        System.debug(LoggingLevel.ERROR, 'accountUserMap ' + accountUserMap);
        Map<String, ObjectAccess__mdt> contactAccessTypes = getObjectAccessMapForContacts();
        Map<String, AccessType__mdt> accessTypesMap = getAccessTypeMap();

        HMAApexSharing apexSharing = new HMAApexSharing('ContactShare');
        Map<Id, ContactShare> existingSharesMap = apexSharing.getExistingContactSharesForContacts(newContactsMap.values());
        System.debug(LoggingLevel.ERROR, 'existingSharesMap');
        System.debug(LoggingLevel.ERROR, existingSharesMap);

        for(Contact contact:newContactsMap.values()) {
            Account contactAccount = accountMap.get(contact.AccountId);
            System.debug(LoggingLevel.ERROR, contactAccount);
            
            //if(contact.Active_DPM_User__c) { //DPM-5301 changed from DPMActiveUser__c to Active_DPM_User__c by MinheeKim - 2024.05.29

            //DPM-5301 changed from DPMActiveUser__c to Active_DPM_User__c by MinheeKim - 2024.05.29
            //DPM-5979 Added condition DNAMS_Active_User__c by Areum on 12-11-2024
            if(contact.Active_DPM_User__c || contact.DNAMS_Active_User__c) { 
                if(accountUserMap.containsKey(contact.AccountId)) {
                    for(User dealerUser:accountUserMap.get(contactAccount.Id)) {
                        Boolean processed = false;
                        System.debug(LoggingLevel.ERROR, dealerUser);
                        if(dealerUser.AccessTypes__c != null) {
                            for(String accessType:dealerUser.AccessTypes__c.split(',')) {
                                System.debug(LoggingLevel.ERROR, accessType);
                                if(accessType.contains('/') && accessType.contains(contactAccount.DealerCode__c)) {
                                    System.debug(LoggingLevel.ERROR, accessType);
                                    String[] dealerAccessType = accessType.split('/');

                                    if(accessTypesMap.containsKey(dealerAccessType[0])) {
                                        String objectAccessAPINames = accessTypesMap.get(dealerAccessType[0]).ObjectAccessAPINames__c;
                                        if(!String.isBlank(objectAccessAPINames)) {
                                            for(String objectAccessAPIName:objectAccessAPINames.split(',')) {
                                                System.debug(LoggingLevel.ERROR, dealerAccessType);
                                                if(contactAccessTypes.containsKey(objectAccessAPIName)){
                                                    if(existingSharesMap.containsKey(dealerUser.Id)) {
                                                        if(existingSharesMap.containsKey(dealerUser.Id)) {
                                                            existingSharesMap.remove(dealerUser.Id);
                                                            processed = true;
                                                            break;
                                                        }
                                                    }
                                                    
                                                    apexSharing.add(contact, dealerUser.Id, contactAccessTypes.get(objectAccessAPIName).AccessLevel__c, null);
                                                    processed = true;
                                                    break;
                                                }
                                            }
                                            if(processed) {
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        apexSharing.share();

        if(!existingSharesMap.keySet().isEmpty()) {
            for(Id contactId:existingSharesMap.keySet()) {
                //if(!existingSharesMap.get(contactId).keySet().isEmpty()) {
                //for(String groupDeveloperName:existingSharesMap.get(contactId).keySet()) {
                ContactShare shareToRemove = (ContactShare) existingSharesMap.get(contactId);
                apexSharing.remove(new Contact(Id = shareToRemove.ContactId), shareToRemove.UserOrGroupId, 'Read', 'Manual');
                //}
                //}
            }
        }
        apexSharing.unshare();
    }

    private static Map<Id, List<User>> getAccountContactsMap(Set<Id> accountIds) {
        Map<Id, List<User>> accountUserMap = new Map<Id, List<User>>();

        Map<Id, List<Id>> mapContactIdsToAccountIdsList = new Map<Id, List<Id>>();
        System.debug(LoggingLevel.ERROR,accountIds);
        for(AccountContactRelation accountContactRelation:[select Id, AccountId, ContactId from AccountContactRelation where AccountId in :accountIds]) {
            System.debug(LoggingLevel.ERROR,accountContactRelation);
            if(!mapContactIdsToAccountIdsList.containsKey(accountContactRelation.ContactId)) {
                mapContactIdsToAccountIdsList.put(accountContactRelation.ContactId, new List<Id>());
            }
            mapContactIdsToAccountIdsList.get(accountContactRelation.ContactId).add(accountContactRelation.AccountId);
        }

        for(User user:[select Id, AccountId, Account.DealerCode__c, ContactId, AccessTypes__c from User where ContactId in :mapContactIdsToAccountIdsList.keySet()]) {
            for(Id accountId:mapContactIdsToAccountIdsList.get(user.ContactId)) {
                if(!accountUserMap.containsKey(accountId)) {
                    accountUserMap.put(accountId, new List<User>());
                }
                accountUserMap.get(accountId).add(user);
            }
        }
        System.debug(LoggingLevel.ERROR, accountUserMap);
        return accountUserMap;
    }

    public static Map<String, AccessType__mdt> getAccessTypeMap() {

        Map<String, AccessType__mdt> accessTypeMap = new Map<String, AccessType__mdt>();
        for(AccessType__mdt accessType:[select Id, DeveloperName, ObjectAccessAPINames__c from AccessType__mdt]) {

            System.debug(LoggingLevel.ERROR, accessType);
            accessTypeMap.put(accessType.DeveloperName, accessType);
        }
        return accessTypeMap;
    }

    private static Map<String, ObjectAccess__mdt> getObjectAccessMapForContacts() {

        Map<String, ObjectAccess__mdt> objectAccessMap = new Map<String, ObjectAccess__mdt>();
        for(ObjectAccess__mdt objectAccess:[select Id, AccessLevel__c, ObjectAPINames__c, DeveloperName from ObjectAccess__mdt where Active__c = true ]) {
            if(objectAccess.ObjectAPINames__c.contains('Contact')) {
                objectAccessMap.put(objectAccess.DeveloperName, objectAccess);
            }
        }
        System.debug(LoggingLevel.ERROR, objectAccessMap);
        return objectAccessMap;
    }
}