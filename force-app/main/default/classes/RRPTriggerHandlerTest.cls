/**
* @description : RRP Project
* @author San, Kang : SanKang@autoeveramerica.com 
*/
@isTest
public with sharing class RRPTriggerHandlerTest {
    
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

    static CaseVehicle__c makeCaseVehicle(String CaseId) {
        CaseVehicle__c caseVehicleObj = new CaseVehicle__c();
        caseVehicleObj.Make__c = 'Hyundai';
        caseVehicleObj.VehicleYear__c='2018';
        caseVehicleObj.Model__c='ELANTRA';
        caseVehicleObj.Case__c = CaseId;

        return caseVehicleObj;
    }

    static RRP__c makeRRP() {
        RRP__c RRPObj = new RRP__c();
        //RRPObj.SCS_CaseNumber__c = 'N-024-9999';
        RRPObj.Name ='N-024-9999-RRP';

        return RRPObj;
    }
    
    @isTest
    static void testVehicles() {
        Test.startTest();
        try {
            Case c = makeCase();
            insert c;
            insert makeCaseVehicle(c.Id);
            RRP__c RRPObj1 = makeRRP();
            insert RRPObj1;
            RRPObj1.PartName__c='test';
            update RRPObj1;
        } catch (Exception err) {
            System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
        }
        Test.stopTest();
    }
    static RRPDocument__c makeRRPDocument() {
        RRPDocument__c RRPDocumentobj = new RRPDocument__c();
        RRPDocumentobj.Name ='test';
        RRPDocumentobj.Folder__c ='Data';
        return RRPDocumentobj;
    }

    static RRPValidationDocument__c makeRRPValidationDocument() {
        RRPValidationDocument__c RRPValidationDocumentObj = new RRPValidationDocument__c();
        RRPValidationDocumentObj.Name = 'test';
        RRPValidationDocumentObj.Folder__c ='Data';
        return RRPValidationDocumentObj;
    }

    static ISEQCDocument__c makeISEQDocument() {
        ISEQCDocument__c ISEQCDocumenObj = new ISEQCDocument__c();
        ISEQCDocumenObj.Name = 'test';
        ISEQCDocumenObj.Folder__c ='Data';
        return ISEQCDocumenObj;
    }

    @isTest
    static void testRRPDocument() {
        Test.startTest();
        try {
            Case c = makeCase();
            insert c;
            insert makeCaseVehicle(c.Id);
            RRP__c RRPObj = makeRRP();
            insert RRPObj;
            RRPDocument__c RRPDocumentobj = makeRRPDocument();
            RRPDocumentobj.RRP__c =RRPObj.Id;
            insert RRPDocumentobj;
            RRPDocumentobj.Name = 'Testtest';
            update RRPDocumentobj;
            delete RRPDocumentobj;

        } catch (Exception err) {
            System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
        }
        Test.stopTest();
    }
    @isTest
    static void testRRPValidationDocument() {
        Test.startTest();
        try {
            Case c = makeCase();
            insert c;
            insert makeCaseVehicle(c.Id);
            RRP__c RRPObj = makeRRP();
            insert RRPObj;
            RRPValidationDocument__c RRPValidationDocumentobj = makeRRPValidationDocument();
            RRPValidationDocumentObj.RRP__c =RRPObj.Id;
            insert RRPValidationDocumentobj;
            RRPValidationDocumentobj.Name = 'Testtest';
            update RRPValidationDocumentobj;
            delete RRPValidationDocumentobj;

        } catch (Exception err) {
            System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
        }
        Test.stopTest();
    }
    @isTest
    static void testISEQDocument() {
        Test.startTest();
        try {
            Case c = makeCase();
            insert c;
            insert makeCaseVehicle(c.Id);
            RRP__c RRPObj = makeRRP();
            insert RRPObj;
            ISEQCDocument__c ISEQDocumentobj = makeISEQDocument();
            ISEQDocumentobj.RRP__c =RRPObj.Id;
            insert ISEQDocumentobj;
            ISEQDocumentobj.Name = 'Testtest';
            update ISEQDocumentobj;
            delete ISEQDocumentobj;
        } catch (Exception err) {
            System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
        }
        Test.stopTest();
    }
}