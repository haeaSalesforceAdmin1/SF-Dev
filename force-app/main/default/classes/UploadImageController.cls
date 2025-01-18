public with sharing class UploadImageController {
	@AuraEnabled
    public static Id getContentVersionId(Id contentDocumentId) {
        
        System.debug('INNNNNNNN getContentVersionId');
        return [
            SELECT Id, ContentDocument.ContentSize
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ].Id;
    }

   
    @AuraEnabled
    public static ContentWrapper checkFileSize(List<String> documentIds) {

        String response = NULL;
        Integer count = 1;
        List<ContentDocument> listToDlt = new List<ContentDocument>();
        List<String> listDLTFiles = new List<String>();
        ContentWrapper contWrpr = NULL;
        for (ContentDocument contDoc : [SELECT Id, contentsize, title 
                                        FROM ContentDocument 
                                        WHERE Id IN: documentIds]) {
               
                    Integer size = contDoc.contentsize;
                    System.debug('Title '+contDoc.title+' size-->> '+size);
                    if(size > 5000000){
                        listDLTFiles.add(contDoc.Id);
                        listToDlt.add(contDoc);
                            response = count+') '+contDoc.title+' \n ';   
                            count++; 
                            }
                                                      
        }

        if (listToDlt.size() > 0) {
            response = 'The file size exceeds the maximum limit of 5MB. \n \n '+response;
            delete listToDlt;
            
        } else {
            response = 'SUCCESS';
        }

        contWrpr = new ContentWrapper(response,listDLTFiles);

        return contWrpr;
    }

    public class ContentWrapper{

        @AuraEnabled public String response{get;set;}
        @AuraEnabled public List<String> deletedFiles{get;set;}

        public ContentWrapper(String rsp,List<String> files){
            this.response = rsp;
            this.deletedFiles = files;
        }
        
    }	
}