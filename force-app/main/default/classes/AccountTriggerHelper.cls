public with sharing class AccountTriggerHelper {

 
    public static void handleBeforeInsertUpdate(List<Account> accounts, Map<Id, Account> oldMap) {
        
        Set<Id> organizationIds = new Set<Id>();
        Set<Id> regionIds = new Set<Id>();
        Set<Id> districtIds = new Set<Id>();
        Set<Id> genesisAreaIds = new Set<Id>();
        Set<Id> hyundaiAreaIds = new Set<Id>();
        for(Account account:accounts) {
            if(account.Organization__c != null) {
                organizationIds.add(account.Organization__c);
            }
            if(account.Region__c != null) {
                regionIds.add(account.Region__c);
            }
            if(account.SalesDistrict__c != null) {
                districtIds.add(account.SalesDistrict__c);
            }
            if(account.ServiceDistrict__c != null) {
                districtIds.add(account.ServiceDistrict__c);
            }
            
            /* following lines comment by neeraj sharma for ticket 3453

if(account.GenesisArea__c != null) {
genesisAreaIds.add(account.GenesisArea__c);
}*/
            if(account.HyundaiArea__c != null) {
                hyundaiAreaIds.add(account.HyundaiArea__c);
            }
            if(account.Market__c != null) {
                districtIds.add(account.Market__c);
            }
        }

        Map<Id, Organization__c> organizationMap = getOrganizationMapFromOrganiztionIds(organizationIds);
        Map<Id, Region__c> regionMap = getRegionsMapFromRegionIds(regionIds);
        Map<Id, District__c> districtMap = getDistrictMapFromDistrictIds(districtIds);
        /* following lines comment by neeraj sharma for ticket 3453

Map<Id, GenesisArea__c> genesisAreaMap = getGenesisAreasMapFromGenAreaIds(genesisAreaIds);
*/
        Map<Id, HyundaiArea__c> hyundaiAreaMap = getHyundaiAreasMapFromHyundaiAreaIds(hyundaiAreaIds);
        
        for(Account account:accounts) {
            
            if(account.Region__c != null && regionMap.containsKey(account.Region__c)) {
                account.RegionCodePicklist__c = regionMap.get(account.Region__c).RegionCode__c;
            }
            
            if(account.SalesDistrict__c != null && districtMap.containsKey(account.SalesDistrict__c)) {
                account.SalesDistrictCode__c = districtMap.get(account.SalesDistrict__c).DistrictCode__c;
                account.DistrictSalesManager__c = districtMap.get(account.SalesDistrict__c).SalesManager__c;
                //account.DistrictSalesManagerAlt__c = districtMap.get(account.SalesDistrict__c).DistrictSalesManagerAlt__c;              
                account.DistrictManager__c = districtMap.get(account.SalesDistrict__c).DistrictManager__c;
                // account.DistrictManagerAlt__c = districtMap.get(account.SalesDistrict__c).DistrictManagerAlt__c;
            }
            
            if(account.ServiceDistrict__c != null && districtMap.containsKey(account.ServiceDistrict__c)) {
                account.ServiceDistrictCodePicklist__c = districtMap.get(account.ServiceDistrict__c).DistrictCode__c;
                account.DistrictPartsServiceManager__c = districtMap.get(account.SalesDistrict__c).DistrictPartsServiceManager__c;
                //account.DistrictPartsServiceManagerAlt__c = districtMap.get(account.SalesDistrict__c).DistrictPartsServiceManagerAlt__c;
            }
            
            if(account.Market__c != null && districtMap.containsKey(account.Market__c)) {
                account.MarketCodeGenesisPicklist__c = districtMap.get(account.Market__c).DistrictCode__c;
                account.MarketManager__c = districtMap.get(account.Market__c).MarketManager__c;
                account.Aftersales_Market_Manager__c = districtMap.get(account.Market__c).Aftersales_Market_Manager__c;// DPM-4188
                account.GenesisMarketManagerAlt__c = districtMap.get(account.Market__c).GenesisMarketManagerAlt__c;
            }
            
            /*if(account.GenesisArea__c != null && genesisAreaMap.containsKey(account.GenesisArea__c)) {
account.GenesisAreaCodePicklist__c = genesisAreaMap.get(account.GenesisArea__c).AreaCode__c;
account.GenesisAreaManager__c = genesisAreaMap.get(account.GenesisArea__c).GenesisAreaManager__c;
}*/
            
            String accountSearchString = (!String.isBlank(account.Organization__c) ? organizationMap.get(account.Organization__c).Name + '@@@' : '');
            accountSearchString += (!String.isBlank(account.DealerCode__c) ? account.DealerCode__c + '@@@' : '');
            accountSearchString += (!String.isBlank(account.Name) ? account.Name + '@@@' : '');
            accountSearchString += (!String.isBlank(account.Region__c) ? regionMap.get(account.Region__c).RegionCode__c + '@@@' : '');
            accountSearchString += (!String.isBlank(account.Region__c) ? regionMap.get(account.Region__c).Name + '@@@' : '');
            accountSearchString += (!String.isBlank(account.ServiceDistrict__c) ? districtMap.get(account.ServiceDistrict__c).DistrictCode__c + '@@@' : '');
            accountSearchString += (!String.isBlank(account.ServiceDistrict__c) ? districtMap.get(account.ServiceDistrict__c).Name + '@@@' : '');
            
            accountSearchString += account.SalesDistrict__c != null ? districtMap.get(account.SalesDistrict__c).DistrictCode__c + '@@@' : '';
            accountSearchString += account.SalesDistrict__c != null? districtMap.get(account.SalesDistrict__c).Name + '@@@' : '';
            
            accountSearchString += account.Market__c != null ? districtMap.get(account.Market__c).DistrictCode__c + '@@@' : '';
            accountSearchString += account.Market__c != null ? districtMap.get(account.Market__c).Name + '@@@' : '';
            
            accountSearchString += account.HyundaiArea__c != null ? hyundaiAreaMap.get(account.HyundaiArea__c).Name + '@@@' : '';
            /* following lines comment by neeraj sharma for ticket 3453

//   accountSearchString += account.GenesisArea__c != null ? genesisAreaMap.get(account.GenesisArea__c).Name + '@@@' : '';
*/         
            account.HMAAccountSearch__c = accountSearchString.removeEnd('@@@');
        }
        
        /* Code for DNAMS */
        tempDealerCreationInDNAMS(accounts, oldMap);
        /* End of code for DNAMS*/

        
    }
    
    private static Map<Id, Region__c> getRegionsMapFromRegionIds(Set<Id> regionIds) {
        return new Map<Id, Region__c>([select Id, Name, RegionCode__c from Region__c where Id in :regionIds]);
    }
    
    private static Map<Id, District__c> getDistrictMapFromDistrictIds(Set<Id> districtIds) {
        return new Map<Id, District__c>([select Id, Name, DistrictCode__c, DistrictManager__c, SalesManager__c, DistrictPartsServiceManager__c, MarketManager__c,Aftersales_Market_Manager__c,DistrictPartsServiceManagerAlt__c,DistrictSalesManagerAlt__c,DistrictManagerAlt__c,GenesisMarketManagerAlt__c from District__c where Id in :districtIds]);
    }
    
    private static Map<Id, Organization__c> getOrganizationMapFromOrganiztionIds(Set<Id> organizationIds) {
        return new Map<Id, Organization__c>([select Id, Name from Organization__c where Id in :organizationIds]);
    }
    
    /*  private static Map<Id, GenesisArea__c> getGenesisAreasMapFromGenAreaIds(Set<Id> genAreaIds) {
return new Map<Id, GenesisArea__c>([select Id, Name, AreaCode__c, GenesisAreaManager__c from GenesisArea__c where Id in :genAreaIds]);
}*/
    
    private static Map<Id, HyundaiArea__c> getHyundaiAreasMapFromHyundaiAreaIds(Set<Id> hyundaiAreaIds) {
        return new Map<Id, HyundaiArea__c>([select Id, Name from HyundaiArea__c where Id in :hyundaiAreaIds]);
    }
    
    
    public static void handleAfterUpdate(List<Account> newList, Map<Id,Account> oldMap) {
        List<Id> listAccIds = new List<Id>();
        Set<Id> setDealerCodeUpdatedAccIds = new Set<Id>();//Added for DNAMS.
        
        for (Account acc : newList) {
            if (oldMap != NULL && ((acc.SalesDistrict__c != NULL && acc.SalesDistrict__c != oldMap.get(acc.Id).SalesDistrict__c)
                                   || (acc.ServiceDistrict__c != NULL && acc.ServiceDistrict__c != oldMap.get(acc.Id).ServiceDistrict__c)
                                   || (acc.Market__c != NULL && acc.Market__c != oldMap.get(acc.Id).Market__c))) {
                                       listAccIds.add(acc.Id);
                                   }
            /* 
* Code for DNAMS
* If DealerCode__c on an account gets updated, add the Account ID into setDealerCodeUpdatedAccIds.
*/
            if(oldMap != NULL && acc.DealerCode__c != NULL && acc.DealerCode__c != oldMap.get(acc.Id).DealerCode__c) {
                setDealerCodeUpdatedAccIds.add(acc.Id);
            }
            /* End of code for DNAMS*/
        }
        
        if (listAccIds.size() > 0) {
            EvaluationDistrictBatch btchEval = new EvaluationDistrictBatch(listAccIds);
            Database.executeBatch(btchEval,50);
            
            ActionPlanDistrictBatch btchAP = new ActionPlanDistrictBatch(listAccIds);
            Database.executeBatch(btchAP,50);
        }
        
        /* Code for DNAMS */
        if(!setDealerCodeUpdatedAccIds.isEmpty()) {
            System.enqueueJob(new DNAMSEnforceSSOPermSetQueueable(setDealerCodeUpdatedAccIds));
        }
        /* End of code for DNAMS*/
    }
    
    /*
* When a temporary dealer account is created in DNAMS, generate a temporary dealer code and
* Prefix the dealer code on the Account Name.
* Accepts list of Accounts as a param.
*/
    private static void tempDealerCreationInDNAMS(List<Account> accounts, Map<Id, Account> oldMap) {
        List<TempDealerCodes__c> tdsList = new List<TempDealerCodes__c>();
        
        for(Account account : accounts) {
            if(!account.Is_Temp_Account__c) {
                continue;
            }
            if(trigger.isInsert) {
                TempDealerCodes__c updateTempMetaRec = TempDealerCodes__c.getInstance(account.RegionCodePicklist__c);
                if(updateTempMetaRec <> null) {
                    integer bigNum = integer.valueof(updateTempMetaRec.LatestRunningNumber__c) + 1;
                    String formattedNumber = String.valueOf(bigNum).leftPad(5, '0');
                    
                    account.DealerCode__c = 'T' + account.RegionCodePicklist__c + formattedNumber;
                    account.Name = account.DealerCode__c + ' - ' + account.Name;
                    
                    updateTempMetaRec.LatestRunningNumber__c = updateTempMetaRec.LatestRunningNumber__c + 1;
                    tdsList.add(updateTempMetaRec);
                }
            }
            else if(trigger.isUpdate && oldMap != null && account.DealerCode__c <> null && account.DealerCode__c <> oldMap.get(account.Id).DealerCode__c) {
                if(account.Name.contains('-')) {
                    account.Name = account.DealerCode__c + ' - ' + account.Name.substringAfter('-').trim();
                }
                else {
                    account.Name = account.DealerCode__c + ' - ' + account.Name;   
                }
     
            }
        }
        if(!tdsList.isEmpty()) {
            update tdsList;
        }
    }

    /**
     * [Method Description] close Evaluation and Action plan which are related to terminated account
     * Created by [MinheeKim] on [2024-03-29] for [DPM-4456]
     * Edited by [MinheeKim] on [2024-05-20] for [DPM-4455] Change the action plan's owner when the account is terminated.
     * Edited by [MinheeKim] on [11-20-2024] for [DPM-5923] Added logic to update Disable_Email_Notification_Flag__c field when account is terminated.
    */    
    public static void updateEvaluationAcionPlan(List<Account> accounts, Map<Id, Account> oldMap) {
        List<Evaluation__c> closeEvaluationsToUpdate = new List<Evaluation__c>();
        List<Action_Plan__c> closeActionPlansToUpdate = new List<Action_Plan__c>();
    
        Set<Id> terminatedAccountIds = new Set<Id>();
        for (Account account : accounts) {
            if (account.IsTerminated__c && oldMap.containsKey(account.Id) && !oldMap.get(account.Id).IsTerminated__c) {
                terminatedAccountIds.add(account.Id);
            }
        }
    
        if (!terminatedAccountIds.isEmpty()) {
            Map<Id, Evaluation__c> evaluationsMap = new Map<Id, Evaluation__c>([
                SELECT Id, Status__c, ApprovalStatus__c , OwnerId //DPM-4455 added OwnerId by MinheeKim - 24.05.20
                FROM Evaluation__c 
                WHERE Account__c IN :terminatedAccountIds 
                //AND ApprovalStatus__c != 'Region Approved' //DPM-5923 Changed to comment by MinheeKim -11.20.2024
            ]);
    
            for (Evaluation__c eval : evaluationsMap.values()) {  
                if(eval.ApprovalStatus__c != 'Region Approved'){ //DPM-5923 added condition by MinheeKim - 11.20.2024
                    eval.Status__c = 'Non-Compliant';
                    eval.ApprovalStatus__c = 'Region Approved';
                    
                }
                eval.Disable_Email_Notification_Flag__c = true; //DPM-5923 added by MinheeKim - 11.20.2024
                closeEvaluationsToUpdate.add(eval);
            }
    
            Map<Id, Action_Plan__c> actionPlansMap = new Map<Id, Action_Plan__c>([
                SELECT Id, Status__c, Evaluation__c , ApprovalStatus__c , OwnerId, Owner.Profile.Name //DPM-4455 added OwnerId, Owner.Profile.Name by MinheeKim - 24.05.20
                FROM Action_Plan__c 
                WHERE Account__c IN :terminatedAccountIds  
                AND ApprovalStatus__c != 'Region Approved'
            ]);
    
            for (Action_Plan__c ap : actionPlansMap.values()) {
                ap.Status__c = 'Non-Compliant';
                ap.ApprovalStatus__c = 'Region Approved';
                closeActionPlansToUpdate.add(ap);
                //DPM-4455 start: If the action plan's owner is dealer, change the owner to the evaluation's owner by MinheeKim - 24.05.20
                if(ap.Owner.Profile.Name !=null && ap.Owner.Profile.Name.contains('Partner') && evaluationsMap.containsKey(ap.Evaluation__c) ){
                    ap.OwnerId = evaluationsMap.get(ap.Evaluation__c).OwnerId;
                }
                //DPM-4455 end
            }
        }
    
        try {
            EvaluationTriggerHandler.run = false;
            update closeEvaluationsToUpdate;
            update closeActionPlansToUpdate;
            EvaluationTriggerHandler.run = true;
        } catch (Exception e) {
            System.debug('Error closeEvaluationAcionPlan: ' + e.getMessage());
        }
    }
    
    
}