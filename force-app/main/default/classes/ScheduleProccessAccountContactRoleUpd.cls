public with sharing class ScheduleProccessAccountContactRoleUpd implements Schedulable {

    public Integer batchSize = 200;
    public DateTime asOfDateTime;

    public ScheduleProccessAccountContactRoleUpd() {
        this.asOfDateTime = DateTime.now();
    }

    public ScheduleProccessAccountContactRoleUpd(DateTime asOfDateTime) {
        this.asOfDateTime = asOfDateTime;
    }

    public void execute(SchedulableContext sc) {
        BatchProccessAccountContactRoleUpdates batchProcess = new BatchProccessAccountContactRoleUpdates(asOfDateTime);
        Database.executeBatch(batchProcess, batchSize);

        System.abortJob(sc.getTriggerId()); 
    }
}