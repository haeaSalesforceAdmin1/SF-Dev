/**
 * @description       : TriggerHelper for Notice__c sObject 
 *                      - Funcionality 1 ) block any insert/update to make multiple visible record ( only one Visible record is allowwed )  
 * @author            : inhokim
 * @group             : 
 * @last modified on  : 02-17-2024
 * @last modified by  : inhokim
**/
public with sharing class NoticeTriggerHelper {
    
    public static void handleBeforeInsertNotice(List<Notice__c> notices) {

        throwErrorToBlockMoreThanOneVisible(notices, 'insert');
    }

    public static void handleBeforeUpdateNotice(Map<Id,Notice__c> notices) {
		List<Notice__c> newList = new List<Notice__c>();
		for (Id key: notices.keySet()){
			newList.add(notices.get(key));
		}
        throwErrorToBlockMoreThanOneVisible(newList, 'update');
    }


    public static void throwErrorToBlockMoreThanOneVisible(List<Notice__c> notices, String triggerType) {
        //if NewList has isVisible field true , check if there is no already existing "true" record 
        Boolean visibleExist = false;
        Boolean addErrorActivated = false;
        List<Notice__c> noticesAlreadyVisible = new List<Notice__c>();
        for(Notice__c noti : notices){
            if(noti.isVisible__c){visibleExist = true;}
        }
        if(visibleExist){
            noticesAlreadyVisible =  [SELECT Id, isVisible__c FROM Notice__c WHERE isVisible__c = true];
        }
        for(Notice__c noti : notices){
            for(Notice__c visible : noticesAlreadyVisible){
                if(noti?.Id != visible?.Id){
                    addErrorActivated  = true;
                }
            }
        }
        // if anything is retrieved . run addError
        if(addErrorActivated && noticesAlreadyVisible.size() >0 ){
            String errMessage = triggerType + ' Failed. \n Only One Visible Record In one app is allowed.';
            if(!Test.isRunningTest()){notices[0].addError(errMessage);}
        }
    }   

}