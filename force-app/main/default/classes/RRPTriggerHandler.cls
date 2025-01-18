/**
* @description : RRP Project
* @author San, Kang : SanKang@autoeveramerica.com 
*/
public with sharing class RRPTriggerHandler extends Trigger_Framework.baseHandler {
    
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        
    }
    public override void afterInsert(Map<Id, SObject> newMapGeneric){

    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){

        // Field History Tracking init
        RRPFieldHistoryUtil.initReferences(oldMapGeneric.values());
        RRPFieldHistoryUtil.trackUserChanges(newMapGeneric.values());
        
        RRPFieldHistoryUtil.setContext(
            RRPFieldHistoryUtil.CONTEXT_TRIGGER,
            RRP__c.getSObjectType().getDescribe().getName(),
            RRPTriggerHandler.class.getName()
            );
            
        // Field History Tracking save logs
        RRPFieldHistoryUtil.takeSnapshots(newMapGeneric.keySet());
        RRPFieldHistoryUtil.commitLogs();
        RRPFieldHistoryUtil.resetContext(RRPFieldHistoryUtil.CONTEXT_TRIGGER);
    }

}