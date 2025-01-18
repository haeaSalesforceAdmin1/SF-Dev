/**
* @description : RRP Project
* @author San, Kang : SanKang@autoeveramerica.com 
*/
@isTest
public with sharing class multiVehicleRRPControllerTest {
    
    static Case makeCase() {
        Case c = new Case();
        c.Subject = 'Testing Batch Case Insert - 11';
        c.Description = 'Testing…';
        c.CompanyName__c = 'HMA';
        c.CountrySubmitterWorks__c = 'United States';
        c.DAPhaseStartDate__c = Date.today();
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.MY__c = '2018';
        c.Make__c = 'Hyundai';
        c.SCSCaseRegion__c = 'Other';
        c.Status = 'Open';
        c.VehicleModel__c = 'ELANTRA';
        c.SCSCaseNumber__c = 'N-024-9999';

        return c;
    }

    static Case makeKASOCase() {
        Case c = new Case();
        c.Subject = 'Testing Batch Case Insert - 11';
        c.Description = 'Testing…';
        c.CompanyName__c = 'HMA';
        c.CountrySubmitterWorks__c = 'United States';
        c.DAPhaseStartDate__c = Date.today();
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.MY__c = '2018';
        c.Make__c = 'Hyundai';
        c.SCSCaseRegion__c = 'Other';
        c.Status = 'Open';
        c.VehicleModel__c = 'ELANTRA';
        c.SCSCaseNumber__c = 'K-024-9999';

        return c;
    }

    static CaseVehicle__c makeCaseVehicle(String CaseId) {
        CaseVehicle__c caseVehicleObj = new CaseVehicle__c();
        caseVehicleObj.Make__c = 'Hyundai';
        caseVehicleObj.VehicleYear__c='2020;2019;2018';
        caseVehicleObj.Model__c='ELANTRA';
        caseVehicleObj.Case__c = CaseId;

        return caseVehicleObj;
    }

    static CaseVehicle__c makeCaseVehicle2(String CaseId) {
        CaseVehicle__c caseVehicleObj = new CaseVehicle__c();
        caseVehicleObj.Make__c = 'Genesis';
        caseVehicleObj.VehicleYear__c='2023';
        caseVehicleObj.Model__c='G70';
        caseVehicleObj.Case__c = CaseId;

        return caseVehicleObj;
    }

    static RRP__c makeRRP() {
        RRP__c rrpObj = new RRP__c();
        //rrpObj.SCS_CaseNumber__c = 'N-024-9999';
        rrpObj.Name ='N-024-9999-RRP';

        return rrpObj;
    }

    static KASOCaseVehicle__c makeKASOCaseVehicle(String CaseId) {
        KASOCaseVehicle__c caseVehicleObj = new KASOCaseVehicle__c();
        caseVehicleObj.Make__c = 'Hyundai';
        caseVehicleObj.VehicleYear__c='2020;2019;2018';
        caseVehicleObj.Model__c='ELANTRA';
        caseVehicleObj.Case__c = CaseId;

        return caseVehicleObj;
    }

    @isTest
    static void testVehicles() {
        test.startTest();
        Case c = makeCase();
        insert c;        
        insert makeCaseVehicle(c.Id);
        RRP__c rrpObj = makeRRP();
        insert rrpObj;

        multiVehicleRRPController.getVehicleRRP(rrpObj.Id);
        test.stopTest();
    }

    @IsTest
    static void testYearStringFormatting() {
        List<String> yearsStrings = new List<String>{
                '2007;2008;2009;2012',
                '2018;2019',
                '2018;2020',
                '2005;2007;2002;2003;2004;2012;2008;2010;2009;',
                '',
                null
        };

        List<String> formattedYearsStrings = new List<String>{
                '2007-2009; 2012',
                '2018-2019',
                '2018; 2020',
                '2002-2005; 2007-2010; 2012',
                '',
                ''
        };

        for (Integer i = 0; i < yearsStrings.size(); i++) {
            String formattedYearsString = multiVehicleRRPController.getFormattedYearsString(yearsStrings[i]);
            System.assertEquals(formattedYearsStrings[i], formattedYearsString);
        }
    }
}