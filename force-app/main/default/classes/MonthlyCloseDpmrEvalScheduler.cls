public with sharing class MonthlyCloseDpmrEvalScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Execute the batch class
        CloseDpmrEvalBatch batch = new CloseDpmrEvalBatch();
        Database.executeBatch(batch);
    }
}