/**
* Scheduler of BatchRollOverCarryOverAPToNextQuarter Batch class.
* @author Vinit [IBM]
* @creation 17th Sept 2021
* @Test Class BatchRollOverCarryOverApiTest

*/
public class SchedulerRollOverCarryOverAPToNextQtr implements Schedulable {


    public Integer batchSize = 1;
    public String query;

    public void execute(SchedulableContext SC) {
        query = NULL;
        BatchRollOverCarryOverAPToNextQuarter btch = new BatchRollOverCarryOverAPToNextQuarter(query);
        Database.executeBatch(btch, batchSize);
    }
}

/**
SchedulerRollOverCarryOverAPToNextQtr rollOver = new SchedulerRollOverCarryOverAPToNextQtr();
String cronexpression = '0 0 0 ? * * *';
System.schedule('Roll Over Carry Over AP To Next Quarter', cronexpression, rollOver);
 */