public with sharing class ScheduleRollOverActionPlans implements Schedulable {

    public Integer batchSize = 1;
    public String query;
    public Integer monthsToAdd = 1;

    public void execute(SchedulableContext sc) {

        BatchRollOverActionPlans batchJob = new BatchRollOverActionPlans();
        batchJob.query = query;
        batchJob.monthsToAdd = monthsToAdd;
        Database.executeBatch(batchJob, batchSize);
    }
}