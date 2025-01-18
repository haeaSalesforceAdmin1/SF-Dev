@isTest
public class RelatedCaseTriggerHandlerTest 
{
    
    @IsTest
    public static void testingDeleteRelatedCaseMethod1() {
        

        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMA';
        c.CountrySubmitterWorks__c = 'Canada';
        c.SCSCaseRegion__c = 'North America';
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.TrackingID__c= '73';
c.Origin= 'Value';
c.VIN_Text_Field__c= '5NMS33AD2LH202622';
c.Make__c= 'Hyundai';
c.HazardCategory__c= '1-Difficulty/inability to control direction/path (steering, stability, etc.)';
c.MY__c= '2020';
c.MethodofRepair__c= 'Dealer to replace the engine';
c.Parts__c= '2';
c.PossiblyAssociablePrimaryHazard__c= 'Difficulty/inability to control direction/path (steering, stability, etc.)';
c.Region__c= 'central region';
c.Severity__c= '3';
c.CategoryofComponentAffected__c= 'Engine';
c.ModelCode__c= 'TMA';
c.CompanyName__c= 'HMA';
c.CountrySubmitterWorks__c= 'Korea';
c.Haveyoupreviouslyreportedtheissues__c= 'No';
c.Engine__c='2.4L I4 GDI Theta II';
c.Fuel_Type__c='Gas';
c.Related_Cases__c ='test';     

        insert c;
        
        Test.startTest();
		RelatedCase__c r = new RelatedCase__c();
        r.Case__c=c.Id;
        r.Type__c='related to';
        r.RelatedCase__c=c.Id;
        insert r;
		try
			{
				Delete 	r;
			}
			catch(Exception ee)
			{}
            Test.stopTest();
     }
    
    @IsTest
    public static void testingDeleteRelatedCaseMethod2() {
        

        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMA';
        c.CountrySubmitterWorks__c = 'Canada';
        c.SCSCaseRegion__c = 'North America';
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.TrackingID__c= '73';
c.Origin= 'Value';
c.VIN_Text_Field__c= '5NMS33AD2LH202622';
c.Make__c= 'Hyundai';
c.HazardCategory__c= '1-Difficulty/inability to control direction/path (steering, stability, etc.)';
c.MY__c= '2020';
c.MethodofRepair__c= 'Dealer to replace the engine';
c.Parts__c= '2';
c.PossiblyAssociablePrimaryHazard__c= 'Difficulty/inability to control direction/path (steering, stability, etc.)';
c.Region__c= 'central region';
c.Severity__c= '3';
c.CategoryofComponentAffected__c= 'Engine';
c.ModelCode__c= 'TMA';
c.CompanyName__c= 'HMA';
c.CountrySubmitterWorks__c= 'Korea';
c.Haveyoupreviouslyreportedtheissues__c= 'No';
c.Engine__c='2.4L I4 GDI Theta II';
c.Fuel_Type__c='Gas';
c.Related_Cases__c ='';     

        insert c;
     Test.startTest();
	    RelatedCase__c r = new RelatedCase__c();
        r.Case__c=c.Id;
        r.Type__c='related to';
        r.RelatedCase__c=c.Id;
        insert r;
		try
			{
				Delete 	r;
			}
			catch(Exception ee)
			{}
            Test.stopTest();
     }
}