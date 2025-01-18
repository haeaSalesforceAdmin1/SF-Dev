/**
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
public with sharing class DRCDocumentTriggerHandler extends Trigger_Framework.baseHandler {
    
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric) {

        if(CMT_DocumentTriggerHandlerUtil.checkProfileAuthorization(newMapGeneric)) {

            CMT_DocumentTriggerHandlerUtil.checkDocAuthorization(newMapGeneric);
        } 
    }
    public override void beforeDelete(Map<Id, SObject> oldMapGeneric) {

        if(CMT_DocumentTriggerHandlerUtil.checkProfileAuthorization(oldMapGeneric)) {

            CMT_DocumentTriggerHandlerUtil.checkDocAuthorization(oldMapGeneric);
        } 
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric) {
        FileHistoryUtil.InsertContentDocument(newMapGeneric);
    }
    
    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric) {
        FileHistoryUtil.UpdateContentDocument(oldMapGeneric,newMapGeneric);

    }
    
    public override void afterDelete(Map<Id, SObject> oldMapGeneric) {
        FileHistoryUtil.DeleteContentDocument(oldMapGeneric);
    }
    // public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric) {
        
        
    //     /**
    //      * date 03.23.23
    //      * Added by Semy Lee for SO-85 
    //      * Prevent modification of DA documents for cases that do not meet the conditions.
    //      */
    //     // Check User Profie, Permission
    //     Id profileId                                          = UserInfo.getProfileId();
    //     String profileName                                    = [Select Id, Name from Profile where Id=:profileId].Name; 
    //     Boolean hasCustomPermission                           = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
    //     if(!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission) {

    //         Map<Id, DRCDocument__c> documentsToUpdateByDocumentId = (Map<Id, DRCDocument__c>) newMapGeneric;
    //         String docType = [select RecordType.DeveloperName from DRCDocument__c where id =: documentsToUpdateByDocumentId.keySet()].RecordType.DeveloperName;
    //         System.debug('================ docType : ' + docType);
    //         if(docType == null) docType = '';
    //         if(!docType.equalsIgnoreCase('MeetingDocument')) {
    //             Map<Id, Boolean> getUpdateDocumentsBydocId            = ContentDocumentUtil.checkDocAuthorByDocumentObjId(documentsToUpdateByDocumentId);
                
    //             for(DRCDocument__c doc : documentsToUpdateByDocumentId.values()) {
    //                 Boolean allowed = getUpdateDocumentsBydocId.get(doc.Id);
    //                 System.debug('========== allowed : ' + allowed);
    //                 if(!allowed) {
    //                     DRCDocument__c daDocument = documentsToUpdateByDocumentId.get(doc.id); 
    //                     daDocument.addError(Label.DRC_Document_Error_Message);
    //                 }
    //             } 
    //         }
    //         /** SO-85 END */
    //     }
    // }
    // /* BEFORE UPDATE METHODS END */
    
    // public override void beforeDelete(Map<Id, SObject> oldMapGeneric) {
        
    //     /**
    //      * date 03.23.23
    //      * Added by Semy Lee for SO-85 
    //      * Prevent deletion of DA documents for cases that do not meet the conditions.
    //      */
    //     // Check User Profie, Permission
    //     Id profileId                                          = UserInfo.getProfileId();
    //     String profileName                                    = [Select Id, Name from Profile where Id=:profileId].Name; 
    //     Boolean hasCustomPermission                           = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
        
    //     if(!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission) {
    //         Map<Id, DRCDocument__c> documentsToDeleteByDocumentId = (Map<Id, DRCDocument__c>) oldMapGeneric;
    //         String docType = [select RecordType.DeveloperName from DRCDocument__c where id =: documentsToDeleteByDocumentId.keySet()].RecordType.DeveloperName;
    //         if(docType == null) docType = '';
    //         if(!docType.equalsIgnoreCase('MeetingDocument')) {
    //             Map<Id, Boolean> getDeleteDocumentsBydocId            = ContentDocumentUtil.checkDocAuthorByDocumentObjId(documentsToDeleteByDocumentId);
    //             for(DRCDocument__c doc : documentsToDeleteByDocumentId.values()) {
    //                 Boolean allowed = getDeleteDocumentsBydocId.get(doc.Id);
    //                 if(!allowed) {
    //                     DRCDocument__c daDocument = documentsToDeleteByDocumentId.get(doc.id); 
    //                     daDocument.addError(Label.DRC_Document_Error_Message);
    //                 }
    //             }
    //         }
    //     }
    //     /** SO-85 END */
    //     Integer i = 0;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    // }
    /* BEFORE DELETE METHODS END */
    // 0713 ajw
    // public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric) {
    //     Set<String> pName = new Set<String>();
    //     pName.addAll(new Set<String>{'Integration User', 'System Administrator'});

    //     if(CMT_DocumentTriggerHandlerUtil_3.validateProfileName(pName)) {
    //         CMT_DocumentTriggerHandlerUtil_3.addError(newMapGeneric);
    //     }
    // }
    // public override void beforeDelete(Map<Id, SObject> oldMapGeneric) {
    //     Set<String> pName = new Set<String>();
    //     pName.addAll(new Set<String>{'Integration User', 'System Administrator'});    

    //     if(CMT_DocumentTriggerHandlerUtil_3.validateProfileName(pName)) {
    //         CMT_DocumentTriggerHandlerUtil_3.addError(oldMapGeneric);
    //     }
    // }
   
}