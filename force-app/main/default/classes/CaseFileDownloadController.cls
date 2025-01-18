public with sharing class CaseFileDownloadController {
    /**
     * @description       : SO-310 Create a means to bulk download files attached to a case
     * @author            : sankang@autoeveramerica.com | 2024-01-02 ~ 2024-01-03
     * @last modified on  : 01-03-2024
     * @last modified by  : sankang@autoeveramerica.com
    **/
    @AuraEnabled(cacheable=true)
    public static ContentDocument[] getFilesByIds(String[] contentDocumentIds) {
        return [
            SELECT
            Id, Title, FileExtension, LatestPublishedVersionId
            FROM ContentDocument
            WHERE Id IN :contentDocumentIds
        ];
    }
}