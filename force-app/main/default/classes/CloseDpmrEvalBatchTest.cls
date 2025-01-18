/* [Component Description] Test class for CloseDpmrEvalBatch
* Created by [Jonghoon Kim] on [2024-08-05] for [DPM-5663]
*/
@isTest
private class CloseDpmrEvalBatchTest {
    
    @isTest
    static void testCloseDpmrEvalBatch() {
        // 1. Set up test data
        Date today = System.today();
        Date endOfLastMonth = today.toStartOfMonth().addDays(-1);
        
        // Create record types needed for the test
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'DPMR_Sales_Dealer_Performance_Management_Report_Internal_Confidential' LIMIT 1];
        
        // Create Evaluation records
        List<Evaluation__c> evals = new List<Evaluation__c>{
            new Evaluation__c(
                Name = 'Test Evaluation 1',
                RecordTypeId = rt.Id,
                DPMR_Status__c = 'Open',
                PrimaryContactDate__c = endOfLastMonth
            ),
            new Evaluation__c(
                Name = 'Test Evaluation 2',
                RecordTypeId = rt.Id,
                DPMR_Status__c = 'Open',
                PrimaryContactDate__c = endOfLastMonth.addDays(-10)
            ),
            new Evaluation__c(
                Name = 'Test Evaluation 3',
                RecordTypeId = rt.Id,
                DPMR_Status__c = 'Open',
                PrimaryContactDate__c = today
            )
        };
        insert evals;
        
        // 2. Execute the batch class
        Test.startTest();
        CloseDpmrEvalBatch batch = new CloseDpmrEvalBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // 3. Verify the results
        List<Evaluation__c> updatedEvals = [SELECT Id, DPMR_Status__c, PrimaryContactDate__c FROM Evaluation__c WHERE Id IN :evals];
        for (Evaluation__c eval : updatedEvals) {
            if (eval.PrimaryContactDate__c <= endOfLastMonth) {
                System.assertEquals('Closed', eval.DPMR_Status__c, 'Record status should be Closed.');
            } else {
                System.assertEquals('Open', eval.DPMR_Status__c, 'Record status should remain Open.');
            }
        }
    }
    
    @isTest
    static void testMonthlyCloseDpmrEvalScheduler() {
        // 1. Set up test data (same as above)
        Date today = System.today();
        Date endOfLastMonth = today.toStartOfMonth().addDays(-1);
        
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'DPMR_Sales_Dealer_Performance_Management_Report_Internal_Confidential' LIMIT 1];
        
        List<Evaluation__c> evals = new List<Evaluation__c>{
            new Evaluation__c(
                Name = 'Test Evaluation 1',
                RecordTypeId = rt.Id,
                DPMR_Status__c = 'Open',
                PrimaryContactDate__c = endOfLastMonth
            ),
            new Evaluation__c(
                Name = 'Test Evaluation 2',
                RecordTypeId = rt.Id,
                DPMR_Status__c = 'Open',
                PrimaryContactDate__c = endOfLastMonth.addDays(-10)
            ),
            new Evaluation__c(
                Name = 'Test Evaluation 3',
                RecordTypeId = rt.Id,
                DPMR_Status__c = 'Open',
                PrimaryContactDate__c = today
            )
        };
        insert evals;
        
        // 2. Execute the scheduler
        Test.startTest();
        MonthlyCloseDpmrEvalScheduler scheduler = new MonthlyCloseDpmrEvalScheduler();
        scheduler.execute(null);
        Test.stopTest();
        
        // 3. Verify the results
        List<Evaluation__c> updatedEvals = [SELECT Id, DPMR_Status__c, PrimaryContactDate__c FROM Evaluation__c WHERE Id IN :evals];
        for (Evaluation__c eval : updatedEvals) {
            if (eval.PrimaryContactDate__c <= endOfLastMonth) {
                System.assertEquals('Closed', eval.DPMR_Status__c, 'Record status should be Closed.');
            } else {
                System.assertEquals('Open', eval.DPMR_Status__c, 'Record status should remain Open.');
            }
        }
    }
}