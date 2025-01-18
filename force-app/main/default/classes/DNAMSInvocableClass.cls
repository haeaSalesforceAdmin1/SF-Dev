/*
 * _______________________________________________________________________________________________________
 * Description: DNAMSInvocableClass class to delete package record. This will be called from Screen flow
 * _______________________________________________________________________________________________________
 * @author          Bhavana
 * @version         1.0
 * @created         05/02/2024
 * @input      		String recordId
 * @output      	NA
 * ________________________________________________________________________________________________________
 */
public class DNAMSInvocableClass {
	@InvocableMethod(label='DNAMS Invocable Class' description='Invocable apex to delete records' iconName='slds:standard:output')
    public static void invoke(List<InvocableInput> requests){
        /*
        //Call Quable Class to schedule a quueable job to delete the records
        if(Test.isRunningTest()){
            DNAMSDeleteRecordsQueueable.disableEnqueueJobForTest = true;
        }*/
        ID jobId = System.enqueueJob(new DNAMSDeleteRecordsQueueable(requests[0].recordId));
        System.debug('BR=DNAMSDeletePackageRecord=jobId='+jobId);
    }
    
    public class InvocableInput {
    
        @InvocableVariable(label='Delete Package Record Id')
        public String recordId;

    }
}