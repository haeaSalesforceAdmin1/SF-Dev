public class DNAMSDeletePackageRecordQueueable implements Queueable {
	private String packageRecordId;
    
    public DNAMSDeletePackageRecordQueueable(String recordId) {
        if(recordId != null ){
            this.packageRecordId = recordId;
        }
    }
  /*  
    public DNAMSDeletePackageRecordQueueable(String recordId, Map<Id,PackageElement__c> mapOfSourcePackageElements) {
        if(recordId != null ){
            this.packageRecordId = recordId;
        }
    }
  */  
    public void execute(QueueableContext context) {
        ContentVersionTriggerHandler.run = false;
        ContentVersionTriggerHandler.skipForClone = true;
        ContentDocumentLinkTriggerHandler.run = false;
        
        List<String> listOfLinkedEntities = new List<String>();
        List<sObject> deleteRecords = new List<sObject>();
        //New Code
        for(Package__c packageRecord :[Select Id, 
                                       (Select Id FROM PackageElements__r),
                                       (Select Id FROM Applicant_Info__r),
                                       (Select Id FROM Approval_History__r) 
                                       FROM Package__c Where Id =: this.packageRecordId ]){	
            for(PackageElement__c packageElement : packageRecord.PackageElements__r){
                deleteRecords.add(packageElement);
                listOfLinkedEntities.add(packageElement.Id);
            }
            for(Applicant_Info__c packageApplicant : packageRecord.Applicant_Info__r){
                deleteRecords.add(packageApplicant);
            }
            for(Package_Approval__c packageApproval : packageRecord.Approval_History__r){
                deleteRecords.add(packageApproval);
            }
            
            deleteRecords.add(packageRecord);
            listOfLinkedEntities.add(packageRecord.Id);
            
        }
        //New Code Ends
        
        //Old code
        Set<String> setOfCDI = new Set<String>();
        //Get all linked files from Package and Package Elements
        for(ContentDocumentLink cdl:[SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: listOfLinkedEntities]){
            setOfCDI.add(cdl.ContentDocumentId);
        }
        //Add Package Elements Files
    	if(setOfCDI.size() > 0){
            List<ContentDocument> listOfCD= [SELECT Id FROM ContentDocument WHERE Id IN: setOfCDI];
            if(listOfCD != null && !listOfCD.isEmpty()){
                deleteRecords.addAll(listOfCD);
            }
        }
        //Delete All records 
        //delete deleteRecords;
        
        Database.DeleteResult[] results = Database.delete(deleteRecords, false);
        
        // Iterate through each returned result
        for(Database.DeleteResult dr : results) {
            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted package with ID: ' + dr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Package/Related Record fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
}