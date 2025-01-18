public with sharing class ContentVersionTriggerHelper {

    /**
     * [Method Description] create error message when user uploads file on completed evaluation 
     * Created by [Jonghoon Kim] on [2024-] for [DPM-]
     * Edited by [Minhee Kim] on [2024-08-23] for [DPM-5746]
    */
    public static void evaluationFileValidation(Map<Id, ContentVersion> newMap) {
        System.debug('evaluationFileValidation newMap: ' + newMap);
        System.debug('evaluationFileValidation newMapvalues ' + newMap.values());

        
         Map<Id, Evaluation__c> evaluationMap = new Map<Id, Evaluation__c>(
                [SELECT Id, Status__c, ActionPlanFileId__c FROM Evaluation__c WHERE Id IN :newMap.keySet()]
        );

        for (Id evalId : newMap.keySet()) {
            Evaluation__c evaluation = evaluationMap.get(evalId);
            if (evaluation != null && evaluation.ActionPlanFileId__c != null ) { 
                String errorMessage = 'You don\'t have permission to replace or delete the Approved Action Plan.';
                newMap.get(evalId).addError(errorMessage, false);
                        
            }
                
        }
        
    }

     /**
     * [Method Description] COPP Project - Prvent to re-upload file
     * Created by [Minhee Kim] on [2024-09-26] for [DPM-5818]
     * Edited by [Minhee Kim] on [2024-10-30] for [DPM-5893] edit SObject type condition from Account to COPPInfo
    */
    public static void COPPFileValidation(Map<Id, ContentVersion> newMap) {
        System.debug('COPPFileValidation newMap: ' + newMap);
        System.debug('COPPFileValidation newMapvalues ' + newMap.values());
        UserPermission usrInfo = checkAdminUserOrNot();
        Map<Id, ContentVersion> mapContentdocContentversion = new Map<Id, ContentVersion>();
        if((!usrInfo.isSystemAdmin && usrInfo.isDPMUser)|| Test.isRunningTest()){
            List<ContentDocumentLink> coppTrackers = new List<ContentDocumentLink>();
            List<Id> contentDocIds = new List<Id>();
            Integer batchSize = 200; 

            for (Id contentVersion : newMap.keySet()) {
                if (newMap.get(contentVersion).ContentDocumentId != null) {
                    contentDocIds.add(newMap.get(contentVersion).ContentDocumentId);
                    mapContentdocContentversion.put(newMap.get(contentVersion).ContentDocumentId, newMap.get(contentVersion));
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
                        mapContentdocContentversion.get(coppTracker.ContentDocumentId).addError(errorMessage, false);
                    }
                }
            }
        }   
        
    }


   

    public static UserPermission checkAdminUserOrNot(){
        
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

    public class UserPermission{
        public Boolean isDPMUser;
        public Boolean isSystemAdmin;

        public UserPermission(Boolean DPMUser, Boolean SystemAdmin ) {
            this.isDPMUser = DPMUser;
            this.isSystemAdmin = SystemAdmin;
        }
    }
    /**
     * [Method Description] get ContentVersion related to evaluation
     * Created by [Minhee Kim] on [2024-08-23] for [DPM-5746]
    */
    public static Map<Id, ContentVersion> getEvalContentVersion(Map<Id, ContentVersion>  newMap) {
        Map<Id, ContentVersion> evluationContentVersion = new Map<Id, ContentVersion>();
        Map<Id, ContentVersion> docContentVersion = new Map<Id, ContentVersion>();
        Set<Id> contentDocumentIds = new Set<Id>();
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        UserPermission usrInfo = checkAdminUserOrNot();

        if((!usrInfo.isSystemAdmin && usrInfo.isDPMUser)|| Test.isRunningTest()){
            for (ContentVersion cv : newMap.values()) {
                if (cv.ContentDocumentId != null) {
                    contentDocumentIds.add(cv.ContentDocumentId);
                    docContentVersion.put(cv.ContentDocumentId, cv);
                }
            }

            if (!contentDocumentIds.isEmpty()) {
                try {
                    documentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                    FROM ContentDocumentLink 
                                    WHERE ContentDocumentId IN :contentDocumentIds];
                } catch (Exception e) {
                    System.debug('Error during SOQL query: ' + e.getMessage());
                }
            }

            System.debug('evaluationFileValidation documentLinks: ' + documentLinks);

            Set<Id> evaluationIds = new Set<Id>();

            for (ContentDocumentLink link : documentLinks) {
                if (link.LinkedEntityId != null && link.LinkedEntityId.getSObjectType() == Evaluation__c.SObjectType) {
                    evluationContentVersion.put(link.LinkedEntityId ,docContentVersion.get(link.ContentDocumentId));
                }
            }
        }
        return evluationContentVersion;
    }
}