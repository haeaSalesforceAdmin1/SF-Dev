/**
* @description : RRP Project
* @author San, Kang : SanKang@autoeveramerica.com 
*/
public with sharing class RRPDocumentTriggerHandler extends Trigger_Framework.baseHandler{
    
    public override void afterInsert(Map<Id, SObject> newMapGeneric) {
        FileHistoryUtil.InsertContentDocument(newMapGeneric);
    }
    
    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric) {
        FileHistoryUtil.UpdateContentDocument(oldMapGeneric,newMapGeneric);

    }
    
    public override void afterDelete(Map<Id, SObject> oldMapGeneric) {
        FileHistoryUtil.DeleteContentDocument(oldMapGeneric);
    }
}