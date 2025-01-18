/**
 * Created by dw.lee on 2023-10-17.
 */
@IsTest
public with sharing class KASO_VIN_tr_Test {

    @IsTest
    static void runTest(){
        List<HMCReferenceDataMapping__c> listMapping = new List<HMCReferenceDataMapping__c>();
        HMCReferenceDataMapping__c objMapping_A = new HMCReferenceDataMapping__c();
        objMapping_A.InterfaceValue__c = 'test';
        objMapping_A.ChangeValue__c = 'test_VehicleModel';
        objMapping_A.Field__c = 'VehicleModel__c';
        listMapping.add(objMapping_A);

        HMCReferenceDataMapping__c objMapping_B = objMapping_A.clone();
        objMapping_B.InterfaceValue__c = 'test';
        objMapping_B.ChangeValue__c = 'test_EngineDescription';
        objMapping_B.Field__c = 'EngineDescription__c';
        listMapping.add(objMapping_B);

        HMCReferenceDataMapping__c objMapping_C = objMapping_A.clone();
        objMapping_C.InterfaceValue__c = 'test';
        objMapping_C.ChangeValue__c = 'test_TransmissionDescription';
        objMapping_C.Field__c = 'TransmissionDescription__c';
        listMapping.add(objMapping_C);

        insert listMapping;

        KASO_VIN_Mapping__c objKASOMapping = new KASO_VIN_Mapping__c();
        objKASOMapping.Model__c = 'test';
        objKASOMapping.EngineDesciption__c = 'test';
        objKASOMapping.TransmissionDesc__c = 'test';
        objKASOMapping.FuelType__c = 'test';
        insert objKASOMapping;

        Test.startTest();
        KASO_VIN__c objVIN = new KASO_VIN__c();
        objVIN.ModelDesc__c = 'test';
        objVIN.EngineDesc__c = 'test';
        objVIN.TransmissionDesc__c = 'test';
        insert objVIN;
        Test.stopTest();
    }
}