public class DNAMSAdditionalEmails {
    @InvocableMethod(label='Get Additional Emails Invocable Apex' description='Invocable apex to get the Additional Emails' iconName='slds:standard:output')
    public static List<List<String>> addAdditionalEmails(List<List<String>> requests){
    	List<String> setOfAdditionalEmails = new List<String>();
        Set<String> setOfIds= new Set<String>();
        for(List<String> listOfIds:requests){
            for(String input:listOfIds){
                setOfIds.add(input);
            }
        }
        for(Package__c clonnedPkgRecord:[Select Id, AdditionalCCForInitiateToDealers__c FROM Package__c WHERE Id IN: setOfIds]){
            if(clonnedPkgRecord.AdditionalCCForInitiateToDealers__c != null && clonnedPkgRecord.AdditionalCCForInitiateToDealers__c != ''){
                String emailAddresses = clonnedPkgRecord.AdditionalCCForInitiateToDealers__c;
                emailAddresses=emailAddresses.remove('[');
                emailAddresses=emailAddresses.remove(']');
                for(String emailId: emailAddresses.split(',')){
                	 setOfAdditionalEmails.add(emailId);	   
                }
            }
        }
        
        List<List<String>> bulkResults = new List<List<String>>();
        bulkResults.add(setOfAdditionalEmails);
        return bulkResults;
    }
    
}