/**
************************************************************************************************
* @classname         : BatchProcessCUVcorpLibraryFilePublish
* @description       : Batch which runs by ContentVersion's Publish_Date__c
* @author            : Inho Kim
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       25th Jul 2024          Inho Kim             CCSOM-59        Initial Version
************************************************************************************************
**/
public with sharing class BatchProcessCUVcorpLibraryFilePublish implements Database.Batchable<sObject>{
        // Main Custom Fields related 
        //Publish_Date__c / Expiration_Date__c  //PublishTargetFolderStringCUV__c  //PublishTargetFolderIdCUV__c    
        public Database.QueryLocator start(Database.BatchableContext BC) {
            System.debug('BatchProcessCUVcorpLibraryFilePublish started.');
    
            String query = 'SELECT Id, CUVorCPO__c, ContentDocumentId, VersionData, Title, PathOnClient,PublishTargetFolderStringCUV__c, PublishTargetFolderIdCUV__c,Publish_Date__c,Expiration_Date__c FROM'+
                                ' ContentVersion WHERE IsLatest = TRUE AND Publish_Date__c = TODAY';//



            return Database.getQueryLocator(query);
        }        

        /*
        core logic description (only 2 of the 5 steps are done in the current batch class)
            1) [BATCH] Get a list of CVs that meet the conditions when executing the batch. Set work target case - scope 
            2) [TRIGGERHANDLER] Duplicate the record based on the existing CV and insert it. 
            3) [TRIGGERHANDLER] Create a new CV and associate the same CD with the new Workspace through CDL Insert. 
            4) [TRIGGERHANDLER] Modify the ParentFolderId of the ContentFolderMember through the Future method to move it to the subfolder set by the user.
            5) [BATCH] Batch delete CV records within the scope (via CD Delete, both CD and CDL are deleted, making them invisible to the user). 

        */
        public void execute(Database.BatchableContext BC, List<ContentVersion> scope) {

            try {
                System.debug('BATCH START  ' + scope.size() + ' records to go');
                Map<Id, String> documentIdToWorkspaceMap = new Map<Id, String>();
                String wsIdCPOPublish = '058cY0000000nAPQAY';
                String wsIdCUVpublish = '058cY0000002GS5QAM';
                List<ContentVersion> cpoContentVersions = new List<ContentVersion>();
                List<ContentVersion> cuvContentVersions = new List<ContentVersion>();
                List<ContentVersion> publishContentVersions = new List<ContentVersion>();
                Set<Id> oldContentDocumentIds = new Set<Id>();  
                for (ContentVersion cv : scope) {                   
                    List<String> rootWsNameOneList = HCUV_FileUtility.getRootWorkspaceName(new List<Id>{cv.ContentDocumentId});
                    String rootWsName = rootWsNameOneList.isEmpty() ? '' : rootWsNameOneList[0];
                    System.debug(rootWsName);
                    // Did not confirm if they are a CUV/CPO user.
                    //When there is a Publish_date or Expiration date value corresponding to CUV/CPO, CUVorCPO__c is created by the screen flow that inputs that value.
                    String cuvcpoValue = rootWsName.containsIgnoreCase('CUV') ? 'CUV'  :   rootWsName.containsIgnoreCase('CPO')  ? 'CPO'  : null;                     
                    if(cuvcpoValue != null){
                        ContentVersion newCV = new ContentVersion(
                            ContentDocumentId = null,
                            ContentLocation = 'S',
                            VersionData = cv.VersionData,
                            Title = cv.Title,
                            PathOnClient = cv.PathOnClient,
                            Publish_Date__c = cv.Publish_Date__c,
                            Expiration_Date__c = cv.Expiration_Date__c, 
                            PublishTargetFolderStringCUV__c = cv.PublishTargetFolderStringCUV__c ,
                            PublishTargetFolderIdCUV__c = cv.PublishTargetFolderIdCUV__c,
                            CUVorCPO__c =  cuvcpoValue
                        );
                        publishContentVersions.add(newCV); 
                    }                    
                    oldContentDocumentIds.add(cv.ContentDocumentId);
                }// Loop over for scope CVs 


                System.debug('Trigger START soon by Insert  ' + oldContentDocumentIds.size() + ' records to go');                
                insert publishContentVersions; 

                //5 Delete the old ContentDocuments
                System.debug('TO DELETE in PublishBatch - Records to go :' +  [SELECT Id FROM ContentDocument WHERE Id IN :oldContentDocumentIds].size() );
                if([SELECT Id FROM ContentDocument WHERE Id IN :oldContentDocumentIds].size() > 0){
                delete [SELECT Id FROM ContentDocument WHERE Id IN :oldContentDocumentIds];
                }
            } catch (Exception e) {
                System.debug(e);return;
            }

            }

        public void finish(Database.BatchableContext BC) {
            System.debug('BatchProcessCUVcorpLibraryFilePublish finished.');
        }
    }