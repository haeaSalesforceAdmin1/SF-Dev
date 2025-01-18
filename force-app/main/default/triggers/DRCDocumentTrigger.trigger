/**
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
trigger DRCDocumentTrigger on DRCDocument__c (before update, before delete, after insert, after update, after delete) {
    if(Trigger.isDelete){
        Trigger_Framework.createHandler(DRCDocument__c.SObjectType);
    }else{
        for(DRCDocument__c drc : Trigger.new){
            if(drc.DRCDocumentCloneBasetId__c  == null || drc.DRCDocumentCloneBasetId__c  == '' || String.isBlank(drc.DRCDocumentCloneBasetId__c )){
                Trigger_Framework.createHandler(DRCDocument__c.SObjectType);
            }
        }
    }
}