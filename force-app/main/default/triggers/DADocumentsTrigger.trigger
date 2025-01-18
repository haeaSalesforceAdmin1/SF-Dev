/**
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
trigger DADocumentsTrigger on DADocuments__c (before delete, before update,after insert, after update, after delete) {
    if(Trigger.isDelete){
        Trigger_Framework.createHandler(DADocuments__c.SObjectType);
    }else{
        for(DADocuments__c da : Trigger.new){
            if(da.DADocumentCloneBasetId__c == null || da.DADocumentCloneBasetId__c == '' || String.isBlank(da.DADocumentCloneBasetId__c)){
                Trigger_Framework.createHandler(DADocuments__c.SObjectType);
            }
        }
    }
}