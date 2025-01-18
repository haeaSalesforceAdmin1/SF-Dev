public without sharing class ContentDocumentLinkTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = true; //Test by Minhee / Original: true
    public static final String PACKAGE_OBJ_API_NAME = 'Package__c'; //DNA-421
    public static final String PACKAGE_ELEMENT_OBJ_API_NAME = 'PackageElement__c'; //DNA-421
    public static final String CDL_VISIBILITY_ALL = 'AllUsers'; //DNA-421

    public override void beforeInsert(List<SObject> newListGeneric) {

        if (!run) {
            return;
        }

        List<ContentDocumentLink> newList = (List<ContentDocumentLink>) newListGeneric;

        /*BEFORE INSERT METHODS START*/
        for(ContentDocumentLink cdl : newList) {
            /*
             * Added by Sarath Pullanikkatt for DNA-421
             * ContentDocuments attached to Package Elements should be visible to Experience users
             * Updated by Cathy Sun DNA-650
             * ContentDocuments attached to Account should be visible to Experience users
             */
            String strLinkedObj = ContentDocumentUtil.getDocumentRelatedStage(cdl);
            if(strLinkedObj != NULL && (strLinkedObj == PACKAGE_OBJ_API_NAME || strLinkedObj == PACKAGE_ELEMENT_OBJ_API_NAME || strLinkedObj == 'Account')) {
                if(cdl.Visibility != CDL_VISIBILITY_ALL) {
                    cdl.Visibility = CDL_VISIBILITY_ALL;
                }
            }
            //End of code changes for DNA-421

            /* 
             * date 03.16.23
             * Added by Soyeon Kim for DPM-4602
             * ContentDocuments attached to HMA Survey Question should be visible to Experience users
             */
            Boolean relatedObjIsEval = ContentDocumentUtil.getDocumentRelatedObj(cdl);
            if(relatedObjIsEval) cdl.Visibility = CDL_VISIBILITY_ALL;
        }
        /* Date : 03.15.23
         * Added by Minhee Kim for SO-85
         * Prevent upload Documents if the case is another phase.
         * Updated by Semy Lee for SO-85
         */
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name; 
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
        Boolean hasDNACustomPermission = FeatureManagement.checkPermission('DNAMSNationalUser'); //DNA-696
        /**
        * @description : Gir Cloned Issue
        * @author San, Kang : SanKang@autoeveramerica.com | 2023-10-19
        * @tecket no: SO-275
        */
        /**
        * @description : Bug Fix - Clone Handler_ Update ContentVersionUtil.apxc Apex Class ( to pass the logic when SDA Case is closed with 'closed with monitoring')
        * @author Bitna Seong | 2024-01-03
        * @ticket no: SO-317
        * @remarks : only add !ContentVersionUtil.checkSDACaseClosedWithMonitoring(newList) in If condition
        */
        if((!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') 
        && !hasCustomPermission && !hasDNACustomPermission) && !ContentVersionUtil.CheckDocumentLinkGIRCloned(newList)
        && !ContentVersionUtil.checkSDACaseClosedWithMonitoring(newList)) {

            Map<Id, String> currentCaseStageByDocumentId = ContentDocumentUtil.getCaseCurrentStageByDocumentId(newList);
            
            // Prevent upload Documents for (Incorrect Case Stage || Closed Cases)
            Map<Id, String> currentCaseStageByDocumentLinkId = ContentDocumentUtil.getCaseCurrentStageByDocumentId(newList); 

            Map<Id, Map<String,Boolean>> DocAuthorByDocumentId = ContentDocumentUtil.checkDocAuthorByDocumentId(newList); 
            System.debug('DocAuthorByDocumentId::: '+DocAuthorByDocumentId);

            for (ContentDocumentLink contentDocumentLink : newList) {

                    String documentRelatedStage = ContentDocumentUtil.getDocumentRelatedStage(contentDocumentLink);
                    String caseStage            = currentCaseStageByDocumentLinkId.get(contentDocumentLink.LinkedEntityId);
                    System.debug('LinkedEntityId::: '+contentDocumentLink.LinkedEntityId);
    
                    Map<String, Boolean> fileAllowed = new Map<String, Boolean>();
                
                    for(Id key : DocAuthorByDocumentId.keySet()){
                        System.debug('DocAuthorByDocumentId.get(key)):::'+DocAuthorByDocumentId.get(key));
                        fileAllowed.putAll(DocAuthorByDocumentId.get(key));
                    }

                    if(fileAllowed.size()>0){
    
                        System.debug('=================== fileAllowed : ' + fileAllowed);
                        if(fileAllowed.containsKey('DADocuments__c')){
                            if(!fileAllowed.get('DADocuments__c')){
                                contentDocumentLink.addError(Label.DA_Document_Error_Message);
                            }
                        }else if(fileAllowed.containsKey('DRCDocument__c')){
                            if(!fileAllowed.get('DRCDocument__c')) {
                                contentDocumentLink.addError(Label.DRC_Document_Error_Message);
                            }
                        }else if(fileAllowed.containsKey('TRCDocument__c')){
                            if(!fileAllowed.get('TRCDocument__c')) {
                                contentDocumentLink.addError(Label.TRC_Document_Error_Message);
                            }
                        }else if(fileAllowed.containsKey('NASDADocument__c')){
                            if(!fileAllowed.get('NASDADocument__c')) {
                                contentDocumentLink.addError(Label.NASDA_Document_Error_Message);
                            }
                        }
                        //Added for DNA
                        else if(fileAllowed.containsKey('Package__c')){
                            if(!fileAllowed.get('Package__c')) { contentDocumentLink.addError(Label.PAC_Document_Error_Message); }
                        }
                        else if(fileAllowed.containsKey('PackageElement__c')){
                            if(!fileAllowed.get('PackageElement__c')) { contentDocumentLink.addError(Label.PAC_ELE_Content_Error_Message); }
                        }
                        else if(fileAllowed.containsKey('PackageRequest__c')){
                            if(!fileAllowed.get('PackageRequest__c')) { contentDocumentLink.addError(Label.DCR_Insert_Document_Error_Message); }
                        }
    
                    }else{
                        System.debug('NullPointerException');
                    }
                /** End of code changes for SO-85 */

            }  
        }

        /*BEFORE INSERT METHODS END*/
    }
    
    public override void beforeDelete(Map<Id, SObject> oldMapGeneric) {
        if (!run) {
            return;
        }
        Map<Id, ContentDocumentLink> oldMap = (Map<Id, ContentDocumentLink>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/
        if (!ContentDocumentUtil.isAuthorizedUser(UserInfo.getUserId(), UserInfo.getProfileId())) {
            // Prevent Delete Documents for (Incorrect Case Stage || Closed Cases)
            Map<Id, String> currentCaseStageByDocumentId = ContentDocumentUtil.getCaseCurrentStageByDocumentId(oldMap.values());
            for (ContentDocumentLink contentLink : oldMap.values()) {

                String documentRelatedStage = ContentDocumentUtil.getDocumentRelatedStage(contentLink);
                String caseStage = currentCaseStageByDocumentId.get(contentLink.LinkedEntityId);
                if (!String.isBlank(caseStage)) {
                     if (caseStage.equalsIgnoreCase('Request Closed')) {
                        contentLink.addError(String.format(System.Label.ERROR_WRONG_STAGE_DELETE, new List<String>{
                                'Request is already Approved or Rejected!'
                        }));
                    } else if (caseStage.equalsIgnoreCase('Closed')) {
                        contentLink.addError(String.format(System.Label.ERROR_WRONG_STAGE_DELETE, new List<String>{
                                'Original Case is Closed'
                        }));
                    } else if (!caseStage.equalsIgnoreCase('Allowed') && !documentRelatedStage.equalsIgnoreCase(caseStage)) { // Case stage will be null if the document is part of a personal library
                        contentLink.addError(String.format(System.Label.ERROR_WRONG_STAGE_DELETE, new List<String>{
                                'Delete Files Outside ' + caseStage + ' Phase'
                        }));
                    }
                }
            }
        }

        /*BEFORE DELETE METHODS END*/
    } 
    
    public override void afterInsert(Map<Id, SObject> newMapGeneric) {
        if (!run) {
            return;
        }
        Map<Id, ContentDocumentLink> newMap = (Map<Id, ContentDocumentLink>) newMapGeneric;
        ContentDocumentLinkHelper.handlePopulatingFlagForActionPlan(newMapGeneric.values());
        ContentDocumentLinkHelper.handleEvaluationFiles(newMapGeneric.values());//DPM-5879 added by MinheeKim - 12.09.2024
        /*AFTER INSERT METHODS START*/
        /*AFTER INSERT METHODS END*/
    }

    
    
}