/**
 * @description       : TRC Document TriggerHandler Class
 * @author            : kimgil419@gmail.com
 * @group             : solomontech
 * @last modified on  : 08-04-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
public with sharing class TRCDocumentTriggerHandler extends Trigger_Framework.baseHandler {

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){

        if(CMT_DocumentTriggerHandlerUtil.checkProfileAuthorization(newMapGeneric)) {
            CMT_DocumentTriggerHandlerUtil.checkDocAuthorization(newMapGeneric);
        } 
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){

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

//    /**
//     * @description : Add Document Error / Code refactoring
//     * @author San, Kang : SanKang@autoeveramerica.com | 2023-07-13
//     * @param Map<Id, SObject> beforeDoc
//     */
//    public static void trcDocumentError(Map<Id, SObject> beforeDoc) {
//        try{
//
//            Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(beforeDoc);
//            for(SObject trcObj : beforeDoc.values()) {
//                Boolean allowed = getUpdateDocumentsBydocId.get(trcObj.Id);
//                if(!allowed) {
//                    TRCDocument__c daDocument = (TRCDocument__c)beforeDoc.get(trcObj.id);
//                    daDocument.addError(Label.TRC_Document_Error_Message);
//                }
//            }
//        }catch(Exception e){
//            System.debug('exception =>' + e);
//        }
//    }
}



//    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric) {
//        /**
//         * Date 3.23.23
//         * Added by Semy Lee for SO-85
//         * Prevent modification of TRC documents for cases that do not meet the conditions.
//         */
//
//        Id profileId                = UserInfo.getProfileId();
//        String profileName          = [Select Id, Name from Profile where Id=:profileId].Name;
//        Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
//        if(!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission) {
//
//            Map<Id, TRCDocument__c> docByDocumentId = (Map<Id, TRCDocument__c>) newMapGeneric;
//            // check document record type
//            String docType = [select RecordType.DeveloperName from TRCDocument__c where id =: docByDocumentId.keySet()].RecordType.DeveloperName;
//            if(docType == null) docType = '';
//            if(!docType.equalsIgnoreCase('MeetingDocument')) {
//                Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
//                for(TRCDocument__c doc : docByDocumentId.values()) {
//                    Boolean allowed = getUpdateDocumentsBydocId.get(doc.Id);
//                    System.debug('========== allowed : ' + allowed);
//                    if(allowed != null && !allowed) {
//                        TRCDocument__c daDocument = docByDocumentId.get(doc.id);
//                        daDocument.addError(Label.TRC_Document_Error_Message);
//                    }
//                }
//            }
//        }
//        /** SO-85 END */
//        if(Test.isRunningTest()) {
//            Integer i = 0;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//        }
//    }
//
//    public override void beforeDelete(Map<Id, SObject> oldMapGeneric) {
//
//        /**
//         * Date 3.23.23
//         * Added by Semy Lee for SO-85
//         * Prevent deletion of TRC documents for cases that do not meet the conditions.
//         */
//        Id profileId                = UserInfo.getProfileId();
//        String profileName          = [Select Id, Name from Profile where Id=:profileId].Name;
//        Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
//        if(!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission) {
//
//            Map<Id, TRCDocument__c> documentsToDeleteByDocumentId = (Map<Id, TRCDocument__c>) oldMapGeneric;
//            String docType = [select RecordType.DeveloperName from TRCDocument__c where id =: documentsToDeleteByDocumentId.keySet()].RecordType.DeveloperName;
//            if(docType == null) docType = '';
//            if(!docType.equalsIgnoreCase('MeetingDocument')) {
//
//                Map<Id, Boolean> getDeleteDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(documentsToDeleteByDocumentId);
//                for(TRCDocument__c doc : documentsToDeleteByDocumentId.values()) {
//                    Boolean allowed = getDeleteDocumentsBydocId.get(doc.Id);
//                    System.debug('========== allowed : ' + allowed);
//                    if(allowed != null && !allowed) {
//                        TRCDocument__c daDocument = documentsToDeleteByDocumentId.get(doc.id);
//                        daDocument.addError(Label.TRC_Document_Error_Message);
//                    }
//                }
//            }
//
//        }
//        /** SO-85 END */
//        if(Test.isRunningTest()) {
//            Integer i = 0;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//            i++;
//        }
//
//    }