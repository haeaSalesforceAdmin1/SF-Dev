/**
 * Created by San on 2023-08-02.
 */

 public with sharing class FileHistoryUtil {

    public static final String Content_Insert = 'Uploaded a File';
    public static final String Content_VersionUpdate = 'Uploaded New Version';
    public static final String Content_Rename = 'Renamed a File';
    public static final String Content_Update = 'Updated a File';
    public static final String Content_Delete = 'Deleted a File';
    public static final String Collection_Insert = 'Created a Collection';
    public static final String Collection_Rename = 'Renamed a Collection';
    public static final String Collection_Update = 'Updated a Collection';
    public static final String Collection_Delete = 'Deleted a Collection';
    public static final String Version_Number = 'Version Number';
    public static final String File_Name = 'File Name';
    /**
     * @description : InsertTrigger Insert File History
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-02
     * @param Map<Id, SObject> newMap
     * Code Edit : 23/09/25 fixed for loop code
     */
    public static void InsertContentVersion(Map<Id, SObject> newMap) {
        List<DocumentHistory__c> InsertList = InsertVersionFileHistory(newMap);
        List<ContentVersion> ContentVersionList = (List<ContentVersion>)newMap.values();
        try{

            if(CheckVersionUpdate(newMap.values()[0].Id)){
                for(ContentVersion ContentVersionObj : ContentVersionList){
                    for(DocumentHistory__c DocumentHistoryObj :InsertList){
                        DocumentHistoryObj.Activity__c = Content_VersionUpdate;
                        DocumentHistoryObj.FieldName__c = Version_Number;
                        DocumentHistoryObj.HiddenField__c = ContentVersionObj.Id;
                        DocumentHistoryObj.OriginalValue__c = String.valueOf(Integer.valueOF(ContentVersionList[0].VersionNumber)-1);
                        DocumentHistoryObj.NewValue__c = ContentVersionList[0].VersionNumber + ' ' + (ContentVersionList[0].ReasonForChange == null ? '' : '');
                        DocumentHistoryObj.FileName__c = ContentVersionObj.PathOnClient;
                    }
                }
            }else{
                String NewValue = [SELECT Title FROM ContentVersion WHERE Id =: newMap.values()[0].Id].Title;
                for(ContentVersion ContentVersionObj : ContentVersionList){
                    for(DocumentHistory__c DocumentHistoryObj :InsertList){
                        DocumentHistoryObj.Activity__c = Content_Insert;
                        DocumentHistoryObj.FieldName__c = File_Name;
                        DocumentHistoryObj.HiddenField__c = newMap.values()[0].Id;
                        DocumentHistoryObj.NewValue__c = NewValue;
                        DocumentHistoryObj.FileName__c = ContentVersionObj.PathOnClient;
                    }
                }
            }
            if(InsertList.size()>0) insert InsertList;
        }catch(Exception e){
            System.debug('Exception :: ' + e);
        }
    }
    
    /** 
     * @description : InsertTrigger VersionUpdate Check (ContentVersion Previous version query)
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-02
     * @param String cvId
     */
    public static Boolean CheckVersionUpdate(String cvId){
        Boolean result = false;
        
        List<ContentVersion> cvList = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cvId AND IsLatest = True AND VersionNumber > '1'];
        result = cvList.size()>0 ? true : false;

        return result;
    }


    /**
     * @description :  UpdateTrigger Insert File History (Common Logic)
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-02
     * @param Map<Id, SObject> oldMap,Map<Id, SObject> newMap,String Field
     */
    public static void UpdateContentVersion(Map<Id, SObject> oldMap,Map<Id, SObject> newMap) {

        try{
            UpdateContentFileField(oldMap,newMap,'Title');
            UpdateContentFileField(oldMap,newMap,'Description');
        }catch(Exception e){
            System.debug('Exception ::'+e);
        }
        
    }

    /**
     * @description :  UpdateTrigger Insert File History (Common Logic)
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-02
     * @param Map<Id, SObject> oldMap,Map<Id, SObject> newMap,String Field
     */
    public static void UpdateContentFileField(Map<Id, SObject> oldMap,Map<Id, SObject> newMap,String Field) {
        List<DocumentHistory__c> DefaultValueList = InsertVersionFileHistory(newMap);
        List<ContentVersion> oldList = (List<ContentVersion>)oldMap.values();
        List<ContentVersion> newList = (List<ContentVersion>)newMap.values();

        for(ContentVersion ContentVersionObj : newList){
                
            if(oldList[0].get(Field) != ContentVersionObj.get(Field)){
                for(DocumentHistory__c DocumentHistoryObj : DefaultValueList){
                    DocumentHistoryObj.Activity__c = Field == 'Title' ? Content_Rename : Content_Update;
                    DocumentHistoryObj.FieldName__c = Field;
                    DocumentHistoryObj.OriginalValue__c = (String)oldList[0].get(Field);
                    DocumentHistoryObj.NewValue__c = (String)ContentVersionObj.get(Field);
                    DocumentHistoryObj.FileName__c = ContentVersionObj.PathOnClient;
                }
                if(DefaultValueList.size()>0) insert DefaultValueList;
            }
        }
    }

    /** 
     * @description : Insert, Update, Delete Trigger Common Insert Field
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-02
     * @param Map<Id, SObject> oldMap,Map<Id, SObject> newMap
     * Code Edit : 23/09/21 FileHistory Bulk (San,Kang)
     * Code Edit : 23/09/25 fixed for loop code
     */
    public static List<DocumentHistory__c> InsertVersionFileHistory(Map<Id, SObject> newMap) {
        List<DocumentHistory__c> DocumentHistoryList = new List<DocumentHistory__c>();
        /**
         * VersionUpdate Issue Query 
         * */
        String cdId = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:newMap.values()[0].Id].ContentDocumentId;
        List<ContentVersion> DocumentList = [SELECT Id,FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId =:cdId AND VersionNumber = '1'];
        String obj = DocumentList[0].FirstPublishLocationId.getSObjectType().getDescribe().getName();
        // San,Kang : 23/09/21 FileHistory Bulk, Added ObjIdList 
        List<Id> objIdList = new List<Id>();
        for(ContentVersion contentVersionId : DocumentList){
            objIdList.add(contentVersionId.FirstPublishLocationId);
        }
        List<SObject> sobjList = getCollectionName(objIdList);

        DocumentHistory__c DocumentHistoryObj = new DocumentHistory__c(); 
        // San,Kang : 23/09/21 FileHistory Bulk, Added objIdList 
        DocumentHistoryObj.CollectionId__c = (String)sobjList[0].get('Id');
        DocumentHistoryObj.CollectionName__c = (String)sobjList[0].get('Name');
        if(obj != 'MiscDocument__c' ){
            DocumentHistoryObj.Folder__c = (String)sobjList[0].get('Folder__c');
        }
        /**
         * @description :RRP Project RRP Check
         * @author San, Kang : SanKang@autoeveramerica.com | 2024-05-01
         */
        if(ContentVersionUtil.Check_RRPObj.contains(obj)){
            System.debug('test:::'+(String)sobjList[0].get('RRP__c'));
            DocumentHistoryObj.RRP__c = (String)sobjList[0].get('RRP__c');
        }else if(ContentVersionUtil.Check_LRObj.contains(obj)){              // STIL Project, 2024-06-19 San, Kang
            DocumentHistoryObj.Lab_Request__c = (String)sobjList[0].get('Lab_Request__c');
        }
        else{
            DocumentHistoryObj.Case__c = (String)sobjList[0].get('Case__c');
        }
        DocumentHistoryObj.DocumentName__c = DocumentList[0].FirstPublishLocationId.getSObjectType().getDescribe().getLabel();
        DocumentHistoryObj.Timestamp__c = System.now();
        DocumentHistoryList.add(DocumentHistoryObj);

        return DocumentHistoryList;
    }

    /**
     * @description : DeleteTrigger Insert File History
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-02
     * @param Map<Id, SObject> oldMap,Map<Id, SObject> newMap
     */
    public static void deleteContentVersion(Map<Id, SObject> oldMap) {
        List<DocumentHistory__c> DeleteList = [SELECT RRP__c,Case__c,Lab_Request__c,CollectionName__c,CollectionId__c,DocumentName__c,Folder__c,FileName__c,HiddenField__c FROM DocumentHistory__c WHERE HiddenField__c =:(String)oldMap.values()[0].get('LatestPublishedVersionId') ORDER BY Timestamp__c DESC Limit 1];
        System.debug('deleteList' + DeleteList);
        List<ContentDocument> ContentDocumentList = (List<ContentDocument>)oldMap.values();
        List<DocumentHistory__c> InsertList = new List<DocumentHistory__c>();
        try{
            if(DeleteList.size()>0){

                for(ContentDocument ContentDocumentObj : ContentDocumentList){
                    DocumentHistory__c DocumentHistoryObj = new DocumentHistory__c(); 
                    DocumentHistoryObj.FieldName__c = ContentDocumentObj.Title;
                    DocumentHistoryObj.Activity__c = Content_Delete;
                    DocumentHistoryObj.OriginalValue__c = ContentDocumentObj.Title;
                    DocumentHistoryObj.CollectionId__c = (String)DeleteList[0].get('CollectionId__c'); //obj Name
                    DocumentHistoryObj.CollectionName__c = (String)DeleteList[0].get('CollectionName__c'); //obj Name
                    /**
                     * @description :RRP Project RRP Check
                     * @author San, Kang : SanKang@autoeveramerica.com | 2024-05-01
                     */
                    if((String)DeleteList[0].get('RRP__c') != null){
                        DocumentHistoryObj.RRP__c = (String)DeleteList[0].get('RRP__c');
                    }else if((String)DeleteList[0].get('Lab_Request__c') != null){          // STIL Project, 2024-06-19 San, Kang
                        DocumentHistoryObj.Lab_Request__c = (String)DeleteList[0].get('Lab_Request__c');
                    }
                    else{
                        DocumentHistoryObj.Case__c = (String)DeleteList[0].get('Case__c');
                    }
                    DocumentHistoryObj.DocumentName__c = (String)DeleteList[0].get('DocumentName__c'); 
                    DocumentHistoryObj.Folder__c = (String)DeleteList[0].get('Folder__c'); 
                    DocumentHistoryObj.Timestamp__c = System.now();
                    DocumentHistoryObj.FileName__c = (String)DeleteList[0].get('FileName__c'); 
                    InsertList.add(DocumentHistoryObj);
                }
            }
            System.debug('size'+InsertList.size());
            if(InsertList.size()>0) insert InsertList;
        }catch(Exception e){
            System.debug('Exception :: ' + e);
        }
    }


    /**
     * @description :  InsertTrigger DA, DRC, TRC, SDA, SIMS, Legal, Misc ContentDocument
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-03
     * @param Map<Id, SObject> newMap
     * Code Edit : 23/09/21 FileHistory Bulk (San,Kang)
     * Code Edit : 23/09/25 fixed for loop code
     */
    public static void InsertContentDocument(Map<Id, SObject> newMap) {
        // San,Kang : 23/09/21 FileHistory Bulk, Added ObjIdList 
        List<Id> objIdList = new List<Id>();
        for(SObject objId : newMap.values()){
            objIdList.add((Id)objId.Id);
        }
        try{
        List<SObject> sobjList = getCollectionName(objIdList);
        List<DocumentHistory__c> InsertList = InsertDocumentFileHistory(newMap,sobjList);

            for(DocumentHistory__c DocumentHistoryObj : InsertList){
                DocumentHistoryObj.Activity__c = Collection_Insert;
                // San,Kang : 23/09/21 FileHistory Bulk, Added objIdList
                DocumentHistoryObj.FieldName__c = (String)newMap.values()[0].get('Name');
                DocumentHistoryObj.NewValue__c = (String)newMap.values()[0].get('Name');
            }
           
            if(InsertList.size()>0) insert InsertList;
        }catch(Exception e){
            System.debug('Exception :: ' + e);
        }
    }

    /**
     * @description :  UpdateTrigger DA, DRC, TRC, SDA, SIMS, Legal, Misc ContentDocument
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-03
     * Map<Id, SObject> oldMap,Map<Id, SObject> newMap
     * Code Edit : 23/09/21 FileHistory Bulk (San,Kang)
     */
    public static void UpdateContentDocument(Map<Id, SObject> oldMap,Map<Id, SObject> newMap) {
        String obj = newMap.values()[0].Id.getSObjectType().getDescribe().getName();
        System.debug('obj'+obj);
        try{
            UpdateDocumentFileField(oldMap, newMap, 'Name');
            if(obj != 'SIMS_Document__c'){
            UpdateDocumentFileField(oldMap, newMap, 'OwnerId');
            }
            if(obj != 'MiscDocument__c'){
                UpdateDocumentFileField(oldMap, newMap, 'Folder__c');
                if(obj == 'LegalDocument__c'){
                    UpdateDocumentFileField(oldMap, newMap, 'Case_File_ID__c');
                    UpdateDocumentFileField(oldMap, newMap, 'Case_Search__c');
                    UpdateDocumentFileField(oldMap, newMap, 'Case__c');
                }
            }
            // if(InsertList.size()>0) insert InsertList;
        }catch(Exception e){
            System.debug('Exception :: ' + e);
        }
    }

    /**
     * @description :  UpdateTrigger DA, DRC, TRC, SDA, SIMS, Legal, Misc ContentDocument (Common Logic)
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-03
     * @param Map<Id, SObject> oldMap,Map<Id, SObject> newMap,String Field
     * San,Kang Code Edit : 23/09/21 FileHistory Bulk
     * Code Edit : 23/09/25 fixed for loop code
     */
    public static void UpdateDocumentFileField(Map<Id, SObject> oldMap,Map<Id, SObject> newMap,String Field) {
        String obj = newMap.values()[0].Id.getSObjectType().getDescribe().getName();
        List<Id> ObjIdList = new List<Id>();
        for(SObject objId : oldMap.values()){
            ObjIdList.add((Id)objId.Id);
        } 

        List<SObject> sobjList = getCollectionName(objIdList);
        List<DocumentHistory__c> DefaultValueList = InsertDocumentFileHistory(newMap,sobjList);

        // San,Kang : 23/09/21 FileHistory Bulk, Added ObjIdList, NewIdList
        List<Id> OldIdList = new List<Id>();
        List<Id> NewIdList = new List<Id>();

        if(Field == 'OwnerId'){
            for(SObject objId : oldMap.values()){
                OldIdList.add((Id)objId.get('OwnerId'));
            } 
            for(SObject objId : newMap.values()){
                NewIdList.add((Id)objId.get('OwnerId'));
            } 
        }
        System.debug('debug :::@@' + (oldMap.values()[0].get(Field) != newMap.values()[0].get(Field)));
        System.debug(oldMap.values()[0].get(Field));
        System.debug(newMap.values()[0].get(Field));
        if(oldMap.values()[0].get(Field) != newMap.values()[0].get(Field) ){            
            for(DocumentHistory__c DocumentHistoryObj : DefaultValueList){
                
                DocumentHistoryObj.Activity__c = Field == 'Name' ? Collection_Rename : Collection_Update;
                DocumentHistoryObj.FieldName__c = Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().get(Field).getDescribe().getLabel();
                
                // San,Kang : 23/09/21 FileHistory Bulk, Added objIdList,NewIdList
                DocumentHistoryObj.OriginalValue__c = Field == 'OwnerId' ? (String)oldMap.values()[0].get('Name') : (String)oldMap.values()[0].get(Field);
                DocumentHistoryObj.NewValue__c = Field == 'OwnerId' ? (String)newMap.values()[0].get('Name') : (String)newMap.values()[0].get(Field);
                if(!(obj.equalsIgnoreCase('MiscDocument__c'))){
                    DocumentHistoryObj.Folder__c = (String)newMap.values()[0].get('Folder__c');
                }
            }
            if(DefaultValueList.size()>0) insert DefaultValueList;
        }
    }

   /**
     * @description :  Insert,Update Trigger DA, DRC, TRC, SDA, SIMS, Legal, Misc ContentDocument (Common Logic)
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-03
     * @param Map<Id, SObject> newMap
     * Code Edit : 23/09/21 FileHistory Bulk (San,Kang)
     * Code Edit : 23/09/25 fixed for loop code
     */
    public static List<DocumentHistory__c> InsertDocumentFileHistory(Map<Id, SObject> newMap, List<SObject> sobjList) {
        String obj = newMap.values()[0].Id.getSObjectType().getDescribe().getName();
        List<DocumentHistory__c> fhList = new List<DocumentHistory__c>();
        List<Id> objIdList = new List<Id>();
        for(SObject objId : newMap.values()){
            objIdList.add((Id)objId.Id);
        } 
        DocumentHistory__c DocumentHistoryObj = new DocumentHistory__c(); 
        // San,Kang : 23/09/21 FileHistory Bulk, Added objIdList
        DocumentHistoryObj.CollectionId__c = (String)sobjList[0].get('Id');
        DocumentHistoryObj.CollectionName__c = (String)sobjList[0].get('Name');
        /**
        * @description :RRP Project RRP Check
        * @author San, Kang : SanKang@autoeveramerica.com | 2024-05-01
        */
        if(ContentVersionUtil.Check_RRPObj.contains(obj)){
            DocumentHistoryObj.RRP__c = (String)sobjList[0].get('RRP__c');
        }else if(ContentVersionUtil.Check_LRObj.contains(obj)){                  // STIL Project, 2024-06-19 San, Kang
            DocumentHistoryObj.Lab_Request__c = (String)sobjList[0].get('Lab_Request__c');
        }else{
            DocumentHistoryObj.Case__c = (String)sobjList[0].get('Case__c');
        }
        DocumentHistoryObj.DocumentName__c = newMap.values()[0].Id.getSObjectType().getDescribe().getLabel();
        if(!(obj.equalsIgnoreCase('MiscDocument__c'))){
            DocumentHistoryObj.Folder__c = (String)sobjList[0].get('Folder__c');
        }
        DocumentHistoryObj.Timestamp__c = System.now();
        fhList.add(DocumentHistoryObj);

        return fhList;
    }
    /**
     * @description :  DeleteTrigger DA, DRC, TRC, SDA, SIMS, Legal, Misc ContentDocument
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-04
     * @param Map<Id, SObject> oldMap
     * Code Edit : 23/09/21 FileHistory Bulk (San,Kang)
     */
    public static void DeleteContentDocument(Map<Id, SObject> oldMap) {
        String obj = oldMap.values()[0].Id.getSObjectType().getDescribe().getName();
        List<DocumentHistory__c> deleteList = new List<DocumentHistory__c>(); 
        try{
            DocumentHistory__c DocumentHistoryObj = new DocumentHistory__c(); 
            DocumentHistoryObj.CollectionId__c = (String)oldMap.values()[0].get('Id');
            DocumentHistoryObj.CollectionName__c = (String)oldMap.values()[0].get('Name');
            if(ContentVersionUtil.Check_RRPObj.contains(obj)){
                DocumentHistoryObj.RRP__c = (String)oldMap.values()[0].get('RRP__c');
            }else if(ContentVersionUtil.Check_LRObj.contains(obj)){              // STIL Project, 2024-06-19 San, Kang
                DocumentHistoryObj.Lab_Request__c = (String)oldMap.values()[0].get('Lab_Request__c');
            }else{
                DocumentHistoryObj.Case__c = (String)oldMap.values()[0].get('Case__c');
            }
            DocumentHistoryObj.DocumentName__c = oldMap.values()[0].Id.getSObjectType().getDescribe().getLabel();
            if(!(obj.equalsIgnoreCase('MiscDocument__c'))){
                DocumentHistoryObj.Folder__c = (String)oldMap.values()[0].get('Folder__c');
            }
            DocumentHistoryObj.Timestamp__c = System.now();
            DocumentHistoryObj.Activity__c = Collection_Delete;
            DocumentHistoryObj.FieldName__c = (String)oldMap.values()[0].get('Name');
            DocumentHistoryObj.OriginalValue__c = (String)oldMap.values()[0].get('Name');
            deleteList.add(DocumentHistoryObj);
            System.debug('deleteList'+deleteList);
            if(deleteList.size()>0) insert deleteList;
        }catch(Exception e){
            System.debug('Exception :: ' + e);
        }
    }
    
    /** 
     * @description : Collection Name, Case <- Document Dynamic Query
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-02
     * @param Id objId
     * Code Edit : 23/09/21 FileHistory Bulk (San,Kang)
     */

     // San,Kang : 23/09/21 FileHistory Bulk Id > List<Id>
    public static List<SObject> getCollectionName(List<Id> objIdList){

        String obj = objIdList[0].getSObjectType().getDescribe().getName();
        System.debug('objList :::' + obj);

        String SelectQuery = 'SELECT Case__c, Name FROM ';
        if(!(obj.equalsIgnoreCase('MiscDocument__c')  || obj.equalsIgnoreCase('ContentVersion'))){
            System.debug(!(obj.equalsIgnoreCase('MiscDocument__c')  && obj.equalsIgnoreCase('ContentVersion')));
            SelectQuery = 'SELECT Case__c, Folder__c, Name FROM ';
        }
        if(obj.equalsIgnoreCase('User')){
            SelectQuery = 'SELECT Name FROM ';
        }
        /**
        * @description :RRP Project RRP Check
        * @author San, Kang : SanKang@autoeveramerica.com | 2024-05-01
        */
        if(ContentVersionUtil.Check_RRPObj.contains(obj)){
            SelectQuery = 'SELECT RRP__c,Folder__c,Name FROM  ';
        }

        // STIL Project, 2024-06-19 San, Kang
        if(ContentVersionUtil.Check_LRObj.contains(obj)){
            SelectQuery = 'SELECT Lab_Request__c,Folder__c,Name FROM  ';
        }
        // San,Kang : 23/09/21 FileHistory Bulk
        String WhereQuery = ' WHERE Id IN (\'' + String.join(objIdList, '\', \'') + '\')';
        System.debug('query :::' + SelectQuery + obj + WhereQuery);

        List<SObject> records = Database.query(SelectQuery + obj + WhereQuery);

        return records;
    }

}