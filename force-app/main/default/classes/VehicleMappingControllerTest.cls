@IsTest
public with sharing class VehicleMappingControllerTest {
    @TestSetup
    static void testSetup(){
        HMCReferenceDataMapping__c objMapping = new HMCReferenceDataMapping__c();
        objMapping.Field__c = 'VehicleModel__c';
        objMapping.InterfaceValue__c = 'Test Model Data';
        objMapping.ChangeValue__c = 'Test Change Model Data';
        insert objMapping;

    }

    @IsTest
    static void testStart(){
        List<HMCReferenceDataMapping__c> objMapping = new List<HMCReferenceDataMapping__c>([
                SELECT  Id, Name, Field__c, InterfaceValue__c, ChangeValue__c, LastModifiedBy.Name, LastModifiedDate
                FROM    HMCReferenceDataMapping__c
                WHERE   Field__c =: 'VehicleModel__c' AND ChangeValue__c = 'Test Change Model Data'
                LIMIT   1
        ]);

        VehicleMappingController.MappingWrapper wrapper = new VehicleMappingController.MappingWrapper(objMapping[0]);
        String jsonWrapper = '[';
        jsonWrapper += JSON.serialize(wrapper);
        jsonWrapper +=']';

        Test.startTest();
        VehicleMappingController.getFieldLabelInfo();
        VehicleMappingController.getListHMCMappingInfo('VehicleModel__c', 'Test', true);
        VehicleMappingController.updateMappingData(jsonWrapper, 'VehicleModel__c');
        Test.stopTest();
    }
}