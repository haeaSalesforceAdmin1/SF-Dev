public without sharing class SurveyQuestionCompPDFController {

    public Survey__c survey {get; set;}
    public List<SurveyQuestionWrapper> surveyQuestionWappers {get; set;}
    public Map<Id, SurveyQuestionWrapper> surveyQuestionWrapperMap {get; set;}

    public String surveyId {get; set;}

    public SurveyQuestionCompPDFController() {
        surveyId = ApexPages.currentPage().getParameters().get('id');
        surveyQuestionWappers = new List<SurveyQuestionWrapper>();
        surveyQuestionWrapperMap = new Map<Id, SurveyQuestionWrapper>();
    }

    public void handleLoad() {
       
        getSurveyDetails();
        buildSurveyQuestionWrapper();

    }

    public void getSurveyDetails() {
        survey = [SELECT Id, Dealer__r.Name, Dealer__r.Organization__r.Name, OrganizationName__c,OrganizationRef__c, 
                  OrganizationRef__r.Name, Name, Evaluation_Date__c, Latest_PDF_Version_Date__c, 
                  Latest_PDF_Version_Id__c, Evaluation__r.PrimaryContact__r.Name, Evaluation__r.PrimaryContactDate__c,
                  Owner.Name, Completed_Total_Score__c, Total_Score__c,Dealer__r.DealerCode__c, 
                  Evaluation__r.StartDate__c, Evaluation__r.Type__c,Evaluation__c, Dealer__c,  Evaluation__r.RecordType.DeveloperName, Evaluation__r.Organization__c FROM Survey__c WHERE Id = :surveyId];
        
         if (survey != NULL && survey.Evaluation__c != NULL && survey.Dealer__c != NULL && survey.Dealer__r.DealerCode__c != NULL && survey.Evaluation__r.Type__c != NULL && survey.Evaluation__r.StartDate__c != NULL) {
             String quarter =  ((String.isNotBlank(survey.Name) ? ((survey.Name).contains('Q1') ? 'Q1' : ((survey.Name).contains('Q2') ? 'Q2' : ((survey.Name).contains('Q3') ? 'Q3' : 'Q4'))) : ''));
          	String tmpName = '';
             if (survey.Evaluation__r.RecordType.DeveloperName == 'MonthlyPerformanceEvaluation' || survey.Evaluation__r.RecordType.DeveloperName == 'Other'){
                 tmpName = survey.Name;
             } else if (survey.Evaluation__r.RecordType.DeveloperName != 'MonthlyPerformanceEvaluation' && survey.Evaluation__r.Organization__c == 'Hyundai'){
                 tmpName = 'CEE';
             }else if (survey.Evaluation__r.RecordType.DeveloperName != 'MonthlyPerformanceEvaluation' && survey.Evaluation__r.Organization__c == 'Genesis'){
                 tmpName = 'Genesis';
             }
           Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+survey.Dealer__r.DealerCode__c+' '+(survey.Evaluation__r.StartDate__c).year()+' '+quarter+' '+tmpName+' - '+survey.Evaluation__r.Type__c+' - SurveyPDF'); 
          
        }
    }

    public void buildSurveyQuestionWrapper() {

        List<Survey_Question__c> surveyQuestions = SurveyQuestionController.getSurveyQuestions(surveyId, false);
        List<ContentDocumentLink> contentDocumentLinks = SurveyQuestionController.getContentDocumentsForSurvey(surveyId);

        Map<Id, List<File>> surveyQuestionContentDocumentIdMap = new Map<Id, List<File>>();
        for(ContentDocumentLink contentDocumentLink:contentDocumentLinks) {
            if(!surveyQuestionContentDocumentIdMap.containsKey(contentDocumentLink.LinkedEntityId)) {
                surveyQuestionContentDocumentIdMap.put(contentDocumentLink.LinkedEntityId, new List<File>());
            }
            surveyQuestionContentDocumentIdMap.get(contentDocumentLink.LinkedEntityId).add(new File(contentDocumentLink.ContentDocument.FileExtension, contentDocumentLink.ContentDocument.LatestPublishedVersionId, contentDocumentLink.ContentDocument.Title));//ContentDocument.LatestPublishedVersionId
        }

        for(Survey_Question__c surveyQuestion:surveyQuestions) {
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
        surveyQuestionWappers = surveyQuestionWrapperMap.values();
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
                if(surveyQuestionTableHeader.size() == 3){
                    tabularHeader3 = surveyQuestionTableHeader[2];
                }
            }
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

    @AuraEnabled
    public static String launchQueueableForSurveyGeneration(String surveyId) {

        System.debug(LoggingLevel.ERROR, surveyId);
        GeneratePDFQueueable queueable = new GeneratePDFQueueable(new List<String>{surveyId}, 'Survey', 0, 0);
        String jobId = System.enqueueJob(queueable);

        return jobId;
    } 

    @AuraEnabled
    public static AsyncApexJob getQueueableForSurveyGenerationStatus(String jobId) {
        
        return [SELECT Status, NumberOfErrors, ExtendedStatus FROM AsyncApexJob WHERE Id=:jobID];
        
    }

    @AuraEnabled
    public static Survey__c getSurveyDetails(String surveyId){
        return [select Id, Dealer__r.Name, Name, Evaluation_Date__c, Latest_PDF_Version_Date__c, Latest_PDF_Version_Id__c from Survey__c where Id = :surveyId];
    }
}