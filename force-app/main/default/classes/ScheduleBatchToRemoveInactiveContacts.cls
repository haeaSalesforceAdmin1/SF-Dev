/**
* Scheduler of BatchToRemoveInactiveContacts Batch class.
* @author Vinit [IBM]
* @creation 29th Sept 2021
*/
public with sharing class ScheduleBatchToRemoveInactiveContacts implements Schedulable{

    public Integer batchSize = 1;
    public String query;

    public void execute(SchedulableContext sc) {

        BatchToRemoveInactiveContacts batchJob = new BatchToRemoveInactiveContacts(query);
        Database.executeBatch(batchJob, batchSize);
    }
}

/**
ScheduleBatchToRemoveInactiveContacts cleanUp = new ScheduleBatchToRemoveInactiveContacts();
String cronexpression = '0 0 0 ? * * *';
System.schedule('Clean-up Inactive Account Contact Relationships and Contact Records', cronexpression, cleanUp);
 */