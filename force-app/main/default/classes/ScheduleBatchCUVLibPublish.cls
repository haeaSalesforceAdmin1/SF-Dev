/**
************************************************************************************************
* @classname         : ScheduleBatchCUVLibPublish;
* @description       : Used to run HCUVcorpLibraryBatch - PublishBatch
* @author            : Inho Kim
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       25th Jul 2024          Inho Kim             CCSOM-59        Initial Version
************************************************************************************************
**/
public class ScheduleBatchCUVLibPublish implements Schedulable{
        public void execute(SchedulableContext SC) {
            BatchProcessCUVcorpLibraryFilePublish batch = new BatchProcessCUVcorpLibraryFilePublish();
            Database.executeBatch(batch, 200);
        }   
    }
    
    /*
    add this apexjob in specific pattern of time 
    
        //for test
        //String cronExpr = '/5 * * * *  ';   
        //prod
        String cronExpr = '0 10 0 * * ?';// every 00:10 AM 
        String jobName = 'Daily-NoticeVisibilityAutoOff';
        ScheduleBatchCUVLibPublish scheduler = new ScheduleBatchCUVLibPublish();    
        System.schedule(jobName, cronExpr, scheduler);
    to check if scheduling is activated
        SOQL : SELECT CronTrigger.Id,CronTrigger.CronJobDetail.Name, ApexClass.Name, ApexClass.CreatedBy.Name, ApexClass.LastModifiedBy.Name,CronTrigger.CronExpression ,CreatedDate,CronTriggerId,JobType,LastProcessed,MethodName,Status FROM AsyncApexJob Where Jobtype ='ScheduledApex' ORDER BY CreatedDate desc
    if you want to abort job 
        System.abortJob(jobId); 
        */