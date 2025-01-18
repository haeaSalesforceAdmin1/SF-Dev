/**
 * CreateSTILLRVehiclesFromCaseTest
 * Description: TEST CASE FOR CreateSTILLRVehiclesFromCase
 * > ADD testCase_KASO and add update part for testWorkOrder.Safety_Case_Number__c = 'K-024-0000'; INSIDE start ~ stop test block
 * ----- Change Log -----
 * Author : Hayeon Cho / [MM-DD-YYYY] / [Ticket #] / [Change Description] 
 * Author : Inho Kim / [10-07-2024] / [OU24-135] / [ADD LOGIC TO GET KASOCaseVehicle__c, to solve issue - (When creating an LR from LR app or CMT and using safety case with (E, O, or K) prefix, the Affected Vehicles is not populating.) ] 
 * ---------------------------
 */
@isTest
public class CreateSTILLRVehiclesFromCaseTest {
    @testSetup
    static void setupTestData() {
        // Create a test Case
        Case testCase = new Case(
            SCSCaseNumber__c = 'N-024-0000',
            Status = 'New',
            Origin = 'Phone'
        );
        insert testCase;

        Profile p = [SELECT Id,name FROM Profile WHERE name='System Administrator' LIMIT 1];
        UserRole uRole = [SELECT Id FROM UserRole WHERE Name LIKE '%KASO%' LIMIT 1];
        User newUser = new User(
        //UserRoleId = '00E3I000000Nfj9',
        profileId = p.Id,
        userRoleId = uRole.Id,
        username = 'newUser1@y1.com',
        email = 'pb@ff.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname'
        );

        Case testCase_KASO;
        // Create a test Case KASO +  Case_Own_Org__c : KASO 
        User kasoUser = [SELECT ID FROM USER WHERE UserRole.Name LIKE '%KASO%' AND IsActive =TRUE LIMIT 1];
        System.runAs(kasoUser){
            System.debug('kasoUser : ' + kasoUser);
            testCase_KASO = new Case(
                SCSCaseNumber__c = 'K-024-0000',
                Status = 'New',
                //Case_Own_Org__c = 'KASO', //IF(CONTAINS(Owner:User.UserRole.Name, "KASO") || CONTAINS(Owner:Queue.QueueName, "KASO"), "KASO", "NASO")
                Origin = 'Phone'
            );
            insert testCase_KASO;
        }
        





        // Create a test WorkOrder NASO
        WorkOrder testWorkOrder = new WorkOrder(
            CaseId = testCase.Id,
            Safety_Case_Number__c = 'N-024-0000',
            Status = 'New'
        );
        insert testWorkOrder;

        
        // Create test CaseVehicle records
        List<CaseVehicle__c> caseVehicles = new List<CaseVehicle__c>();
        for (Integer i = 0; i < 3; i++) {
            CaseVehicle__c cv = new CaseVehicle__c(
                Case__c = testCase.Id,
                Make__c = 'Make ' + i,Model__c = 'Model ' + i,VehicleYear__c = String.valueof(2020 + i),ModelCode__c = 'MC' + i
            );
            caseVehicles.add(cv);
        }
        insert caseVehicles;


        // Create test CaseVehicle records  ( KASOCaseVehicle__c ) 
        List<KASOCaseVehicle__c> caseVehicles_KASO = new List<KASOCaseVehicle__c>();
        for (Integer i = 0; i < 3; i++) {
            KASOCaseVehicle__c cv = new KASOCaseVehicle__c(
                Case__c = testCase_KASO.Id,
                Make__c = 'Make ' + i,Model__c = 'Model ' + i,VehicleYear__c = String.valueof(2020 + i),ModelCode__c = 'MC' + i
            );
            caseVehicles_KASO.add(cv);
        }
        insert caseVehicles_KASO;
    }

    @isTest
    static void testCreateSTILLRVehiclesFromCase() {
        // Get the test WorkOrder Id
        WorkOrder testWorkOrder = [SELECT Id,CaseId,Safety_Case_Number__c FROM WorkOrder LIMIT 1];

        // Call the method
        List<Id> workOrderIds = new List<Id> { testWorkOrder.Id };
        Test.startTest();
        CreateSTILLRVehiclesFromCase.CreateSTILLRVehiclesFromCase(workOrderIds);
        //Test.stopTest();
        
        // Verify that LRVehicle records are created
        List<LRVehicle__c> lrvList = [SELECT WorkOrder__c, Make__c, Model__c, VehicleYear__c, ModelCode__c FROM LRVehicle__c WHERE WorkOrder__c = :testWorkOrder.Id];
        
        System.assertEquals(3, lrvList.size(), 'Expected 3 LRVehicle records to be created');
        
        // Verify that the details match
        for (Integer i = 0; i < 3; i++) {
            LRVehicle__c lrv = lrvList[i];
            System.assertEquals('Make ' + i, lrv.Make__c, 'Make does not match');
            System.assertEquals('Model ' + i, lrv.Model__c, 'Model does not match');
            System.assertEquals(String.valueOf(2020 + i), lrv.VehicleYear__c, 'VehicleYear does not match');
            System.assertEquals('MC' + i, lrv.ModelCode__c, 'ModelCode does not match');
        }

        //Test.startTest();
        testWorkOrder.Safety_Case_Number__c = 'K-024-0000';
        
        update testWorkOrder;
        CreateSTILLRVehiclesFromCase.CreateSTILLRVehiclesFromCase(workOrderIds);
        Test.stopTest();
    }
}