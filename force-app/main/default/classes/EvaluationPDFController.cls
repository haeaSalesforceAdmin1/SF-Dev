public without sharing class EvaluationPDFController {
    
    public String evaluationId {get; set;}
    public EvaluationWrapper evaluationWrapper {get; set;}
    public Boolean showFinancials {get; set;}
    public Boolean showApprovals {get; set;}
    public KPISelectorController.KPISelectorWrapper[] kpiSelectorWrapper{get; set;}
    
    public EvaluationPDFController() {
        showFinancials = true;
        showApprovals = true;
        System.debug(LoggingLevel.ERROR, 'PDF Controller');
        evaluationId = ApexPages.currentPage().getParameters().get('id');
              
        if(ApexPages.currentPage().getParameters().get('showFinancials') != null) {
            String showFinancicalsString = ApexPages.currentPage().getParameters().get('showFinancials');
            if(showFinancicalsString == 'false') {
                showFinancials = false;    
            }
        }
        
        if(ApexPages.currentPage().getParameters().get('showApprovals') != null) {
            String showApprovalsString = ApexPages.currentPage().getParameters().get('showApprovals');
            if(showApprovalsString == 'false') {
                showApprovals = false;
            }
        }
        
        handleLoad();
        
        
    }
    
    
    public List<ContentDocumentLink> getContentDocumentsForEntities(Set<Id> entityIds) {
        
        System.debug(LoggingLevel.ERROR, entityIds);
        List<ContentDocumentLink> contentDocumentLinks = [select ContentDocument.LatestPublishedVersionId, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, LinkedEntityId from ContentDocumentLink where LinkedEntityId in :entityIds and ContentDocument.LatestPublishedVersion.SystemGeneratedPDF__c = false];
        
        return contentDocumentLinks;
    }
    
    public void handleLoad() {
        
        Boolean hasGenesisFinancialPermission = FeatureManagement.checkPermission('Financial_Data_GMA');
        Boolean hasHyundaiFinancialPermission = FeatureManagement.checkPermission('FinancialDataHMA');
        
        Evaluation__c evaluation = [select Id, Name, Account__r.Name, Organization__c, Status__c, Total_Score__c, Pass_Fail__c, Survey__c, Owner.Name, Owner.Email, Owner.Phone, Account__r.Organization__r.Name,
                                    of_Completed_Action_Plans__c, of_Non_Compliant_Action_Plans__c, EndDate__c, Survey__r.Name, StartDate__c, DueDate__c, Account__r.DealerCode__c, Type__c, RecordType.DeveloperName from Evaluation__c where Id = :evaluationId];
        
         if (evaluation != NULL && evaluation.Account__r.DealerCode__c != NULL && evaluation.Type__c != NULL && evaluation.StartDate__c != NULL) {
             String tmpName = '';
             if (evaluation.RecordType.DeveloperName == 'MonthlyPerformanceEvaluation' || evaluation.RecordType.DeveloperName == 'Other'){
                 tmpName = evaluation.Name;
             } else if (evaluation.RecordType.DeveloperName != 'MonthlyPerformanceEvaluation' && evaluation.Organization__c == 'Hyundai'){
                 tmpName = 'CEE';
             }else if (evaluation.RecordType.DeveloperName != 'MonthlyPerformanceEvaluation' && evaluation.Organization__c == 'Genesis'){
                 tmpName = 'Genesis';
             }
             String quarter = (evaluation.Survey__c != NULL ? (String.isNotBlank(evaluation.Survey__r.Name) ? ((evaluation.Survey__r.Name).contains('Q1') ? 'Q1' : ((evaluation.Survey__r.Name).contains('Q2') ? 'Q2' : ((evaluation.Survey__r.Name).contains('Q3') ? 'Q3' : 'Q4'))) : '') : '' );
           Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+evaluation.Account__r.DealerCode__c+' '+(evaluation.StartDate__c).year()+' '+(String.isNotBlank(quarter) ? quarter+' ' : '')+tmpName+' - '+evaluation.Type__c+' - EvaluationPDF.pdf'); 
          
        }
        evaluationWrapper = new EvaluationWrapper(evaluation);
        List<ContentDocumentLink> evaluationContentDocumentLinks = getContentDocumentsForEntities(new Set<Id>{evaluation.Id});
        for(ContentDocumentLink contentDocumentLink:evaluationContentDocumentLinks) {
            evaluationWrapper.evaluationDocumentIds.add(new File(contentDocumentLink.ContentDocument.FileExtension, contentDocumentLink.ContentDocument.LatestPublishedVersionId, contentDocumentLink.ContentDocument.FileExtension));
        }
        
        System.debug(LoggingLevel.ERROR, evaluation);
        Map<Id, ProcessInstance> evaluationApprovalHistory = getProcessHistory(new Set<Id>{evaluation.Id});
        
        Map<Id, ActionPlanWrapper> actionPlanWrapperMap = new Map<Id, ActionPlanWrapper>();
        List<ActionPlanWrapper> actionPlanWrappers = new List<ActionPlanWrapper>();
        List<Id> actionPlanIds = new List<Id>();
        Map<Id, String> dashboardTableDataMap = new Map<Id, String>();
        Integer actionPlanCount = 0;
        Integer inProgressActionPlanCount = 0;
        Integer nonCompliantActionPlanCount = 0;
        Integer compliantActionPlanAccount = 0;
        Integer carryOverActionPlanAccount = 0;
        List<Id> listCarryOverSurveyques = new List<Id>();
        boolean isDashboardDataPresent=false;
        
        for(Action_Plan__c actionPlan:[select Id, Name, Status__c,Dashboard_table_record__c, ApprovalStatus__c, DateInitiated__c, DueDate__c, HMAInternalSummary__c, HMASurveyQuestion__c, DPMCategory__c, SummaryDealer__c, 
                                       Question_Failed_Official__c,KPI__c, KPI__r.Category__c,RelatedSurvey__c, Question_Failed__c, Is_Carried_Over__c,Is_Carry_Over_Button_Clicked__c FROM Action_Plan__c where Evaluation__c = :evaluationId]) {
                                           
                                           ActionPlanWrapper actionPlanWrapper = new ActionPlanWrapper(actionPlan);
                                           
                                           if(actionPlan.KPI__c != null && actionPlan.KPI__r.Category__c == 'Financial') {
                                               if((evaluation.Organization__c == 'Hyundai' && showFinancials && hasHyundaiFinancialPermission) ||  (evaluation.Organization__c == 'Genesis' && showFinancials && hasGenesisFinancialPermission)) {
                                                   actionPlanWrappers.add(actionPlanWrapper);
                                                   actionPlanWrapperMap.put(actionPlan.Id, actionPlanWrapper);
                                               }
                                           }
                                           else {
                                               actionPlanWrappers.add(actionPlanWrapper);
                                               actionPlanWrapperMap.put(actionPlan.Id, actionPlanWrapper);
                                           }
                                           if(actionPlan.Dashboard_table_record__c!=null){
                                               dashboardTableDataMap.put(actionPlan.KPI__c,actionPlan.Dashboard_table_record__c);
                                           }
                                           actionPlanCount++;
                                           
                                           if(actionPlan.Status__c == 'Compliant') {
                                               compliantActionPlanAccount++;
                                                if (actionPlan.Is_Carried_Over__c && actionPlan.RelatedSurvey__c != NULL && actionPlan.HMASurveyQuestion__c != NULL
                                                    && actionPlan.Question_Failed__c != NULL && actionPlan.Question_Failed_Official__c != NULL) {
                                                       
                                                listCarryOverSurveyques.add(actionPlan.HMASurveyQuestion__c); 
                                                    }
                                            
                                           }
                                           else if(actionPlan.Status__c == 'Non-Compliant') {
                                               nonCompliantActionPlanCount++;

                                               if (actionPlan.Is_Carried_Over__c && actionPlan.RelatedSurvey__c != NULL && actionPlan.HMASurveyQuestion__c != NULL
                                                    && actionPlan.Question_Failed__c != NULL && actionPlan.Question_Failed_Official__c != NULL) {
                                                       
                                                listCarryOverSurveyques.add(actionPlan.HMASurveyQuestion__c); 
                                                    }
                                               
                                           } else if(actionPlan.Is_Carried_Over__c ) {
                                               if (actionPlan.RelatedSurvey__c != NULL && actionPlan.HMASurveyQuestion__c != NULL
                                                   && actionPlan.Question_Failed__c != NULL && actionPlan.Question_Failed_Official__c != NULL) {
                                                      
                                               listCarryOverSurveyques.add(actionPlan.HMASurveyQuestion__c); 
                                                   }
                                               carryOverActionPlanAccount++;
                                           } else if(actionPlan.Is_Carry_Over_Button_Clicked__c && actionPlan.Status__c == 'Carry Over') {
                                            if (actionPlan.RelatedSurvey__c != NULL && actionPlan.HMASurveyQuestion__c != NULL
                                                && actionPlan.Question_Failed__c != NULL && actionPlan.Question_Failed_Official__c != NULL) {
                                                   
                                           // listCarryOverSurveyques.add(actionPlan.HMASurveyQuestion__c); 
                                                }
                                            carryOverActionPlanAccount++;
                                        }
                                           else {
                                               inProgressActionPlanCount++;
                                           }
                                       }

                                       for (Evaluation__c eval : [SELECT Id, Count_of_AP_Carried_Over_to_Next_Quarter__c 
                                                                  FROM Evaluation__c 
                                                                  WHERE Id=: evaluationId]) {
                                                                  if (eval.Count_of_AP_Carried_Over_to_Next_Quarter__c != NULL && eval.Count_of_AP_Carried_Over_to_Next_Quarter__c > 0) {
                                                                    carryOverActionPlanAccount += Integer.valueOf(eval.Count_of_AP_Carried_Over_to_Next_Quarter__c);
                                                                    actionPlanCount+= carryOverActionPlanAccount;
                                                                  }  
                                       }
        
        evaluationWrapper.standardActionPlanCount = actionPlanCount;
        evaluationWrapper.actionPlanCountInProgress = inProgressActionPlanCount;
        evaluationWrapper.actionPlanCountNonCompliant = nonCompliantActionPlanCount;
        evaluationWrapper.actionPlanCountCompliant = compliantActionPlanAccount;
        evaluationWrapper.actionPlanCountCarryOver = carryOverActionPlanAccount;
        
        Map<Id, ProcessInstance> actionPlanApprovalHistoryMap = getProcessHistory(actionPlanWrapperMap.keySet());
        System.debug(LoggingLevel.ERROR, actionPlanApprovalHistoryMap);
        for(Id actionPlanId:actionPlanApprovalHistoryMap.keyset()) {
            if (actionPlanWrapperMap != NULL && actionPlanWrapperMap.containsKey(actionPlanId)) {
                ActionPlanWrapper actionPlanWrapper = actionPlanWrapperMap.get(actionPlanId);
                if (actionPlanApprovalHistoryMap.containsKey(actionPlanId)) {
               actionPlanWrapper.processInstance = actionPlanApprovalHistoryMap.get(actionPlanId);
            }
            }
            
        }
        
        if(!actionPlanWrapperMap.keySet().isEmpty()) {
            List<ContentDocumentLink> actionPlanContentDocumentLinks = getContentDocumentsForEntities(actionPlanWrapperMap.keySet());
            for(ContentDocumentLink contentDocumentLink:actionPlanContentDocumentLinks) {
                ActionPlanWrapper actionPlanWrapper = actionPlanWrapperMap.get(contentDocumentLink.LinkedEntityId);
                actionPlanWrapper.actionPlanDocumentIds.add(new File(contentDocumentLink.ContentDocument.FileExtension, contentDocumentLink.ContentDocument.LatestPublishedVersionId, contentDocumentLink.ContentDocument.Title));
            }
        }
        
        //getSurveyDetails();
        //buildSurveyQuestionWrapper();
        List<EvaluationKPIs__c> evaluationKPIs = new List<EvaluationKPIs__c>();
        List<EvaluationKPIs__c> evaluationKPIsUpdate = new List<EvaluationKPIs__c>();
        String sql = 'select Id, KPI__r.Name, Initial_Threshold_Value__c,EinsteinKPIDetail__c, KPI__r.Category__c, EinsteinKPIDetail__r.ThresholdStatusIcon__c, EinsteinKPIDetail__r.ThresholdStatus__c, Initial_Key_Value__c from EvaluationKPIs__c where Evaluation__c = :evaluationId and Include_in_PDF__c = true';
        if((evaluation.Organization__c == 'Hyundai' && (!showFinancials || !hasHyundaiFinancialPermission)) ||  (evaluation.Organization__c == 'Genesis' && (!showFinancials  || !hasGenesisFinancialPermission))) {
            sql += ' and KPI__r.Category__c != \'Financial\'';
        }

        System.debug('sql -->> '+sql);
        evaluationKPIs = Database.query(sql); 
        List<String> EinsteinKPIidList = new List<String>();
        for(EvaluationKPIs__c evkpi:evaluationKPIs){
            EinsteinKPIidList.add(evkpi.KPI__r.Name);
        }
         kpiSelectorWrapper= new List<KPISelectorController.KPISelectorWrapper>();
        if(EinsteinKPIidList.size()>0){    
        kpiSelectorWrapper=KPISelectorController.getEinsteinKPIDetailsForEvaluation(evaluationId);
        }
        System.debug('kpiSelectorWrapper ::: -->> '+kpiSelectorWrapper);
        List<EvaluationKPIsDetails> evalKPIDetailsList = new List<EvaluationKPIsDetails>();
        if(kpiSelectorWrapper!=null) { 
        for(KPISelectorController.KPISelectorWrapper KPISelector:kpiSelectorWrapper){
              if(!EinsteinKPIidList.contains(KPISelector.einsteinKPIName)){
                  continue;
              }
            EvaluationKPIsDetails evalKPIdetail = new EvaluationKPIsDetails();
                EinsteinKPIDetail__c regionEinsteinKPIDetail=KPISelector.regionEinsteinKPIDetail;
                evalKPIdetail.einsteinKPIDetail = new EinsteinKPIDetail__c();
                evalKPIdetail.regionEinsteinKPIDetail = new EinsteinKPIDetail__c();
                evalKPIdetail.districtEinsteinKPIDetail =  new EinsteinKPIDetail__c();
                evalKPIdetail.kpiname = KPISelector.KPIName;
            	evalKPIdetail.einsteinKPI =  new EinsteinKPI__c();
           		
            	
               	if(KPISelector.einsteinKPIDetail != null && KPISelector.einsteinKPIDetail.Key_Value__c != null && !KPISelector.einsteinKPIDetail.Key_Value__c.startsWith('null')) {
                    evalKPIdetail.einsteinKPIDetail = KPISelector.einsteinKPIDetail;
                    evalKPIdetail.einsteinKPIDetail.Key_Value__c = KPISelector.einsteinKPIDetail.Key_Value__c;
                    evalKPIdetail.einsteinKPIDetail.Threshold_Value__c = KPISelector.einsteinKPIDetail.Threshold_Value__c;
                   if(!dashboardTableDataMap.isEmpty() && dashboardTableDataMap.containsKey(KPISelector.einsteinKPIDetail.KPI__c))
                   {evalKPIdetail.dashboardTableData = (dashboardTableDataMap.get(KPISelector.einsteinKPIDetail.KPI__c));
                   isDashboardDataPresent=true;
                   }
                }
            for(EinsteinKPIDetail__c einsteinKPIDealer : [SELECT  EinsteinKPI__r.Dealer_Value_is_High__c from EinsteinKPIDetail__c  where Id = :evalKPIdetail.einsteinKPIDetail.Id]){
            	//if(einsteinKPIDealer.EinsteinKPI__r.Dealer_Value_is_High__c == false){
                try{
            		String einsteinKPIKeyValueString = String.valueOf(evalKPIdetail.einsteinKPIDetail.Key_Value__c).replaceAll('[^0-9.]', '');
                	Double einsteinKPIKeyValue  = Double.valueOf(einsteinKPIKeyValueString);
                    if(KPISelector.regionEinsteinKPIDetail != null && KPISelector.regionEinsteinKPIDetail.Key_Value__c != null && !KPISelector.regionEinsteinKPIDetail.Key_Value__c.startsWith('null')) {
                        evalKPIdetail.regionEinsteinKPIDetail.Key_Value__c = KPISelector.regionEinsteinKPIDetail.Key_Value__c;
                        String regionKPIKeyValueString = String.valueOf(evalKPIdetail.regionEinsteinKPIDetail.Key_Value__c).replaceAll('[^0-9.]', '');
                        Double regionKPIKeyValue = Double.valueOf(regionKPIKeyValueString);   
                        if(einsteinKPIDealer.EinsteinKPI__r.Dealer_Value_is_High__c == false){
                       		if(einsteinKPIKeyValue > regionKPIKeyValue){
                                evalKPIdetail.regionColor='red';
                            }
                            else{
                             	evalKPIdetail.regionColor = 'green';   
                            }
                    	}else{
                            //if(KPISelector.regionEinsteinKPIDetail != null && KPISelector.regionEinsteinKPIDetail.Key_Value__c != null && !KPISelector.regionEinsteinKPIDetail.Key_Value__c.startsWith('null')) {
                                //evalKPIdetail.regionEinsteinKPIDetail.Key_Value__c = KPISelector.regionEinsteinKPIDetail.Key_Value__c;
                               if(einsteinKPIKeyValue >= regionKPIKeyValue)
                                evalKPIdetail.regionColor='green';
                                else
                                evalKPIdetail.regionColor = 'red';
                            //}
                        }
                    }
				//if(einsteinKPIDealer.EinsteinKPI__r.Dealer_Value_is_High__c == false){
                    if(KPISelector.districtEinsteinKPIDetail != null && KPISelector.districtEinsteinKPIDetail.Key_Value__c != null && !KPISelector.districtEinsteinKPIDetail.Key_Value__c.startsWith('null')) {
                        evalKPIdetail.districtEinsteinKPIDetail.Key_Value__c = KPISelector.districtEinsteinKPIDetail.Key_Value__c;
                        String districtKPIKeyValueString = String.valueOf(evalKPIdetail.districtEinsteinKPIDetail.Key_Value__c).replaceAll('[^0-9.]', '');
                        Double districtKPIKeyValue = Double.valueOf(districtKPIKeyValueString);
                        
                        if(einsteinKPIDealer.EinsteinKPI__r.Dealer_Value_is_High__c == false){
                            if(einsteinKPIKeyValue > districtKPIKeyValue)
                            {
                                System.debug('districtKPIKeyValue RED : '+districtKPIKeyValue);
                                evalKPIdetail.districtColor='red';   
                            }
                            else{
                                evalKPIdetail.districtColor = 'green';
                            }
                        }else{
                            if(KPISelector.districtEinsteinKPIDetail != null && KPISelector.districtEinsteinKPIDetail.Key_Value__c != null && !KPISelector.districtEinsteinKPIDetail.Key_Value__c.startsWith('null')) {
                            	evalKPIdetail.districtEinsteinKPIDetail.Key_Value__c = KPISelector.districtEinsteinKPIDetail.Key_Value__c;
                                if(einsteinKPIKeyValue >= districtKPIKeyValue){
                                    System.debug('districtKPIKeyValue RED : '+districtKPIKeyValue);
                                    evalKPIdetail.districtColor='green';   
                                }
                            	else{
                                	evalKPIdetail.districtColor = 'red';
                            	}
                        	}
                		}
                   }
            	}catch(Exception e){
                		double	regionKPIKeyValue = 0.0;
            	}
            }
                evalKPIDetailsList.add(evalKPIdetail);      
        	}
        }	
       
       evaluationWrapper.evalKPIDetails=evalKPIDetailsList;
        evaluationWrapper.evaluationKPIs = evaluationKPIs;
        
        List<EvaluationContact__c> evaluationContacts = [select Id, Contact__r.Name, Contact__r.Email, Contact__r.Phone from EvaluationContact__c where Evaluation__c = :evaluationId ];
        evaluationWrapper.evaluationContacts = evaluationContacts;
        
        if(evaluation.Survey__c != null) {
            evaluationWrapper.surveyQuestionWrappersMap = buildSurveyQuestionWrapper(evaluation.Survey__c);
        }
        System.debug('listCarryOverSurveyques '+listCarryOverSurveyques);
        if (listCarryOverSurveyques != NULL && listCarryOverSurveyques.size() > 0){
           evaluationWrapper.carryOverSurveyQuestionWrappersMap = buildCarryOverSurveyQuestionWrapper(listCarryOverSurveyques);
        System.debug('carryOverSurveyQuestionWrappersMap '+evaluationWrapper.carryOverSurveyQuestionWrappersMap);
        }
        
        //evaluationWrapper.actionPlanWrappers = actionPlanWrappers;
        System.debug('actionPlanWrapperMap '+actionPlanWrapperMap);
        evaluationWrapper.actionPlanWrapperMap = actionPlanWrapperMap;
        evaluationWrapper.isDashboardDataPresent=isDashboardDataPresent;
        
    }
    
    public Map<Id, SurveyQuestionWrapper> buildSurveyQuestionWrapper(String surveyId) {
        Map<Id, SurveyQuestionWrapper> surveyQuestionWrapperMap = new Map<Id, SurveyQuestionWrapper>();
        List<Survey_Question__c> surveyQuestions = SurveyQuestionController.getSurveyQuestions(surveyId, false);
        
        if(surveyId != null) {
            List<ContentDocumentLink> contentDocumentLinks = SurveyQuestionController.getContentDocumentsForSurvey(surveyId);
            Map<Id, List<File>> surveyQuestionContentDocumentIdMap = new Map<Id, List<File>>();
            for(ContentDocumentLink contentDocumentLink:contentDocumentLinks) {
                if(!surveyQuestionContentDocumentIdMap.containsKey(contentDocumentLink.LinkedEntityId)) {
                    surveyQuestionContentDocumentIdMap.put(contentDocumentLink.LinkedEntityId, new List<File>());
                }
                surveyQuestionContentDocumentIdMap.get(contentDocumentLink.LinkedEntityId).add(new File(contentDocumentLink.ContentDocument.FileExtension, contentDocumentLink.ContentDocument.LatestPublishedVersionId, contentDocumentLink.ContentDocument.Title));//ContentDocument.LatestPublishedVersionId
            }
            
            for(Survey_Question__c surveyQuestion:surveyQuestions) {
                
                if (!surveyQuestion.Is_Carried_Over__c) {

                SurveyQuestionWrapper surveyQuestionWrapper;
                if(surveyQuestion.DependentQuestion__c == null) {
                    surveyQuestionWrapper = new SurveyQuestionWrapper(surveyQuestion);
                    surveyQuestionWrapperMap.put(surveyQuestion.Id, surveyQuestionWrapper);
                }
                else {
                    surveyQuestionWrapper = surveyQuestionWrapperMap.get(surveyQuestion.DependentQuestion__c);
                    if(surveyQuestion.Input_Type__c != 'Numeric Tabular with Inline Entry') {
                        surveyQuestionWrapper.inlineQuestions.add(surveyQuestion);
                    }
                    else {
                        surveyQuestionWrapper.numericTabularQuestions.add(surveyQuestion);
                    }
                }
                
                if(surveyQuestionContentDocumentIdMap.containsKey(surveyQuestion.Id)) {
                    surveyQuestionWrapper.contentDocumentIds = surveyQuestionContentDocumentIdMap.get(surveyQuestion.Id);
                }
            }
            }
        }
        return surveyQuestionWrapperMap;
    }
    
    
    
     /**
    * Build Carry Over Action Plan Survey Question Wrapper.
    * @param  surveyQueId  list of Survey Questions
    * @return map of SurveyQuestionWrapper   
    * @author Vinit [11 August 2021] [IBM] 
    */
    public Map<Id, SurveyQuestionWrapper> buildCarryOverSurveyQuestionWrapper(List<Id> surveyQueId) {
        Map<Id, SurveyQuestionWrapper> carryOverSurveyQuestionWrapperMap = new Map<Id, SurveyQuestionWrapper>();
       Integer carryOverActionPlanAccount = 0;
       List<Survey_Question__c> surveyQuestions = new List<Survey_Question__c>();
        
        String sql = 'select Id, Survey__c, Survey__r.Evaluation__c, Section_Number__c, Question_Number__c, Question_Text__c, Due_Date__c,Instruction_Text__c, Benefit_Text__c, Response_Text__c, DependentQuestion__c, DependentQuestionResponse__c, Remarks__c, ';
        sql += 'Input_Type__c, InputValues__c, Question_Number_Text__c, DependentQuestion__r.Response_Text__c, Photos_Required__c, RemarksEnabled__c, ';
        sql += 'Response_Calculated_From_Inline_Answers__c, Table_Columns__c, Fail_Value__c, Other_Response_Text__c, ';
        sql += 'Response_Number__c, Response_Number_2__c, Response_Number_3__c, Status__c, Survey__r.Status__c, Response__c, Image_Required_Prior_To_Answer__c, InitialResponseText__c, Action_Plan__c, Score__c, Category__c, ';
        sql += 'Action_Plan__r.Status__c, Is_Carried_Over__c, AP_Moved_to_Next_Quarter__c ';
        sql +=' from Survey_Question__c where Id IN: surveyQueId order by Section_Number__c NULLS LAST, Question_Number_Text__c NULLS LAST';
        

        surveyQuestions = Database.query(sql);
        
        if( surveyQuestions != NULL && surveyQuestions.size() > 0) {
           List<ContentDocumentLink> contentDocumentLinks = [select ContentDocument.LatestPublishedVersionId, ContentDocument.FileExtension, ContentDocument.TItle, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN (select Id from Survey_Question__c where Id IN: surveyQuestions)];

            Map<Id, List<File>> carryOverSurveyQuestionContentDocumentIdMap = new Map<Id, List<File>>();
            for(ContentDocumentLink contentDocumentLink:contentDocumentLinks) {
                if(!carryOverSurveyQuestionContentDocumentIdMap.containsKey(contentDocumentLink.LinkedEntityId)) {
                    carryOverSurveyQuestionContentDocumentIdMap.put(contentDocumentLink.LinkedEntityId, new List<File>());
                }
                carryOverSurveyQuestionContentDocumentIdMap.get(contentDocumentLink.LinkedEntityId).add(new File(contentDocumentLink.ContentDocument.FileExtension, contentDocumentLink.ContentDocument.LatestPublishedVersionId, contentDocumentLink.ContentDocument.Title));//ContentDocument.LatestPublishedVersionId
            }
            
            for(Survey_Question__c surveyQuestion:surveyQuestions) {
                SurveyQuestionWrapper carryOversurveyQuestionWrapper;
                if(surveyQuestion.DependentQuestion__c == null) {
                    carryOversurveyQuestionWrapper = new SurveyQuestionWrapper(surveyQuestion);
                    carryOverSurveyQuestionWrapperMap.put(surveyQuestion.Id, carryOversurveyQuestionWrapper);
                }
                else {
                    carryOversurveyQuestionWrapper = carryOverSurveyQuestionWrapperMap.get(surveyQuestion.DependentQuestion__c);
                    if(surveyQuestion.Input_Type__c != 'Numeric Tabular with Inline Entry') {
                        carryOversurveyQuestionWrapper.inlineQuestions.add(surveyQuestion);
                    }
                    else {
                        carryOversurveyQuestionWrapper.numericTabularQuestions.add(surveyQuestion);
                    }
                }
                
                if(carryOverSurveyQuestionContentDocumentIdMap.containsKey(surveyQuestion.Id)) {
                    carryOversurveyQuestionWrapper.contentDocumentIds = carryOverSurveyQuestionContentDocumentIdMap.get(surveyQuestion.Id);
                }

               
            }
            
            

        }
        return carryOverSurveyQuestionWrapperMap;
    }
    
    
    public Map<Id,ProcessInstance> getProcessHistory(Set<Id> recordIds)  
    {        
        Map<Id,ProcessInstance> actionPlanApprovals =  new Map<Id,ProcessInstance>(); 
        
        if(!recordIds.isEmpty()){
            for(ProcessInstance processInstance:[SELECT Id, TargetObjectId, ProcessDefinition.Name,Status, lastmodifieddate, (SELECT ID, ProcessNodeId,  
                                                                                                                              StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending  
                                                                                                                              ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Id,Actor.Name,  
                                                                                                                              OriginalActor.Name ,ProcessNode.Name FROM StepsAndWorkitems order by CreatedDate DESC, ProcessNode.Name, Id DESC )   
                                                 FROM ProcessInstance where TargetObjectId in :recordIds and Status != 'Removed' order by CreatedDate DESC]) {
                                                     actionPlanApprovals.put(processInstance.TargetObjectId, processInstance);
                                                 }
        }
        return actionPlanApprovals;
    }
    
    
    public class EvaluationWrapper {
        public Evaluation__c evaluation {get; set;}
        //public List<ActionPlanWrapper> actionPlanWrappers {get; set;}
        public List<File> evaluationDocumentIds {get; set;} 
        public List<EvaluationKPIs__c> evaluationKPIs {get; set;}
        public List<EvaluationContact__c> evaluationContacts {get; set;}
        public Map<Id, SurveyQuestionWrapper> surveyQuestionWrappersMap {get; set;}
        public Map<Id, SurveyQuestionWrapper> carryOverSurveyQuestionWrappersMap {get; set;}
        public Map<Id, ActionPlanWrapper> actionPlanWrapperMap {get; set;}
        public ProcessInstance processInstance {get; set;}
        public Integer standardActionPlanCount {get; set;}
        public Integer actionPlanCountInProgress {get; set;}
        public Integer actionPlanCountNonCompliant {get; set;}
        public Integer actionPlanCountCompliant {get; set;}
        public Integer actionPlanCountCarryOver {get;set;}
        public boolean isDashboardDataPresent {get;set;}
        public List<EvaluationKPIsDetails> evalKPIDetails{get;set;}
        public EvaluationWrapper(Evaluation__c evaluation) {
            this.evaluation = evaluation;
            //this.actionPlanWrappers = new List<ActionPlanWrapper>();
            this.evaluationDocumentIds = new List<File>();
            this.evaluationContacts = new List<EvaluationContact__c>();
            this.evaluationKPIs = new List<EvaluationKPIs__c>();
            this.surveyQuestionWrappersMap = new Map<Id, SurveyQuestionWrapper>();
            this.carryOverSurveyQuestionWrappersMap = new Map<Id, SurveyQuestionWrapper>();
            this.actionPlanWrapperMap = new Map<Id, ActionPlanWrapper>();
            this.standardActionPlanCount = 0;   
            this.actionPlanCountInProgress = 0;   
            this.actionPlanCountNonCompliant = 0;   
            this.actionPlanCountCompliant = 0; 
            this.isDashboardDataPresent = false;
        }
        
        public List<SurveyQuestionWrapper> getSurveyQuestionWrappers() {
            return surveyQuestionWrappersMap.values();
        }
        
         public List<SurveyQuestionWrapper> getCarryOverSurveyQuestionWrappers() {
            return carryOverSurveyQuestionWrappersMap.values();
        }
        
        public List<ActionPlanWrapper> getActionPlanWrappers() {
            return actionPlanWrapperMap.values();
        }
        
    }
    
    public class EvaluationKPIsDetails {
        public String KPIName {get; set;}
        public String Initial_Key_Value {get; set;}
        public String Initial_Threshold_Value {get; set;}
        public String ThresholdStatusIcon {get; set;}
        public String regionValue {get; set;}
        public String districtValue {get; set;}
        public String regionColor {get; set;}
        public String districtColor {get; set;}
        public String dashboardTableData {get; set;}

          @AuraEnabled
        public String KPIName1 {get; set;} 

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
    
        
    }
    public class ActionPlanWrapper {
        public Action_Plan__c actionPlan {get; set;}
        public List<File> actionPlanDocumentIds {get; set;} 
        public List<Id> surveyQuestionDocumentIds {get; set;}
        public ProcessInstance processInstance {get; set;}
        
        public ActionPlanWrapper(Action_Plan__c actionPlan) {
            this.actionPlan = actionPlan;
            this.actionPlanDocumentIds = new List<File>();
            this.surveyQuestionDocumentIds = new List<Id>();
        }
    }
    
    public class File {
        public String type {get; set;}
        public String Id {get; set;}
        public String fileName {get; set;}
        
        public File(String type, String Id, String fileName) {
            this.type = type;
            this.Id = Id;
            this.fileName = fileName;
        }
    }
    
    public class SurveyQuestionWrapper {
        
        public String questionName {get; set;}
        public Survey_Question__c surveyQuestion {get; set;}
        public List<Survey_Question__c> inlineQuestions {get; set;}
        public List<Survey_Question__c> numericTabularQuestions {get; set;}
        public List<File> contentDocumentIds {get; set;}
        public String tabularHeader1 {get; set;}
        public String tabularHeader2 {get; set;}
        public String tabularHeader3 {get; set;}
        
        
        public SurveyQuestionWrapper(Survey_Question__c surveyQuestion) {
            this.surveyQuestion = surveyQuestion;
            this.questionName = surveyQuestion.Question_Number_Text__c + '-' + surveyQuestion.Question_Text__c;
            this.inlineQuestions = new List<Survey_Question__c>();
            this.numericTabularQuestions = new List<Survey_Question__c>();
            this.contentDocumentIds = new List<File>();
            
            if(surveyQuestion.Table_Columns__c != null) {
                List<String> surveyQuestionTableHeader = surveyQuestion.Table_Columns__c.split(';');
                tabularHeader1 = surveyQuestionTableHeader[0];
                tabularHeader2 = surveyQuestionTableHeader[1];
                if(surveyQuestionTableHeader.size() == 3) {
                    tabularHeader3 = surveyQuestionTableHeader[2];
                }
            }
        }
    }
    
    @AuraEnabled
    public static String launchQueueableForEvaluationGeneration(String evaluationId) {
        
        System.debug(LoggingLevel.ERROR, 'launchQueueableForEvaluationGeneration');
        System.debug(LoggingLevel.ERROR, evaluationId);
        
        GeneratePDFQueueable queueable = new GeneratePDFQueueable(new List<String>{evaluationId}, 'Evaluation', 0 , 0);
        String jobId = System.enqueueJob(queueable);
        
        System.debug(LoggingLevel.ERROR, 'Job Id' + jobId);
        
        return jobId;
    } 
    
    @AuraEnabled
    public static AsyncApexJob getQueueableForEvaluationGenerationStatus(String jobId) {
        
        return [SELECT Status, NumberOfErrors, ExtendedStatus FROM AsyncApexJob WHERE Id=:jobID];
        
    }
    
    @AuraEnabled
    public static Evaluation__c getEvaluationDetails(String evaluationId){
        return [select Id, Latest_PDF_Version_Date__c, Latest_PDF_Version_Id__c from Evaluation__c where Id = :evaluationId];
    }
    
    @AuraEnabled
    public static string getNetworkId(){
        
        String networkId =  Network.getNetworkId();
        
        DPMConfigurationSettings__c setting = DPMConfigurationSettings__c.getInstance();
        
        System.debug(LoggingLevel.ERROR, setting);
        System.debug(LoggingLevel.ERROR, networkId);
        
        if(networkId == null) {
            return '';
        }
        else if(networkId.left(15) == setting.HyundaiNetworkId__c.left(15)){
            //Hyundai
            
            System.debug(LoggingLevel.ERROR, setting.HyundaiNetworkId__c );
            System.debug(LoggingLevel.ERROR, setting.HyundaiCommunityURL__c );
            return setting.HyundaiCommunityURL__c;
        }
        else {
            //Genesis
            //System.debug(LoggingLevel.ERROR, setting. );
            System.debug(LoggingLevel.ERROR, setting.GenesisCommunityURL__c );
            return setting.GenesisCommunityURL__c;
        }
    }
}