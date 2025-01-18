/*
 * _______________________________________________________________________________________________________
 * Description: Invocable class to delete package and its related records. This will be called from Screen flow
 * _______________________________________________________________________________________________________
 * @author          Bhavana
 * @version         1.0
 * @created         22/03/2024
 * @input			String recordId
 * @output			NA
 * ________________________________________________________________________________________________________
 */
public class DNAMSDeletePackageAndRelatedRecords {
	@InvocableMethod(label='DNAMS Delete Invocable Apex' description='Invocable apex to delete package and related records' iconName='slds:standard:output')
    public static void deletePackages(List<InvocableInput> requests){
        //DNAMSClonePackageElementsFiles.processClonePackageElements(requests[0].recordId, setOfClonnedPackageElementIds, setOfOriginalPackageElementIds);
        //Call 
        ID jobId = System.enqueueJob(new DNAMSDeletePackageRecordQueueable(requests[0].recordId));
		System.debug('BR=DNAMSDeletePackageAndRelatedRecords==deletePackages==requests[0].recordId='+requests[0].recordId);
        System.debug('BR=DNAMSDeletePackageAndRelatedRecords==deletePackages==jobId='+jobId);
    }
    
    public class InvocableInput {
    
        @InvocableVariable(label='Delete Package Record Id')
        public String recordId;
    	
    }
}