public without sharing class DNAMSDeleteFileHandler {
    @AuraEnabled
    public static List<ContentDocument> getFiles(string recordId){        
        Set<Id> recordIds=new Set<Id>{recordId};
        Set<Id> documentIds = new Set<Id>();
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIds];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);
        }      
        return [SELECT Id,Title,LastModifiedDate,FileType FROM ContentDocument WHERE id IN: documentIds ORDER BY LastModifiedDate DESC]; //DNA-986 : Added LastModifiedDate in query
    }

    @AuraEnabled
    public static String deleteFiles(String docId){
        //DNA-1073-Start-Added Exception handling
        try{
        	delete [SELECT Id from ContentDocument WHERE id=:docId];
            return 'SUCCESS';
        }catch(Exception ex){
            System.debug('You can’t delete this file since it was linked to Closed/Cancled Package, please reach out to DNAMS Support for assistance.');
            return 'You can’t delete this file since it was linked to Closed/Cancled Package, please reach out to DNAMS Support for assistance.';
        }//DNA-1073-End
    }
}