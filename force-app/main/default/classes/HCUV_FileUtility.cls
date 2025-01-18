/**
************************************************************************************************
* @classname         : HCUV_FileUtility;
* @description       : Used by Screenflow , HCUVcorpLibraryBatches 
* @author            : Inho Kim
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       25th Jul 2024          Inho Kim             CCSOM-59        Initial Version
* 1.1       08th Oct 2024          Inho Kim             CCSOM-67        Deleted Library PSet Group
************************************************************************************************
**/
public without sharing  class HCUV_FileUtility {
    /**
    * @description - isAssignedUserForCORPLib
    * @param - accountId
    * @return Boolean
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getResultForCUVCORPLib( String currentContDocumentId ){
        Boolean isVisible = true;
        Boolean isVisible_mngr = true;
        Boolean isVisible_viewer = true;
        String visibilityType = null;
        String userType = null;
        Boolean isProperWorkspace = false;
        Boolean isPrepublished = false;
        Boolean isAlreadyPublished = false;
        ContentVersion cv = null;
        String userId = UserInfo.getUserId();
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> psaList_viewer = new List<PermissionSetAssignment>();        

        try{

            // #1 Check CurrentUser's permission Set 
            // CCSOM-67 CHANGED LIKE KEYWORD, [ASIS VIEWER/MANAGER : LibraryVwr/Mngr >> TOBE VIEWER/MANAGER : CUV_Internal/CUV_Business]
            if(String.isNotEmpty(userId)){
                // FOR MANAGERS  PermissionSet.Name is apiname, Label is name
                psaList =[SELECT Id, PermissionSet.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE  AssigneeId  = :userId AND  PermissionSet.Name LIKE  '%CUV_Business%' ];
                if(psaList.isEmpty()){    
                    //FOR VIEWERS            
                    psaList_viewer = [SELECT Id, PermissionSet.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE  AssigneeId  = :userId AND  PermissionSet.Name LIKE  '%CUV_Internal%'];
                }
            }
            //#2 Check Current ContentDoc's Rood Folder(ContentWorkSpace) 
            if(String.isNotEmpty(currentContDocumentId)){   
                Id workSpaceId;
                Id tmpParentId; 
                String cfItemId = [SELECT   Id,ParentContentFolderId,title,IsFolder FROM ContentFolderItem WHERE Id = :currentContDocumentId AND IsFolder = false  AND (NOT ParentContentFolder.Name LIKE '005%') AND  (NOT Title LIKE '005%') LIMIT 1].ParentContentFolderId;
                System.debug('====0 ');
                System.debug(currentContDocumentId);
                System.debug('====1 ');
                System.debug(cfItemId);
                //keepLoop
                ContentWorkspace workSpaceRec;
                ContentFolderItem cfItem;
                Integer startLoop = 1;
                while(startLoop  == 1 || cfItem.get('ParentContentFolderId') != null){
                        startLoop++;
                        cfItem = [SELECT   Id,ParentContentFolderId,title,IsFolder FROM ContentFolderItem WHERE Id = :cfItemId AND   ( NOT ParentContentFolder.Name LIKE '005%' )   LIMIT 1];
                        
                        if(cfItem.get('ParentContentFolderId') != null){
                            cfItemId = cfItem.ParentContentFolderId;
                        }else{
                            workSpaceRec =  [SELECT Id, Name from  ContentWorkspace WHERE Id = :cfItem.Title LIMIT 1];
                        }
                        if(workSpaceRec != null && workSpaceRec.get('Name') != null){
                            String wsName =  (String)  workSpaceRec.get('Name') ;
                            // use label or list later  (add   Pre-Published  ,  Soft Deleted ) 
                            // no need to tet code to seeAllData = true when test to get Custom Label .
                            isProperWorkspace =  wsName.containsIgnoreCase('Certified') ||  wsName.containsIgnoreCase( 'Pre' )  || wsName.containsIgnoreCase('Deleted') ;                                            
                            isPrepublished =  wsName.containsIgnoreCase( 'Pre' );
                            isAlreadyPublished =  wsName.containsIgnoreCase('Certified') || wsName.containsIgnoreCase('Soft Deleted');
                            visibilityType =   (wsName.containsIgnoreCase( 'Certified' )) ? 'main'  : (wsName.containsIgnoreCase( 'Pre' )) ? 'pre'  :   (wsName.containsIgnoreCase( 'Deleted' )) ? 'deleted' : null;
                        }
                    
                }   
                    
            }

            if(String.isNotBlank(currentContDocumentId)){
                // Use isLates field rather than isMajorversion 
                cv = [SELECT Id FROM CONTENTVERSION WHERE contentdocumentId  = :currentContDocumentId AND isLatest = TRUE LIMIT 1 ];
            }        
            isVisible =   (! psaList_viewer.isEmpty() || ! psaList.isEmpty()) && cv != null  && isProperWorkspace;
            isVisible_mngr =   ! psaList.isEmpty() && cv != null  && isProperWorkspace;
            isVisible_viewer =   ! psaList_viewer.isEmpty() && cv != null  && isProperWorkspace;
            
            userType =  (! psaList.isEmpty()) ? 'manager'  :  (! psaList_viewer.isEmpty()) ? 'viewer' : null;
        }catch(Exception e){
            System.debug('ERROR OCCURED -HCUV_FileUtility.getResultForCUVCORPLib: '+ e  );
        }
        return new map<string,object>{ 'isVisible' => isVisible, 'isVisible_mngr'=> isVisible_mngr, 'isVisible_viewer'=> isVisible_viewer,'visibilityType'=> visibilityType,'userType'=> userType, 'cvRecordId' => cv.Id , 'isPrepublished' => isPrepublished ,  'isAlreadyPublished' => isAlreadyPublished};
        
    }


    // make it invocable as it can be used in Flow 
    @InvocableMethod(label = 'get root contentworkspace name V2' description='Get root folder(ContentWorkspace) name.' category = 'ContentDocument')
    public static List<String> getRootWorkspaceName(List<Id> contentDocumentIdOneList){
        String res; 
        //Boolean isProperWorkspace = false;
        //069cY0000005IPJQA2
        System.debug('contentDocumentIdOneList');
        System.debug(contentDocumentIdOneList);
        Id contentDocumentId = contentDocumentIdOneList.isEmpty() ? '' : contentDocumentIdOneList[0];
        Id workSpaceId;
        Id tmpParentId; 
        // use NOT ~ LIKE statement to filter out the case when ParentFolder is User(005) . 
        String cfItemId = [SELECT   Id,ParentContentFolderId,title,IsFolder FROM ContentFolderItem WHERE Id = :contentDocumentId AND IsFolder = false  AND (NOT ParentContentFolder.Name LIKE '005%') AND  (NOT Title LIKE '005%') LIMIT 1].ParentContentFolderId;
        if(Test.isRunningTest()){            cfItemId =   contentDocumentId;     }
        System.debug('====1 ');
        System.debug(cfItemId);        
        //keepLoop
        ContentWorkspace workSpaceRec;
        ContentFolderItem cfItem;
        Integer startLoop = 1;
        while(startLoop  == 1 || cfItem.get('ParentContentFolderId') != null){
                startLoop++;
                cfItem = [SELECT   Id,ParentContentFolderId,title,IsFolder FROM ContentFolderItem WHERE Id = :cfItemId AND   ( NOT ParentContentFolder.Name LIKE '005%' )   LIMIT 1];
                System.debug('=====2   ');
                System.debug(cfItemId);        
                if(cfItem.get('ParentContentFolderId') != null){
                    cfItemId = cfItem.ParentContentFolderId;
                }else{
                    workSpaceRec =  [SELECT Id, Name from  ContentWorkspace WHERE Id = :cfItem.Title LIMIT 1];
                    System.debug('=====3   ');
                    System.debug(workSpaceRec);    
                }
                if(workSpaceRec != null && workSpaceRec.get('Name') != null){
                    res = (String)workSpaceRec.get('Name');
                }
        }
        return new List<String>{res};// this list can be passed to FLOW as 'a text variable'(not collection)
    }

}