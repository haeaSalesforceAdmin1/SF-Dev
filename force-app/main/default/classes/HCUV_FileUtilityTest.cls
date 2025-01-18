@isTest
public class HCUV_FileUtilityTest {

    @TestSetup
    static void createData() {
        System.debug('======USER INFO');
        System.debug(UserInfo.getUserId());
        System.debug(UserInfo.getProfileId());
        ContentWorkspace testWorkspace_cpopre = new ContentWorkspace(Name='CPO Pre', DeveloperName='CPO_Pre');
        insert testWorkspace_cpopre;
        ContentWorkspace testWorkspace_cpocertified = new ContentWorkspace(Name='CPO Certified', DeveloperName='CPO_Certified');
        insert testWorkspace_cpocertified;
        ContentWorkspace testWorkspace_cpodeleted = new ContentWorkspace(Name='CPO Deleted', DeveloperName='CPO_Deleted');
        insert testWorkspace_cpodeleted;
    }

    @IsTest static void BatchProcessCUVcorpLibraryFilePublish() {



        Test.startTest();     
        ContentWorkspace cwTargetWsFolder = [Select Id,Name from ContentWorkspace WHERE Name LIKE '%CPO%' AND Name = 'CPO Pre' LIMIT 1];
        ContentWorkspace mainContWorkspace = [Select Id,Name from ContentWorkspace WHERE Name LIKE '%CPO%' AND Name = 'CPO Certified' LIMIT 1];
        System.debug('cwTargetWsFolder------------');
        System.debug(cwTargetWsFolder); //ContentWorkspace:{Id=058cY0000002GS5QAM, Name=[CPO GMA] Certified Pre-Owned Library} 
        // not a CW i created in TestSetup.. 
        List<ContentVersion> cvObjList_main = new List<ContentVersion>();        
        for(Integer i=0;i<1;i++) {
            ContentVersion cvObj = new ContentVersion();
            cvObj.Title = 'Test FilePub' + i;
            cvObj.PathOnClient = 'TestFilePub' + i + '.pdf';
            cvObj.VersionData = Blob.valueOf('Test Content');
            //cvObj.IsMajorVersion = true;
            cvObj.Publish_Date__c = Date.today();
            cvObj.CUVorCPO__c = 'CPO';
            cvObj.FirstPublishLocationId  = cwTargetWsFolder.Id;
            cvObjList_main.add(cvObj);
        }
        Database.SaveResult[] srList = Database.insert(cvObjList_main);
        Id contVerId;
        ContentVersion cvInserted;
        ContentDocument contentDocInserted;
        for( Database.SaveResult sr : srList ){
            System.debug('sr.getId()');
            System.debug(sr.getId());
            contVerId = sr.getId();
            cvInserted = [SELECT Id, ContentDocumentId,FirstPublishLocationId, RecordTypeId, IsLatest, ContentUrl, ContentBodyId, VersionNumber, Title, Description, SharingOption, SharingPrivacy, PathOnClient,OwnerId,  FileType, PublishStatus, VersionData, ContentSize, FileExtension,  Origin, NetworkId, ContentLocation,Expiration_Date__c, Publish_Date__c, PublishTargetFolderStringCUV__c, Folder_Before_Deletion__c, PublishTargetFolderIdCUV__c, CUVorCPO__c FROM ContentVersion WHERE Id = :contVerId LIMIT 1 ];
            System.debug('cvInserted Record ============');
            System.debug(cvInserted); 
            contentDocInserted = [SELECT Id FROM ContentDocument WHERE Id = :cvInserted.ContentDocumentId];
            System.debug('contentDocInserted Record ============');
            System.debug(cvInserted); 
        }

        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument]; 
        List<ContentDocumentLink> cdlListInsert = new List<ContentDocumentLink>();         
        Id firstContDocId ;
        if( ! [Select Id,Name from ContentWorkspace WHERE Name LIKE '%CPO%' AND Name LIKE '%Deleted%' LIMIT 1].isEmpty()){
            Integer temp_num = 0;
            for (ContentDocument cd : conDocList ) {
                temp_num++;
                List<ContentFolderMember> conFolMemTest = [SELECT   Id, ParentContentFolderId, ChildRecordId, IsDeleted,  CreatedById, CreatedDate FROM ContentFolderMember WHERE ChildRecordId = :cd.Id LIMIT 10];
                System.debug('conFolMemTest >>> each ');
                System.debug('conFolMemTest >>> size '+conFolMemTest.size());
            }
            //insert cdlListInsert;//  insert before 

            firstContDocId = [SELECT Id FROM ContentDocument Limit 1 ][0].Id;            
        }
        executeAdditionalUpdates(cwTargetWsFolder.Id,  mainContWorkspace.Id );
   
