@isTest
public with sharing class girPreCheckControllerTest {
    private enum Similarity {Exact, Partial, Different}

    static void makeData(Similarity howSimilar){

        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('NASDA').getRecordTypeId();
        Case c = new Case();
        c.Subject = 'Test Hyundai G80 Car';
        c.Description = 'Hyundai G80';
        c.Make__c = 'Hyundai';
        c.VehicleModel__c = 'G80';
        c.MY__c = '2021';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMA';                               
        c.CountrySubmitterWorks__c = 'United States';                  
        c.SCSCaseRegion__c = 'North America';                           
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';
        c.MethodofRepair__c = 'Changed Hyundai G80 Engine';
        c.IncidentswithFires__c = '10';
        c.Drivetrain__c = 'REAR WHEEL DRIVE';
        c.PossiblyAssociablePrimaryHazard__c = 'Difficulty/inability to control direction/path (steering, stability, etc.)';
        c.CategoryofComponentAffected__c = 'Brakes';
        c.Trans__c = 'Auto';
        c.Engine__c = '5.0L V8 DOHC GDI Tau';
        c.ModelCode__c = 'DH';
        insert c;

    }


    @isTest
    static void myUnitTest() {

        makeData(Similarity.Partial);
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        girPreCheckController.getAffectedOffiesPickListValue(c.Id);
        girPreCheckController.getGirRequiredPickListValue(c.Id);
        Test.stopTest();
    }
}