/*
 * _______________________________________________________________________________________________________
 * Description: Invocable class to clone package. This will be called from Screen flow
 * _______________________________________________________________________________________________________
 * @author          Bhavana
 * @version         1.0
 * @created         30/11/2023
 * @input			String recordId and List<PackageElement__c>
 * @output			NA
 * ________________________________________________________________________________________________________
 */
public class DNAMSPackageClone {
    @InvocableMethod(label='Package Clone Invocable Apex' description='Invocable apex to clone package' iconName='slds:standard:output')
    public static void clonePackages(List<InvocableInput> requests){
        Set<String> setOfClonnedPackageElementIds = new Set<String>();
        Set<String> setOfOriginalPackageElementIds = new Set<String>();
        for(PackageElement__c clonnedPkgRecord:requests[0].updatedPackageElements){
            setOfClonnedPackageElementIds.add(clonnedPkgRecord.Id);
            setOfOriginalPackageElementIds.add(clonnedPkgRecord.OriginalPackageElementId__c);
        }
        //Call Future Method
        //DNAMSClonePackageElementsFiles.processClonePackageElements(requests[0].recordId, setOfClonnedPackageElementIds, setOfOriginalPackageElementIds);
        //Call 
        ID jobId = System.enqueueJob(new DNAMSClonePackageElementsFilesQueueable(requests[0].recordId, setOfClonnedPackageElementIds, setOfOriginalPackageElementIds, UserInfo.getUserId()));
        System.debug('BR=jobId='+jobId);
    }
    
    public class InvocableInput {
    
        @InvocableVariable(label='Cloned Package Record Id')
        public String recordId;
    	
        @InvocableVariable(label='Cloned Package Elements Records')
        public List<PackageElement__c> updatedPackageElements;
    }
}