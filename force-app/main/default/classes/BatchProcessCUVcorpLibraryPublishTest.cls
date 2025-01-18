/**
************************************************************************************************
* @classname         : BatchProcessCUVcorpLibraryPublishTest
* @description       : Testclass -  to test BatchProcessCUVcorpLibraryFilePublish class
* @author            : Inho Kim
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       25th Jul 2024          Inho Kim             CCSOM-59        Initial Version
************************************************************************************************
**/
@isTest
public class BatchProcessCUVcorpLibraryPublishTest {

    /*
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
        */
        @IsTest(SeeAllData=true)
        static void registerCurrUserAsCWAdmin() {
    
    
    
    
            // Can query all data in the organization.      
            Id contWSPermissionId =  [SELECT Id FROM ContentWorkspacePermission WHERE Type ='Admin'].Id;
            Id currUserId = UserInfo.getUserId();
            User cuvSysadminUser = [SELECT Id, Profile.Name FROM User WHERE Name LIKE 'CUV/CPO%']; 
            System.runAs(cuvSysadminUser) {
                List<ContentWorkspace> contWsList = [SELECT Id,Name FROM ContentWorkspace WHERE Name LIKE '%CPO%'] ?? null;
                String wsSearchId = contWsList == null ?  '' : contWsList[0].Id;        
                System.debug('wsSearchId=====  ' + wsSearchId ); 
                if( [SELECT Id FROM ContentWorkSpaceMember WHERE ContentWorkspaceId = :wsSearchId AND MemberId =:currUserId].size() == 0 ){
    
            //2안
            //  List<ContentWorkspace> contWsList = [Select Id,Name from ContentWorkspace WHERE Name LIKE '%CUV%'];
            //  String wsSearchId = contWsList.size() == 0 ? '' : contWsList[0].Id;
            //  if(String.isBlank(wsSearchId)){
                
                    for(ContentWorkspace i : contWsList){
                        System.debug('EACH LOOP =====  '  ); 
                        System.debug('contWsList LOOP =====  ' + i  ); 
                        ContentWorkspaceMember workspaceMember = new ContentWorkspaceMember(
                            ContentWorkspaceId = i.Id,MemberId = currUserId,ContentWorkspacePermissionId = contWSPermissionId
                        );   
                        System.debug('workspaceMember LOOP =====  ' + workspaceMember  );     
                        insert workspaceMember;       
                    }     
                }
            }
        }



        @IsTest(SeeAllData=true)
        static void BatchProcessCUVcorpLibraryFilePublish() {

        
        registerCurrUserAsCWAdmin();// works good when it is before Test.startTest();
        Test.startTest();     
        User cuvSysadminUser = [SELECT Id, Profile.Name FROM User WHERE Name LIKE 'CUV/CPO%']; 
        ContentWorkspace cwTargetWsFolder;
        ContentWorkspace mainContWorkspace;
        System.runAs(cuvSysadminUser) {
            cwTargetWsFolder = [Select Id,Name from ContentWorkspace WHERE Name LIKE '%CPO%' AND Name LIKE '%Pre-Published%' LIMIT 1];
            mainContWorkspace = [Select Id,Name from ContentWorkspace WHERE Name LIKE '%CPO%' AND Name LIKE '%Library%' LIMIT 1];
        }
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
            System.debug('cvObj >>>>>>>>>>>'+cvObj);
            System.debug('cvObj.Publish_Date__c > '+ cvObj.Publish_Date__c);
            cvObjList_main.add(cvObj);
        }
        Database.SaveResult[] srList;
        System.runAs(cuvSysadminUser) {        
            srList = Database.insert(cvObjList_main);
            System.debug('inserted Result> '+  srList);
        }
        Id contVerId;
        ContentVersion cvInserted;
        for( Database.SaveResult sr : srList ){
            System.debug('sr.getId()');
            System.debug(sr.getId());
            contVerId = sr.getId();
            System.runAs(cuvSysadminUser) { 
                cvInserted = [SELECT Id, ContentDocumentId,FirstPublishLocationId, RecordTypeId, IsLatest, ContentUrl, ContentBodyId, VersionNumber, Title, Description, SharingOption, SharingPrivacy, PathOnClient,OwnerId,  FileType, PublishStatus, VersionData, ContentSize, FileExtension,  Origin, NetworkId, ContentLocation,Expiration_Date__c, Publish_Date__c, PublishTargetFolderStringCUV__c, Folder_Before_Deletion__c, PublishTargetFolderIdCUV__c, CUVorCPO__c FROM ContentVersion WHERE Id = :contVerId LIMIT 1 ];
            }
                System.debug('cvInserted Record ============');
            System.debug(cvInserted); 
            ContentDocument contentDocInserted = [SELECT Id FROM ContentDocument WHERE Id = :cvInserted.ContentDocumentId];
            System.debug('contentDocInserted Record ============');
            System.debug(cvInserted); 
        }

        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument ORDER BY CreatedDate DESC LIMIT 5]; 
        List<ContentDocumentLink> cdlListInsert = new List<ContentDocumentLink>();         
        Id firstContDocId ;
        List<ContentWorkspace> forCheckingCWList;
        System.runAs(cuvSysadminUser) {        
            forCheckingCWList =[Select Id,Name from ContentWorkspace WHERE Name LIKE '%CPO%' AND Name LIKE '%Deleted%' LIMIT 1];
        }
        if( ! forCheckingCWList.isEmpty()){
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
        BatchProcessCUVcorpLibraryFilePublish batch = new BatchProcessCUVcorpLibraryFilePublish();
        Id jobId =  Database.executeBatch(batch);
        System.debug(jobid);



        Test.stopTest();// moved  after runBatch because of error - |FATAL_ERROR|System.FinalException: Method only allowed during testing 

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