public with sharing class ScheduleProcessTopicAutomation implements Schedulable {

    public Integer batchSize = 1;

    public void execute(SchedulableContext sc) {
        BatchProcessTopicAutomation batchProcess = new BatchProcessTopicAutomation();
        Database.executeBatch(batchProcess, batchSize);
    }
}