/**
 * Description: [Class BatchProcessObjectShares]
 * (.....)
 * ----- Change Log -----
 * Author : [jonghoonKim] / [10-04-2024] / [DPM-5814] / [Modify the Action Plan And Evaluation add Field IsDealerCommunityVisible__c] 
 * ---------------------------
 */
public without sharing class BatchProcessObjectShares implements Database.Batchable<SObject> {

    public String query;
    public String type;

    public Set<String> accountIds;
    public Set<Id> objectIds;

    public Boolean updateAllObjectsSharing = false;

    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug(LoggingLevel.ERROR, type);
        System.debug('Dhiraj type '+ type);
        if(query== null) {
            if(type == 'Action Plan') {
                query = 'select Id, Account__c,Organization__c, RegionCode__c, ServiceDistrictCode__c, SalesDistrictCode__c, MarketCode__c, OwnerId, Owner.IsActive, CreatedById, CreatedBy.IsActive ';
                query += ' , DistrictPartsServiceManager__c, DistrictPartsServiceManager__r.IsActive, IsDealerCommunityVisible__c '; 
                query += ' , DistrictSalesManager__c, DistrictSalesManager__r.IsActive, MarketManager__c,Aftersales_Market_Manager__r.IsActive, Aftersales_Market_Manager__c,Division__c, MarketManager__r.IsActive, DistrictManager__r.IsActive, DistrictManager__c,DistrictPartsServiceManagerAlt__c,DistrictSalesManagerAlt__c,DistrictManagerAlt__c,GenesisMarketManagerAlt__c,DistrictPartsServiceManagerAlt__r.IsActive,DistrictSalesManagerAlt__r.IsActive,DistrictManagerAlt__r.IsActive,GenesisMarketManagerAlt__r.IsActive from Action_Plan__c where Id != null';

                /*This line Commented by NeeraJ sharma for Story 3453
                * 
                query += ' , DistrictSalesManager__c, DistrictSalesManager__r.IsActive, MarketManager__c,Aftersales_Market_Manager__c,Division__c, MarketManager__r.IsActive, GenesisAreaManager__c, GenesisAreaManager__r.IsActive, DistrictManager__r.IsActive, DistrictManager__c from Action_Plan__c where Id != null';
                */
                if(objectIds != null && !objectIds.isEmpty()) {
                    query += ' and Id in :objectIds';
                }
                if(accountIds != null && !accountIds.isEmpty()) {
                    query += ' and Account__c in :accountIds';
                }
            }
            else if(type == 'Evaluation') {
                query = 'select Id,Organization__c, Account__c, RegionCode__c, ServiceDistrictCode__c, SalesDistrictCode__c, MarketCode__c, OwnerId, Owner.IsActive, CreatedById, CreatedBy.IsActive, DistrictPartsServiceManager__c, DistrictPartsServiceManager__r.IsActive, IsDealerCommunityVisible__c ';
                query += ', DistrictSalesManager__c, DistrictSalesManager__r.IsActive, MarketManager__c,Aftersales_Market_Manager__c,Type__c, MarketManager__r.IsActive,  PrimaryContact__c, DistrictManager__r.IsActive, DistrictManager__c,DistrictPartsServiceManagerAlt__c,DistrictSalesManagerAlt__c,DistrictManagerAlt__c,GenesisMarketManagerAlt__c,DistrictPartsServiceManagerAlt__r.IsActive,DistrictSalesManagerAlt__r.IsActive,DistrictManagerAlt__r.IsActive,GenesisMarketManagerAlt__r.IsActive from Evaluation__c where Id != null ';
                
                /*This line Commented by NeeraJ sharma for Story 3453
                * 
                query += ', DistrictSalesManager__c, DistrictSalesManager__r.IsActive, MarketManager__c,Aftersales_Market_Manager__c,Type__c, MarketManager__r.IsActive, GenesisAreaManager__c, GenesisAreaManager__r.IsActive, PrimaryContact__c, DistrictManager__r.IsActive, DistrictManager__c from Evaluation__c where Id != null ';
                */
                if(objectIds != null && !objectIds.isEmpty()) {
                    query += ' and Id in :objectIds';
                }
                if(accountIds != null && !accountIds.isEmpty()) {
                    query += ' and Account__c in :accountIds';
                }
            }
            else if(type == 'Survey') {
                query = 'select Id,OrganizationName__c, Dealer__c, RegionCode__c, ServiceDistrictCode__c, SalesDistrictCode__c, MarketCode__c, OwnerId, CreatedById, CreatedBy.IsActive, DistrictPartsServiceManager__c, DistrictPartsServiceManager__r.IsActive, PrimaryContact__c';
                query += ', DistrictSalesManager__c, DistrictSalesManager__r.IsActive , MarketManager__c, Aftersales_Market_Manager__c, Division__c, MarketManager__r.IsActive,  DistrictManager__r.IsActive, DistrictManager__c,DistrictPartsServiceManagerAlt__c,DistrictSalesManagerAlt__c,DistrictManagerAlt__c,GenesisMarketManagerAlt__c,DistrictPartsServiceManagerAlt__r.IsActive,DistrictSalesManagerAlt__r.IsActive,DistrictManagerAlt__r.IsActive,GenesisMarketManagerAlt__r.IsActive from Survey__c where Id != null ';

                /*This line Commented by NeeraJ sharma for Story 3453
                * 
                query += ', DistrictSalesManager__c, DistrictSalesManager__r.IsActive , MarketManager__c, Aftersales_Market_Manager__c, Division__c, MarketManager__r.IsActive, GenesisAreaManager__c, GenesisAreaManager__r.IsActive, DistrictManager__r.IsActive, DistrictManager__c from Survey__c where Id != null ';
               
               */
               if(objectIds != null && !objectIds.isEmpty()) {
                    query += ' and Id in :objectIds';
                }
                if(accountIds != null && !accountIds.isEmpty()) {
                    query += ' and Dealer__c in :accountIds';
                }
            }
            else if(type == 'Contact')  {
                //DPM-5979 Added 'DNAMS_Active_User__c' Field by Areum on 12-22-2024
                query = 'select Id, Active_DPM_User__c, DNAMS_Active_User__c, Account.DealerCode__c, Account.RegionCodePicklist__c, Account.ServiceDistrictCodePicklist__c, Account.SalesDistrictCode__c, Account.MarketCodeGenesisPicklist__c, OwnerId, CreatedById, CreatedBy.IsActive, Account.DistrictPartsServiceManager__c, Account.DistrictPartsServiceManager__r.IsActive'; //DPM-5301 changed from DPMActiveUser__c to Active_DPM_User__c by MinheeKim - 2024.05.29
                query += ', Account.DistrictSalesManager__c, Account.DistrictSalesManager__r.IsActive , Account.MarketManager__c,Account.Aftersales_Market_Manager__c, Account.MarketManager__r.IsActive, Account.DistrictManager__c, Account.DistrictManager__r.IsActive from Contact where Id != null ';
                /**This line Commented by NeeraJ sharma for Story 3453
                query += ', Account.DistrictSalesManager__c, Account.DistrictSalesManager__r.IsActive , Account.MarketManager__c,Account.Aftersales_Market_Manager__c, Account.MarketManager__r.IsActive, Account.GenesisAreaManager__c, Account.GenesisAreaManager__r.IsActive, Account.DistrictManager__c, Account.DistrictManager__r.IsActive from Contact where Id != null ';
                */
                if(objectIds != null && !objectIds.isEmpty()) {
                    query += ' and Id in :objectIds';
                }
                if(accountIds != null && !accountIds.isEmpty()) {
                    query += ' and AccountId in :accountIds';
                }
            }

        }
        System.debug(LoggingLevel.ERROR, query);
        return Database.getQueryLocator(query);
    }

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] Added getExistingSharesForObject method to reduce the queries 
    */
    public void execute(Database.BatchableContext BC, List<SObject> objects) {
		System.debug('Dhiraj updateAllObjectsSharing value '+ updateAllObjectsSharing);
        if(type == 'Action Plan') {
            List<Action_Plan__c> actionPlans = (List<Action_Plan__c>) objects;
            Map<Id, Action_Plan__c> actionPlanMap = new Map<Id, Action_Plan__c>();
            for(Action_Plan__c actionPlan:actionPlans) {
                actionPlanMap.put(actionPlan.Id, actionPlan);
            }

            //DPM-5426 change to query Dealer sharing and sharing in once 
            List<String> sharingReason = new List<String>();
            sharingReason.add(Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
            sharingReason.add(Schema.Action_Plan__Share.RowCause.Action_Plan_Sharing__c);
            HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
            Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(actionPlanMap.values(), sharingReason); //DPM-5426 changed to comments by MinheeKim - 24.03.19
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

            ActionPlanService.updateActionPlanSharing(actionPlanMap, internalSharesMap);
            ActionPlanService.createActionPlanDealerSharing(actionPlanMap, dealerSharesMap);
        }
        else if(type == 'Evaluation') {
            List<Evaluation__c> evaluations = (List<Evaluation__c>) objects;
            Map<Id, Evaluation__c> evaluationMap = new Map<Id, Evaluation__c>();
            for(Evaluation__c evaluation:evaluations) {
                evaluationMap.put(evaluation.Id, evaluation);
            }

            //DPM-5426 change to query Dealer sharing and sharing in once 
            List<String> sharingReason = new List<String>();
            sharingReason.add(Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c);
            sharingReason.add(Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
            HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');
            Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(evaluationMap.values(), sharingReason); //DPM-5426 changed to comments by MinheeKim - 24.03.19
            //DPM-5426 devide the sharing as Dealer and internal sharing
            Map<Id, Map<String, SObject>> dealerSharesMap = new Map<Id, Map<String, SObject>>();
            Map<Id, Map<String, SObject>> internalSharesMap = new Map<Id, Map<String, SObject>>();

            for(Id parentId :existingSharesMap.keySet()){
                Map<String, SObject> sharesMap = existingSharesMap.get(parentId);
                for(String key : sharesMap.keySet()){
                    if(sharesMap.get(key).get('RowCause')==Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c){
                        if(!dealerSharesMap.containsKey(parentId)) {
                            dealerSharesMap.put(parentId, new Map<String, SObject>());
                        }
                        dealerSharesMap.get(parentId).put(key, sharesMap.get(key));
                    }else if(sharesMap.get(key).get('RowCause')==Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c){
                        if(!internalSharesMap.containsKey(parentId)) {
                            internalSharesMap.put(parentId, new Map<String, SObject>());
                        }
                        internalSharesMap.get(parentId).put(key, sharesMap.get(key));
                    }

                }

            }
            //DPM-5426 end

            EvaluationService.createEvaluationSharing(evaluationMap, internalSharesMap);
            EvaluationService.createEvaluationDealerSharing(evaluationMap, dealerSharesMap);
        }
        else if(type == 'Survey') {
            List<Survey__c> surveys = (List<Survey__c>) objects;
            Map<Id, Survey__c> surveyMap = new Map<Id, Survey__c>();
            for(Survey__c survey:surveys) {
                surveyMap.put(survey.Id, survey);
            }

             //DPM-5426 change to query Dealer sharing and sharing in once 
             List<String> sharingReason = new List<String>();
             sharingReason.add(Schema.Survey__Share.RowCause.Dealer_Survey_Sharing__c);
             sharingReason.add(Schema.Survey__Share.RowCause.Survey_Sharing__c);
             HMAApexSharing apexSharing = new HMAApexSharing('Survey__Share');
             Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(surveyMap.values(), sharingReason); //DPM-5426 changed to comments by MinheeKim - 24.03.19
             //DPM-5426 devide the sharing as Dealer and internal sharing
             Map<Id, Map<String, SObject>> dealerSharesMap = new Map<Id, Map<String, SObject>>();
             Map<Id, Map<String, SObject>> internalSharesMap = new Map<Id, Map<String, SObject>>();
 
             for(Id parentId :existingSharesMap.keySet()){
                 Map<String, SObject> sharesMap = existingSharesMap.get(parentId);
                 for(String key : sharesMap.keySet()){
                     if(sharesMap.get(key).get('RowCause')==Schema.Survey__Share.RowCause.Dealer_Survey_Sharing__c){
                         if(!dealerSharesMap.containsKey(parentId)) {
                             dealerSharesMap.put(parentId, new Map<String, SObject>());
                         }
                         dealerSharesMap.get(parentId).put(key, sharesMap.get(key));
                     }else if(sharesMap.get(key).get('RowCause')==Schema.Survey__Share.RowCause.Survey_Sharing__c){
                         if(!internalSharesMap.containsKey(parentId)) {
                             internalSharesMap.put(parentId, new Map<String, SObject>());
                         }
                         internalSharesMap.get(parentId).put(key, sharesMap.get(key));
                     }
 
                 }
 
             }
             //DPM-5426 end

            SurveyService.createSurveySharing(surveyMap, internalSharesMap);
            SurveyService.createSurveyDealerSharing(surveyMap, dealerSharesMap);
        }
        else if(type == 'Contact') {
            List<Contact> contacts = (List<Contact>) objects;
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            for(Contact contact:contacts) {
                contactMap.put(contact.Id, contact);
            }

            ContactService.createContactDealerSharing(contactMap);
        }
    }

    public void finish(Database.BatchableContext BC){

        if(updateAllObjectsSharing || Test.isRunningTest()) {
            BatchProcessObjectShares BatchProcessObjectShares = new BatchProcessObjectShares();
            BatchProcessObjectShares.updateAllObjectsSharing = true;
            BatchProcessObjectShares.accountIds = accountIds;
            System.debug(LoggingLevel.ERROR, accountIds);
            if(type == 'Action Plan') {
                BatchProcessObjectShares.type = 'Evaluation';
            }
            else if(type == 'Evaluation') {
                BatchProcessObjectShares.type = 'Survey';
            }
            else if(type == 'Survey') {
                System.debug(LoggingLevel.ERROR, 'survey to contact');
                BatchProcessObjectShares.type = 'Contact';
                BatchProcessObjectShares.updateAllObjectsSharing = false;
            }

            System.debug(LoggingLevel.ERROR, type);
            if(!Test.isRunningTest()) Database.executeBatch(BatchProcessObjectShares, 1);
        }
    }
}