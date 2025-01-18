public without sharing class ContentDocumentLinkHelper {

    public static void handlePopulatingFlagForActionPlan(List<ContentDocumentLink> newContentDocumentLinks) {
        
        Set<Id> actionPlanIds = new Set<Id>();
        List<Action_Plan__c> actionPlansToUpdate = new List<Action_Plan__c>();
        for(ContentDocumentLink cdl:newContentDocumentLinks) {
            if(cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Action_Plan__c' && !actionPlanIds.contains(cdl.LinkedEntityId) ) {
                actionPlansToUpdate.add(new Action_Plan__c(Id = cdl.LinkedEntityId, HasActionPlanFile__c = true));
                actionPlanIds.add(cdl.LinkedEntityId);
            }
        }

        if(!actionPlansToUpdate.isEmpty()) {
            update actionPlansToUpdate;
        }
    }

    /**
     * [Method Description] 
     * Created by [MinheeKim] on [2024-12-09] for [DPM-5879]
    */
    public static void handleEvaluationFiles(List<ContentDocumentLink> newContentDocumentLinks) {
        Set<Id> evalIds = new Set<Id>();
        List<Evaluation__c> evalToUpdate = new List<Evaluation__c>();
        for(ContentDocumentLink cdl:newContentDocumentLinks) {
            if(cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Evaluation__c' && !evalIds.contains(cdl.LinkedEntityId) ) {
                evalToUpdate.add(new Evaluation__c(Id = cdl.LinkedEntityId, Attachment__c = 'Yes'));
                evalIds.add(cdl.LinkedEntityId);
            }
        }

        if(!evalToUpdate.isEmpty()) {
            update evalToUpdate;
        }
    }

    
}