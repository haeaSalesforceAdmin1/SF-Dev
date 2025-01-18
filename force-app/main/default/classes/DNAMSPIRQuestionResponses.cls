public class DNAMSPIRQuestionResponses {
    @AuraEnabled(cacheable=true)
    public static List<PIRQnResponse__c> getPIRResponses(Id pirId) {
        System.debug('PIR Record Id: ' + pirId); 
        List<PIRQnResponse__c> responses = [
            SELECT Id, PIR_Question__r.Question__c, Response__c, Section__c 
            FROM PIRQnResponse__c 
            WHERE Package_Initiation_Request__c = :pirId
        ];
        System.debug('Responses found: ' + responses.size());    
        return responses.isEmpty() ? new List<PIRQnResponse__c>() : responses;
    }
    
    @AuraEnabled
    public static void saveResponses(List<PIRQnResponse__c> updatedResponses) {
        if (updatedResponses == null || updatedResponses.isEmpty()) {
            throw new AuraHandledException('No responses provided for update.');
        } 

        List<PIRQnResponse__c> responsesToUpdate = new List<PIRQnResponse__c>();
        
        for (PIRQnResponse__c response : updatedResponses) {
            if (response.Id == null) {
                throw new AuraHandledException('Response ID cannot be null.');
            }
          
            responsesToUpdate.add(new PIRQnResponse__c(Id=response.Id, Response__c=response.Response__c));
        }

        try {
            if (!responsesToUpdate.isEmpty()) {
                update responsesToUpdate; 
            } 
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating responses: ' + e.getMessage());
        }
    }
}