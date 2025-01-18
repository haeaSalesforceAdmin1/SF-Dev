/**
* @description : STIL Project
* @author San, Kang : SanKang@autoeveramerica.com 
*/
@IsTest
public with sharing class WorkOrderTriggerHandlerTest {
    static WorkOrder makeWorkOrder() {
        WorkOrder wo = new WorkOrder();
        wo.Description = 'Testing...';
        wo.Makes__c = 'Hyundai';
        wo.Model_Years__c = '2018';
        wo.Models__c = 'ELANTRA';
        wo.Report_Review_Comments__c = 'Test Comments';
        return wo;
    }

    @TestSetup
    static void makeData(){
        Case oneCase = CMT_DataFactory.createCase();
        Database.SaveResult caseSr = Database.insert(oneCase, false);
        Id caseId;
        if(caseSr.isSuccess()){
            System.debug('Successfully inserted WO. WO ID: ' + caseSr.getId());
            caseId = caseSr.getId();
        } 
        
        
        WorkOrder wo = makeWorkOrder();
        wo.Subject = 'Test1';
        wo.Safety_Case_Number__c = 'TEST-SafetyCaseNumbe';
        wo.Safety_Case_Number__c = 'N-024-0697';
        wo.CaseId = caseId;
        //insert wo;
        Database.SaveResult sr = Database.insert(wo, false);
        if(sr.isSuccess()){
            System.debug('Successfully inserted WO. WO ID: ' + sr.getId());
        }

        Lab_Request_Number_Master__c numMaster = new Lab_Request_Number_Master__c();
        numMaster.Name = '2024';
        numMaster.NextNumber__c = 1;
        insert numMaster;

    }

    @isTest
    static void testUpdateWorkOrder() {
        Test.startTest();
        try{

            WorkOrder woLater = makeWorkOrder();
            woLater.Subject = 'Test2';
            woLater.Safety_Case_Number__c = 'N-024-0697';
            Database.SaveResult srLater = Database.insert(woLater, false);
            if(srLater.isSuccess()){
                System.debug('Successfully inserted WO. WO ID: ' + srLater.getId());
            }

            WorkOrder woLaterWithoutCase = makeWorkOrder();
            woLaterWithoutCase.Subject = 'Test2';
            //woLaterWithoutCase.Safety_Case_Number__c = 'N-024-0697';
            Database.SaveResult srLaterWithoutCase = Database.insert(woLaterWithoutCase, false);
            if(srLaterWithoutCase.isSuccess()){
                System.debug('Successfully inserted WO. WO ID: ' + srLaterWithoutCase.getId());
            }            

            WorkOrder woToUpdate = [SELECT Id, 	Estimated_Test_Start_Date__c FROM WorkOrder Where Phase__c  ='New' Limit 1];
            woToUpdate.Estimated_Test_Start_Date__c = Date.today();
            update woToUpdate;

            // WorkOrder woToUpdate2 = [SELECT Id, 	Estimated_Test_Start_Date__c FROM WorkOrder Where Phase__c  ='New' Limit 1];
            // woToUpdate2.Report_Review_Comments__c = 'NOT UPDATAGBLE FIELD TO MAKE EXCEPTION';
            // update woToUpdate2;


            // wo.Report_Review_Comments__c = 'Update Test Comments';
            // update wo;
        } catch (Exception e) {
            System.debug('ERROR DETAILS ::' + e.getStackTraceString());
        }
        Test.stopTest();
    }
}