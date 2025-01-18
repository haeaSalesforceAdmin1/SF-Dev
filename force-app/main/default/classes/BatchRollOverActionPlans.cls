public with sharing class BatchRollOverActionPlans implements Database.Batchable<SObject> {
    
    public String query;
    public Integer monthsToAdd = 1;

    public BatchRollOverActionPlans() {

    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        if(query == null) {
            Date today = Date.today();
            query = 'select Id, DueDate__c, OriginalDueDate__c, Evaluation__c, Evaluation__r.Status__c, Evaluation__r.StartDate__c, Evaluation__r.EndDate__c, Evaluation__r.Account__c, Evaluation__r.RecordType.DeveloperName, Recordtype.DeveloperName ';
            query += ' from Action_Plan__c ';
            query += ' where DueDate__c < :today and DueDate__c != null and Status__c in (\'Open\', \'In Progress\') and RecordType.DeveloperName != \'Other\' ';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Action_Plan__c> actionPlans) {

        Map<String, Map<String, Evaluation__c>> mapOfFutureEvaluationsForAccounts = getFutureEvaluationsForAccountsFromActionPlans(actionPlans);

        for(Action_Plan__c actionPlan:actionPlans) {
            System.debug(LoggingLevel.ERROR, actionPlan.Evaluation__c);
            System.debug(LoggingLevel.ERROR, actionPlan.Evaluation__c);
            if(actionPlan.Evaluation__c != null) {
                String evaluationAccountId = actionPlan.Evaluation__r.Account__c;
                String evaluationRecordTypeDeveloperName = actionPlan.Evaluation__r.RecordType.DeveloperName;

                if(mapOfFutureEvaluationsForAccounts.containsKey(evaluationAccountId)) {
                    if(mapOfFutureEvaluationsForAccounts.get(evaluationAccountId).containsKey(evaluationRecordTypeDeveloperName)) {
                        Evaluation__c evaluation = mapOfFutureEvaluationsForAccounts.get(evaluationAccountId).get(evaluationRecordTypeDeveloperName);
                        if(evaluation.StartDate__c > actionPlan.Evaluation__r.EndDate__c) {
                            actionPlan.Evaluation__c = evaluation.Id;
                            if(actionPlan.OriginalDueDate__c == null) {
                                actionPlan.OriginalDueDate__c = actionPlan.DueDate__c;
                            }   
                            actionPlan.DueDate__c = evaluation.EndDate__c;
                        }
                    }
                }
            }
            else {
                if(actionPlan.OriginalDueDate__c == null) {
                    actionPlan.OriginalDueDate__c = actionPlan.DueDate__c;
                }   
                actionPlan.DueDate__c = actionPlan.DueDate__c.addMonths(monthsToAdd);
            }
        }

        update actionPlans;

    }

    private Map<String, Map<String, Evaluation__c>> getFutureEvaluationsForAccountsFromActionPlans(List<Action_Plan__c> actionPlans) {

        Map<String, Map<String, Evaluation__c>> mapOfAccountEvaluations = new Map<String, Map<String, Evaluation__c>>();
        Set<String> evaluationRecordTypeDeveloperNames = new Set<String>();
        Set<Id> accountIds = new Set<Id>();

        for(Action_Plan__c actionPlan:actionPlans) {    
            if(actionPlan.Evaluation__c != null && actionPlan.Evaluation__r.Status__c != 'Open' && actionPlan.Evaluation__r.Status__c != 'Draft') {
                accountIds.add(actionPlan.Evaluation__r.Account__c);
                evaluationRecordTypeDeveloperNames.add(actionPlan.Evaluation__r.RecordType.DeveloperName);
            }   
        }

        for(Evaluation__c evaluation:[select Id, Account__c, RecordType.DeveloperName, StartDate__c, EndDate__c from Evaluation__c where Status__c in ('Open', 'Draft') and Account__c in :accountIds and RecordType.DeveloperName in :evaluationRecordTypeDeveloperNames order by StartDate__c desc]) {
            if(!mapOfAccountEvaluations.containsKey(evaluation.Account__c)) {
                mapOfAccountEvaluations.put(evaluation.Account__c, new Map<String, Evaluation__c>());
            }
            if(!mapOfAccountEvaluations.get(evaluation.Account__c).containsKey(evaluation.RecordType.DeveloperName)) {
                mapOfAccountEvaluations.get(evaluation.Account__c).put(evaluation.RecordType.DeveloperName, evaluation);
            }
        }

        return mapOfAccountEvaluations;
    }

    public void finish(Database.BatchableContext BC){

    }
}