/**
 * Created by baltamimi on 2021-12-21.
 */

public inherited sharing class ContentDocumentTriggerHelper {

    public static Map<Id, ContentVersion> getLatestContentVersionsByDocumentId(List<ContentDocument> contentDocuments) {
        Set<Id> contentVersionsIds = new Set<Id>();

        for (ContentDocument contentDocument : contentDocuments) {
            contentVersionsIds.add(contentDocument.LatestPublishedVersionId);
        }
        List<ContentVersion> latestVersions = [SELECT Id, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE Id IN :contentVersionsIds];

        Map<Id, ContentVersion> latestVersionsByDocumentId = new Map<Id, ContentVersion>();
        for(ContentVersion contentVersion: latestVersions){
            latestVersionsByDocumentId.put(contentVersion.ContentDocumentId, contentVersion);
        }

        return latestVersionsByDocumentId;

    }

    /**
     * [Method Description] Prevent user to delete file in evaluation
     * Created by [MinheeKim] on [2024-08-23] for [DPM-5746]
    */
    public static void deleteEvluationContentDocument(List<ContentDocument> contentDocuments) {
        Set<Id> contentDocumentIds = new Set<Id>();
        Map<Id, ContentDocumentLink> documentLinkMap = new Map<Id, ContentDocumentLink>();
        Set<Id> evaluationIds = new Set<Id>();
        Boolean isAdmin =checkAdminUserOrNot();

        for (ContentDocument contentDocument : contentDocuments) {
            contentDocumentIds.add(contentDocument.Id);
        }
        List<ContentDocumentLink> contentDocLink = new List<ContentDocumentLink>();
        if(contentDocumentIds.size()>0) contentDocLink= [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds];

        for (ContentDocumentLink link : contentDocLink) {
            if (link.LinkedEntityId != null && link.LinkedEntityId.getSObjectType() == Evaluation__c.SObjectType) {
                evaluationIds.add(link.LinkedEntityId);
                documentLinkMap.put(link.ContentDocumentId, link);
            }
        }
        if (!evaluationIds.isEmpty()) {
            Map<Id, Evaluation__c> evaluationMap = new Map<Id, Evaluation__c>(
                [SELECT Id, Status__c, ActionPlanFileId__c FROM Evaluation__c WHERE Id IN :evaluationIds]
            );

            for (ContentDocument cd : contentDocuments) {
                ContentDocumentLink link = documentLinkMap.get(cd.Id);
                if (link != null) {
                    Evaluation__c evaluation = evaluationMap.get(link.LinkedEntityId);
                    if (evaluation != null && evaluation.ActionPlanFileId__c != null && !isAdmin) { 
                        String errorMessage = 'You don\'t have permission to replace or delete the Approved Action Plan.';
                        System.debug('Error Message: ' + errorMessage); 

                        cd.addError(errorMessage, false);
                        
                    }
                }
            }
        }

    }

    /**
     * [Method Description] COPP Project - Prevent to delete file
     * Created by [Minhee Kim] on [2024-09-26] for [DPM-5818]
     * Edited by [Minhee Kim] on [2024-10-30] for [DPM-5893] edit SObject type condition from Account to COPPInfo
    */
    public static void COPPFileValidation(Map<Id, ContentDocument> oldMap) {
        System.debug('COPPFileValidation contentDocuments: ' + oldMap.values());

        UserPermission usrInfo = checkUserInfo();
        Map<Id, ContentVersion> mapContentdocContentversion = new Map<Id, ContentVersion>();
        if(!usrInfo.isSystemAdmin && usrInfo.isDPMUser){
            List<ContentDocumentLink> coppTrackers = new List<ContentDocumentLink>();
            List<Id> contentDocIds = new List<Id>();
            Integer batchSize = 200; 

            for (Id contentDoc : oldMap.keySet()) {
                contentDocIds.add(contentDoc);
            }

            List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocIds];

            if(contentVersions.size()>0){
                for(ContentVersion contentversion: contentVersions){
                    mapContentdocContentversion.put(contentversion.ContentDocumentId, contentversion);
                }
            }
                

            for (Integer i = 0; i < contentDocIds.size(); i += batchSize) {
                List<Id> batchDocIds = new List<Id>();
                for (Integer j = i; j < Math.min(i + batchSize, contentDocIds.size()); j++) {
                    batchDocIds.add(contentDocIds[j]);
                }

                coppTrackers.addAll([SELECT ContentDocumentId, LinkedEntityId  , ContentDocument.Title
                                    FROM ContentDocumentLink 
                                    WHERE ContentDocumentId IN :batchDocIds 
                                    ORDER BY SystemModstamp DESC]);
            }
            
            if(coppTrackers.size()>0){
                for(ContentDocumentLink coppTracker : coppTrackers){
                    if (coppTracker.LinkedEntityId != null && coppTracker.LinkedEntityId.getSObjectType() == COPPInfo__c.SObjectType && coppTracker.ContentDocument.Title.contains('COPP_Tracker_Letter_')) {
                        String errorMessage = 'You don\'t have permission to replace or delete the COPP tracker pdf.';
                        oldMap.get(coppTracker.ContentDocumentId).addError(errorMessage, false);
                    }
                }
            }
        }   
        
    }

    public static Boolean checkAdminUserOrNot(){
        User userDetail = [
                SELECT Id
                        , Name
                        , Profile.Name
                FROM    User
                WHERE   Id =: UserInfo.getUserId()
                LIMIT   1
        ];
        
        if(userDetail.Profile.Name =='System Administrator'){
            return true;
        }
        else{
            return false;
        }
    }

    public class UserPermission{
        public Boolean isDPMUser;
        public Boolean isSystemAdmin;

        public UserPermission(Boolean DPMUser, Boolean SystemAdmin ) {
            this.isDPMUser = DPMUser;
            this.isSystemAdmin = SystemAdmin;
        }
    }

    public static UserPermission checkUserInfo(){
        
        Boolean isSystemAdmin;
        User userDetail = [
                SELECT Id
                        , Name
                        , Profile.Name
                        , DPM_User__c
                FROM    User
                WHERE   Id =: UserInfo.getUserId()
                LIMIT   1
        ];
        
        
        if(userDetail.Profile.Name =='System Administrator'){
            isSystemAdmin = true;
        }else{
            isSystemAdmin= false;
        }
        UserPermission usrInfo = new UserPermission(userDetail.DPM_User__c, isSystemAdmin);

        return usrInfo;
        
    }

    /**
     * [Method Description] Check if the evaluation doesn't have attached file after deleting the file
     * Created by [MinheeKim] on [2024-12-09] for [DPM-5879]
    */
    public static void handleEvaluationFileDeleting(List<ContentDocument> contentDocuments) {
        Set<Id> evaluationIds = new Set<Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        List<Evaluation__c> evalToUpdate = new List<Evaluation__c>();
        List<ContentDocumentLink> evalContentDocLink = new List<ContentDocumentLink>();
        Map<Id, List<ContentDocumentLink>> evalDocumentLinkMap = new Map<Id, List<ContentDocumentLink>>();
        for (ContentDocument contentDocument : contentDocuments) {
            contentDocumentIds.add(contentDocument.Id);
        }
        List<ContentDocumentLink> contentDocLink = new List<ContentDocumentLink>();
        if(contentDocumentIds.size()>0) contentDocLink= [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds];

        for (ContentDocumentLink link : contentDocLink) {
            if (link.LinkedEntityId != null && link.LinkedEntityId.getSObjectType() == Evaluation__c.SObjectType) {
                evaluationIds.add(link.LinkedEntityId);
            }
        }
        if (evaluationIds != null && !evaluationIds.isEmpty()) {
            evalContentDocLink= [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:evaluationIds];
        }
        // List<ContentDocumentLink> evalContentDocLink= [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:evaluationIds];

        for(ContentDocumentLink link:evalContentDocLink){
            if(!evalDocumentLinkMap.containsKey(link.LinkedEntityId)){
                    List<ContentDocumentLink> links = new List<ContentDocumentLink>();
                    links.add(link);
                    evalDocumentLinkMap.put(link.LinkedEntityId, links);
            }else{
                List<ContentDocumentLink> links = evalDocumentLinkMap.get(link.LinkedEntityId);
                links.add(link);
                evalDocumentLinkMap.put(link.LinkedEntityId, links);
            }
        }


        // DPM - 5879 01.08.25 by JongHoon Kim 
        for(Id evalId : evalDocumentLinkMap.keySet() ){
            if(evalDocumentLinkMap.get(evalId).size()<=1){
                evalToUpdate.add(new Evaluation__c(Id = evalId, Attachment__c = 'No')); 
            }
        }
 
        try {
            if(!evalToUpdate.isEmpty()) {
                EvaluationTriggerHandler.run = false;
                update evalToUpdate;
                EvaluationTriggerHandler.run = true;
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
}