/**
 * @description       : 
 * @author            : sankang@autoeveramerica.com
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
public with sharing class LegalDocumentTriggerHandler extends Trigger_Framework.baseHandler {
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