/**
 * Created by user on 2023-07-03.
 */

public with sharing class ActionPlanSurveyQuestionController {

    public class FileWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Title { get; set; }
        @AuraEnabled public String Extension { get; set; }
        @AuraEnabled public String ContentDocumentId { get; set; }
        @AuraEnabled public Datetime CreatedDate { get; set; }
        @AuraEnabled public String ThumbnailFileCard { get; set; }
        @AuraEnabled public String DownloadUrl { get; set; }
        @AuraEnabled public String Url {get;set;}
    }

    public class SurveyQuestionWrapper{
        @AuraEnabled public Survey_Question__c surveyQuestion{get;set;}
        @AuraEnabled public List<Survey_Question__c> surveyQuestions{get;set;}
        @AuraEnabled public List<FileWrapper> contentVersions{get;set;}
        public SurveyQuestionWrapper(Survey_Question__c surveyQuestion, List<Survey_Question__c> surveyQuestions, List<FileWrapper> contentVersions){
            this.surveyQuestion = surveyQuestion;
            this.surveyQuestions = surveyQuestions;
            this.contentVersions = contentVersions;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<SurveyQuestionWrapper> getSurveyQuestions(String recordId){

        Map<String,Survey_Question__c> surveyQuestionMap = new Map<String,Survey_Question__c>();
        Map<String,List<Survey_Question__c>> surveyQuestionChildMap = new Map<String,List<Survey_Question__c>>();
        List<String> surveyQuestionIds = new List<String>();
        Map<String, String> contentDocumentMap = new Map<String,String>();
        Map<String, List<FileWrapper>> contentVersionMap = new Map<String, List<FileWrapper>>();
        List<SurveyQuestionWrapper> surveyQuestionWrapperList = new List<SurveyQuestionWrapper>();

        for(Survey_Question__c surveyQuestion : [
                SELECT Id, Question_Number_Text__c, Question_Text__c,Response__c,Remarks__c,Is_Parent__c,DependentQuestion__c
                FROM Survey_Question__c
                WHERE Action_Plan__c = :recordId]){
           // surveyQuestion.Question_Text__c = surveyQuestion.Question_Text__c.replaceAll('<[/a-zAZ0-9]*>','');
            if(surveyQuestion.Remarks__c != null){
                surveyQuestion.Remarks__c = surveyQuestion.Remarks__c.replaceAll('<[/a-zAZ0-9]*>','');
            }
            surveyQuestionMap.put(surveyQuestion.Id, surveyQuestion);
            surveyQuestionIds.add(surveyQuestion.Id);
            System.debug(surveyQuestion.Question_Text__c);
        }

        if(!surveyQuestionIds.isEmpty()){
            for(Survey_Question__c surveyQuestion : [
                    SELECT Id, DependentQuestion__c, Question_Text__c, Response__c
                    FROM Survey_Question__c
                    WHERE DependentQuestion__c IN :surveyQuestionIds AND Response__c='No'
                    ORDER BY Question_Number_Text__c ASC]){
                //surveyQuestion.Question_Text__c = surveyQuestion.Question_Text__c.replaceAll('<[/a-zAZ0-9]*>','');
                if(!surveyQuestionChildMap.containsKey(surveyQuestion.DependentQuestion__c)){
                    List<Survey_Question__c> surveyChildQuestions = new List<Survey_Question__c>();
                    surveyChildQuestions.add(surveyQuestion);
                    surveyQuestionChildMap.put(surveyQuestion.DependentQuestion__c, surveyChildQuestions);
                }else{
                    surveyQuestionChildMap.get(surveyQuestion.DependentQuestion__c).add(surveyQuestion);
                }
            }
            for(ContentDocumentLink contentDocumentLink : [
                    SELECT ContentDocumentId,LinkedEntityId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :surveyQuestionIds
                    ORDER BY SystemModstamp DESC]){
                contentDocumentMap.put(contentDocumentLink.ContentDocumentId, contentDocumentLink.LinkedEntityId);
            }
            for(ContentVersion contentVersion : [
                    SELECT
                            Id,
                            Title,
                            ContentDocumentId,
                            FileExtension,
                            CreatedDate
                    FROM ContentVersion
                    WHERE ContentDocumentId =:contentDocumentMap.keySet()
                    ORDER BY CreatedDate DESC
            ]){
                FileWrapper file = new FileWrapper();
                file.Id = contentVersion.Id;
                file.Title = contentVersion.Title;
                file.Extension = contentVersion.FileExtension;
                file.ContentDocumentId = contentVersion.ContentDocumentId;
                file.CreatedDate = contentVersion.CreatedDate;
                file.Url = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + contentVersion.Id;
                file.ThumbnailFileCard = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + contentVersion.Id
                        + '&operationContext=CHATTER&contentId=' + contentVersion.ContentDocumentId;
                file.DownloadUrl = '/sfc/servlet.shepherd/document/download/' + contentVersion.ContentDocumentId;

                if(!contentVersionMap.containsKey(contentDocumentMap.get(contentVersion.ContentDocumentId))){
                    List<FileWrapper> files = new List<FileWrapper>();
                    files.add(file);
                    contentVersionMap.put(contentDocumentMap.get(contentVersion.ContentDocumentId), files);
                }else{
                    contentVersionMap.get(contentDocumentMap.get(contentVersion.ContentDocumentId)).add(file);
                }
            }
            for(String id : surveyQuestionIds){
                surveyQuestionWrapperList.add(new SurveyQuestionWrapper(surveyQuestionMap.get(id), surveyQuestionChildMap.get(id), contentVersionMap.get(id)));
            }
        }
        return surveyQuestionWrapperList;
    }

    @AuraEnabled(Cacheable=true)
    public static String getActionPlanStatus(String recordId){
        return [SELECT ApprovalStatus__c FROM Action_Plan__c WHERE Id =: recordId].ApprovalStatus__c;
    }
}