/**
 * @description       : test class for CaseForCaseVehicleTriggerHelper.cls / CaseTriggerUtil.cls / CaseTriggerHandler.cls 
 * @author            : bseong@haeaus.com
 * @group             : 
 * @last modified on  : 08-18-2023
 * @last modified by  : bseong@haeaus.com
**/
@isTest
public class CaseForCaseVehicleTriggerHelperTest {

    static testMethod void setData() {
        List<HMAReferenceData__c> hmaReferenceDataList =new List<HMAReferenceData__c>();
        for(Integer i=0; i<2; i++){
            HMAReferenceData__c newHMAReference = CMT_DataFactory.createHMAReferencee();
            newHMAReference.ExternalKey__c = 'testtest' + String.valueOf(i);
            newHMAReference.Year__c = String.valueOf(2021+i);
            hmaReferenceDataList.add(newHMAReference);
        }
        insert hmaReferenceDataList;

        VIN__c testVin = CMT_DataFactory.createVin();
        testVin.VIN_External_ID__c = '8S2DA10NU048949';
        insert testVin;

        Case testCase = CMT_DataFactory.createCase();
        testCase.FirstReportSource__c = 'SIMS';
        testCase.VIN_Text_Field__c = '8S2DA10NU048949';
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();
        testCase.CompanyName__c = 'HMA';
        testCase.CountrySubmitterWorks__c = 'Canada';
        testCase.SCSCaseRegion__c = 'North America';
        testCase.Haveyoupreviouslyreportedtheissues__c = 'No';
        testCase.RecordTypeId = recordTypeId;
        testCase.SCSCaseNumber__c = 'Test1';       
        insert testCase;

        Map<Id, Case> casesMapForTest = new Map<Id, Case>();

        Test.startTest();

            casesMapForTest.put(testCase.Id, testCase);
            CaseForCaseVehicleTriggerHelper.caseForCaseVehicle(casesMapForTest);

            testCase.VIN_Text_Field__c = 'test';
            testCase.CaseID__c = '8S2DA10NU048949';
            CaseForCaseVehicleTriggerHelper.caseForCaseVehicle(casesMapForTest);

            delete testCase;
        Test.stopTest();

    }



}