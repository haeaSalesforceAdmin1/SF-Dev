/**
 * @description       : Trigger Handler for Survey Question object
 * @author            : minheekim@haeaus.com
 * @group             : 
 * @last modified on  : 03-04-2025
 * @last modified by  : Minhee Kim
**/

public class Survey_QuestionTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = true;
    public static Boolean isInserting = false;

    public override void beforeInsert(List<SObject> newListGeneric){

        if(!run) {
            return;
        }
        isInserting = true;
        List<Survey_Question__c> newList = (List<Survey_Question__c>) newListGeneric;
        SurveyQuestionTriggerHelper.handleQuestionNumber(newList, null);
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Survey_Question__c> oldMap = (Map<Id, Survey_Question__c>) oldMapGeneric;
        Map<Id, Survey_Question__c> newMap = (Map<Id, Survey_Question__c>) newMapGeneric;
        SurveyQuestionTriggerHelper.handleQuestionNumber(newMap.values(), oldMap);
    }


    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Survey_Question__c> newMap = (Map<Id, Survey_Question__c>) newMapGeneric;
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Survey_Question__c> oldMap = (Map<Id, Survey_Question__c>) oldMapGeneric;
        Map<Id, Survey_Question__c> newMap = (Map<Id, Survey_Question__c>) newMapGeneric;

    }

}