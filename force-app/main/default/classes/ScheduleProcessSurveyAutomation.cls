public with sharing class ScheduleProcessSurveyAutomation implements Schedulable {

    public Integer batchSize = 1;

    public void execute(SchedulableContext sc) {
        BatchProcessTopicSurveyAutomation batchProcess = new BatchProcessTopicSurveyAutomation();
        Database.executeBatch(batchProcess, batchSize);
    }
}