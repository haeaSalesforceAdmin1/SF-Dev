trigger ContentDocumentTrigger on ContentDocument (before delete,after delete) {
    
//Added by Egen Team --- To handle Files on PIR Elements Object based on Owner and status of Package Initiation Request
    
     // Set to store the Ids of the deleted ContentDocuments
    Set<Id> contentDocumentIds = new Set<Id>();
	//DNAMS_PIR_File_Handler.DNAMS_ContentDocumentTrigger_BeforeDelete(Trigger.old);
    // Collect the ContentDocument IDs from Trigger.old (deleted ContentDocuments)
    for (ContentDocument doc : Trigger.old) {
        contentDocumentIds.add(doc.Id);
    }

    // Query ContentDocumentLink to check if any deleted ContentDocuments are linked to Element__c records
    if (!contentDocumentIds.isEmpty()) {
        // Query ContentDocumentLink for the links to Element__c
        List<ContentDocumentLink> docLinks = [
            SELECT Id, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentDocumentIds
            //AND LinkedEntityId IN (SELECT Id FROM PIR_Element__c)
        ];
        List<ContentDocumentLink> cdl_filtered = new List<ContentDocumentLink>();
        for(ContentDocumentLink c1 : docLinks){
            if(c1.LinkedEntityId.getSObjectType() == PIR_Element__c.SObjectType){
                cdl_filtered.add(c1);
            }
        }
        
        if (!cdl_filtered.isEmpty()) {
            // Call your Apex class and pass the relevant records
            DNAMS_PIR_File_Handler.DNAMS_ContentDocumentTrigger_BeforeDelete(Trigger.old);
        }
    
    }
    
    if (BypassTriggers__c.getInstance().ContentDocumentTrigger__c) {
        System.Debug('ContentDocument Trigger ByPassed.');
        return;
    }
    Trigger_Framework.createHandler(ContentDocument.SObjectType);
    
    
}