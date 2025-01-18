public with sharing class BatchCheckThesholdsForEinsteinKPIs implements Database.Batchable<SObject>, Database.Stateful {
    
    public String query;
    public String einsteinKPIId;
    public String accountId;
    public Boolean dailyBatchProcess = false;
    public Boolean rescheduleDailyBatchProcess = false;

    Map<String, List<String>> mapOfKPIAccountActionPlans;
    Map<Id, Id> mapOfAccountEvaluations;
    Map<String, List<EinsteinKPIMapping__c>> mapOfEinsteinMappings;
    
    public BatchCheckThesholdsForEinsteinKPIs(String einsteinKPIId) {
        this.einsteinKPIId = einsteinKPIId;
    }

    public BatchCheckThesholdsForEinsteinKPIs(String einsteinKPIId, String accountId) {
        this.einsteinKPIId = einsteinKPIId;
        this.accountId = accountId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){ 

        if(query == null) {
            query = 'select Id, KPI__c, Account__c, Account__r.Region__c, Account__r.Organization__c, Account__r.ServiceDistrict__c, Account__r.SalesDistrict__c, Account__r.Market__c,  Account__r.HyundaiArea__c,  ';
            query += ' EinsteinKPI__c, KPISummary__c, KPI__r.Name, Account__r.Name, ';
            query += ' Label1_Value_Num__c, Label2_Value_Num__c, Label3_Value_Num__c, Label4_Value_Num__c, Label5_Value_Num__c, Label6_Value_Num__c, Label7_Value_Num__c, Label8_Value_Num__c, Label9_Value_Num__c, Label10_Value_Num__c, Label11_Value_Num__c, Label12_Value_Num__c, Label13_Value_Num__c, Label14_Value_Num__c, Label15_Value_Num__c, ';
            query += ' Label1_Value_Percent__c, Label2_Value_Percent__c, Label3_Value_Percent__c, Label4_Value_Percent__c, Label5_Value_Percent__c, Label6_Value_Percent__c, Label7_Value_Percent__c, Label8_Value_Percent__c, Label9_Value_Percent__c, Label10_Value_Percent__c, Label11_Value_Percent__c, Label12_Value_Percent__c, Label13_Value_Percent__c, Label14_Value_Percent__c, Label15_Value_Percent__c, ';
            query += ' Label1_Value_Curr__c, Label2_Value_Curr__c, Label3_Value_Curr__c, Label4_Value_Curr__c, Label5_Value_Curr__c, Label6_Value_Curr__c, Label7_Value_Curr__c, Label8_Value_Curr__c, Label9_Value_Curr__c, Label10_Value_Curr__c, Label11_Value_Curr__c, Label12_Value_Curr__c, Label13_Value_Curr__c, Label14_Value_Curr__c, Label15_Value_Curr__c ';
            query += ' from EinsteinKPIDetail__c ';
            String whereClause = '';
            if(einsteinKPIId != null) {
                whereClause += ' where EinsteinKPI__c = :einsteinKPIId';
            }
            if(accountId != null && whereClause == '') {
                whereClause += ' where Account__c = :accountId';
            }
            else if(accountId != null && whereClause != '') {
                whereClause += ' and Account__c = :accountId';
            }
            query += whereClause;
        }
        return Database.getQueryLocator(query);
    }

    public class ThresholdWrapper {
        public Integer thresholdsChecked {get; set;}
        public Integer thresholdsFailed {get; set;}
        public List<Id> failedThresholdIds {get; set;}
        public String failedThresholdDescription {get; set;} 
        public Action_Plan__c actionPlanToCreate {get; set;}
        public Evaluation__c evaluation {get; set;}
        public String actualValue {get; set;}
        public String actualValueType {get; set;}
        public String objectiveValue {get; set;}
        public String thresholdField {get; set;}

        public ThresholdWrapper() {
            this.thresholdsChecked = 0;
            this.thresholdsFailed = 0;
            this.failedThresholdIds = new List<Id>();
            this.failedThresholdDescription = '';
            this.actualValue = '';
            this.actualValueType = '';
            this.objectiveValue = '';
            this.thresholdField = '';
        }
    }

    public ThresholdWrapper processEinsteinKPIDetailForLevel(EinsteinKPIDetail__c einsteinKPIDetail, Map<Id, Map<Id, List<KPIThreshold__c>>> mapOfThresholds, String levelId) {

        ThresholdWrapper thresholdWrapper = new ThresholdWrapper();
        
        Decimal actual;
        Decimal objective;

        Integer thresholdsChecked = 0;
        Integer thresholdsFailed = 0;

        String failedThresholdsDescription = ''; 

        System.debug(LoggingLevel.ERROR, mapOfThresholds);
        System.debug(LoggingLevel.ERROR, einsteinKPIDetail);
        if(mapOfThresholds.containsKey(einsteinKPIDetail.KPI__c)) {
            if(mapOfThresholds.get(einsteinKPIDetail.KPI__c).containsKey(levelId)) {
                for(KPIThreshold__c threshold:mapOfThresholds.get(einsteinKPIDetail.KPI__c).get(levelId )) {
                    if(threshold.AnalyticThreshold__c) {
                        objective = (Decimal) einsteinKPIDetail.get(threshold.EinsteinKPIObjectiveMapping__r.Object_Field__c);
                    }
                    else {
                        if(threshold.AbsoluteValuePercentage__c != null) {
                            objective = threshold.AbsoluteValuePercentage__c;
                        }
                        else if(threshold.AbsoluteValueNumber__c != null) {
                            objective = threshold.AbsoluteValueNumber__c;
                        }
                    }
                    actual = (Decimal) einsteinKPIDetail.get(threshold.EinsteinKPIMapping__r.Object_Field__c);
                    
                    thresholdWrapper.actualValue = String.valueOf(actual);
                    thresholdWrapper.objectiveValue = String.valueOf(objective);
                    thresholdWrapper.thresholdField = threshold.ThresholdField__c;

                    Boolean thesholdFailed = EinsteinService.checkThreshold(actual, objective, threshold.ActualObjectiveComparator__c);
                    if(thesholdFailed) {
                        thresholdWrapper.thresholdsFailed++;
                        thresholdWrapper.failedThresholdIds.add(threshold.Id);
                        thresholdWrapper.failedThresholdDescription += threshold.ThresholdField__c + ' value of ' + actual + ' is ' + threshold.ActualObjectiveComparator__c + ' ' + objective + '<br/>'; 

                        if(threshold.AutoGenerateActionPlanForFailure__c && (!mapOfKPIAccountActionPlans.containsKey(einsteinKPIDetail.KPI__c) || !mapOfKPIAccountActionPlans.get(einsteinKPIDetail.KPI__c).contains(einsteinKPIDetail.Account__c))) {
                            Action_Plan__c actionPlan = EinsteinService.createActionPlanFromFailedEinsteinKPIDetail(einsteinKPIDetail, threshold.Id, thresholdWrapper.failedThresholdDescription );
                            if(mapOfAccountEvaluations.containsKey(actionPlan.Account__c)) {
                                actionPlan.Evaluation__c = mapOfAccountEvaluations.get(actionPlan.Account__c);
                            }
                            else{

                            }
                            
                            thresholdWrapper.actionPlanToCreate = actionPlan;

                            if(!mapOfKPIAccountActionPlans.containsKey(einsteinKPIDetail.KPI__c)) {
                                mapOfKPIAccountActionPlans.put(einsteinKPIDetail.KPI__c, new List<String>());
                            }
                            mapOfKPIAccountActionPlans.get(einsteinKPIDetail.KPI__c).add(einsteinKPIDetail.Account__c);
                        } 
                    }
                    thresholdWrapper.thresholdsChecked++;
                }
            }
            System.debug(LoggingLevel.ERROR, thresholdsChecked);
        }

        return thresholdWrapper;

    }

    private Map<Id, Id> getNonClosedEvaluationForLevelForAccounts(Set<String> accountIds) {

        Map<Id, Id> mapOfAccountEvaluations = new Map<Id, Id>();
        for(Evaluation__c eval:[select Id, Account__c from Evaluation__c where RecordType.DeveloperName = 'MonthlyPerformanceEvaluation' and Account__c in :accountIds and Status__c != 'Completed' and Status__c != 'Non-Compliant' order by StartDate__c]) {
            if(!mapOfAccountEvaluations.containsKey(eval.Account__c)) {
                mapOfAccountEvaluations.put(eval.Account__c, eval.Id);
            }
        }
        return mapOfAccountEvaluations;
    }

    public void execute(Database.BatchableContext BC, List<EinsteinKPIDetail__c> einsteinKPIDetails) {

        Set<String> kpiIds = EinsteinService.getListOfKPIIdsFromDetailRecords(einsteinKPIDetails);
        Set<String> einsteinKPIIds = EinsteinService.getListOfEinsteinKPIIdsFromDetailRecords(einsteinKPIDetails);
        Set<String> accountIds = EinsteinService.getListOfAccountIdsFromDetailRecords(einsteinKPIDetails);

        Map<Id, Map<Id, List<KPIThreshold__c>>> mapOfAccountThresholds = EinsteinService.getThresholdsForKPI(kpiIds, 'Account'); 
        Map<Id, Map<Id, List<KPIThreshold__c>>> mapOfRegionThresholds = EinsteinService.getThresholdsForKPI(kpiIds, 'Region'); 
        Map<Id, Map<Id, List<KPIThreshold__c>>> mapOfOrganizationThresholds = EinsteinService.getThresholdsForKPI(kpiIds, 'Organization'); 
        Map<Id, Map<Id, List<KPIThreshold__c>>> mapOfDistrictThresholds = EinsteinService.getThresholdsForKPI(kpiIds, 'District'); 
        //Map<Id, Map<Id, List<KPIThreshold__c>>> mapOfAccountKPIThresholds = EinsteinService.getAccountThresholdsForKPI(kpiIds, false);    
        mapOfEinsteinMappings = EinsteinService.getKPIFieldMappings(einsteinKPIIds, null);      
        mapOfKPIAccountActionPlans = EinsteinService.getOpenActionPlansForAccountAndKPIs(kpiIds, accountIds);
        mapOfAccountEvaluations = getNonClosedEvaluationForLevelForAccounts(accountIds);

        List<Action_Plan__c> actionPlansToCreate = new List<Action_Plan__c>();
        List<Evaluation__c> evaluationsToCreate = new List<Evaluation__c>();
        Map<Id, Evaluation__c> mapOfNewAccountEvaluations = new Map<Id, Evaluation__c>();
        
        System.debug(LoggingLevel.ERROR, mapOfAccountThresholds);                 

        RecordType otherRecordType = [select Id from RecordType where SObjectType = 'Evaluation__c' and DeveloperName = 'Other' limit 1];

        for(EinsteinKPIDetail__c einsteinKPIDetail:einsteinKPIDetails) {
            Decimal actual;
            Decimal objective;

            Integer thresholdsChecked = 0;
            Integer thresholdsFailed = 0;
            String failedThresholdsDescription = '';

            List<Id> failedThresholdIds = new List<Id>();

            ThresholdWrapper thresholdWrapper;

            thresholdWrapper = processEinsteinKPIDetailForLevel(einsteinKPIDetail, mapOfAccountThresholds, einsteinKPIDetail.Account__c);
            thresholdsChecked += thresholdWrapper.thresholdsChecked;
            thresholdsFailed += thresholdWrapper.thresholdsFailed;
            failedThresholdIds.addAll(thresholdWrapper.failedThresholdIds);
            failedThresholdsDescription  += thresholdWrapper.failedThresholdDescription;
            if(thresholdWrapper.actionPlanToCreate != null) {
                actionPlansToCreate.add(thresholdWrapper.actionPlanToCreate);
                if(thresholdWrapper.evaluation == null) {
                    Evaluation__c evalToCreate = new Evaluation__c(Account__c = thresholdWrapper.actionPlanToCreate.Account__c, RecordTypeId = otherRecordType.Id);
                    mapOfNewAccountEvaluations.put(thresholdWrapper.actionPlanToCreate.Account__c, evalToCreate);
                }
            }

            thresholdWrapper = processEinsteinKPIDetailForLevel(einsteinKPIDetail, mapOfRegionThresholds, einsteinKPIDetail.Account__r.Region__c);
            thresholdsChecked += thresholdWrapper.thresholdsChecked;
            thresholdsFailed += thresholdWrapper.thresholdsFailed;
            failedThresholdIds.addAll(thresholdWrapper.failedThresholdIds);
            failedThresholdsDescription  += thresholdWrapper.failedThresholdDescription;
            if(thresholdWrapper.actionPlanToCreate != null) {
                actionPlansToCreate.add(thresholdWrapper.actionPlanToCreate);
                if(thresholdWrapper.evaluation == null) {
                    Evaluation__c evalToCreate = new Evaluation__c(Account__c = thresholdWrapper.actionPlanToCreate.Account__c, RecordTypeId = otherRecordType.Id);
                    mapOfNewAccountEvaluations.put(thresholdWrapper.actionPlanToCreate.Account__c, evalToCreate);
                }
            }

            thresholdWrapper = processEinsteinKPIDetailForLevel(einsteinKPIDetail, mapOfOrganizationThresholds, einsteinKPIDetail.Account__r.Organization__c);
            thresholdsChecked += thresholdWrapper.thresholdsChecked;
            thresholdsFailed += thresholdWrapper.thresholdsFailed;
            failedThresholdIds.addAll(thresholdWrapper.failedThresholdIds);
            failedThresholdsDescription  += thresholdWrapper.failedThresholdDescription;
            if(thresholdWrapper.actionPlanToCreate != null) {
                actionPlansToCreate.add(thresholdWrapper.actionPlanToCreate);
                if(thresholdWrapper.evaluation == null) {
                    Evaluation__c evalToCreate = new Evaluation__c(Account__c = thresholdWrapper.actionPlanToCreate.Account__c, RecordTypeId = otherRecordType.Id);
                    mapOfNewAccountEvaluations.put(thresholdWrapper.actionPlanToCreate.Account__c, evalToCreate);
                }
            }

            einsteinKPIDetail.ThresholdsChecked__c = thresholdsChecked;
            einsteinKPIDetail.ThresholdsFailed__c = thresholdsFailed;

            einsteinKPIDetail.Threshold_Value__c = thresholdWrapper.objectiveValue;
            //einsteinKPIDetail.Key_Value__c =  thresholdWrapper.actualValue;

            if(thresholdsChecked > 0 && thresholdsFailed > 0) {
                einsteinKPIDetail.ThresholdStatus__c = 'Failed';
                einsteinKPIDetail.FailedThreshold__c = failedThresholdIds[0];
                einsteinKPIDetail.FailedThresholdDescription__c = failedThresholdsDescription;
            } 
            else if(thresholdsChecked > 0) {
                einsteinKPIDetail.ThresholdStatus__c = 'Success';
                einsteinKPIDetail.FailedThreshold__c = null;
                einsteinKPIDetail.FailedThresholdDescription__c = '';
            }
            einsteinKPIDetail.ApexJobId__c = bc.getJobId();
            if(thresholdsFailed > 0) {

            }
        }

        if(!einsteinKPIDetails.isEmpty()) {
            update einsteinKPIDetails;
        }

        if(!mapOfNewAccountEvaluations.values().isEmpty()) {
            insert mapOfNewAccountEvaluations.values();
        }

        if(!actionPlansToCreate.isEmpty()) {
            for(Action_Plan__c actionPlan:actionPlansToCreate) {
                if(actionPlan.Evaluation__c == null) {
                    actionPlan.Evaluation__c = mapOfNewAccountEvaluations.get(actionPlan.Account__c).Id;
                }
            }
            insert actionPlansToCreate;
        }
    }


    public void finish(Database.BatchableContext BC){

        if(dailyBatchProcess) {
            BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2();
            batchEinsteinJob.dailyBatchProcess = true;
            batchEinsteinJob.rescheduleDailyBatchProcess = rescheduleDailyBatchProcess;
            Database.executeBatch(batchEinsteinJob, 1);
        }
    }

}