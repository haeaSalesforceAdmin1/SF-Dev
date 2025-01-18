public without sharing class BatchProcessTopicAutomation implements Database.Batchable<SObject> {

    public String query; 
    
    public Database.QueryLocator start(Database.BatchableContext BC){

        Date today = Date.today();
        if(query == null) {
            query = 'select Id, Type__c, NextRunDate__c, CreateRecordsFor__c, Topic_Start_Date__c, LastRunDate__c, Organization__c, Region__c, ServiceDistrict__c, SalesDistrict__c';
           //following line is commented by Neeraj for ticket number 3521, check line number 133 also 
            // query += ', Account__c, Market__c, GenesisArea__c, HyundaiArea__c, KPI__c, Division__c, Reoccurence__c from Topic__c ';
            
            query += ', Account__c, Market__c, HyundaiArea__c, KPI__c, Division__c, Reoccurence__c, DealerCodes__c from Topic__c ';
           // query += ' where RecordType.DeveloperName != \'Survey_Topic\' and NextRunDate__c = :today and (LastRunDate__c < :today or LastRunDate__c = null) and Active_Topic__c = true';
          query += ' where  NextRunDate__c = :today and (LastRunDate__c < :today or LastRunDate__c = null) and Active_Topic__c = true';
        }
        
        return Database.getQueryLocator(query);
    }

    public BatchProcessTopicAutomation() {

    }

    public BatchProcessTopicAutomation(String query) {
        this.query = query;
    }

    public void execute(Database.BatchableContext BC, List<Topic__c> topics) {

        List<Action_Plan__c> actionPlansToInsert = new List<Action_Plan__c>();
        Map<String, RecordGeneration__mdt> topicTypeRecordGenerationMap = new Map<String, RecordGeneration__mdt>();
        Map<String, List<RecordMapping__mdt>> regordGenerationRecordMappingMap = new Map<String, List<RecordMapping__mdt>>();

        for(Topic__c topic:topics) {
            if(!topicTypeRecordGenerationMap.containsKey(topic.Type__c)) {
                RecordGeneration__mdt recordGeneration = HMATopicService.getRecordMappingSettingsForType(topic.Type__c);
                if(recordGeneration != null) {
                    topicTypeRecordGenerationMap.put(topic.Type__c, recordGeneration);
                    List<RecordMapping__mdt> recordMappings = HMATopicService.getRecordMappingSettingsFromRecordMappingDeveloperName(recordGeneration.DeveloperName);
                    regordGenerationRecordMappingMap.put(recordGeneration.DeveloperName, recordMappings);
                }
            }
        }

        List<Topic__c> topicsWithDetails = HMATopicService.getTopicDetailsFromTopicsAndMappings(topics, regordGenerationRecordMappingMap.values());
        Map<String, HMATopicService.LevelWrapper> levelWrapperMap = HMATopicService.getLevelWrapperMapsFromTopics(topics);
        
        createActionPlansFromTopics(topicsWithDetails, topicTypeRecordGenerationMap, regordGenerationRecordMappingMap, levelWrapperMap, BC.getJobId());
        HMATopicService.updateRunDateForTopics(topics);        
    }

    private Map<Id, Id> getNonClosedEvaluationForLevelWrapperAccounts(List<HMATopicService.LevelWrapper> levelWrappers) {
        Set<Account> accountIds = new Set<Account>();
        for(HMATopicService.LevelWrapper levelWrapper:levelWrappers) {
            accountIds.addAll(levelWrapper.accounts);
        }

        Map<Id, Id> mapOfAccountEvaluations = new Map<Id, Id>();
        for(Evaluation__c eval:[select Id, Account__c from Evaluation__c where RecordType.DeveloperName = 'MonthlyPerformanceEvaluation' and Account__c in :accountIds and Status__c != 'Completed' and Status__c != 'Non-Compliant' order by StartDate__c]) {
            if(!mapOfAccountEvaluations.containsKey(eval.Account__c)) {
                mapOfAccountEvaluations.put(eval.Account__c, eval.Id);
            }
        }
        return mapOfAccountEvaluations;
    }

    private void createActionPlansFromTopics(List<Topic__c> topicsWithDetails, Map<String, RecordGeneration__mdt> topicTypeRecordGenerationMap,  Map<String, List<RecordMapping__mdt>> regordGenerationRecordMappingMap, Map<String, HMATopicService.LevelWrapper> levelWrapperMap, String apexJobId) {
        
        System.debug(LoggingLevel.ERROR, levelWrapperMap);
        List<Action_Plan__c> actionPlansToCreate = new List<Action_Plan__c>();

        Map<Id, Id> contactIdUserIdMap = HMATopicService.getContactUserMapFromLevelWrapper(levelWrapperMap.values());
        //Map<Id, Id> existingAccountEvaluationsMap = getNonClosedEvaluationForLevelWrapperAccounts(levelWrapperMap.values());
        Map<Id, Evaluation__c> accountNewEvaluationsMap = new Map<Id, Evaluation__c>();
        RecordType otherRecordType = [select Id from RecordType where SObjectType = 'Evaluation__c' and DeveloperName = 'Other' limit 1];
System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
 List<User> workflowAdminUsers = [select Id from User where UserName like 'sfworkflowadmin%' limit 1];
       
		string recordtype= HMAUtility.getRecordTypeIdForObjectDeveloperName( 'Action_Plan__c', 'Other');
        for(Topic__c topic:topicsWithDetails) {
            if(topicTypeRecordGenerationMap.containsKey(topic.Type__c)){
                RecordGeneration__mdt recordGeneration = topicTypeRecordGenerationMap.get(topic.Type__c);
                if(regordGenerationRecordMappingMap.containsKey(recordGeneration.DeveloperName)) {
                    String mapKey = HMATopicService.getKeyFromTopic(topic);
                    if(mapKey != null && levelWrapperMap.containsKey(mapKey)) {
System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
                        for(Account account:levelWrapperMap.get(mapKey).accounts) {
                            Action_Plan__c newObject = new Action_Plan__c();
                            for(RecordMapping__mdt recordMapping:regordGenerationRecordMappingMap.get(recordGeneration.DeveloperName)) {
                                if(recordMapping.SourceFieldAPIName__c != null) {
                                    newObject.put(recordMapping.TargetFieldAPIName__c, topic.get(recordMapping.SourceFieldAPIName__c));
                                }
                            }System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
                            if(topic.CreateRecordsFor__c != 'All District Managers' && topic.CreateRecordsFor__c != 'All Market Managers') {
                                newObject.put('Account__c', account.Id);
                                //if(existingAccountEvaluationsMap.containsKey(account.Id)) {
                                //    newobject.put('Evaluation__c', existingAccountEvaluationsMap.get(account.Id));
                                //}
                                //else {
                                Evaluation__c evaluation = new Evaluation__c(Name = topic.Division__c + ' - Other - ' + account.Name, Account__c = account.Id, RecordTypeId = otherRecordType.Id, Type__c = topic.Division__c);

                                if(topic.Reoccurence__c == 'Run Once') {
                                    evaluation.StartDate__c = topic.Topic_Start_Date__c;
                                    //DPM-5062 changed to insert endDate of HMASurvey of Topic by MH - 10/19/2023
                                    // evaluation.EndDate__c = topic.Topic_End_Date__c;
                                    evaluation.EndDate__c = topic.HMASurvey__r.EndDate__c;
                                    if(topic.HMASurvey__r.EndDate__c != null) {
                                        // evaluation.DueDate__c = topic.Topic_End_Date__c.addDays(-14);
                                        // evaluation.CloseDate__c = topic.Topic_End_Date__c.addDays(-7);
                                        evaluation.DueDate__c = topic.HMASurvey__r.DueDate__c;
                                        evaluation.CloseDate__c = topic.HMASurvey__r.EndDate__c.addDays(-7);
                                    }
                                    //}
                                    accountNewEvaluationsMap.put(account.Id, evaluation);
                                }
                            }
                            else {
                                newObject.put('MarketRef__c', account.Market__c);
                                newObject.put('MarketCode__c', account.Market__c);
                                newObject.put('MarketName__c', account.Market__c);
                                newObject.put('MarketManager__c', account.Market__c);
                                newObject.put('Aftersales_Market_Manager__c', account.Aftersales_Market_Manager__c);
                               newObject.put('GenesisMarketManagerAlt__c', account.GenesisMarketManagerAlt__c);
                                newObject.put('OrganizationRef__c', account.Organization__c);
                                newObject.put('Organization__c', account.Organization__r.Name);
                                
                                if(account.ServiceDistrict__c != null) {
                                    newObject.put('ServiceDistrict__c', account.ServiceDistrict__c);
                                    newObject.put('ServiceDistrictCode__c', account.ServiceDistrict__r.DistrictCode__c);
                                    newObject.put('ServiceDistrictName__c', account.ServiceDistrict__r.DistrictCode__c + ' - ' + account.ServiceDistrict__r.Name);
                                    newObject.put('DistrictPartsServiceManager__c', account.DistrictPartsServiceManager__c);
                                   // newObject.put('DistrictPartsServiceManagerAlt__c', account.DistrictPartsServiceManagerAlt__c);
                                }

                                if(account.SalesDistrict__c != null) {
                                    newObject.put('SalesDistrict__c', account.SalesDistrict__c);
                                    newObject.put('SalesDistrictCode__c', account.SalesDistrict__r.DistrictCode__c);
                                    newObject.put('SalesDistrictName__c', account.SalesDistrict__r.DistrictCode__c + ' - ' + account.SalesDistrict__r.Name);
                                    newObject.put('DistrictSalesManager__c', account.DistrictSalesManager__c);
                                   // newObject.put('DistrictSalesManagerAlt__c', account.DistrictSalesManagerAlt__c);
                                }
                                
                                newObject.put('RegionRef__c', account.Region__c);
                                newObject.put('RegionCode__c', account.RegionCodePicklist__c);

                                /*if(account.GenesisArea__c != null) {
                                    newObject.put('GenesisArea__c', account.GenesisArea__c);
                                    newObject.put('GenesisAreaCode__c', account.GenesisAreaCodePicklist__c);
                                    newObject.put('GenesisAreaManager__c', account.GenesisAreaManager__c);
                                    newObject.put('GenesisAreaName__c', account.GenesisArea__r.Name);
                                }*/
                            }
                            /*below 2 lines are commented and added by neeraj to optimize the code for 3483 changes
                             * As this is not in a best practice using query in loop as per salesforce. 
                             * 
							*/
                           newObject.put('RecordTypeId',recordtype);
                           // newObject.put('RecordTypeId', HMAUtility.getRecordTypeIdForObjectDeveloperName( 'Action_Plan__c', 'Other'));
                            newObject.put('Topic__c', topic.Id);
                            newObject.put('ApexJobId__c', apexJobId);
                            newObject.put('DueDate__c', HMATopicService.calculateEndDate(topic));
                            newObject.put('DateInitiated__c', Date.today());


                            Id dealerPrincipalUserId;
                            Id generalManagerUserId;
                            if(account.DealerPrincipal__c != null) {
                                dealerPrincipalUserId = contactIdUserIdMap.get(account.DealerPrincipal__c);
                            }
                            if(account.GeneralManager__c != null) {
                                generalManagerUserId = contactIdUserIdMap.get(account.GeneralManager__c);
                            }

                            if(account.SalesDistrict__r.SalesManager__c != null) {
                               /*this method contains query in for loop which is not best practice. i commented that query and provided optimized solution*/
                                string ids= HMATopicService.getTopicOwnerFromAccount(topic, account, dealerPrincipalUserId, generalManagerUserId);
                                 if(ids!=UserInfo.getUserId())
                                 {
                                     newObject.put('OwnerId',ids);
                                 }
                                else{
                                newObject.put('OwnerId', workflowAdminUsers[0].Id);// HMATopicService.getTopicOwnerFromAccount(topic, account, dealerPrincipalUserId, generalManagerUserId));
                                }
                            }

                            //System.debug(LoggingLevel.ERROR, newObject);
                            actionPlansToCreate.add(newObject);
                        }
                    }
                }
            }
        }

        if(!accountNewEvaluationsMap.values().isEmpty()) {
            insert accountNewEvaluationsMap.values();
        }

        if(!actionPlansToCreate.isEmpty()) {
            for(Action_Plan__c actionPlan:actionPlansToCreate) {
                if(actionPlan.Evaluation__c == null && actionPlan.Account__c != null && accountNewEvaluationsMap.containsKey(actionPlan.Account__c)) {
                    actionPlan.Evaluation__c = accountNewEvaluationsMap.get(actionPlan.Account__c).Id;
                }
            }
            insert actionPlansToCreate;
        }
    }

    public void finish(Database.BatchableContext BC){
        Set<Id> actionPlanIds = new Set<Id>();
        for(Action_Plan__c actionPlan:[select Id from Action_Plan__c where ApexJobId__c = :BC.getJobId() and KPI__c != null]) {
            actionPlanIds.add(actionPlan.Id);
        }

        if(!actionPlanIds.isEmpty()) {
            BatchProcessActionPlanSnapshots processActionPlanSnapshots = new BatchProcessActionPlanSnapshots(actionPlanIds);
            Database.executeBatch(processActionPlanSnapshots, 1);
        }
    }

}