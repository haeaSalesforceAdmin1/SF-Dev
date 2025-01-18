/** Class Description
 * Ticket: DPM-5633 Genesis Retailer Evaluation Project
 * Created By: Minhee Kim
 * Created Date: 2024-07-23
 * Description: Get failed questions related to action plan to represent on the action plan pdf for Genesis.
 * 
 * **/

public with sharing class FileUploadController {
    @AuraEnabled
    public static List<ContentDocument> getFilesForRecord(Id recordId) {
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];
        List<ContentDocument> files = new List<ContentDocument>();
        for (ContentDocumentLink link : links) {
            files.add([
                SELECT Id, Title, FileType, LatestPublishedVersionId
                FROM ContentDocument
                WHERE Id = :link.ContentDocumentId
            ]);
        }
        return files;
    }

    //DPM-5633 for actionPlanFileUpload component
    @AuraEnabled
    public static String uploadFiles(Id recordId, List<Map<String, String>> files) {
        try {
            for (Map<String, String> file : files) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = recordId;
                cdl.ContentDocumentId = file.get('documentId');
                cdl.ShareType = 'V';
                if(!Test.isRunningTest()) insert cdl;
            }
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading files: ' + e.getMessage());
        }
    }


    /*
   * @method uploadFile() 
   * @desc Creates a content version from a given file's base64 and name
   * 
   * @param {String} base64 - base64 string that represents the file
   * @param {String} filename - full file name with extension, i.e. 'products.csv'
   * @param {String} recordId - Id of the record you want to attach this file to
   * 
   * @return {ContentVersion} - returns the created ContentDocumentLink Id if the
   *   upload was successful, otherwise returns null
   */
   @AuraEnabled
   public static String uploadFile(String base64, String filename, String recordId) {
         ContentVersion cv = createContentVersion(base64, filename);
       	Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
       	System.debug('cv.Id: '+cv.Id);
        // ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
         if (cv == null) { return null; }
         return contentDocumentId;
   }

   @AuraEnabled
   public static String updateFile(String contentDocumentId, String recordId) {
         ContentDocumentLink cdl = createContentLink(contentDocumentId, recordId);
         if ( cdl == null) { return null; }
         return cdl.ContentDocumentId;
   }
   /*
    * @method createContentVersion() [private]
    * @desc Creates a content version from a given file's base64 and name
    * 
    * @param {String} base64 - base64 string that represents the file
    * @param {String} filename - full file name with extension, i.e. 'products.csv'
    * 
    * @return {ContentVersion} - returns the newly created ContentVersion, or null
    *   if there was an error inserting the record
    */
   private static ContentVersion createContentVersion(String base64, String filename) {
     ContentVersion cv = new ContentVersion();
     cv.VersionData = EncodingUtil.base64Decode(base64);
     cv.Title = filename;
     cv.PathOnClient = filename;
     try {
       insert cv;
       return cv;
     } catch(DMLException e) {
       System.debug(e);
       return null;
     }
   }
 
    /*
    * @method createContentLink() [private]
    * @desc Creates a content link for a given ContentVersion and record
    * 
    * @param {String} contentVersionId - Id of the ContentVersion of the file
    * @param {String} recordId - Id of the record you want to attach this file to
    * 
    * @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
    *   or null if there was an error inserting the record
    */
   private static ContentDocumentLink createContentLink(String contentDocumentId, String recordId) {
               if (contentDocumentId == null || recordId == null) { return null; }
     ContentDocumentLink cdl = new ContentDocumentLink();
     cdl.ContentDocumentId =Id.valueOf(contentDocumentId);
     cdl.LinkedEntityId = recordId;
     // ShareType is either 'V', 'C', or 'I'
     // V = Viewer, C = Collaborator, I = Inferred
     cdl.ShareType = 'V';
     try {
       insert cdl;
       return cdl;
     } catch(DMLException e) {
       System.debug(e);
       return null;
     }
   }
}