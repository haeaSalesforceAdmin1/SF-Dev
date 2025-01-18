/**
 * Created by dw.lee on 2023-10-17.
 */

@IsTest
public with sharing class HMCReferenceDataMapping_tr_Test {

    @TestSetup
    static void setupData(){
        HMCReferenceData__c objHmcReferenceData = new HMCReferenceData__c();
        objHmcReferenceData.Make__c = 'Hyundai';
        objHmcReferenceData.CBU_CKD__c = 'CBU';
        objHmcReferenceData.ProdCorp__c = 'HMMA(현대미국생산법인)';
        objHmcReferenceData.VehicleType__c = '승용(Passenger)';
        objHmcReferenceData.VehicleModel__c = '(YFa) YF SONATA [IN]';
        objHmcReferenceData.ModelCode__c = 'YFA';
        objHmcReferenceData.EngineDescription__c = 'θ-Ⅱ 2.0(TGDI)';
        objHmcReferenceData.TransmissionDescription__c = 'A6MF2';
        insert objHmcReferenceData;
    }

    @IsTest
    static void runTest_Model(){
        HMCReferenceDataMapping__c objMapping_A = new HMCReferenceDataMapping__c();
        objMapping_A.InterfaceValue__c = '(YFa) YF SONATA [IN]';
        objMapping_A.ChangeValue__c = '';
        objMapping_A.Field__c = 'VehicleModel__c';
        insert objMapping_A;

        Test.startTest();
        objMapping_A.ChangeValue__c = 'SONATA';
        update objMapping_A;
        Test.stopTest();
    }

    @IsTest
    static void runTest_Engine(){
        HMCReferenceDataMapping__c objMapping_B = new HMCReferenceDataMapping__c();
        objMapping_B.InterfaceValue__c = 'θ-Ⅱ 2.0(TGDI)';
        objMapping_B.ChangeValue__c = '';
        objMapping_B.Field__c = 'EngineDescription__c';
        insert objMapping_B;

        Test.startTest();
        objMapping_B.ChangeValue__c = 'TGDI';
        update objMapping_B;
        Test.stopTest();
    }

    @IsTest
    static void runTest_Transmission(){
        HMCReferenceDataMapping__c objMapping_C = new HMCReferenceDataMapping__c();
        objMapping_C.InterfaceValue__c = 'A6MF2';
        objMapping_C.ChangeValue__c = '';
        objMapping_C.Field__c = 'TransmissionDescription__c';
        insert objMapping_C;

        Test.startTest();
        objMapping_C.ChangeValue__c = 'A6MF1';
        update objMapping_C;
        Test.stopTest();
    }
}