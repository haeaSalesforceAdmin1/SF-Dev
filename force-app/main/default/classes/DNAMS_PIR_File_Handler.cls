public without sharing class DNAMS_PIR_File_Handler {
    
    public static void DNAMS_ContentDocumentLinkTrigger_BeforeInsert(List<ContentDocumentLink> trigger_New){
        
        Set<Id> pirElementIds = new Set<Id>();  // Set to hold PIR_Element__c IDs
    Map<Id, PIR_Element__c> pirElementMap = new Map<Id, PIR_Element__c>();  // To hold PIR_Element__c records
    List<PIR_Element__c> pirElementsToUpdate = new List<PIR_Element__c>();  // List of PIR_Element__c records to update
    List<Id>ContentDocIds = new List<Id>(); 
    // Collect PIR_Element__c IDs from ContentDocumentLinks being inserted or deleted
        for (ContentDocumentLink cdl : trigger_New) {
            pirElementIds.add(cdl.LinkedEntityId);
            ContentDocIds.add(cdl.ContentDocumentId);
        }
    

    // Query PIR_Element__c records to get their owner and PIR_Status__c
    pirElementMap = new Map<Id, PIR_Element__c>([
        SELECT Id, OwnerId, PIR__r.PIR_Status__c 
        FROM PIR_Element__c 
        WHERE Id IN :pirElementIds
    ]);

    // **Before Insert:** Validate file linking (ownership, PIR_Status__c)
    if (Trigger.isInsert && Trigger.isBefore) {
        for (ContentDocumentLink cdl : trigger_New) {
            PIR_Element__c pirElement = pirElementMap.get(cdl.LinkedEntityId);
            if (pirElement != null) {
                // Ensure the user is the owner of the PIR_Element__c
                if (pirElement.OwnerId != UserInfo.getUserId()) {
                    cdl.addError('You are not the owner of this PIR Element. You cannot link files.');
                }

                // Ensure PIR_Status__c is not restricted
                if (pirElement.PIR__r != null && 
                    (String.isEmpty(pirElement.PIR__r.PIR_Status__c) || 
                     pirElement.PIR__r.PIR_Status__c == 'Cleared' || 
                     pirElement.PIR__r.PIR_Status__c == 'Cleared With Condition[s]' || 
                     pirElement.PIR__r.PIR_Status__c == 'Not Cleared')) {
                    cdl.addError('You cannot link files to this PIR Element because PIR_Status__c is either Cleared, Cleared with Conditions, or Not Cleared.');
                }
            }
        }
    }
        
    }
    
    public static void DNAMS_ContentDocumentLinkTrigger_AfterInsert(List<ContentDocumentLink> trigger_New){
        
                
        Set<Id> pirElementIds = new Set<Id>();  // Set to hold PIR_Element__c IDs
    Map<Id, PIR_Element__c> pirElementMap = new Map<Id, PIR_Element__c>();  // To hold PIR_Element__c records
    List<PIR_Element__c> pirElementsToUpdate = new List<PIR_Element__c>();  // List of PIR_Element__c records to update
    List<Id>ContentDocIds = new List<Id>(); 
    // Collect PIR_Element__c IDs from ContentDocumentLinks being inserted or deleted
        for (ContentDocumentLink cdl : trigger_New) {
            pirElementIds.add(cdl.LinkedEntityId);
            ContentDocIds.add(cdl.ContentDocumentId);
        }
    

    // Query PIR_Element__c records to get their owner and PIR_Status__c
    pirElementMap = new Map<Id, PIR_Element__c>([
        SELECT Id, OwnerId, PIR__r.PIR_Status__c 
        FROM PIR_Element__c 
        WHERE Id IN :pirElementIds
    ]);
        
        //if (Trigger.isInsert && Trigger.isAfter) {
        List<ID> PIRElementIDs1 = new List<Id>();
        for(ContentDocumentLink cdl : trigger_New){
            PIR_Element__c pirElement = pirElementMap.get(cdl.LinkedEntityId);
            
            if (pirElement != null) {
                PIRElementIDs1.add(pirElement.Id);  
            }
        }
        
        List<PIR_Element__c> pirElementsToUpdate1 = new List<PIR_Element__c>(); 
        
        List<PIR_Element__c> ele_Last = [select id, (
                            SELECT
                                    Id,
                                    ContentDocumentId,
                                    ContentDocument.Title
                            FROM ContentDocumentLinks 
                            
                    ) from PIR_Element__c where Id in: PIRElementIDs1];
        
        for(PIR_Element__c p : ele_Last ){
            p.File_Count__c = p.ContentDocumentLinks.size();
            pirElementsToUpdate1.add(p);
        }
        
        

        if (!pirElementsToUpdate1.isEmpty()) {
            update pirElementsToUpdate1;
        }
    //}
    }
    
    public static void DNAMS_ContentDocumentLinkTrigger_BeforeDelete(List<ContentDocumentlink> trigger_old){
        

    Set<Id> pirElementIds = new Set<Id>();  // Set to hold PIR_Element__c IDs
    Map<Id, PIR_Element__c> pirElementsMap = new Map<Id, PIR_Element__c>();  // Map for PIR_Element__c records
    List<PIR_Element__c> pirElementsToUpdate = new List<PIR_Element__c>();  // List to update PIR_Element__c records
    List<ContentDocumentLink> cdl_old = new List<ContentDocumentLink>();
    List<Id> contentDcoIds = new List<Id>();
    
        for(ContentDocumentlink c : trigger_old){
        	contentDcoIds.add(c.ContentDocumentId);
    	}
    if(!contentDcoIds.isEmpty()){
    cdl_old = [select id, contentDocumentId, LinkedEntityId from ContentDocumentLink where ContentDocumentId IN: contentDcoIds];
    system.debug('Trigger.old '+ trigger_old);
    system.debug('cdl_old '+ cdl_old);
    List<ContentDocumentLink> cdl_new = new List<ContentDocumentLink>();

    // Collect the related PIR_Element__c IDs for the ContentDocuments being inserted or deleted
    //if (Trigger.isDelete) {
        system.debug('insert or delete document '+ Trigger.isDelete);
        for (ContentDocumentLink cdl :  cdl_old) { //Trigger.isInsert ? cdl_new :
            pirElementIds.add(cdl.LinkedEntityId);  // Collect PIR_Element__c IDs linked to the document
        }
        system.debug( Trigger.isAfter +' pirElementsMap  '+ pirElementsMap);
   // }
    
    // If no PIR_Element__c is linked to the ContentDocumentLink, exit early
    if (pirElementIds.isEmpty()) return;
    
    // Query PIR_Element__c records to get their owner and PIR_Status__c
    pirElementsMap = new Map<Id, PIR_Element__c>([
        SELECT Id, OwnerId, PIR__r.PIR_Status__c
        FROM PIR_Element__c
        WHERE Id IN :pirElementIds
    ]);
    system.debug('pirElementsMap '+ pirElementsMap);
    
    
    // **Before Delete: Prevent file deletion if PIR_Status__c is restricted or if not the owner**
    //if (Trigger.isDelete && Trigger.isBefore) {
        system.debug('Delete Before ' + Trigger.isBefore);
        for (ContentDocumentLink cdl : cdl_old) {
            PIR_Element__c pirElement = pirElementsMap.get(cdl.LinkedEntityId);
            
            // Ensure that the file is linked to a valid PIR_Element__c
            if (pirElement != null && pirElement.PIR__r != null) {
                String pirStatus = pirElement.PIR__r.PIR_Status__c;
                system.debug('pirStatus '+ pirStatus);
                system.debug('pirElement.OwnerId '+ pirElement.OwnerId + 'User '+ UserInfo.getUserId());
                // Check if the PIR_Status__c is restricted (Cleared, Cleared with Conditions, or Not Cleared)
                if (String.isEmpty(pirStatus) || pirStatus == 'Cleared' || pirStatus == 'Cleared With Condition[s]' || pirStatus == 'Not Cleared') {
                    cdl.addError('You cannot delete files because PIR_Status__c is either Cleared, Cleared with Conditions, or Not Cleared.');
                }
                
                // Check if the user is the owner of PIR_Element__c
                system.debug('pirElement.OwnerId '+ pirElement.OwnerId + 'User '+ UserInfo.getUserId());
                if (pirElement.OwnerId != UserInfo.getUserId()) {
                    cdl.addError('You are not the owner of this PIR Element. You cannot delete files.');
                }
            }
        }
    //}
    
    
    // After delete: Update File_Count__c for PIR_Element__c after file deletion (file count update)
    List<ID> contentdocIds = new List<Id>();
    for(ContentDocumentLink cdl1 : cdl_old){
        contentdocIds.add(cdl1.contentDocumentId);
    }
    List<ID> PIRElementIDs1 = new List<Id>();
   // if (Trigger.isDelete) {
        system.debug('After delete ' + Trigger.isAfter);
        for (ContentDocumentLink cdl : cdl_old) {
            PIR_Element__c pirElement = pirElementsMap.get(cdl.LinkedEntityId);

            // Ensure the PIR_Element__c exists
            if (pirElement != null) {
                PIRElementIDs1.add(pirElement.Id);
                //Integer updatedFileCount = [SELECT COUNT() FROM ContentDocumentLink WHERE contentDocumentId !=: cdl.contentDocumentId and LinkedEntityId = :pirElement.Id];
                //pirElement.File_Count__c = updatedFileCount;
                //pirElementsToUpdate.add(pirElement);
            }
        }
        
        List<PIR_Element__c> pirElementsToUpdate1 = new List<PIR_Element__c>(); 
        
        List<PIR_Element__c> ele_Last = [select id, (
                            SELECT
                                    Id,
                                    ContentDocumentId,
                                    ContentDocument.Title
                            FROM ContentDocumentLinks where ContentDocumentId not IN: contentdocIds
                            
                    ) from PIR_Element__c where Id in: PIRElementIDs1];
        
        for(PIR_Element__c p : ele_Last ){
            p.File_Count__c = p.ContentDocumentLinks.size();
            pirElementsToUpdate1.add(p);
        }

        // Update PIR_Element__c with the new file count
        if (!pirElementsToUpdate1.isEmpty()) {
            //update pirElementsToUpdate;
            update pirElementsToUpdate1;
        }
    //}
}
        
    }

    
    public static void DNAMS_ContentDocumentTrigger_BeforeDelete(List<ContentDocument> trigger_old){
        

    Set<Id> pirElementIds = new Set<Id>();  // Set to hold PIR_Element__c IDs
    Map<Id, PIR_Element__c> pirElementsMap = new Map<Id, PIR_Element__c>();  // Map for PIR_Element__c records
    List<PIR_Element__c> pirElementsToUpdate = new List<PIR_Element__c>();  // List to update PIR_Element__c records
    List<ContentDocumentLink> cdl_old = new List<ContentDocumentLink>();
    List<Id> contentDcoIds = new List<Id>();
    
        for(ContentDocument c : trigger_old){
        	contentDcoIds.add(c.Id);
    	}
    if(!contentDcoIds.isEmpty()){
    cdl_old = [select id, contentDocumentId, LinkedEntityId from ContentDocumentLink where ContentDocumentId IN: contentDcoIds];
    system.debug('Trigger.old '+ trigger_old);
    system.debug('cdl_old '+ cdl_old);
    List<ContentDocumentLink> cdl_new = new List<ContentDocumentLink>();

    // Collect the related PIR_Element__c IDs for the ContentDocuments being inserted or deleted
    //if (Trigger.isDelete) {
        system.debug('insert or delete document '+ Trigger.isDelete);
        for (ContentDocumentLink cdl :  cdl_old) { //Trigger.isInsert ? cdl_new :
            pirElementIds.add(cdl.LinkedEntityId);  // Collect PIR_Element__c IDs linked to the document
        }
        system.debug( Trigger.isAfter +' pirElementsMap  '+ pirElementsMap);
   // }
    
    // If no PIR_Element__c is linked to the ContentDocumentLink, exit early
    if (pirElementIds.isEmpty()) return;
    
    // Query PIR_Element__c records to get their owner and PIR_Status__c
    pirElementsMap = new Map<Id, PIR_Element__c>([
        SELECT Id, OwnerId, PIR__r.PIR_Status__c
        FROM PIR_Element__c
        WHERE Id IN :pirElementIds
    ]);
    system.debug('pirElementsMap '+ pirElementsMap);
    
    
    // **Before Delete: Prevent file deletion if PIR_Status__c is restricted or if not the owner**
    //if (Trigger.isDelete && Trigger.isBefore) {
        system.debug('Delete Before ' + Trigger.isBefore);
        for (ContentDocumentLink cdl : cdl_old) {
            PIR_Element__c pirElement = pirElementsMap.get(cdl.LinkedEntityId);
            
            // Ensure that the file is linked to a valid PIR_Element__c
            if (pirElement != null && pirElement.PIR__r != null) {
                String pirStatus = pirElement.PIR__r.PIR_Status__c;
                system.debug('pirStatus '+ pirStatus);
                system.debug('pirElement.OwnerId '+ pirElement.OwnerId + 'User '+ UserInfo.getUserId());
                // Check if the PIR_Status__c is restricted (Cleared, Cleared with Conditions, or Not Cleared)
                if (String.isEmpty(pirStatus) || pirStatus == 'Cleared' || pirStatus == 'Cleared With Condition[s]' || pirStatus == 'Not Cleared') {
                    cdl.addError('You cannot delete files because PIR_Status__c is either Cleared, Cleared with Conditions, or Not Cleared.');
                }
                
                // Check if the user is the owner of PIR_Element__c
                system.debug('pirElement.OwnerId '+ pirElement.OwnerId + 'User '+ UserInfo.getUserId());
                if (pirElement.OwnerId != UserInfo.getUserId()) {
                    cdl.addError('You are not the owner of this PIR Element. You cannot delete files.');
                }
            }
        }
    //}
    
    
    // After delete: Update File_Count__c for PIR_Element__c after file deletion (file count update)
    List<ID> contentdocIds = new List<Id>();
    for(ContentDocumentLink cdl1 : cdl_old){
        contentdocIds.add(cdl1.contentDocumentId);
    }
    List<ID> PIRElementIDs1 = new List<Id>();
   // if (Trigger.isDelete) {
        system.debug('After delete ' + Trigger.isAfter);
        for (ContentDocumentLink cdl : cdl_old) {
            PIR_Element__c pirElement = pirElementsMap.get(cdl.LinkedEntityId);

            // Ensure the PIR_Element__c exists
            if (pirElement != null) {
                PIRElementIDs1.add(pirElement.Id);
                //Integer updatedFileCount = [SELECT COUNT() FROM ContentDocumentLink WHERE contentDocumentId !=: cdl.contentDocumentId and LinkedEntityId = :pirElement.Id];
                //pirElement.File_Count__c = updatedFileCount;
                //pirElementsToUpdate.add(pirElement);
            }
        }
        
        List<PIR_Element__c> pirElementsToUpdate1 = new List<PIR_Element__c>(); 
        
        List<PIR_Element__c> ele_Last = [select id, (
                            SELECT
                                    Id,
                                    ContentDocumentId,
                                    ContentDocument.Title
                            FROM ContentDocumentLinks where ContentDocumentId not IN: contentdocIds
                            
                    ) from PIR_Element__c where Id in: PIRElementIDs1];
        
        for(PIR_Element__c p : ele_Last ){
            p.File_Count__c = p.ContentDocumentLinks.size();
            pirElementsToUpdate1.add(p);
        }

        // Update PIR_Element__c with the new file count
        if (!pirElementsToUpdate1.isEmpty()) {
            //update pirElementsToUpdate;
            update pirElementsToUpdate1;
        }
    //}
}
        
    }

}