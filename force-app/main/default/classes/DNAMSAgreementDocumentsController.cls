public without sharing class DNAMSAgreementDocumentsController {

    public static boolean allowForTest = false;
    
    @AuraEnabled(cacheable=false)
    public static String getRelatedFilesByRecordId(String recordId) {
        Boolean isDNAMSUser=false;
        String currentUserContactId = [Select Id,ContactId From User Where Id =:UserInfo.getUserId()].ContactId;
        //String currentUserContactId = '0033I00000Rtal4QAB';
        
        for(AccountContactRelation acrRecord: [
            SELECT Id,
                AccountId,
                ContactId 
            FROM AccountContactRelation 
            WHERE AccountId =: recordId 
            AND DNAMSAccountUser__c = true
        ]){
            if(currentUserContactId == acrRecord.ContactId || allowForTest){
                isDNAMSUser = true;
            }
        }
        System.debug('BR==isDNAMSUser='+isDNAMSUser);
        List<DocumentWrapper> documents = new List<DocumentWrapper>();
        if(isDNAMSUser){
            // Get record file IDs        
            List<ContentDocumentLink> files = [SELECT 
                                                ContentDocumentId 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId = :recordId
                                            ];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }

            List<ContentVersion> docs = [SELECT 
                                            ContentDocumentId, 
                                            FileExtension, 
                                            Title,  
                                            LastModifiedDate,
                                            ContentSize
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN : fileIDs
                                        ];
            Map<ID, String> mapIdTitle = new Map<ID, String>();
            for (ContentVersion docLink : docs) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
            }

           
            //Generate wrapper records
            for (ContentVersion record : docs) {
                System.debug('record:: ' + JSON.serializePretty(record));

                DocumentWrapper wrapper = new DocumentWrapper();
                wrapper.Id = record.ContentDocumentId;
                wrapper.Title = record.Title;
                wrapper.LastModified = record.LastModifiedDate+'';
                wrapper.Size = record.ContentSize+'';
                wrapper.FileExtension = record.FileExtension;
                documents.add(wrapper);
            }
        }

        return (isDNAMSUser)?JSON.serialize(documents):'';
    }

    // ---------------- Wrapper Classes ----------------
    public class DocumentWrapper {
        public Id Id;
        public String Title;
        public String LastModified;
        public String Size;
        public String FileExtension;
    }
}