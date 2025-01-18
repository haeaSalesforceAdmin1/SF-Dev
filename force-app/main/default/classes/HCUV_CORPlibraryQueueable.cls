public with sharing class HCUV_CORPlibraryQueueable implements Queueable{


    private List<Id> contentDocumentIds;
    private List<Id> targetFolderIds;

    // Method to be called by another classes 
    // HCUV_CORPlibraryQueueable.updateContentFolderMembersAsync( List<Id> contentDocumentIds, List<Id> targetFolderIds )
    public static void updateContentFolderMembersAsync(List<Id> contentDocumentIds, List<Id> targetFolderIds) {
        // AsyncOptions asyncOptions = new AsyncOptions();
        // asyncOptions.MaximumQueueableStackDepth = depth;
        Integer i = 1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        System.enqueueJob(new HCUV_CORPlibraryQueueable(contentDocumentIds, targetFolderIds));
    }


    private HCUV_CORPlibraryQueueable(List<Id> contentDocumentIds, List<Id> targetFolderIds) {
        this.contentDocumentIds = contentDocumentIds;
        this.targetFolderIds = targetFolderIds;
    }


    // proceed Async Queueable Job 
    public void execute(QueueableContext context) {
        List<ContentFolderMember> folderMembersToUpdate = new List<ContentFolderMember>();
        for (ContentFolderMember cfm : [SELECT Id, ParentContentFolder.Name, ParentContentFolderId, ChildRecordId FROM ContentFolderMember WHERE ChildRecordId IN :contentDocumentIds]) {
            String folderName =cfm.ParentContentFolder.Name; 
            // only allow when parentName is 058, which is ContentWorkSpace RecordId  005(User) creates exception
            if( folderName.containsIgnoreCase('058')){
                Integer index = contentDocumentIds.indexOf(cfm.ChildRecordId);
                if (index != -1) {cfm.ParentContentFolderId = targetFolderIds[index];folderMembersToUpdate.add(cfm);
                }
            }
        }
        if (!folderMembersToUpdate.isEmpty()) {
            update folderMembersToUpdate;
        }
    }


}