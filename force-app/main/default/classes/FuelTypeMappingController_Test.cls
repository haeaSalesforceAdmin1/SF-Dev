@IsTest
public with sharing class FuelTypeMappingController_Test {
    @TestSetup
    static void testSetup(){
        KASO_VIN_Mapping__c obj = new KASO_VIN_Mapping__c();
        obj.FuelType__c = 'fuelType test';
        obj.EngineDesciption__c = 'engine test';
        obj.Engine_Interface_Value__c = 'engine test interface';
        obj.TransmissionDesc__c = 'trans test';
        obj.Transmission_Interface_Value__c = 'trans test interface';
        obj.Model__c = 'model test';
        obj.Model_Interface_Value__c = 'model test interface';
        insert obj;
    }


    @IsTest
    static void testStart(){
        List<KASO_VIN_Mapping__c> listMapping = new List<KASO_VIN_Mapping__c>([
                SELECT  Id, FuelType__c, Engine_Interface_Value__c, Transmission_Interface_Value__c, Model_Interface_Value__c, TransmissionDesc__c, EngineDesciption__c, Model__c, LastModifiedDate, LastModifiedBy.Name
                FROM    KASO_VIN_Mapping__c
                WHERE   Model__c LIKE '%test%'
                LIMIT   1
        ]);

        FuelTypeMappingController.MappingWrapper wrapper = new FuelTypeMappingController.MappingWrapper(listMapping[0]);
        String jsonWrapper = '[';
        jsonWrapper += JSON.serialize(wrapper);
        jsonWrapper +=']';

        Test.startTest();

        FuelTypeMappingController.getKASOVinMappingData('test', false);
        FuelTypeMappingController.saveKASOVinMappingData(jsonWrapper);
        Test.stopTest();
    }


}