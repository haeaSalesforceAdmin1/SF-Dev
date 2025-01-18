/**********************************************************************
* Name : CaseVehicleTriggerHandlerTest
* Author: Pratz Joshi
* Description : Apex Test Class which Tests that the Case.VehicleInfo__c field 
* is updated with the Make/Model/Year info from CaseVehicle__c record/s created through
* SODAS Integration
* Project : SODAS/CMT Integration
* Date Created : 06/16/2022
**********************************************************************/
@isTest
public class CaseVehicleTriggerHandlerTest {
	@isTest static void createCaseVechicle(){
        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMA';
        c.CountrySubmitterWorks__c = 'Canada';
        c.SCSCaseRegion__c = 'North America';
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';
        Insert c;
        
        CaseVehicle__c cv = new CaseVehicle__c();
        cv.Case__c = c.Id;
        cv.Make__c = 'Genesis';
        cv.Model__c = 'G90';
        cv.VehicleYear__c = '2022';
        
        INSERT cv;
        integer count=[select count() from CaseVehicle__c];
        system.assertEquals(1,count);
        system.assertNotEquals('', c.VehicleInfo__c);
    }
}