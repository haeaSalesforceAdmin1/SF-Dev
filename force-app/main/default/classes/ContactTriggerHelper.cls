public without sharing class ContactTriggerHelper {


    public static final String ACTIVE = 'Active';
    public static final String INACTIVE = 'Inactive';
    public static final String GeneralManager = 'GM'; //DPM-5400 added by Minhee Kim - 24.04.26

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
     */
    public static void updateDNAMSActiveUser( Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        
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
    }


    /**
     * @description:    
     * @params:         newMap - Trigger.newMap, oldMap - Trigger.oldMap
     */

    public static void updateAccountId( Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        System.debug(LoggingLevel.ERROR, 'Contact Trigger - updateAccountId started');
        //Compare old accesstype and new accesstype

        
        if(!newMap.isEmpty()){
            for(Id con : newMap.keySet()){
                Contact newCon = newMap.get(con);
                Contact oldCon = oldMap.get(con);
                Map<String,List<Account>> accMap = compareAccesstype(newCon, oldCon);
                Set<Id> inactiveAccSet = new Set<Id>();
                Boolean haveToChangeAccount = [SELECT isActive FROM AccountContactRelation WHERE ContactId=:oldCon.Id AND AccountId=:oldCon.AccountId LIMIT 1].IsActive;
        
                
                if(accMap.get(INACTIVE).size()>0 || !haveToChangeAccount){
                    for(Account acc: accMap.get(INACTIVE)){
                        inactiveAccSet.add(acc.Id);
                    }

                    if((inactiveAccSet.contains(newCon.AccountId) && newCon.Access_Types__c!=null && newCon.Access_Types__c!='') || !haveToChangeAccount){
                        Integer ACRCount = [SELECT COUNT() FROM AccountContactRelation WHERE ContactId=:newCon.Id AND AccountId!=:newCon.AccountId AND isActive=true];
                        if(ACRCount>0){
                            Id replaceAcc = [SELECT AccountId FROM AccountContactRelation WHERE ContactId=:newCon.Id AND isActive=true LIMIT 1].AccountId;
                            if(replaceAcc!=null){
                                newCon.AccountId=replaceAcc;
                            }
                            System.debug(LoggingLevel.ERROR, 'new Account: '+newCon.AccountId);
                        }else if(accMap.get(ACTIVE).size()>0){
                            newCon.AccountId = accMap.get(ACTIVE)[0].Id;
                        }
                        
                    }
                    // else{
                    //     newCon.AccountId=null;
                    // }
                }
            }
        }
     
    }

    /**
     * [Method Description] Split contact's access type
     * Created by [MinheeKim] on [2023-12-12] for [DPM-4454]
    */
    public static Map<String,List<String>> contactAccessType(Contact con) {
        System.debug('====== contactAccessType Start ======');
        System.debug('Original Access_Types__c: ' + con.Access_Types__c);
    
        List<String> accesstypes = con.Access_Types__c.split('</p>');
        System.debug('After </p> split: ' + accesstypes);
        System.debug(accesstypes);
        Map<String,List<String>> accesstypeMap = new Map<String,List<String>>();

        if(accesstypes.size()>0){
            for(String accesstype: accesstypes){
                String splitAccesstype='';
                splitAccesstype = accesstype.split(' ')[1];
                if(splitAccesstype.contains('/') && accesstypeMap.containsKey(splitAccesstype.split('/')[1])){
                    System.debug('Existing dealer code found: ' + splitAccesstype.split('/')[1]);
                    List<String> preAccesstypes = accesstypeMap.get(splitAccesstype.split('/')[1]);
                    List<String> accesstypePerAccount = preAccesstypes;
                    accesstypePerAccount.add(splitAccesstype.split('/')[0]);
                    accesstypeMap.put(splitAccesstype.split('/')[1], accesstypePerAccount);   
                }else if(splitAccesstype.contains('/')){
                    System.debug('New dealer code found: ' + splitAccesstype.split('/')[1]);
                    List<String> accesstypePerAccount = new List<String>();
                    accesstypePerAccount.add(splitAccesstype.split('/')[0]);
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
    */
    public static Map<String,List<Account>> compareAccesstype(Contact newCon, Contact oldCon){
        Map<String,List<String>> newAccesstype = new Map<String,List<String>>();
        Map<String,List<String>> oldAccesstype = new Map<String,List<String>>();
        Map<String,List<Account>> accMap = new Map<String,List<Account>>();

        if(newCon.Access_Types__c!='' && newCon.Access_Types__c!=null) newAccesstype = contactAccessType(newCon);
        if(oldCon.Access_Types__c!='' && oldCon.Access_Types__c!=null) oldAccesstype = contactAccessType(oldCon);

        System.debug('newAccesstype: '+newAccesstype);
        System.debug('oldAccesstype: '+oldAccesstype);
        Map<String,Set<String>> inactiveACR = new Map<String,Set<String>>(); //Map of dealer code and app
        Map<String,Set<String>> activeACR = new Map<String,Set<String>>();
        List<Account> inactiveAcc = new List<Account>();
        List<Account> activeAcc = new List<Account>();

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
        }

        activeAcc=activeAccountContactRelation(newCon, activeACR);
        inactiveAcc=inactiveAccountContactRelation(oldCon, inactiveACR);
        accMap.put(ACTIVE,activeAcc);
        accMap.put(INACTIVE,inactiveAcc);
        return accMap;

    }
    

    /**
     * [Method Description] Deactive ACR for deleted accesstype
     * Created by [MinheeKim] on [2023-12-12] for [DPM-4454]
     * Edited by [MinheeKim] on [2024-03-29] for [DPM-5469] change to prevent inactive DNAMS ACR
     * Edited by [MinheeKim] on [2024-07-10] for [DPM-5613] add logic to turn off DPMAccountUser flag when user loses DPM access for the account
     * Edited by Areum on 11-01-2024 for DNAMS PIR / add DNAMS logic 
    */
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
    }

    /**
     * [Method Description] Active ACR for deleted accesstype
     * Created by [MinheeKim] on [2023-12-13] for [DPM-4454]
     * Edited by [MinheeKim] on [2024-07-10] for [DPM-5613] add logic to turn on DPMAccountUser flag when user gets DPM access for the account
     * Edited by Areum on 11-01-2024 for DNAMS PIR / add DNAMS logic 
    */
    public static List<Account> activeAccountContactRelation(Contact newCon, Map<String,Set<String>> newDealerCode){

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
    }

     /**
     * [Method Description] Delete the ACR 
     * Created by [MinheeKim] on [2024-06-28] for [DPM-5613]
    */
    public static void deleteInactiveACR( Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        System.debug(LoggingLevel.ERROR, 'Contact Trigger - updateACR started');

        /*List<AccountContactRelation> acrList = [SELECT AccountId, Account.DealerCode__c, IsActive, IsDirect, DNAMSAccountUser__c FROM AccountContactRelation 
        WHERE ContactId IN :newMap.keySet() AND IsDirect = false AND IsActive=false AND DNAMSAccountUser__c = false];*/ 
        
        List<AccountContactRelation> acrList = [SELECT AccountId, Account.DealerCode__c, IsActive, IsDirect, DNAMSAccountUser__c FROM AccountContactRelation 
        WHERE ContactId IN :newMap.keySet() AND IsDirect = false AND IsActive=false]; //Added by Areum on 11-01-2024 for DNAMS PIR

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

    
}