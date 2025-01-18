trigger STIL_Report_DocumentTrigger on STIL_Report_Document__c (after insert, after update, after delete) {
    Trigger_Framework.createHandler(STIL_Report_Document__c.sObjectType);
}