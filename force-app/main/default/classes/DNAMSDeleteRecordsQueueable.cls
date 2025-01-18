public class DNAMSDeleteRecordsQueueable implements Queueable {
	private String packageRecordId;
    public static Boolean disableEnqueueJobForTest = false;
    
    public DNAMSDeleteRecordsQueueable(String recordId){
        System.debug('BR=DNAMSDeleteRecordsQueueable=recordId='+recordId);
        this.packageRecordId = recordId;
        System.debug('BR=DNAMSDeleteRecordsQueueable=this.packageRecordId='+this.packageRecordId);
    }
    
    public void execute(QueueableContext context) {
        // Logic to clone records based on packageRecordId
        //Package__c newPackageRecord = [Select Id from Package__c where Id =: packageRecordId];
        /*Map<Id,PackageElement__c> mapOfSourcePackageElements = new Map<Id, PackageElement__c>([
            SELECT Id
            FROM PackageElement__c 
            WHERE Package__c=:packageRecordId 
        ]);
        */    
        // Delete Package Record
        // Schedule the next job to delete the source files
        if(!disableEnqueueJobForTest){
        	//System.enqueueJob(new DNAMSDeletePackageRecordQueueable(packageRecordId,mapOfSourcePackageElements));
        	System.enqueueJob(new DNAMSDeletePackageRecordQueueable(packageRecordId));
        }
        
    }
}