public without sharing class SurveyTriggerHelper {
 
    public static void handleCompletedSurveyUpdate(List<Survey__c> newSurveys, Map<Id, Survey__c> oldSurveyMap) {
        Set<Id> surveyIds = new Set<Id>();
        for(Survey__c newSurvey:newSurveys) {
            Survey__c oldSurvey = oldSurveyMap.get(newSurvey.Id);
            if(newSurvey.Status__c == 'Completed' && oldSurvey.Status__c != 'Completed') {
                surveyIds.add(newSurvey.Id);
            }
        }
        if(!surveyIds.isEmpty()) {
            SurveyTriggerHelper.updateTotalPercent(surveyIds);
        }
    }

    @future
    public static void updateTotalPercent(Set<Id> surveyIds) {

        List<Survey__c> surveysToUpdate = [select Total_Score__c from Survey__c where Id in :surveyIds];
    
        for(Survey__c survey:surveysToUpdate) {
            survey.Completed_Total_Score__c = survey.Total_Score__c;
        }

        SurveyTriggerHandler.run = false;
        update surveysToUpdate;
        SurveyTriggerHandler.run = true;
    }

    public static void populateSurveyFromAccount(List<Survey__c> surveys,Map<Id, Survey__c> oldSurveyMap) {

        Set<Id> accountIds = new Set<Id>();
        set<id> regionIds= new set<Id>();
        Map<id,Region__c> regionsMap = new Map<id,Region__c>();
        for(Survey__c survey:surveys) {
            if(survey.Dealer__c != null) {
                accountIds.add(survey.Dealer__c);
            }
           
        }
      /*  if(survey.RegionRef__c!=null)
        regionIds.add(survey.RegionRef__c);
        if(regionIds.size()>0){
           
            for(Region__c reg : [select id,RegionCode__c,Name from Region__c where id in:regionIds]){
             regionsMap.put(reg.id,reg);
            }
         
         }*/

        List<Id> genesisAreas = new List<Id>();
        List<Survey__c> genesisSurveys = new List<Survey__c>();
        Map<Id, Account> accountMap = HMAQueryService.getAccountMapFromSetOfAccountIds(accountIds);
        system.debug('getQueries HMAQueryService 77: '+Limits.getQueries());
        for(Survey__c survey:surveys) {

            if(survey.Dealer__c != null) {

                Account surveyAccount = accountMap.get(survey.Dealer__c);

                if(surveyAccount != null) {
                    survey.OrganizationRef__c = surveyAccount.Organization__c;
                    survey.OrganizationName__c = surveyAccount.Organization__r.Name;
                    survey.DealerCode__c = surveyAccount.DealerCode__c;
                    //survey.GeneralManager__c = surveyAccount.GeneralManager__c;
                    //survey.DealerPrincipal__c = surveyAccount.DealerPrincipal__c;
                    if(surveyAccount.Name.contains('-')) {
                        survey.DealerName__c = surveyAccount.Name.split('-')[1].trim();
                    }
                    else {
                        survey.DealerName__c = surveyAccount.Name;
                    }
                    system.debug(' test '+ (survey.RegionRef__c));
                    system.debug(' test '+ (surveyAccount.Region__c));

                    if(surveyAccount.RecordType.DeveloperName == 'HyundaiDealer' || surveyAccount.RecordType.DeveloperName == 'GenesisRetailer'){
                        if(oldSurveyMap != NULL && oldSurveyMap.containsKey(survey.id) && oldSurveyMap.containsKey(survey.id) != NULL 
                        && survey.RegionRef__c!=surveyAccount.Region__c ){
                            survey.RegionRef__c = surveyAccount.Region__c;
                            survey.RegionCode__c = surveyAccount.Region__r.RegionCode__c;
                            survey.RegionName__c = surveyAccount.Region__r.Name;
                           }
                           else{
                        survey.RegionRef__c = surveyAccount.Region__c;
                        survey.RegionCode__c = surveyAccount.Region__r.RegionCode__c;
                        survey.RegionName__c = surveyAccount.Region__r.Name;
                           }
                        survey.ServiceDistrict__c = surveyAccount.ServiceDistrict__c;
                        if(survey.ServiceDistrict__c != null) {
                            survey.ServiceDistrictName__c = surveyAccount.ServiceDistrict__r.DistrictCode__c + ' - ' + surveyAccount.ServiceDistrict__r.Name;
                            survey.ServiceDistrictCode__c = surveyAccount.ServiceDistrict__r.DistrictCode__c;
                        }
                        survey.DistrictPartsServiceManager__c = surveyAccount.ServiceDistrict__r.DistrictPartsServiceManager__c;
                        survey.DistrictPartsServiceManagerAlt__c = surveyAccount.ServiceDistrict__r.DistrictPartsServiceManagerAlt__c;

                        survey.SalesDistrict__c = surveyAccount.SalesDistrict__c;
                        if(survey.SalesDistrict__c != null) {
                            survey.SalesDistrictName__c = surveyAccount.SalesDistrict__r.DistrictCode__c + ' - ' + surveyAccount.SalesDistrict__r.Name;
                            survey.SalesDistrictCode__c = surveyAccount.SalesDistrict__r.DistrictCode__c;
                        }
                        survey.DistrictSalesManager__c = surveyAccount.SalesDistrict__r.SalesManager__c;
                        survey.DistrictSalesManagerAlt__c = surveyAccount.SalesDistrict__r.DistrictSalesManagerAlt__c;

                            if(surveyAccount.Market__c!=null){
                                survey.Market__c = surveyAccount.Market__c;
                        survey.MarketCode__c = surveyAccount.Market__r.DistrictCode__c;
						survey.Aftersales_Market_Manager__c = surveyAccount.Market__r.Aftersales_Market_Manager__c;
                        survey.MarketManager__c = surveyAccount.Market__r.MarketManager__c;
                        survey.GenesisMarketManagerAlt__c = surveyAccount.Market__r.GenesisMarketManagerAlt__c;
                        
                            }
                        //actionPlan.OwnerId = actionPlanAccount.SalesDistrict__r.SalesManager__c;
                    }
                    else {
                        // evaluation.MarketName__c = evalAccount.Market__r.DistrictCode__c + ' - ' + evalAccount.Market__r.Name;
                        survey.Market__c = surveyAccount.Market__c;
                        survey.MarketCode__c = surveyAccount.Market__r.DistrictCode__c;
                        survey.Aftersales_Market_Manager__c = surveyAccount.Market__r.Aftersales_Market_Manager__c;
                        survey.MarketManager__c = surveyAccount.Market__r.MarketManager__c;
                        survey.GenesisMarketManagerAlt__c = surveyAccount.Market__r.GenesisMarketManagerAlt__c;

                      /* following code is commented by Neeraj sharma for 3522 ticket 
                       *  survey.GenesisArea__c = surveyAccount.GenesisArea__c;
                        survey.GenesisAreaCode__c = surveyAccount.GenesisArea__r.AreaCode__c;
                        survey.GenesisAreaName__c = surveyAccount.GenesisArea__r.Name;
                        survey.GenesisAreaManager__c = surveyAccount.GenesisAreaManager__c;
                        genesisAreas.add(surveyAccount.GenesisArea__c);*/
                        genesisSurveys.add(survey);
                    }

                    survey.DistrictManager__c = surveyAccount.DistrictManager__c;
                    survey.DistrictManagerAlt__c = surveyAccount.DistrictManagerAlt__c;

                    String surveySearchString = surveyAccount.Organization__c != null ? (!String.isBlank(surveyAccount.Organization__r.Name) ? surveyAccount.Organization__r.Name + '@@@' : '') : '';
                    surveySearchString += !String.isBlank(surveyAccount.DealerCode__c) ? surveyAccount.DealerCode__c + '@@@' : '';
                    surveySearchString += !String.isBlank(surveyAccount.Name) ? surveyAccount.Name + '@@@' : '';
                    surveySearchString += surveyAccount.Region__c != null ? (!String.isBlank(surveyAccount.Region__r.RegionCode__c) ? surveyAccount.Region__r.RegionCode__c + '@@@' : '')  : '';
                    surveySearchString += surveyAccount.Region__c != null ? (!String.isBlank(surveyAccount.Region__r.Name) ? surveyAccount.Region__r.Name + '@@@' : '') : '';
                    surveySearchString += surveyAccount.ServiceDistrict__c != null ? (!String.isBlank(surveyAccount.ServiceDistrict__r.DistrictCode__c) ? surveyAccount.ServiceDistrict__r.DistrictCode__c + '@@@' : '') : '';
                    surveySearchString += surveyAccount.ServiceDistrict__c != null ? (!String.isBlank(surveyAccount.ServiceDistrict__r.Name) ? surveyAccount.ServiceDistrict__r.Name + '@@@' : '') : '';
                    surveySearchString += surveyAccount.SalesDistrict__c != null ? (!String.isBlank(surveyAccount.SalesDistrict__r.Name) ? surveyAccount.SalesDistrict__r.Name + '@@@' : '') : '';
                    surveySearchString += surveyAccount.SalesDistrict__c != null ? (!String.isBlank(surveyAccount.SalesDistrict__r.DistrictCode__c) ? surveyAccount.SalesDistrict__r.DistrictCode__c + '@@@' : '') : '';
                    surveySearchString += surveyAccount.SalesDistrict__c != null ? (!String.isBlank(surveyAccount.SalesDistrict__r.Name) ? surveyAccount.SalesDistrict__r.Name + '@@@' : '') : '';
                    surveySearchString += surveyAccount.Market__c != null ? (!String.isBlank(surveyAccount.Market__r.DistrictCode__c) ? surveyAccount.Market__r.DistrictCode__c + '@@@' : '') : '';
                    surveySearchString += surveyAccount.Market__c != null ? (!String.isBlank(surveyAccount.Market__r.Name) ? surveyAccount.Market__r.Name + '@@@' : '') : '';
                 /* following code is commented by Neeraj sharma for 3522
                  *   surveySearchString += surveyAccount.GenesisArea__c != null ? (!String.isBlank(surveyAccount.GenesisArea__r.AreaCode__c) ? surveyAccount.GenesisArea__r.AreaCode__c + '@@@' : '') : '';
                    surveySearchString += surveyAccount.GenesisArea__r != null ?  (!String.isBlank(surveyAccount.GenesisArea__r.Name) ? surveyAccount.GenesisArea__r.Name : '') : ''; 
                  */      
                    survey.HMASurveySearch__c = surveySearchString.removeEnd('@@@');
                        //System.debug(LoggingLevel.ERROR, surveySearchString);
                }
            }
        }
    }

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] Added getExistingSharesForObject method to reduce the queries 
    */
    public static void handleSurveySharing(Map<Id, Survey__c> surveyMap, Boolean isUpdate) {

        if(!System.isBatch() && !System.isFuture() && !System.isQueueable()) {
            try{
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

                //          DPM-4548
            SurveyService.createSurveySharing(surveyMap, internalSharesMap); //DPM-5426 added internalSharesMap by MinheeKim - 24.03.19
            SurveyService.createSurveyDealerSharing(surveyMap, dealerSharesMap); //DPM-5426 added dealerSharesMap by MinheeKim - 24.03.19
            /* DPM-4548
            if(surveyMap.keyset().size() > 0) {
                BatchProcessObjectShares batchProcessObjectShares = new BatchProcessObjectShares();
                batchProcessObjectShares.objectIds = surveyMap.keySet();
                batchProcessObjectShares.type = 'Survey';
                if(!Test.isRunningTest()) {
                    Database.executeBatch(batchProcessObjectShares, 1);
                }
            }*/
            /*else {
                if(isUpdate){
                    SurveyService.recalculateEvaluationSharing(surveyMap.values());
                }
                else {
                    SurveyService.createSurveySharing(surveyMap);
                }
                SurveyService.createSurveyDealerSharing(surveyMap);
            }*/
            //DPM-5426 end
            }catch(Exception e){
                System.debug(e.getCause());
                System.debug(e.getMessage());
            }


        }
    }

    public static void populateAssignedDealOnPartnerOwner(List<Survey__c> newSurveys, Map<Id, Survey__c> oldSurveysMap){
        
        List<Id> ownerIds = new List<Id>();
        for(Survey__c survey:newSurveys) {
            if(oldSurveysMap == null || (survey.OwnerId != oldSurveysMap.get(survey.Id).OwnerId)){
                ownerIds.add(survey.OwnerId);
            }
        }

        Map<Id, User> usersMap = new Map<Id, User>([select Id, IsPortalEnabled from User where Id in :ownerIds]);

        for(Survey__c survey:newSurveys) {
            if(usersMap.containsKey(survey.OwnerId)) {
                survey.AssignedDealer__c = survey.OwnerId;
            }
        }

    }
    
     /*
   * @method updateGenesisEvaluation() 
   * @desc DPM-5633
   * 
   * @param {List<Survey__c>} newSurveys - new Survey list
   * @param {Map<Id, Survey__c>} oldSurveysMap 
   * 
   */
     public static void updateGenesisEvaluationStatus(List<Survey__c> newSurveys, Map<Id, Survey__c> oldSurveysMap){
         // Get the profile name of the current user
        String userProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        Id salesRecordType = [SELECT Id FROM RecordType  WHERE SobjectType ='Survey__c' AND DeveloperName = 'GenesisRetailerEvalSales'].Id;
        Id serviceRecordType = [SELECT Id FROM RecordType  WHERE SobjectType ='Survey__c' AND DeveloperName = 'GenesisRetailerEvalService'].Id;

         // List to hold Evaluation__c records to update
         List<Evaluation__c> evaluationsToUpdate = new List<Evaluation__c>();


        for(Survey__c survey:newSurveys) {
            Survey__c oldSurvey = oldSurveysMap.get(survey.Id);
            if(survey.RecordTypeId == salesRecordType || survey.RecordTypeId == serviceRecordType ){
                System.debug('GBX score: '+survey.GBX_Score__c);

                //Status Change from 'Not Started' to 'Previous' when survey is completed
                if(survey.Total_Score__c == 100.0 && survey.GenesisEvaluationStatus__c=='Not Started' && survey.Status__c=='Completed'){
                    
                    Evaluation__c evaluationToUpdate = new Evaluation__c(Id = survey.Evaluation__c, Action_Plan_Status__c = 'Completed', ApprovalStatus__c = 'Approved', Status__c = 'Completed', Indicator__c = 'Action Plan Not Required', DueDate__c = Date.today()+30);
                    evaluationsToUpdate.add(evaluationToUpdate);
                    System.debug('evaluationToUpdate Action_Plan_Status__c: ' + evaluationToUpdate.Action_Plan_Status__c);
                }else if(survey.GenesisEvaluationStatus__c=='Not Started' && survey.Status__c=='Completed'){
                    Evaluation__c evaluationToUpdate = new Evaluation__c(Id = survey.Evaluation__c, Action_Plan_Status__c = 'Pending', DueDate__c = Date.today()+30 );
                    if(survey.RecordTypeId == salesRecordType && survey.Total_Score__c < 80 && survey.GBX_Score__c < 959){ 
                        evaluationToUpdate.Indicator__c='Action Plan Required';
                    }else if(survey.RecordTypeId == salesRecordType){
                        evaluationToUpdate.Indicator__c='Action Plan Not Required';
                    }else if(survey.RecordTypeId == serviceRecordType && survey.ActionPlanRequired__c==true && survey.Total_Score__c < 80 && survey.GSX_Score__c < 917){ 
                        evaluationToUpdate.Indicator__c='Action Plan Required';
                    }else if(survey.RecordTypeId == serviceRecordType){
                        evaluationToUpdate.Indicator__c='Action Plan Not Required';
                    }
                    
                    System.debug('evaluationToUpdate.Indicator__c: '+evaluationToUpdate.Indicator__c);
                    evaluationsToUpdate.add(evaluationToUpdate);
                } 
            }
        }

         // Update Evaluation__c records if there are any to update
        if (!evaluationsToUpdate.isEmpty()) {
            try {
                EvaluationTriggerHandler.run = false;
                update evaluationsToUpdate;
                EvaluationTriggerHandler.run = true;
            } catch(Exception e) {
                System.debug('Error updating Evaluation records: ' + e.getMessage());
            }
        }
     }
}