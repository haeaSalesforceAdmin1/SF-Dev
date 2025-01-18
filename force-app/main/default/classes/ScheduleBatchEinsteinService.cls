public with sharing class ScheduleBatchEinsteinService implements Schedulable {

    public Integer batchSize = 1;

    public void execute(SchedulableContext sc) {

        BatchEinsteinService2 batchProcess = new BatchEinsteinService2();
        batchProcess.dailyBatchProcess = true;
        Database.executeBatch(batchProcess, batchSize);

        System.abortJob(sc.getTriggerId());
    }
}