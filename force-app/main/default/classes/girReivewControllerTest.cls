/**
 * @description       : GIR Reivew의 Clone Regions 값을 Flow로 Return
 * @author            : ahyoung@hyundai-autoever.com
 * @group             : Hyundai-autoever
 * @last modified on  : 09-08-2023
**/
@isTest
public class girReivewControllerTest {
    
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
        c.Other_Safety_Office_Potentially_Affected__c = 'KASO';
        c.GIR_clone_regions__c = 'KASO';
        insert c;

    }
    
	@isTest
    static void getPickListValuesIntoListTest() {

        makeData(Similarity.Partial);
        Case c = [SELECT Id, GIR_clone_regions__c FROM Case LIMIT 1];
        List<String> selectedValueStringTest = new List<String>();
        selectedValueStringTest.add(c.GIR_clone_regions__c);
        Test.startTest();
        girReivewController.getPickListValuesIntoList(c.Id);
        girReivewController.getPickListValuesIntoList(c.Id);
        girReivewController.getSelectClonRegion(selectedValueStringTest);
        girReivewController.getSelectOtherSafetyOffice(c.Id);
        Test.stopTest();
    }
}