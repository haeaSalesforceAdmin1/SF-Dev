public without sharing class ContactTriggerHelper {


    public static final String ACTIVE = 'Active';
    public static final String INACTIVE = 'Inactive';
    public static final String GeneralManager = 'GM'; //DPM-5400 added by Minhee Kim - 24.04.26
    public static final String DealerPrincipal = 'DP'; //DPM-5620 added by Minhee Kim - 02.12.2025
    public static final String DealerAdminSupport = 'DA'; //DPM-5620 added by Minhee Kim - 02.12.2025
    public static final String OfficeManager = 'OM'; //DPM-5620 added by Minhee Kim - 02.12.2025

    /**DPM-5620 add to get current ACR */
    private static List<AccountContactRelation> cachedACRs = new List<AccountContactRelation>();
    private static Boolean nonACR = false;

    /**
    * [Method Description]  get AccountContactRelation
    * Created by [MinheeKim] on [01-31-2025] for [DPM-5620]
    */
    public static List<AccountContactRelation> getACRs(Contact newCon) {
        if (cachedACRs.size()==0 && !nonACR) {
            cachedACRs = [SELECT AccountId, Account.Name, Roles, DNAMS_Role__c, JobCode__c, IsActive, Account.DealerCode__c, Account.Temporary_Dealer__c, DPMAccountUser__c, DNAMSUser__c, DPM_User_Active__c, DNAMSAccountUser__c, Active_CUV_User__c FROM AccountContactRelation WHERE ContactId=:newCon.Id];
            if(cachedACRs.size()==0) nonACR = true;
        }
        return cachedACRs;
    }/**DPM-5620 end*/

    public static void handleExternalSharingForContacts(List<Contact> contacts) {
//      DPM-4548
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact contact:contacts) {
            contactMap.put(contact.Id, contact);
        }

        ContactService.createContactDealerSharing(contactMap);
        /* DPM-4548
        Set<Id> contactIds = new Set<Id>();
        for(Contact contact:contacts) {
            contactIds.add(contact.Id);
        }

        if(!contactIds.isEmpty()) {
            BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
            objectShares.type = 'Contact';
            objectShares.updateAllObjectsSharing = false;
            objectShares.objectIds = contactIds;
            Database.executeBatch(objectShares, 1);
        }*/
    }
    
    /**
     * @description:    When DNAMS_Active_User__c flag on the Contact gets updated, find the associated partner user
     *                  and invoke DNAMSUserProvisioningServiceQueueable to assign necessary permission sets/public groups
     * @params:         newMap - Trigger.newMap, oldMap - Trigger.oldMap
     * Edited by [Minhee Kim] on [02-10-2025] for [DPM-6020] Changed to comment not to run DNAMSUserProvisioningServiceQueueable
     */
    /**public static void updateDNAMSActiveUser( Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        
        Map<Id, Boolean> mapContactDNAActiveUserFlag = new Map<Id, Boolean>();
        Map<Id, Boolean> mapUserDNAMSFlag = new Map<Id, Boolean>();
        
        for(Id cId : newMap.keySet()) {
            //Check if DNAMS_Active_User__c flag got updated on the Contact.
            if(newMap.get(cId).DNAMS_Active_User__c != oldMap.get(cId).DNAMS_Active_User__c) {
                mapContactDNAActiveUserFlag.put(cId, newMap.get(cId).DNAMS_Active_User__c);
            }
        }

        if(!mapContactDNAActiveUserFlag.isEmpty()) {
            for(User u : [SELECT Id, ContactId FROM User WHERE ContactId IN :mapContactDNAActiveUserFlag.keySet() AND IsActive = TRUE LIMIT 1000]) {
                mapUserDNAMSFlag.put(u.Id, mapContactDNAActiveUserFlag.get(u.ContactId));
            }
    
            if(!mapUserDNAMSFlag.isEmpty()) {
                System.enqueueJob(new DNAMSUserProvisioningServiceQueueable(mapUserDNAMSFlag));
            }
        }
    }*/



    /**
     * @description:    
     * @params:         newMap - Trigger.newMap, oldMap - Trigger.oldMap
     * Edited by  [MinheeKim] on [01-30-2025] for [DPM-5620] changed the logic to use Map<String,List<AccountContactRelation>> acrMap
     */

    public static void updateAccountId( Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        System.debug(LoggingLevel.ERROR, 'Contact Trigger - updateAccountId started');
        //Compare old accesstype and new accesstype

        
        if(!newMap.isEmpty()){
            for(Id con : newMap.keySet()){
                Contact newCon = newMap.get(con);
                Contact oldCon = oldMap.get(con);
                Map<String,List<AccountContactRelation>> acrMap = compareAccesstype(newCon);
                Set<Id> inactiveAccSet = new Set<Id>();

                /**DPM-5620 start */
                for(AccountContactRelation acr: acrMap.get(INACTIVE)){
                    if(acr.AccountId == newCon.AccountId && acrMap.get(ACTIVE).size()>0){
                        newCon.AccountId = acrMap.get(ACTIVE)[0].AccountId;
                        break;
                    }
                }/**DPM-5620 end */
                // Boolean haveToChangeAccount = [SELECT isActive FROM AccountContactRelation WHERE ContactId=:oldCon.Id AND AccountId=:oldCon.AccountId LIMIT 1].IsActive;
        
                
                // if(accMap.get(INACTIVE).size()>0 || !haveToChangeAccount){
                //     for(Account acr: acrMap.get(INACTIVE)){
                //         inactiveAccSet.add(acr.Id);
                //     }

                //     if((inactiveAccSet.contains(newCon.AccountId) && newCon.Access_Types__c!=null && newCon.Access_Types__c!='') || !haveToChangeAccount){
                //         Integer ACRCount = [SELECT COUNT() FROM AccountContactRelation WHERE ContactId=:newCon.Id AND AccountId!=:newCon.AccountId AND isActive=true];
                //         if(ACRCount>0){
                //             Id replaceAcc = [SELECT AccountId FROM AccountContactRelation WHERE ContactId=:newCon.Id AND isActive=true LIMIT 1].AccountId;
                //             if(replaceAcc!=null){
                //                 newCon.AccountId=replaceAcc;
                //             }
                //             System.debug(LoggingLevel.ERROR, 'new Account: '+newCon.AccountId);
                //         }else if(accMap.get(ACTIVE).size()>0){
                //             newCon.AccountId = accMap.get(ACTIVE)[0].Id;
                //         }
                        
                //     }
                    
                // }
            }
        }
     
    }

    /**
     * [Method Description] Split contact's access type
     * Created by [MinheeKim] on [2023-12-12] for [DPM-4454]
     * Edited by [MinheeKim] on [01-30-2025] for [DPM-5620] changed the return value from List<String> to Set<String>
    */
    public static Map<String,Set<String>> contactAccessType(Contact con) {
        System.debug('====== contactAccessType Start ======');
        System.debug('Original Access_Types__c: ' + con.Access_Types__c);
    
        List<String> accesstypes = con.Access_Types__c.split('</p>');
        System.debug('After </p> split: ' + accesstypes);
        System.debug(accesstypes);
        Map<String,Set<String>> accesstypeMap = new Map<String,Set<String>>();

        if(accesstypes.size()>0){
            for(String accesstype: accesstypes){
                String splitAccesstype='';
                splitAccesstype = accesstype.split(' ')[1];
                /**DPM-5620 start: trim the apptype*/
                String appType = splitAccesstype.split('/')[0];
                if(appType.contains('DPM')){
                    appType = 'DPM';
                }else if(appType.contains('CUV')){
                    appType = 'CUV';
                }else if(appType.contains('DNA')){
                    appType = 'DNA';
                }
                /**DPM-5620 end */
                if(splitAccesstype.contains('/') && accesstypeMap.containsKey(splitAccesstype.split('/')[1])){
                    System.debug('Existing dealer code found: ' + splitAccesstype.split('/')[1]);
                    Set<String> preAccesstypes = accesstypeMap.get(splitAccesstype.split('/')[1]);
                    Set<String> accesstypePerAccount = preAccesstypes;
                    
                    accesstypePerAccount.add(appType);
                    accesstypeMap.put(splitAccesstype.split('/')[1], accesstypePerAccount);   
                }else if(splitAccesstype.contains('/')){
                    System.debug('New dealer code found: ' + splitAccesstype.split('/')[1]);
                    Set<String> accesstypePerAccount = new Set<String>();
                    accesstypePerAccount.add(appType);
                    accesstypeMap.put(splitAccesstype.split('/')[1], accesstypePerAccount);  
                }

            }
        }

        System.debug('Final accesstypeMap: ' + accesstypeMap);
        System.debug('====== contactAccessType End ======');
        return accesstypeMap;

    }

    /**
     * [Method Description] Check whether there is any deleted access type.
     * Created by [MinheeKim] on [2023-12-12] for [DPM-4454]
     * Edited by [MinheeKim] on [2024-07-10] for [DPM-5613] add logic to check the app type for each accesstype
     * Edited by [MinheeKim] on [01-30-2025] for [DPM-5620] change the logic to compare with existing ACR and new accesstype
     * Edited by [MinheeKim] on [02-12-2025] for [DPM-6083] add logic to update DNAMS Role
    */
    public static Map<String,List<AccountContactRelation>> compareAccesstype(Contact newCon){//DPM-5620 changed the paramaneter from newCon, oldCon to newCon
        Map<String,Set<String>> newAccesstype = new Map<String,Set<String>>();
        // Map<String,List<String>> oldAccesstype = new Map<String,List<String>>();//DPM-5620 changed to comment
        Map<String,List<AccountContactRelation>> acrMap = new Map<String,List<AccountContactRelation>>();

        if(newCon.Access_Types__c!='' && newCon.Access_Types__c!=null) newAccesstype = contactAccessType(newCon);
        //if(oldCon.Access_Types__c!='' && oldCon.Access_Types__c!=null) oldAccesstype = contactAccessType(oldCon); //DPM-5620 changed to comment
        List<AccountContactRelation> ACRList = getACRs(newCon); //DPM-5620 added to get existingACRs

        System.debug('newAccesstype: '+newAccesstype);
        Map<String,Set<String>> inactiveACR = new Map<String,Set<String>>(); //Map of dealer code and app
        Map<String,Set<String>> activeACR = new Map<String,Set<String>>();
        Set<String> existingAcc = new Set<String>();
        //List<Account> inactiveAcc = new List<Account>();
        //List<Account> activeAcc = new List<Account>();
        List<AccountContactRelation> acrToUpsert = new List<AccountContactRelation>();
        List<AccountContactRelation> acrToDelete = new List<AccountContactRelation>();
        List<AccountContactRelation> existingACRs = new List<AccountContactRelation>(); //DPM-5620 Add to use in updateDNAMSRole method
        Boolean runUpdateDNAMSRole = false;
        Boolean hasTempAccount = false;

        /**DPM-5620 start: added to compare the ACRs with accesstype */
        if(ACRList.size()>0){
            for(AccountContactRelation acr : ACRList){
                if(newCon.Access_Types__c!='' && newCon.Access_Types__c!=null && newAccesstype.containsKey(acr.Account.DealerCode__c)){
                    //If the dealer code of existing ACR is in new Accesstype, remain the ACR and check the flags
                    if(newAccesstype.get(acr.Account.DealerCode__c).contains('DPM')){
                        acr.DPMAccountUser__c = true;
                    }else if(!(newAccesstype.get(acr.Account.DealerCode__c).contains('DPM'))){
                        acr.DPMAccountUser__c = false;
                    }
                        
                    if(newAccesstype.get(acr.Account.DealerCode__c).contains('DNA')){
                        acr.DNAMSAccountUser__c = true;
                    }else if(!(newAccesstype.get(acr.Account.DealerCode__c).contains('DNA'))){
                        acr.DNAMSAccountUser__c = false;
                    }

                    if(!acr.IsActive){
                        acr.IsActive = true;
                    }
                    acrToUpsert.add(acr);
                        
                }else if(acr.Account.Temporary_Dealer__c){
                    acrToUpsert.add(acr);
                    hasTempAccount = true;
                }else if(!acr.Account.Temporary_Dealer__c){
                    //If the dealer code of existing ACR isn't in new Accesstype and the account of ACR is not temporary dealer, put the acr in list to inactive
                    acr.IsActive = false;
                    acr.DNAMSAccountUser__c = false;
                    acr.DPMAccountUser__c = false;
                    acrToDelete.add(acr); 
                }
                existingAcc.add(acr.Account.DealerCode__c);

                if(acr.DNAMSAccountUser__c) {
                    runUpdateDNAMSRole = true;
                }
                existingACRs.add(acr); //DPM-6083 Add to use in updateDNAMSRole method
            }
        }
        //If there's no existing ACR and new access type isn't blank, create new ACR
        if(newAccesstype.size()>0) {
            Map<Account,Set<String>> accountAppMap =getAccountApptypeMap(newAccesstype);
            for(Account acc : accountAppMap.keySet()){ 
                if(!existingAcc.contains(acc.DealerCode__c)){
                    AccountContactRelation newACR = new AccountContactRelation(AccountId = acc.Id, ContactId = newCon.Id, IsActive = true);
                    Set<String> appType = accountAppMap.get(acc);
                    if(appType.contains('DPM')){
                        newACR.DPMAccountUser__c = true;
                    }else{
                        newACR.DPMAccountUser__c = false;
                    }

                    if(appType.contains('DNA')){ //Added by Areum on 11-01-2024 for DNAMS PIR
                        newACR.DNAMSAccountUser__c = true;
                        runUpdateDNAMSRole = true;
                    }else{
                        newACR.DNAMSAccountUser__c = false;
                    }
                    acrToUpsert.add(newACR);
                    
                    if(newACR.DNAMSAccountUser__c){
                        runUpdateDNAMSRole = true;
                    } 
                    existingACRs.add(newACR); //DPM-6083 Add to use in updateDNAMSRole method
                }
            }
        }
            
        if(existingACRs.size()>0 && runUpdateDNAMSRole && !hasTempAccount){
            String dnamsRole = updateDNAMSRole(existingACRs);
            if(dnamsRole!=null) newCon.DNAMS_Role__c = dnamsRole;
        }
        
        /**DPM-5620 end: added to compare the ACRs with accesstype */
        /** DPM-5620 Changed to comments
        if(!oldAccesstype.isEmpty()){
            for(String oldDealerCode: oldAccesstype.keySet()){
                if(newAccesstype.containsKey(oldDealerCode)){
                    continue;
                }else{
                    //Deactive ACR for deleted accesstype
                    Set<String> appType = new Set<String>();
                    for(String accesstype : oldAccesstype.get(oldDealerCode)){
                        if(accesstype.contains('DPM')){
                            appType.add('DPM');
                        }
                        if(accesstype.contains('CUV')){
                            appType.add('CUV');
                        } 
                        if (accesstype.contains('DNA')){ //Added by Areum on 11-01-2024 for DNAMS PIR
                            appType.add('DNA');
                        }
                    }
                    inactiveACR.put(oldDealerCode, appType);
                    System.debug('Added to inactiveACR: '+oldDealerCode);
                }
            }
        }
        if(!newAccesstype.isEmpty()){
            for(String newDealerCode: newAccesstype.keySet()){
                
                if(inactiveACR.containsKey(newDealerCode)){
                    continue;
                }else{
                    //Deactive ACR for deleted accesstype
                    Set<String> appType = new Set<String>();
                    for(String accesstype : newAccesstype.get(newDealerCode)){
                        if(accesstype.contains('DPM')){
                            appType.add('DPM');
                        }
                        
                        if(accesstype.contains('CUV')){
                            appType.add('CUV');
                        }
                        
                        if (accesstype.contains('DNA')){ //Added by Areum on 11-01-2024 for DNAMS PIR
                            appType.add('DNA');
                        }
                    }
                    activeACR.put(newDealerCode, appType);
                }
            }
        } */

        //activeAcc=activeAccountContactRelation(newCon, activeACR);
        //inactiveAcc=inactiveAccountContactRelation(oldCon, inactiveACR);

        Database.UpsertResult[] results = new List<Database.UpsertResult>();
        List<Async_Apex_Error__c> errorLogs = new List<Async_Apex_Error__c>();
        if(!existingACRs.isEmpty()) {
            try {
                Boolean hasError = false;
                
                System.debug('### Before update - ACRs to update: ');
                for(AccountContactRelation acrToUpdate : existingACRs) {
                    System.debug('### Account: ' + acrToUpdate.Account.Name + 
                                ', DNAMSAccountUser__c: ' + acrToUpdate.DNAMSAccountUser__c);
                }
                AccountContactRelationTriggerHandler.isRunning = false;
                results = Database.upsert(existingACRs, false);

                System.debug(LoggingLevel.ERROR, 'results.size(): ' + results.size());
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        Database.Error error = results[i].getErrors()[0];
                        AccountContactRelation failedAcr = existingACRs[i];
        
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
                AccountContactRelationTriggerHandler.isRunning = true;
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
    
        
        // try {
        //     System.debug('acrToUpsert: '+acrToUpsert);
        //     System.debug('acrToDelete: '+acrToDelete);
        //     if(acrToUpsert.size()>0) upsert acrToUpsert;
        //     if(acrToDelete.size()>0) update acrToDelete; 

            
        // } catch(Exception e) {
        //     System.debug(e.getMessage());
        // }
        acrMap.put(ACTIVE,acrToUpsert);
        acrMap.put(INACTIVE,acrToDelete);
        return acrMap;

    }
    
    public class ACRDMLException extends Exception {}

    /**
     * [Method Description] get Account Apptype map
     * Created by [MinheeKim] on [01-30-2025] for [DPM-5620]
     * */
    public static Map<Account,Set<String>> getAccountApptypeMap(Map<String,Set<String>> newAccesstypeMap){
        List<Account> accList = [SELECT Id, DealerCode__c FROM Account WHERE DealerCode__c IN : newAccesstypeMap.keySet()];
        Map<Account,Set<String>> accountAppMap = new Map<Account,Set<String>>();
        for(Account acc : accList){
            accountAppMap.put(acc,newAccesstypeMap.get(acc.DealerCode__c));
        }

        return accountAppMap;
    }

    /**
     * [Method Description] Deactive ACR for deleted accesstype
     * Created by [MinheeKim] on [2023-12-12] for [DPM-4454]
     * Edited by [MinheeKim] on [2024-03-29] for [DPM-5469] change to prevent inactive DNAMS ACR
     * Edited by [MinheeKim] on [2024-07-10] for [DPM-5613] add logic to turn off DPMAccountUser flag when user loses DPM access for the account
     * Edited by Areum on 11-01-2024 for DNAMS PIR / add DNAMS logic 
     * Edited by [MinheeKim] on [01-31-2025] for [DPM-5620] Change to comments
    */
    /**
    public static List<Account> inactiveAccountContactRelation(Contact oldCon, Map<String,Set<String>> oldDealerCode){
        //search
        List<Account> accList = [SELECT Id FROM Account WHERE DealerCode__c IN :oldDealerCode.keySet()];
        List<AccountContactRelation> acrList = [SELECT IsActive, Account.DealerCode__c, DNAMSUser__c, DPM_User_Active__c, DPMAccountUser__c, DNAMSAccountUser__c, Active_CUV_User__c FROM AccountContactRelation WHERE ContactId=:oldCon.Id AND AccountId IN :accList]; //dPM-5469 added  AND DNAMSAccountUser__c =false by Minhee - 24.03.29
        for(AccountContactRelation acr : acrList){
            
            // if(!acr.DNAMSAccountUser__c) acr.isActive=false;
            acr.isActive=false; // Added by Areum on 11-01-2024 for DNAMS PIR
            
            Set<String> appType = oldDealerCode.get(acr.Account.DealerCode__c);
        
            if(appType.contains('DPM')){
                acr.DPMAccountUser__c = false;
            }
            if(appType.contains('DNA')){ // Added by Areum on 11-01-2024 for DNAMS PIR
                acr.DNAMSAccountUser__c = false;
            }
        }

        try {
            update acrList;
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getLineNumber() + e.getMessage() );
        }

        return accList;
    } */

    /**
     * [Method Description] Active ACR for deleted accesstype
     * Created by [MinheeKim] on [2023-12-13] for [DPM-4454]
     * Edited by [MinheeKim] on [2024-07-10] for [DPM-5613] add logic to turn on DPMAccountUser flag when user gets DPM access for the account
     * Edited by Areum on 11-01-2024 for DNAMS PIR / add DNAMS logic 
     * Edited by [MinheeKim] on [01-31-2025] for [DPM-5620] Change to comments
    */
    /**public static List<Account> activeAccountContactRelation(Contact newCon, Map<String,Set<String>> newDealerCode){

        //search
        List<Account> accList = [SELECT Id , DealerCode__c FROM Account WHERE DealerCode__c IN :newDealerCode.keySet()];
        List<Id> accIds = new List<Id>();
        for(Account acc : accList){
            accIds.add(acc.Id);
        }
        List<AccountContactRelation> acrList = [SELECT AccountId, isActive, Account.DealerCode__c, DNAMSUser__c, DPM_User_Active__c, DNAMSAccountUser__c, Active_CUV_User__c FROM AccountContactRelation WHERE ContactId=:newCon.Id AND AccountId IN :accIds]; 
        Map<Id,AccountContactRelation> accMap = new Map<Id,AccountContactRelation>();

        for(AccountContactRelation acr: acrList){
            accMap.put(acr.AccountId, acr);
        }
        
        for(Account acc : accList){
            
            if(accMap.containsKey(acc.Id)){
                accMap.get(acc.Id).isActive=true;
                Set<String> appType = newDealerCode.get(acc.DealerCode__c);
                if(appType.contains('DPM')){
                    accMap.get(acc.Id).DPMAccountUser__c=true;
                }else{
                    accMap.get(acc.Id).DPMAccountUser__c=false;
                }

                if(appType.contains('DNA')){ //Added by Areum on 11-01-2024 for DNAMS PIR
                    accMap.get(acc.Id).DNAMSAccountUser__c=true;
                }else{
                    accMap.get(acc.Id).DNAMSAccountUser__c=false;
                }
                
            }else{
                AccountContactRelation newACR = new AccountContactRelation(AccountId = acc.Id, ContactId = newCon.Id, isActive = true);
                Set<String> appType = newDealerCode.get(acc.DealerCode__c);
                if(appType.contains('DPM')){
                    newACR.DPMAccountUser__c = true;
                }else{
                    newACR.DPMAccountUser__c = false;
                }

                if(appType.contains('DNA')){ //Added by Areum on 11-01-2024 for DNAMS PIR
                    newACR.DNAMSAccountUser__c = true;
                }else{
                    newACR.DNAMSAccountUser__c = false;
                }
                acrList.add(newACR);
            }
        }

        try {
            upsert acrList;
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getLineNumber() + e.getMessage() );

        }
        return accList;
    }*/

     /**
     * [Method Description] Delete the ACR 
     * Created by [MinheeKim] on [2024-06-28] for [DPM-5613]
    */
    public static void deleteInactiveACR( Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        System.debug(LoggingLevel.ERROR, 'Contact Trigger - updateACR started');

        /*List<AccountContactRelation> acrList = [SELECT AccountId, Account.DealerCode__c, IsActive, IsDirect, DNAMSAccountUser__c FROM AccountContactRelation 
        WHERE ContactId IN :newMap.keySet() AND IsDirect = false AND IsActive=false AND DNAMSAccountUser__c = false];*/ 
        
        List<AccountContactRelation> acrList = [SELECT AccountId, Account.DealerCode__c, IsActive, IsDirect, DNAMSAccountUser__c FROM AccountContactRelation 
        WHERE ContactId IN :newMap.keySet() AND IsDirect = false AND IsActive=false //Added by Areum on 11-01-2024 for DNAMS PIR 
        AND Account.Temporary_Dealer__c =false]; //not delete the ACR of temporary account as DPM-6005 -02.04.2025

        for(AccountContactRelation acr : acrList){
            System.debug('Delete ACR: '+acr.Account.DealerCode__c);
        }
         try {
            delete acrList;
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getLineNumber() + e.getMessage() );

        }
    }

     /**
     * [Method Description] change the primary contact on evaluation when the original primary contact is deleted
     * Created by [MinheeKim] on [2024-04-26] for [DPM-5400]
    */
    public static void changePrimaryContactOnEval(List<Contact> oldCon){
        System.debug('changePrimaryContactOnEval Started' );
        List<Evaluation__c> evalToUpdate = new List<Evaluation__c>();
        List<Action_Plan__c> apToUpdate = new List<Action_Plan__c>();
        List<Id> conIds = new List<Id>();
        for(Contact con : oldCon){
            conIds.add(con.Id);
        }

        if(oldCon.size()>0){
            System.debug('changePrimaryContactOnEval OldCon: '+ oldCon);
            Map<Id, Evaluation__c> evalMap = new Map<Id, Evaluation__c>([
                SELECT Id, PrimaryContact__c , Account__c
                FROM Evaluation__c 
                WHERE PrimaryContact__c IN :conIds 
            ]);
            System.debug('changePrimaryContactOnEval evalMap: '+ evalMap);

            Map<Id, List<Evaluation__c>> evalAccountMap = new Map<Id, List<Evaluation__c>>();
            Map<Id, Action_Plan__c> evalAPMap = new Map<Id, Action_Plan__c>();
            if(evalMap.size()>0){
                
                for(Evaluation__c eval : evalMap.values()){
                    if(!evalAccountMap.containsKey(eval.Account__c)){
                        List<Evaluation__c> evalList = new List<Evaluation__c>();
                        evalList.add(eval);
                        evalAccountMap.put(eval.Account__c, evalList);
                    }else{
                        List<Evaluation__c> preEvalList = evalAccountMap.get(eval.Account__c);
                        preEvalList.add(eval);
                        evalAccountMap.put(eval.Account__c, preEvalList);
                    }
                    
                }
                Map<Id, Action_Plan__c> apMap = new Map<Id, Action_Plan__c>([
                    SELECT Id, Evaluation__c, Original_Partner_User_ID__c
                    FROM Action_Plan__c 
                    WHERE Evaluation__c IN :evalMap.keySet() 
                ]);

                if(apMap.size()>0){
                    for(Action_Plan__c ap : apMap.values()){
                        evalAPMap.put(ap.Evaluation__c, ap);                    
                    }
                }


                Map<Id, AccountContactRelation> AccountContactRelationMap = new Map<Id, AccountContactRelation>([
                    SELECT Id, JobCode__c, AccountId, ContactId
                    FROM AccountContactRelation 
                    WHERE AccountId IN :evalAccountMap.keySet() and IsActive = true
                ]);

                //Map of ContactId, User
                Map<Id, User> userConMap = getUserbyAccountContactRelation(AccountContactRelationMap.values()); 

                if(AccountContactRelationMap.size()>0){
                    Map<Id, List<AccountContactRelation>> Account_GM_ACRMap = new Map<Id, List<AccountContactRelation>>();

                    for(AccountContactRelation acr : AccountContactRelationMap.values()){
                        if(!Account_GM_ACRMap.containsKey(acr.AccountId)){
                            List<AccountContactRelation> acrList = new List<AccountContactRelation>();
                            if(acr.JobCode__c != null && acr.JobCode__c.contains(GeneralManager)){
                                acrList.add(acr);
                                Account_GM_ACRMap.put(acr.AccountId, acrList);
                            }
                        }else{
                            List<AccountContactRelation> preACRList = Account_GM_ACRMap.get(acr.AccountId);
                            if(acr.JobCode__c != null && acr.JobCode__c.contains(GeneralManager)){
                                preACRList.add(acr);
                                Account_GM_ACRMap.put(acr.AccountId, preACRList);
                            }
                        }
                        
                    }

                    for(Id acc : evalAccountMap.keySet()){
                        if(Account_GM_ACRMap.size()>0 && Account_GM_ACRMap.containsKey(acc)){
                            List<Evaluation__c> evalList = evalAccountMap.get(acc);
                            for(Evaluation__c evaluation : evalList){
                                Action_Plan__c apOfEval = apMap.get(evaluation.Id);
                                evaluation.PrimaryContact__c = Account_GM_ACRMap.get(acc)[0].ContactId;
                                if(apOfEval!=null){
                                    apOfEval.Original_Partner_User_ID__c = userConMap.get(Account_GM_ACRMap.get(acc)[0].ContactId).Id;//get user id matching with contact
                                    apToUpdate.add(apOfEval);
                                }
                                evalToUpdate.add(evaluation);
                            }
                        }
                    }
                }

            }

        }

        if(evalToUpdate.size()>0){
            try{
                update evalToUpdate;
            }catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e.getLineNumber() + e.getMessage() );
    
            }

        }

        if(apToUpdate.size()>0){
            try{
                update apToUpdate;
            }catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e.getLineNumber() + e.getMessage() );
    
            }
        }
    }

    /**
     * [Method Description] get User Id by ContactId
     * Created by [MinheeKim] on [2024-04-26] for [DPM-5400]
    */
    public static Map<Id, User> getUserbyAccountContactRelation(List<AccountContactRelation> AccountContactRelationMap){
        List<Id> conList = new List<Id>();
        Map<Id, User> conUserMap = new Map<Id, User>();
        for(AccountContactRelation acr: AccountContactRelationMap){
            conList.add(acr.ContactId);
        }
        if(conList.size()>0){
            Map<Id, User> userMap = new Map<Id, User>([
                SELECT Id, ContactId FROM User WHERE ContactId IN :conList
            ]);
            
            if(userMap.size()>0){
                for(User user : conUserMap.values()){
                    conUserMap.put(user.ContactId, user);
                }
            }
        }

        return conUserMap;
    }

    /**
     * [Method Description] update ACR's DNAMSRole field
     * Created by [MinheeKim] on [02-12-2025] for [DPM-6083]
    */
    public static String updateDNAMSRole(List<AccountContactRelation> existingACRs){

        String finalDNAMSRole = '';
        String finalJobCode = '';
        Map<String, Integer> dnamsRolePriority = new Map<String, Integer>();
        dnamsRolePriority.put(DealerPrincipal, 0);
        dnamsRolePriority.put(GeneralManager, 1);
        dnamsRolePriority.put(DealerAdminSupport, 2);
        dnamsRolePriority.put(OfficeManager, 3);

        Map<String, String> jobcodeToRole = new Map<String, String>();
        jobcodeToRole.put(DealerPrincipal, 'Dealer Principal');
        jobcodeToRole.put(GeneralManager, 'General Manager');
        jobcodeToRole.put(DealerAdminSupport, 'Dealer Admin Support');
        jobcodeToRole.put(OfficeManager, 'Office Manager');

        for(AccountContactRelation acr : existingACRs) {
            if(acr.isActive && acr.DNAMSAccountUser__c){
                if(acr.JobCode__c != null) {
                    Set<String> jobCodes = new Set<String>(acr.JobCode__c.split(';'));
                    for(String jobCode : jobCodes) {
                        if(dnamsRolePriority.containsKey(jobCode)){
                            if(finalJobCode!='' && dnamsRolePriority.containsKey(finalJobCode)){
                                if(dnamsRolePriority.get(finalJobCode) > dnamsRolePriority.get(jobCode)) {
                                    finalJobCode=jobCode;

                                }
                            }else if(finalJobCode==''){finalJobCode=jobCode;}
                        }
                    }
                }
            }
        }

        if(finalJobCode!='') finalDNAMSRole = jobcodeToRole.get(finalJobCode);
        return finalDNAMSRole;
    }


    
}