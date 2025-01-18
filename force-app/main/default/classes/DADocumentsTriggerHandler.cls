/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
public with sharing class DADocumentsTriggerHandler extends Trigger_Framework.baseHandler {

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
    //     if (!run) {  return; }

        /**
         * Date 3.23.23
         * Added by Semy Lee for SO-85
         * Prevent modification of DA documents for cases that do not meet the conditions.
         */


        // Map<Id, DADocuments__c> docByDocumentId = (Map<Id, DADocuments__c>) newMapGeneric;
        // Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
        
        // Id profileId = UserInfo.getProfileId();
        // String profileName =[Select Id, Name from Profile where Id=:profileId].Name; 
        // Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');

        // if(!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission) {
        //     for(DADocuments__c da : docByDocumentId.values()) {
        //         Boolean allowed = getUpdateDocumentsBydocId.get(da.Id);
        //         System.debug('!================ allowed : ' + allowed);
        //         if(!allowed) {
        //             DADocuments__c daDocument = docByDocumentId.get(da.id); 
        //             daDocument.addError(Label.DA_Document_Error_Message);
        //         }
        //     }
        // } 
        /** SO-85 END */
    // }

    // public override void beforeDelete(Map<Id, SObject> oldMapGeneric) {
    //     if (!run) {  return; }

        /**
         * Date 3.23.23
         * Added by Semy Lee for SO-85
         * Prevent deletion of DA documents for cases that do not meet the conditions.
         */

        // Map<Id, DADocuments__c> documentsToDeleteByDocumentId = (Map<Id, DADocuments__c>) oldMapGeneric;
        // Map<Id, Boolean> getDeleteDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(documentsToDeleteByDocumentId);
        
        // Id profileId                = UserInfo.getProfileId();
        // String profileName          = [Select Id, Name from Profile where Id=:profileId].Name; 
        // Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
        
        // if(!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission) {
        //     for(DADocuments__c da : documentsToDeleteByDocumentId.values()) {
        //         Boolean allowed = getDeleteDocumentsBydocId.get(da.Id);
        //         if(!allowed) {
        //             DADocuments__c daDocument = documentsToDeleteByDocumentId.get(da.id); 
        //             daDocument.addError(Label.DA_Document_Error_Message);
        //         }
        //     }
        // }

        /** SO-85 END */

    // }
    
    // public static Boolean daDocumentError(Map<Id, SObject> beforeDoc) {
    //     Map<Id, DADocuments__c> docByDocumentId = (Map<Id, DADocuments__c>) beforeDoc;
    //     Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);

    //     for(DADocuments__c da : docByDocumentId.values()) {
    //         Boolean allowed = getUpdateDocumentsBydocId.get(da.Id);
    //         System.debug('!================ allowed : ' + allowed);
    //         if(!allowed) {
    //             DADocuments__c daDocument = docByDocumentId.get(da.id); 
    //             daDocument.addError(Label.DA_Document_Error_Message);
    //         }
    //     } 

    // }


}