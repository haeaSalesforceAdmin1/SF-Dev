/**
************************************************************************************************
* @classname         : BatchProcessCUVcorpLibraryFileDeleteTest
* @description       : Testclass -  to test BatchProcessCUVcorpLibraryFileDelete class
* @author            : Inho Kim
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       25th Jul 2024          Inho Kim             CCSOM-59        Initial Version
************************************************************************************************
**/
@IsTest
public class BatchProcessCUVcorpLibraryFileDeleteTest {


    /*
     * @TestSetup
    static void createData() {
        System.debug('======USER INFO'+ UserInfo.getUserId());
        System.debug(UserInfo.getProfileId());
		ContentWorkspacePermission  newCWpermission = new ContentWorkspacePermission(
            Name = 'Library Administrator TEST',    PermissionsManageWorkspace =true,    PermissionsAddContent =false,    PermissionsAddContentOBO =false,    PermissionsArchiveContent=true,
            PermissionsFeatureContent=false,    PermissionsViewComments=false,    PermissionsAddComment=false,    PermissionsModifyComments=false,    PermissionsTagContent=false,    PermissionsDeliverContent=true,
            PermissionsChatterSharing=false,    PermissionsOrganizeFileAndFolder=true
        );
        insert newCWpermission;         



        ContentWorkspace testWorkspace_cuvpre = new ContentWorkspace(Name='CUV Pre', DeveloperName='CUV_Pre');
        insert testWorkspace_cuvpre;
        ContentWorkspaceMember workspaceMember1 = new ContentWorkspaceMember(
            ContentWorkspaceId = testWorkspace_cuvpre.Id,MemberId = UserInfo.getUserId(),ContentWorkspacePermissionId = newCWpermission.Id
        );        insert workspaceMember1;        
        ContentWorkspace testWorkspace_cuvcertified = new ContentWorkspace(Name='CUV Certified', DeveloperName='CUV_Certified');
        insert testWorkspace_cuvcertified;
        ContentWorkspaceMember workspaceMember2 = new ContentWorkspaceMember(
            ContentWorkspaceId = testWorkspace_cuvcertified.Id,MemberId = UserInfo.getUserId(),ContentWorkspacePermissionId = newCWpermission.Id
        );        insert workspaceMember2;         
        ContentWorkspace testWorkspace_cuvdeleted = new ContentWorkspace(Name='CUV Deleted', DeveloperName='CUV_Deleted');
        insert testWorkspace_cuvdeleted;
        ContentWorkspaceMember workspaceMember3 = new ContentWorkspaceMember(
            ContentWorkspaceId = testWorkspace_cuvdeleted.Id,MemberId = UserInfo.getUserId(),ContentWorkspacePermissionId = newCWpermission.Id
        );        insert workspaceMember3;     
    }
	*/
    
