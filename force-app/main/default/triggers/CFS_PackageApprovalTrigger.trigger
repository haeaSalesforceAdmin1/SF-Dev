/* Automatically created by the Conga Contracts configurator */
trigger CFS_PackageApprovalTrigger on Package__c (before update,after update) {
    if (APXT_Redlining.TriggerSetting.isEnabled('Package.ApprovalTrigger')) {
        APXT_Redlining.apxt_clauseApprovals_triggerAction clauseApprovals = new APXT_Redlining.apxt_clauseApprovals_triggerAction();
        if (clauseApprovals.shouldRun()) {
            clauseApprovals.doAction();
        }
    }
    //Added for DNA-757
    Trigger_Framework.createHandler(Package__c.SObjectType);
}