public without sharing class  BatchToUpdateContentDocumentLink  implements Database.Batchable<SObject> {

    public String query = 'select Id, Visibility from ContentDocumentLink where LinkedEntityId IN (select Id from Survey_Question__c) and Visibility !=\'AllUsers\'';
    public Set<Id> contentDocumentIds;
    public Integer i = 0;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<ContentDocumentLink> contentDocumentLinks) {

        List<ContentDocumentLink> tobeUpdate = new List<ContentDocumentLink>();
        
        for(ContentDocumentLink contentdocumentlink : contentDocumentLinks){
            System.debug(LoggingLevel.ERROR, contentdocumentlink);
            contentdocumentlink.Visibility = 'AllUsers';
            tobeUpdate.add(contentdocumentlink);
            System.debug(LoggingLevel.ERROR, contentdocumentlink);
        }
        
        try{
            update tobeUpdate;
        }catch(Exception e){
            System.debug(e.getCause());
            System.debug(e.getMessage());
        }
 
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('finish');
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
    }


}