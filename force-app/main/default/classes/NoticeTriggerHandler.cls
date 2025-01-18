/**
 * @description       : 
 * @author            : inhokim
 * @group             : 
 * @last modified on  : 02-15-2024
 * @last modified by  : inhokim
**/
public with sharing class NoticeTriggerHandler extends Trigger_Framework.baseHandler{
    public override void beforeInsert(List<SObject> newListGeneric){
        List<Notice__c> newList = (List<Notice__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        NoticeTriggerHelper.handleBeforeInsertNotice(newList);
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Notice__c> oldMap = (Map<Id, Notice__c>) oldMapGeneric;
        Map<Id, Notice__c> newMap = (Map<Id, Notice__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        NoticeTriggerHelper.handleBeforeUpdateNotice(newMap);
        /*BEFORE UPDATE METHODS END*/
    }   
}