public without sharing class KPISelectorController {

    public class KPISelectorWrapper {

        @AuraEnabled
        public String KPIName {get; set;} 

        @AuraEnabled
        public String einsteinKPIName {get; set;} 

        @AuraEnabled 
        public EvaluationKPIs__c evaluationKPI {get; set;} 

        @AuraEnabled 
        public EinsteinKPI__c einsteinKPI {get; set;} 

        @AuraEnabled
        public EinsteinKPIDetail__c einsteinKPIDetail {get; set;}

        @AuraEnabled
        public EinsteinKPIDetail__c regionEinsteinKPIDetail {get; set;}

        @AuraEnabled
        public EinsteinKPIDetail__c districtEinsteinKPIDetail {get; set;}
    
       public  KPISelectorWrapper() {
        
       }

        public KPISelectorWrapper(EvaluationKPIs__c evalKPI, EinsteinKPIDetail__c einsteinKPIDetail) {
            this.evaluationKPI = evalKPI;
            this.einsteinKPIDetail = einsteinKPIDetail;
        }
    }

    @AuraEnabled
    public static Map<Id, KPISelectorWrapper> getAllKPIsForOrganizationAndDivision(Evaluation__c eval){

        Map<Id, KPISelectorWrapper> kpiSelectorMap = new Map<Id, KPISelectorWrapper>();

        List<EinsteinKPI__c> mandatoryKPIs = [select Id,Name, KPI__c, KPI__r.Name, ActionPlanRequirement__c, Ranking__c from EinsteinKPI__c where RecordType.DeveloperName = :eval.Organization__c and Division__c = :eval.Type__c and
                                                ActionPlanRequirement__c = 'Mandatory' and Active__c=true order by Ranking__c asc];

        System.debug(LoggingLevel.ERROR, mandatoryKPIs);

        List<EinsteinKPI__c> optionalKPIs = [select Id,Name, KPI__c, KPI__r.Name, ActionPlanRequirement__c, Ranking__c from EinsteinKPI__c where RecordType.DeveloperName = :eval.Organization__c and Division__c = :eval.Type__c and
                                                ActionPlanRequirement__c = 'Optional' and Active__c=true order by Ranking__c,Name desc ];

        System.debug(LoggingLevel.ERROR, optionalKPIs);

        for(EinsteinKPI__c einsteinKPI:mandatoryKPIs) {
          
            KPISelectorWrapper kpiSelectorWrapper = new KPISelectorWrapper();
            //kpiSelectorWrapper.KPIName = einsteinKPI.KPI__r.Name;
            if(einsteinKPI.Ranking__c!=null ){
            kpiSelectorWrapper.KPIName = einsteinKPI.Name;
            kpiSelectorWrapper.einsteinKPIName = einsteinKPI.KPI__r.Name;

            kpiSelectorWrapper.evaluationKPI = new EvaluationKPIs__c(Evaluation__c = eval.Id, KPI__c = einsteinKPI.KPI__c);
            kpiSelectorWrapper.evaluationKPI.EvalKPIExternalID__c = eval.Id + '-' + einsteinKPI.KPI__c;
            kpiSelectorWrapper.einsteinKPI = einsteinKPI;
            kpiSelectorMap.put(einsteinKPI.KPI__c, kpiSelectorWrapper);}
        }
        for(EinsteinKPI__c einsteinKPI:optionalKPIs) {
            if(einsteinKPI.Ranking__c!=null){
            KPISelectorWrapper kpiSelectorWrapper = new KPISelectorWrapper();
            kpiSelectorWrapper.KPIName = einsteinKPI.Name;
            kpiSelectorWrapper.einsteinKPIName = einsteinKPI.KPI__r.Name;
            kpiSelectorWrapper.evaluationKPI = new EvaluationKPIs__c(Evaluation__c = eval.Id, KPI__c = einsteinKPI.KPI__c);
            kpiSelectorWrapper.evaluationKPI.EvalKPIExternalID__c = eval.Id + '-' + einsteinKPI.KPI__c;
            kpiSelectorWrapper.einsteinKPI = einsteinKPI;
            kpiSelectorMap.put(einsteinKPI.KPI__c, kpiSelectorWrapper);}
        }
        return kpiSelectorMap;
    }

    @AuraEnabled
    public static List<KPISelectorWrapper> getEinsteinKPIDetailsForEvaluation(String evaluationId) {
        
        List<KPISelectorWrapper> kpiSelectorWrappers = new List<KPISelectorWrapper>();
        Evaluation__c evaluation = [select Id,Name, Account__c, Type__c, Organization__c, Region__c, RegionRef__c, SalesDistrict__c, ServiceDistrict__c,MarketRef__c from Evaluation__c where Id = :evaluationId limit 1];  //Made chnages for DPM-3802
        Map<Id, KPISelectorWrapper> kpiSelectorMap = getAllKPIsForOrganizationAndDivision(evaluation);
        Map<Id, EvaluationKPIs__c> einsteinKPIDetailEinsteinKPIMap = new Map<Id, EvaluationKPIs__c>();
        Map<Id, EvaluationKPIs__c> EinsteinKPIMapForActionPlan = new Map<Id, EvaluationKPIs__c>();
        Map<Id, EinsteinKPIDetail__c> einsteinKPIDetailMap = new Map<Id, EinsteinKPIDetail__c>();


        for(EvaluationKPIs__c evalKPI:[select Id, EinsteinKPIDetail__c, Evaluation__c, KPI__c, ActionPlan__c, ActionPlanReviewRequired__c, EvalKPIExternalID__c, Include_in_PDF__c
                                                             from EvaluationKPIs__c where Evaluation__c = :evaluation.Id ]) {
            einsteinKPIDetailEinsteinKPIMap.put(evalKPI.KPI__c, evalKPI);
            if(evalKPI.EinsteinKPIDetail__c==null && evalKPI.ActionPlan__c!=null){
                EinsteinKPIMapForActionPlan.put(evalKPI.KPI__c,evalKPI);
            }
        }

        for(EinsteinKPIDetail__c einsteinKPIDetail:getEinsteinKPIDetailsByCriteria(evaluation, evaluation.Type__c, 'Mandatory')) {
            System.debug(LoggingLevel.ERROR, einsteinKPIDetail);
            //einsteinKPIDetailMap.put(einsteinKPIDetail.KPI__c, einsteinKPIDetail);
            system.debug('eval kpi in 98' + einsteinKPIDetail.Key_Value__c );
            EvaluationKPIs__c evalKPI;
            if(einsteinKPIDetailEinsteinKPIMap.containsKey(einsteinKPIDetail.KPI__c)) {
                evalKPI = einsteinKPIDetailEinsteinKPIMap.get(einsteinKPIDetail.KPI__c);
            }
            else {
                evalKPI = new EvaluationKPIs__c(Evaluation__c = evaluationId, KPI__c = einsteinKPIDetail.KPI__c, EinsteinKPIDetail__c = einsteinKPIDetail.Id);
                evalKPI.EvalKPIExternalID__c = evaluationId + '-' + einsteinKPIDetail.KPI__c;
                if(einsteinKPIDetail.ThresholdStatus__c == 'Failed' &&  einsteinKPIDetail.EinsteinKPI__r.ActionPlanRequirement__c == 'Mandatory'){
                    evalKPI.ActionPlanReviewRequired__c = true;
                    evalKPI.Include_in_PDF__c = true;
                }
            }
            System.debug(LoggingLevel.ERROR,evalKPI);
            System.debug(LoggingLevel.ERROR, kpiSelectorMap.get(einsteinKPIDetail.KPI__c));
            System.debug(LoggingLevel.ERROR, einsteinKPIDetail);
            if(kpiSelectorMap.get(einsteinKPIDetail.KPI__c)!=null){
            KPISelectorWrapper kpiSelectorWrapper = kpiSelectorMap.get(einsteinKPIDetail.KPI__c);
            kpiSelectorWrapper.evaluationKPI = evalKPI;
                kpiSelectorWrapper.einsteinKPIDetail = einsteinKPIDetail;
        	}  
        }
        
        for(EinsteinKPIDetail__c einsteinKPIDetail:getRegionEinsteinKPIDetailsByCriteria(evaluation, evaluation.Type__c, 'Mandatory')) {
            KPISelectorWrapper kpiSelectorWrapper = new KPISelectorWrapper();
            if( kpiSelectorMap.get(einsteinKPIDetail.KPI__c)==null){
                continue;
            }
            kpiSelectorWrapper= kpiSelectorMap.get(einsteinKPIDetail.KPI__c);
            
            if(einsteinKPIDetail.Region__c != null) {
                kpiSelectorWrapper.regionEinsteinKPIDetail = einsteinKPIDetail;
            }
            else if(einsteinKPIDetail.District__c != null) {
                kpiSelectorWrapper.districtEinsteinKPIDetail = einsteinKPIDetail;
            }
        }

        for(EinsteinKPIDetail__c einsteinKPIDetail:getEinsteinKPIDetailsByCriteria(evaluation, evaluation.Type__c, 'Optional')) {
            einsteinKPIDetailMap.put(einsteinKPIDetail.KPI__c, einsteinKPIDetail);
            if( kpiSelectorMap.get(einsteinKPIDetail.KPI__c)==null){
                continue;
            }
			 
            EvaluationKPIs__c evalKPI;
            if(einsteinKPIDetailEinsteinKPIMap.containsKey(einsteinKPIDetail.KPI__c)) {
                evalKPI = einsteinKPIDetailEinsteinKPIMap.get(einsteinKPIDetail.KPI__c);
            }
            else {
                evalKPI = new EvaluationKPIs__c(Evaluation__c = evaluationId, KPI__c = einsteinKPIDetail.KPI__c, EinsteinKPIDetail__c = einsteinKPIDetail.Id);
                evalKPI.EvalKPIExternalID__c = evaluationId + '-' + einsteinKPIDetail.KPI__c;
            }
            KPISelectorWrapper kpiSelectorWrapper = new KPISelectorWrapper();
            
               kpiSelectorWrapper= kpiSelectorMap.get(einsteinKPIDetail.KPI__c);
            kpiSelectorWrapper.evaluationKPI = evalKPI;
            system.debug('eval kpi in 143' + einsteinKPIDetail.KPI__c );
                kpiSelectorWrapper.einsteinKPIDetail = einsteinKPIDetail;
        }
        
        for(EinsteinKPIDetail__c einsteinKPIDetail:getRegionEinsteinKPIDetailsByCriteria(evaluation, evaluation.Type__c, 'Optional')) {
            KPISelectorWrapper kpiSelectorWrapper = new KPISelectorWrapper();
            if( kpiSelectorMap.get(einsteinKPIDetail.KPI__c)==null){
                continue;
            }
            kpiSelectorWrapper= kpiSelectorMap.get(einsteinKPIDetail.KPI__c);
            
            if(einsteinKPIDetail.Region__c != null) {
                kpiSelectorWrapper.regionEinsteinKPIDetail = einsteinKPIDetail;
            }
            else if(einsteinKPIDetail.District__c != null) {
                kpiSelectorWrapper.districtEinsteinKPIDetail = einsteinKPIDetail;
            }
        }

        for(EvaluationKPIs__c evalKPI:EinsteinKPIMapForActionPlan.values()) {
            
            evalKPI.EvalKPIExternalID__c = evalKPI.id + '-' + evalKPI.KPI__c;
            evalKPI.ActionPlanReviewRequired__c = true;
            evalKPI.Include_in_PDF__c = true;
            
            System.debug(LoggingLevel.ERROR, kpiSelectorMap);
            KPISelectorWrapper kpiSelectorWrapper = kpiSelectorMap.get(evalKPI.KPI__c);
            kpiSelectorWrapper.evaluationKPI = evalKPI;
            system.debug('eval kpi in 173' + evalKPI.ActionPlan__c );     
        }
      return kpiSelectorMap.values();
       

    }

    private static List<EinsteinKPIDetail__c> getEinsteinKPIDetailsByCriteria(Evaluation__c evaluation, String evaluationType, String actionPlanRequirement) {
        String accountId = evaluation.Account__c;

        String sql = 'select Id, KPI__c, KPI__r.Name,EinsteinKPI__r.Name,Dashboard_table_record__c, ThresholdStatusIcon__c, ThresholdStatus__c, EinsteinKPI__r.ActionPlanRequirement__c, Key_Value__c, Threshold_Value__c, EinsteinKPI__r.Ranking__c,Region__c, District__c ';
        sql += ' from EinsteinKPIDetail__c where Account__c = :accountId and EinsteinKPI__r.ActionPlanRequirement__c = :actionPlanRequirement ';
        sql += ' and KPI__c != null and EinsteinKPI__r.Division__c = :evaluationType ';
        if(evaluationType == 'Mandatory') {
            sql +=  ' order by EinsteinKPI__r.Ranking__c ';
        }
        else {
            sql +=  ' order by ThresholdStatus__c desc, EinsteinKPI__r.Ranking__c ';
        }
        
        List<EinsteinKPIDetail__c> einsteinKPIDetails = Database.query(sql);
        System.debug(LoggingLevel.ERROR, einsteinKPIDetails);

        return einsteinKPIDetails;
    }
    
    private static List<EinsteinKPIDetail__c> getRegionEinsteinKPIDetailsByCriteria(Evaluation__c evaluation, String evaluationType, String actionPlanRequirement) {
        
        String regionId = evaluation.RegionRef__c;
        String salesDistrictId = evaluation.SalesDistrict__c;
        String serviceDistrictId = evaluation.ServiceDistrict__c;
		String districtId = evaluation.MarketRef__c;	
        String likeValue = '%G-%';
        System.debug(LoggingLevel.ERROR, regionId);
        
        String regsql = 'select Id, KPI__c, KPI__r.Name,EinsteinKPI__r.Name,EinsteinKPI__r.Dealer_Value_is_High__c,Dashboard_table_record__c, ThresholdStatusIcon__c, ThresholdStatus__c, EinsteinKPI__r.ActionPlanRequirement__c, Key_Value__c, Threshold_Value__c, EinsteinKPI__r.Ranking__c, Region__c, District__c ';
        //regsql += ' from EinsteinKPIDetail__c where (Region__c = :regionId or District__c = :salesDistrictId or District__c = :serviceDistrictId or District__c = :districtId) and EinsteinKPI__r.ActionPlanRequirement__c = :actionPlanRequirement ';
        //regsql += ' from EinsteinKPIDetail__c where ((Region__c = :regionId and (District__c = :salesDistrictId or District__c = :serviceDistrictId)) or (Region__c = :regionId or District__c = :districtId)) and EinsteinKPI__r.ActionPlanRequirement__c = :actionPlanRequirement ';
         System.debug('First likeValue '+likeValue+ 'regionId '+regionId+' districtId '+districtId+' actionPlanRequirement '+actionPlanRequirement);
          
        if(districtId != null){
            System.debug('second likeValue '+likeValue+ 'regionId '+regionId+' districtId '+districtId+' actionPlanRequirement '+actionPlanRequirement);
           regsql += ' from EinsteinKPIDetail__c where (EinsteinKPI__r.Name LIKE : likeValue) AND (Region__c = :regionId or District__c = :districtId) and EinsteinKPI__r.ActionPlanRequirement__c = :actionPlanRequirement '; 
        }else{
         regsql += ' from EinsteinKPIDetail__c where (NOT EinsteinKPI__r.Name LIKE : likeValue) AND (Region__c = :regionId or District__c = :salesDistrictId or District__c = :serviceDistrictId) and EinsteinKPI__r.ActionPlanRequirement__c = :actionPlanRequirement ';   
        }
        regsql += ' and KPI__c != null and EinsteinKPI__r.Division__c = :evaluationType ';
        if(evaluationType == 'Mandatory') {
            regsql +=  ' order by EinsteinKPI__r.Ranking__c ';
        }
        else {
            regsql +=  ' order by ThresholdStatus__c desc, EinsteinKPI__r.Ranking__c ';
        }
        System.debug('regsql '+regsql);
        List<EinsteinKPIDetail__c> einsteinKPIDetails = Database.query(regsql);
        System.debug('Region Values: '+ einsteinKPIDetails);

        return einsteinKPIDetails;
    }
 
    @AuraEnabled
    public static String saveEvaluationKPIRecord(String evaulationKPIJSON){

        try {
            System.debug('####evaulationKPIJSON: '+evaulationKPIJSON);
            EvaluationKPIs__c evaluationKPI = (EvaluationKPIs__c)System.JSON.deserializeStrict(evaulationKPIJSON, EvaluationKPIs__c.class);
			String DashboardGridData='';
            Evaluation__c evaluation = [select Id, Type__c from Evaluation__c where Id = :evaluationKPI.Evaluation__c];
            KPI__c kpi = [select Id, Name from KPI__c where Id = :evaluationKPI.KPI__c];
            
            //--Neeraj Grid Issue resolved hence code is commented 
            /*if(evaluationKPI.EinsteinKPIDetail__c!=null){
                system.debug('evaluationKPI.EinsteinKPIDetail__c id is '+evaluationKPI.EinsteinKPIDetail__c );
                for(EinsteinKPIDetail__c einsDetails : [select id,EinsteinKPI__r.Einstein_KPI_Grid__c,  Account__r.DealerCode__c,  KPI__c from EinsteinKPIDetail__c where id=:evaluationKPI.EinsteinKPIDetail__c]){
                   system.debug('EinsteinKPIDetail__c '+einsDetails);
                    if(einsDetails.EinsteinKPI__r.Einstein_KPI_Grid__c!=null &&  einsDetails.Account__r.DealerCode__c!=null ){//&& einsDetails.DealerCode__c!=null
                     system.debug('einsDetails.EinsteinKPI__r.Einstein_KPI_Grid__c '+einsDetails.EinsteinKPI__r.Einstein_KPI_Grid__c);
                        EinsteinKPIDetail__c einsGridKPIDetail=  [select id,Dashboard_table_record__c,DealerCode__c from EinsteinKPIDetail__c where EinsteinKPI__c=:einsDetails.EinsteinKPI__r.Einstein_KPI_Grid__c and DealerCode__c =:einsDetails.Account__r.DealerCode__c limit 1];
                    DashboardGridData=einsGridKPIDetail.Dashboard_table_record__c;
                         system.debug('DashboardGridData '+DashboardGridData);
                    }
                } 
            }*/
            if(evaluationKPI.ActionPlanReviewRequired__c && evaluationKPI.ActionPlan__c == null) {
                String accId = NULL;
                if(evaluationKPI.Evaluation__c != NULL) {
                    accId = [SELECT Id, Account__c 
                             FROM Evaluation__c 
                             WHERE Id =:evaluationKPI.Evaluation__c 
                             AND Account__c != NULL LIMIT 1].Account__c;
                }
                System.debug('accId '+accId);
                
                Action_Plan__c actionPlan = new Action_Plan__c();
                actionPlan.Evaluation__c = evaluationKPI.Evaluation__c;
        
                System.debug('action evaluationKPI.KPI__c' + evaluationKPI.KPI__c);
                actionPlan.KPI__c = evaluationKPI.KPI__c;
                actionPlan.Name = evaluation.Type__c + ' - ' + kpi.Name;
                actionPlan.EinsteinKPIDetail__c = evaluationKPI.EinsteinKPIDetail__c;
                actionPlan.InitialKPISnapshotValue__c = evaluationKPI.Initial_Key_Value__c;
                actionPlan.KPIThresholdValue__c = evaluationKPI.Initial_Threshold_Value__c;
                actionplan.Dashboard_table_record__c=DashboardGridData;
                if(String.isNotBlank(accId)) {
                    actionPlan.Account__c = accId;
                }
                insert actionPlan;
                System.debug('action plan' + actionPlan);

                evaluationKPI.ActionPlan__c = actionPlan.Id;
            }

            upsert  evaluationKPI EvalKPIExternalID__c;  
        }
        catch(Exception e) {
            System.debug('action plan is fail' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
        return 'Success';
    }
}