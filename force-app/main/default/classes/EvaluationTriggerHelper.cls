/**
************************************************************************************************
* @classname         : EvaluationTriggerHelper
* @description       : 
* @author            : JongHoon Kim
* History
* Version      Date                Author               Ticket         Modification
* 1.0       10-07-2024           JongHoon Kim           DPM-5663      Created evaluationDPMRTopicChange Method
* 1.1       11-08-2024           JongHoon Kim           DPM-5924      Created preventDuplicateEvaluation Method
* 1.2       12-03-2024           JongHoon Kim           DPM-5946      Update evaluationDPMRTopicChange Method
* 1.3       01-22-2025           JongHoon Kim           DPM-133       Change DSM, DPSM, GMM, GAMM Update logic
* 1.4       02-03-2025           JongHoon Kim           DPM-6033      If the due date has not passed, update the Manager and Owner
* 1.5       02-04-2025           Minhee Kim             DPM-6017      add the method to input the business last modified date, by
************************************************************************************************
**/

public without sharing class EvaluationTriggerHelper {

    /**DPM-6017 added static variable */
    private static String INTEGRATIONUSER = 'Integration User';
    private static String SYSTEMADMIN = 'System Administrator';/**DPM-6017 end */
    
     /**Start - [TBD] To fix error occuring while many files at COPP Comfidential button */
     private static String cachedUserProfileName;
     private static RecordType cachedSalesRecType;
     private static RecordType cachedServiceRecType;
     private static RecordType  cachedCOPPRecType;
     private static Set<RecordType> cachedDpmrRecodTypes = new Set<RecordType>();
     private static Date today = Date.today(); // DPM-6033

     public static String getUserProfileName() {
         if (cachedUserProfileName == null) {
             cachedUserProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
         }
         return cachedUserProfileName;
     }
 
     public static RecordType getSalesRecType() {
         if (cachedSalesRecType == null) {
             cachedSalesRecType = [SELECT Id FROM RecordType WHERE  SObjectType = 'Evaluation__c' AND DeveloperName = 'Genesis_Retailer_Eval_Sales' LIMIT 1];
         }
         return cachedSalesRecType;
     }
 
     public static RecordType getServiceRecType() {
         if (cachedServiceRecType == null) {
             cachedServiceRecType = [SELECT Id FROM RecordType WHERE  SObjectType = 'Evaluation__c' AND DeveloperName = 'Genesis_Retailer_Eval_Service' LIMIT 1];
         }
         return cachedServiceRecType;
     }
     public static RecordType getCOPPRecType(){
        if (cachedCOPPRecType == null) {
            cachedCOPPRecType = [SELECT Id FROM RecordType WHERE  SObjectType = 'Evaluation__c' AND DeveloperName = 'COPP_Confidential' LIMIT 1];
        }
        return cachedCOPPRecType;
     }
     public static Set<RecordType> getDPMRRecordType(){
        if (cachedDpmrRecodTypes==null || cachedDpmrRecodTypes.size()==0) {
            List<RecordType> tempRecords = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Evaluation__c' AND DeveloperName LIKE '%DPMR%'];
            if(tempRecords.size()>0){
                for(RecordType rt: tempRecords){
                    cachedDpmrRecodTypes.add(rt);
                }
            }    
        }
        return cachedDpmrRecodTypes;
     }
      /**End - [TBD] To fix error occuring while many files at COPP Comfidential button */

    /**
     * Description: [Prevent Duplicate Reocrd] 
     * Created by [JonghoonKim] on [11-08-2024] for [Ticket 5924]
     * Edited by [Author] on [MM-DD-YYYY] for [Ticket #]
    */
    public static void preventDuplicateEvaluation(List<Evaluation__c> newEvaluations) {
        Set<String> setRecordTypeId = new Set<String>();
        Map<Id, Boolean> recordTypeMap = new Map<Id, Boolean>();

        for (Evaluation__c eval : newEvaluations) {
            setRecordTypeId.add(eval.RecordTypeId);  
        }

        //List<RecordType> rtList = [SELECT DeveloperName FROM RecordType WHERE Id IN :setRecordTypeId LIMIT 1];
        Set<RecordType> dpmrRecTypes = getDPMRRecordType();
        Set<String> dpmrRecTypeIds = new Set<String>();
        for(RecordType rt: dpmrRecTypes){
            dpmrRecTypeIds.add(rt.Id);
        }
        for (String rectypeId : setRecordTypeId) {
            if(dpmrRecTypeIds!=null && dpmrRecTypeIds.contains(rectypeId)){
                recordTypeMap.put(rectypeId, true);
            }else{
                recordTypeMap.put(rectypeId, false);
            }
        }


        Set<String> setNameToCheck = new Set<String>();
        for (Evaluation__c evaluation : newEvaluations) {
            Boolean isDPMR = recordTypeMap.get(evaluation.RecordTypeId);
            if(isDPMR != null && isDPMR){
                List<String> selectedValues = new List<String>();
                Boolean containsFinancial = false;

                if (evaluation.Topics_HmaSales__c != null) {
                    selectedValues.addAll(evaluation.Topics_HmaSales__c.split(';'));
                }
                if (evaluation.Topics_HmaService__c != null) {
                    selectedValues.addAll(evaluation.Topics_HmaService__c.split(';'));
                }
                if (evaluation.Topics_GmaSales__c != null) {
                    selectedValues.addAll(evaluation.Topics_GmaSales__c.split(';'));
                }
                if (evaluation.Topics_GmaService__c != null) {
                    selectedValues.addAll(evaluation.Topics_GmaService__c.split(';'));
                }

                for (String value : selectedValues) {
                    if (value.contains('Financial Performance')) {
                        containsFinancial = true;
                        break;
                    }
                }
                System.debug('preventDuplicateEvaluation evaluation.Name ==>>>'+ evaluation.Name);
                if(evaluation.Name == null) {
                    for(Evaluation__c eval : newEvaluations) {
                        try{
                            System.debug('preventDuplicateEvaluation evaluation.Name ==>>>22');
                            eval.Name.addError('This name already exists. Please avoid duplicate evaluations.');
                            throw new evalNameDuplException('This name already exists. Please avoid duplicate evaluations.');
                        }catch(Exception e) {
    
                            ErrorEmailNotifier.notifyAdmins(e, 'preventDuplicateEvaluation');
                            System.debug(e.getMessage());
                        }
                    }
                }

                if (containsFinancial && !evaluation.Name.contains(' (FIN)')) {
                    String[] parts = evaluation.Name.split(' - ');
                    if (parts.size() > 1) {
                        evaluation.Name = parts[0] + ' - ' + parts[1] + ' (FIN) - ' + parts[2] + ' - ' + parts[3];
                    }
                } else if (!containsFinancial && evaluation.Name.contains(' (FIN)')) {
                    evaluation.Name = evaluation.Name.replace(' (FIN)', '');
                }


                setNameToCheck.add(evaluation.Name);
            } 
            
        }
        if (!setNameToCheck.isEmpty()) {
            List<Evaluation__c> existingEvaluations = [
                SELECT Name 
                FROM Evaluation__c 
                WHERE Name IN :setNameToCheck
                LIMIT 1
            ];
            Map<String, Id> evalNameCheckMap = new Map<String, Id>();
            for(Evaluation__c existingEval: existingEvaluations) {
                evalNameCheckMap.put(existingEval.Name, existingEval.Id);
            }
            if (!existingEvaluations.isEmpty()) {
                for(Evaluation__c evaluation : newEvaluations) {
                    try{
                        if (evalNameCheckMap.containsKey(evaluation.Name)) {
                            evaluation.Name.addError('This name already exists. Please avoid duplicate evaluations.');
                            throw new evalNameDuplException('This name already exists. Please avoid duplicate evaluations.');
                        }
                    }catch(Exception e) {

                        ErrorEmailNotifier.notifyAdmins(e, 'preventDuplicateEvaluation');
                        System.debug(e.getMessage());
                    }
                }
            }
        }
    }

    public static void populatePrimaryContactUserId(List<Evaluation__c> newEvaluations, Boolean isUpdate) {
        Map<Id, Id> primaryContactIdUserIdMap = EvaluationService.getPrimaryContactUserMapFromEvaluations(newEvaluations);
        System.debug('newEvaluations: ' + newEvaluations.size());
        //DPM-5400 added to get Action plans related to evaluations
        List<Id> evalIdList = new List<Id>(); 
        Map<Id, List<Action_Plan__c>> evalAPMap = new Map<Id, List<Action_Plan__c>>();
        List<Action_Plan__c> actionPlanToUpdateList = new List<Action_Plan__c>(); 

        for(Evaluation__c eval : newEvaluations) {
            evalIdList.add(eval.Id);
        }
        System.debug('evalIdList: ' + evalIdList);
        Map<Id, Action_Plan__c> apMap = new Map<Id, Action_Plan__c>();
        Map<Id, User> userMap = new Map<Id,User>();
        if(isUpdate){ //DPM-5550 added isupdate parameter to reduce CPU by MinheeKim - 24.05.11
            apMap = new Map<Id, Action_Plan__c>([
                SELECT Id, Evaluation__c, Original_Partner_User_ID__c, OwnerId
                FROM Action_Plan__c 
                WHERE Evaluation__c IN :evalIdList 
            ]);
            
            
            if(apMap.size()>0){
                userMap = ActionPlanService.getUserMapFromActionPlans(apMap.values()); //DPM-5550 move into If clause  
                for(Action_Plan__c ap: apMap.values()){
                    if(!evalAPMap.containsKey(ap.Evaluation__c)){
                        List<Action_Plan__c> apList = new List<Action_Plan__c>();
                        if(userMap.containsKey(ap.OwnerId)){
                            apList.add(ap);
                            evalAPMap.put(ap.Evaluation__c, apList);
                        }
                    }else{
                        List<Action_Plan__c> preAPList = evalAPMap.get(ap.Evaluation__c);
                        if(userMap.containsKey(ap.OwnerId)){
                            preAPList.add(ap);
                            evalAPMap.put(ap.Evaluation__c, preAPList);
                        }
                    }
                }

            }
        }
        //DPM-5400 end

        for(Evaluation__c evaluation:newEvaluations) {
            if(primaryContactIdUserIdMap.containsKey(evaluation.PrimaryContact__c)) {
                evaluation.PrimaryContactUserId__c = primaryContactIdUserIdMap.get(evaluation.PrimaryContact__c);
                //DPM-5400 start
                if(evalAPMap.size()>0 && evalAPMap.containsKey(evaluation.Id) ){
                    List<Action_Plan__c> actionplans = evalAPMap.get(evaluation.Id);
                    for(Action_Plan__c actionplan : actionplans){
                        actionplan.Original_Partner_User_ID__c = primaryContactIdUserIdMap.get(evaluation.PrimaryContact__c);
                        if(userMap.size()>0 && userMap.containsKey(actionplan.OwnerId) && (userMap.get(actionplan.OwnerId).Profile.Name).contains('Partner')){
                            actionplan.OwnerId = primaryContactIdUserIdMap.get(evaluation.PrimaryContact__c);
                        }
                        actionPlanToUpdateList.add(actionplan);
                    }
                    
                }//DPM-5400 end
            }
            else {
                evaluation.PrimaryContactUserId__c = null;
            }
        }

        try{
            if(actionPlanToUpdateList.size()>0){
                update actionPlanToUpdateList;
            }
        }catch(Exception e){
            System.debug(e.getCause());
            System.debug(e.getMessage());
        }
    }

    public static void populateEvaluationFromAccount(List<Evaluation__c> newEvaluations, Map<Id, Evaluation__c> oldEvaluationMap) {    
        Set<Id> accountIds = new Set<Id>();
        set<id> regionIds= new set<Id>();
        Map<id,Region__c> regionsMap = new Map<id,Region__c>();
        for(Evaluation__c evaluation:newEvaluations) {
            if(evaluation.Account__c != null) {
                accountIds.add(evaluation.Account__c);

                if(evaluation.Account__r.Region__c!=null)
                regionIds.add(evaluation.Account__r.Region__c);

            }
           

        }
        if(regionIds.size()>0){
           
           for(Region__c reg : [select id,RegionCode__c,Name from Region__c where id in:regionIds]){
            regionsMap.put(reg.id,reg);
           }
        
        }

        Map<Id, Account> accountMap = HMAQueryService.getAccountMapFromSetOfAccountIds(accountIds);
        List<Id> genesisAreas = new List<Id>();
        List<Evaluation__c> genesisEvaluations = new List<Evaluation__c>();

        for(Evaluation__c evaluation:newEvaluations) {
            if(evaluation.Account__c != null) {
                Account evalAccount = accountMap.get(evaluation.Account__c);

                //Changes by Dhiraj starts here
                // if(evaluation.RecordTypeId=='0123I0000009qFwQAI'){
                //  //   evaluation.Organization__c = 'Hyundai Confidential';
                //  //evaluation.OrganizationRef__c = '';
                 		
                // }else{
                // 	//evaluation.Organization__c = evalAccount.Organization__r.Name;
                // 	//evaluation.OrganizationRef__c = evalAccount.Organization__c;
                // }
                
                //Changes by Dhiraj ends here
                evaluation.OrganizationRef__c = evalAccount.Organization__c;
                evaluation.Organization__c = evalAccount.Organization__r.Name;
                evaluation.DealerCode__c = evalAccount.DealerCode__c;
                //evaluation.GeneralManager__c = evalAccount.GeneralManager__c;
                //evaluation.DealerPrincipal__c = evalAccount.DealerPrincipal__c;

                /*if(evaluation.PrimaryContact__c == null) {
                    if(evalAccount.DealerPrincipal__c != null) {
                        evaluation.PrimaryContact__c = evalAccount.DealerPrincipal__c;
                    }
                    else if(evaluation.GeneralManager__c != null) {
                        evaluation.PrimaryContact__c = evalAccount.GeneralManager__c;
                    }
                }*/
                if(evalAccount.Name.contains('-')) {
                    evaluation.DealerName__c = evalAccount.Name.split('-')[1].trim();
                }
                else {
                    evaluation.DealerName__c = evalAccount.Name;
                }
                
                evaluation.DistrictManager__c = evalAccount.DistrictManager__c;
               //evaluation.DistrictManagerAlt__c = evalAccount.DistrictManagerAlt__c;
                if(evalAccount.RecordType.DeveloperName == 'HyundaiDealer' || evalAccount.RecordType.DeveloperName == 'GenesisRetailer'){
                    if( oldEvaluationMap != NULL && oldEvaluationMap.containsKey(evaluation.id) && oldEvaluationMap.get(evaluation.id) != NULL 
                    && oldEvaluationMap.get(evaluation.id).RegionRef__c != evalAccount.Region__c && !regionsMap.isEmpty()){

                        evaluation.RegionCode__c = regionsMap.get(evalAccount.Region__c).RegionCode__c;
                        evaluation.Region__c = regionsMap.get(evalAccount.Region__c).Name;
                       }
                       else{
                    evaluation.RegionRef__c = evalAccount.Region__c;
                    evaluation.RegionCode__c = evalAccount.Region__r.RegionCode__c;
                    evaluation.Region__c = evalAccount.Region__r.Name;
                       }
                    if(evalAccount.ServiceDistrict__c != null || !String.isBlank(evalAccount.ServiceDistrict__c)) {
                        evaluation.ServiceDistrict__c = evalAccount.ServiceDistrict__c;    
                        evaluation.ServiceDistrictName__c = evalAccount.ServiceDistrict__r.DistrictCode__c + ' - ' + evalAccount.ServiceDistrict__r.Name;
                        evaluation.ServiceDistrictCode__c = evalAccount.ServiceDistrict__r.DistrictCode__c;
                        //DPM-6033
                        if(evaluation.EndDate__c >= today && !String.isBlank(evaluation.ScheduledTopic__c) && evalAccount.SalesDistrict__r.SalesManager__r.isactive == true) {
                            evaluation.DistrictPartsServiceManager__c = evalAccount.ServiceDistrict__r.DistrictPartsServiceManager__c;
                        }
                        
                        //DPM-133
                        //DPM-6033
                        // if(evaluation.Status__c != null &&  evaluation.ApprovalStatus__c != 'Region Approved' && evaluation.Status__c != 'Completed' && evaluation.Status__c !='Closed' && !String.isBlank(evaluation.ScheduledTopic__c) && !String.isBlank(evaluation.Type__c) ) {
                        if(evaluation.EndDate__c >= today && !String.isBlank(evaluation.ScheduledTopic__c) && !String.isBlank(evaluation.Type__c) ) {   
                            if(evaluation.Type__c == 'Service' && evalAccount.ServiceDistrict__r.DistrictPartsServiceManager__r.isactive == true) {
                                evaluation.OwnerId = evalAccount.ServiceDistrict__r.DistrictPartsServiceManager__c;
                            }
                            
                        }
                        //
                        // evaluation.DistrictPartsServiceManagerAlt__c = evalAccount.ServiceDistrict__r.DistrictPartsServiceManagerAlt__c;
                    }
                    
                    if(evalAccount.SalesDistrict__c != null || !String.isBlank(evalAccount.SalesDistrict__c)) {
                        evaluation.SalesDistrict__c = evalAccount.SalesDistrict__c;
                        evaluation.SalesDistrictName__c = evalAccount.SalesDistrict__r.DistrictCode__c + ' - ' + evalAccount.SalesDistrict__r.Name;
                        evaluation.SalesDistrictCode__c = evalAccount.SalesDistrict__r.DistrictCode__c;
                        //DPM-6033
                        if(evaluation.EndDate__c >= today && !String.isBlank(evaluation.ScheduledTopic__c) && evalAccount.SalesDistrict__r.SalesManager__r.isactive == true) {
                            evaluation.DistrictSalesManager__c = evalAccount.SalesDistrict__r.SalesManager__c;
                        }
                        
                        //DPM-133
                        //DPM-6033
                        // if(evaluation.Status__c != null && evaluation.ApprovalStatus__c != 'Region Approved' && evaluation.Status__c != 'Completed' && evaluation.Status__c !='Closed' && !String.isBlank(evaluation.ScheduledTopic__c) && !String.isBlank(evaluation.Type__c) ) {
                        if(evaluation.EndDate__c >= today && !String.isBlank(evaluation.ScheduledTopic__c) && !String.isBlank(evaluation.Type__c) ) {    
                            if(evaluation.Type__c == 'Sales' && evalAccount.SalesDistrict__r.SalesManager__r.isactive == true) {
                                evaluation.OwnerId = evalAccount.SalesDistrict__r.SalesManager__c;
                            }
                        }
                        //
                       // evaluation.DistrictSalesManagerAlt__c = evalAccount.SalesDistrict__r.DistrictSalesManagerAlt__c;

                    }
                    if(evalAccount.Market__c != null && evalAccount.RecordType.DeveloperName == 'GenesisRetailer') {
                        evaluation.MarketRef__c = evalAccount.Market__c;
                        evaluation.MarketCode__c = evalAccount.Market__r.DistrictCode__c;
                        //DPM-6033
                        if(evaluation.EndDate__c >= today && !String.isBlank(evaluation.ScheduledTopic__c)) {
                            if(evalAccount.Market__r.MarketManager__r.isactive == true) {
                                evaluation.MarketManager__c = evalAccount.Market__r.MarketManager__c;
                            }
                            
                            if(evalAccount.Market__r.Aftersales_Market_Manager__r.isactive == true) {
                                evaluation.Aftersales_Market_Manager__c = evalAccount.Market__r.Aftersales_Market_Manager__c;
                            } 
                        }
                        evaluation.GenesisMarketManagerAlt__c = evalAccount.Market__r.GenesisMarketManagerAlt__c;
                        //DPM-133
                        //DPM-6033
                        // if(evaluation.Status__c != null && evaluation.ApprovalStatus__c != 'Region Approved' && evaluation.Status__c != 'Completed' && evaluation.Status__c !='Closed' && !String.isBlank(evaluation.ScheduledTopic__c) && !String.isBlank(evaluation.Type__c) ) {
                        if(evaluation.EndDate__c >= today && !String.isBlank(evaluation.ScheduledTopic__c) && !String.isBlank(evaluation.Type__c) ) {
                            if(evaluation.Type__c == 'Sales' && evalAccount.Market__r.MarketManager__r.isactive == true) {
                                evaluation.OwnerId = evalAccount.Market__r.MarketManager__c;
                            } else if(evaluation.Type__c == 'Service' && evalAccount.Market__r.Aftersales_Market_Manager__r.isactive == true){
                                evaluation.OwnerId = evalAccount.Market__r.Aftersales_Market_Manager__c;
                            }
                        }
                        //
                    }
                }
                else {
                   // evaluation.MarketName__c = evalAccount.Market__r.DistrictCode__c + ' - ' + evalAccount.Market__r.Name;
                  /*  if(evalAccount.Market__c != null) {
                        evaluation.MarketRef__c = evalAccount.Market__c;
                        evaluation.MarketCode__c = evalAccount.Market__r.DistrictCode__c;
                        evaluation.MarketManager__c = evalAccount.Market__r.MarketManager__c;
                    }*/

                    /* folowing code commented by Neeraj for 3523 ticket 
                     * 
                     * evaluation.GenesisArea__c = evalAccount.GenesisArea__c;
                    evaluation.GenesisAreaCode__c = evalAccount.GenesisArea__r.AreaCode__c;
                    evaluation.GenesisAreaName__c = evalAccount.GenesisArea__r.Name;
                    evaluation.GenesisAreaManager__c = evalAccount.GenesisAreaManager__c;
                    genesisAreas.add(evalAccount.GenesisArea__c);
                    genesisEvaluations.add(evaluation);*/
                    
                }
            }
            String evaluationSearchString = (!String.isBlank(evaluation.Organization__c) ? evaluation.Organization__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.DealerCode__c) ? evaluation.DealerCode__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.DealerName__c) ? evaluation.DealerName__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.RegionCode__c) ? evaluation.RegionCode__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.Region__c) ? evaluation.Region__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.ServiceDistrictName__c) ? evaluation.ServiceDistrictName__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.ServiceDistrictCode__c) ? evaluation.ServiceDistrictCode__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.SalesDistrictName__c) ? evaluation.SalesDistrictName__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.SalesDistrictCode__c) ? evaluation.SalesDistrictCode__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.MarketCode__c) ? evaluation.MarketCode__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.MarketManager__c) ? evaluation.MarketManager__c + '@@@' : '') +
                    (!String.isBlank(evaluation.Aftersales_Market_Manager__c) ? evaluation.Aftersales_Market_Manager__c + '@@@' : '') ; // DPm-4188 made changes by Milind Shinde
           
                   /* following code commented by Neeraj Sharma for 3523 ticket 
                    * (!String.isBlank(evaluation.GenesisAreaCode__c) ? evaluation.GenesisAreaCode__c + '@@@' : '') + 
                    (!String.isBlank(evaluation.GenesisAreaName__c) ? evaluation.GenesisAreaName__c : '');
                    */
                    
            evaluation.HMAEvaluationSearch__c = evaluationSearchString.removeEnd('@@@');
        }
       /*
        * This ticket commented by Neeraj for 3523 ticket 
        *  if(!genesisEvaluations.isEmpty()) {
            Map<Id, List<AreasRegion__c>> mapOfGeneisisRegions = HMAQueryService.getAreaRegionsForGenesisAreas(genesisAreas);

            for(Evaluation__c genesisEval:genesisEvaluations) {
                String regionCodes = '';
                String regions = '';
                if(mapOfGeneisisRegions.containsKey(genesisEval.GenesisArea__c)) {
                    for(AreasRegion__c areaRegion:mapOfGeneisisRegions.get(genesisEval.GenesisArea__c)) {
                        if(regions != '') {
                            regionCodes += ';';
                            regions += ';';
                        }
                        regionCodes += areaRegion.Region__r.RegionCode__c;
                        regions += areaRegion.Region__r.Name;
                    }
                }
                genesisEval.RegionCode__c = regionCodes;
                genesisEval.Region__c = regions;       
            } 
        }*/
    }

    public static void handleEvaluationStatusChange(List<Evaluation__c> evaluations, Map<Id, Evaluation__c> oldEvaluationMap) {
        List<String> evaluationIds = new List<String>();
        for(Evaluation__c evaluation:evaluations) {
            
            Evaluation__c oldEvaluation = oldEvaluationMap.get(evaluation.Id);
            if(evaluation.Status__c != oldEvaluation.Status__c && (evaluation.Status__c == 'Compliant' || evaluation.Status__c == 'Non-Compliant')) {
                evaluationIds.add(evaluation.Id);
            }
        }
        DateTime nextFireDateTime = DateTime.now().addSeconds(5);
        String hour = String.valueOf(nextFireDateTime.hour());
        String min = String.valueOf(nextFireDateTime.minute());
        String ss = String.valueOf(nextFireDateTime.second());
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        if(!evaluationIds.isEmpty()) {
            System.schedule('Generate PDF Scheduler ' + nextFireDateTime, nextFireTime, new GeneratePDFScheduler(evaluationIds, 'Evaluation'));
        }
    }

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] Added getExistingSharesForObject method to reduce the queries 
    */
    public static void handleEvaluationSharing(Map<Id, Evaluation__c> evaluationMap, Boolean isUpdate) {

        if(!System.isBatch() && !System.isFuture() && !System.isQueueable()) {
            try{
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

    //          DPM-4548
                EvaluationService.createEvaluationSharing(evaluationMap, internalSharesMap); //DPM-5426 internalSharesMap by Minheekim - 24.03.19
                EvaluationService.createEvaluationDealerSharing(evaluationMap, dealerSharesMap); //DPM-5426 dealerSharesMap by Minheekim - 24.03.19
                
            }catch(Exception e){
                System.debug(e.getCause());
                System.debug(e.getMessage());
            }
            /* DPM-4548
            if(evaluationMap.keyset().size() > 0) {
                BatchProcessObjectShares batchProcessObjectShares = new BatchProcessObjectShares();
                batchProcessObjectShares.objectIds = evaluationMap.keySet();
                batchProcessObjectShares.type = 'Evaluation';
                Database.executeBatch(batchProcessObjectShares, 1);

            }*/
            /*else {
                if(isUpdate) {
                    EvaluationService.recalculateEvaluationSharing(evaluationMap.values());
                }
                else {
                    EvaluationService.createEvaluationSharing(evaluationMap);
                }
                EvaluationService.createEvaluationDealerSharing(evaluationMap);
            }*/
        }
        /*if(trigger.isInsert){
        List<Evaluation__share> evalShare = new List<Evaluation__share>();
            for(Evaluation__c eval : [Select id from Evaluation__c where RecordType.Name = 'Confidential']){
                Evaluation__share eShare = new Evaluation__share();
               	eShare.ParentId = eval.Id;
                eShare.UserOrGroupId = '00G3I000000oRxwUAE';
                eShare.AccessLevel = '';
                evalShare.add(eShare);
            }            
        }*/
    }

    public static void populateAssignedDealOnPartnerOwner(List<Evaluation__c> newEvaluations, Map<Id, Evaluation__c> oldEvaluationsMap){
        
        List<Id> ownerIds = new List<Id>();
        for(Evaluation__c evaluation:newEvaluations) {
            if(oldEvaluationsMap == null || (evaluation.OwnerId != oldEvaluationsMap.get(evaluation.Id).OwnerId)){
                ownerIds.add(evaluation.OwnerId);
            }
        }

        Map<Id, User> usersMap = new Map<Id, User>([select Id, IsPortalEnabled from User where Id in :ownerIds]);

        for(Evaluation__c evaluation:newEvaluations) {
            if(usersMap.containsKey(evaluation.OwnerId)) {
                evaluation.AssignedDealer__c = evaluation.OwnerId;
            }
// 4754 - ticket
//            if(evaluation.ApprovalStatus__c == 'Submitted for District Approval' && oldEvaluationsMap.get(evaluation.Id).ApprovalStatus__c != 'Submitted for District Approval' && evaluation.Total_of_Related_Action_Plans__c == 0) {
            if(evaluation.ApprovalStatus__c == 'Submitted for District Approval' && oldEvaluationsMap.get(evaluation.Id).ApprovalStatus__c != 'Submitted for District Approval') {
                if(evaluation.Organization__c == 'Hyundai') {

                    if(evaluation.DistrictManager__c != null) {
                        evaluation.OwnerId = evaluation.DistrictManager__c;
                    }
                    else if(evaluation.Type__c == 'Sales' && evaluation.DistrictSalesManager__c != null) {
                        evaluation.OwnerId = evaluation.DistrictSalesManager__c;
                    }
                    
                    else if(evaluation.Type__c == 'Service' && evaluation.DistrictPartsServiceManager__c != null ) {
                        evaluation.OwnerId = evaluation.DistrictPartsServiceManager__c;
                    }
                   
                } else if(evaluation.Organization__c == 'Genesis') {
                    if(evaluation.Type__c == 'Service' && evaluation.Aftersales_Market_Manager__c != null) {
                        evaluation.OwnerId = evaluation.Aftersales_Market_Manager__c;
                    }
                    else if(evaluation.Type__c == 'Sales' && evaluation.MarketManager__c != null) {
                        evaluation.OwnerId = evaluation.MarketManager__c;
                    }
                }
                
            } else if(evaluation.ApprovalStatus__c == 'Submitted for District Approval' && oldEvaluationsMap.get(evaluation.Id).ApprovalStatus__c != 'Submitted for District Approval' && evaluation.Total_of_Related_Action_Plans__c > 0) {
                if(evaluation.Organization__c == 'Hyundai') {

                    if(evaluation.DistrictManager__c != null) {
                        evaluation.OwnerId = evaluation.DistrictManager__c;
                    }
                   
                    else if(evaluation.Type__c == 'Sales' && evaluation.DistrictSalesManager__c != null) {
                        evaluation.OwnerId = evaluation.DistrictSalesManager__c;
                    }
                   
                    else if(evaluation.Type__c == 'Service' && evaluation.DistrictPartsServiceManager__c != null ) {
                        evaluation.OwnerId = evaluation.DistrictPartsServiceManager__c;
                    } 
                }else if(evaluation.Type__c == 'Genesis' && evaluation.Aftersales_Market_Manager__c != null && evaluation.Type__c == 'Service') {
                    evaluation.OwnerId = evaluation.Aftersales_Market_Manager__c;
                }
                else if(evaluation.Type__c == 'Genesis' && evaluation.MarketManager__c != null && evaluation.Type__c == 'Sales') {
                    evaluation.OwnerId = evaluation.MarketManager__c;
                }
            }
            else if(evaluation.ApprovalStatus__c == 'Sent Back' && oldEvaluationsMap.get(evaluation.Id).ApprovalStatus__c == 'Submitted for District Approval') { 
                if (evaluation.AssignedDealer__c != NULL) {
                    
                evaluation.OwnerId = evaluation.AssignedDealer__c;
                }
            }
        }

    }
    
        /**
    * Populate District Approver Email Address
    * @param  newEvaluations  list of new Action Plan
    * @param oldEvaluationsMap map of old Action Plan
    * @return none     
    * @author Vinit [06 August 2021] 
    */
    public static void populateDistrictApproverEmail(List<Evaluation__c> newEvaluations,Map<Id, Evaluation__c> oldEvaluationsMap){
        
        for (Evaluation__c eval : newEvaluations) {
            if (eval.ApprovalStatus__c == 'District Approved'  
                && eval.ApprovalStatus__c  != oldEvaluationsMap.get(eval.Id).ApprovalStatus__c) {
                eval.District_Approval_Email__c = UserInfo.getUserEmail();
            }
        }
    }
  /*  
* Update dealer indicator while creation/update of Evaluation for hyundai service
* @param  newEvaluations  list of Evaluation Plan
* @param  oldEvaluationsMap map of Evaluation plan
* @return none     
* @author Neeraj [09 oct 2021]  Ticket DPM262
*/
    public static void UpdateDealerIndicator(List<Evaluation__c> newEvaluations,Map<Id, Evaluation__c> oldEvaluationsMap){
        String Imagelink='';
        
        DPMConfigurationSettings__c var = DPMConfigurationSettings__c.getOrgDefaults();
        
       // CurrentEnvironment__c instanceName = [SELECT name,Environment__c FROM CurrentEnvironment__c LIMIT 1];
        
        
        
        for(Evaluation__c ev :newEvaluations ){
           
                if((ev.IsSelfReview__c && ev.Survey__r.Status__c=='Completed')||(ev.IsSelfReview__c && ev.ApprovalStatus__c=='Sent Back' && (ev.DistrictApprovalDate__c==null))){
                    Imagelink=URL.getSalesforceBaseUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEEvalDealerIndicatorCompleteSurvFil__c;
                }
                else if(ev.PrimaryContact__c!=null && ev.Total_of_Related_Action_Plans__c>0 && ev.ApprovalStatus__c!='Submitted for Genesis Area Approval' && ev.ApprovalStatus__c!='Genesis Area Approved'&& ev.ApprovalStatus__c!='Region Approved'&& ev.ApprovalStatus__c!='Submitted for Regional Approval'&& ev.ApprovalStatus__c!='District Approved'&& ev.ApprovalStatus__c!='Submitted for District Approval' ){
               Imagelink=URL.getSalesforceBaseUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEEvalDealerIndicatorReviewAPsFileId__c;

                }
                else if(ev.Status__c!='Compliant' && ev.Status__c!='Non-Compliant' && (ev.Status__c=='Completed'||ev.ApprovalStatus__c=='Submitted for Genesis Area Approval' || ev.ApprovalStatus__c=='Genesis Area Approved'|| ev.ApprovalStatus__c=='Region Approved'|| ev.ApprovalStatus__c=='Submitted for Regional Approval'|| ev.ApprovalStatus__c=='District Approved'|| ev.ApprovalStatus__c=='Submitted for District Approval' )){
               Imagelink=URL.getSalesforceBaseUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEDealerIndicatorCompleteFileId__c;

                }
                else if(ev.Status__c=='Compliant' ){
              Imagelink=URL.getSalesforceBaseUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEDealerIndicatorCompleteCompliant__c;

                }
                else if(ev.Status__c=='Non-Compliant' ){
              Imagelink=URL.getSalesforceBaseUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGEDealerIndicatorCompleteNonComplia__c;

                }
                else{
               Imagelink=URL.getSalesforceBaseUrl().toExternalForm()+'/'+var.FileURLHelper__c+''+var.STAGE_EvalDealerIndicatorNoActReqFile__c;

                }
            ev.Dealer_Indicator_Link__c =Imagelink;
            }
    
    
    
    }

           /**
    * Remove Manual Share if district removed from Evaluation.
    * @param  newEvaluations  list of new Evaluation
    * @param  oldEvaluationsMap map of old Evaluation
    * @return none     
    * @author Vinit [07 Jan 2022] 
    */
    public static void removeManualShareEval(List<Evaluation__c> newEvaluations,Map<Id, Evaluation__c> oldEvaluationsMap) {

        Map<Id,List<Id>> mapOfAltDistrict = new Map<Id,List<Id>>();
        for (Evaluation__c eval : newEvaluations) {

                if (oldEvaluationsMap != NULL) {

                    if (!mapOfAltDistrict.containsKey(eval.Id)){
                        mapOfAltDistrict.put(eval.Id,new List<Id>());
                    }

                   /* if ((eval.DistrictManagerAlt__c != oldEvaluationsMap.get(eval.Id).DistrictManagerAlt__c
                        && eval.DistrictManager__c != oldEvaluationsMap.get(eval.Id).DistrictManagerAlt__c)
                        || (eval.DistrictManager__c == NULL && eval.DistrictManagerAlt__c == NULL)) {
                        mapOfAltDistrict.get(eval.Id).add(oldEvaluationsMap.get(eval.Id).DistrictManagerAlt__c);
                    }

                    if ((eval.DistrictPartsServiceManagerAlt__c != oldEvaluationsMap.get(eval.Id).DistrictPartsServiceManagerAlt__c
                        && eval.DistrictPartsServiceManager__c != oldEvaluationsMap.get(eval.Id).DistrictPartsServiceManagerAlt__c)
                        || (eval.DistrictPartsServiceManager__c == NULL && eval.DistrictPartsServiceManagerAlt__c == NULL)) {
                        mapOfAltDistrict.get(eval.Id).add(oldEvaluationsMap.get(eval.Id).DistrictPartsServiceManagerAlt__c);
                    }

                    if ((eval.DistrictSalesManagerAlt__c != oldEvaluationsMap.get(eval.Id).DistrictSalesManagerAlt__c
                        && eval.DistrictSalesManager__c != oldEvaluationsMap.get(eval.Id).DistrictSalesManagerAlt__c)
                        || (eval.DistrictSalesManager__c == NULL && eval.DistrictSalesManagerAlt__c == NULL)) {
                        mapOfAltDistrict.get(eval.Id).add(oldEvaluationsMap.get(eval.Id).DistrictSalesManagerAlt__c);
                    }*/

                    if (eval.Aftersales_Market_Manager__c != oldEvaluationsMap.get(eval.Id).Aftersales_Market_Manager__c 
                    && oldEvaluationsMap.get(eval.Id).Aftersales_Market_Manager__c != NULL) {
                        mapOfAltDistrict.get(eval.Id).add(oldEvaluationsMap.get(eval.Id).Aftersales_Market_Manager__c);
                    }// DPM-4188 Made changes by Milind Shinde
                    
                    if ((eval.GenesisMarketManagerAlt__c != oldEvaluationsMap.get(eval.Id).GenesisMarketManagerAlt__c
                        && eval.MarketManager__c != oldEvaluationsMap.get(eval.Id).GenesisMarketManagerAlt__c
                        && oldEvaluationsMap.get(eval.Id).GenesisMarketManagerAlt__c != NULL)
                        || (eval.MarketManager__c == NULL && eval.GenesisMarketManagerAlt__c == NULL 
                        && oldEvaluationsMap.get(eval.Id).GenesisMarketManagerAlt__c != NULL)) {
                        mapOfAltDistrict.get(eval.Id).add(oldEvaluationsMap.get(eval.Id).GenesisMarketManagerAlt__c);
                    }
                    
                }
        }

        if (mapOfAltDistrict.size() > 0) {
            List<Evaluation__Share> listOfShare = new List<Evaluation__Share>();
            for (Evaluation__Share eps : [SELECT Id, userOrGroupId, parentId,Parent.OwnerId 
                                           FROM Evaluation__Share 
                                           WHERE parentId =:mapOfAltDistrict.keySet()]) {
                                     if (eps.userOrGroupId != NULL && mapOfAltDistrict.get(eps.parentId) != NULL 
                                         && (mapOfAltDistrict.get(eps.parentId)).size() > 0
                                         && (mapOfAltDistrict.get(eps.parentId)).contains(eps.userOrGroupId)
                                         && eps.Parent.OwnerId != eps.userOrGroupId)   {
                                            listOfShare.add(eps);
                                     }       

            }

            if (listOfShare.size() > 0) {
                delete listOfShare;
            }
        }
  
    
        
     }

    /*
   * @method evaluationDPMRTopicChange() 
   * @desc DPM-5663
   * Prevent the record to be edited when Topic Update
   * @param {List<Evaluation__c>} newEvaluations - new Evaluation list
   * @param {Map<Id, Evaluation__c>} oldEvaluationsMap 
   * 
   */
    // public static void evaluationDPMRTopicChange(List<Evaluation__c> newEvaluations,Map<Id, Evaluation__c> oldEvaluationsMap){
        
    //     Map<Id, String> recordTypeMap = new Map<Id, String>();
    //     for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Evaluation__c' AND DeveloperName LIKE 'DPMR%']) {
    //         recordTypeMap.put(rt.Id, rt.DeveloperName);
    //     }

    //     for(Evaluation__c evaluation:newEvaluations) {
    //         Evaluation__c oldEval = oldEvaluationsMap.get(evaluation.Id);
    //         if (recordTypeMap.containsKey(evaluation.RecordTypeId) || Test.isRunningTest()) {
                
    //             List<String> selectedValues = new List<String>();
    //             Boolean containsFinancial = false;
    //             Boolean containsSI = false;
    //             if (evaluation.Topics_HmaSales__c != null) {
    //                 selectedValues = evaluation.Topics_HmaSales__c.split(';');
    //             }
    //             if (evaluation.Topics_HmaService__c != null) {
    //                 selectedValues = evaluation.Topics_HmaService__c.split(';');
    //             }
    //             if (evaluation.Topics_GmaSales__c != null) {
    //                 selectedValues = evaluation.Topics_GmaSales__c.split(';');
    //             }
    //             if (evaluation.Topics_GmaService__c != null) {
    //                 selectedValues = evaluation.Topics_GmaService__c.split(';');
    //             }

                
    //             for (String value : selectedValues) {
    //                 if (value.contains('Financial Performance')) {
    //                     containsFinancial = true;
    //                     break;
    //                 }
    //             }

    //             for (String value : selectedValues) {
    //                 if (value.contains('Survey Integrity')) {
    //                     containsSI = true;
    //                     break;
    //                 }
    //             }

    //             if(evaluation.topics_HmaSales__c != oldEval.topics_HmaSales__c || evaluation.Topics_HmaService__c != oldEval.Topics_HmaService__c 
    //                 || evaluation.Topics_GmaSales__c != oldEval.Topics_GmaSales__c || evaluation.Topics_GmaService__c != oldEval.Topics_GmaService__c) {
    //                 if(containsFinancial && containsSI && evaluation.Name != null) {
    //                     if (!evaluation.Name.contains(' (FIN, SI)') && !evaluation.Name.contains(' (FIN)') && !evaluation.Name.contains(' (SI)')) {
    //                         String[] parts = evaluation.Name.split(' - ');
    //                         if (parts.size() > 1) {
    //                             String newName = parts[0] + ' - ' + parts[1] + ' (FIN, SI) - ' + parts[2] + ' - ' + parts[3];
    //                             evaluation.Name = newName;
    //                         }
    //                     } else if(!evaluation.Name.contains(' (FIN, SI)') && evaluation.Name.contains(' (FIN)') && !evaluation.Name.contains(' (SI)')) {
    //                         String newName = evaluation.Name.replace('(FIN)', '(FIN, SI)');
    //                         evaluation.Name = newName;
    //                     } else if(!evaluation.Name.contains(' (FIN, SI)') && !evaluation.Name.contains(' (FIN)') && evaluation.Name.contains(' (SI)')) {
    //                         String newName = evaluation.Name.replace('(SI)', '(FIN, SI)');
    //                         evaluation.Name = newName;
    //                     }
    //                 } else if(!containsFinancial && containsSI && evaluation.Name != null) {
    //                     if (!evaluation.Name.contains(' (FIN, SI)') && !evaluation.Name.contains(' (FIN)') && !evaluation.Name.contains(' (SI)')) {
    //                         String[] parts = evaluation.Name.split(' - ');
    //                         if (parts.size() > 1) {
    //                             String newName = parts[0] + ' - ' + parts[1] + ' (SI) - ' + parts[2] + ' - ' + parts[3];
    //                             evaluation.Name = newName;
    //                         }
    //                     } else if(evaluation.Name.contains(' (FIN, SI)') && !evaluation.Name.contains(' (FIN)') && !evaluation.Name.contains(' (SI)')) {
    //                         String newName = evaluation.Name.replace('(FIN, SI)', '(SI)');
    //                         evaluation.Name = newName;
    //                     } else if(!evaluation.Name.contains(' (FIN, SI)') && evaluation.Name.contains(' (FIN)') && !evaluation.Name.contains(' (SI)')) {
    //                         String newName = evaluation.Name.replace('(FIN)', '(SI)');
    //                         evaluation.Name = newName;
    //                     }
    //                 } else if(containsFinancial && !containsSI && evaluation.Name != null) {
    //                     if (!evaluation.Name.contains(' (FIN, SI)') && !evaluation.Name.contains(' (FIN)') && !evaluation.Name.contains(' (SI)')) {
    //                         String[] parts = evaluation.Name.split(' - ');
    //                         if (parts.size() > 1) {
    //                             String newName = parts[0] + ' - ' + parts[1] + ' (FIN) - ' + parts[2] + ' - ' + parts[3];
    //                             evaluation.Name = newName;
    //                         }
    //                     } else if(evaluation.Name.contains(' (FIN, SI)') && !evaluation.Name.contains(' (FIN)') && !evaluation.Name.contains(' (SI)')) {
    //                         String newName = evaluation.Name.replace('(FIN, SI)', '(FIN)');
    //                         evaluation.Name = newName;
    //                     } else if(!evaluation.Name.contains(' (FIN, SI)') && !evaluation.Name.contains(' (FIN)') && evaluation.Name.contains(' (SI)')) {
    //                         String newName = evaluation.Name.replace('(SI)', '(FIN)');
    //                         evaluation.Name = newName;
    //                     }
    //                 }  else {
    //                     if(evaluation.Name != null) {
    //                         if (evaluation.Name.contains('(FIN, SI)')) {
    //                             String newName = evaluation.Name.replace(' (FIN, SI)', '');
    //                             evaluation.Name = newName;
    //                         } else if(evaluation.Name.contains('(FIN)')) {
    //                             String newName = evaluation.Name.replace(' (FIN)', '');
    //                             evaluation.Name = newName;
    //                         } else if(evaluation.Name.contains('(SI)')) {
    //                             String newName = evaluation.Name.replace(' (SI)', '');
    //                             evaluation.Name = newName;
    //                         } 
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }

