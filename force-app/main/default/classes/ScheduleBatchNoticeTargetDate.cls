/**
 * @description       : 
 * @author            : inhokim
 * @group             : 
 * @last modified on  : 02-16-2024
 * @last modified by  : inhokim
**/
public class ScheduleBatchNoticeTargetDate implements Schedulable {
    public void execute(SchedulableContext SC) {
        BatchProcessNoticeTargetDate batch = new BatchProcessNoticeTargetDate();
        Database.executeBatch(batch, 200);
    }   
}
/*
add this apexjob in specific pattern of time 
    String cronExpr = '0 10 0 * * ?';
    String jobName = 'Daily-NoticeVisibilityAutoOff';
    ScheduleBatchNoticeTargetDate scheduler = new ScheduleBatchNoticeTargetDate();    
    System.schedule(jobName, cronExpr, scheduler);
to check if scheduling is activated
    SOQL : SELECT CronTrigger.Id,CronTrigger.CronJobDetail.Name, ApexClass.Name, ApexClass.CreatedBy.Name, ApexClass.LastModifiedBy.Name,CronTrigger.CronExpression ,CreatedDate,CronTriggerId,JobType,LastProcessed,MethodName,Status FROM AsyncApexJob Where Jobtype ='ScheduledApex' ORDER BY CreatedDate desc
if you want to abort job 
    System.abortJob(jobId); 
    */