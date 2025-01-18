@isTest
private without sharing class RelatedWorkOrdersControllerTest {

    @isTest
    static void testGetRelatedWorkOrders() {
        // Create a Case
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.SCSCaseNumber__c = 'C-001';
        insert testCase;

        // Create Work Orders associated with the Case
        WorkOrder testWorkOrder1 = new WorkOrder();
        testWorkOrder1.Safety_Case_Number__c = 'C-001';
        testWorkOrder1.Phase__c = 'New';
        testWorkOrder1.Status = 'Open';
        insert testWorkOrder1;

        WorkOrder testWorkOrder2 = new WorkOrder();
        testWorkOrder2.Safety_Case_Number__c = 'C-001';
        testWorkOrder2.Phase__c = 'Report Generation';
        testWorkOrder2.Status = 'Closed';
        insert testWorkOrder2;

        // Call the method to test
        Test.startTest();
        String result = RelatedWorkOrdersController.getRelatedWorkOrders(testCase.Id);
        Test.stopTest();

        // Deserialize the JSON result
        List<WorkOrder> woList = (List<WorkOrder>) JSON.deserialize(result, List<WorkOrder>.class);

        // Assertions
        System.assertEquals(2, woList.size());
        System.assertEquals('New', woList[0].Phase__c, 'Phase check');
        System.assertEquals('Report Generation', woList[1].Phase__c, 'Phase check');
        System.assertEquals('Open', woList[0].Status, 'Status check');
        System.assertEquals('Closed', woList[1].Status, 'Status check');
    }

}