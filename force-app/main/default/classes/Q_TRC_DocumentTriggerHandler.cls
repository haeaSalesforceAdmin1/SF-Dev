/**
 * @description       : 
 * @author            : sankang@autoeveramerica.com
 * @group             : 
 * @last modified on  : 09-13-2024
 * @last modified by  : sankang@autoeveramerica.com
**/
public with sharing class Q_TRC_DocumentTriggerHandler extends Trigger_Framework.baseHandler {
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