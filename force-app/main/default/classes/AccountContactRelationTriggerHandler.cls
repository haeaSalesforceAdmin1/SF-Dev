public class AccountContactRelationTriggerHandler {
    public static Boolean isRunning = false; 
    
    /**
     * Updates the DNAMS_Role__c field on Contact records based on their roles in active AccountContactRelation records.
     * Created by Areum on 11-01-2024 for DNAMS PIR
     */
    public static void updateContactDNAMSRole(List<AccountContactRelation> newACRs) {
        if(isRunning) return;  
        isRunning = true;
        
        try {
            Set<Id> contactIds = new Set<Id>();
            for(AccountContactRelation acr : newACRs) {
                if(acr.IsActive && String.isNotBlank(acr.Roles) && acr.ContactId != null) {
                    contactIds.add(acr.ContactId);
                }
            }
            
            if(!contactIds.isEmpty()) {
                Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
                
                // First get DNAMS Active contacts
                Map<Id, Contact> dnamsContacts = new Map<Id, Contact>([
                    SELECT Id, DNAMS_Active_User__c 
                    FROM Contact 
                    WHERE Id IN :contactIds 
                    AND DNAMS_Active_User__c = true
                ]);
                
                if(!dnamsContacts.isEmpty()) {
                    for(AccountContactRelation acr : [SELECT ContactId, Roles 
                                                    FROM AccountContactRelation 
                                                    WHERE ContactId IN :dnamsContacts.keySet()
                                                    AND IsActive = true]) {
                        if(String.isNotBlank(acr.Roles)) {
                            Set<String> roles = new Set<String>(acr.Roles.split(';'));
                            String dnamsRole = getDNAMSRoleByPriority(roles);
                            if(dnamsRole != null) {
                                contactsToUpdate.put(acr.ContactId, new Contact(
                                    Id = acr.ContactId,
                                    DNAMS_Role__c = dnamsRole
                                ));
                            }
                        }
                    }
                    
                    if(!contactsToUpdate.isEmpty()) {
                        ContactTriggerHandler.run = false;  
                        update contactsToUpdate.values();
                        ContactTriggerHandler.run = true;   
                    }
                }
            }
        } finally {
            isRunning = false;
        }
    }
    
    /**
     * Update DNAMS roles and flags for contacts based on their active status and roles in AccountContactRelation.
     * Created by Areum on 11-01-2024 for DNAMS PIR
     */
    private static String getDNAMSRoleByPriority(Set<String> contactRoles) {
        List<String> rolePriority = new List<String>{
            'Dealer Principal',
            'General Manager',
            'Dealer Admin Support',
            'Office Manager'
        };
        
        for(String priorityRole : rolePriority) {
            if(contactRoles.contains(priorityRole)) {
                return priorityRole;
            }
        }
        return null;
    }

    /**
    * Handles the manual updates of DNAMSAccountUser__c field in AccountContactRelation.
    * Processes changes when the DNAMSAccountUser__c field is manually updated in the AccountContactRelation screen.
    * Created by Areum on 12-21-2024 for DNAMS PIR
    */
    public static void handleDNAMSAccessUpdate(List<AccountContactRelation> newACRs, Map<Id, AccountContactRelation> oldMap) {
        if(isRunning || ContactTriggerHandler.run) return;
        
        List<AccountContactRelation> acrsToUpdate = new List<AccountContactRelation>();
        
        for(AccountContactRelation acr : newACRs) {
            AccountContactRelation oldAcr = oldMap.get(acr.Id);
            
            if(acr.DNAMSAccountUser__c != oldAcr.DNAMSAccountUser__c) {
                acrsToUpdate.add(acr);
            }
        }
        
        if(!acrsToUpdate.isEmpty()) {
            isRunning = true;
            try {
                update acrsToUpdate;
            } finally {
                isRunning = false;
            }
        }
    }
}