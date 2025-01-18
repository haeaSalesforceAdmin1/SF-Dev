/** Class Description
 * Ticket: DPM-5633 Genesis Retailer Evaluation Project
 * Created By: Minhee Kim
 * Created Date: 2024-07-23
 * Description: Get failed questions related to action plan to represent on the action plan pdf for Genesis.
 * 
 * **/

 public without sharing class GenesisActionPlanPDFController {

    public Evaluation__c evaluation {get; set;}
    public List<SurveyQuestionWrapper> surveyQuestionWappers {get; set;}
    public Map<String, List<SurveyQuestionWrapper>> surveyQuestionWrapperMap {get; set;}
    public List<String> mapKey {get; set;}
    public String recordId {get; set;}
    public String summary {get; set;}
    public String responsiblePerson {get; set;}
    public String completionDate {get; set;}
    public String measured {get; set;}
    

    public GenesisActionPlanPDFController(ApexPages.StandardController stdController) {
        recordId = ApexPages.currentPage().getParameters().get('id');
        surveyQuestionWappers = new List<SurveyQuestionWrapper>();
        surveyQuestionWrapperMap = new Map<String, List<SurveyQuestionWrapper>>();
    }

    public void handleLoad() {
        // setMapKey();
        getSurveyQuestions();
        summary='(What will specifically be done/changed?)';
        responsiblePerson= 'Name of responsible person​';
        completionDate= 'Completion Date​';
        measured= 'How improvement will be measured​';
    }



    public class SurveyQuestionWrapper{
        public String category{get;set;}
        public Survey_Question__c surveyQuestion{get;set;}
        public List<Survey_Question__c> surveyQuestions{get;set;}
        
        public SurveyQuestionWrapper(Survey_Question__c surveyQuestion, List<Survey_Question__c> surveyQuestions){
            this.category = surveyQuestion.Category_Type__c;
            this.surveyQuestion = surveyQuestion;
            this.surveyQuestions = surveyQuestions;
        }
    }


    public void getSurveyQuestions(){
        Evaluation__c eval = getEvaluation(recordId);
        
        Map<String,Survey_Question__c> surveyQuestionMap = new Map<String,Survey_Question__c>();
        Map<String,List<Survey_Question__c>> surveyQuestionChildMap = new Map<String,List<Survey_Question__c>>();
        List<String> surveyQuestionIds = new List<String>();
        List<SurveyQuestionWrapper> surveyQuestionWrapperList = new List<SurveyQuestionWrapper>();
        Map<String, List<SurveyQuestionWrapper>> surveyQuestionWrapperCategoryMap = new Map<String, List<SurveyQuestionWrapper>>();
        List<String> keys = new List<String>();
        List<Survey_Question__c> failedQuestions = new List<Survey_Question__c>();
        
        List<Survey_Question__c> priorityQuestions = new List<Survey_Question__c>();

        if(eval.Type__c=='Service'){
            priorityQuestions = [
                SELECT Id, Question_Number__c, Question_Text__c,Response__c,Remarks__c,Is_Parent__c,DependentQuestion__c , Benefit_Text__c, Score__c, Category_Type__c
                FROM Survey_Question__c
                WHERE Survey__c = :eval.Survey__c AND Priority__c = 'Y'  AND Response__c='No' 
                ORDER BY Category_Order__c ASC ];           
        }else if(eval.Type__c=='Sales'){
            List<Survey_Question__c> allQuestions = [
                SELECT Id, Question_Number__c, Question_Text__c,Response__c,Remarks__c,Is_Parent__c,DependentQuestion__c , Benefit_Text__c, Score__c, Category_Type__c, Sales_Category_Number__c
                FROM Survey_Question__c
                WHERE Survey__c = :eval.Survey__c  AND Response__c='No' 
                AND Priority__c!=null
                ORDER BY Priority__c, Category_Order__c ASC ]; 
                
                Map<Decimal, Survey_Question__c> mapHighPriorityQuestion = new Map<Decimal, Survey_Question__c>(); 
                if(allQuestions.size()>0){
                    for(Survey_Question__c question : allQuestions){
                        if(mapHighPriorityQuestion.containsKey(question.Sales_Category_Number__c)){
                            continue;
                        }else{
                            mapHighPriorityQuestion.put( question.Sales_Category_Number__c, question);
                            priorityQuestions.add(question);
                            System.debug('Sales q: '+question.Question_Number__c);
                        }
                    }
                }
        }
        
        if(priorityQuestions.size()>0){
            for(Survey_Question__c surveyQuestion : priorityQuestions){
               // surveyQuestion.Question_Text__c = surveyQuestion.Question_Text__c.replaceAll('<[/a-zAZ0-9]*>','');
                if(surveyQuestion.Remarks__c != null){
                    surveyQuestion.Remarks__c = surveyQuestion.Remarks__c.replaceAll('<[/a-zAZ0-9]*>','');
                }
                surveyQuestionMap.put(surveyQuestion.Id, surveyQuestion);
                surveyQuestionIds.add(surveyQuestion.Id);
                System.debug(surveyQuestion.Question_Text__c);
            }
        }


        if(!surveyQuestionIds.isEmpty()){
            List<Survey_Question__c> childQuestions = new List<Survey_Question__c>();
            
            if(eval.Type__c=='Service'){
                childQuestions = [
                    SELECT Id, DependentQuestion__c, Question_Text__c, Response__c, Category_Type__c
                    FROM Survey_Question__c
                    WHERE DependentQuestion__c IN :surveyQuestionIds AND Response__c='No' 
                    AND Priority__c = 'Y'
                    ORDER BY Category_Order__c, Question_Number_Text__c ASC];
            }else if(eval.Type__c=='Sales'){
                childQuestions = [SELECT Id, DependentQuestion__c, Question_Number__c, Question_Text__c, Response__c, Category_Type__c , Sales_Category_Number__c
                                                         FROM Survey_Question__c WHERE DependentQuestion__c IN :surveyQuestionIds AND Response__c='No' AND Priority__c!=null 
                                                         ORDER BY Category_Order__c, Priority__c ASC]; 
                
                
            }
            if(childQuestions.size()>0){
                for(Survey_Question__c surveyQuestion : childQuestions){
                    surveyQuestion.Question_Text__c = surveyQuestion.Question_Text__c.replaceAll('<[/a-zAZ0-9]*>','');
                    if(!surveyQuestionChildMap.containsKey(surveyQuestion.DependentQuestion__c)){
                        List<Survey_Question__c> surveyChildQuestions = new List<Survey_Question__c>();
                        surveyChildQuestions.add(surveyQuestion);
                        surveyQuestionChildMap.put(surveyQuestion.DependentQuestion__c, surveyChildQuestions);
                    }else{
                        surveyQuestionChildMap.get(surveyQuestion.DependentQuestion__c).add(surveyQuestion);
                    }
                }
            } 
            
            
            for(String id : surveyQuestionIds){
                surveyQuestionWrapperList.add(new SurveyQuestionWrapper(surveyQuestionMap.get(id), surveyQuestionChildMap.get(id)));
                if(surveyQuestionWrapperCategoryMap.containsKey((surveyQuestionMap.get(id).Category_Type__c).toUpperCase()) && eval.Type__c=='Service'){
                    List<SurveyQuestionWrapper> preMap = surveyQuestionWrapperCategoryMap.get((surveyQuestionMap.get(id).Category_Type__c).toUpperCase());
                    preMap.add(new SurveyQuestionWrapper(surveyQuestionMap.get(id), surveyQuestionChildMap.get(id)));
                    surveyQuestionWrapperCategoryMap.put((surveyQuestionMap.get(id).Category_Type__c).toUpperCase(), preMap);

                }else if(!surveyQuestionWrapperCategoryMap.containsKey((surveyQuestionMap.get(id).Category_Type__c).toUpperCase())){
                    List<SurveyQuestionWrapper> preMap = new List<SurveyQuestionWrapper>();
                    preMap.add(new SurveyQuestionWrapper(surveyQuestionMap.get(id), surveyQuestionChildMap.get(id)));
                    surveyQuestionWrapperCategoryMap.put((surveyQuestionMap.get(id).Category_Type__c).toUpperCase(), preMap);
                    keys.add((surveyQuestionMap.get(id).Category_Type__c).toUpperCase());
                }
            }
        }

        evaluation = eval;
        mapKey = keys;
        surveyQuestionWrapperMap = surveyQuestionWrapperCategoryMap;
        surveyQuestionWappers = surveyQuestionWrapperList;
    }

    @AuraEnabled(Cacheable=true)
    public static Evaluation__c getEvaluation(String recordId){
        return [SELECT Account__r.DealerCode__c, Account__r.Name, DueDate__c, Survey__c, ApprovalStatus__c, Status__c, Type__c, BrandCode__c FROM Evaluation__c WHERE Id =: recordId LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static String getCommunityBaseUrl() {
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        return baseUrl;
    }
}