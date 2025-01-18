/**
 * Description: [Class ActionPlanService]
 * (.....)
 * ----- Change Log -----
 * Author : [jonghoonKim] / [10-01-2024] / [DPM-5814] / [Modify the createActionPlanDealerSharing method to execute only when the IsDealerCommunityVisible__c value is True] 
 * ---------------------------
 */
public without sharing class ActionPlanService {

    public static void createActionPlanSharing(Map<Id, Action_Plan__c> newActionPlanMap) {

        Map<Id, List<ObjectAccess__mdt>> mapOfActionPlanToObjectAccess = buildObjectAccessMap(newActionPlanMap.values());
        Set<String> publicGroups = new Set<String>();
        Map<String, Id> publicGroupMap = HMAQueryService.getPublicGroupMapByDeveloperName();

        // DPM-4754 create listActionPlanShares, not use apexSharing
        List<Action_Plan__Share> listActionPlanShares = new List<Action_Plan__Share>();
        for(Action_Plan__c actionPlan:newActionPlanMap.values()) {

            System.debug('actionPlans OwnerId: '+actionPlan.OwnerId);
            System.debug('actionPlans Marketmanager: '+actionPlan.MarketManager__c +' '+actionPlan.MarketManager__r.IsActive);
            
            if(mapOfActionPlanToObjectAccess.containsKey(actionPlan.Id)) {
                for(ObjectAccess__mdt objectAccess:mapOfActionPlanToObjectAccess.get(actionPlan.Id)) {
                    System.debug(objectAccess);
                    System.debug(objectAccess.PublicGroups__c);
                    Id publicGroupId= publicGroupMap.get(objectAccess.PublicGroups__c);
                    //DPM-5031 Temporary change
                    System.debug('publicGroupId: '+publicGroupId);
                    System.debug('actionPlan.Organization__c: '+actionPlan.Organization__c);
                    System.debug('objectAccess.OrganizationName__c: '+objectAccess.OrganizationName__c);
                    if(publicGroupId!=null &&((actionPlan.Organization__c==objectAccess.OrganizationName__c)|| (objectAccess.OrganizationName__c==null))) {
                        Action_Plan__Share objActionPlanShare = new Action_Plan__Share();
                        objActionPlanShare.ParentId = actionPlan.Id;
                        objActionPlanShare.UserOrGroupId = publicGroupId;
                        objActionPlanShare.AccessLevel = objectAccess.AccessLevel__c;
                        objActionPlanShare.RowCause = Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c;
                        listActionPlanShares.add(objActionPlanShare);

                        System.debug('1');
                        System.debug(objActionPlanShare);
                    }
                }
            }

            if(actionPlan.OwnerId != actionPlan.CreatedById && actionPlan.CreatedBy.IsActive) {
                Action_Plan__Share objActionPlanShare = new Action_Plan__Share();
                objActionPlanShare.ParentId = actionPlan.Id;
                objActionPlanShare.UserOrGroupId = actionPlan.CreatedById;
                objActionPlanShare.AccessLevel = 'Edit';
                objActionPlanShare.RowCause = Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c;
                listActionPlanShares.add(objActionPlanShare);
                System.debug('2');
                System.debug(objActionPlanShare);
            }

            if(actionPlan.OwnerId != actionPlan.DistrictPartsServiceManager__c && actionPlan.DistrictPartsServiceManager__c !=null && actionPlan.DistrictPartsServiceManager__r.IsActive) {
                Action_Plan__Share objActionPlanShare = new Action_Plan__Share();
                objActionPlanShare.ParentId = actionPlan.Id;
                objActionPlanShare.UserOrGroupId = actionPlan.DistrictPartsServiceManager__c;
                objActionPlanShare.AccessLevel = 'Edit';
                objActionPlanShare.RowCause = Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c;
                listActionPlanShares.add(objActionPlanShare);
                System.debug('3');
                System.debug(objActionPlanShare);
            }

            if(actionPlan.OwnerId != actionPlan.DistrictSalesManager__c && actionPlan.DistrictSalesManager__c !=null && actionPlan.DistrictSalesManager__r.IsActive) {
                Action_Plan__Share objActionPlanShare = new Action_Plan__Share();
                objActionPlanShare.ParentId = actionPlan.Id;
                objActionPlanShare.UserOrGroupId = actionPlan.DistrictSalesManager__c;
                objActionPlanShare.AccessLevel = 'Edit';
                objActionPlanShare.RowCause = Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c;
                listActionPlanShares.add(objActionPlanShare);
                System.debug('4');
                System.debug(objActionPlanShare);
            }

            if(actionPlan.OwnerId != actionPlan.Aftersales_Market_Manager__c && actionPlan.Aftersales_Market_Manager__c !=null && actionPlan.Division__c == 'Service' && actionPlan.Aftersales_Market_Manager__r.IsActive) {
                Action_Plan__Share objActionPlanShare = new Action_Plan__Share();
                objActionPlanShare.ParentId = actionPlan.Id;
                objActionPlanShare.UserOrGroupId = actionPlan.Aftersales_Market_Manager__c;
                objActionPlanShare.AccessLevel = 'Edit';
                objActionPlanShare.RowCause = Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c;
                listActionPlanShares.add(objActionPlanShare);
                System.debug('5');
                System.debug(objActionPlanShare);
            }
            
            if(actionPlan.OwnerId != actionPlan.MarketManager__c && actionPlan.MarketManager__c !=null  && actionPlan.Division__c == 'Sales' && actionPlan.MarketManager__r.IsActive) {
                Action_Plan__Share objActionPlanShare = new Action_Plan__Share();
                objActionPlanShare.ParentId = actionPlan.Id;
                objActionPlanShare.UserOrGroupId = actionPlan.MarketManager__c;
                objActionPlanShare.AccessLevel = 'Edit';
                objActionPlanShare.RowCause = Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c;
                listActionPlanShares.add(objActionPlanShare);
                System.debug('6');
                System.debug(objActionPlanShare);
            }

            if(actionPlan.OwnerId != actionPlan.GenesisMarketManagerAlt__c && actionPlan.GenesisMarketManagerAlt__c !=null && actionPlan.GenesisMarketManagerAlt__r.IsActive) {
                Action_Plan__Share objActionPlanShare = new Action_Plan__Share();
                objActionPlanShare.ParentId = actionPlan.Id;
                objActionPlanShare.UserOrGroupId = actionPlan.GenesisMarketManagerAlt__c;
                objActionPlanShare.AccessLevel = 'Edit';
                objActionPlanShare.RowCause = Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c;
                listActionPlanShares.add(objActionPlanShare);
                System.debug('7');
                System.debug(objActionPlanShare);
            }

            if(actionPlan.OwnerId != actionPlan.DistrictManager__c && actionPlan.DistrictManager__c != null && actionPlan.DistrictManager__r.IsActive) {
                Action_Plan__Share objActionPlanShare = new Action_Plan__Share();
                objActionPlanShare.ParentId = actionPlan.Id;
                objActionPlanShare.UserOrGroupId = actionPlan.DistrictManager__c;
                objActionPlanShare.AccessLevel = 'Edit';
                objActionPlanShare.RowCause = Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c;
                listActionPlanShares.add(objActionPlanShare);
                System.debug('8');
                System.debug(objActionPlanShare);
            }
        }
        System.debug(LoggingLevel.ERROR, 'Limits.getQueries(); ' + Limits.getQueries());

        insert listActionPlanShares;
    }

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] Added parameter Map<Id, Map<String, SObject>> existingSharesMap to reduce the queries 
    */
    public static void updateActionPlanSharing(Map<Id, Action_Plan__c> newActionPlanMap, Map<Id, Map<String, SObject>> existingSharesMap) {  //DPM-5426 added Map<Id, Map<String, SObject>> existingSharesMap by minheekim - 24.03.19

        Map<Id, List<ObjectAccess__mdt>> mapOfActionPlanToObjectAccess = buildObjectAccessMap(newActionPlanMap.values());
        Set<String> publicGroups = new Set<String>();
        System.debug('Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c : '+Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        // Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(newActionPlanMap.values(), Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c); //DPM-5426 changed to comment by MinheeKim - 24.03.19

        /*for(Action_Plan__c actionPlan:newActionPlanMap.values()) {
            for(ObjectAccess__mdt objectAccess:HMAQueryService.getObjectAccessTypes(actionPlan, 'Action_Plan__c')) {
                if(!mapOfActionPlanToObjectAccess.containsKey(actionPlan.Id)) {
                    mapOfActionPlanToObjectAccess.put(actionPlan.Id, new List<ObjectAccess__mdt>());
                }
                mapOfActionPlanToObjectAccess.get(actionPlan.Id).add(objectAccess);
                publicGroups.add(objectAccess.PublicGroups__c);
            }
        }*/

        Map<String, Id> publicGroupMap = HMAQueryService.getPublicGroupMapByDeveloperName();

        for(Action_Plan__c actionPlan:newActionPlanMap.values()) {
            if(mapOfActionPlanToObjectAccess.containsKey(actionPlan.Id)) {
                for(ObjectAccess__mdt objectAccess:mapOfActionPlanToObjectAccess.get(actionPlan.Id)) {

                    if(existingSharesMap.containsKey(actionPlan.Id)) {
                        if(existingSharesMap.get(actionPlan.Id).containsKey(objectAccess.PublicGroups__c)) {
                            if((actionPlan.Organization__c==objectAccess.OrganizationName__c)|| (objectAccess.OrganizationName__c==null))
                                existingSharesMap.get(actionPlan.Id).remove(objectAccess.PublicGroups__c);
                            //continue;
                        }
                    }

                    Id publicGroupId= publicGroupMap.get(objectAccess.PublicGroups__c);
                    //if((actionPlan.Organization__c).equalsIgnoreCase(objectAccess.OrganizationName__c))
                    if((actionPlan.Organization__c==objectAccess.OrganizationName__c)|| (objectAccess.OrganizationName__c==null))
                        apexSharing.add(actionPlan, publicGroupId, objectAccess.AccessLevel__c, Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }
            if(actionPlan.OwnerId != actionPlan.CreatedById) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.CreatedById)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.CreatedById);
                        //continue;
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.CreatedById, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(actionPlan, actionPlan.CreatedById, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }
            if(actionPlan.OwnerId != actionPlan.DistrictPartsServiceManager__c && actionPlan.DistrictPartsServiceManager__c !=null) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.DistrictPartsServiceManager__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.DistrictPartsServiceManager__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.DistrictPartsServiceManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(actionPlan, actionPlan.DistrictPartsServiceManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }
            /* if(actionPlan.OwnerId != actionPlan.DistrictPartsServiceManagerAlt__c && actionPlan.DistrictPartsServiceManagerAlt__c !=null) {
                 if(existingSharesMap.containsKey(actionPlan.Id)) {
                     if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.DistrictPartsServiceManagerAlt__c)) {
                         existingSharesMap.get(actionPlan.Id).remove(actionPlan.DistrictPartsServiceManagerAlt__c);
                         //continue;
                     }
                     else {
                         apexSharing.add(actionPlan, actionPlan.DistrictPartsServiceManagerAlt__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                     }
                 }
                 else {
                     apexSharing.add(actionPlan, actionPlan.DistrictPartsServiceManagerAlt__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                 }
             }*/
            if(actionPlan.OwnerId != actionPlan.DistrictSalesManager__c && actionPlan.DistrictSalesManager__c !=null) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.DistrictSalesManager__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.DistrictSalesManager__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.DistrictSalesManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(actionPlan, actionPlan.DistrictSalesManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }
            /*if(actionPlan.OwnerId != actionPlan.DistrictSalesManagerAlt__c && actionPlan.DistrictSalesManagerAlt__c !=null) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.DistrictSalesManagerAlt__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.DistrictSalesManagerAlt__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.DistrictSalesManagerAlt__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(actionPlan, actionPlan.DistrictSalesManagerAlt__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }*/
            if(actionPlan.OwnerId != actionPlan.Aftersales_Market_Manager__c && actionPlan.Aftersales_Market_Manager__c !=null && actionPlan.Division__c == 'Service') {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.Aftersales_Market_Manager__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.Aftersales_Market_Manager__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.Aftersales_Market_Manager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(actionPlan, actionPlan.Aftersales_Market_Manager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }

            if(actionPlan.OwnerId != actionPlan.MarketManager__c && actionPlan.MarketManager__c !=null  && actionPlan.Division__c == 'Sales') {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.MarketManager__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.MarketManager__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.MarketManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(actionPlan, actionPlan.MarketManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }
            if(actionPlan.OwnerId != actionPlan.GenesisMarketManagerAlt__c && actionPlan.GenesisMarketManagerAlt__c !=null) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.GenesisMarketManagerAlt__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.GenesisMarketManagerAlt__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.GenesisMarketManagerAlt__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(actionPlan, actionPlan.GenesisMarketManagerAlt__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }

            if(actionPlan.OwnerId != actionPlan.DistrictManager__c && actionPlan.DistrictManager__c != null && actionPlan.DistrictManager__r.IsActive) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.DistrictManager__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.DistrictManager__c);
                        //continue;
                    }
                    else{
                        apexSharing.add(actionPlan, actionPlan.DistrictManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(actionPlan, actionPlan.DistrictManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }
            /* if(actionPlan.OwnerId != actionPlan.DistrictManagerAlt__c && actionPlan.DistrictManagerAlt__c != null && actionPlan.DistrictManagerAlt__r.IsActive) {

                 if(existingSharesMap.containsKey(actionPlan.Id)) {
                     if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.DistrictManagerAlt__c)) {
                         existingSharesMap.get(actionPlan.Id).remove(actionPlan.DistrictManagerAlt__c);
                         //continue;
                     }
                     else{
                         apexSharing.add(actionPlan, actionPlan.DistrictManagerAlt__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                     }
                 }
                 else {
                     apexSharing.add(actionPlan, actionPlan.DistrictManagerAlt__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                 }
             }*/
/*/* following code is commented by neeraj for 3523 ticket
            if(actionPlan.OwnerId != actionPlan.GenesisAreaManager__c && actionPlan.GenesisAreaManager__c !=null) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.GenesisAreaManager__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.GenesisAreaManager__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.GenesisAreaManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(actionPlan, actionPlan.GenesisAreaManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }*/

        }
        apexSharing.share();
        if(!existingSharesMap.keySet().isEmpty()) {
            for(Id actionPlanId:existingSharesMap.keySet()) {
                if(!existingSharesMap.get(actionPlanId).keySet().isEmpty()) {
                    for(String groupDeveloperName:existingSharesMap.get(actionPlanId).keySet()) {
                        Action_Plan__Share shareToRemove = (Action_Plan__Share) existingSharesMap.get(actionPlanId).get(groupDeveloperName);
                        apexSharing.remove(new Action_Plan__c(Id = actionPlanId), shareToRemove.UserOrGroupId, shareToRemove.AccessLevel, Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
            }
        }
        apexSharing.unshare();
    }

    /*public static void recalculateActionPlanSharing(List<Action_Plan__c> updatedActionPlans) {

        Map<Id, List<ObjectAccess__mdt>> mapOfActionPlanToObjectAccess = buildObjectAccessMap(updatedActionPlans);
        Set<String> publicGroups = new Set<String>();

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(updatedActionPlans, Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);


        Map<String, Id> publicGroupMap = HMAQueryService.getPublicGroupMapByDeveloperName();
        for(Action_Plan__c actionPlan:updatedActionPlans) {
            if(mapOfActionPlanToObjectAccess.containsKey(actionPlan.Id)) {
                for(ObjectAccess__mdt objectAccess:mapOfActionPlanToObjectAccess.get(actionPlan.Id)) {
                    if(existingSharesMap.containsKey(actionPlan.Id)) {
                        if(existingSharesMap.get(actionPlan.Id).containsKey(objectAccess.PublicGroups__c)) {
                            existingSharesMap.get(actionPlan.Id).remove(objectAccess.PublicGroups__c);
                            continue;
                        }
                    }
                    Id publicGroupId= publicGroupMap.get(objectAccess.PublicGroups__c);
                    apexSharing.add(actionPlan, publicGroupId, objectAccess.AccessLevel__c, Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                }
            }
            if(actionPlan.OwnerId != actionPlan.CreatedById) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.CreatedById)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.CreatedById);
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.CreatedById, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
            }
            if(actionPlan.OwnerId != actionPlan.DistrictPartsServiceManager__c && actionPlan.DistrictPartsServiceManager__c != null) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.DistrictPartsServiceManager__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.DistrictPartsServiceManager__c);
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.DistrictPartsServiceManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
            }
            if(actionPlan.OwnerId != actionPlan.DistrictSalesManager__c && actionPlan.DistrictSalesManager__c != null) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.DistrictSalesManager__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.DistrictSalesManager__c);
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.DistrictSalesManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
            }
            if(actionPlan.OwnerId != actionPlan.MarketManager__c && actionPlan.MarketManager__c != null) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.MarketManager__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.MarketManager__c);
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.MarketManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
            }
            if(actionPlan.OwnerId != actionPlan.GenesisAreaManager__c && actionPlan.GenesisAreaManager__c != null) {
                if(existingSharesMap.containsKey(actionPlan.Id)) {
                    if(existingSharesMap.get(actionPlan.Id).containsKey(actionPlan.GenesisAreaManager__c)) {
                        existingSharesMap.get(actionPlan.Id).remove(actionPlan.GenesisAreaManager__c);
                    }
                    else {
                        apexSharing.add(actionPlan, actionPlan.GenesisAreaManager__c, 'Edit', Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
            }
        }

        apexSharing.share();

        if(!existingSharesMap.keySet().isEmpty()) {
            for(Id actionPlanId:existingSharesMap.keySet()) {
                if(!existingSharesMap.get(actionPlanId).keySet().isEmpty()) {
                    for(String groupDeveloperName:existingSharesMap.get(actionPlanId).keySet()) {
                        Action_Plan__Share shareToRemove = (Action_Plan__Share) existingSharesMap.get(actionPlanId).get(groupDeveloperName);
                        apexSharing.remove(new Action_Plan__c(Id = actionPlanId), shareToRemove.UserOrGroupId, shareToRemove.AccessLevel, Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
                    }
                }
            }
        }
        apexSharing.unshare();
    }*/

    public static Map<Id, List<ObjectAccess__mdt>> buildObjectAccessMap(List<Action_Plan__c> actionPlans) {
        Map<Id, List<ObjectAccess__mdt>> actionPlanAccessTypeMap = new Map<Id, List<ObjectAccess__mdt>>();

        List<String> regionCodes = new List<String>();
        List<String> salesDistrictCodes = new List<String>();
        List<String> serviceDistrictCodes = new List<String>();
        List<String> marketCodes = new List<String>();

        Map<String, List<ObjectAccess__mdt>> regionObjectAccessTypes;
        Map<String, List<ObjectAccess__mdt>> serviceDistrictObjectAccessTypes;
        Map<String, List<ObjectAccess__mdt>> salesDistrictObjectAccessTypes;
        Map<String, List<ObjectAccess__mdt>> marketObjectAccessTypes;

        for(Action_Plan__c actionPlan:actionPlans) {
            if(!String.isBlank(actionPlan.RegionCode__c)) {
                regionCodes.add(actionPlan.RegionCode__c);
            }
            if(!String.isBlank(actionPlan.ServiceDistrictCode__c)) {
                serviceDistrictCodes.add(actionPlan.ServiceDistrictCode__c);
            }
            if(!String.isBlank(actionPlan.SalesDistrictCode__c)) {
                salesDistrictCodes.add(actionPlan.SalesDistrictCode__c);
            }
            if(!String.isBlank(actionPlan.MarketCode__c)) {
                marketCodes.add(actionPlan.MarketCode__c);
            }
        }
        System.debug(regionCodes);
        System.debug(serviceDistrictCodes);
        System.debug(salesDistrictCodes);
        System.debug(marketCodes);

        if(!regionCodes.isEmpty()) {
            regionObjectAccessTypes = HMAQueryService.getObjectAccessTypes('Region', 'Action_Plan__c', regionCodes);
        }

        if(!serviceDistrictCodes.isEmpty()) {
            serviceDistrictObjectAccessTypes = HMAQueryService.getObjectAccessTypes('District', 'Action_Plan__c', serviceDistrictCodes);
        }

        if(!salesDistrictCodes.isEmpty()) {
            salesDistrictObjectAccessTypes = HMAQueryService.getObjectAccessTypes('District', 'Action_Plan__c', salesDistrictCodes);
        }

        if(!marketCodes.isEmpty()) {
            marketObjectAccessTypes = HMAQueryService.getObjectAccessTypes('Market', 'Action_Plan__c', marketCodes);
        }
        System.debug(regionObjectAccessTypes);
        System.debug(serviceDistrictObjectAccessTypes);
        System.debug(salesDistrictObjectAccessTypes);
        System.debug(marketObjectAccessTypes);

        for(Action_Plan__c actionPlan:actionPlans) {
            if(!actionPlanAccessTypeMap.containsKey(actionPlan.Id)) {
                actionPlanAccessTypeMap.put(actionPlan.Id, new List<ObjectAccess__mdt>());
            }

            if(!String.isBlank(actionPlan.RegionCode__c) && regionObjectAccessTypes.containsKey(actionPlan.RegionCode__c)) {
                actionPlanAccessTypeMap.get(actionPlan.Id).addAll(regionObjectAccessTypes.get(actionPlan.RegionCode__c));
            }

            if(!String.isBlank(actionPlan.ServiceDistrictCode__c) && serviceDistrictObjectAccessTypes.containsKey(actionPlan.ServiceDistrictCode__c)) {
                actionPlanAccessTypeMap.get(actionPlan.Id).addAll(serviceDistrictObjectAccessTypes.get(actionPlan.ServiceDistrictCode__c));
            }

            if(!String.isBlank(actionPlan.SalesDistrictCode__c) && salesDistrictObjectAccessTypes.containsKey(actionPlan.SalesDistrictCode__c)) {
                actionPlanAccessTypeMap.get(actionPlan.Id).addAll(salesDistrictObjectAccessTypes.get(actionPlan.SalesDistrictCode__c));
            }

            if(!String.isBlank(actionPlan.MarketCode__c) && marketObjectAccessTypes.containsKey(actionPlan.MarketCode__c)) {
                actionPlanAccessTypeMap.get(actionPlan.Id).addAll(marketObjectAccessTypes.get(actionPlan.MarketCode__c));
            }
            System.debug(actionPlanAccessTypeMap);

        }
        return actionPlanAccessTypeMap;
    }

    public static Map<String, AccessType__mdt> getAccessTypeMap() {

        Map<String, AccessType__mdt> accessTypeMap = new Map<String, AccessType__mdt>();
        //DPM-5093 add condition to check active of AccessType_mdt - by MH - 2023.10.27
        for(AccessType__mdt accessType:[select Id, DeveloperName, ObjectAccessAPINames__c from AccessType__mdt where Active__c=true]) {

            System.debug(LoggingLevel.ERROR, accessType);
            accessTypeMap.put(accessType.DeveloperName, accessType);
        }
        return accessTypeMap;
    }

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] Added parameter Map<Id, Map<String, SObject>> existingSharesMap to reduce the queries
     * Edited by [Jonghoon Kim] on [10-01-2024] for [DPM-5814] Add showDealerCommunity 
    */
    public static void createActionPlanDealerSharing(Map<Id, Action_Plan__c> newActionPlanMap, Map<Id, Map<String, SObject>> existingSharesMap) { //DPM-5426 added Map<Id, Map<String, SObject>> existingSharesMap by MinheeKim - 24.03.19
        try {
            // DPM - 5814 
            Boolean showDealerCommunity = false;
            for (Action_Plan__c ap : newActionPlanMap.values()) {
                if (ap.IsDealerCommunityVisible__c) {
                    showDealerCommunity = true;
                    break;
                }
            }
    
            if (showDealerCommunity) {

                Map<Id, List<Action_Plan__c>> accountActionPlanMap = new  Map<Id, List<Action_Plan__c>>();

                for(Action_Plan__c actionPlan:newActionPlanMap.values()) {
                    if(!accountActionPlanMap.containsKey(actionPlan.Account__c)) {
                        accountActionPlanMap.put(actionPlan.Account__c, new List<Action_Plan__c>());
                    }
                    accountActionPlanMap.get(actionPlan.Account__c).add(actionPlan);
                }

                Map<Id, Account> accountMap = new Map<Id, Account>([select Id, DealerCode__c from Account where Id in :accountActionPlanMap.keyset()]);
                Map<Id, List<User>> accountUserMap = getAccountContactsMap(accountActionPlanMap.keySet());

                Map<String, ObjectAccess__mdt> actionPlanAccessTypes = getObjectAccessMapForActionPlans();
                Map<String, AccessType__mdt> accessTypesMap = getAccessTypeMap();

                HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
                // Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(newActionPlanMap.values(), Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c); //DPM-5426 changed to comments by MinheeKim - 24.03.19

                for(Action_Plan__c actionPlan:newActionPlanMap.values()) {
                    Account actionPlanAccount = accountMap.get(actionPlan.Account__c);
                    if(accountUserMap.containsKey(actionPlan.Account__c)) {
                        for(User dealerUser:accountUserMap.get(actionPlan.Account__c)) {
                            Boolean processed = false;
                            if(dealerUser.AccessTypes__c != null) {
                                for(String accessType:dealerUser.AccessTypes__c.split(',')) {
                                    if(accessType.contains('/') && accessType.contains(actionPlanAccount.DealerCode__c)) {
                                        String[] dealerAccessType = accessType.split('/');

                                        if(accessTypesMap.containsKey(dealerAccessType[0])) {
                                            
                                            String objectAccessAPINames = accessTypesMap.get(dealerAccessType[0]).ObjectAccessAPINames__c;
                                            
                                            if(!String.isBlank(objectAccessAPINames)) {
                                                for(String objectAccessAPIName:objectAccessAPINames.split(',')) {
                                                    if(actionPlanAccessTypes.containsKey(objectAccessAPIName)){
                                                        if(existingSharesMap.containsKey(actionPlan.Id)) {
                                                            if(existingSharesMap.get(actionPlan.Id).containsKey(dealerUser.Id)) {
                                                                existingSharesMap.get(actionPlan.Id).remove(dealerUser.Id);
                                                                processed = true;
                                                                break;
                                                            }
                                                        }

                                                        System.debug('Dealer User: '+dealerUser.Id);
                                                        System.debug('Dealer AccessType: '+accessTypesMap.get(dealerAccessType[0])+accessTypesMap.get(dealerAccessType[1]));
                                                        System.debug('Dealer objectAccessAPINames: '+objectAccessAPINames);
                                                        apexSharing.add(actionPlan, dealerUser.Id, actionPlanAccessTypes.get(objectAccessAPIName).AccessLevel__c, Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
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
                apexSharing.share();
            }
        } catch (Exception e) {
            System.debug('Error occurred while processing dealer sharing: ' + e.getMessage());
        }    
    }

    private static Map<String, ObjectAccess__mdt> getObjectAccessMapForActionPlans() {

        Map<String, ObjectAccess__mdt> objectAccessMap = new Map<String, ObjectAccess__mdt>();
        for(ObjectAccess__mdt objectAccess:[select Id, AccessLevel__c, ObjectAPINames__c, DeveloperName from ObjectAccess__mdt where Active__c = true ]) {
            if(objectAccess.ObjectAPINames__c.contains('Action_Plan__c')) {
                objectAccessMap.put(objectAccess.DeveloperName, objectAccess);
            }
        }
        return objectAccessMap;
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

    public static void rollupActionPlansForEvaluations(Set<Id> evaluationIds) {

        Map<Id, Evaluation__c> evaluationsMap = new Map<Id, Evaluation__c>();

        for(Id evaluationId:evaluationIds) {
            if(!evaluationsMap.containsKey(evaluationId)){
                //Dhiraj changes of_Non_Compliant_Action_Plans__c =0 and NumofCompliantActionPlans__c =0 i have change it to 1
                Evaluation__c eval = new Evaluation__c(Id = evaluationId, Total_of_Related_Action_Plans__c = 0, of_Completed_Action_Plans__c = 0, of_Non_Compliant_Action_Plans__c = 0, NumofCompliantActionPlans__c = 0, NumofDistrictSubmittedActionPlans__c = 0, NumofRegionSubmittedActionPlans__c = 0, Numof_CarryOver_Action_Plans__c = 0);
                eval.NumofRegionApprovedActionPlans__c = 0;
                eval.NumofDistrictApprovedActionPlans__c = 0;
                eval.NumofSentBackActionPlans__c = 0;
                evaluationsMap.put(evaluationId, eval);
            }
        }


        for(Action_Plan__c actionPlan:[select Id, Evaluation__c, Status__c, ApprovalStatus__c from Action_Plan__c where Evaluation__c in :evaluationIds]) {
            Evaluation__c evaluationTRollup = evaluationsMap.get(actionPlan.Evaluation__c);
            evaluationTRollup.Total_of_Related_Action_Plans__c++;


            if(actionPlan.Status__c == 'Completed') {
                evaluationTRollup.of_Completed_Action_Plans__c++;
            }
            else if(actionPlan.Status__c == 'Non-Compliant') {
                evaluationTRollup.of_Non_Compliant_Action_Plans__c++;
            }
            else if(actionPlan.Status__c == 'Compliant') {
                evaluationTRollup.NumofCompliantActionPlans__c++;
            } else if (actionPlan.Status__c == 'Carry Over' && actionPlan.ApprovalStatus__c != 'District Approved') {
                evaluationTRollup.Numof_CarryOver_Action_Plans__c++;
            }

            if(actionPlan.ApprovalStatus__c == 'Submitted for District Approval') {
                evaluationTRollup.NumofDistrictSubmittedActionPlans__c++;
            }
//            following code is commented by neeraj for 3523 ticket
//            else if(actionPlan.ApprovalStatus__c == 'Submitted for Regional Approval' || actionPlan.ApprovalStatus__c == 'Submitted for Genesis Area Approval') {

            else if(actionPlan.ApprovalStatus__c == 'Submitted for Regional Approval') {
                evaluationTRollup.NumofRegionSubmittedActionPlans__c++;
            }

//            following code is commented by neeraj for 3523 ticket
//            else if(actionPlan.ApprovalStatus__c == 'Region Approved' ||  actionPlan.ApprovalStatus__c == 'Genesis Area Approved') {

            else if(actionPlan.ApprovalStatus__c == 'Region Approved' ) {
                evaluationTRollup.NumofRegionApprovedActionPlans__c++;
            }
            else if(actionPlan.ApprovalStatus__c == 'District Approved') {
                evaluationTRollup.NumofDistrictApprovedActionPlans__c++;
            }
            else if(actionPlan.ApprovalStatus__c == 'Sent Back' || actionPlan.ApprovalStatus__c == 'Sent Back To Dealer') {
                evaluationTRollup.NumofSentBackActionPlans__c++;
            }
        }
        for(Evaluation__c ev : evaluationsMap.Values())
        {

            //Changes made by Dhiraj starts here
            if(ev.of_Non_Compliant_Action_Plans__c==0){
                //ev.NumofCompliantActionPlans__c++;
            }else if(ev.NumofCompliantActionPlans__c==0){
                //ev.of_Non_Compliant_Action_Plans__c++;
            }else{
                //ev.of_Non_Compliant_Action_Plans__c++;
            }

            //Changes made by Dhiraj ends here

        }

        if(!evaluationsMap.values().isEmpty()) {
            //EvaluationTriggerHandler.run = false;
            update evaluationsMap.values();
            //EvaluationTriggerHandler.run = true;
        }
    }

    /**
     * [Method Description] get active user among action plans' owner
     * Created by [MinheeKim] on [2024-05-01] for [DPM-5400] Get active action plans' owners
    */
    public static Map<Id, User> getUserMapFromActionPlans(List<Action_Plan__c> actionplans) {
        List<User> userList = new List<User>();
        List<Id> userIdList = new List<Id>();
        for(Action_Plan__c ap:actionplans) {
            if(ap.OwnerId != null) {
                userIdList.add(ap.OwnerId);
            }
        }

        Map<Id, User> UserIdMap = new Map<Id, User>();
        for(User user:[select Id, Profile.Name, IsActive from User where Id in :userIdList ]) {
            UserIdMap.put(user.Id, user);
        }
        return UserIdMap;
    }
}