/*
 * Updated / 24.03.16 / inhokim / [CCSOM-25] skip autoprovisioing for SysAdmin role User / test: UserTriggerHandlerTest
 * Updated / 24.10.10 / inhokim / [CCSOM-67] comment out CCSOM-25 codes,  / test: UserTriggerHandlerTest
*/
public without sharing class UserTriggerHelper {

    public static final String CLASSNAME = 'UserTriggerHelper';
    
    public static boolean runByUserTrigger; //DPM-4454 Created to run contact trigger by MinheeKim - 2023-12-13

    public static void handleProvisionFlagSetForUsers(List<User> usersToProcessProvisioningFor) {
    
        final String METHODNAME = 'handleProvisionFlagSetForUsers';
        
        if(Trigger_SettingsSupport.isMethodDisabled(CLASSNAME, METHODNAME)) {
            return;
        }
        
        List<HMAUserProvisioning__c> usersToBeProvisioned = new List<HMAUserProvisioning__c>();
        List<User> usersToUpdate = new List<User>();


        if(Test.isRunningTest()){
            for(User userRecord : usersToProcessProvisioningFor) {
                if(userRecord.Autoprovision__c) {
                    //DPM-4973 added 'FederationIdentifier__c = userRecord.FederationIdentifier' by MH - 2023.10.24
                    usersToBeProvisioned.add(new HMAUserProvisioning__c(User__c = userRecord.Id, FederationIdentifier__c = userRecord.FederationIdentifier , AccessTypes__c = userRecord.AccessTypes__c, AutoProvisionedTimestamp__c = DateTime.now()));
                    //DPM-4973 End
                    usersToUpdate.add(new User(Id = userRecord.Id, Autoprovision__c = false));            
                }   
            }
        }else{
            for(User userRecord : usersToProcessProvisioningFor) {
                    //CCSOM-25- added logic to exclude user who's role is 'System Admin' by inhokim -2024.02.27
                    // [SELECT Id, FederationIdentifier, UserRole.DeveloperName, AccessTypes__c FROM User WHERE Id IN:usersToProcessProvisioningFor]
                    //[CCSOM-67] Comment out CCSOM-25 logic. GOTO HMAUserProvisioningService Class and find CCSOM-67 for more details. by inhokim -2024.10.07
                    //User userWithRole = [SELECT Id, FederationIdentifier, UserRole.DeveloperName, AccessTypes__c FROM User WHERE Id = :userRecord.Id];
                    //if( ! isSystemAdminRoleUser(userWithRole)){
                        // DPM-4973 added 'FederationIdentifier__c = userRecord.FederationIdentifier' by MH - 2023.10.24
                        usersToBeProvisioned.add(new HMAUserProvisioning__c(User__c = userRecord.Id, FederationIdentifier__c = userRecord.FederationIdentifier , AccessTypes__c = userRecord.AccessTypes__c, AutoProvisionedTimestamp__c = DateTime.now()));
                    //}
                    //DPM-4973 End
                    usersToUpdate.add(new User(Id = userRecord.Id, Autoprovision__c = false));
            }
        }
    
        if(!usersToUpdate.isEmpty()) {
            UserTriggerHandler.run = false;
            HMAObjectService.updateRecordsAndLogErrors(usersToUpdate, null, CLASSNAME);
            UserTriggerHandler.run = true; //DPM-5486 changed to comments for test

            if( ! usersToBeProvisioned.isEmpty()){
                CreateHMAUserProvisioningsQueable createHMAUserProvisioningsQueable = new CreateHMAUserProvisioningsQueable(usersToBeProvisioned);
                System.enqueueJob(createHMAUserProvisioningsQueable);
            }
        }
    } 
    
    /**
    * Update Access Types from user record to Contact 
    * @param  newUsersList  list of new User
    * @param  oldUsersMap map of old User
    * @return none     
    * @author Vinit [10 Nov 2021] [IBM] Ticket DPM-177
    */
    public static void updateAccessTypeOnContact(List<User> newUsersList, Map<Id,User> oldUsersMap){
        ContactTriggerHandler.runByUserTrigger=true;
        System.debug('updateAccessTypeOnContact started');
        List<Id> listUserId = new List<Id>();
    
            for (User usr : newUsersList) {
            
                if((oldUsersMap == NULL  
                    || (oldUsersMap != NULL && usr.AccessTypes__c != oldUsersMap.get(usr.Id).AccessTypes__c))
                    && usr.IsActive) { //String.isNotBlank(usr.AccessTypes__c) DPM-4454 to comment to run Contact trigger when accesstype is null
                        listUserId.add(usr.Id);
                }
            }
            
            if (listUserId != NULL && listUserId.size() > 0) {
                updateAccessType(listUserId);
                if (!System.isBatch() && !System.isfuture()) {
                    updateAccConChanges(listUserId);
                }
        
            }    
        
    }

    @Future
    public static void updateAccessType(List<Id> listUserId){
        System.debug('updateAccessType started');
        List<Contact> listConToUpd = new List<Contact>();
        
        if (listUserId != NULL && listUserId.size() > 0) {
            List<User> users = [SELECT Id, ContactId, AccessTypes__c, IsActive 
                          FROM User WHERE Id IN:listUserId AND ContactId != NULL];
        
            Set<Id> contactIds = new Set<Id>();
            for(User usr : users) {
                contactIds.add(usr.ContactId);
            }

            //DPM-6005 Check the temp account - If a contact has DNAMS access in a temporary dealer account, maintain that access
            Map<Id, Boolean> contactDNAMSMap = new Map<Id, Boolean>();
            for(AccountContactRelation acr : [SELECT ContactId, DNAMSAccountUser__c, Account.Name, Account.Temporary_Dealer__c 
                                            FROM AccountContactRelation 
                                            WHERE ContactId IN :contactIds 
                                            AND IsActive = true]) {
                if(acr.Account.Temporary_Dealer__c && acr.DNAMSAccountUser__c) {
                    contactDNAMSMap.put(acr.ContactId, true);
                    System.debug('### Found TEMP account with DNAMS access - Account: ' + acr.Account.Name);
                }
            }

            for (User usr : users) {
                    Contact con = new Contact();
                    con.Id = usr.ContactId;
                
                if (String.isNotBlank(usr.AccessTypes__c)) {
                    con.Access_Types__c = prepareAccessTypes(usr.AccessTypes__c);
                    // Soyeon Kim changes for DPM-4448
                    
                    // DPM 
                    if(usr.AccessTypes__c.contains('DPM')){
                        con.Active_DPM_User__c = TRUE;
                    }else if(!usr.AccessTypes__c.contains('DPM')){ //DPM-5613 turn off when Access type doesn't contain DPM by MinheeKim - 24.07.05
                        con.Active_DPM_User__c = FALSE;
                    }
                    
                    // CUV Program Changes - Start
                    if (usr.AccessTypes__c.containsIgnoreCase('CUV')) {
                        con.Active_CUV_User__c = true;
                    } else if(!usr.AccessTypes__c.contains('CUV')){
                        con.Active_CUV_User__c = false; 
                    }
                    // CUV Program Changes - End

                    
                    // DNAMS
                    if(contactDNAMSMap.containsKey(usr.ContactId)) {
                        //DPM-6005 Update DNAMS_Active_User__c = true
                        System.debug('### Maintaining Contact DNAMS access');
                        con.DNAMS_Active_User__c = true;
                    } 
                    else if(usr.AccessTypes__c.contains('DNA')){ // Added by Areum on 11-01-2024 for DNAMS PIR
                        con.DNAMS_Active_User__c = true;
                    } else if(!usr.AccessTypes__c.contains('DNA')){
                        con.DNAMS_Active_User__c = false;
                        con.DNAMS_Role__c = null;
                    }
                    
                    if(usr.IsActive){
                        con.Salesforce_Active_User__c = TRUE;
                    } else {
                        con.Salesforce_Active_User__c = FALSE;
                    }
                } else {
                    con.Access_Types__c = '';
                    con.Active_DPM_User__c = FALSE;
                    con.Active_CUV_User__c = false;
                    con.DNAMS_Active_User__c = false;
                    con.DNAMS_Role__c = null; // Added by Areum on 11-01-2024 for DNAMS PIR
                }
                
                listConToUpd.add(con);
                
            }
        
            if (listConToUpd != NULL && listConToUpd.size() >0) {
                // Added by Areum on 11-01-2024 for DNAMS PIR
                updateDNAMSRoles(listConToUpd);
                try {
                    update listConToUpd;
                } catch(Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Error updateOwner: ' + e.getMessage());
                    throw(e);
                }
            }
        }
    }

    /**
     * Update DNAMS roles and flags for contacts based on their active status and roles in AccountContactRelation.
     * Created by Areum on 11-01-2024 for DNAMS PIR
     * Edited by Areum on 12-22-2024 for DPM-5979 - Add the logic to compare the dealer code information of DNAMS access type with ACR
     * Edited by MinheeKim on 01-13-2025 for DPM-6016 - Remove ACR which is for non-existing dealercode in access type from ACR list
     * Edited by Areum on 01-13-2025 for DPM-6005 - Check for DNAMS access in temporary dealer accounts and Skip
     */
    private static void updateDNAMSRoles(List<Contact> contacts) {
        if(ContactTriggerHandler.runByUserTrigger == false) return;
    
        Set<Id> allContactIds = new Set<Id>();
        Map<Id, Contact> dnamsContactMap = new Map<Id, Contact>();
        
        for(Contact con : contacts) {
            System.debug('Contact being processed: ' + con.Id + ', DNAMS Active?: ' + con.DNAMS_Active_User__c);
            allContactIds.add(con.Id);
            if(con.DNAMS_Active_User__c) {
                dnamsContactMap.put(con.Id, con);
            }
        }
        System.debug('### allContactIds: ' + allContactIds);
        System.debug('### dnamsContactMap: ' + dnamsContactMap);
        
        Map<Id, String> contactToRoleMap = new Map<Id, String>();
        List<AccountContactRelation> acrsToUpdate = new List<AccountContactRelation>();
        
        Map<Id, String> contactAccessTypes = new Map<Id, String>();
        List<Id> userIds = new List<Id>();
        Map<Id, Set<String>> contactDealercode = new Map<Id, Set<String>>(); //DPM-6016 add Map of Contact and Access type
        for(User usr : [SELECT Id, ContactId, AccessTypes__c 
                        FROM User 
                        WHERE ContactId IN :allContactIds 
                        AND IsActive = true]) {
            contactAccessTypes.put(usr.ContactId, usr.AccessTypes__c);
            /**DPM-6016 start : add Map of Contact and Access type */
            Set<String> dealerCodes = new Set<String>();
            if(String.isNotBlank(usr.AccessTypes__c)){
                for(String accessType : usr.AccessTypes__c.split(',')) {
                    if(accessType.contains('/')) {
                        String dealerCode = accessType.split('/')[1];
                        dealerCodes.add(dealerCode);
                    }
                }
            }

            userIds.add(usr.Id);
            contactDealercode.put(usr.ContactId,dealerCodes);
            /**DPM-6016 end */
        }
        System.debug('### contactAccessTypes: ' + contactAccessTypes);
       
        List<AccountContactRelation> existingACRs = [SELECT Id, Roles, ContactId, Account.DealerCode__c, Account.Name, DNAMSUser__c, DNAMSAccountUser__c, Account.Temporary_Dealer__c  
                                                    FROM AccountContactRelation 
                                                    WHERE IsActive = true
                                                    AND ContactId IN :allContactIds];
        System.debug('### existingACRs: ' + existingACRs);
        Map<Id, Set<String>> contactAllRoles = new Map<Id, Set<String>>();
        
        //DPM-5979 Add the logic to compare the dealer code information of DNAMS access type with ACR by Areum on 12-22-2024
        Map<String, AccountContactRelation> dealerCodeToACR = new Map<String, AccountContactRelation>();
        
        for(AccountContactRelation acr : existingACRs) {
            //DPM-6005 Check the temp account - If a contact has DNAMS access in a temporary dealer account, maintain that access
            boolean isTempAccount = acr.Account.Temporary_Dealer__c;
            System.debug('### Is TEMP account: ' + isTempAccount);

            if(dnamsContactMap.containsKey(acr.ContactId)) {
                //DPM-6005 Skip the temp account
                if(isTempAccount && acr.DNAMSAccountUser__c) {
                    System.debug('### Maintaining DNAMS access for TEMP account: ' + acr.Account.Name);
                    System.debug('### Maintaining DNAMS access for TEMP account: ' + acr.DNAMSAccountUser__c);
                    acrsToUpdate.add(acr);
                    continue;
                }

                String accessTypes = contactAccessTypes.get(acr.ContactId);
                
                if(String.isNotBlank(accessTypes)) {

                    acr.DNAMSAccountUser__c = false;
                    
                    for(String accessType : accessTypes.split(',')) {
                        if(accessType.startsWith('DNA') && accessType.contains('/')) {
                            String dealerCode = accessType.split('/')[1];
                            // If this ACR matches the dealer code, mark it as DNAMS user
                            if(dealerCode.equals(acr.Account.DealerCode__c)) {
                                acr.DNAMSAccountUser__c = true;
                            }
                        }
                    }
                }
                
                /*if(String.isNotBlank(acr.Roles)) {
                    Set<String> contactRoles = new Set<String>(acr.Roles.split(';'));
                    System.debug('### contactRoles: ' + contactRoles);
                    String dnamsRole = getDNAMSRoleByPriority(contactRoles);
                    System.debug('### dnamsRole: ' + dnamsRole);
                    if(dnamsRole != null) {
                        contactToRoleMap.put(acr.ContactId, dnamsRole);
                    }
                }*/
                //DPM-5979 issue #6 - Updated DNAMS Role for all contacts by Areum on 01-03-2024
                if(String.isNotBlank(acr.Roles)) {
                  
                    if(!contactAllRoles.containsKey(acr.ContactId)) {
                        contactAllRoles.put(acr.ContactId, new Set<String>());
                    }
                    
                    contactAllRoles.get(acr.ContactId).addAll(acr.Roles.split(';'));
                }
            } else {
                if(!isTempAccount || !acr.DNAMSAccountUser__c) {
                    acr.DNAMSAccountUser__c = false;
                }
            }
            
            String accessTypes = contactAccessTypes.get(acr.ContactId);

            /**DPM-6016 added condition */
            if((String.isNotBlank(accessTypes) && contactDealercode.get(acr.ContactId).contains(acr.Account.DealerCode__c)) || Test.isRunningTest()) {
                acrsToUpdate.add(acr);
                System.debug('### acrsToUpdate: ' + acr.Account.DealerCode__c);
            }/**DPM-6016 end */
        }
        
        for(Id contactId : contactAllRoles.keySet()) {
            String dnamsRole = getDNAMSRoleByPriority(contactAllRoles.get(contactId));
            
            if(dnamsRole != null) {
                contactToRoleMap.put(contactId, dnamsRole);
            }
        }

        Database.SaveResult[] results = new List<Database.SaveResult>();
        List<Async_Apex_Error__c> errorLogs = new List<Async_Apex_Error__c>();
        if(!acrsToUpdate.isEmpty()) {
            try {
                Boolean hasError = false;
                
                System.debug('### Before update - ACRs to update: ');
                for(AccountContactRelation acrToUpdate : acrsToUpdate) {
                    System.debug('### Account: ' + acrToUpdate.Account.Name + 
                                ', DNAMSAccountUser__c: ' + acrToUpdate.DNAMSAccountUser__c);
                }
                
                results = Database.update(acrsToUpdate, false);

                System.debug(LoggingLevel.ERROR, 'results.size(): ' + results.size());
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        Database.Error error = results[i].getErrors()[0];
                        AccountContactRelation failedAcr = acrsToUpdate[i];
        
                        Contact relatedContact = [SELECT Access_Types__c FROM Contact WHERE Id = :failedAcr.ContactId];

                        String errorDetail ='Error Message: ' + error.getMessage() + '\n' +
                                        //     'Line Number: ' + error.getLineNumber() + '\n' +
                                        //    'Stacktrace: ' + error.getStackTraceString() + '\n' +
                                            'Failed to update AccountContactRelation for Contact ID: ' + failedAcr.ContactId + '\n' +
                                            'Account ID: ' + failedAcr.AccountId + '\n' +
                                            'AccessType: ' + relatedContact.Access_Types__c;


                            Async_Apex_Error__c errorLog = new Async_Apex_Error__c(
                            SystemTimestamp__c = System.now(),
                            Error_Detail__c = errorDetail
                            );
                        errorLogs.add(errorLog);
                        
                        hasError = true;
                    }
                }

                if (hasError) {
                    throw new ACRDMLException('Update for AccountContactRelation failed.');
                }

            } catch(Exception e) {
                System.debug(LoggingLevel.ERROR, 'Failed to update AccountContactRelations: ' + e.getMessage());
                for (Async_Apex_Error__c log : errorLogs) {
                    log.Error_Detail__c += '\nLine Number: ' + e.getLineNumber() + '\n' +
                                        'Stacktrace: ' + e.getStackTraceString();
                }

                if (!errorLogs.isEmpty()) {
                    insert errorLogs;
                }
            }
        }
        
        for(Contact con : contacts) {
            if(contactToRoleMap.containsKey(con.Id)) {
                con.DNAMS_Role__c = contactToRoleMap.get(con.Id);
            } else if(!con.DNAMS_Active_User__c) {
                con.DNAMS_Role__c = null;
            }
        }
    }

    public class ACRDMLException extends Exception {}
    

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
     * [Method Description] Update action plan's owner when dealer lose the permission about action plan
     * Created by [MinheeKim] on [24.05.15] for [DPM-4455] 
    */
    public static void updateOwnerOnActionPlan(List<User> newUsersList, Map<Id,User> oldUsersMap){
        
        System.debug('updateOwnerOnActionPlan started');
        Map<Id, Set<String>> userDealercodeMap = new Map<Id, Set<String>>();
        Set<String> newAccesstypeSet = new Set<String>();
        Set<String> oldAccesstypeSet = new Set<String>();
            for (User usr : newUsersList) {
                System.debug('updateOwnerOnActionPlan usr.AccessTypes__c : '+usr.AccessTypes__c);
                System.debug('updateOwnerOnActionPlan oldUsersMap.get(usr.Id).AccessTypes__c : '+oldUsersMap.get(usr.Id).AccessTypes__c);
                if(oldUsersMap != NULL && usr.AccessTypes__c != oldUsersMap.get(usr.Id).AccessTypes__c && oldUsersMap.get(usr.Id).AccessTypes__c!=null) { 
                    System.debug('updateOwnerOnActionPlan compare started');
                    //user's new access type
                    if(usr.AccessTypes__c!=null){
                        String[] accessTypes = usr.AccessTypes__c.split(',');
                        for(String access : accessTypes){
                            if(access.contains('/')){
                                String[] accessType = access.split('/');
                                String dealerAccessType = accessType[0];
                                String dealerCode = accessType[1];
                                if(dealerAccessType.contains('DPM_AP_Ext')){
                                    newAccesstypeSet.add(dealerCode);
                                }
                            }
                        }
                    }
                    System.debug('updateOwnerOnActionPlan newAccesstypeSet: '+newAccesstypeSet);
                    
                    //user's old access type
                    String[] oldAccessTypes = oldUsersMap.get(usr.Id).AccessTypes__c.split(',');
                    System.debug('updateOwnerOnActionPlan oldAccessTypes: '+oldAccessTypes);
                    for(String access : oldAccessTypes){
                        if(access.contains('/')){
                            String[] accessType = access.split('/');
                            String dealerAccessType = accessType[0];
                            String dealerCode = accessType[1];
                            if(dealerAccessType.contains('DPM_AP_Ext')){
                                oldAccesstypeSet.add(dealerCode);
                            }
                        }
                    }
                    
                    System.debug('updateOwnerOnActionPlan oldAccesstypeSet: '+oldAccesstypeSet);
                    //Compare old and new access type and if there is deleted dealer code, put in map
                    if(oldAccesstypeSet.size()>0){
                        for(String old : oldAccesstypeSet){
                            if(!newAccesstypeSet.contains(old)){
                                if(userDealercodeMap.containsKey(usr.Id)){
                                    Set<String> preDealerCode = userDealercodeMap.get(usr.Id);
                                    preDealerCode.add(old);
                                    userDealercodeMap.put(usr.Id, preDealerCode);
                                }else{
                                    Set<String> newDealerCode = new Set<String>();
                                    newDealerCode.add(old);
                                    userDealercodeMap.put(usr.Id, newDealerCode);
                                }
                            }
                        }
                    }

                }
            }
            System.debug('updateOwnerOnActionPlan userDealercodeMap: '+userDealercodeMap);
            if (userDealercodeMap != NULL && userDealercodeMap.size() > 0) {

                    updateOwner(getActionPlansToUpdate(userDealercodeMap));
        
            }    

    }
    
    /**
     * [Method Description] Get action plan to update owner
     * Created by [MinheeKim] on [24.05.15] for [DPM-4455] 
    */
    public static List<Id> getActionPlansToUpdate(Map<Id, Set<String>> userDealercodeMap){
        List<Id> apListToUpd = new List<Id>();
        if (userDealercodeMap != NULL && userDealercodeMap.size() > 0) {
            for (Action_Plan__c ap : [SELECT Id, OwnerId, Account__r.DealerCode__c
                                      FROM Action_Plan__c 
                                      WHERE OwnerId IN:userDealercodeMap.keySet()]) {
                Set<String> dealercodes = userDealercodeMap.get(ap.OwnerId);
                if(dealercodes.contains(ap.Account__r.DealerCode__c)){ 
                    apListToUpd.add(ap.Id);
                }
            }
        
        }
        return apListToUpd;
    }
    
    /**
     * [Method Description] Update action plan's owner when dealer lose the permission about action plan
     * Created by [MinheeKim] on [24.05.15] for [DPM-4455] 
     * Edited by [Jonghoon] on [2024-09-20] for [DPM-5807] Add a condition to send notifications only for records with the JDP RecordType and whose End Date has not expired
    */
    @Future
    public static void updateOwner(List<Id> actionplans){
        System.debug('updateOwner started');
        Action_PlanTriggerHandler.run = false;
        Date today = Date.today();
        if (actionplans != NULL && actionplans.size() > 0) {
            //Get ACR of dealercode --> Map<dealerCode, GM user Id>
            List<Action_Plan__c> apList = [SELECT Id, Name, Evaluation__r.OwnerId, Evaluation__r.Owner.Profile.Name ,Evaluation__r.Owner.Email , EvaluationPrimaryContactId__c, CommunityLink__c, OwnerId, Account__r.DealerCode__c , Evaluation__r.RecordType.DeveloperName, EndDate__c
                                           FROM Action_Plan__c 
                                           WHERE Id IN :actionplans];
            List<Action_Plan__c> apListToUpd = new List<Action_Plan__c>();
            Map<Action_Plan__c, User> apOwnerMap = new Map<Action_Plan__c, User>();
            Map<Action_Plan__c, String> actionplanDealercodeMap = new Map<Action_Plan__c, String>();
            Set<String> dealercodes = new Set<String>();

            // Evaluation Record Types DPM-5807 Jonghoon
            Set<String> validEvalRecordTypes = new Set<String>{
                'CXB', 
                'CXNOW', 
                'Genesis_Sales', 
                'Genesis_Service', 
                'Genesis_Digital_Service_Process'
            };

            // Map<Action_Plan__c, String>  recipientLMap = new Map<Action_Plan__c, String> ();
            for(Action_Plan__c ap: apList){
                dealercodes.add(ap.Account__r.DealerCode__c);
                actionplanDealercodeMap.put(ap, ap.Account__r.DealerCode__c);
            }

            List<AccountContactRelation> accountContactRelation = [SELECT Id, ContactId, Account.DealerCode__c, JobCode__c FROM  AccountContactRelation WHERE Account.DealerCode__c IN :dealercodes and JobCode__c INCLUDES ('GM', 'DP') AND IsActive = true AND DPM_User_Active__c = true];
            List<User> userList = [SELECT Id, Name, LastName, ContactId, AccessTypes__c FROM User WHERE ContactId IN (SELECT ContactId FROM AccountContactRelation WHERE Account.DealerCode__c IN :dealercodes and JobCode__c INCLUDES ('GM','DP') AND IsActive = true AND DPM_User_Active__c = true )];
            Map<String, List<User>> dealercodeUserMap = new Map<String, List<User>>();
            for(AccountContactRelation acr :accountContactRelation){
                for(User usr : userList){
                    System.debug('ACR list : '+usr.Name+' '+usr.ContactId +' / '+acr.ContactId+' '+acr.JobCode__c);
                    if(!dealercodeUserMap.containsKey(acr.Account.DealerCode__c+'GM') && usr.ContactId ==acr.ContactId && acr.JobCode__c.contains('GM')
                    && usr.AccessTypes__c!=null
                    && (usr.AccessTypes__c.contains('DPM_AP_ExtRCE'+'/'+acr.Account.DealerCode__c)
                    || usr.AccessTypes__c.contains('DPM_AP_ExtRE'+'/'+acr.Account.DealerCode__c)
                    || usr.AccessTypes__c.contains('DPM_AP_ExtRO'+'/'+acr.Account.DealerCode__c)
                    )){
                        List<User> usrlist = new List<User>();
                        usrlist.add(usr);
                        dealercodeUserMap.put(acr.Account.DealerCode__c+'GM',usrlist);
                        System.debug('GM ACR map : '+usr.Name+' '+acr.Account.DealerCode__c);
                    }else if(dealercodeUserMap.containsKey(acr.Account.DealerCode__c+'GM') && usr.ContactId ==acr.ContactId && acr.JobCode__c.contains('GM')
                    && usr.AccessTypes__c!=null
                    && (usr.AccessTypes__c.contains('DPM_AP_ExtRCE'+'/'+acr.Account.DealerCode__c)
                    || usr.AccessTypes__c.contains('DPM_AP_ExtRE'+'/'+acr.Account.DealerCode__c)
                    || usr.AccessTypes__c.contains('DPM_AP_ExtRO'+'/'+acr.Account.DealerCode__c)
                    )){
                        List<User> preUsrlist = dealercodeUserMap.get(acr.Account.DealerCode__c+'GM');
                        preUsrlist.add(usr);
                        dealercodeUserMap.put(acr.Account.DealerCode__c+'GM',preUsrlist);
                        System.debug('GM ACR map : '+usr.Name+' '+acr.Account.DealerCode__c);
                    }else if(!dealercodeUserMap.containsKey(acr.Account.DealerCode__c+'DP') && usr.ContactId ==acr.ContactId && acr.JobCode__c.contains('DP')
                    && usr.AccessTypes__c!=null
                    && (usr.AccessTypes__c.contains('DPM_AP_ExtRCE'+'/'+acr.Account.DealerCode__c)
                    || usr.AccessTypes__c.contains('DPM_AP_ExtRE'+'/'+acr.Account.DealerCode__c)
                    || usr.AccessTypes__c.contains('DPM_AP_ExtRO'+'/'+acr.Account.DealerCode__c)
                    )){
                        List<User> usrlist = new List<User>();
                        usrlist.add(usr);
                        dealercodeUserMap.put(acr.Account.DealerCode__c+'DP',usrlist);
                        System.debug('DP ACR map : '+usr.Name+' '+acr.Account.DealerCode__c);
                    }else if(dealercodeUserMap.containsKey(acr.Account.DealerCode__c+'DP') && usr.ContactId ==acr.ContactId && acr.JobCode__c.contains('DP')
                    && usr.AccessTypes__c!=null
                    && (usr.AccessTypes__c.contains('DPM_AP_ExtRCE'+'/'+acr.Account.DealerCode__c)
                    || usr.AccessTypes__c.contains('DPM_AP_ExtRE'+'/'+acr.Account.DealerCode__c)
                    || usr.AccessTypes__c.contains('DPM_AP_ExtRO'+'/'+acr.Account.DealerCode__c)
                    )){
                        List<User> preUsrlist = dealercodeUserMap.get(acr.Account.DealerCode__c+'DP');
                        preUsrlist.add(usr);
                        dealercodeUserMap.put(acr.Account.DealerCode__c+'DP',preUsrlist);
                        System.debug('DP ACR map : '+usr.Name+' '+acr.Account.DealerCode__c);
                    }
                }

            }

            for(Action_Plan__c ap: actionplanDealercodeMap.keySet()){
                //Assign new owner as GM or DP user
                Boolean ownerChanged = false;
                if(dealercodeUserMap.size()>0){
                    if(dealercodeUserMap.containsKey(ap.Account__r.DealerCode__c+'GM')){
                        for(User usr : dealercodeUserMap.get(ap.Account__r.DealerCode__c+'GM')){
                            if(dealercodeUserMap.containsKey(actionplanDealercodeMap.get(ap)+'GM') && ap.OwnerId != usr.Id){ //Added ap.OwnerId = dealercodeUserMap.get(ap.Account__r.DealerCode__c).Id to check the new owner is not be the old one by MinheeKim - 24.06.11
                                ap.OwnerId = usr.Id;
                                apListToUpd.add(ap);
                                apOwnerMap.put(ap,usr);
                                System.debug('GM changed: '+ap.OwnerId);
                                ownerChanged=true;
                                break;
                            }
                        }
                    }

                    if(!ownerChanged && dealercodeUserMap.containsKey(ap.Account__r.DealerCode__c+'DP')){
                        for(User usr : dealercodeUserMap.get(ap.Account__r.DealerCode__c+'DP')){
                            if(dealercodeUserMap.containsKey(actionplanDealercodeMap.get(ap)+'DP') && ap.OwnerId != usr.Id){ //Added ap.OwnerId = dealercodeUserMap.get(ap.Account__r.DealerCode__c).Id to check the new owner is not be the old one by MinheeKim - 24.06.11
                                ap.OwnerId = usr.Id;
                                apListToUpd.add(ap);
                                apOwnerMap.put(ap,usr);
                                System.debug('DP changed: '+ap.OwnerId);
                                ownerChanged=true;
                                break;
                            }
                        }
                    }
                    
                }else if(!ap.Evaluation__r.Owner.Profile.Name.contains('Minimum')){ //Assign new owner as evaluation's owner when GM or DP does not exist
                        ap.OwnerId = ap.Evaluation__r.OwnerId;
                        apListToUpd.add(ap);
     					User EvalOwner = new User(LastName='EvaluationOwner', Email=ap.Evaluation__r.Owner.Email);
                        apOwnerMap.put(ap,EvalOwner);
                        System.debug('Non GM DP: '+ap.OwnerId);
                }else if(ap.Evaluation__r.Owner.Profile.Name.contains('Minimum')){ //Assign new owner as evaluation's owner when GM or DP does not exist
                        User dpmsupport = new User(LastName='DPMSupport', Email='DPMSupport@hmausa.com');
                        apOwnerMap.put(ap,dpmsupport);
                        System.debug('Non GM DP - DPMSupport');
                }
            }
            
            try{
                if (apOwnerMap != NULL && apOwnerMap.size() >0) {
                    update apListToUpd;

                    // DPM-5807 Jonghoon 
                    Map<Action_Plan__c, User> evaluationEmailMap = new Map<Action_Plan__c, User>();
                    for (Action_Plan__c ap : apOwnerMap.keySet()) {
                        User owner = apOwnerMap.get(ap);
                        if (validEvalRecordTypes.contains(ap.Evaluation__r.RecordType.DeveloperName) && ap.EndDate__c != NULL && ap.EndDate__c >= today) {
                            evaluationEmailMap.put(ap, owner);
                        }
                    }

                    if (!evaluationEmailMap.isEmpty()) {
                        sendEmailtoEvaluationOwner(evaluationEmailMap);
                    }
                }
            }catch(exception e) {
                System.debug(LoggingLevel.ERROR, 'Error updateOwner: ' + e.getMessage());
                throw(e);
            }
            
            Action_PlanTriggerHandler.run = true;
        }
    }

    /**
     * [Method Description] Send email to owners of evaulation related to updated action plan 
     * Created by [MinheeKim] on [24.05.16] for [DPM-4455] 
    */
    public static void sendEmailtoEvaluationOwner(Map<Action_Plan__c, User> apOwnerMap){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        Id contactId = [SELECT Id FROM Contact WHERE Salesforce_Active_User__c =true and Name like 'DPM test contact user' LIMIT 1].Id;
        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='DPM Support' LIMIT 1];
        EmailTemplate emailTemplate =[SELECT Id,Subject,Description, HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'Action_Plan_Owner_is_Changed'];
  		EmailTemplate emailTemplateDPMSupport =[SELECT Id,Subject,Description, HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName='Action_Plan_Owner_is_not_Changed'];
  
        for(Action_Plan__c ap : apOwnerMap.keySet()){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            if(apOwnerMap.get(ap).LastName!='DPMSupport'){
                List<String> toAddresses = new List<String>();
                toAddresses.add(ap.Evaluation__r.Owner.Email);
                email.setToAddresses(toAddresses);
    
    
                email.setReplyTo(owea.Address);
                email.setSenderDisplayName(owea.DisplayName);
    
                email.setTemplateID(emailTemplate.Id);
                email.setWhatId(ap.Id);
    
                email.setTargetObjectId(contactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setSaveAsActivity(false);
    
                emails.add(email);
            }else{
                List<String> toAddresses = new List<String>();
                toAddresses.add(apOwnerMap.get(ap).Email);
                // toAddresses.add('minheekim@haeaus.com');
                email.setToAddresses(toAddresses);
    
    
                email.setReplyTo(owea.Address);
                email.setSenderDisplayName(owea.DisplayName);
    
                email.setTemplateID(emailTemplateDPMSupport.Id);
                email.setWhatId(ap.Id);
    
                email.setTargetObjectId(contactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setSaveAsActivity(false);
    
                emails.add(email);
            }
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);

        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                System.debug('Email ' + (i + 1) + ' sent successfully.');
            } else {
                System.debug('Failed to send email ' + (i + 1) + ': ' + results[i].getErrors()[0].getMessage());
            }
        }
    }
    
    /**
    * Prepare Access Types for Contact record 
    * @param  accessTypes  Access Types
    * @return none     
    * @author Vinit [10 Nov 2021] [IBM] Ticket DPM-177
    */
    public static String prepareAccessTypes(String accessTypes){
    
        String response = '';
        Integer count = 1;
        Map<String,String> mapOfAT = new Map<String,String>();
        List<String> listAT = new List<String>();
        
        for (String key: accessTypes.split(',')) {
            System.debug('key '+key);
            System.debug('key .. '+key.split('/')[0]);
            listAT.add(key.split('/')[0]);
        }
        System.debug('listAT '+listAT);
        List<AccessType__mdt> mapAT = AccessType__mdt.getAll().values();
        for(AccessType__mdt acType : mapAT){
        
            if (listAT != NULL && listAT.size() > 0 && listAT.contains(acType.DeveloperName)) {
                if (!mapOfAT.containsKey(acType.DeveloperName)) {
                    mapofAT.put(acType.DeveloperName, acType.AccessDescription__c);
                }
            }
            System.debug('mapofAT '+mapofAT);
        }
        
        for (String str : accessTypes.split(',')) {
            response += '<p>'+count+') '+ str+'  - '+ (mapofAT.containsKey(str.split('/')[0]) ? mapofAT.get(str.split('/')[0]) : '') +'</p>';
            count++;
        }
        return response;
    }

     /**
     * Update Public Group for DPM-4702
     * When user access type contains 'DPM', add 'DPM ALL USERS' public group.
     */
    
    public static void updatePublicGroup(List<User> newUsersList) {
        List<Id> listOfDPMUser = new List<Id>();
        List<Id> listOfUser = new List<Id>();
        for (User usr : newUsersList) {
            if(usr.AccessTypes__c != null && usr.AccessTypes__c.contains('DPM')){
                listOfDPMUser.add(usr.Id);
            }else{
                listOfUser.add(usr.Id);
            }
        }
        if (listOfDPMUser.size() >0 && !System.isfuture() && !System.isBatch()) {
            updatePublicGroups(listOfDPMUser);
        }
        if (listOfUser.size() >0 && !System.isfuture() && !System.isBatch()) {
            removePublicGroup(listOfUser);
        }
    }
    
    @future
    public static void updatePublicGroups(List <Id> listUserId){
        Boolean isGroupMember = false;
        List<GroupMember> groupMemberToInsertList = new List<GroupMember>();
        
        if (listUserId != NULL && listUserId.size() > 0) {
            for(GroupMember groupmember : [select Id from GroupMember where UserOrGroupId IN :listUserId and Group.DeveloperName = 'DPM_ALL_DPM_USERS'] ){
                isGroupMember = true;
            }
            if(!isGroupMember){
                Group publicGroup = [select Id from Group where DeveloperName = 'DPM_ALL_DPM_USERS'];
                for(String usrId : listUserId){
                    groupMemberToInsertList.add(new GroupMember(UserOrGroupId = usrId, GroupId = publicGroup.Id));
                }
            }
        }
        if(!groupMemberToInsertList.isEmpty()){
            insert groupMemberToInsertList;
        }
    }
    
    @future
    public static void removePublicGroup(List <Id> listUserId){
        List<GroupMember> groupMemberToDeleteList = new List<GroupMember>();
        
        if (listUserId != NULL && listUserId.size() > 0){
            for(GroupMember groupmember : [select Id from GroupMember where UserOrGroupId IN :listUserId and Group.DeveloperName = 'DPM_ALL_DPM_USERS'] ){
                groupMemberToDeleteList.add(groupmember);
            }
        }
        if(!groupMemberToDeleteList.isEmpty()){
            delete groupMemberToDeleteList;
        }
    }
    
    /**
    * Update User Application Type 
    * @param  newUsersList  list of new User
    * @param  oldUsersMap map of old User
    * @return none     
    * @author Vinit [27 May 2022] [IBM] Ticket DPM-177
    */
    public static void updateUserAppType(List<User> newUsersList, Map<Id,User> oldUsersMap) {
    
        List<Id> listOfUser = new List<Id>();
        for (User usr : newUsersList) {
        
            if(usr.IsActive){
                    
                if (oldUsersMap == NULL && (usr.UserRoleId != NULL || usr.AccessTypes__c != NULL)){
                    listOfUser.add(usr.Id);
            
                } else if (oldUsersMap != NULL && usr.AccessTypes__c != oldUsersMap.get(usr.Id).AccessTypes__c){
                    listOfUser.add(usr.Id);
                }
                if (listOfUser.size() >0 && !System.isfuture() && !System.isBatch()) {
                    updateChanges(listOfUser);
                }
            }
        
        }
    }
    
    /**
     * Update User Application Type changes
     * @param  listUserId  list of User
     * @return none     
     * @author Vinit [27 May 2022] [IBM] Ticket DPM-177
     * Edited by Areum on 01-13-2025 for DPM-6005 - Check for DNAMS access in temporary dealer accounts and Skip
     */
    @future
    public static void updateChanges(List < Id > listUserId) {
    System.debug('updateChanges started');

        List < User > listUserToUpdate = new List < User > ();
    
        if (listUserId != NULL && listUserId.size() > 0) {

            //DPM-6005 Check the temp account - If a contact has DNAMS access in a temporary dealer account, maintain that access
            Map<Id, Boolean> contactDNAMSMap = new Map<Id, Boolean>();
            for(AccountContactRelation acr : [SELECT ContactId, DNAMSAccountUser__c, Account.Name, Account.Temporary_Dealer__c
                                            FROM AccountContactRelation 
                                            WHERE ContactId IN (SELECT ContactId FROM User WHERE Id IN :listUserId)
                                            AND IsActive = true]) {
                if(acr.Account.Temporary_Dealer__c && acr.DNAMSAccountUser__c) {
                    contactDNAMSMap.put(acr.ContactId, true);
                }
            }

            for (User usr: [SELECT Id, AccessTypes__c, UserRoleId, UserRole.Name, Safety_User__c, DPM_User__c, DNAMS_Internal_User__c, DNAMS_User__c, DNAMS_User_Flag__c, ProfileId, Profile.Name, ContactId 
                              FROM User
                             WHERE Id IN: listUserId]) {
                                    
                usr.Safety_User__c = FALSE;
                usr.DPM_User__c = FALSE;
                usr.CUV_User__c = false;
                usr.DNAMS_Internal_User__c = false; //Added by Areum on 11-01-2024 for DNAMS PIR
                usr.DNAMS_User_Flag__c = false; //Added by Areum on 11-01-2024 for DNAMS PIR

                //DPM-6005 Update DNAMS_User_Flag__c = true
                if(usr.ContactId != null && contactDNAMSMap.containsKey(usr.ContactId)) {
                    usr.DNAMS_User_Flag__c = true;
                } 
                
                if (usr.AccessTypes__c != NULL) {
                    List < String > listOfAT = (usr.AccessTypes__c).split(',');
    
                    if (listOfAT != NULL && listOfAT.size() > 0) {
    
                        for (String at: listOfAT) {
                            if ((at.toUpperCase()).contains('SCS') || (at.toUpperCase()).contains('SAFETY')) {
                                usr.Safety_User__c = TRUE;
                            }
                            if ((at.toUpperCase()).contains('DPM')) {
                                usr.DPM_User__c = TRUE;
                            }
                            // CUV Program Changes - Start
                            if (at.containsIgnoreCase('CUV')) {
                                usr.CUV_User__c = true;
                            }
                            // CUV Program Changes - End
                            if (at.containsIgnoreCase('DNA')) { //Added by Areum on 11-01-2024 for DNAMS PIR
                               
                                if(at.containsIgnoreCase('DNA_HyundaiExt') || at.containsIgnoreCase('DNA_GenesisExt')) {
                                    usr.DNAMS_User_Flag__c = true;
                                } else {
                                    usr.DNAMS_Internal_User__c = true; 
                                    usr.DNAMS_User_Flag__c = true;
                                }
                            }
                        }

                    }
                }

                if (usr.UserRoleId != NULL) {
    
                    if (usr.UserRole.Name != NULL && (((usr.UserRole.Name).toUpperCase()).contains('SCS') || ((usr.UserRole.Name).toUpperCase()).contains('SAFETY'))) {
                        usr.Safety_User__c = TRUE;    
                    }
    
                    //Dhiraj Changes DPM_User__c
                    //if (usr.UserRole.Name != NULL && (((usr.UserRole.Name).toUpperCase()).contains('DPM') || !((usr.UserRole.Name).toUpperCase()).contains('SAFETY'))) {
                    if (usr.UserRole.Name != NULL && ((usr.UserRole.Name).toUpperCase()).contains('DPM')) {
                        usr.DPM_User__c = TRUE;
                        
                    }
                }
    
                if (usr.Profile.Name != NULL && (((usr.Profile.Name).toUpperCase()).contains('SCS') || ((usr.Profile.Name).toUpperCase()).contains('SAFETY'))) {
                    usr.Safety_User__c = TRUE;
                }
                            
                //Dhiraj Changes for DPM_User__c
                //if (usr.Profile.Name != NULL && (((usr.Profile.Name).toUpperCase()).contains('DPM') || !((usr.Profile.Name).toUpperCase()).contains('SAFETY'))) {
                /*if ((usr.Profile.Name != NULL && ((usr.Profile.Name).toUpperCase()).contains('DPM')) || usr.DNAMS_User__c==False) {
                    usr.DPM_User__c = TRUE;
                }*/
    
                listUserToUpdate.add(usr);
        
                if (listUserToUpdate.size() > 0) {
                    update listUserToUpdate;
                }

            }
    
        }
    }
    
        /**
    * Update Account Contact relationship
    * @param  newUsersList  list of new User
    * @param  oldUsersMap map of old User
    * @return none     
    * @author Swikriti [6 June 2022] [IBM] Ticket DPM- 4142
    * Edited by MinheeKim on 01-13-2025 for DPM-6016 - Remove the condition 'DNAMSAccountUser__c=false' because the DNAMS ACR is controlled by accesstype
    */
    
    @future
    public static void updateAccConChanges(List<Id> listUserId) {
         Map<Id,Set<String>> mapOfContToAT = new Map<Id,Set<String>>();
        if (listUserId != NULL && listUserId.size() > 0) {         
            for (User usr: [SELECT Id, AccessTypes__c, ContactId 
                            FROM User 
                            WHERE Id 
                            IN: listUserId
                            AND IsPortalEnabled = TRUE]) {            
              
                if (usr.AccessTypes__c != NULL) {
    
                    List <String> listOfAT = (usr.AccessTypes__c).split(',');
                    system.debug('listOfAT '+listOfAT);
    
                    if (listOfAT != NULL && listOfAT.size() > 0) {
                        Set<String> setOfAT = new Set<String>();
                        for (String at: listOfAT) {
                        if(at.contains('/')){
                            setOfAT.add(at.split( '/' ).get(1));
                            } 
                            }
                            mapOfContToAT.put(usr.ContactId,setOfAT);
                            system.debug('setOfAT '+setOfAT);
                        }
                    }
                    // else{ //Added temporarily DPM-5613
                    //     mapOfContToAT.put(usr.ContactId,null);
                    // }
                }
                           
                    List<Id> listACRToDlt = new List<Id>();
                    for(AccountContactRelation AccCon : [SELECT Id, Account.Name,AccountId, IsDirect, Account.DealerCode__c, ContactId, DNAMSAccountUser__c, Account.Temporary_Dealer__c 
                                                        FROM AccountContactRelation 
                                                        WHERE ContactId 
                                                        IN: mapOfContToAT.keySet()
                                                        AND IsDirect = FALSE]) {//AND DNAMSAccountUser__c = FALSE //DPM-6016
                          
                        // DPM-6005: Skip temp dealer accounts with DNAMS access
                        if(AccCon.DNAMSAccountUser__c && AccCon.Account.Temporary_Dealer__c) {
                            continue;
                        }
    
                        if (
                            // mapOfContToAT.get(AccCon.ContactId)==null || //Added temporarily DPM-5613
                        (mapOfContToAT.containsKey(AccCon.ContactId) 
                        && !mapOfContToAT.get(AccCon.ContactId).contains(AccCon.Account.DealerCode__c)
                        && !listACRToDlt.contains(AccCon.Id)))  {
                            
                            listACRToDlt.add(AccCon.Id);
                        }             
                                           
                    }
    
                    System.debug('listACRToDlt '+listACRToDlt);
                    List<AccountContactRelation> aCRToDlt = [SELECT Id, AccountId,Account.Name, ContactId, Roles, IsDirect, IsActive, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, JobCode__c, Contact_Name__c, DNAMSUser__c, DNAMS_Role__c, DPM_User_Active__c, DNAMSAccountUser__c, Active_CUV_User__c  FROM AccountContactRelation WHERE Id=:listACRToDlt]; 
    
                    if (aCRToDlt.size() > 0) {
                        database.delete(aCRToDlt,false);
                    }
                    
        } 
    }
        
    /**
     * Update User DNAMS User changes
     * @param  listUserId  list of User
     * @return none     
     * @author Rajendra [20 Dec 2022] 
     */
    public static void updateDNAMSUserCheck(Map<Id, User> mapUsers) {
        
        Map<Id, Id> mapUserContactIds = new Map<Id, Id>();
        Set<Id> setDNAMSDealerUserIds = new Set<Id>();

        for(User u : mapUsers.values()) {
            if(u.ContactId != null) {
                mapUserContactIds.put(u.Id, u.ContactId);
            }
        }
        System.debug(mapUserContactIds);

        if(!mapUserContactIds.isEmpty()) {
            Map<Id, Contact> mapPartnerContacts = new Map<Id, Contact>([SELECT Id, DNAMS_Active_User__c
                                                                        FROM Contact
                                                                        WHERE Id IN :mapUserContactIds.values()
                                                                            AND DNAMS_Active_User__c = true
                                                                        LIMIT 1000]);

            if(!mapPartnerContacts.isEmpty()) {
                for(Id userId : mapUserContactIds.keySet()) {
                    if(mapPartnerContacts.get(mapUserContactIds.get(userId)) != null) {
                        setDNAMSDealerUserIds.add(userId);
                    }
                }
            }
        }

        if(!setDNAMSDealerUserIds.isEmpty()) {
            System.enqueueJob(new DNAMSUserProvisioningServiceQueueable(setDNAMSDealerUserIds));
        }
    }


    /**
     * [Method Description] 
     * Prevent isActive from being false when DNAMS_Internal_User__c is true.
     * Created by [Jonghoon Kim] on [24-08-27] for [Ticket DPM-5754]
     * Edited by [Author] on [Date] for [Ticket #]
    */
    public static void DNAMsIUActive(Map<Id, User> oldMap, Map<Id, User> newMap) {  
        try {
            for (Id userId : newMap.keySet()) {
                User newUser = newMap.get(userId);
                User oldUser = oldMap.get(userId);
                
                if (newUser.DNAMS_Internal_User__c == true) {
                    if (newUser.IsActive == false) {
                        newUser.IsActive = true;
                    }
                }
            }
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getLineNumber() + e.getMessage() );
            throw new AuraHandledException('User Trigger DNAMsIUActive: ' + e.getMessage());
        }
        
    }

        
    /**
    *! WARNING: ONLY USE IT BEFORE TRIGGERS
    *? @description: If newUser record is deacivating(IsActive == false), return true
    * @author LJ: liamjeong@haeaus.com | 2023-08-09 
    * @param User oldUser 
    * @param User newUser 
    * @return Boolean 
    **/
    private static Boolean isDeactivating(User oldUser, User newUser) {

        return true == oldUser.IsActive && false == newUser.IsActive;

    }
    
    /**
    *! WARNING: ONLY USE IT BEFORE TRIGGERS 
    *? @description: Detach Role assigned to the User records in newUserById.
    * @author LJ: liamjeong@haeaus.com | 2023-08-09 
    * @param Map<Id User> oldUserById 
    * @param Map<Id User> newUserById 
    **/
    public static void detachRole(Map<Id, User> oldUserById, Map<Id, User> newUserById) {
    
        for (User newUser : newUserById.values()) {
            
            if (isDeactivating(oldUserById.get(newUser.Id), newUser)) {
             
                newUser.UserRoleId = null;
                
            }            

        }

    }

    /**
    *! WARNING: ONLY USE IT BEFORE TRIGGERS
    *? @description: Blank AccessTypes__c and input true to Autoprovision__c for the User records in newUserById for Permission Auto-Provisiontiong.
    * @author LJ: liamjeong@haeaus.com | 2023-08-09 
    * @param Map<Id User> oldUserById 
    * @param Map<Id User> newUserById 
    **/
    public static void blankAccessType(Map<Id, User> oldUserById, Map<Id, User> newUserById) {
        
        for (User newUser : newUserById.values()) {

            if (isDeactivating(oldUserById.get(newUser.Id), newUser)) {

                newUser.AccessTypes__c = '';
                newUser.Autoprovision__c = true;

                // DNAMS PIR - initialize user flags
                newUser.Safety_User__c = FALSE;
                newUser.DPM_User__c = FALSE;
                newUser.CUV_User__c = false;
                newUser.DNAMS_Internal_User__c = false;
                newUser.DNAMS_User_Flag__c = false;

                newUser.RegionCodes__c= null;
                newUser.DistrictCodes__c= null;
            }

        }

    }

    /**
    *! WARNING: ONLY USE IT BEFORE TRIGGERS
    *? @description: Blank FederationIdentifier.
    *? @modified: DPM-5009 not in condition when the user is internal./ MH: minheekim@autoeveramerica.com | 2023-09-26
    * @author JK: jakyungku@haeaus.com | 2023-08-25
    * @param Map<Id User> oldUserById
    * @param Map<Id User> newUserById
    **/
    public static void blankFederationIdentifier(Map<Id, User> oldUserById, Map<Id, User> newUserById) {
        System.debug('blank federation started');
        for (User newUser : newUserById.values()) {
            System.debug('blank federation for loop started');
            System.debug('isDeactivating: '+isDeactivating(oldUserById.get(newUser.Id), newUser));
             //* MH : DPM-5009: 4994 Roll back for Internal User
            if (isDeactivating(oldUserById.get(newUser.Id), newUser) && hasContact(oldUserById.get(newUser.Id)) && isChangedByIntegrationUser()) {
                System.debug('blank federation for if logic started');
                newUser.FederationIdentifier = '';
            }

        }

    }

    /**
    *! WARNING: ONLY USE IT BEFORE TRIGGERS
    *? @description: Disable portal when user is inactivated.
    *? @modified: DPM-5009 not in condition when the user is internal./ MH: minheekim@autoeveramerica.com | 2023-09-26
    * @author SY: soyeonkim@haeaus.com | 2023-08-29
    * @param Map<Id User> oldUserById
    * @param Map<Id User> newUserById
    **/
    public static void disablePortal(Map<Id, User> oldUserById, Map<Id, User> newUserById){
        for (User newUser :  newUserById.values()){
            //* MH : DPM-5009: 4994 Roll back for Internal User
            if(!newUser.isActive && newUser.isPortalEnabled && hasContact(oldUserById.get(newUser.Id)) && isChangedByIntegrationUser()){
                newUser.isPortalEnabled = false;
                System.debug('disablePortal : '+newUser.Name);
            }
        }
    }

    /**
    *! WARNING: ONLY USE IT AFTER TRIGGERS
    *? @description: Delete contact when user is inactivated.
    * @author SY: soyeonkim@haeaus.com | 2023-08-29
    * @param List<User> newUsersList
    **/
    public static void isInactivating(List<User> newUsersList){
        List<Id> listContactToDelete = new List<Id>();

        for(User newUser : newUsersList){
            if(!newUser.IsActive && newUser.ContactId != null && !newUser.isPortalEnabled){
                listContactToDelete.add((Id)newUser.ContactId);
            }
        }

        /* DPM-5192 Code for Delete Contact by Queable by MinheeKim - 2023-12-05 */
        // if(listContactToDelete.size() > 0){
        //     deleteContact(listContactToDelete);
        // }
        System.debug('isInactivating: '+listContactToDelete);
        if(listContactToDelete.size() > 0) {
            System.enqueueJob(new UserTriggerQueueable(listContactToDelete));
        }
        /* End of code for DPM-5192*/
    }
    
    /* DPM-5192 Change to comments for Delete Contact by Queable by MinheeKim - 2023-12-05 */
    // @future
    // public static void deleteContact(List<Id> listContactToDelete){
    //     List<Contact> contacts = new List<Contact>();
    //     for(Id contactId : listContactToDelete){
    //         contacts.add(new Contact(Id=contactId));
    //     }
    //     delete contacts;
	// }


    private static Boolean hasContact(User oldUser) {

        System.debug('blank hasContact: '+oldUser.ContactId!=null);
        return oldUser.ContactId!=null;
    }

     /**
    *! WARNING: ONLY USE IT BEFORE TRIGGERS
    *? @description: Check whether the WebDCS send the user info. DPM-5128
    * @author MH: minheekim@haeaus.com | 2023-11-09
    **/
    private static Boolean isChangedByIntegrationUser() {
        System.debug('blank isChangedByIntegrationUser: '+UserInfo.getName());
        return UserInfo.getName()=='Integration User';
    }


    /**
    * @Description CCSOM-25, exclude from provisioning process if a user has roleName = 'System_Admin'
    * @created : [InhoKim] on [24.02.27] for [CCSOM-25]
    * @Updated : [InhoKim] on [24.10.09] for [CCSOM-67] Commented out CCSOM-25
    * @author: inhokim@haeaus.com | 2024-02-27
    **/
    // private static Boolean isSystemAdminRoleUser(User userRecord) {
    //     String roleDevName = userRecord.UserRole.DeveloperName ?? '';
    //     System.debug('  User detail : '+ userRecord );
    //     System.debug('  isSystemAdminRoleUser: '+ roleDevName );        
    //     return roleDevName.equalsIgnoreCase('SYSTEM_ADMIN');
    // }

}