/**
 * @description       : 
 * @author            : sankang@autoeveramerica.com
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
trigger MiscDocumentTrigger on MiscDocument__c (after insert, after update, after delete) {
    if(Trigger.isDelete){
        Trigger_Framework.createHandler(MiscDocument__c.SObjectType);
    }else{
        for(MiscDocument__c misc : Trigger.new){
            if(misc.MicDocumentCloneBasetId__c   == null || misc.MicDocumentCloneBasetId__c   == '' || String.isBlank(misc.MicDocumentCloneBasetId__c  )){
                Trigger_Framework.createHandler(MiscDocument__c.SObjectType);
            }
        }
    }
}