/**
    * [Class Description] Scheduler to copy flag from COPPInfo to Account
    * Created by [MinheeKim] on [2024-10-07] for [DPM-5701]
    */
    public class COPPInfoToAccountScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        COPPInfoToAccountBatch batch = new COPPInfoToAccountBatch();
        Database.executeBatch(batch, 200);  
    }
}