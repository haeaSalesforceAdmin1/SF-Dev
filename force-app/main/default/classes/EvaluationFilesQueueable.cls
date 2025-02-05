/**
************************************************************************************************
* @classname         : EvaluationFilesQueueable
* @description       : 
* @author            : JongHoon Kim
* History
* Version      Date                Author               Ticket         Modification
* 1.0       2025-01-27           JongHoon Kim           DPM-6036       Modified to fix errors related to Too many Query Limit Error and Action Plan Upload Flow
************************************************************************************************
**/

public class EvaluationFilesQueueable implements Queueable {
    private List<ContentDocumentLink> contentDocumentLinks;

    public EvaluationFilesQueueable(List<ContentDocumentLink> contentDocumentLinks) {
        this.contentDocumentLinks = contentDocumentLinks;
    }

    public void execute(QueueableContext context) {
        Set<Id> evalIds = new Set<Id>();
        List<Evaluation__c> evalToUpdate = new List<Evaluation__c>();


        // [TBD] Only Upload Action Plan flow error start
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Evaluation__c']) {
            recordTypeMap.put(rt.DeveloperName, rt.Id);
        }

        Id serviceRecordTypeId = recordTypeMap.get('Genesis_Retailer_Eval_Service');
        Id salesRecordTypeId = recordTypeMap.get('Genesis_Retailer_Eval_Sales');
        // end
        Set<Id> linkedEntityIds = new Set<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Evaluation__c') {
                linkedEntityIds.add(cdl.LinkedEntityId);
            }
        }

        Map<Id, Evaluation__c> evaluationsMap = new Map<Id, Evaluation__c>(
            [SELECT Id, RecordTypeId FROM Evaluation__c WHERE Id IN :linkedEntityIds]
        );

        for (ContentDocumentLink cdl : contentDocumentLinks) {
            Evaluation__c eval = evaluationsMap.get(cdl.LinkedEntityId);
            // [TBD] Only Upload Action Plan flow error start RecordTypeId decision
            if (eval != null && eval.RecordTypeId != serviceRecordTypeId && eval.RecordTypeId != salesRecordTypeId && !evalIds.contains(eval.Id)) {
                evalToUpdate.add(new Evaluation__c(Id = eval.Id, Attachment__c = 'Yes'));
                evalIds.add(eval.Id);
            }
        }
        if (!evalToUpdate.isEmpty()) {
            update evalToUpdate;
        }
    }
}