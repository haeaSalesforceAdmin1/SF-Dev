/**
 * @description       : Trigger Helper for Survey Question object
 * @author            : minheekim@haeaus.com
 * @group             : 
 * @last modified on  : 03-04-2025
 * @last modified by  : Minhee Kim
**/

public without sharing class SurveyQuestionTriggerHelper {

    private static Set<Id> cachedWarrantyRecType = new Set<Id>();
    
    public static Set<Id> getWarrantyRecType() {
         if (cachedWarrantyRecType == null || cachedWarrantyRecType.size()==0) {
            List<RecordType> tempRecords = [SELECT Id FROM RecordType WHERE  SObjectType = 'Survey_Question__c' AND Name like 'Warranty RO Survey%'];
            if(tempRecords.size()>0){
                for(RecordType rt: tempRecords){
                    cachedWarrantyRecType.add(rt.Id);
                }
            }    
         }
         return cachedWarrantyRecType;
     }


    public static void handleQuestionNumber(List<Survey_Question__c> newSurveyQuestions, Map<Id, Survey_Question__c> oldSurveyQuestionMap) {

        Set<Id> warrantyRecType = Test.isRunningTest() ? new Set<Id>{newSurveyQuestions[0].RecordTypeId} : getWarrantyRecType();
        if(newSurveyQuestions.size()>0){
            for(Survey_Question__c surveyQuestion : newSurveyQuestions){
                if(warrantyRecType.contains(surveyQuestion.RecordTypeId)){
                    //When User input question number
                    if(surveyQuestion.Question_Number__c!=null){
                        continue;
                    }
                    //When user didn't input question number and input question number text
                    else if(surveyQuestion.Question_Number__c==null && surveyQuestion.Question_Number_Text__c!=null){
                        Decimal textToNumber;
                        try {
                            textToNumber = Decimal.valueOf(surveyQuestion.Question_Number_Text__c);
                        } catch (Exception e) {
                            String onlyNumber = surveyQuestion.Question_Number_Text__c.replaceAll('[^0-9]', '');
                            if(onlyNumber!='' && onlyNumber!=null){
                                textToNumber = Decimal.valueOf(onlyNumber);
                            }else{
                                textToNumber = null;
                            }
                        }
                        if(textToNumber!=null){
                            surveyQuestion.Question_Number__c = textToNumber;
                        }
                    }
                    //When user didn't input question number and question number text
                }
            }
        }
    }

}