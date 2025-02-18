/**
************************************************************************************************
* @classname         : ContentDocumentLinkHelper
* @description       : 
* @author            : JongHoon Kim
* History
* Version      Date                Author               Ticket         Modification
* 1.0       01-27-2025          JongHoon Kim           DPM-6036       Modified the handleEvaluationFiles method to address file upload errors.
* 1.1       02-03-2025          MinheeKim              DPM-6061       Error : System.LimitException: Too many queueable jobs added to the queue: 2
* 1.2       02-14-2025          JongHoon Kim           DPM-6084       Remove future Method.
************************************************************************************************
**/

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
            //DPM-6061 Add EvaluationTriggerHandler.run
            EvaluationTriggerHandler.run = false;
            update evalToUpdate;
            EvaluationTriggerHandler.run = true;
        }
    }

    /**
     * [Method Description] 
     * Created by [MinheeKim] on [2024-12-09] for [DPM-5879]
     * Edited by [MinheeKim] on [02-03-2025] for [DPM-6061] Error : System.LimitException: Too many queueable jobs added to the queue: 2
    */
    // Static method to enqueue the queueable job
    // public static void handleEvaluationFiles(List<ContentDocumentLink> newContentDocumentLinks) {
    //     // if (newContentDocumentLinks != null && !newContentDocumentLinks.isEmpty()) {
    //     //     System.enqueueJob(new EvaluationFilesQueueable(newContentDocumentLinks));
    //     // }

    //     if (newContentDocumentLinks == null || newContentDocumentLinks.isEmpty()) {
    //         return;
    //     }

    //     Set<Id> contentDocumentLinkIds = new Set<Id>();
    //     for (ContentDocumentLink cdl : newContentDocumentLinks) {
    //         contentDocumentLinkIds.add(cdl.Id);
    //     }

    //     updateEvaluationFiles(contentDocumentLinkIds);
    // }

    // DPM-6084 Remove @future
    // @future
    // public static void updateEvaluationFiles(Set<Id> contentDocumentLinkIds) {
    //     if (contentDocumentLinkIds == null || contentDocumentLinkIds.isEmpty()) {
    //         return;
    //     }

    //     Set<Id> evalIds = new Set<Id>();
    //     List<Evaluation__c> evalToUpdate = new List<Evaluation__c>();

    //     for (ContentDocumentLink cdl : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE Id IN :contentDocumentLinkIds]) {
    //         if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Evaluation__c' && !evalIds.contains(cdl.LinkedEntityId)) {
    //             evalToUpdate.add(new Evaluation__c(Id = cdl.LinkedEntityId, Attachment__c = 'Yes'));
    //             evalIds.add(cdl.LinkedEntityId);
    //         }
    //     }

    //     if (!evalToUpdate.isEmpty()) {
    //         EvaluationTriggerHandler.run = false;
    //         update evalToUpdate;
    //         EvaluationTriggerHandler.run = true;
    //     }
    // }

    
}