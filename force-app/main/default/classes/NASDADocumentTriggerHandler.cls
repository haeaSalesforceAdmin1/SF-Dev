/**
 * @description       : 
 * @author            : sankang@autoeveramerica.com
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
public with sharing class NASDADocumentTriggerHandler extends Trigger_Framework.baseHandler {
  
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
    //      * Date 3.23.23
    //      * Added by Semy Lee for SO-85
    //      * Prevent modification of DA documents for cases that do not meet the conditions.
    //      */
    //     Id profileId                = UserInfo.getProfileId();
    //     String profileName          = [Select Id, Name from Profile where Id=:profileId].Name; 
    //     Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
        
    //     if(!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission) {
    //         Map<Id, NASDADocument__c> documentsToUpdateByDocumentId = (Map<Id, NASDADocument__c>) newMapGeneric;
    //         // check document record type
    //         String docType = [select RecordType.DeveloperName from NASDADocument__c where id =: documentsToUpdateByDocumentId.keySet()].RecordType.DeveloperName;
    //         if(docType == null) docType = '';
    //         if(!docType.equalsIgnoreCase('MeetingDocument')) {

    //             Map<Id, Boolean> getDeleteDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(documentsToUpdateByDocumentId);    
    //             for(NASDADocument__c doc : documentsToUpdateByDocumentId.values()) {
    //                 Boolean allowed = getDeleteDocumentsBydocId.get(doc.Id);
    //                 if(!allowed) {
    //                     System.debug('================== allowed : ' + allowed);
    //                     NASDADocument__c nasdaDocument = documentsToUpdateByDocumentId.get(doc.id); 
    //                     nasdaDocument.addError(Label.NASDA_Document_Error_Message);
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
    // public override void beforeDelete(Map<Id, SObject> oldMapGeneric) {
        
    //     /**
    //      * Date 3.23.23
    //      * Added by Semy Lee for SO-85
    //      * Prevent deletion of DA documents for cases that do not meet the conditions.
    //      */
    //     Id profileId                = UserInfo.getProfileId();
    //     String profileName          = [Select Id, Name from Profile where Id=:profileId].Name; 
    //     Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
        
    //     if(!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission) {
            
    //         Map<Id, NASDADocument__c> documentsToDeleteByDocumentId = (Map<Id, NASDADocument__c>) oldMapGeneric;
    //         // check document record type
    //         String docType = [select RecordType.DeveloperName from NASDADocument__c where id =: documentsToDeleteByDocumentId.keySet()].RecordType.DeveloperName;
    //         if(docType == null) docType = '';
    //         if(!docType.equalsIgnoreCase('MeetingDocument')) {

    //             Map<Id, Boolean> getDeleteDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(documentsToDeleteByDocumentId);
    //             for(NASDADocument__c doc : documentsToDeleteByDocumentId.values()) {
    //                 Boolean allowed = getDeleteDocumentsBydocId.get(doc.Id);
    //                 if(!allowed) {
    //                     NASDADocument__c nasdaDocument = documentsToDeleteByDocumentId.get(doc.id); 
    //                     nasdaDocument.addError(Label.NASDA_Document_Error_Message);
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
    // }

}