/**
 * @description       : test class for CaseDuplicateHelper.cls / CaseTriggerUtil.cls 
 * @author            : bseong@haeaus.com
 * @group             : 
 * @last modified on  : 08-18-2023
 * @last modified by  : bseong@haeaus.com
**/
@isTest
public class CaseDuplicateHelperTest {
    static testMethod void setData() {

        List<HMAReferenceData__c> hmaReferenceDataList =new List<HMAReferenceData__c>();
        for(Integer i=0; i<2; i++){
            HMAReferenceData__c newHMAReference = CMT_DataFactory.createHMAReferencee();
            newHMAReference.ExternalKey__c = 'testtest' + String.valueOf(i+1);
            newHMAReference.Year__c = String.valueOf(2021+i);
            hmaReferenceDataList.add(newHMAReference);
        }
        insert hmaReferenceDataList;


        List<VIN__c> vinListForTest = new List<VIN__c>();

        VIN__c testVin1 = CMT_DataFactory.createVin();
        testVin1.VIN_External_ID__c = 'caseDuplicateTest1';
        vinListForTest.add(testVin1);

        VIN__c testVin3 = CMT_DataFactory.createVin();
        testVin3.VIN_External_ID__c = 'caseDuplicateTest3';
        vinListForTest.add(testVin3);

        VIN__c testVin4 = CMT_DataFactory.createVin();
        testVin4.EngineDesc__c = 'HEV 1.6 (Kappa)';
        testVin4.FuelType__c = 'Turbo';
        testVin4.VIN_External_ID__c = 'caseDuplicateTest4';
        vinListForTest.add(testVin4);     

        for(Integer i=0; i<3; i++){  //testVin5,6,7
            VIN__c testVin = CMT_DataFactory.createVin();
            testVin.Make__c = 'Genesis';
            if(i==2){       testVin.PQMSModelCode__c = 'DH';}
            if(i==0){       testVin.ModelYear__c = '2021'; }
            else if(i==1){  testVin.ModelYear__c = '2023'; }
            else{           testVin.ModelYear__c = '2026';}
            testVin.EngineDesc__c = '88kw (118hp)';
            testVin.FuelType__c = 'Turbo';
            testVin.VIN_External_ID__c = 'caseDuplicateTest' + String.valueOf(i+5);
            vinListForTest.add(testVin);  
        }
        insert vinListForTest;


        List<Case> testCaseList = new List<Case>();
        Case testCase1_1 = CMT_DataFactory.createCase();
        testCase1_1.VIN_Text_Field__c = 'caseDuplicateTest1';
        testCase1_1.ModelCode__c = 'DN8A';
        testCase1_1.SIMS_GSI_Number__c = 'caseDuplicateTest1_1';
        testCaseList.add(testCase1_1);

        Case testCase1_2 = CMT_DataFactory.createCase();
        testCase1_2.FirstReportSource__c = 'Common SEL';
        testCase1_2.VIN_Text_Field__c = 'caseDuplicateTest1';
        testCase1_2.ModelCode__c = 'DN8A';
        testCase1_2.SIMS_GSI_Number__c = 'caseDuplicateTest1_2';
        testCaseList.add(testCase1_2);

        for(Integer i=0; i<2; i++){ //testCase2_1, 2_2
            Case testCase = CMT_DataFactory.createCase();
            testCase.VIN_Text_Field__c = 'caseDuplicateTest2';
            testCase.SIMS_GSI_Number__c = 'caseDuplicateTest2_' + String.valueOf(i+1);
            testCaseList.add(testCase);
        }


        for(Integer i=0; i<5; i++){
            Case testCase = CMT_DataFactory.createCase();
            testCase.VIN_Text_Field__c = 'caseDuplicateTest'+String.valueOf(i+3);
            if(i==2 || i==3) testCase.MY__c = '2021';
            else testCase.MY__c = '2022';
            testCase.SIMS_GSI_Number__c = 'caseDuplicateTest'+String.valueOf(i+3);
            testCaseList.add(testCase);  
        }

        Test.startTest();
            CaseDuplicateHelper.checkCaseDupl(testCaseList);
        Test.stopTest();
    }
}