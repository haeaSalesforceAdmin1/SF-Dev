public with sharing class CloseDpmrEvalBatch implements Database.Batchable<SObject> {
    // 1. Query the records to be processed
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date today = System.today();
        Date endOfLastMonth = today.toStartOfMonth().addDays(-1);
        
        String query = 'SELECT Id FROM Evaluation__c ' +
                       'WHERE RecordType.DeveloperName LIKE \'%DPMR%\' ' +
                       'AND DPMR_Status__c = \'Open\' ' +
                       'AND PrimaryContactDate__c  <= :endOfLastMonth';
        
        return Database.getQueryLocator(query);
    }

    // 2. Process each batch of records
    public void execute(Database.BatchableContext bc, List<Evaluation__c> scope) {
        if(scope.size() > 0) {
            for (Evaluation__c eval : scope) {
                eval.DPMR_Status__c = 'Closed'; // Update status to Closed
            }
            // Perform the update operation
            try {
                update scope;
            } catch (DmlException e) {
                // Log the DML exception
                System.debug('DML Exception: ' + e.getMessage());
                // Optionally, send an email alert or notification
            }
        }
    }

    // 3. Finish any post-processing operations
    public void finish(Database.BatchableContext bc) {
        System.debug('CloseDpmrEvalBatch job finished successfully.');
    }
}