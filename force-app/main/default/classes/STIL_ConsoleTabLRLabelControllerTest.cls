/**
* @description : Changed Lab Request Detail page Tab Name
* @author San, Kang : SanKang@autoeveramerica.com | 2024-07-31
* @tecket no: OU24-127
*/
@isTest
 public class STIL_ConsoleTabLRLabelControllerTest {

     @isTest static void Test() {
        WorkOrder testWorkOrder1 = new WorkOrder();
        testWorkOrder1.Safety_Case_Number__c = 'C-001';
        testWorkOrder1.Phase__c = 'New';
        testWorkOrder1.Status = 'Open';
        testWorkOrder1.Lab_Request_Number__c ='test1';
        
        insert testWorkOrder1;

        Test.startTest();
        STIL_ConsoleTabLRLabelController.getLRObj(testWorkOrder1.Id);
        Test.stopTest();
 
     }
 }