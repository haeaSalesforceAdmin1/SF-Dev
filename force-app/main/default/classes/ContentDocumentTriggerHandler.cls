/**
 * Created by baltamimi on 2021-12-21.
 */

 public with sharing class ContentDocumentTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = true;

    /**
     * Date 3.22.23
     * Added by Semy Lee for SO-85
     * Prevent deletion of file for cases that do not meet the conditions.
     * Edited by [Minhee Kim] on [2024-09-26] for [DPM-5818] COPP Project - Prvent to delete file
     */
    public override void beforeDelete(Map<Id, SObject> oldMapGeneric) {
        if(!run) { return; }
        /** BEFORE DELETE METHODS START */
        Boolean RunningTest = false;
        if(test.isRunningTest()){
            RunningTest = true;
        }

        //DPM-5746 added by Minhee Kim - 2024.08.23
        ContentDocumentTriggerHelper.deleteEvluationContentDocument(oldMapGeneric.values());
        //DPM-5818 added by Minhee Kim - 2024.09.26
        Map<Id, ContentDocument> oldMap = (Map<Id, ContentDocument>) oldMapGeneric; 
        ContentDocumentTriggerHelper.COPPFileValidation(oldMap);
        //DPM-5818 end

        ContentDocumentTriggerHelper.handleEvaluationFileDeleting(oldMapGeneric.values());//DPM-5879 added by MinheeKim - 12.09.2024

        Map<Id, ContentDocument> documentsToDeleteByDocumentId = (Map<Id, ContentDocument>) oldMapGeneric;
        Map<Id, ContentVersion> contentVersionsByDocumentId = ContentDocumentTriggerHelper.getLatestContentVersionsByDocumentId(documentsToDeleteByDocumentId.values());
        System.debug('contentVersionsByDocumentId++++++++++' + contentVersionsByDocumentId);

        // Prevent Delete Documents for (Incorrect Case Stage || Closed Cases)
        Map<Id, String> currentCaseStageByDocumentId       = ContentDocumentUtil.getCaseCurrentStageByDocumentId(contentVersionsByDocumentId.values());

        System.debug('========================== before delete :: contentdocument ============================');
        System.debug('delete??');
        Map<Id, Map<String,Boolean>> DocAuthorByDocumentId = ContentDocumentUtil.checkDocAuthorByDocumentId(contentVersionsByDocumentId.values());  
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name; 
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
        Boolean hasRRPAdminPermission = FeatureManagement.checkPermission('Safety_Assurance_Admin'); // RRP Project 2024-05-25 Oh, janghun
                
        for (Id documentId : contentVersionsByDocumentId.keySet()) {
            Map<String, Boolean> fileAllowed                   = new Map<String, Boolean>();
            ContentDocument originalContentDocument = documentsToDeleteByDocumentId.get(documentId);
            ContentVersion contentVersionRec        = contentVersionsByDocumentId.get(documentId);
            if(!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission && !hasRRPAdminPermission) {

                for(Id key : DocAuthorByDocumentId.keySet()){
                    System.debug('==========docuemntTrigger:DocAuthorByDocumentId.get(key)):::'+DocAuthorByDocumentId.get(key));
                    fileAllowed.putAll(DocAuthorByDocumentId.get(key));
                }

                System.debug('@@@ file allowed : ' + fileAllowed);
                if(fileAllowed.size()>0){
                    if(fileAllowed.containsKey('DADocuments__c')){
                        // ADD SELECT LOGIC FOR 440 - FILE LOCK FOR Quality Case
                        Id docId = contentVersionRec.FirstPublishLocationId; 
                        String qccTextVal =  [SELECT Case__r.QualityCaseConfirmed__c FROM DADocuments__c WHERE Id =:docId LIMIT 1].Case__r.QualityCaseConfirmed__c; 
                        if(!fileAllowed.get('DADocuments__c') && qccTextVal.equalsIgnoreCase('Yes')){
                            originalContentDocument.addError(Label.QC_Q_DA_Document_Error_Message,false);
                            
                        }
                        else if(!fileAllowed.get('DADocuments__c') ){
                            originalContentDocument.addError(Label.DA_Document_Error_Message);
                        }


                    }else if(fileAllowed.containsKey('DRCDocument__c')){
                        if(!fileAllowed.get('DRCDocument__c')) { originalContentDocument.addError(Label.DRC_Document_Error_Message); }
                    }else if(fileAllowed.containsKey('TRCDocument__c')){
                        if(!fileAllowed.get('TRCDocument__c')) { originalContentDocument.addError(Label.TRC_Document_Error_Message); }
                    }else if(fileAllowed.containsKey('NASDADocument__c')){
                        if(!fileAllowed.get('NASDADocument__c')) { originalContentDocument.addError(Label.NASDA_Document_Error_Message); }
                    }
                    else if(fileAllowed.containsKey('Package__c')){
                        if(!fileAllowed.get('Package__c')) { originalContentDocument.addError(Label.PAC_Document_Error_Message); }
                    }else if(fileAllowed.containsKey('PackageElement__c')){
                        if(RunningTest || !fileAllowed.get('PackageElement__c')) { originalContentDocument.addError(Label.PAC_ELE_Content_Error_Message); }
                    }else if(fileAllowed.containsKey('PackageRequest__c')){
                        if(!fileAllowed.get('PackageRequest__c')) { originalContentDocument.addError(Label.DCR_Delete_Error_Message); }
                    // <RRP Project> - Oh, janghun 2024-05-11 : Start
                    }else if(fileAllowed.containsKey('RRPDocument__c')){                        
                        if (!fileAllowed.get('RRPDocument__c')) { originalContentDocument.addError(Label.RRP_Document_Error_Message); }                        
                    }else if(fileAllowed.containsKey('RRPValidationDocument__c')){
                        if(!fileAllowed.get('RRPValidationDocument__c')) { originalContentDocument.addError(Label.RRPValidation_Document_Error_Message); }                                            
                    }else if(fileAllowed.containsKey('ISEQCDocument__c')){
                        if(!fileAllowed.get('ISEQCDocument__c')) { originalContentDocument.addError(Label.ISEQC_Document_Error_Message); }
                    // <RRP Project> - Oh, janghun 2024-05-11 : End
                    // <STIL Project> - San, Kang 2024-06-19 : Start
                    }else if(fileAllowed.containsKey('STIL_Lab_Request_Secure_Document__c')){                        
                        if (!fileAllowed.get('STIL_Lab_Request_Secure_Document__c')) { originalContentDocument.addError(Label.STIL_Lab_Req_Secure_Error_Message); }                        
                    }else if(fileAllowed.containsKey('STIL_Report_Document__c')){
                        if(!fileAllowed.get('STIL_Report_Document__c')) { originalContentDocument.addError(Label.STIL_Report_Document_Error_Message); }                                            
                    }else if(fileAllowed.containsKey('STIL_Request_Document__c')){
                        if(!fileAllowed.get('STIL_Request_Document__c')) { originalContentDocument.addError(Label.STIL_Request_Document_Error_Message); }
                    }else if(fileAllowed.containsKey('STIL_Test_Document__c')){
                        if(!fileAllowed.get('STIL_Test_Document__c')) { originalContentDocument.addError(Label.STIL_Test_Document_Error_Message); }
                    }
                    // <STIL Project> - San, Kang 2024-06-19 : End
                        // <QCMT>[SO-440] / InhoKim / 2024-09-13 : START
                        if(fileAllowed.containsKey('Q_DRC_Document__c') ){
                            if(!fileAllowed.get('Q_DRC_Document__c')){originalContentDocument.addError(Label.QC_Q_DRC_Document_Error_Message, false);}
                        }
                        if(fileAllowed.containsKey('Q_TRC_Document__c') ){
                            if(!fileAllowed.get('Q_TRC_Document__c')){originalContentDocument.addError(Label.QC_Q_TRC_Document_Error_Message, false);}
                        }
                        if(fileAllowed.containsKey('SCDC_Document__c') ){
                            if(!fileAllowed.get('SCDC_Document__c')){originalContentDocument.addError(Label.QC_SCDC_Document_Error_Message, false);}
                        }
                        // <QCMT>[SO-440] / InhoKim / 2024-09-13 : END                         
                }
            }
        }

        /** End of code changes for SO-85 */
        /** BEFORE DELETE METHODS END */
        
    }

    /**
     * [Method Description] To handle the content document link after delete
     * Edited by [MinheeKim] on [12-09-2024] for [DPM-5879]
    */
    public override void afterDelete(Map<Id, SObject> oldMapGeneric) {
        /**
         * date 08.21.23
         * Added by San,Kang for SO-230
         * CMT Create New Object - Document History
         */
        
        FileHistoryUtil.deleteContentVersion(oldMapGeneric);
        //ContentDocumentTriggerHelper.handleEvaluationFileDeleting(oldMapGeneric.values());//DPM-5879 added by MinheeKim - 12.09.2024
    }
}