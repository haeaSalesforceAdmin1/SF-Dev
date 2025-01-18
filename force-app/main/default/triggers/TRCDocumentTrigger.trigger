/**
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
trigger TRCDocumentTrigger on TRCDocument__c (before update, before delete, after insert, after update, after delete) {
    if(Trigger.isDelete){
        Trigger_Framework.createHandler(TRCDocument__c.SObjectType);
    }else{
        for(TRCDocument__c trc : Trigger.new){
            if(trc.TRCDocumentCloneBasetId__c  == null || trc.TRCDocumentCloneBasetId__c  == '' || String.isBlank(trc.TRCDocumentCloneBasetId__c )){
                Trigger_Framework.createHandler(TRCDocument__c.SObjectType);
            }
        }
    }
}