    // Test method that has access to all data.
    @IsTest(SeeAllData=true)
    static void registerCurrUserAsCWAdmin() {

        // Can query all data in the organization.      
        Id contWSPermissionId =  [SELECT Id FROM ContentWorkspacePermission WHERE Type ='Admin'].Id;
        Id currUserId = UserInfo.getUserId();
        User cuvSysadminUser = [SELECT Id, Profile.Name FROM User WHERE Name LIKE 'CUV/CPO%']; 
        System.runAs(cuvSysadminUser) {
            List<ContentWorkspace> contWsList = [SELECT Id,Name FROM ContentWorkspace WHERE Name LIKE '%CUV%'] ?? null;
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
     static void BatchProcessCUVcorpLibraryFileDelete() {


        registerCurrUserAsCWAdmin();// works good when it is before Test.startTest();
        Test.startTest();  
                
        System.debug('======USER INFO'+ UserInfo.getUserId());
        System.debug(UserInfo.getProfileId());
        List<ContentWorkspace> contWs = [Select Id,Name from ContentWorkspace LIMIT 5];
        System.debug('contWs------------');// why this can see all real-existing CW datas? 
        System.debug(contWs);
        // NEW PERMISSION TO LIBRARY 
       /*
        *  ContentWorkspacePermission  newCWpermission = new ContentWorkspacePermission(
            Name = 'Library Administrator TEST',    PermissionsManageWorkspace =true,    PermissionsAddContent =false,    PermissionsAddContentOBO =false,    PermissionsArchiveContent=true,
            PermissionsFeatureContent=false,    PermissionsViewComments=false,    PermissionsAddComment=false,    PermissionsModifyComments=false,    PermissionsTagContent=false,    PermissionsDeliverContent=true,
            PermissionsChatterSharing=false,    PermissionsOrganizeFileAndFolder=true
        );
        insert newCWpermission; 
		*/
		// ContentWorkspace testWorkspace_cuvcertified = new ContentWorkspace(Name='CUV Certified', DeveloperName='CUV_Certified');
        // insert testWorkspace_cuvcertified;        
        ContentWorkspace cwTargetWsFolder;
        User cuvSysadminUser = [SELECT Id, Profile.Name FROM User WHERE Name LIKE 'CUV/CPO%']; 
        System.runAs(cuvSysadminUser) {
            // before Seealldata true
            //cwTargetWsFolder = [Select Id,Name from ContentWorkspace WHERE Name LIKE '%CUV%' AND Name = 'CUV Certified' ORDER BY CREATEDDATE DESC LIMIT 1];
             
            cwTargetWsFolder = [Select Id,Name from ContentWorkspace WHERE Name LIKE '%CUV%' AND Name LIKE '%Certified%' AND Name LIKE '%Library%' ORDER BY CREATEDDATE DESC LIMIT 1];
        }
        System.debug ('cwTargetWsFolder');
        System.debug(cwTargetWsFolder);
        // not a CW i created in TestSetup.. 
        List<ContentVersion> cvObjList_main = new List<ContentVersion>();        
        for(Integer i=0;i<5;i++) {
            ContentVersion cvObj = new ContentVersion();
            cvObj.Title = 'Test Document' + i;
            cvObj.PathOnClient = 'TestDocument' + i + '.pdf';
            cvObj.VersionData = Blob.valueOf('Test Content');
            //cvObj.IsMajorVersion = true;
            cvObj.Expiration_Date__c = Date.today();
            cvObj.CUVorCPO__c = 'CUV';
            cvObj.FirstPublishLocationId  = cwTargetWsFolder.Id;
            cvObjList_main.add(cvObj);            
        }
        Database.SaveResult[] srList;
        System.runAs(cuvSysadminUser) {
            srList = Database.insert(cvObjList_main);
        }
        Id contVerId;
        ContentVersion cvInserted;
        Integer tmpNum = 1;
        for( Database.SaveResult sr : srList ){
            System.debug('sr.getId()');
            System.debug(sr.getId());
            contVerId = sr.getId();
            cvInserted = [SELECT Id, ContentDocumentId,FirstPublishLocationId, RecordTypeId, IsLatest, ContentUrl, ContentBodyId, VersionNumber, Title, Description, SharingOption, SharingPrivacy, PathOnClient,OwnerId,  FileType, PublishStatus, VersionData, ContentSize, FileExtension,  Origin, NetworkId, ContentLocation,Expiration_Date__c, Publish_Date__c, PublishTargetFolderStringCUV__c, Folder_Before_Deletion__c, PublishTargetFolderIdCUV__c, CUVorCPO__c FROM ContentVersion WHERE Id = :contVerId LIMIT 1 ];
            System.debug('cvInserted Record ============');
            System.debug(cvInserted); 
            ContentDocument contentDocInserted = [SELECT Id FROM ContentDocument WHERE Id = :cvInserted.ContentDocumentId];
            System.debug('contentDocInserted Record ============');
            System.debug(cvInserted); 

            createContentFolderConnection(cwTargetWsFolder.Id,  cvInserted.ContentDocumentId , tmpNum++);
            
        }



        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument ORDER BY CreatedDate DESC LIMIT 5]; 
        System.debug('>>>>>6   conDocList ');
        System.debug(conDocList); 
        List<ContentDocumentLink> cdlListInsert = new List<ContentDocumentLink>(); 

        
        Id firstContDocId ;
        if( ! [Select Id,Name from ContentWorkspace WHERE Name LIKE '%CUV%' AND Name LIKE '%Deleted%' LIMIT 1].isEmpty()){
            Integer temp_num = 0;
            for (ContentDocument cd : conDocList ) {
                temp_num++;
                List<ContentFolderMember> conFolMemTest = [SELECT   Id, ParentContentFolderId, ChildRecordId, IsDeleted,  CreatedById, CreatedDate FROM ContentFolderMember WHERE ChildRecordId = :cd.Id LIMIT 10];

                System.debug('conFolMemTest >>> each ');
                System.debug(conFolMemTest);
                System.debug('conFolMemTest >>> size '+conFolMemTest.size());
            }//insert cdlListInsert;//  insert before 

            firstContDocId = [SELECT Id FROM ContentDocument Limit 1 ][0].Id;
            
        }
        createContDocLink(cwTargetWsFolder.Id);
        System.debug('======USER INFO'+ UserInfo.getUserId());
        System.debug(UserInfo.getProfileId());
        System.debug('First ===============START TEST');
        List<ContentFolderMember> folderMemberTestFinal = [SELECT   Id, ParentContentFolderId, ChildRecordId, IsDeleted,  CreatedById, CreatedDate FROM ContentFolderMember WHERE ChildRecordId = :firstContDocId LIMIT 10];
        System.debug('GetMemberFianl'+ folderMemberTestFinal.size());
        System.debug(folderMemberTestFinal);
        // run Batch last of Future
        // runBatch();  System.AsyncException: Database.executeBatch cannot be called from a batch start, batch execute, or future method

        BatchProcessCUVcorpLibraryFileDelete batch = new BatchProcessCUVcorpLibraryFileDelete();
        Id jobId =  Database.executeBatch(batch);
        System.debug(jobid);
        Test.stopTest();// moved  after runBatch because of error - |FATAL_ERROR|System.FinalException: Method only allowed during testing 

    }



    public static void createContDocLink(Id wsId){
        System.debug(wsId+ ' >>> createContDocLink ');
        ContentFolder workspaceFolder = [Select Id from ContentFolder where Name =:wsId LIMIT 1 ];
        System.debug('workspaceFolder In CreateContDocLink');
        System.debug(workspaceFolder);
        ContentFolder cf2 = new ContentFolder();
        cf2.Name = 'TestFolder9999999';
        cf2.ParentContentFolderId = workspaceFolder.Id;
        Database.SaveResult sr = Database.insert(cf2);
        System.debug('********After insert ContentFolder>> cf2');
        System.debug(sr);
        Id testFolderId = sr.getId();
        System.debug(sr.getId()); 
        System.debug(testFolderId); 
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        List<ContentFolderMember> folderMembers = new List<ContentFolderMember>();  
        for(ContentFolderMember cfm : [Select Id, ChildRecordId, ParentContentFolderId
                                       from ContentFolderMember
                                       where ParentContentFolderId =: workspaceFolder.Id]) {
            cfm.ParentContentFolderId = testFolderId;
            folderMembers.add(cfm);
        }    
        update folderMembers;
    }



    /**
     * this method to be invoked 5 times 
     */
    //@future
    
    public static void createContentFolderConnection(Id cwId, Id firstContDocId, Integer temp_num){

        ContentWorkspace testWorkspace;
        User cuvSysadminUser = [SELECT Id, Profile.Name FROM User WHERE Name LIKE 'CUV/CPO%']; 
        System.runAs(cuvSysadminUser) {
            testWorkspace= [select Id, RootContentFolderId from ContentWorkspace where Id=:cwId];
        }// #trial_05

        String folderName = 'Test Folder' + String.valueOf(temp_num);
        //get library by  Id - cwId
        //Get library as folder
        ContentFolder cf1 = [SELECT Id,Name FROM ContentFolder WHERE Name =:cwId];
        //Create test folder in test library
        ContentFolder cf2 = new ContentFolder();
        cf2.Name = 'TestFolder9999999'+ String.valueOf(temp_num);
        cf2.ParentContentFolderId = cf1.Id;
        insert cf2;
        System.debug('********After insert ContentFolder>> cf2');
        System.debug(cf2);
        Id contItemId = null;
        System.debug('firstContDocId  >> '+ firstContDocId); 
        List<ContentFolderItem> contFolderItem = [SELECT   Id,ParentContentFolderId,title,IsFolder FROM ContentFolderItem 
                                                                 WHERE Id = :firstContDocId AND IsFolder = false 
                                                                 AND (NOT ParentContentFolder.Name LIKE '005%') AND  (NOT Title LIKE '005%') LIMIT 1];
        System.debug('contFolderItem >>> each ');
        System.debug(contFolderItem);
        if( ! contFolderItem.isEMpty()){
            contItemId =  contFolderItem[0].ParentContentFolderId;
        }

        List<ContentFolderItem> contFolderItemTEST = [SELECT   Id,ParentContentFolderId,title,IsFolder FROM ContentFolderItem WHERE ParentContentFolderId  = :cf1.Id LIMIT 10];
        System.debug('contFolderItem >>> each ');
        System.debug(contFolderItemTEST);        
        List<ContentDocumentLink> conDocLinkTest = [SELECT  Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility    FROM ContentDocumentLink  WHERE ContentDocumentId = :firstContDocId LIMIT 10];
        System.debug('conDocLinkTest >>> each ');
        System.debug(conDocLinkTest);
        List<ContentFolderMember> conFolMemTest = [SELECT   Id, ParentContentFolderId, ChildRecordId, IsDeleted,  CreatedById, CreatedDate FROM ContentFolderMember WHERE ChildRecordId = :firstContDocId LIMIT 10];
        System.debug('conFolMemTest(07I) >>> each ');
        System.debug('conFolMemTest(07I) >>> size '+conFolMemTest.size());
        System.debug(conFolMemTest);
        for(ContentFolderMember i : conFolMemTest){// one cycle loop
            //i.ParentContentFolderId = testFolderRecord.Id;
            // update i;
        }


    }
}