/**
* Roll Over Carry Over Action Plan To Next Quarter.
* @author Vinit [IBM]
* @creation 17th Sept 2021
*/
public with sharing class BatchRollOverCarryOverAPToNextQuarter implements Database.Batchable<SObject> {

    public String query;

    public BatchRollOverCarryOverAPToNextQuarter(String query) {

        if (String.isNotBlank(query)) {
            
            this.query = query;
        } 
    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        if (String.isBlank(query)) {
            query = 'SELECT Id, Status__c, Account__c, Evaluation__c, EndDate__c, Question_Failed__c, Evaluation__r.RecordType.DeveloperName,RelatedSurvey__c,ApprovalStatus__c,Phase__c,DistrictApprovalDate__c,OverrideDistrictApproval__c,Original_Partner_User_ID__c,OwnerId, '; 
            query += ' RelatedSurvey__r.SurveyTemplate__r.EndDate__c ,HMASurveyQuestion__c, Is_Carry_Over_Button_Clicked__c, Evaluation__r.EndDate__c,OriginalDueDate__c,DueDate__c FROM Action_Plan__c ';
            query += ' WHERE Is_Carry_Over_Button_Clicked__c = TRUE ';
            query += ' AND Status__c = \'Carry Over\' AND Evaluation__c != NULL AND Account__c != NULL AND Evaluation__r.EndDate__c != NULL ';
            query += ' AND EndDate__c != NULL AND Question_Failed__c != NULL AND RelatedSurvey__c != NULL AND RelatedSurvey__r.SurveyTemplate__r.EndDate__c != NULL';
        }

        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.batchableContext BC, List<Action_Plan__c> actionPlans) {

        Map<String, Map<String, Evaluation__c>> mapOfFutureEvaluationsForAccounts = getFutureEvaluationsForAccountsFromActionPlans(actionPlans);
        List<Id> listOfSurveyQueToUpdate = new List<Id>(); 
        List<Id> APIds = new List<Id>();

        System.debug('actionPlans '+actionPlans);
        System.debug('mapOfFutureEvaluationsForAccounts '+mapOfFutureEvaluationsForAccounts);
        for(Action_Plan__c actionPlan:actionPlans) {

                String evaluationAccountId = actionPlan.Account__c;
                String evaluationRecordTypeDeveloperName = actionPlan.Evaluation__r.RecordType.DeveloperName;

                if( mapOfFutureEvaluationsForAccounts.containsKey(evaluationAccountId)) {
                    if(mapOfFutureEvaluationsForAccounts.get(evaluationAccountId).containsKey(evaluationRecordTypeDeveloperName)) {
                        Evaluation__c evaluation = mapOfFutureEvaluationsForAccounts.get(evaluationAccountId).get(evaluationRecordTypeDeveloperName);
                        if(evaluation.StartDate__c > actionPlan.Evaluation__r.EndDate__c) {
                            listOfSurveyQueToUpdate.add(actionPlan.HMASurveyQuestion__c);
                            if(actionPlan.OriginalDueDate__c == null) {
                                actionPlan.OriginalDueDate__c = actionPlan.DueDate__c;
                            }  
                            actionPlan.Evaluation__c = evaluation.Id;
                            actionPlan.RelatedSurvey__c = evaluation.Survey__c;
                            actionPlan.HMASurveyQuestion__c = NULL;
                            actionPlan.DueDate__c = evaluation.DueDate__c;
                            actionPlan.EndDate__c = evaluation.EndDate__c;  
                            actionPlan.Is_Carry_Over_Button_Clicked__c = FALSE;
                            actionPlan.Is_Carried_Over__c = TRUE;
                            if (actionPlan.ApprovalStatus__c == 'Region Approved' || actionPlan.ApprovalStatus__c == 'District Approved') {
                                APIds.add(actionPlan.Id);
                                actionPlan.Phase__c = 'Open'; 
                                actionPlan.DistrictApprovalDate__c = NULL;
                                actionPlan.ApprovalStatus__c = 'Not Submitted';
                                actionPlan.Status__c = 'Pending';
                                actionPlan.OverrideDistrictApproval__c = FALSE;
                                if (actionPlan.Original_Partner_User_ID__c != NULL) {
                                    actionPlan.OwnerId = actionPlan.Original_Partner_User_ID__c;
                                }

                            } 
                            
                            
                        }
                    }
                }
            
        }
        

        System.debug('actionPlans updated 1st '+actionPlans);
        if (actionPlans != NULL && actionPlans.size() > 0) {
            
            List<Action_Plan__c> tmpAPList = new List<Action_Plan__c>();
            Map<Id,String> surveyIdMap = new Map<Id,String>();
            Map<Id,Id> surveyQueMap = new Map<Id,Id>();
            for (Action_Plan__c ap : actionPlans) {
                surveyIdMap.put(ap.RelatedSurvey__c, ap.Question_Failed__c);
            }
            if (surveyIdMap != NULL && surveyIdMap.size() > 0) {
                for (Survey_Question__c sq : [SELECT Id, Question_Number_Text__c, Survey__c  
                FROM Survey_Question__c 
                WHERE Survey__c IN: surveyIdMap.KeySet()]) {
                    if (surveyIdMap.containsKey(sq.Survey__c) 
                        && surveyIdMap.get(sq.Survey__c) == sq.Question_Number_Text__c){
                     surveyQueMap.put(sq.Survey__c, sq.Id);
                    }
                }
            }
            Map<Id,Id> mapSurveyQuest = new Map<Id,Id>();
            if (surveyQueMap != NULL && surveyQueMap.size() >0) {
                for (Action_Plan__c ap : actionPlans) {
                    if (surveyQueMap.containsKey(ap.RelatedSurvey__c)) {
                        ap.HMASurveyQuestion__c = surveyQueMap.get(ap.RelatedSurvey__c);
                        mapSurveyQuest.put(ap.HMASurveyQuestion__c, ap.Id);
                    }
                   // tmpAPList.add(ap);
                }
            } 

            if (mapSurveyQuest != NULL && mapSurveyQuest.size() >0) {
                List<Survey_Question__c> listSQ = new List<Survey_Question__c>();
                for (Survey_Question__c sq : [SELECT Id, Response__c, Response_Text__c, Score__c , InitialResponseText__c, Action_Plan__c, Is_Carried_Over__c 
                                              FROM Survey_Question__c 
                                              WHERE Id IN: mapSurveyQuest.keySet()]) {
                                    sq.Action_Plan__c = mapSurveyQuest.get(sq.Id);            
                                    sq.Response__c = 'No';
                                    sq.Response_Text__c = 'No';
                                    sq.Score__c = 0;
                                    sq.InitialResponseText__c = 'No';
                                    sq.Is_Carried_Over__c = TRUE;
                                    listSQ.add(sq);    
                }
                if (listSQ != NULL && listSQ.size() > 0) {
                    update listSQ;
                }
            }

            System.debug('actionPlans updated 2nd '+actionPlans);

            update actionPlans;

            if (APIds.size() > 0) {
                List<Action_Plan__c> apList = [SELECT Id FROM Action_Plan__c WHERE Id IN:APIds];

                Approval.UnLockResult[] lrList = Approval.Unlock(apList, false);
                for(Approval.UnlockResult lr : lrList) {
                    if (lr.isSuccess()) {
                        System.debug('Successfully Unlocked Quote with ID: ' + lr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : lr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Quote fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }

          /*  System.debug('tmpAPList '+tmpAPList);
           if (tmpAPList != NULL && tmpAPList.size() > 0) {
               update tmpAPList;
           }*/
        }
        
       //  System.debug('listOfSurveyQueToUpdate '+listOfSurveyQueToUpdate);
        if (listOfSurveyQueToUpdate != NULL && listOfSurveyQueToUpdate.size() > 0) {
            List<Survey_Question__c> listSQ = new List<Survey_Question__c>();
            Map<Id,Integer> mapOfEval = new Map<Id,Integer>();
            for (Survey_Question__c sq : [SELECT Id, Response__c, Response_Text__c, Score__c, Action_Plan__c, AP_Moved_to_Next_Quarter__c, Evaluation__c 
                                          FROM Survey_Question__c 
                                          WHERE Id IN: listOfSurveyQueToUpdate]) {
                                   // Commented below code as discussed with Sylvia in Stand Up call           
                                   /* sq.Response__c = 'Yes';
                                    sq.Response_Text__c = 'Yes';
                                    sq.Score__c = 1;*/
                                    if (sq.Evaluation__c != NULL) {
                                        if (!mapOfEval.containsKey(sq.Evaluation__c)) {
                                            mapOfEval.put(sq.Evaluation__c,0);
                                        }
                                        mapOfEval.put(sq.Evaluation__c,mapOfEval.get(sq.Evaluation__c) + 1);
                                    }
                                    sq.AP_Moved_to_Next_Quarter__c = TRUE;
                                    sq.Action_Plan__c = NULL;
                                    listSQ.add(sq);
                                }
                                if (listSQ != NULL && listSQ.size() > 0) {
                                    update listSQ;
                                }

                                if (mapOfEval.size() > 0){
                                    List<Evaluation__c> listEval = new List<Evaluation__c>();
                                    for (Evaluation__c eval : [SELECT Id, Count_of_AP_Carried_Over_to_Next_Quarter__c 
                                                               FROM Evaluation__c 
                                                               WHERE Id IN:mapOfEval.keySet()]) {
                                                                eval.Count_of_AP_Carried_Over_to_Next_Quarter__c =  mapOfEval.get(eval.Id); 
                                                                listEval.add(eval);
                                    }

                                    if (listEval.size() > 0) {
                                        update listEval;
                                    }
                                }
        }


    }

    public void finish(Database.BatchableContext BC){

    }

    /**
    * Get Future Evaluations For Accounts From Action Plans
    * @param  actionPlans  list of new Action Plan
    * @return Map of Account to key as Eval Record type and value as Evaluation record    
    * @author Vinit [17th Sep 2021] [IBM]
    */
    private Map<String, Map<String, Evaluation__c>> getFutureEvaluationsForAccountsFromActionPlans(List<Action_Plan__c> actionPlans) {

        Map<String, Map<String, Evaluation__c>> mapOfAccountEvaluations = new Map<String, Map<String, Evaluation__c>>();
        Set<String> evaluationRecordTypeDeveloperNames = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Date> mapOfAccToAPEndDate = new Map<Id,Date>();
        Date currentQtrEndDate = NULL;

        for(Action_Plan__c actionPlan:actionPlans) {
            if (currentQtrEndDate == NULL) {
                currentQtrEndDate = actionPlan.RelatedSurvey__r.SurveyTemplate__r.EndDate__c;
            }
                accountIds.add(actionPlan.Account__c);
                evaluationRecordTypeDeveloperNames.add(actionPlan.Evaluation__r.RecordType.DeveloperName);
            
        }

        if (currentQtrEndDate != NULL && accountIds.size() > 0 && evaluationRecordTypeDeveloperNames.size() > 0) {
            for(Evaluation__c evaluation:[SELECT Id, EndDate__c,Survey__c,Survey__r.SurveyTemplate__r.EndDate__c,DueDate__c, 
                                      Survey__r.SurveyTemplate__r.Evaluation_Date__c, Account__c, Type__c, CloseDate__c, StartDate__c, RecordType.DeveloperName 
                                      FROM Evaluation__c 
                                      WHERE Account__c in :accountIds 
                                      AND RecordType.DeveloperName IN :evaluationRecordTypeDeveloperNames 
                                      AND Survey__r.SurveyTemplate__r.EndDate__c > :currentQtrEndDate
                                      ORDER BY StartDate__c DESC]) {

            if(!mapOfAccountEvaluations.containsKey(evaluation.Account__c)) {
                mapOfAccountEvaluations.put(evaluation.Account__c, new Map<String, Evaluation__c>());
            }
            if(!mapOfAccountEvaluations.get(evaluation.Account__c).containsKey(evaluation.RecordType.DeveloperName)) {
                mapOfAccountEvaluations.get(evaluation.Account__c).put(evaluation.RecordType.DeveloperName, evaluation);
            }
        }
        }
        

        return mapOfAccountEvaluations;
    }
}