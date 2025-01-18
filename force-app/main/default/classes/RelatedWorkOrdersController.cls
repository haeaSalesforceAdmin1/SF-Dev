public without sharing class RelatedWorkOrdersController {
    @AuraEnabled
    public static String getRelatedWorkOrders(Id caseId) {
        List<WorkOrder> woList = new List<WorkOrder>();
        List<Case> clist = [SELECT SCSCaseNumber__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
        String caseNumber = clist[0].SCSCaseNumber__c;
        for (WorkOrder wo : [SELECT Id, WorkOrderNumber, Lab_Request_Number__c, Phase__c, Status FROM WorkOrder 
                                WHERE Safety_Case_Number__c = :caseNumber 
                                WITH SECURITY_ENFORCED
                                ORDER BY WorkOrderNumber asc]) {
            woList.add(wo);
        }
        return JSON.serializePretty(woList);
    }
}