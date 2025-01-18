public without sharing class BatchProcessSurveyQuestionClone implements Database.Batchable<SObject>{
    
    public String query;
    public Id surveyApexJobId;

    public BatchProcessSurveyQuestionClone(String query) {
        this.query = query;
    }

    public BatchProcessSurveyQuestionClone(Id surveyApexJobId) {
        this.surveyApexJobId = surveyApexJobId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        if(query == null) {
            query = 'select Id, SurveyTemplate__c from Survey__c where ApexJobId__c = :surveyApexJobId ';
        }
        return Database.getQueryLocator(query);
    }

    public static Map<Id, List<Survey_Question__c>> getParentSurveyQuestionMap(List<Id> surveyIds) {
        Map<Id, List<Survey_Question__c>> surveyQuestionMap = new Map<Id, List<Survey_Question__c>>();
        //DPM-5633 added Category_Order__c, Sales_Category_Number__c
        List<Survey_Question__c> surveyQuestions = [select Id,Category_Order__c, Sales_Category_Number__c, Category_Type__c,QuestionSubCategory__c, Name, Survey__c, Photos_Required__c, Action_Plan__c, Available_Picklist_Values__c, Benefit_Text__c,Due_Date__c, Can_Be_Done_Remotely__c, Category__c, DependentQuestion__c, 
                                                    DependentQuestionResponse__c, Survey_Field__c, EntryDataType__c, Evaluation__c, Fail_Value__c, InputValues__c ,Input_Type__c, Instruction_Text__c, Is_Parent__c, Is_Text_or_Number_a_valid_response__c, 
                                                    Notes__c, OldInputField__c, Other_Response_Text__c, Picklist_Option_1__c, Picklist_Option_2__c, Priority__c, Question_Number__c, Question_Number_Text__c, Question_Text__c, Remarks__c, RemarksEnabled__c, 
                                                    Response__c, Response_Calculated_From_Inline_Answers__c, Response_Number__c, Response_Number_2__c, Response_Text__c, Score__c, Score_Picklist_Option_2__c, Score_Picklist_Option_1__c, SecondarySSIGaps__c, 
                                                    Section_Number__c, SSIGaps__c, Status__c, Meet_ALL_Criteria_Check__c,Subcategory__c,Table_Columns__c,Topic__c, Type__c,
                                                    RecordType.DeveloperName from Survey_Question__c where Survey__c in :surveyIds and
                                                    DependentQuestion__c = null order by CreatedDate ASC];
        
        for(Survey_Question__c surveyQuestion:surveyQuestions) {
            
            if(!surveyQuestionMap.containsKey(surveyQuestion.Survey__c)) {
                surveyQuestionMap.put(surveyQuestion.Survey__c, new List<Survey_Question__c>());
            }
            surveyQuestionMap.get(surveyQuestion.Survey__c).add(surveyQuestion);
        }
        return surveyQuestionMap;
    }

    public static Map<Id, List<Survey_Question__c>> getChildSurveyQuestionMap(List<Id> surveyIds) {
        Map<Id, List<Survey_Question__c>> surveyQuestionMap = new Map<Id, List<Survey_Question__c>>();
        //DPM-5633 added Category_Order__c, Sales_Category_Number__c
       List<Survey_Question__c> surveyQuestions = [select Id, Category_Order__c, Sales_Category_Number__c, Category_Type__c,QuestionSubCategory__c, Name, Survey__c, Photos_Required__c, Action_Plan__c, Available_Picklist_Values__c, Benefit_Text__c, Can_Be_Done_Remotely__c, Category__c, DependentQuestion__c, 
                                                    DependentQuestionResponse__c, Survey_Field__c, EntryDataType__c, Evaluation__c, Fail_Value__c, InputValues__c ,Input_Type__c, Instruction_Text__c,Due_Date__c, Is_Parent__c, Is_Text_or_Number_a_valid_response__c, 
                                                    Notes__c, OldInputField__c, Other_Response_Text__c, Picklist_Option_1__c, Picklist_Option_2__c, Priority__c, Question_Number__c, Question_Number_Text__c, Question_Text__c, Remarks__c, RemarksEnabled__c, 
                                                    Response__c, Response_Calculated_From_Inline_Answers__c, Response_Number__c, Response_Number_2__c, Response_Text__c, Score__c, Score_Picklist_Option_2__c, Score_Picklist_Option_1__c, SecondarySSIGaps__c, 
                                                    Section_Number__c,Meet_ALL_Criteria_Check__c, SSIGaps__c, Status__c, Subcategory__c,Table_Columns__c,Topic__c, Type__c,
                                                    RecordType.DeveloperName from Survey_Question__c where Survey__c in :surveyIds and
                                                    DependentQuestion__c != null order by CreatedDate ASC];

        for(Survey_Question__c surveyQuestion:surveyQuestions) {
            
            if(!surveyQuestionMap.containsKey(surveyQuestion.DependentQuestion__c)) {
                surveyQuestionMap.put(surveyQuestion.DependentQuestion__c, new List<Survey_Question__c>());
            }
            surveyQuestionMap.get(surveyQuestion.DependentQuestion__c).add(surveyQuestion);
        }
        return surveyQuestionMap;
    }


    public void execute(Database.BatchableContext BC, List<Survey__c> clonedSurveys) {

        Set<Id> surveyIds = new Set<Id>();
        Map<Id, Id> surveyToOldSurveyMap = new Map<Id, Id>();
        for(Survey__c survey:clonedSurveys) {
            surveyIds.add(survey.Id);
            surveyToOldSurveyMap.put(survey.Id, survey.SurveyTemplate__c);
            survey.Status__c = 'Not Started';
        }

        Map<Id, List<Survey_Question__c>> parentQuestionsMap = getParentSurveyQuestionMap(surveyToOldSurveyMap.values());
        Map<Id, List<Survey_Question__c>> childQuestionsMap = getChildSurveyQuestionMap(surveyToOldSurveyMap.values());
        Map<String, RecordType> surveyQuestionRecordTypeMapping = getSurveyQuestionRecordTypeMappings();
        System.debug(LoggingLevel.ERROR, surveyQuestionRecordTypeMapping);

        List<Survey_Question__c> newParentSurveyQuestions = new List<Survey_Question__c>();

        for(Survey__c survey:clonedSurveys) {
            if(parentQuestionsMap.containsKey(survey.SurveyTemplate__c)) {
                for(Survey_Question__c surveyQuestionToClone:parentQuestionsMap.get(survey.SurveyTemplate__c)) {
                    Survey_Question__c newParentSurveyQuestion = surveyQuestionToClone.clone(false, false, false, false);
                    newParentSurveyQuestion.Survey__c = survey.Id;
                    newParentSurveyQuestion.SurveyQuestionTemplate__c = surveyQuestionToClone.Id;   
                    newParentSurveyQuestion.Status__c = 'Draft';
                    newParentSurveyQuestion.Instruction_Text__c = surveyQuestionToClone.Instruction_Text__c;
                    newParentSurveyQuestion.Benefit_Text__c = surveyQuestionToClone.Benefit_Text__c;
                    String key = surveyQuestionToClone.RecordType.DeveloperName.replace('_','');
                    System.debug(LoggingLevel.ERROR, key);
                    if(surveyQuestionRecordTypeMapping.containsKey(key)){
                        newParentSurveyQuestion.RecordTypeId = surveyQuestionRecordTypeMapping.get(key).Id;
                    }
                    newParentSurveyQuestions.add(newParentSurveyQuestion);    
                }
            }
        }
        Map<Id, List<Survey_Question__c>> parentQuestionOldParentQuestionIdMap = new Map<Id, List<Survey_Question__c>>();
        List<Survey_Question__c> newChildSurveyQuestions = new List<Survey_Question__c>();
        if(!newParentSurveyQuestions.isEmpty()) {
            insert newParentSurveyQuestions;

            for(Survey_Question__c surveyQuestion:newParentSurveyQuestions) {
                if(childQuestionsMap.containsKey(surveyQuestion.SurveyQuestionTemplate__c)) {
                    for(Survey_Question__c surveyQuestionToClone:childQuestionsMap.get(surveyQuestion.SurveyQuestionTemplate__c)) {
                        Survey_Question__c newChildSurveyQuestion = surveyQuestionToClone.clone(false, false, false, false);
                        newChildSurveyQuestion.Survey__c = surveyQuestion.Survey__c;
                        newChildSurveyQuestion.SurveyQuestionTemplate__c = surveyQuestionToClone.Id;    
                        newChildSurveyQuestion.DependentQuestion__c = surveyQuestion.Id;
                        newChildSurveyQuestion.Status__c = 'Draft';
                        String key = surveyQuestionToClone.RecordType.DeveloperName.replace('_','');
                        System.debug(LoggingLevel.ERROR, key);
                        if(surveyQuestionRecordTypeMapping.containsKey(key)){
                            newChildSurveyQuestion.RecordTypeId = surveyQuestionRecordTypeMapping.get(key).Id;
                        }
                        newChildSurveyQuestions.add(newChildSurveyQuestion);
                    }
                }
            }
        }

        if(!newChildSurveyQuestions.isEmpty()) {
            insert newChildSurveyQuestions;
        }

        SurveyTriggerHandler.run = false;
        update clonedSurveys;
        SurveyTriggerHandler.run = true;

    }

    private Map<String, RecordType> getSurveyQuestionRecordTypeMappings() {

        Map<String, RecordType> recordTypeMap = new  Map<String, RecordType>();        
        List<RecordType> surveyQuestionTemplateRecordTypes = [select Id, Name, DeveloperName from RecordType where SobjectType = 'Survey_Question__c' and (DeveloperName like '%TemplateQuestion' or DeveloperName like '%Template_Question')];
        List<RecordType> surveyQuestionNonTemplateRecordTypes = [select Id, Name, DeveloperName from RecordType where SobjectType = 'Survey_Question__c' and (NOT DeveloperName like '%TemplateQuestion') and (NOT DeveloperName like '%Template_Question')];

        System.debug(LoggingLevel.ERROR, surveyQuestionTemplateRecordTypes);
        for(RecordType surveyQuestionRecordTypeTemplate:surveyQuestionTemplateRecordTypes) {
            recordTypeMap.put(surveyQuestionRecordTypeTemplate.DeveloperName.replace('_', ''), null);
        }

        for(RecordType surveyQuestionNonTemplateRecordType:surveyQuestionNonTemplateRecordTypes) {
            String key = surveyQuestionNonTemplateRecordType.DeveloperName.replace('_', '') + 'TemplateQuestion';
            if(recordTypeMap.containsKey(key)) {
                recordTypeMap.put(key, surveyQuestionNonTemplateRecordType);
            }
        }

        return recordTypeMap;
    }

    public void finish(Database.BatchableContext BC) {
        
        Map<Id, Survey__c> surveyMap = new Map<Id, Survey__c>([select Id from Survey__c where ApexJobId__c = :surveyApexJobId]);
        if(!surveyMap.keySet().isEmpty()) {
            BatchProcessObjectShares surveyObjectSharesBatch = new BatchProcessObjectShares();
            surveyObjectSharesBatch.type = 'Survey';
            surveyObjectSharesBatch.objectIds = surveyMap.keySet();
            Database.executeBatch(surveyObjectSharesBatch, 1);
        }

        Map<Id, Evaluation__c> evaluationMap = new Map<Id, Evaluation__c>([select Id from Evaluation__c where ApexJobId__c = :surveyApexJobId]);
        if(!evaluationMap.keySet().isEmpty()) {
            BatchProcessObjectShares evaluationObjectSharesBatch = new BatchProcessObjectShares();
            evaluationObjectSharesBatch.type = 'Evaluation';
            evaluationObjectSharesBatch.objectIds = evaluationMap.keySet();
            if(!Test.isRunningTest()) {
                Database.executeBatch(evaluationObjectSharesBatch, 1);
            }
        }
    }
}