public with sharing class ScheduleProcessActionPlanSnapshots implements Schedulable {

    public Integer batchSize = 1;

    public void execute(SchedulableContext sc) {
        BatchProcessActionPlanSnapshots batchProcess = new BatchProcessActionPlanSnapshots();
        Database.executeBatch(batchProcess, batchSize);
    }
}