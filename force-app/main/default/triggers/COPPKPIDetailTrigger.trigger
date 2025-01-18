/**
     * [Class Description] COPPKPIDetail Trigger
     * Created by [MinheeKim] on [2024-10-01] for [DPM-5700] COPP Project
    */ 
    trigger COPPKPIDetailTrigger on COPPKPIDetail__c (before insert, before update, after insert, after update) {
        Trigger_Framework.createHandler(COPPKPIDetail__c.sObjectType);
    }