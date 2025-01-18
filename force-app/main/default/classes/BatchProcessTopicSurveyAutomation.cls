public without sharing class BatchProcessTopicSurveyAutomation implements Database.Batchable<SObject> {

    public String query;
    HMACalendarQuarters__c calendarQuarters = HMACalendarQuarters__c.getInstance();
    public static Map<Id, Id> contactIdUserIdMap;

    private static List<Id> surveyIds;
    private static List<Id> evaluationIds;

    public Map<String, RecordType> surveyRecordTypeMapping;
    public Map<String, RecordType> evaluationRecordTypeMapping;

    public BatchProcessTopicSurveyAutomation() {
    }

    public BatchProcessTopicSurveyAutomation(String query) {
        this.query = query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Dhiraj Inside Batch');
        Date today = Date.today();
        if(query == null) {
            query = 'select Id,JDP_Evaluation__c, Type__c, CalendarType__c, Reoccurence__c, HMASurvey__c, Organization__c, Region__c, SalesDistrict__c, CreateRecordsFor__c, ServiceDistrict__c, DealerCodes__c '; 
           //following line is commented by neeraj sharma for dpm-3521
            //query += ', Account__c, HyundaiArea__c, GenesisArea__c, Market__c, Division__c from Topic__c where RecordType.DeveloperName = \'Survey_Topic\' and Active_Topic__c = true ';
            query += ', Account__c, HyundaiArea__c, Market__c, Division__c from Topic__c where RecordType.DeveloperName = \'Survey_Topic\' and Active_Topic__c = true ';
            query += ' and NextRunDate__c = :today and (LastRunDate__c < :today or LastRunDate__c = null)';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Topic__c> surveyTopics) {

        Map<String, RecordGeneration__mdt> topicTypeRecordGenerationMap = new Map<String, RecordGeneration__mdt>();
        Map<String, List<RecordMapping__mdt>> recordGenerationRecordMappingMap = new Map<String, List<RecordMapping__mdt>>();

        for(Topic__c surveyTopic:surveyTopics) {
            if(!topicTypeRecordGenerationMap.containsKey(surveyTopic.Type__c)) {
                RecordGeneration__mdt recordGeneration = HMATopicService.getRecordMappingSettingsForType(surveyTopic.Type__c);
                if(recordGeneration != null) {
                    topicTypeRecordGenerationMap.put(surveyTopic.Type__c, recordGeneration);
                    List<RecordMapping__mdt> recordMappings = HMATopicService.getRecordMappingSettingsFromRecordMappingDeveloperName(recordGeneration.DeveloperName);
                    recordGenerationRecordMappingMap.put(recordGeneration.DeveloperName, recordMappings);
                }
            }
        }
        List<Topic__c> topicsWithDetails = HMATopicService.getTopicDetailsFromTopicsAndMappings(surveyTopics, recordGenerationRecordMappingMap.values());

        Map<String, HMATopicService.LevelWrapper> levelWrapperMap = HMATopicService.getLevelWrapperMapsFromTopics(surveyTopics);

        System.debug(LoggingLevel.ERROR, levelWrapperMap);
        contactIdUserIdMap = HMATopicService.getContactUserMapFromLevelWrapper(levelWrapperMap.values());
        createSurveysFromTopics(topicsWithDetails, topicTypeRecordGenerationMap, recordGenerationRecordMappingMap, levelWrapperMap, BC.getJobId());
        

        HMATopicService.updateRunDateForTopics(surveyTopics);
    }

    public static Map<Id, Survey__c> getSurveyMap(Set<Id> surveyIds) {

        Map<Id, Survey__c> surveyMap = new Map<Id, Survey__c>();

        List<Schema.FieldSetMember> fieldSetMembers = SObjectType.Survey__c.FieldSets.SurveyCloneFields.getFields();
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : fieldSetMembers) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id, Name, RecordType.DeveloperName,Warranty_Review_2022__c,X22_Warranty_Review__c, Warranty_Review_Instruction_2022__c, Warranty_Review_Due_Date_Text_2022__c FROM Survey__c where Id in :surveyIds';

        for(Survey__c survey:Database.query(query)) {
            surveyMap.put(survey.Id, survey);
        }
    
        return surveyMap;
    }

    private Map<String, Evaluation__c> createEvaluationsForSurveyTopics(List<Topic__c> topicsWithDetails, Map<String, RecordGeneration__mdt> topicTypeRecordGenerationMap,  Map<String, List<RecordMapping__mdt>> regordGenerationRecordMappingMap, Map<String, HMATopicService.LevelWrapper> levelWrapperMap, String apexJobId) {

        Map<String, Evaluation__c> accountIdEvaluationMap = new Map<String, Evaluation__c>();
        //String recordTypeId = HMAUtility.getRecordTypeIdForObjectDeveloperName('Evaluation__c', 'CXB');
        for(Topic__c topic:topicsWithDetails) { 
            Date endDate = HMATopicService.calculateEndDate(topic);
            if(topic.CreateEvaluation__c == 'Yes') {
                String mapKey = HMATopicService.getKeyFromTopic(topic);
                System.debug(LoggingLevel.ERROR, mapKey);
                System.debug(LoggingLevel.ERROR, levelWrapperMap.get(mapKey));
                if(mapKey != null && levelWrapperMap.containsKey(mapKey)) {
                    for(Account account:levelWrapperMap.get(mapKey).accounts) {
                        System.debug(LoggingLevel.ERROR, account);
                        System.debug('Dhiraj Account '+ account.Id);
                        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id);

                        /*for(RecordMapping__mdt recordMapping:regordGenerationRecordMappingMap.get(recordGeneration.DeveloperName)) {
                            if(recordMapping.SourceFieldAPIName__c != null) {
                                //System.debug(LoggingLevel.ERROR, recordMapping.TargetFieldAPIName__c);
                                //System.debug(LoggingLevel.ERROR, topic.get(recordMapping.SourceFieldAPIName__c));
                                newObject.put(recordMapping.TargetFieldAPIName__c, topic.get(recordMapping.SourceFieldAPIName__c));
                            }
                        }*/
                        Id dealerPrincipalUserId;
                        Id generalManagerUserId;

                        if(account.DealerPrincipal__c != null) {
                            dealerPrincipalUserId = contactIdUserIdMap.get(account.DealerPrincipal__c);
                        }
                        if(account.GeneralManager__c != null) {
                            generalManagerUserId = contactIdUserIdMap.get(account.GeneralManager__c);
                        }
                        evaluation.OwnerId = HMATopicService.getTopicOwnerFromAccount(topic, account, dealerPrincipalUserId, generalManagerUserId);


                        if(evaluation.OwnerId == null) {
                            evaluation.OwnerId = UserInfo.getUserId();
                            System.debug(LoggingLevel.ERROR, account.Id);
                        }
                        evaluation.Name = topic.Name + ' - ' + account.DealerCode__c;
                        //added by dhiraj
                        evaluation.JDP_Evaluation__c=topic.JDP_Evaluation__c;
                        if(topic.Reoccurence__c == 'Run Once') {
                            evaluation.StartDate__c = topic.Topic_Start_Date__c;
                            // evaluation.EndDate__c = topic.Topic_End_Date__c;
                            //DPM-5062 changed to insert endDate of HMASurvey of Topic by MH - 10/19/2023
                            evaluation.EndDate__c = topic.HMASurvey__r.EndDate__c;
                            if(topic.Topic_End_Date__c != null && account.BrandCode__c!='G') { //DPM-5633 changed to be processed for Hyundai 
                                //DPM-5062 changed to insert DueDate of HMASurvey of Topic by MH - 10/19/2023
                                // evaluation.DueDate__c = topic.Topic_End_Date__c.addDays(-14);
                                evaluation.DueDate__c = topic.HMASurvey__r.DueDate__c;
                                evaluation.CloseDate__c = topic.HMASurvey__r.EndDate__c.addDays(-7);

                            }else if(account.BrandCode__c=='G'){
                                evaluation.GBX_Score__c = account.GBX_Score__c;
                                evaluation.GSX_Score__c = account.GSX_Score__c;
                            }
                        }
                        else {
                            evaluation.StartDate__c = Date.today();
                            //DPM-5062 changed to insert endDate of HMASurvey of Topic by MH - 10/19/2023
                            // evaluation.EndDate__c = endDate;
                            evaluation.EndDate__c = topic.HMASurvey__r.EndDate__c;
                        }
                        //evaluation.RecordTypeId = recordTypeId;
                        //System.debug(LoggingLevel.ERROR, 'Evaluation RecordType Id ' + recordTypeId);
                        evaluation.ScheduledTopic__c = topic.Id;
                        evaluation.ApexJobId__c = apexJobId;
                        
                        accountIdEvaluationMap.put(topic.Id + '-' + account.Id, evaluation);
                        System.debug(LoggingLevel.ERROR, evaluationRecordTypeMapping);
                        System.debug(LoggingLevel.ERROR, topic.HMASurvey__r.RecordTypeId);
                        evaluation.RecordTypeId = evaluationRecordTypeMapping.get(topic.HMASurvey__r.RecordTypeId).Id;

                        if(evaluationRecordTypeMapping.get(topic.HMASurvey__r.RecordTypeId).DeveloperName == 'Other') { // || evaluationRecordTypeMapping.get(topic.HMASurvey__r.RecordTypeId).DeveloperName == 'Genesis_Digital_Service_Process'
                            evaluation.Type__c = topic.Division__c;
                        }
                        System.debug(LoggingLevel.ERROR, 'Evaluation Type ' + evaluation.Type__c);
                    }
                }
            }
        }

        if(!accountIdEvaluationMap.values().isEmpty()) {
            insert accountIdEvaluationMap.values();

            List<Evaluation__c> evals = [select Id, Type__c, RecordType.Name from Evaluation__c where Id in :accountIdEvaluationMap.values()];
            System.debug(LoggingLevel.ERROR, evals);
        }

        return accountIdEvaluationMap;
    }

    private Map<String, RecordType> getSurveyRecordTypeMappings() {

        Map<String, RecordType> recordTypeMap = new  Map<String, RecordType>();        
        List<RecordType> surveyTemplateRecordTypes = [select Id, Name, DeveloperName from RecordType where SobjectType = 'Survey__c' and DeveloperName like '%SurveyTemplate'];
        List<RecordType> surveyNonTemplateRecordTypes = [select Id, Name, DeveloperName from RecordType where SobjectType = 'Survey__c' and (NOT DeveloperName like '%SurveyTemplate')];

        System.debug(LoggingLevel.ERROR, surveyTemplateRecordTypes);
        for(RecordType surveyRecordTypeTemplate:surveyTemplateRecordTypes) {
            recordTypeMap.put(surveyRecordTypeTemplate.DeveloperName, null);
        }

        for(RecordType surveyNonTemplateRecordType:surveyNonTemplateRecordTypes) {
            String key = surveyNonTemplateRecordType.DeveloperName + 'SurveyTemplate';
            if(recordTypeMap.containsKey(key)) {
                recordTypeMap.put(key, surveyNonTemplateRecordType);
            }
        }
		System.debug('Dhiraj Survey Record Type '+ recordTypeMap);
        return recordTypeMap;
    }

    private Map<String, RecordType> getEvaluationRecordTypeMappings(Map<String, RecordType> surveyRecordTypeMappings) {

        Map<String, RecordType> recordTypeMap = new  Map<String, RecordType>();        
        Map<String, RecordType> surveyTemplateRecordTypeMap = new Map<String, RecordType>();
        List<RecordType> surveyTemplateRecordTypes = [select Id, Name, DeveloperName from RecordType where SobjectType = 'Survey__c' and (DeveloperName like '%SurveyTemplate' OR DeveloperName = 'Digital_Service_Process')];
        //DPM-5063 added 'Genesis_Service_Process' record type by Minhee - 2023.11.07
        List<RecordType> evaluationRecordTypes = [select Id, Name, DeveloperName from RecordType where SobjectType = 'Evaluation__c' and DeveloperName in ('Other', 'Genesis_Sales','Genesis_Service','Genesis_Digital_Service_Process','CXNOW','CXB','Warranty_RO_Review', 'Genesis_Retailer_Eval_Service','Genesis_Retailer_Eval_Sales')]; //DPM-5633 created new evaluation 

        for(RecordType recordType:surveyTemplateRecordTypes) {
            surveyTemplateRecordTypeMap.put(recordType.DeveloperName, recordType);
        }

        System.debug(LoggingLevel.ERROR, evaluationRecordTypes);
        for(RecordType evaluationRecordType:evaluationRecordTypes) {
            if(evaluationRecordType.DeveloperName == 'Genesis_Sales') {
                //recordTypeMap.put('GenesisSales', evaluationRecordType);
                recordTypeMap.put(surveyTemplateRecordTypeMap.get('GenesisSalesSurveyTemplate').Id, evaluationRecordType);
            }
            else if(evaluationRecordType.DeveloperName == 'Genesis_Service') {
                ///recordTypeMap.put('GenesisService', evaluationRecordType);
                recordTypeMap.put(surveyTemplateRecordTypeMap.get('GenesisServiceSurveyTemplate').Id, evaluationRecordType);
                // recordTypeMap.put(surveyTemplateRecordTypeMap.get('Digital_Service_Process').Id, evaluationRecordType);
            }
            //DPM-5063 added 'Genesis_Service_Process' record type by Minhee - 2023.11.07
            else if(evaluationRecordType.DeveloperName == 'Genesis_Digital_Service_Process') {
                ///recordTypeMap.put('GenesisService', evaluationRecordType);
                recordTypeMap.put(surveyTemplateRecordTypeMap.get('Digital_Service_Process').Id, evaluationRecordType); //
            }
            else if(evaluationRecordType.DeveloperName == 'CXNOW') {
                //recordTypeMap.put('HyundaiSales', evaluationRecordType);
                recordTypeMap.put(surveyTemplateRecordTypeMap.get('HyundaiSalesSurveyTemplate').Id, evaluationRecordType);
            }
            else if(evaluationRecordType.DeveloperName == 'CXB') {
                //recordTypeMap.put('HyundaiService', evaluationRecordType);
                recordTypeMap.put(surveyTemplateRecordTypeMap.get('HyundaiServiceSurveyTemplate').Id, evaluationRecordType);
            }
            else if(evaluationRecordType.DeveloperName == 'Other') {
                //recordTypeMap.put('HyundaiService', evaluationRecordType);
                recordTypeMap.put(surveyTemplateRecordTypeMap.get('OtherSurveyTemplate').Id, evaluationRecordType);
            }
            else if(evaluationRecordType.DeveloperName == 'Warranty_RO_Review') {
                recordTypeMap.put(surveyTemplateRecordTypeMap.get('WarrantyROReviewSurveyTemplate').Id, evaluationRecordType);
            } 
            //DPM-5633 Project
            else if(evaluationRecordType.DeveloperName == 'Genesis_Retailer_Eval_Sales') {
                recordTypeMap.put(surveyTemplateRecordTypeMap.get('GenesisRetailerEvalSalesSurveyTemplate').Id, evaluationRecordType);
            }
            else if(evaluationRecordType.DeveloperName == 'Genesis_Retailer_Eval_Service') {
                recordTypeMap.put(surveyTemplateRecordTypeMap.get('GenesisRetailerEvalServiceSurveyTemplate').Id, evaluationRecordType);
            }



        }

        return recordTypeMap;
    }


    private void createSurveysFromTopics(List<Topic__c> topicsWithDetails, Map<String, RecordGeneration__mdt> topicTypeRecordGenerationMap,  Map<String, List<RecordMapping__mdt>> regordGenerationRecordMappingMap, Map<String, HMATopicService.LevelWrapper> levelWrapperMap, String apexJobId) {
        
        System.debug(LoggingLevel.ERROR, levelWrapperMap);
        List<Survey__c> surveysToCreate = new List<Survey__c>();
        List<Evaluation__c> evalsToUpdate = new List<Evaluation__c>();

        Set<Id> surveyIds = new Set<Id>(); 
        for(Topic__c topic:topicsWithDetails) {
            surveyIds.add(topic.HMASurvey__c);
        }
 
        surveyRecordTypeMapping = getSurveyRecordTypeMappings();
        evaluationRecordTypeMapping = getEvaluationRecordTypeMappings(surveyRecordTypeMapping);

        Map<Id, Survey__c> surveyMap = getSurveyMap(surveyIds);
        Map<String, Evaluation__c> accountIdEvaluationMap = createEvaluationsForSurveyTopics(topicsWithDetails, topicTypeRecordGenerationMap, regordGenerationRecordMappingMap, levelWrapperMap, apexJobId );

        for(Topic__c topic:topicsWithDetails) {
            Survey__c surveyToClone = surveyMap.get(topic.HMASurvey__c);
            Date endDate = HMATopicService.calculateEndDate(topic);
            String mapKey = HMATopicService.getKeyFromTopic(topic);
            if(mapKey != null && levelWrapperMap.containsKey(mapKey)) {
                for(Account account:levelWrapperMap.get(mapKey).accounts) {
                    //System.debug(LoggingLevel.ERROR, account.Id);
                    Survey__c survey = surveyToClone.clone(false, false, false, false);
                    survey.Dealer__c = account.Id;
                    survey.Name = topic.Name + ' - ' + account.DealerCode__c;
                    Id dealerPrincipalUserId;
                    Id generalManagerUserId;
                    if(account.DealerPrincipal__c != null) {
                        dealerPrincipalUserId = contactIdUserIdMap.get(account.DealerPrincipal__c);
                    }
                    if(account.GeneralManager__c != null) {
                        generalManagerUserId = contactIdUserIdMap.get(account.GeneralManager__c);
                    }
                    survey.OwnerId = HMATopicService.getTopicOwnerFromAccount(topic, account, dealerPrincipalUserId, generalManagerUserId);
                    if(survey.OwnerId == null ) {
                        survey.OwnerId = UserInfo.getUserId();
                    }

                    if(topic.CreateEvaluation__c == 'Yes') {
                        String topicAccountKey = topic.Id + '-' + account.Id;
                        if(accountIdEvaluationMap.containsKey(topicAccountKey)) {
                            survey.Evaluation__c = accountIdEvaluationMap.get(topicAccountKey).Id;
                        }
                    }
                    survey.DueDate__c = endDate;
                    survey.EndDate__c = endDate;
                    survey.ScheduledTopic__c = topic.Id;
                    survey.SurveyTemplate__c = surveyToClone.Id;
                    survey.Warranty_Review_2022__c = surveyToClone.Warranty_Review_2022__c;
                    survey.Warranty_Review_Instruction_2022__c = surveyToClone.Warranty_Review_Instruction_2022__c;
                    survey.Warranty_Review_Due_Date_Text_2022__c = surveyToClone.Warranty_Review_Due_Date_Text_2022__c;
                    survey.In_Store_Review__c = '';
                    survey.Is_the_Warranty_CEE_RO_Review_complete__c = '';
                    survey.ApexJobId__c = apexJobId;
                    survey.Status__c = 'Generating';
                    if(surveyRecordTypeMapping.containsKey(surveyToClone.RecordType.DeveloperName)){
                        survey.RecordTypeId = surveyRecordTypeMapping.get(surveyToClone.RecordType.DeveloperName).Id;
                    }

                    surveysToCreate.add(survey);
                }
            }
        }

        if(!surveysToCreate.isEmpty()) {
            insert surveysToCreate;
            
            for(Survey__c survey:surveysToCreate) {
                if(survey.Evaluation__c != null) {
                    //String recordTypeId = evaluationRecordTypeMapping.get(survey.RecordTypeId).Id;
                    evalsToUpdate.add(new Evaluation__c(Id = survey.Evaluation__c, Survey__c = survey.Id));
                }
            }
            if(!evalsToUpdate.isEmpty()) {
                update evalsToUpdate;
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        BatchProcessSurveyQuestionClone surveyObjectSharesBatch = new BatchProcessSurveyQuestionClone(bc.getJobId());
        Database.executeBatch(surveyObjectSharesBatch, 50);
    }
}