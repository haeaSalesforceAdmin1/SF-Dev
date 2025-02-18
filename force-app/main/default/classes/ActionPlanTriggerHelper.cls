/**
************************************************************************************************
* @classname         : ActionPlanTriggerHelper
* @description       : 
* @author            : JongHoon Kim
* History
* Version      Date                Author               Ticket         Modification
* 1.0       01-22-2025           JongHoon Kim           DPM-133       Add Action Plan District Manager Update Logic
* 1.1       02-03-2025           JongHoon Kim           DPM-6033      If the due date has not passed, update the Manager and Owner
************************************************************************************************
**/

public without sharing class ActionPlanTriggerHelper {
    
    public static Map<String, Map<String, List<ObjectAccess__mdt>>> objectAccessMap =  new Map<String, Map<String, List<ObjectAccess__mdt>>>();
    
    private static String cachedEnvironment;
    private static Date today = Date.today(); // DPM-6033

     public static String getEnvironment() {
         if (cachedEnvironment == null) {
             cachedEnvironment = [SELECT Environment__c FROM CurrentEnvironment__c].Environment__c;
         }
         return cachedEnvironment;
     }
    
    public static void populateAccountForActionsPlansCreatedFromEinsteinKPI(List<Action_Plan__c> actionPlans) {
        
        List<Id> einsteinKPIDetailIds = new List<Id>();
        List<Action_Plan__c> actionPlansToUpdate = new List<Action_Plan__c>();
        for(Action_Plan__c actionPlan:actionPlans) {
            if(actionPlan.Account__c == null && actionPlan.EinsteinKPIDetail__c != null) {
                einsteinKPIDetailIds.add(actionPlan.EinsteinKPIDetail__c);
                actionPlansToUpdate.add(actionPlan);
            }
        }
        Map<Id, EinsteinKPIDetail__c> mapOfEinsteinEninsteinKPIDetail = new Map<Id, EinsteinKPIDetail__c>([select Id, Account__c from EinsteinKPIDetail__c where Id in :einsteinKPIDetailIds]);
        
        for(Action_Plan__c actionPlan: actionPlansToUpdate) {
            actionPlan.Account__c = mapOfEinsteinEninsteinKPIDetail.get(actionPlan.EinsteinKPIDetail__c).Account__c;
        }
    }
    
    public static void populateOwnerFromPrimaryContactUser(List<Action_Plan__c> actionPlans) {
        
        List<Id> contactIds = new List<Id>();
        for(Action_Plan__c actionPlan:actionPlans) {
            if(!String.isBlank(actionPlan.EvaluationPrimaryContactId__c)) {
                contactIds.add(actionPlan.EvaluationPrimaryContactId__c);
            }
        }
        
        Map<Id, Id> contactUserMap = new Map<Id, Id>();
        for(User user:[select Id, ContactId from User where ContactId in :contactIds]) {
            contactUserMap.put(user.ContactId, user.Id);
        }
        
        for(Action_Plan__c actionPlan:actionPlans) {
            if(!String.isBlank(actionPlan.EvaluationPrimaryContactId__c) && contactUserMap.containsKey(actionPlan.EvaluationPrimaryContactId__c)) {
                actionPlan.OwnerId = contactUserMap.get(actionPlan.EvaluationPrimaryContactId__c);
            }
        }
    }
     
    public static void populateActionPlanFromAccount(List<Action_Plan__c> actionPlans,Map<Id, Action_Plan__c> oldActionPlanMap) {    
        System.debug(LoggingLevel.ERROR, actionPlans);
        set<id> regionIds= new set<Id>();
        Map<id,Region__c> regionsMap = new Map<id,Region__c>();
        Set<Id> accountIds = new Set<Id>();
        for(Action_Plan__c actionPlan:actionPlans) {
            if(actionPlan.Account__c != null) {
                accountIds.add(actionPlan.Account__c);
                system.debug('test is '+ actionPlan.Account__r.Region__c);
                if(actionPlan.Account__r.Region__c!=null)
                    regionIds.add(actionPlan.Account__r.Region__c);
            }
            
        }
        
        if(regionIds.size()>0){
            
            for(Region__c reg : [select id,RegionCode__c,Name from Region__c where id in:regionIds]){
                regionsMap.put(reg.id,reg);
            }
            
        }
        
        Map<Id, Account> accountMap = HMAQueryService.getAccountMapFromSetOfAccountIds(accountIds);
        System.debug(LoggingLevel.ERROR, accountMap);
        List<Id> genesisAreas = new List<Id>();
        List<Action_Plan__c> genesisActionPlans = new List<Action_Plan__c>();
        //Add DPM-133
        Set<String> validApprovalStatuses = new Set<String>{
            'Submitted for District Approval',
            'District Approved',
            'Sent Back'
        };
        
        for(Action_Plan__c actionPlan:actionPlans) {
            System.debug(LoggingLevel.ERROR, actionPlan);
            
            if(actionPlan.Account__c != null) {
                if(actionPlan.KPI__c != null && String.isBlank(actionPlan.HMAInternalSummary__c)) {
                    actionPlan.RefreshKPI__c = true;
                }
                
                Account actionPlanAccount = accountMap.get(actionPlan.Account__c);
                System.debug(LoggingLevel.ERROR, actionPlanAccount);
                
                actionPlan.OrganizationRef__c = actionPlanAccount.Organization__c;
                actionPlan.Organization__c = actionPlanAccount.Organization__r.Name;
                System.debug(LoggingLevel.ERROR, actionPlanAccount.Organization__r.Name);
                System.debug(LoggingLevel.ERROR, actionPlan.Organization__c);
                System.debug(LoggingLevel.ERROR, actionPlan);
                actionPlan.DealerCodeText__c = actionPlanAccount.DealerCode__c;
                //actionPlan.GeneralManager__c = actionPlanAccount.GeneralManager__c;
                //actionPlan.DealerPrincipal__c = actionPlanAccount.DealerPrincipal__c;
                if(actionPlanAccount.Name.contains('-')) {
                    actionPlan.DealerName__c = actionPlanAccount.Name.split('-')[1].trim();
                }
                else {
                    actionPlan.DealerName__c = actionPlanAccount.Name;
                }
                
                actionPlan.DistrictManager__c = actionPlanAccount.DistrictManager__c;
                //actionPlan.DistrictManagerAlt__c = actionPlanAccount.DistrictManagerAlt__c;

                if(actionPlanAccount.RecordType.DeveloperName == 'HyundaiDealer' || actionPlanAccount.RecordType.DeveloperName == 'GenesisRetailer'){
                    if(oldActionPlanMap!=null && oldActionPlanMap.get(actionPlan.id).RegionRef__c!=actionPlanAccount.Region__c && !regionsMap.isEmpty()){
                        system.debug('i am here' +actionPlan.RegionRef__c );
                        actionPlan.RegionCode__c = regionsMap.get(actionPlanAccount.Region__c).RegionCode__c;
                        actionPlan.Region__c = regionsMap.get(actionPlanAccount.Region__c).Name;
                    }
                    else{
                        actionPlan.RegionRef__c = actionPlanAccount.Region__c;
                        actionPlan.RegionCode__c = actionPlanAccount.Region__r.RegionCode__c;
                        actionPlan.Region__c = actionPlanAccount.Region__r.Name;
                    }
                    actionPlan.ServiceDistrict__c = actionPlanAccount.ServiceDistrict__c;
                    if(actionPlan.ServiceDistrict__c != null) {
                        actionPlan.ServiceDistrictName__c = actionPlanAccount.ServiceDistrict__r.DistrictCode__c + ' - ' + actionPlanAccount.ServiceDistrict__r.Name;
                        actionPlan.ServiceDistrictCode__c = actionPlanAccount.ServiceDistrict__r.DistrictCode__c;
                    }
                    // DPM-6033 Add EndDate__c logic start
                    if(actionPlan.EndDate__c >= today && actionPlanAccount.ServiceDistrict__r.DistrictPartsServiceManager__r.isactive  == true) {
                        actionPlan.DistrictPartsServiceManager__c = actionPlanAccount.ServiceDistrict__r.DistrictPartsServiceManager__c;
                    }
                    
                    if(actionPlan.EndDate__c >= today && actionPlan.Division__c == 'Service' && validApprovalStatuses.contains(actionPlan.ApprovalStatus__c) && actionPlanAccount.ServiceDistrict__r.DistrictPartsServiceManager__r.isactive  == true) {
                        actionPlan.OwnerId = actionPlanAccount.ServiceDistrict__r.DistrictPartsServiceManager__c;
                    }
                    // end
                    //actionPlan.DistrictPartsServiceManagerAlt__c = actionPlanAccount.ServiceDistrict__r.DistrictPartsServiceManagerAlt__c;
                    actionPlan.SalesDistrict__c = actionPlanAccount.SalesDistrict__c;
                    if(actionPlan.SalesDistrict__c != null) {
                        actionPlan.SalesDistrictName__c = actionPlanAccount.SalesDistrict__r.DistrictCode__c + ' - ' + actionPlanAccount.SalesDistrict__r.Name;
                        actionPlan.SalesDistrictCode__c = actionPlanAccount.SalesDistrict__r.DistrictCode__c;
                    }
                    // DPM-6033 Add EndDate__c logic start
                    if(actionPlan.EndDate__c >= today && actionPlanAccount.SalesDistrict__r.SalesManager__r.isactive  == true) {
                        actionPlan.DistrictSalesManager__c = actionPlanAccount.SalesDistrict__r.SalesManager__c;
                    }
                    
                    if(actionPlan.EndDate__c >= today && actionPlan.Division__c == 'Sales' && validApprovalStatuses.contains(actionPlan.ApprovalStatus__c) && actionPlanAccount.SalesDistrict__r.SalesManager__r.isactive  == true) {
                        actionPlan.OwnerId = actionPlanAccount.SalesDistrict__r.SalesManager__c;
                    }
                    // end
                    //actionPlan.DistrictSalesManagerAlt__c = actionPlanAccount.SalesDistrict__r.DistrictSalesManagerAlt__c;

                    //actionPlan.OwnerId = actionPlanAccount.SalesDistrict__r.SalesManager__c;
                    if(actionPlanAccount.RecordType.DeveloperName == 'GenesisRetailer'){
                        
                        actionPlan.MarketRef__c = actionPlanAccount.Market__c;
                        actionPlan.MarketCode__c = actionPlanAccount.Market__r.DistrictCode__c;
                        actionPlan.MarketManager__c = actionPlanAccount.Market__r.MarketManager__c;
                        actionPlan.Aftersales_Market_Manager__c = actionPlanAccount.Market__r.Aftersales_Market_Manager__c;
                        actionPlan.GenesisMarketManagerAlt__c = actionPlanAccount.Market__r.GenesisMarketManagerAlt__c;
                    }
                    
                }
                else {
                    // evaluation.MarketName__c = evalAccount.Market__r.DistrictCode__c + ' - ' + evalAccount.Market__r.Name;
                    actionPlan.MarketRef__c = actionPlanAccount.Market__c;
                    actionPlan.MarketCode__c = actionPlanAccount.Market__r.DistrictCode__c;
                    actionPlan.MarketManager__c = actionPlanAccount.Market__r.MarketManager__c;
                    actionPlan.Aftersales_Market_Manager__c = actionPlanAccount.Market__r.Aftersales_Market_Manager__c;
                    actionPlan.GenesisMarketManagerAlt__c = actionPlanAccount.Market__r.GenesisMarketManagerAlt__c;

                    /* code is commented by Neeraj for ticket 3451
*  actionPlan.GenesisArea__c = actionPlanAccount.GenesisArea__c;
actionPlan.GenesisAreaCode__c = actionPlanAccount.GenesisArea__r.AreaCode__c;
actionPlan.GenesisAreaName__c = actionPlanAccount.GenesisArea__r.Name;
actionPlan.GenesisAreaManager__c = actionPlanAccount.GenesisAreaManager__c;
genesisAreas.add(actionPlanAccount.GenesisArea__c);
genesisActionPlans.add(actionPlan);*/
                }
            }
            
            String actionPlanString = (!String.isBlank(actionPlan.Organization__c) ? actionPlan.Organization__c + '@@@' : '') + 
                (!String.isBlank(actionPlan.DealerCodeText__c) ? actionPlan.DealerCodeText__c + '@@@' : '') + 
                (!String.isBlank(actionPlan.DealerName__c) ? actionPlan.DealerName__c + '@@@' : '') + 
                (!String.isBlank(actionPlan.RegionCode__c) ? actionPlan.RegionCode__c + '@@@' : '') + 
                (!String.isBlank(actionPlan.Region__c) ? actionPlan.Region__c + '@@@' : '') + 
                (!String.isBlank(actionPlan.ServiceDistrictName__c) ? actionPlan.ServiceDistrictName__c + '@@@' : '') + 
                (!String.isBlank(actionPlan.ServiceDistrictCode__c) ? actionPlan.ServiceDistrictCode__c + '@@@' : '') + 
                (!String.isBlank(actionPlan.SalesDistrictName__c) ? actionPlan.SalesDistrictName__c + '@@@' : '') + 
                (!String.isBlank(actionPlan.SalesDistrictCode__c) ? actionPlan.SalesDistrictCode__c + '@@@' : '') + 
                (!String.isBlank(actionPlan.MarketCode__c) ? actionPlan.MarketCode__c + '@@@' : '') + 
                (!String.isBlank(actionPlan.MarketManager__c) ? actionPlan.MarketManager__c + '@@@' : '') +
                (!String.isBlank(actionPlan.Aftersales_Market_Manager__c) ? actionPlan.Aftersales_Market_Manager__c + '@@@' : ''); // DPM-4188 Made changes by Milind Shinde
            
            /*  /* code is commented by Neeraj for ticket 3451
(!String.isBlank(actionPlan.GenesisAreaCode__c) ? actionPlan.GenesisAreaCode__c + '@@@' : '') + 
(!String.isBlank(actionPlan.GenesisAreaName__c) ? actionPlan.GenesisAreaName__c + '@@@' : '');*/
            actionPlan.ActionPlanSearch__c = actionPlanString.removeEnd('@@@');
            
        } /* code is commented by Neeraj for ticket 3451
if(!genesisActionPlans.isEmpty()) {
Map<Id, List<AreasRegion__c>> mapOfGeneisisRegions = HMAQueryService.getAreaRegionsForGenesisAreas(genesisAreas);

for(Action_Plan__c genesisActionPlan:genesisActionPlans) {
String regionCodes = '';
String regions = '';
if(mapOfGeneisisRegions.containsKey(genesisActionPlan.GenesisArea__c)) {
for(AreasRegion__c areaRegion:mapOfGeneisisRegions.get(genesisActionPlan.GenesisArea__c)) {
if(regions != '') {
regionCodes += ';';
regions += ';';
}
regionCodes += areaRegion.Region__r.RegionCode__c;
regions += areaRegion.Region__r.Name;
}    
}
genesisActionPlan.RegionCode__c = regionCodes;
genesisActionPlan.Region__c = regions;       
} 
}*/
    }
    
    public static void processKPICalculationsForActionsPlans(Map<Id, Action_Plan__c> newActionPlanMap) {
        
        if(!System.isBatch()) {
            Set<Id> actionPlanIds = new Set<Id>();
            for(Action_Plan__c actionPlan:newActionPlanMap.values()) {
                if(actionPlan.KPI__c != null) {
                    actionPlanIds.add(actionPlan.Id);
                }
            }
            
            if(!actionPlanIds.isEmpty()) {
                BatchProcessActionPlanSnapshots processActionPlanSnapshots = new BatchProcessActionPlanSnapshots(actionPlanIds);
                Database.executeBatch(processActionPlanSnapshots, 1);
            }
        }
    }
    
    public static void processRefreshKPICalculationsForActionsPlans(Map<Id, Action_Plan__c> newActionPlanMap, Map<Id, Action_Plan__c> oldActionPlanMap) {
        Set<String> kpiIds = new Set<String>();
        for(Action_Plan__c actionPlan:newActionPlanMap.values()) {
            System.debug(LoggingLevel.ERROR, actionPlan.KPI__c);
            System.debug(LoggingLevel.ERROR, actionPlan.RefreshKPI__c);
            System.debug(LoggingLevel.ERROR, oldActionPlanMap.get(actionPlan.Id).RefreshKPI__c);
            if(actionPlan.KPI__c != null && actionPlan.RefreshKPI__c && !oldActionPlanMap.get(actionPlan.Id).RefreshKPI__c) {
                kpiIds.add(actionPlan.KPI__c);
            }
        }
        
        if(!kpiIds.isEmpty()) {
            List<String> kpiIdArray = new List<String>();
            kpiIdArray.addAll(kpiIds);
            BatchEinsteinService2 batchEinsteinService = new BatchEinsteinService2(kpiIdArray);
            if(!Test.isRunningTest()) {
                Database.executeBatch(batchEinsteinService, 1);
            }
        }
    }
    
    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] Added getExistingSharesForObject method to reduce the queries 
    */
    public static void handleActionPlanSharing(Map<Id, Action_Plan__c> actionsPlanMap, Boolean isUpdate) {
        
        System.debug(LoggingLevel.ERROR, actionsPlanMap);
        System.debug(LoggingLevel.ERROR, actionsPlanMap.keySet());

        if(!System.isBatch() && !System.isFuture() && !System.isQueueable()) {
            try{
            //DPM-5426 change to query Dealer sharing and sharing in once 
                List<String> sharingReason = new List<String>();
                sharingReason.add(Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
                sharingReason.add(Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
                Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(actionsPlanMap.values(), sharingReason); //DPM-5426 changed to comments by MinheeKim - 24.03.19
                //DPM-5426 devide the sharing as Dealer and internal sharing
                Map<Id, Map<String, SObject>> dealerSharesMap = new Map<Id, Map<String, SObject>>();
                Map<Id, Map<String, SObject>> internalSharesMap = new Map<Id, Map<String, SObject>>();

                for(Id parentId :existingSharesMap.keySet()){
                    Map<String, SObject> sharesMap = existingSharesMap.get(parentId);
                    for(String key : sharesMap.keySet()){
                        if(sharesMap.get(key).get('RowCause')==Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c){
                            if(!dealerSharesMap.containsKey(parentId)) {
                                dealerSharesMap.put(parentId, new Map<String, SObject>());
                            }
                            dealerSharesMap.get(parentId).put(key, sharesMap.get(key));
                        }else if(sharesMap.get(key).get('RowCause')==Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c){
                            if(!internalSharesMap.containsKey(parentId)) {
                                internalSharesMap.put(parentId, new Map<String, SObject>());
                            }
                            internalSharesMap.get(parentId).put(key, sharesMap.get(key));
                        }

                    }

                }
            //DPM-5426 end

                //DPM-4548 DPM-4754
                if(!isUpdate) {
                    ActionPlanService.createActionPlanSharing(actionsPlanMap);
                } else {
                    ActionPlanService.updateActionPlanSharing(actionsPlanMap, internalSharesMap); //DPM-5426 added internalSharesMap by MinheeKim - 24.03.19
                }
                ActionPlanService.createActionPlanDealerSharing(actionsPlanMap, dealerSharesMap); //DPM-5426 added dealerSharesMap by MinheeKim - 24.03.19
            }catch(Exception e){
                System.debug(e.getCause());
                System.debug(e.getMessage());
            }
            /* DPM-4548
            if(actionsPlanMap.keyset().size() > 0) {
                BatchProcessObjectShares batchProcessObjectShares = new BatchProcessObjectShares();
                batchProcessObjectShares.objectIds = actionsPlanMap.keySet();
                batchProcessObjectShares.type = 'Action Plan';
                if(!Test.isRunningTest()) {
                    Database.executeBatch(batchProcessObjectShares, 1);
                }
            }*/
            /*else {
if(isUpdate) {
ActionPlanService.recalculateActionPlanSharing(actionsPlanMap.values());
}
else {
ActionPlanService.createActionPlanSharing(actionsPlanMap);
}
ActionPlanService.createActionPlanDealerSharing(actionsPlanMap);
}*/
        }
    }

    /* DPM-4548  */
    public static void handleActionPlanRollupForEvaluationApprovalStatus(List<Action_Plan__c> newActionPlans, Map<Id, Action_Plan__c> oldActionPlansMap) {

        Set<Id> evaluationIds = new Set<Id>();

        for(Action_Plan__c actionPlan:newActionPlans) {
            if(actionPlan.Evaluation__c != null) {
                Action_Plan__c oldActionPlan = oldActionPlansMap.get(actionPlan.Id);
                if(actionPlan.ApprovalStatus__c != oldActionPlan.ApprovalStatus__c
                        && (actionPlan.ApprovalStatus__c == 'Submitted for Regional Approval' || actionPlan.ApprovalStatus__c == 'Region Approved')){
                    evaluationIds.add(actionPlan.Evaluation__c);
                }
            }
        }

        System.debug(LoggingLevel.ERROR, evaluationIds);
        if(!evaluationIds.isEmpty()) ActionPlanService.rollupActionPlansForEvaluations(evaluationIds);
    }

    public static void handleActionPlanRollupForEvaluation(List<Action_Plan__c> newActionPlans, Map<Id, Action_Plan__c> oldActionPlansMap) {
        
        Set<Id> evaluationIds = new Set<Id>();
        
        for(Action_Plan__c actionPlan:newActionPlans) {
            if(actionPlan.Evaluation__c != null) {
                if(oldActionPlansMap != null) {
                    Action_Plan__c oldActionPlan = oldActionPlansMap.get(actionPlan.Id);
                    if(actionPlan.Evaluation__c != oldActionPlan.Evaluation__c || actionPlan.Status__c != oldActionPlan.Status__c || actionPlan.ApprovalStatus__c != oldActionPlan.ApprovalStatus__c){
                        evaluationIds.add(actionPlan.Evaluation__c);
                        if(oldActionPlan.Evaluation__c != null) {
                            evaluationIds.add(oldActionPlan.Evaluation__c);
                        }
                    }
                }
                else {
                    evaluationIds.add(actionPlan.Evaluation__c);
                }  
            }          
        }
        
        System.debug(LoggingLevel.ERROR, evaluationIds);
        ActionPlanService.rollupActionPlansForEvaluations(evaluationIds);
    }
    
    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-04-30] for [DPM-5400] Check if any of the potential AP owners are inactive before processing this change, and block the user from performing the action if we find the next owner is inactive/unavailable. 
    */
    public static void populateAssignedDealOnPartnerOwner(List<Action_Plan__c> newActionPlans, Map<Id, Action_Plan__c> oldActionPlansMap){
        
        List<Id> ownerIds = new List<Id>();
        for(Action_Plan__c actionPlan:newActionPlans) {
            if(oldActionPlansMap == null || (actionPlan.OwnerId != oldActionPlansMap.get(actionPlan.Id).OwnerId)) {
                ownerIds.add(actionPlan.OwnerId);
            }
            //DPM-5400 added to get user related to original_partener_user_id by MinheeKim - 24.04.30
            if(actionPlan.Original_Partner_User_ID__c!=null){
                ownerIds.add(actionPlan.Original_Partner_User_ID__c);
            }
        }

        
        Map<Id, User> usersMap = new Map<Id, User>([select Id, IsActive, IsPortalEnabled from User where Id in :ownerIds and IsPortalEnabled = true]); //DPM-5400 added IsActive by MinheeKim - 24.04.30
        
        for(Action_Plan__c actionPlan:newActionPlans) {
            if(usersMap.containsKey(actionPlan.OwnerId)) {
                actionPlan.AssignedDealer__c = actionPlan.OwnerId;
            }
            
            
            System.debug(LoggingLevel.ERROR, actionPlan.ApprovalStatus__c);
            System.debug(LoggingLevel.ERROR, actionPlan.MarketManager__c);
            if (oldActionPlansMap == NULL){
                actionPlan.Original_Partner_User_ID__c = actionPlan.OwnerId;
            }
            if((actionPlan.ApprovalStatus__c == 'Submitted for District Approval' && oldActionPlansMap != NULL && oldActionPlansMap.containsKey(actionPlan.Id) && oldActionPlansMap.get(actionPlan.Id).ApprovalStatus__c != 'Submitted for District Approval')
               || (actionPlan.ApprovalStatus__c == 'District Approved' && oldActionPlansMap != NULL && oldActionPlansMap.containsKey(actionPlan.Id) && oldActionPlansMap.get(actionPlan.Id).ApprovalStatus__c == 'Submitted for District Approval' )) {
                   if(actionPlan.Organization__c == 'Hyundai') {
                       
                       if(actionPlan.DistrictManager__c != null) {
                           actionPlan.OwnerId = actionPlan.DistrictManager__c;
                       }
                       else if(actionPlan.Division__c == 'Sales' && actionPlan.DistrictSalesManager__c != null) {
                           actionPlan.OwnerId = actionPlan.DistrictSalesManager__c;
                       }
                       else if(actionPlan.Division__c == 'Service' && actionPlan.DistrictPartsServiceManager__c != null ) {
                           actionPlan.OwnerId = actionPlan.DistrictPartsServiceManager__c;
                       }
                   }else if(actionPlan.Organization__c == 'Genesis' && actionPlan.Aftersales_Market_Manager__c != null && actionPlan.Division__c == 'Service') {
                       actionPlan.OwnerId = actionPlan.Aftersales_Market_Manager__c;
                   }
                   else if(actionPlan.Organization__c == 'Genesis' && actionPlan.MarketManager__c != null && actionPlan.Division__c == 'Sales') {
                       actionPlan.OwnerId = actionPlan.MarketManager__c;
                   }
                   
                   actionPlan.Is_Region_Sent_Back__c = FALSE;
                   System.debug(LoggingLevel.ERROR, 'Sent Back To Dealer 0 Original_Partner_User_ID__c'+actionPlan.Original_Partner_User_ID__c);
               }
            else if(actionPlan.ApprovalStatus__c == 'Sent Back To Dealer' && oldActionPlansMap != NULL && oldActionPlansMap.containsKey(actionPlan.Id) && oldActionPlansMap.get(actionPlan.Id).ApprovalStatus__c == 'Submitted for District Approval') { 
                // actionPlan.OwnerId = actionPlan.AssignedDealer__c; // Commented by Vinit on 22nd July 2021
                if (actionPlan.Original_Partner_User_ID__c != NULL) {
                    //DPM-5400 check the Original Partner User Id is acitve by Minhee Kim - 24.04.30
                    if(usersMap.containsKey(actionPlan.Original_Partner_User_ID__c) && usersMap.get(actionPlan.Original_Partner_User_ID__c).IsActive){
                        actionPlan.OwnerId = actionPlan.Original_Partner_User_ID__c; 
                        System.debug(LoggingLevel.ERROR, 'Sent Back To Dealer 1 Original_Partner_User_ID__c'+actionPlan.Original_Partner_User_ID__c);
                    }else{
                        // actionPlan.OwnerId.addError('The new owner of this Evaluation/Action Plan does not have proper DPM access. Please contact DPM Support (DPMSupport@hmausa.com) with details.');
                        // Log the exception or handle it internally
                        System.debug('Original_Partner_User_ID__c is inactive user');
                        
                        // Rollback to the savepoint
                        String error = Id.valueOf(actionPlan.Id);
                        throw new OwnerException(error);
                                        
                        }
                }
                    //DPM-5400 check the Original Partner User Id is acitve by Minhee Kim - 24.04.30
                    
            
                System.debug(LoggingLevel.ERROR, 'Sent Back To Dealer 1 OwnerId'+actionPlan.OwnerId);
                actionPlan.AssignedDealer__c = actionPlan.OwnerId;
                actionPlan.Is_Region_Sent_Back__c = FALSE;
                actionPlan.DistrictApprovalDate__c = NULL;
                actionPlan.Is_District_Sent_Back__c = TRUE;
            }else if ( actionPlan.ApprovalStatus__c == 'Sent Back To Dealer' && actionPlan.Is_Region_Sent_Back__c){
                //DPM-5400 check the Original Partner User Id is acitve by Minhee Kim - 24.04.30
                if(usersMap.containsKey(actionPlan.Original_Partner_User_ID__c) && usersMap.get(actionPlan.Original_Partner_User_ID__c).IsActive){
                    actionPlan.OwnerId = actionPlan.Original_Partner_User_ID__c; 
                    System.debug(LoggingLevel.ERROR, 'Sent Back To Dealer 2 Original_Partner_User_ID__c'+actionPlan.Original_Partner_User_ID__c);
                }else{
                    // actionPlan.OwnerId.addError('The new owner of this Evaluation/Action Plan does not have proper DPM access. Please contact DPM Support (DPMSupport@hmausa.com) with details.');
 
                    // Log the exception or handle it internally
                    System.debug('Original_Partner_User_ID__c is inactive user');
                        
                    // Rollback to the savepoint
                    String error = Id.valueOf(actionPlan.Id);
                    throw new OwnerException(error);
                }
                //DPM-5400 check the Original Partner User Id is acitve by Minhee Kim - 24.04.30
                System.debug(LoggingLevel.ERROR, 'Sent Back To Dealer 2 OwnerId'+actionPlan.OwnerId);
                actionPlan.AssignedDealer__c = actionPlan.OwnerId;
                actionPlan.Is_Region_Sent_Back__c = FALSE;
                actionPlan.DistrictApprovalDate__c = NULL;
                actionPlan.Is_District_Sent_Back__c = TRUE;
                actionPlan.Phase__c = 'Started';
            } else if (actionPlan.ApprovalStatus__c == 'Sent Back' 
                       && oldActionPlansMap != NULL && oldActionPlansMap.containsKey(actionPlan.Id) 
                       && oldActionPlansMap.get(actionPlan.Id).ApprovalStatus__c == 'Submitted for Regional Approval'
                       && !actionPlan.Is_Region_Sent_Back__c){
                        System.debug(LoggingLevel.ERROR, 'Sent Back To Dealer 3 OwnerId'+actionPlan.OwnerId);
                           if(actionPlan.Organization__c == 'Hyundai') {
                               
                               if(actionPlan.DistrictManager__c != null) {
                                   actionPlan.OwnerId = actionPlan.DistrictManager__c;
                               }
                               else if(actionPlan.Division__c == 'Sales' && actionPlan.DistrictSalesManager__c != null) {
                                   actionPlan.OwnerId = actionPlan.DistrictSalesManager__c;
                               }
                               else if(actionPlan.Division__c == 'Service' && actionPlan.DistrictPartsServiceManager__c != null ) {
                                   actionPlan.OwnerId = actionPlan.DistrictPartsServiceManager__c;
                               }
                           }
                           else if(actionPlan.Organization__c == 'Genesis' && actionPlan.Aftersales_Market_Manager__c != null && actionPlan.Division__c == 'Service') {
                               actionPlan.OwnerId = actionPlan.Aftersales_Market_Manager__c;
                           }
                           else if(actionPlan.Organization__c == 'Genesis' && actionPlan.MarketManager__c != null) {
                               actionPlan.OwnerId = actionPlan.MarketManager__c;
                           }
                           actionPlan.Is_District_Sent_Back__c = FALSE;
                           actionPlan.Is_Region_Sent_Back__c = TRUE;
                           actionPlan.Phase__c = 'Started';              
                       }
        }
        
    } 

    /**
     * [Method Description] 
     * Created by  [MinheeKim] on [2024-04-30] for [DPM-5400] Check if any of the potential AP owners are inactive before processing this change, and block the user from performing the action if we find the next owner is inactive/unavailable. 
     */
    public class OwnerException extends Exception {}
    
    
    /**
* Blank Follow-Up date while creation/update of AP for hyundai service
* @param  newActionPlans  list of new Action Plan
* @param  oldActionPlansMap map of old action plan
* @return none     
* @author Vinit [06 August 2021] 
*/
    public static void updateFollowUpDate(List<Action_Plan__c> newActionPlans){
        for (Action_Plan__c actPlan : newActionPlans) {
            // DPM-4626
            if (actPlan.FollowUpDate__c != NULL && actPlan.Organization__c == 'Hyundai' && actPlan.Division__c == 'Service' && actPlan.RecordTypeId != '0123I0000008kErQAI' && actPlan.RecordTypeId != '0123I0000008kEsQAI') {
                actPlan.FollowUpDate__c = NULL;
            }
        }
    }
    
    
    /**
* Validate Carry Over Logic - if user tries to change status to carry over then it will throw an error message. 
* As we have Carry Over button in the top right section for carrying Over logic.
* @param  newActionPlans  list of new Action Plan
* @param  oldActionPlansMap map of old action plan
* @return none     
* @author Vinit [09 August 2021] 
*/
    public static void validateCarryOverLogic(List<Action_Plan__c> newActionPlans, Map<Id, Action_Plan__c> oldActionPlansMap){
        
        for (Action_Plan__c actPlan : newActionPlans) {
            if ((actPlan.Status__c == 'Carry Over' && !actPlan.Is_Carry_Over_Button_Clicked__c
                 && oldActionPlansMap == NULL) || (oldActionPlansMap != NULL 
                                                   && actPlan.Status__c == 'Carry Over' 
                                                   && actPlan.Status__c != oldActionPlansMap.get(actPlan.Id).Status__c
                                                   && !actPlan.Is_Carry_Over_Button_Clicked__c) ) {
                                                       actPlan.addError('Status cannot be changed to Carry Over, click on Carry Over button in the top right section to roll over this Action Plan to the next quarter.');
                                                   }
        }
    }
    
    /**
* When AP is marked as carry over the answer in survey will be change from No to yes.
* it will work the same way as when AP is marked Compliant the answer in survey changes from No to Yes and the score changes.
* @param  newActionPlans  list of new Action Plan
* @param  oldActionPlansMap map of old action plan
* @return none     
* @author Vinit [21 Oct 2021] [IBM]
*/
    public static void carryOverAPSurveyUpdate(List<Action_Plan__c> newActionPlans, Map<Id, Action_Plan__c> oldActionPlansMap){
        
        List<Id> listOfSurveyQueToUpdate = new List<Id>(); 
        List<Action_Plan__c> listToUPDAP = new List<Action_Plan__c>(); 
        
        for (Action_Plan__c actPlan : newActionPlans) {
            
            /*  if (oldActionPlansMap != NULL && oldActionPlansMap.get(actPlan.Id).Status__c == 'Carry Over' 
&& actPlan.Status__c != oldActionPlansMap.get(actPlan.Id).Status__c
&& actPlan.ApprovalStatus__c == 'Region Approved' 
&& actPlan.ApprovalStatus__c != oldActionPlansMap.get(actPlan.Id).ApprovalStatus__c) {
actPlan.Status__c = 'Carry Over';
listToUPDAP.add(actPlan);
}*/
            
            if (oldActionPlansMap != NULL && actPlan.Status__c == 'Carry Over' 
                && actPlan.Is_Carry_Over_Button_Clicked__c 
                && actPlan.Status__c != oldActionPlansMap.get(actPlan.Id).Status__c
                && actPlan.Is_Carry_Over_Button_Clicked__c != oldActionPlansMap.get(actPlan.Id).Is_Carry_Over_Button_Clicked__c
                && actPlan.HMASurveyQuestion__c != NULL){
                    listOfSurveyQueToUpdate.add(actPlan.HMASurveyQuestion__c);
                    
                    if (actPlan.ApprovalStatus__c == 'Not Submitted' || actPlan.ApprovalStatus__c == 'Submitted for District Approval') {
                        ActionPlanApprovalController.handleActionPlanApprovals(actPlan.Id, 'Approve','Compliant Approval','Carry Over');
                    }
                }
            
            
        }
        
        /*if (listToUPDAP != NULL && listToUPDAP.size() > 0) {
update listToUPDAP;
}*/
        
        if (listOfSurveyQueToUpdate != NULL && listOfSurveyQueToUpdate.size() > 0) {
            List<Survey_Question__c> listSQ = new List<Survey_Question__c>();
            for (Survey_Question__c sq : [SELECT Id, Response__c, Response_Text__c, Score__c 
                                          FROM Survey_Question__c 
                                          WHERE Id IN: listOfSurveyQueToUpdate]) {
                                              sq.Response__c = 'Yes';
                                              sq.Response_Text__c = 'Yes';
                                              sq.Score__c = 1;
                                              listSQ.add(sq);
                                          }
            if (listSQ != NULL && listSQ.size() > 0) {
                update listSQ;
            }
        }
    }
    /**
* Blank Follow-Up date while creation/update of AP for hyundai service
* @param  newActionPlans  list of new Action Plan
* @param  oldActionPlansMap map of old action plan
* @return none     
* @author Neeraj [09 oct 2021]  Ticket DPM262
*/
    public static void UpdateDealerIndicator(List<Action_Plan__c> newActionPlans, Map<Id, Action_Plan__c> oldActionPlansMap){
        String Imagelink='';
        
        DPMConfigurationSettings__c var = DPMConfigurationSettings__c.getOrgDefaults();
        
        String instanceName = getEnvironment();
        
        for(Action_Plan__c ap :newActionPlans ){
          
            if(instanceName == 'STAGE'|| Test.isRunningTest()){
                  Imagelink =ap.Dealer_Indicator_Stage__c;
                if(ap.Phase__c=='Open'){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEDealerIndicatorCompletSumaryFileId__c;
                }
                else if (ap.Phase__c=='Started'&& ap.HasActionPlanFile__c && ap.HasDealerSummary__c){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEDealerIndicatorAwaitingFileId__c;
                }
                else if (ap.Phase__c=='Started' && !ap.HasActionPlanFile__c && ap.HasDealerSummary__c){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEDealerIndicatorFileProofReqFileId__c;
                }
                else if (ap.Phase__c=='Completed' && ap.Status__c=='Compliant'){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEDealerIndicatorCompleteCompliant__c;
                }
                else if (ap.Phase__c=='Completed' && ap.Status__c=='Non-Compliant'){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEDealerIndicatorCompleteNonComplia__c;
                }
                
                else if (ap.Phase__c=='Completed'){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEDealerIndicatorCompleteFileId__c;
                    
                }
                ap.Dealer_Indicator_Stage__c=Imagelink;
                
            }
            if(instanceName == 'PROD'|| Test.isRunningTest()){
                 Imagelink =ap.Dealer_Indicator_Prod__c;
                if(ap.Phase__c=='Open'){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.PROD_DealerIndicatorCompletSumaryFileId__c;
                }
                else if (ap.Phase__c=='Started'){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.PRODDealerIndicatorAwaitingFileId__c;
                }
                
                else if (ap.Phase__c=='Completed' && ap.Status__c=='Compliant'){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.PRODDealerIndicatorCompleteCompliant__c;
                }
                else if (ap.Phase__c=='Completed' && ap.Status__c=='Non-Compliant'){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.PRODDealerIndicatorCompleteNonComplian__c;
                }
                
                else if (ap.Phase__c=='Completed'){
                    Imagelink=Url.getOrgDomainUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.PRODDealerIndicatorCompleteFileId__c;
                     
                }
                ap.Dealer_Indicator_Prod__c=Imagelink;
                
            }
            
            
        }
        /*
IF( $Setup.CurrentEnvironment__c.Environment__c = "STAGE",
IF( ISPICKVAL(Phase__c, "Open"), IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) &$Setup.DPMConfigurationSettings__c.FileURLHelper__c &$Setup.DPMConfigurationSettings__c.STAGEDealerIndicatorCompletSumaryFileId__c,""),
IF(
AND(
ISPICKVAL(Phase__c, "Started"),HasActionPlanFile__c = TRUE,HasDealerSummary__c = TRUE),IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) & $Setup.DPMConfigurationSettings__c.FileURLHelper__c&$Setup.DPMConfigurationSettings__c.STAGEDealerIndicatorAwaitingFileId__c , ""),
IF(
AND(ISPICKVAL(Phase__c, "Started"), HasActionPlanFile__c = False, HasDealerSummary__c = TRUE) , IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) & $Setup.DPMConfigurationSettings__c.FileURLHelper__c&$Setup.DPMConfigurationSettings__c.STAGEDealerIndicatorFileProofReqFileId__c , ""),
IF(
AND(ISPICKVAL(Phase__c, "Completed"), ISPICKVAL(Status__c, "Compliant")),
IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) & $Setup.DPMConfigurationSettings__c.FileURLHelper__c& $Setup.DPMConfigurationSettings__c.STAGEDealerIndicatorCompleteCompliant__c, ""),
IF(
AND(ISPICKVAL(Phase__c, "Completed"), ISPICKVAL(Status__c, "Non-Compliant")),
IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) & $Setup.DPMConfigurationSettings__c.FileURLHelper__c& $Setup.DPMConfigurationSettings__c.STAGEDealerIndicatorCompleteNonComplia__c, ""),
IF(
ISPICKVAL(Phase__c, "Completed"), IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) & $Setup.DPMConfigurationSettings__c.FileURLHelper__c&$Setup.DPMConfigurationSettings__c.STAGEDealerIndicatorCompleteFileId__c, ""), "")))))),


IF( $Setup.CurrentEnvironment__c.Environment__c = "PROD",
IF(
ISPICKVAL(Phase__c, "Open"), IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) & $Setup.DPMConfigurationSettings__c.FileURLHelper__c&$Setup.DPMConfigurationSettings__c.PROD_DealerIndicatorCompletSumaryFileId__c, ""),
IF(
ISPICKVAL(Phase__c, "Started"), IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) & $Setup.DPMConfigurationSettings__c.FileURLHelper__c&$Setup.DPMConfigurationSettings__c.PRODDealerIndicatorAwaitingFileId__c , ""),
IF(
AND(ISPICKVAL(Phase__c, "Completed"), ISPICKVAL(Status__c, "Compliant")),
IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) & $Setup.DPMConfigurationSettings__c.FileURLHelper__c& $Setup.DPMConfigurationSettings__c.PRODDealerIndicatorCompleteCompliant__c, ""),
IF(
AND(ISPICKVAL(Phase__c, "Completed"), ISPICKVAL(Status__c, "Non-Compliant")),
IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) & $Setup.DPMConfigurationSettings__c.FileURLHelper__c& $Setup.DPMConfigurationSettings__c.PRODDealerIndicatorCompleteNonComplian__c, ""),
IF(
ISPICKVAL(Phase__c, "Completed"), IMAGE(LEFT($Api.Partner_Server_URL_260, FIND( '/ser', $Api.Partner_Server_URL_260)) & $Setup.DPMConfigurationSettings__c.FileURLHelper__c&$Setup.DPMConfigurationSettings__c.PRODDealerIndicatorCompleteFileId__c, "Complete"), "")))))
,""))

*/      
        
    }


    
       /**
    * Remove Manual Share if district removed from AP.
    * @param  newActionPlans  list of new Action Plan
    * @param  oldActionPlansMap map of old action plan
    * @return none     
    * @author Vinit [07 Jan 2022] 
    */
     /**
     * [Method Description] Prevent to delete share record with implicit rowcause
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [Minheekim] on [2024-02-29] for [DPM-5411]
    */
    public static void removeManualShareAP(List<Action_Plan__c> newActionPlans, Map<Id, Action_Plan__c> oldActionPlansMap) {
        //DPM-5411 edit query by minhee - 24.02.29
        List<String> rowcause= new List<String>();
        rowcause.add('ImplicitChild');
        rowcause.add('ImplicitParent');
        rowcause.add('Owner');
        rowcause.add('Team');
        rowcause.add('Rule');
        rowcause.add('TerritoryRule');
        //DPM-5411 end
 
        Map<Id,List<Id>> mapOfAltDistrict = new Map<Id,List<Id>>();
        for (Action_Plan__c ap : newActionPlans) {
 
                if (oldActionPlansMap != NULL) {
 
                    if (!mapOfAltDistrict.containsKey(ap.Id)){
                        mapOfAltDistrict.put(ap.Id,new List<Id>());
                    }
 
                    /*if ((ap.DistrictManagerAlt__c != oldActionPlansMap.get(ap.Id).DistrictManagerAlt__c
                        && ap.DistrictManager__c != oldActionPlansMap.get(ap.Id).DistrictManagerAlt__c)
                        || (ap.DistrictManager__c == NULL && ap.DistrictManagerAlt__c == NULL)) {
                        mapOfAltDistrict.get(ap.Id).add(oldActionPlansMap.get(ap.Id).DistrictManagerAlt__c);
                    }
 
                    if ((ap.DistrictPartsServiceManagerAlt__c != oldActionPlansMap.get(ap.Id).DistrictPartsServiceManagerAlt__c
                        && ap.DistrictPartsServiceManager__c != oldActionPlansMap.get(ap.Id).DistrictPartsServiceManagerAlt__c)
                        || (ap.DistrictPartsServiceManager__c == NULL && ap.DistrictPartsServiceManagerAlt__c == NULL)) {
                        mapOfAltDistrict.get(ap.Id).add(oldActionPlansMap.get(ap.Id).DistrictPartsServiceManagerAlt__c);
                    }
 
                    if ((ap.DistrictSalesManagerAlt__c != oldActionPlansMap.get(ap.Id).DistrictSalesManagerAlt__c
                        && ap.DistrictSalesManager__c != oldActionPlansMap.get(ap.Id).DistrictSalesManagerAlt__c)
                        || (ap.DistrictSalesManager__c == NULL && ap.DistrictSalesManagerAlt__c == NULL)) {
                        mapOfAltDistrict.get(ap.Id).add(oldActionPlansMap.get(ap.Id).DistrictSalesManagerAlt__c);
                    }*/
 
                    if ((ap.GenesisMarketManagerAlt__c != oldActionPlansMap.get(ap.Id).GenesisMarketManagerAlt__c
                        && ap.MarketManager__c != oldActionPlansMap.get(ap.Id).GenesisMarketManagerAlt__c)
                        || (ap.MarketManager__c == NULL && ap.GenesisMarketManagerAlt__c == NULL)) {
                        mapOfAltDistrict.get(ap.Id).add(oldActionPlansMap.get(ap.Id).DistrictManagerAlt__c);
                    }
                    if ((ap.Aftersales_Market_Manager__c != oldActionPlansMap.get(ap.Id).Aftersales_Market_Manager__c)
                        || ap.Aftersales_Market_Manager__c == NULL) {
                        mapOfAltDistrict.get(ap.Id).add(oldActionPlansMap.get(ap.Id).Aftersales_Market_Manager__c);
                    }   //Changes for DPM-4188 BY Milind Shinde
                   
                }
        }
 
        if (mapOfAltDistrict.size() > 0) {
            List<Action_Plan__Share> listOfShare = new List<Action_Plan__Share>();
            for (Action_Plan__Share aps : [SELECT Id, userOrGroupId, parentId
                                           FROM Action_Plan__Share
                                           WHERE parentId =:mapOfAltDistrict.keySet() AND RowCause NOT IN :rowcause]) { //DPM-5411 edit query by minhee - 24.02.29
                                     if (aps.userOrGroupId != NULL && mapOfAltDistrict.get(aps.parentId) != NULL
                                         && (mapOfAltDistrict.get(aps.parentId)).size() > 0
                                         && (mapOfAltDistrict.get(aps.parentId)).contains(aps.userOrGroupId))   {
                                            listOfShare.add(aps);
                                     }      
 
            }
            system.debug('getQueries ActionPlanTriggerHelper 683: '+Limits.getQueries());
 
            if (listOfShare.size() > 0) {
                delete listOfShare;
            }
            system.debug('getQueries ActionPlanTriggerHelper 697: '+Limits.getQueries());
        }
 
       
   
       
     }

    /* DPM-4754 evaluation flow call */
    @InvocableMethod(label='ActionPlan Approval Change' description='When Evaluation status is Submitted for Regional Approval')
    public static void handleActionPlanApprovalChange(List<Id> evaluationIds) {
        List<Action_Plan__c> listActionPlans = [SELECT Id, SubmitforApproval__c FROM Action_Plan__c WHERE Evaluation__c IN : evaluationIds];
        for(Action_Plan__c objActionPlan : listActionPlans) {
            objActionPlan.SubmitforApproval__c = true;
        }
        System.debug('listActionPlans ===> '+listActionPlans);
        Action_PlanTriggerHandler.run = false;
        update listActionPlans;
        Action_PlanTriggerHandler.run = true;
    }
    
    
    /**
     * [Method Description] Insert Region Manager when AP is Genesis AP 
     * Created by [Minheekim] on [2024-1-11] for [DPM-5120]
     * Edited by [Minheekim] on [2024-03-18] for [DPM-5426] edit to run when region manager is changed
    */
    public static void insertRegionManager(List<Action_Plan__c> newActionPlans, Map<Id, Action_Plan__c> oldActionPlansMap) {
        //DPM-5426 added to prevent too many query
        List<Action_Plan__c> newAPs = new List<Action_Plan__c>();
        for(Action_Plan__c actionPlan:newActionPlans) {
            if(oldActionPlansMap!=null){
                Action_Plan__c oldActionPlan = oldActionPlansMap.get(actionPlan.Id);
                if(actionPlan.RegionManager__c != oldActionPlan.RegionManager__c) {
                    newAPs.add(actionPlan);
                }  
            }else{
                newAPs.add(actionPlan);
            }        
        }

        if(newAPs.size()>0){ // DPM-5426 end
            List<User> listRM = [SELECT id, name, AccessTypes__c, UserRole.Name, RM_Region_Codes__c FROM user WHERE UserRole.Name like '%Genesis Region Manager%'];
            system.debug('getQueries ActionPlanTriggerHelper 726: '+Limits.getQueries());
            Map<String,User> salesRM = new Map<String,User>();
            Map<String,User> serviceRM = new Map<String,User>();
            if(listRM.size()>0){
                for(User rm: listRM){
                    if(rm.AccessTypes__c!=null){
                        if(rm.AccessTypes__c.contains('GSFOM')){
                            String region = '';
                            List<String> accesstypes = rm.AccessTypes__c.split(',');
                            if(accesstypes.size()>0){
                                for(String accesstype : accesstypes){
                                    if(accesstype.contains('GSFOM')){
                                        region=accesstype.split('_')[2];
                                    }
                                }
                            }
                            salesRM.put(region,rm);
                        }else if(rm.AccessTypes__c.contains('GAFOM')){
                            String region = '';
                            List<String> accesstypes = rm.AccessTypes__c.split(',');
                            if(accesstypes.size()>0){
                                for(String accesstype : accesstypes){
                                    if(accesstype.contains('GAFOM')){
                                        region=accesstype.split('_')[2];
                                    }
                                }
                            }
                            serviceRM.put(region,rm);
                        }
                    }
                        
                }

                for (Action_Plan__c ap : newActionPlans) {
                    if(ap.BrandCode__c == 'G' && ap.Division__c=='Sales' && salesRM.containsKey(ap.RegionCode__c)){
                        ap.RegionManager__c=salesRM.get(ap.RegionCode__c).Id;
                    }else if(ap.BrandCode__c == 'G' && ap.Division__c=='Service' && serviceRM.containsKey(ap.RegionCode__c)){
                        ap.RegionManager__c=serviceRM.get(ap.RegionCode__c).Id;
                    }
                    
                }
            }
        }
    }
     
}