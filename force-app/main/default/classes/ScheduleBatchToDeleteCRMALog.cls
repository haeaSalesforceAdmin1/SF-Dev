/**
 * CUV Adoption
 * A scheduler that executes the BatchToDeleteCRMALog batch class daily at 11:51 PM.
 * Usage:
 * This class is scheduled to run automatically based on a specified Cron expression, typically set to execute during off-peak hours.
 * The actual scheduling of this class should be performed in the Salesforce environment setup or via an Execute Anonymous window,
 * using the System.schedule method with a job name, Cron expression, and an instance of this class.
 * Created by Areum on 2024-02-12.
 */

public with sharing class ScheduleBatchToDeleteCRMALog implements Schedulable {

    private Integer monthsToKeep;

    public ScheduleBatchToDeleteCRMALog() {
        HCUV_Configuration__mdt mdt = [SELECT Value__c FROM HCUV_Configuration__mdt WHERE DeveloperName = 'CRMALog_Retention_Month' LIMIT 1];
        monthsToKeep = mdt != null ? Integer.valueOf(mdt.Value__c) : 12; //default value
    }

    public void execute(SchedulableContext SC) {
        System.debug('ScheduleBatchToDeleteCRMALog monthsToKeep : '+ monthsToKeep);

        BatchToDeleteCRMALog batch = new BatchToDeleteCRMALog(monthsToKeep);
        Database.executeBatch(batch, 200);
    }

    /*
    String cronExpr = '0 51 23 * * ?';
    String jobName = 'Daily CRMALog Cleanup';
    ScheduleBatchToDeleteCRMALog scheduler = new ScheduleBatchToDeleteCRMALog();

    System.schedule(jobName, cronExpr, scheduler);
    */
}