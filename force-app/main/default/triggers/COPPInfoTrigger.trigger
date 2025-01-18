/**
     * [Class Description] COPPInfo Trigger
     * Created by [MinheeKim] on [2024-09-05] for [DPM-5700] COPP Project
    */ 
trigger COPPInfoTrigger on COPPInfo__c (before insert, before update, after insert, after update) {
    Trigger_Framework.createHandler(COPPInfo__c.sObjectType);
}