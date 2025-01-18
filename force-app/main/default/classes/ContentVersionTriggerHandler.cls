/**
 * Created by baltamimi on 2021-12-20.
 * Specify test class :   ContentVersionTriggerTest,BatchProcessCUVcorpLibraryPublishTest,BatchProcessCUVcorpLibraryFileDeleteTest
 */

 public with sharing class ContentVersionTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = true;
    public static Boolean skipForClone = false;// DNA-890 Flag to skip the after update execution while cloning the package    

    public override void beforeInsert(List<SObject> newListGeneric) {

        if(!run) { return; }
       
        /**
         * date 03.23.23
         * Added by Semy Lee for SO-85 
         * Prevent file upload new version in cases that do not meet the conditions
         * Modified by InhoKim for SO-440 
         */
        
        //BEFOREINSERT LOGIC FOR CMT 
        System.debug('============================ before insert : content vesrion ============================');
        List<ContentVersion> newContVersionList  = (List<ContentVersion>)newListGeneric;
        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>();
        System.debug('=========================== cv/b.insert : ' + newContVersionList);
        Map<Id, Map<String, Boolean>> checkAllowedFileVersionUpload = new Map<Id, Map<String, Boolean>>();
        for(ContentVersion cv : newContVersionList) {
            // IF : FILE IS UPLOADED BY OTHER WAYS - FirstPublishLocationId (X) / ContentDocumentId (O)
            if(cv.ContentDocumentId != null ) { cvMap.put(cv.ContentDocumentId, cv); } 
            // ELSE : FILE IS UPLOADED USING - CUSTOM DOCUMENT OBJECT's "ADD FILES" BUTTON - FirstPublishLocationId (O) / ContentDocumentId (X)
            else { 
                checkAllowedFileVersionUpload = ContentDocumentUtil.checkDocAuthorByDocumentId(newContVersionList); 
            }
        }

        //
        System.debug('cvMap.size()??' + cvMap.size());
        if(cvMap.size() > 0) {
            Set<Id> contentDocId                 = cvMap.keySet();
            List<ContentDocumentLink> conDocLink = [select LinkedEntity.Type, LinkedEntityId from contentDocumentLink where  ContentDocumentId IN: contentDocId];
            checkAllowedFileVersionUpload = ContentDocumentUtil.checkDocAuthorByDocumentId(conDocLink);
        }
        Map<String, Boolean> fileAllowed = new Map<String, Boolean>();
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name; 
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
        Boolean hasDNACustomPermission = FeatureManagement.checkPermission('DNAMSNationalUser'); //DNA-696
        Boolean hasRRPAdminPermission = FeatureManagement.checkPermission('Safety_Assurance_Admin'); // RRP Project 2024-05-25 Oh, janghun
        /**
        * @description : Gir Cloned Issue
        * @author San, Kang : SanKang@autoeveramerica.com | 2023-10-19
        * @ticket no: SO-275
        */
        if((!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission && !hasDNACustomPermission &&!hasRRPAdminPermission) && !ContentVersionUtil.CheckGIRCloned(newContVersionList)) {
            for(Id key : checkAllowedFileVersionUpload.keySet()) {
                System.debug('==== key : ' + key);
                fileAllowed.putAll(checkAllowedFileVersionUpload.get(key));
            }
            System.debug('=========================== b.insert/fileAllowed : ' + fileAllowed);
            System.debug('=========================== b.insert/fileAllowed.size() : ' + fileAllowed.size());
            
            for(ContentVersion cv : newContVersionList) {
                if(fileAllowed.size()>0){
                    if(fileAllowed.containsKey('DADocuments__c') ){
                        // ADD SELECT LOGIC FOR 440 - FILE LOCK FOR Quality Case
                        // ADD SELECT LOGIC FOR 440 - FILE LOCK FOR Quality Case
                        Id versionUpdateDocId = cv.FirstPublishLocationId; Id contDocId = cv.ContentDocumentId ?? versionUpdateDocId;// ADD SOME null handling expression during SO-440 QA 
                        List<ContentDocumentLink> contentDocLinks = [SELECT Id, LinkedEntityId, LinkedEntity.Type, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId =:contDocId];
                        // Initialize a list to store filtered records
                        List<ContentDocumentLink> filteredLinks = new List<ContentDocumentLink>();
                        
                        // Loop through the list and filter based on LinkedEntity Type
                        for (ContentDocumentLink docLink : contentDocLinks) {
                            // Check the type of the LinkedEntity
                            if (docLink.LinkedEntity.Type == 'DADocuments__c') {
                                // If the LinkedEntity is of type Account, add it to the filtered list
                                filteredLinks.add(docLink);
                                versionUpdateDocId = (Id)docLink.LinkedEntityId;
                            }
                        }
                        Id docId = cv.FirstPublishLocationId ?? versionUpdateDocId; 
                        String qccTextVal =  [SELECT Case__r.QualityCaseConfirmed__c FROM DADocuments__c WHERE Id =:docId LIMIT 1].Case__r.QualityCaseConfirmed__c ?? '';// ?,?? Safe Navigation Operaotrs 
                        if(!fileAllowed.get('DADocuments__c') && qccTextVal.equalsIgnoreCase('Yes')){
                            cv.addError(Label.QC_Q_DA_Document_Error_Message, false);
                        }
                        else if(!fileAllowed.get('DADocuments__c') ){
                            cv.addError(Label.DA_Document_Error_Message);
                        }
                    }
                    if(fileAllowed.containsKey('DRCDocument__c')){
                        if(!fileAllowed.get('DRCDocument__c')){
                            cv.addError(Label.DRC_Document_Error_Message);
                        }
                    }
                    if(fileAllowed.containsKey('TRCDocument__c')){
                        if(!fileAllowed.get('TRCDocument__c')){
                            cv.addError(Label.TRC_Document_Error_Message);
                        }
                    }
                    if(fileAllowed.containsKey('NASDADocument__c')){
                        if(!fileAllowed.get('NASDADocument__c')){
                            cv.addError(Label.NASDA_Document_Error_Message);
                        }
                    }
                    //Added for DNA
                    if(fileAllowed.containsKey('Package__c')){
                        if(!fileAllowed.get('Package__c')) { cv.addError(Label.PAC_Document_Error_Message); }
                    }
                    if(fileAllowed.containsKey('PackageElement__c')){
                        if(!fileAllowed.get('PackageElement__c')) { cv.addError(Label.PAC_ELE_Content_Error_Message); }
                    }
                    if(fileAllowed.containsKey('PackageRequest__c')){
                        if(!fileAllowed.get('PackageRequest__c')) { cv.addError(Label.DCR_Insert_Document_Error_Message); }
                    }
                    //End here
                    // <RRP Project> - Oh, janghun 2024-05-11 : Start
                    if(fileAllowed.containsKey('RRPDocument__c') ){
                        if(!fileAllowed.get('RRPDocument__c')){ 
                            cv.addError(Label.RRP_Document_Error_Message); 
                        }
                    }
                    if(fileAllowed.containsKey('RRPValidationDocument__c') ){
                        if(!fileAllowed.get('RRPValidationDocument__c')){
                            cv.addError(Label.RRPValidation_Document_Error_Message);
                        }
                    }
                    if(fileAllowed.containsKey('ISEQCDocument__c') ){
                        if(!fileAllowed.get('ISEQCDocument__c')){
                            cv.addError(Label.ISEQC_Document_Error_Message);
                        }
                    }
                    // <RRP Project> - Oh, janghun 2024-05-11 : End
                    // <STIL Project> - San, Kang 2024-06-19 : Start
                    if(fileAllowed.containsKey('STIL_Lab_Request_Secure_Document__c') ){
                        if(!fileAllowed.get('STIL_Lab_Request_Secure_Document__c')){ 
                            cv.addError(Label.STIL_Lab_Req_Secure_Error_Message); 
                        }
                    }
                    if(fileAllowed.containsKey('STIL_Report_Document__c') ){
                        if(!fileAllowed.get('STIL_Report_Document__c')){
                            cv.addError(Label.STIL_Report_Document_Error_Message);
                        }
                    }
                    if(fileAllowed.containsKey('STIL_Request_Document__c') ){
                        if(!fileAllowed.get('STIL_Request_Document__c')){
                            cv.addError(Label.STIL_Request_Document_Error_Message);
                        }
                    }
                    if(fileAllowed.containsKey('STIL_Test_Document__c') ){
                        if(!fileAllowed.get('STIL_Test_Document__c')){
                            cv.addError(Label.STIL_Test_Document_Error_Message);
                        }
                    }
                    
                    // <QCMT>[SO-440] / InhoKim / 2024-09-13 : START
                    if(fileAllowed.containsKey('Q_DRC_Document__c') ){
                        if(!fileAllowed.get('Q_DRC_Document__c')){
                            cv.addError(Label.QC_Q_DRC_Document_Error_Message, false);
                        }
                    }
                    if(fileAllowed.containsKey('Q_TRC_Document__c') ){
                        if(!fileAllowed.get('Q_TRC_Document__c')){
                            cv.addError(Label.QC_Q_TRC_Document_Error_Message, false);
                        }
                    }
                    if(fileAllowed.containsKey('SCDC_Document__c') ){
                        if(!fileAllowed.get('SCDC_Document__c')){
                            cv.addError(Label.QC_SCDC_Document_Error_Message, false);
                        }
                    }
                    // <QCMT>[SO-440] / InhoKim / 2024-09-13 : END

                }
            }
        }
            /** SO-85 END */

    }// END OF CONTENTVERSION BEFORE INSERT
    
        /**
         * [Method Description] prevent the user to upload files
         * Created by [MinheeKim] on [2024-08-23] for [DPM-5746]
        */
    public override void afterInsert(Map<Id,Sobject> newMapGeneric) {
        if(!run) { return; }
        system.debug('Entered After Insert');
        Map<Id, ContentVersion> newMap = (Map<Id, ContentVersion>) newMapGeneric; 

        //DPM-5764 start
        Map<Id, ContentVersion> evluationContentVersion = ContentVersionTriggerHelper.getEvalContentVersion(newMap);
        if(evluationContentVersion.size()>0) ContentVersionTriggerHelper.evaluationFileValidation(evluationContentVersion);
		//DPM-5764 end
        //DPM-5818 start
        ContentVersionTriggerHelper.COPPFileValidation(newMap);
        //DPM-5818
        //After INSERT METHODS START
        
        
        /**
         * @description : Part of afterinsert - CUVCPO CORP Library Batch 
         * @author Inho Kim | 2024-07-25
         * @ticket no: CCSOM-59
         */
        Set<Id> newContentDocumentIds = new Set<Id>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        //3 Connect to new ws using ContentDocumentLink objects for the newly inserted ContentVersions
        List<ContentFolderMember> folderMembersToUpdate = new List<ContentFolderMember>();
        List<Id> contentDocumentIdstoPub = new List<Id>(); 
        List<Id> contentDocumentIdstoDel = new List<Id>(); 
        List<Id> targetFolderIdsPub = new List<Id>();
        for (ContentVersion contVer : newMap.values()){
            if((contVer.Publish_Date__c != null && contVer.Publish_Date__c == Date.today()) ) {
                System.debug(contVer);
                String publishWorkspaceId = null;// for cuv - temp     
                ContentWorkSpace wsIdCUVPublishRec = [SELECT Id,Name 
                                                            FROM ContentWorkSpace 
                                                            WHERE Name LIKE '%CUV%' AND Name LIKE '%Certified%' ORDER BY CREATEDDATE DESC LIMIT 1];
                String wsIdCUVPublish = wsIdCUVPublishRec.Id;
                ContentWorkSpace wsIdCPOPublishRec = [SELECT Id,Name 
                                                            FROM ContentWorkSpace 
                                                            WHERE Name LIKE '%CPO%' AND Name LIKE '%Certified%' ORDER BY CREATEDDATE DESC LIMIT 1];
                String wsIdCPOPublish = wsIdCPOPublishRec.Id;
                if(contVer.CUVorCPO__c == 'CUV'){
                    publishWorkspaceId = wsIdCUVPublish;
                }else if(contVer.CUVorCPO__c == 'CPO'){
                    publishWorkspaceId = wsIdCPOPublish;
                }


                if(publishWorkspaceId != null){
                    List<ContentDocumentLink> cdlListInsert = new List<ContentDocumentLink>();
                    for (ContentDocument cd : [SELECT Id FROM ContentDocument 
                                                WHERE Id = :contVer.ContentDocumentId 
                                                LIMIT 1]) {
                        ContentDocumentLink cdl = new ContentDocumentLink(
                            ContentDocumentId = cd.Id,
                            LinkedEntityId = publishWorkspaceId, // ID of the new ContentWorkspace
                            ShareType = 'I'
                        );
                        cdlListInsert.add(cdl);
                    }
                    insert cdlListInsert;
                }
                if(publishWorkspaceId != null && contVer.PublishTargetFolderIdCUV__c != null && contVer.ContentDocumentId != null ){
                    contentDocumentIdstoPub.add( contVer.ContentDocumentId );
                    targetFolderIdsPub.add( contVer.PublishTargetFolderIdCUV__c );                    
                }

            }else if( contVer.Expiration_Date__c == Date.today()){
                                // WORKSPACEs FOR DELETE - do not care subfolder like recycle bin in Windows. 
                ContentWorkSpace wsIdCPOdeleteRec = [SELECT Id,Name 
                                                        FROM ContentWorkSpace 
                                                        WHERE Name LIKE '%CPO%' AND Name LIKE '%Deleted%' ORDER BY CREATEDDATE DESC LIMIT 1];
                String wsIdCPOdelete = wsIdCPOdeleteRec.Id;
                ContentWorkSpace wsIdCUVdeleteRec = [SELECT Id,Name 
                                                        FROM ContentWorkSpace 
                                                        WHERE Name LIKE '%CUV%' AND Name LIKE '%Deleted%' ORDER BY CREATEDDATE DESC LIMIT 1];  
                String wsIdCUVdelete = wsIdCUVdeleteRec.Id;

                String deleteWorkspaceId = null;// for cuv - temp
                String cvCUVCPOstr = contVer.CUVorCPO__c;
                if( cvCUVCPOstr == 'CUV'){
                    deleteWorkspaceId = wsIdCUVdelete;
                }else if( cvCUVCPOstr == 'CPO'){
                    deleteWorkspaceId = wsIdCPOdelete;
                }
                
                if(deleteWorkspaceId != null){
                    for (ContentDocument cd : [SELECT Id FROM ContentDocument 
                                                        WHERE Id = :contVer.ContentDocumentId 
                                                        LIMIT 1]) {
                        ContentDocumentLink cdl = new ContentDocumentLink(
                            ContentDocumentId = cd.Id,
                            LinkedEntityId = deleteWorkspaceId, // ID of the new ContentWorkspace
                            ShareType = 'I'
                        );
                        insert cdl;
                    }
                }                


            }
        }// END of loop for CUV Library job 
        if( ! contentDocumentIdstoPub.isEmpty() &&  ! targetFolderIdsPub.isEmpty()  ){
            HCUV_CORPlibraryQueueable.updateContentFolderMembersAsync( contentDocumentIdstoPub , targetFolderIdsPub );
            //** Note : must use this in one batch context if not, this exception will occur - System.LimitException: Too many queueable jobs added to the queue: 2 
        }// END OF queuable part for CUV Library job 



         /**
         * @description : Quip Document Issue
         * @author San, Kang : SanKang@autoeveramerica.com | 2023-10-19
         * @ticket no: SO-273
         */
        System.debug('CheckContentVersionQuip::'+ContentVersionUtil.CheckContentVersionQuip(newMapGeneric.values()));
        System.debug('UserName::'+ContentDocumentUtil.isAuthorizedUser(UserInfo.getUserId(), UserInfo.getProfileId()));
        if ((ContentVersionUtil.CheckContentVersionQuip(newMapGeneric.values()) || 
            (ContentDocumentUtil.isAuthorizedUser(UserInfo.getUserId(), UserInfo.getProfileId()) || !ContentVersionUtil.CheckCMTProfile(UserInfo.getProfileId())) || 
            (ContentVersionUtil.CheckCMTProfile(UserInfo.getProfileId()) && ContentVersionUtil.CheckCMTFileType(newMapGeneric.values())))) {
            system.debug('Authorized user');
            Set<Id> DADocumentIds = new Set<Id>();
            Set<Id> SIMSDocumentIds = new Set<Id>();
            Set<Id> SIMSDocIds = new Set<Id>();
            Set<String> contentSizeSIMS = new Set<String>();
            for (ContentVersion contentVersion : newMap.values()) {
                Id documentId = ContentDocumentUtil.getDocumentId(contentVersion);
                system.debug('document Id in loop'+documentId);
                SIMSDocIds.add(contentVersion.ContentDocumentId);
                if(documentId != null){
                    String documentType = documentId.getSobjectType().getDescribe().getName();
                    if (!String.isBlank(documentType) && documentType.equalsIgnoreCase('DADocuments__c')) {
                        DADocumentIds.add(documentId);
                    }
                    if (!String.isBlank(documentType) && documentType.equalsIgnoreCase('SIMS_Document__c')) {
                        SIMSDocumentIds.add(documentId);
                    }
                }
            }
            system.debug('Document Id is'+DADocumentIds);
            system.debug('SIMS Document Id is'+SIMSDocumentIds);
            List<Case> caseList = new List<Case>();
            List<Case> cse = [SELECT Id, FirstReportSource__c,Common_SEL_Report_Included__c FROM Case WHERE Id IN(SELECT Case__c FROM DADocuments__c where Folder__c='SIMS Common SEL Report' and CreatedById =:Label.IntegrationUserid and Id IN:DADocumentIds) and FirstReportSource__c='Shared KIA Common Issue' and Common_SEL_Report_Included__c= false];
            system.debug('Case List is'+cse);
            if(!cse.isEmpty()){
                system.debug('Inside if block');
                for(Case casee: cse){
                    casee.Common_SEL_Report_Included__c= true;
                    caseList.add(casee); 
                }
                    system.debug('Case List is'+caseList);
            }
            if(!caseList.isEmpty()){
                update caseList;
            }
            if(!SIMSDocumentIds.isEmpty()){ 
                List<ContentDocumentLink> VersionDataSIMS1 = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:SIMSDocumentIds];
                System.debug('VersionDataSIMS1::: ' + VersionDataSIMS1);
                system.debug('data is'+VersionDataSIMS1);
                Set<Id> versionSIMS1=new Set<Id>();
                for(ContentDocumentLink v1:VersionDataSIMS1) {
                    versionSIMS1.add(v1.ContentDocumentId);
                }
                system.debug('ContentDocumentID of SIMSDocument is'+versionSIMS1);

             
                // Added file size check
                List<ContentVersion> contSIMS1 = [SELECT Checksum FROM ContentVersion WHERE ContentDocumentId = :versionSIMS1 and ContentSize < 104857600];
                Set<String> contentSizeSIMS1 = new Set<String>();
                for(ContentVersion contv1 : contSIMS1){  contentSizeSIMS1.add(contv1.Checksum); }
                Set<Id> caseList1 = new Set<Id>();
                List<Case> cse1 = [SELECT Id FROM Case WHERE Id IN(SELECT Case__c FROM SIMS_Document__c where  CreatedById =:Label.IntegrationUserid and Id IN:SIMSDocumentIds)];
             
                system.debug('Case List1 is'+cse1);

                if(!cse1.isEmpty()){
                    for(Case casee1: cse1){
                        caseList1.add(casee1.Id); 
                    }
                    List<SIMS_Document__c> SIMSDocumentId = [select id from SIMS_Document__c where Case__c = :caseList1];
                    Set<Id> SIMSDocument=new Set<Id>();
                    for(SIMS_Document__c c:SIMSDocumentId) { SIMSDocument.add(c.id); } 
                    List<ContentDocument> contdoc = [SELECT Id FROM ContentDocument WHERE Id = :SIMSDocIds];

                    /** SIMSDocuments Start **/
                    if(!SIMSDocument.isEmpty()){
                        List<ContentDocumentLink> VersionDataSIMS = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:SIMSDocument and ContentDocumentId not in :SIMSDocIds];
                        system.debug('data is'+VersionDataSIMS);
                        Set<Id> versionSIMS=new Set<Id>();
                        for(ContentDocumentLink v:VersionDataSIMS) { versionSIMS.add(v.ContentDocumentId); }
                        system.debug('ContentDocumentID of SIMSDocument is'+versionSIMS);
                        // Added file size check
                        List<ContentVersion> contSIMS = [SELECT Checksum FROM ContentVersion WHERE ContentDocumentId = :versionSIMS  and ContentSize < 104857600];
                        //List<ContentDocument> contdoc = [SELECT Id FROM ContentDocument WHERE Id = :versionSIMS1];

                        for(ContentVersion contv : contSIMS){ contentSizeSIMS.add(contv.Checksum); }
                    }

                Boolean test = contentSizeSIMS.containsAll(contentSizeSIMS1);

                //Boolean test1 = SIMSDocument.containsAll(SIMSDocumentIds);

                if(test == true){ delete contdoc; }
            }

            //After INSERT METHODS END
            }
        }else{
            ContentVersionUtil.CheckNotFileType(newMapGeneric.values());
        }

        if(ContentVersionUtil.CheckCMTObj(newMapGeneric.values()) && ((ContentDocumentUtil.isAuthorizedUser(UserInfo.getUserId(), UserInfo.getProfileId()) || ContentVersionUtil.CheckCMTProfile(UserInfo.getProfileId())))){

            FileHistoryUtil.InsertContentVersion(newMapGeneric);
        }
    }// END - CONTENTVERSION AFTER INSERT

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric) {
        
        Map<Id, ContentVersion> oldMap = (Map<Id, ContentVersion>) oldMapGeneric;
        Map<Id, ContentVersion> newMap = (Map<Id, ContentVersion>) newMapGeneric;

        if(!run) { return; }
        // if(ContentVersionUtil.CheckCMTFileType(newMapGeneric.values())){
            System.debug('========================= before update : content version =========================');
            /**
             * date 03.23.23
             * Added by Semy Lee for SO-85 
             * Prevent file modification in cases that do not meet the conditions
             */
            List<ContentVersion> updateContVersinoList     = (List<ContentVersion>)newMapGeneric.values();
            Map<String, Boolean> fileAllowed = new Map<String, Boolean>();
            Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>();
            System.debug('=========================== cv/b.update : ' + updateContVersinoList);
            for(ContentVersion cv : updateContVersinoList) {
                System.debug('===================== cv FirstPublishLocationId : ' + cv.FirstPublishLocationId);
                if(cv.FirstPublishLocationId == null) {
                    if(cv.ContentDocumentId != null ) { cvMap.put(cv.ContentDocumentId, cv); }
                }
            }

            if(cvMap.size() > 0) {
                Set<Id> contentDocId = cvMap.keySet();
                List<ContentDocumentLink> conDocLink = [select LinkedEntity.Type, LinkedEntityId from contentDocumentLink where  ContentDocumentId IN: contentDocId];
                Map<Id, Map<String, Boolean>> checkAllowedFileVersionUpload = ContentDocumentUtil.checkDocAuthorByDocumentId(conDocLink);
                for(Id key : checkAllowedFileVersionUpload.keySet()) {
                    System.debug('1==== key : ' + key);
                    fileAllowed.putAll(checkAllowedFileVersionUpload.get(key));
                }

            } else {
                Map<Id, Map<String,Boolean>> DocAuthorByDocumentId = ContentDocumentUtil.checkDocAuthorByDocumentId(updateContVersinoList);
                for(Id key : DocAuthorByDocumentId.keySet()) {
                    System.debug('2==== key : ' + key);
                    fileAllowed.putAll(DocAuthorByDocumentId.get(key));
                }
            }

            Id profileId = UserInfo.getProfileId();
            String profileName =[Select Id, Name from Profile where Id=:profileId].Name; 
            Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
            Boolean hasDNACustomPermission = FeatureManagement.checkPermission('DNAMSNationalUser'); //DNA-696
            Boolean hasRRPAdminPermission = FeatureManagement.checkPermission('Safety_Assurance_Admin'); // RRP Project 2024-05-25 Oh, janghun
            
            for(ContentVersion contentVersion : updateContVersinoList) {
                if(!profileName.equalsIgnoreCase('Integration User') && !profileName.equalsIgnoreCase('System Administrator') && !hasCustomPermission && !hasDNACustomPermission && !hasRRPAdminPermission) {
                    System.debug('=== fileAllowed : ' + fileAllowed);

                    if(fileAllowed.size()>0){
                        if(fileAllowed.containsKey('DADocuments__c')){
                            // ADD SELECT LOGIC FOR 440 - FILE LOCK FOR Quality Case
                            // START SO-469 ADD logic for occasion - contentVersion.FirstPublishLocationId is null / 24.09.26 / Inho Kim
                            Id contDocId = contentVersion.ContentDocumentId != null ? contentVersion.ContentDocumentId : contentVersion.FirstPublishLocationId;
                            Id docId = contentVersion.FirstPublishLocationId; // Default to FirstPublishLocationId
                            // Retrieve LinkedEntityId if the LinkedEntity.Type is 'DADocuments__c'
                            for (ContentDocumentLink docLink : [SELECT LinkedEntityId,LinkedEntity.Type FROM ContentDocumentLink WHERE ContentDocumentId = :contDocId]) {
                                if (docLink.LinkedEntity.Type == 'DADocuments__c'){docId = docLink.LinkedEntityId; // Update docId to LinkedEntityId if found}                                
                            }}
                            // END SO-469 / 24.09.26 / Inho Kim
                            String qccTextVal =  [SELECT Case__r.QualityCaseConfirmed__c FROM DADocuments__c WHERE Id =:docId LIMIT 1].Case__r.QualityCaseConfirmed__c; 
                            if(!fileAllowed.get('DADocuments__c') && qccTextVal.equalsIgnoreCase('Yes')){
                                contentVersion.addError(Label.QC_Q_DA_Document_Error_Message, false);
                            }
                            else if(!fileAllowed.get('DADocuments__c') ){
                                contentVersion.addError(Label.DA_Document_Error_Message);
                            }
                        }
                        if(fileAllowed.containsKey('DRCDocument__c')){
                            if(!fileAllowed.get('DRCDocument__c')) contentVersion.addError(Label.DRC_Document_Error_Message); 
                        }
                        if(fileAllowed.containsKey('TRCDocument__c')){
                            if(!fileAllowed.get('TRCDocument__c')) contentVersion.addError(Label.TRC_Document_Error_Message);
                        }
                        if(fileAllowed.containsKey('NASDADocument__c')){
                            if(!fileAllowed.get('NASDADocument__c')) contentVersion.addError(Label.NASDA_Document_Error_Message);
                        }
                        //Added for DNA
                        if(fileAllowed.containsKey('Package__c')){
                            if(!fileAllowed.get('Package__c')) { contentVersion.addError(Label.PAC_Document_Error_Message); }
                        }
                        if(fileAllowed.containsKey('PackageElement__c')){
                            if(!fileAllowed.get('PackageElement__c')) { contentVersion.addError(Label.PAC_ELE_Content_Error_Message); }
                        }
                        if(fileAllowed.containsKey('PackageRequest__c')){
                            if(!fileAllowed.get('PackageRequest__c')) { contentVersion.addError(Label.DCR_Edit_Document_Error_Message); }
                        }
                        // <RRP Project> - Oh, janghun 2024-05-11 : Start
                        if(fileAllowed.containsKey('RRPDocument__c')){
                            if(!fileAllowed.get('RRPDocument__c')) contentVersion.addError(Label.RRP_Document_Error_Message); 
                        }
                        if(fileAllowed.containsKey('RRPValidationDocument__c')){
                            if(!fileAllowed.get('RRPValidationDocument__c')) contentVersion.addError(Label.RRPValidation_Document_Error_Message); 
                        }
                        if(fileAllowed.containsKey('ISEQCDocument__c')){
                            if(!fileAllowed.get('ISEQCDocument__c')) contentVersion.addError(Label.ISEQC_Document_Error_Message); 
                        }
                        // <RRP Project> - Oh, janghun 2024-05-11 : End
                        // <STIL Project> - San, Kang 2024-06-19 : Start
                        if(fileAllowed.containsKey('STIL_Lab_Request_Secure_Document__c')){
                            if(!fileAllowed.get('STIL_Lab_Request_Secure_Document__c')) contentVersion.addError(Label.STIL_Lab_Req_Secure_Error_Message); 
                        }
                        if(fileAllowed.containsKey('STIL_Report_Document__c')){
                            if(!fileAllowed.get('STIL_Report_Document__c')) contentVersion.addError(Label.STIL_Report_Document_Error_Message); 
                        }
                        if(fileAllowed.containsKey('STIL_Request_Document__c')){
                            if(!fileAllowed.get('STIL_Request_Document__c')) contentVersion.addError(Label.STIL_Request_Document_Error_Message); 
                        }
                        if(fileAllowed.containsKey('STIL_Test_Document__c')){
                            if(!fileAllowed.get('STIL_Test_Document__c')) contentVersion.addError(Label.STIL_Test_Document_Error_Message); 
                        }
                        // <STIL Project> - San, Kang 2024-06-19 : End
                        // <QCMT>[SO-440] / InhoKim / 2024-09-13 : START
                        if(fileAllowed.containsKey('Q_DRC_Document__c') ){
                            if(!fileAllowed.get('Q_DRC_Document__c')){
                                contentVersion.addError(Label.QC_Q_DRC_Document_Error_Message, false);
                            }
                        }
                        if(fileAllowed.containsKey('Q_TRC_Document__c') ){
                            if(!fileAllowed.get('Q_TRC_Document__c')){
                                contentVersion.addError(Label.QC_Q_TRC_Document_Error_Message, false);
                            }
                        }
                        if(fileAllowed.containsKey('SCDC_Document__c') ){
                            if(!fileAllowed.get('SCDC_Document__c')){
                                contentVersion.addError(Label.QC_SCDC_Document_Error_Message, false);
                            }
                        }
                        // <QCMT>[SO-440] / InhoKim / 2024-09-13 : END                        
                    }
                } 
                
            }
    }// END - CONTENTVERSION BEFORE UPDATE
    public override void afterUpdate(Map<Id,Sobject> oldMapGeneric, Map<Id,Sobject> newMapGeneric) {
        /**
         * date 08.21.23
         * Added by San,Kang for SO-230
         * CMT Create New Object - Document History
         */
        if(ContentVersionUtil.CheckCMTObj(newMapGeneric.values()) && ((ContentDocumentUtil.isAuthorizedUser(UserInfo.getUserId(), UserInfo.getProfileId()) || ContentVersionUtil.CheckCMTProfile(UserInfo.getProfileId())))){

            FileHistoryUtil.UpdateContentVersion(oldMapGeneric, newMapGeneric);
        }
    }// END - CONTENTVERSION AFTER UPDATE 

    

}