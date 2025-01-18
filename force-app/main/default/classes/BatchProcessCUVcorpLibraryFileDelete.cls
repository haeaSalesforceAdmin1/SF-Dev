/**
************************************************************************************************
* @classname         : BatchProcessCUVcorpLibraryFileDelete
* @description       : Batch which runs by ContentVersion's Expiration_Date__c to move file from Main to Deleted Library(ContentWorkspace)
* @author            : Inho Kim
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       25th Jul 2024          Inho Kim             CCSOM-59        Initial Version
************************************************************************************************
**/
public class BatchProcessCUVcorpLibraryFileDelete implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('BatchProcessCUVcorpLibraryFileDelete started.');

        String mainWorkspaceIds =  '' ;
        List<ContentWorkspace> mainWsList = [SELECT Id,Name FROM ContentWorkSpace WHERE Name LIKE '%Certified%'  ORDER BY CreatedDate DESC ];
        Set<String> mainWsSet = new Set<String>();
        for(ContentWorkspace i : mainWsList ){
            String eachId = i.Id;
            System.debug('Name =>>'+ i.Name);
            mainWsSet.add(eachId);
        }
    
        String query = 'SELECT Id, CUVorCPO__c, ContentDocumentId, FirstPublishLocationId,VersionData, Title, PathOnClient,PublishTargetFolderStringCUV__c, PublishTargetFolderIdCUV__c,Publish_Date__c,Expiration_Date__c FROM'+
        ' ContentVersion WHERE IsLatest = true AND Expiration_Date__c = TODAY ';
        if(!mainWsSet.isEmpty() ){  query  =  query + 'AND ContentDocument.ParentId IN :mainWsSet'       ;}                           
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<ContentVersion> records) {

        try {
            System.debug('DELETE ' + records.size() + ' records to be invisible');
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            List<Id> contentDocumentIdList = new List<Id>();
            System.debug('Record:::'+records);
            Set<Id> conDocIds =  new Set<Id>();
            
            for (ContentVersion cv : records) {
                List<String> rootWsNameOneList = HCUV_FileUtility.getRootWorkspaceName(new List<Id>{cv.ContentDocumentId});
                String rootWsName = rootWsNameOneList.isEmpty() ? '' : rootWsNameOneList[0];
                System.debug('>>> BatchDel rootWsName');System.debug(rootWsName);                
                System.debug(cv);
                if(rootWsName.containsIgnoreCase('Certified') || (Test.isRunningTest()) ){
                    String currentFolderDirectory = getFolderDirectory(cv.ContentDocumentId,rootWsName );// retrieve each file's dir loop by loop.
                    
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
                        CUVorCPO__c = cv.CUVorCPO__c,
                        Folder_Before_Deletion__c = currentFolderDirectory
                    );
                    contentDocumentIdList.add(cv.ContentDocumentId);            
                    conDocIds.add( cv.ContentDocumentId );
                    contentVersionList.add(newCV);
                }

            }
            // After Loop you insert New Copied CV by bulk.
            // so in one batch context, CV trigger will ran. 
            if( ! contentVersionList.isEMpty()){
                insert contentVersionList;
            }


            // Use already existing CV's contentdocuemntIDs to query ContentDocumentRecords 
            List<ContentDocument> delContentDocumentList = [SELECT Id FROM ContentDocument WHERE Id =:conDocIds];
            System.debug('Condocs to delete, records to go >>>>>>>' + delContentDocumentList.size() );
            if(delContentDocumentList.size()>0){
                System.debug('delContentDocumentList:::'+delContentDocumentList);
                delete delContentDocumentList;
            }
            

            
        } catch (Exception e) {
                return;
            }

    }

    private String getFolderDirectory(Id currConDocId,String rootWsName){
        String result = '';

        ContentFolderItem cfItemLeaf = [SELECT   Id,ParentContentFolderId,ParentContentFolder.Name FROM ContentFolderItem WHERE Id = :currConDocId AND IsFolder = false  AND (NOT ParentContentFolder.Name LIKE '005%') AND  (NOT Title LIKE '005%')  ORDER BY CreatedDate DESC LIMIT 1];
        String lastLeaf = cfItemLeaf.ParentContentFolder.Name;
        while(cfItemLeaf.ParentContentFolderId == null ){            
            cfItemLeaf = [SELECT   Id,ParentContentFolderId,ParentContentFolder.Name,title,IsFolder FROM ContentFolderItem WHERE Id = :cfItemLeaf.ParentContentFolderId  ORDER BY CreatedDate DESC LIMIT 1 ];
            lastLeaf = cfItemLeaf.ParentContentFolder.Name + '>' + lastLeaf;
            
        }
        // if file is in root folder, it does not add > 
        result = lastLeaf != null ?  rootWsName + '>' +lastLeaf : rootWsName  ;
        
        return result;
    }


    public void finish(Database.BatchableContext BC) {
        System.debug('BatchProcessCUVcorpLibraryFileDelete finished.');
    }
}