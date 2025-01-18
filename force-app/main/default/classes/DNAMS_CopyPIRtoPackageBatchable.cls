public class DNAMS_CopyPIRtoPackageBatchable implements Database.Batchable<sObject> {
    
    private List<ContentVersion> CVListtoInsert_All;
    //private Map<String,String> PackageDetails_NametoID_Map;
    private String PackageEleId;
    private String OriginalId;
    
    public DNAMS_CopyPIRtoPackageBatchable(String PackageEleId , String pirEleId){ //List<ContentVersion> contverrecords, 
       // this.CVListtoInsert_All = contverrecords;
        //this.PackageDetails_NametoID_Map = PackageDetailsMap;
        this.PackageEleId = PackageEleId;
        this.OriginalId = pirEleId;
    }


	 public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
           Select ContentDocumentId, Id, IsDeleted, LinkedEntityId, ShareType, SystemModstamp, Visibility 
                                                     from ContentDocumentLink 
                                                     where LinkedEntityid =: OriginalId
        ]);
    }    
    public void execute(Database.BatchableContext context, List<ContentDocumentLink> scope) {
        try{
            //System.debug('Inserting CVs in DNAMS_CopyPIRtoPackageQueueable - '+CVListtoInsert_All.size() +' - '+PackageEleId);
            system.debug('DNAMS_CopyPIRtoPackageQueueable Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
            List<ContentDocumentLink> CDLtoinsert = new List<ContentDocumentLink>();
            List<String> condocidsList = new List<String>();
           // List<ContentDocumentLink> ContDocLinkList = [Select ContentDocumentId, Id, IsDeleted, LinkedEntityId, ShareType, SystemModstamp, Visibility 
                                                  //   from ContentDocumentLink 
                                                  //   where LinkedEntityid =: OriginalId];
            
            for(ContentDocumentLink c: scope){
                condocidsList.add(c.ContentDocumentId);
            }
            system.debug('condocidsList '+ condocidsList);
            List<ContentVersion> originalVersion = [SELECT Id, Title, VersionData, ContentDocumentId, PathOnClient FROM ContentVersion 
                                                WHERE ContentDocumentId IN : condocidsList AND IsLatest = TRUE ];
            system.debug('originalVersion '+ originalVersion.size());
            system.debug('originalVersion '+ originalVersion);
            Map<String, ContentVersion> Doc_Version_Map = new Map<String, ContentVersion>();
            for(ContentVersion o : originalVersion){
                Doc_Version_Map.put(o.ContentDocumentId, o);
            }
            
            List<ContentVersion> CVlist = new List<ContentVersion>();
            for(ContentDocumentLink cdl : scope){
                ContentVersion originalVersion1 = Doc_Version_Map.get(cdl.ContentDocumentId);
                ContentVersion newVersion = new ContentVersion();
                newVersion.Title = originalVersion1.Title;
                newVersion.VersionData = originalVersion1.VersionData; // Copy the file data
                newVersion.PathOnClient = originalVersion1.PathOnClient;
                CVlist.add(newVersion);
            }
            
            if(!CVlist.isEmpty()){
                
                Database.insert(CVlist,false);
                System.debug('Succesfully inserted CVs - '+CVlist.size());
                List<ContentVersion> insertedCVs_List = [SELECT Id,Title, ContentDocumentId FROM ContentVersion WHERE Id IN :CVlist];
                system.debug('insertedCVs_List '+ insertedCVs_List.size());
                for(ContentVersion cvrec: insertedCVs_List){
                    ContentDocumentLink newLink = new ContentDocumentLink();
                    newLink.ContentDocumentId = cvrec.ContentDocumentId;//docId;
                    //originalVersion.ContentDocumentId; // Use the same ContentDocumentId
                    //newLink.LinkedEntityId = PackageDetails_NametoID_Map.get(PkgNameExtracted); // New Parent ID
                    newLink.LinkedEntityId = PackageEleId; // New Parent ID
                    newLink.ShareType = 'V'; // Can be 'V' for view access, 'C' for collaboration, etc.
                    newLink.Visibility = 'AllUsers'; // Or 'InternalUsers' based on your use case
                    // CDLtoinsert.add(newLink);
                    CDLtoinsert.add(newLink); 
                }
                
            }
            if(!CDLtoinsert.isEmpty()){
                system.debug('CDLtoinsert '+ CDLtoinsert.size());
                Database.SaveResult[] sres =Database.insert(CDLtoinsert, false);
                system.debug('inserted ');
                for (Database.SaveResult sr : sres) {
                    if(sr.isSuccess()){
                        system.debug('inserted');
                    }
                    else {
                        Database.Error err = sr.getErrors()[0];
                        system.debug('err '+ err);
                    }
                }
            }
        } catch (Exception e){
            System.debug('Error inserting records: ' + e.getMessage());
        }
    }
    public void finish(Database.BatchableContext context) {
        System.debug('Batch processing completed.');
    }
    
}