/**
 * Description: [Update the Evaluation Name when the Topic is updated.] 
 * (....)
 * Created by [Jonghoon Kim] on [10-07-2024] for [DPM-5663]
 * Edited by [Jonghoon Kim] on [12-03-2024] for [DPM-5946]
*/
public static void evaluationDPMRTopicChange(List<Evaluation__c> newEvaluations, Map<Id, Evaluation__c> oldEvaluationsMap) {
    try {
        String SUFFIX_FIN_SI = ' (FIN, SI)';
        String SUFFIX_FIN = ' (FIN)';
        String SUFFIX_SI = ' (SI)';
        Map<Id, String> recordTypeMap = new Map<Id, String>();
        Set<RecordType> dpmrRecodType = getDPMRRecordType(); /**[TBD] To fix error occuring while many files at COPP Comfidential button */
        if(dpmrRecodType!=null){
            for (RecordType rt : dpmrRecodType) {
                recordTypeMap.put(rt.Id, rt.DeveloperName);
            }
        }    

        for (Evaluation__c evaluation : newEvaluations) {
            Evaluation__c oldEval = oldEvaluationsMap.get(evaluation.Id);
            if (recordTypeMap.containsKey(evaluation.RecordTypeId) || Test.isRunningTest()) {
                List<String> selectedValues = new List<String>();
                Boolean containsFinancial = false;
                Boolean containsSI = false;

                if (evaluation.Topics_HmaSales__c != null) {
                    selectedValues = evaluation.Topics_HmaSales__c.split(';');
                }
                if (evaluation.Topics_HmaService__c != null) {
                    selectedValues = evaluation.Topics_HmaService__c.split(';');
                }
                if (evaluation.Topics_GmaSales__c != null) {
                    selectedValues = evaluation.Topics_GmaSales__c.split(';');
                }
                if (evaluation.Topics_GmaService__c != null) {
                    selectedValues = evaluation.Topics_GmaService__c.split(';');
                }

                for (String value : selectedValues) {
                    if (value.contains('Financial Performance')) {
                        containsFinancial = true;
                        break;
                    }
                }

                for (String value : selectedValues) {
                    if (value.contains('Survey Integrity')) {
                        containsSI = true;
                        break;
                    }
                }

                if (evaluation.Topics_HmaSales__c != oldEval.Topics_HmaSales__c || evaluation.Topics_HmaService__c != oldEval.Topics_HmaService__c
                        || evaluation.Topics_GmaSales__c != oldEval.Topics_GmaSales__c || evaluation.Topics_GmaService__c != oldEval.Topics_GmaService__c) {

                    if (containsFinancial && containsSI && evaluation.Name != null) {
                        if (!evaluation.Name.contains(SUFFIX_FIN_SI) && !evaluation.Name.contains(SUFFIX_FIN) && !evaluation.Name.contains(SUFFIX_SI)) {
                            String[] parts = evaluation.Name.split(' - ');
                            if (parts.size() > 1) {
                                String newName = parts[0] + ' - ' + parts[1] + SUFFIX_FIN_SI + ' - ' + parts[2] + ' - ' + parts[3];
                                evaluation.Name = newName;
                            }
                        } else if (!evaluation.Name.contains(SUFFIX_FIN_SI) && evaluation.Name.contains(SUFFIX_FIN) && !evaluation.Name.contains(SUFFIX_SI)) {
                            String newName = evaluation.Name.replace(SUFFIX_FIN, SUFFIX_FIN_SI);
                            evaluation.Name = newName;
                        } else if (!evaluation.Name.contains(SUFFIX_FIN_SI) && !evaluation.Name.contains(SUFFIX_FIN) && evaluation.Name.contains(SUFFIX_SI)) {
                            String newName = evaluation.Name.replace(SUFFIX_SI, SUFFIX_FIN_SI);
                            evaluation.Name = newName;
                        }
                    } else if (!containsFinancial && containsSI && evaluation.Name != null) {
                        if (!evaluation.Name.contains(SUFFIX_FIN_SI) && !evaluation.Name.contains(SUFFIX_FIN) && !evaluation.Name.contains(SUFFIX_SI)) {
                            String[] parts = evaluation.Name.split(' - ');
                            if (parts.size() > 1) {
                                String newName = parts[0] + ' - ' + parts[1] + SUFFIX_SI + ' - ' + parts[2] + ' - ' + parts[3];
                                evaluation.Name = newName;
                            }
                        } else if (evaluation.Name.contains(SUFFIX_FIN_SI) && !evaluation.Name.contains(SUFFIX_FIN) && !evaluation.Name.contains(SUFFIX_SI)) {
                            String newName = evaluation.Name.replace(SUFFIX_FIN_SI, SUFFIX_SI);
                            evaluation.Name = newName;
                        } else if (!evaluation.Name.contains(SUFFIX_FIN_SI) && evaluation.Name.contains(SUFFIX_FIN) && !evaluation.Name.contains(SUFFIX_SI)) {
                            String newName = evaluation.Name.replace(SUFFIX_FIN, SUFFIX_SI);
                            evaluation.Name = newName;
                        }
                    } else if (containsFinancial && !containsSI && evaluation.Name != null) {
                        if (!evaluation.Name.contains(SUFFIX_FIN_SI) && !evaluation.Name.contains(SUFFIX_FIN) && !evaluation.Name.contains(SUFFIX_SI)) {
                            String[] parts = evaluation.Name.split(' - ');
                            if (parts.size() > 1) {
                                String newName = parts[0] + ' - ' + parts[1] + SUFFIX_FIN + ' - ' + parts[2] + ' - ' + parts[3];
                                evaluation.Name = newName;
                            }
                        } else if (evaluation.Name.contains(SUFFIX_FIN_SI) && !evaluation.Name.contains(SUFFIX_FIN) && !evaluation.Name.contains(SUFFIX_SI)) {
                            String newName = evaluation.Name.replace(SUFFIX_FIN_SI, SUFFIX_FIN);
                            evaluation.Name = newName;
                        } else if (!evaluation.Name.contains(SUFFIX_FIN_SI) && !evaluation.Name.contains(SUFFIX_FIN) && evaluation.Name.contains(SUFFIX_SI)) {
                            String newName = evaluation.Name.replace(SUFFIX_SI, SUFFIX_FIN);
                            evaluation.Name = newName;
                        }
                    } else {
                        if (evaluation.Name != null) {
                            if (evaluation.Name.contains(SUFFIX_FIN_SI)) {
                                String newName = evaluation.Name.replace(SUFFIX_FIN_SI, '');
                                evaluation.Name = newName;
                            } else if (evaluation.Name.contains(SUFFIX_FIN)) {
                                String newName = evaluation.Name.replace(SUFFIX_FIN, '');
                                evaluation.Name = newName;
                            } else if (evaluation.Name.contains(SUFFIX_SI)) {
                                String newName = evaluation.Name.replace(SUFFIX_SI, '');
                                evaluation.Name = newName;
                            }
                        }
                    }
                }
            }
        }
    } catch (Exception e) {
        System.debug('Exception in evaluationDPMRTopicChange: ' + e.getMessage());
    }
}



      /*
   * @method updateGenesisEvaluation() 
   * @desc DPM-5633
   * Prevent the record to be edited when the status is Completed
   * @param {List<Evaluation__c>} newEvaluations - new Evaluation list
   * @param {Map<Id, Evaluation__c>} oldEvaluationsMap 
   * Edited by [Minhee Kim] on [01-27-2025] for [TBD] To fix error occuring while many files at COPP Comfidential button
   */
     public static void updateGenesisEvaluation(List<Evaluation__c> newEvaluations,Map<Id, Evaluation__c> oldEvaluationsMap){
         /**Start - [TBD] To fix error occuring while many files at COPP Comfidential button */
        // String userProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        // RecordType salesRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Genesis_Retailer_Eval_Sales' LIMIT 1];
        // RecordType serviceRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Genesis_Retailer_Eval_Service' LIMIT 1];

        String userProfileName = getUserProfileName();
        RecordType salesRecType =  getSalesRecType();
        RecordType serviceRecType = getServiceRecType();
        /**End -[TBD] To fix error occuring while many files at COPP Comfidential button */
        for(Evaluation__c evaluation:newEvaluations) {
            Evaluation__c oldEval = oldEvaluationsMap.get(evaluation.Id);
            if(evaluation.RecordTypeId !=null && (evaluation.RecordTypeId==salesRecType.Id||evaluation.RecordTypeId==serviceRecType.Id)){

                if(oldEval.Action_Plan_Status__c =='Completed' && userProfileName != 'System Administrator'){
                    evaluation.addError('You cannot modify fields when the Status is Completed unless you are a System Administrator.');
                }
                
            }
        }
     }

     /**
     * [Method Description] COPP Project - Attach the tracker pdf to copp evaluation
     * Created by [MinheeKim] on [2024-09-23] for [DPM-5709]
    */
    public static void attachTrackerOnEval(List<Evaluation__c> newEvaluations){
        
       RecordType coppRecType = getCOPPRecType();  //[SELECT Id FROM RecordType WHERE DeveloperName = 'COPP_Confidential' LIMIT 1]; //[TBD] To fix error occuring while many files at COPP Comfidential button */
       List<Evaluation__c> coppEvaluations = new List<Evaluation__c>();

       Map<Id, COPPInfo__c> mapOfAccountCOPPInfo = new Map<Id, COPPInfo__c>();
        List<Id> accountIds = new List<Id>();
        for (Evaluation__c evaluation : newEvaluations) {
            if (Test.isRunningTest() || (evaluation.RecordTypeId != null && evaluation.RecordTypeId == coppRecType.Id)) {
                accountIds.add(evaluation.Account__c);
            }
        }

        List<COPPInfo__c> coppInofs = [SELECT Id, COPP__c, Buy_Sell_COPP__c, Account__c FROM COPPInfo__c WHERE Account__c IN :accountIds];

        if(coppInofs.size()>0){
            for (COPPInfo__c copp : coppInofs) {
                mapOfAccountCOPPInfo.put(copp.Account__c, copp);
            }
        }
            
       for (Evaluation__c evaluation : newEvaluations) {
           if (Test.isRunningTest() || (evaluation.RecordTypeId != null && evaluation.RecordTypeId == coppRecType.Id 
           && mapOfAccountCOPPInfo.containsKey(evaluation.Account__c) 
           && (mapOfAccountCOPPInfo.get(evaluation.Account__c).COPP__c || mapOfAccountCOPPInfo.get(evaluation.Account__c).Buy_Sell_COPP__c)) ) {
            coppEvaluations.add(evaluation);
           }
       }
   
       if (!coppEvaluations.isEmpty()) {
        GenerateQueueableCOPPEvaluation pdfGenerator = new GenerateQueueableCOPPEvaluation(coppEvaluations);
           System.enqueueJob(pdfGenerator);
       }

       
    }

    public class evalNameDuplException extends Exception {
    }

     /**
     * [Method Description] method to input the business last modified date, by
     * Created by [MinheeKim] on [02-04-2025] for [DPM-6017]
    */
    public static void updateBusinessLastmodified(List<Evaluation__c> newEvaluations,Map<Id, Evaluation__c> oldEvaluationsMap){
        String userProfileName = getUserProfileName();
        if(userProfileName==INTEGRATIONUSER || userProfileName==SYSTEMADMIN ){
            return;
        }

        for (Evaluation__c evaluation : newEvaluations) {
            evaluation.BusinessLastModifiedBy__c = UserInfo.getUserId();
            evaluation.BusinessLastModifiedDate__c = System.now();
        }
        
    }
     
}