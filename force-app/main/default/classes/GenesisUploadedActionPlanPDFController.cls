/** Class Description
 * Ticket: DPM-5633 Genesis Retailer Evaluation Project
 * Created By: Minhee Kim
 * Created Date: 2024-08-01
 * Description: Get content document which is uploaded by GX team.
 * 
 * **/
public class GenesisUploadedActionPlanPDFController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPdfFilesWithIdsAsBase64(Id recordId) {
  
        // Find all quotes related to the given opportunity
        Evaluation__c eval = [SELECT Id, ActionPlanFileId__c FROM Evaluation__c WHERE Id = :recordId LIMIT 1];
        
        // Find all content document links related to the quotes
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :eval.ActionPlanFileId__c
        ];
        
        // Collect all content document IDs from the links
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }
        
        // Find all content versions based on the content document IDs
        List<ContentVersion> contentVersions = [
            SELECT ContentDocumentId, VersionData, CreatedDate
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            ORDER BY CreatedDate DESC
        ];
        
        // Map content document ID to its content versions
        Map<Id, List<ContentVersion>> documentVersionsMap = new Map<Id, List<ContentVersion>>();
        for (ContentVersion version : contentVersions) {
            if (!documentVersionsMap.containsKey(version.ContentDocumentId)) {
                documentVersionsMap.put(version.ContentDocumentId, new List<ContentVersion>());
            }
            documentVersionsMap.get(version.ContentDocumentId).add(version);
        }
        
        // Prepare the list of files with their IDs and base64 data
        List<Map<String, String>> pdfFilesWithIds = new List<Map<String, String>>();
        List<ContentVersion> allVersionsForEval = new List<ContentVersion>();
        for (ContentDocumentLink link : contentDocumentLinks) {
            if (link.LinkedEntityId == eval.Id && documentVersionsMap.containsKey(link.ContentDocumentId)) {
                allVersionsForEval.addAll(documentVersionsMap.get(link.ContentDocumentId));
            }
        }
        allVersionsForEval.sort();
                    
        for (ContentVersion version : contentVersions) {
            Map<String, String> pdfData = new Map<String, String>();
            if(version.ContentDocumentId!=null){
                pdfData.put('ContentDocumentId', version.ContentDocumentId);
                pdfData.put('Base64Data', EncodingUtil.base64Encode(version.VersionData));
                pdfFilesWithIds.add(pdfData);
            }
        } 
        
        
        return pdfFilesWithIds;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPdfFilesWithIds(String contentDocumentId) {

        // Find all content versions based on the content document IDs
        List<ContentVersion> contentVersions = [
            SELECT ContentDocumentId, VersionData, CreatedDate
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
            ORDER BY CreatedDate DESC
        ];
        
        List<Map<String, String>> pdfFilesWithIds = new List<Map<String, String>>();            
        for (ContentVersion version : contentVersions) {
            Map<String, String> pdfData = new Map<String, String>();
            if(version.ContentDocumentId!=null){
                pdfData.put('ContentDocumentId', version.ContentDocumentId);
                pdfData.put('Base64Data', EncodingUtil.base64Encode(version.VersionData));
                pdfFilesWithIds.add(pdfData);
            }
        } 
        
        
        return pdfFilesWithIds;
    }
}