        System.debug('======USER INFO');
        System.debug(UserInfo.getUserId());
        System.debug(UserInfo.getProfileId());
        System.debug('First ===============START TEST');
        List<ContentFolderMember> folderMemberTestFinal = [SELECT   Id, ParentContentFolderId, ChildRecordId, IsDeleted,  CreatedById, CreatedDate FROM ContentFolderMember WHERE ChildRecordId = :firstContDocId LIMIT 10];
        System.debug('GetMemberFianl'+ folderMemberTestFinal.size());
        System.debug(folderMemberTestFinal);


        HCUV_FileUtility.getResultForCUVCORPLib(contentDocInserted.Id);


        HCUV_FileUtility.getRootWorkspaceName(new List<Id>{contentDocInserted.Id}); 


/*
        if( ! contentDocumentIdstoPub.isEmpty() &&  ! targetFolderIdsPub.isEmpty()  ){
            HCUV_CORPlibraryQueueable.updateContentFolderMembersAsync( contentDocumentIdstoPub , targetFolderIdsPub );
*/


        Test.stopTest();

    }

    public static void executeAdditionalUpdates(Id wsId, Id targetId ){
        ContentFolder wsContFolder = [Select Id from ContentFolder where Name =:wsId LIMIT 1 ];
        ContentFolder wsContTargetFolder = [Select Id from ContentFolder where Name =:targetId LIMIT 1 ];
        // ContentFolder wsContTargetFolder = [Select Id from ContentFolder where Name =:targetId LIMIT 1 ];

        /// FOR PRE
        ContentFolder cf4Pre = new ContentFolder();
        cf4Pre.Name = 'TestFolderPre';
        cf4Pre.ParentContentFolderId = wsContFolder.Id;
        Database.SaveResult srPre = Database.insert(cf4Pre);
        Id preFolderId = srPre.getId();
        System.debug(srPre.getId()); 
        System.debug(preFolderId);         
        ContentFolder cf4Main = new ContentFolder();
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        List<ContentFolderMember> folderMembers = new List<ContentFolderMember>();
        for(ContentFolderMember cfm : [Select Id, ChildRecordId, ParentContentFolderId
                                       from ContentFolderMember
                                       where ParentContentFolderId =: wsContFolder.Id]) {
            cfm.ParentContentFolderId = preFolderId;
            folderMembers.add(cfm);
        }    
        update folderMembers;


        //// FOR MAIN 
        cf4Main.Name = 'TestFolderMain';
        cf4Main.ParentContentFolderId = wsContTargetFolder.Id;
        Database.SaveResult srMain = Database.insert(cf4Main);
        Id mainFolderId = srMain.getId();
        System.debug(srMain.getId()); 
        System.debug(mainFolderId); 
        // insert cf2;
        System.debug('********After insert ContentFolder>> cf2');
        // System.debug(cf2);


        ContentVersion cvToUpdate = [SELECT Id,ContentDocumentId,PublishTargetFolderIdCUV__c FROM ContentVersion WHERE Title Like '%Test FilePub%' ORDER BY Title DESC LIMIT 1 ];
        cvToUpdate.PublishTargetFolderIdCUV__c = mainFolderId;
        update cvToUpdate;



        // Utility Method Test 
        String contDocIdStr = cvToUpdate.ContentDocumentId;
        HCUV_FileUtility.getResultForCUVCORPLib( contDocIdStr );


    }

}