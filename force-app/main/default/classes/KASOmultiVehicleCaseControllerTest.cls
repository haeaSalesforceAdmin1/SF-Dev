@IsTest
private class KASOmultiVehicleCaseControllerTest {
    @TestSetup
    static void testSetup() {
        Case objCase = new Case();
        objCase.Subject = 'Testing Case Insert';
        objCase.Description = 'Testing…';
        objCase.CompanyName__c = 'HMC';
        objCase.CountrySubmitterWorks__c = 'Korea';
        objCase.DAPhaseStartDate__c = Date.today();
        objCase.Haveyoupreviouslyreportedtheissues__c = 'No';
        objCase.MY__c = '2023';
        objCase.Make__c = 'Hyundai';
        objCase.SCSCaseRegion__c = 'Other';
        objCase.Status = 'Open';
        objCase.VehicleModel__c = 'ELANTRA';
        insert objCase;

        List<HMCReferenceData__c> listHmcReferenceDataInsert = new List<HMCReferenceData__c>();
        HMCReferenceData__c HyundaiReferenceData = new HMCReferenceData__c();
        HyundaiReferenceData.CBU_CKD__c = 'CBU';
        HyundaiReferenceData.ProdCorp__c = 'T201';
        HyundaiReferenceData.VehicleType__c = 'T';
        HyundaiReferenceData.VehicleModel__c = 'TEST';
        HyundaiReferenceData.EngineDescription__c = '1.2L TEST TURBO';
        HyundaiReferenceData.ModelCode__c = 'TEST00';
        HyundaiReferenceData.TransmissionDescription__c = 'TEST00';
        HyundaiReferenceData.Make__c = 'TEST00';
        HyundaiReferenceData.Year__c = '2023';
        HyundaiReferenceData.DrivetrainDescription__c = 'TEST00';
        listHmcReferenceDataInsert.add(HyundaiReferenceData);

        insert listHmcReferenceDataInsert;

        KASOCaseVehicle__c objKASOCV = new KASOCaseVehicle__c();
        objKASOCV.Case__c = objCase.Id;
        objKASOCV.Make__c = 'Hyundai';
        objKASOCV.VehicleYear__c = '2010';
        objKASOCV.Model__c = 'Test';
        objKASOCV.FuelType__c = 'Gas';
        objKASOCV.DrivetrainDescription__c = 'ALL TEST DRIVE';
        objKASOCV.EngineDescription__c = 'TEST';
        objKASOCV.TransmissionDescription__c = 'Auto';
        objKASOCV.ModelCode__c = 'true';
        objKASOCV.Need_Review__c = false;
        objKASOCV.CBU_CKD__c = 'CBU';
        objKASOCV.ProdCorp__c = 'T00';
        objKASOCV.VehicleType__c = 'T';
        insert objKASOCV;
    }

    @IsTest
    static void getAffectedVehiclesTest(){
        Id caseId = [
                SELECT  Id, Subject
                FROM    Case
                WHERE   Subject = 'Testing Case Insert'
                LIMIT   1
        ].Id;
        Test.startTest();
        KASOmultiVehicleCaseController.getAffectedVehicles(caseId);
        Test.stopTest();
    }

    @IsTest
    static void getVehicleMakesTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleMakes('Hyundai');
        Test.stopTest();
    }

    @IsTest
    static void getVehicleCBUCKDsTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleCBUCKDs('TEST00', 'CBU');
        Test.stopTest();
    }

    @IsTest
    static void getVehicleProdCorpsTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleProdCorps('TEST00', 'CBU','T201');
        Test.stopTest();
    }

    @IsTest
    static void getVehicleTypesTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleTypes('TEST00', 'CBU', 'T201', 'T');
        Test.stopTest();
    }

    @IsTest
    static void getVehicleYearsTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleYears('TEST00', 'Test', '2023');
        Test.stopTest();
    }

    @IsTest
    static void getVehicleModelsTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleModels('TEST00', 'CBU', 'T201','T','Test');
        Test.stopTest();
    }

    @IsTest
    static void getVehicleModelcodesTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleModelcodes('TEST00', 'CBU', 'T201','T','Test','TEST00');
        Test.stopTest();
    }
    @IsTest
    static void getVehicleDrivetrainsTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleDrivetrains('ALL TEST DRIVE');
        Test.stopTest();
    }
    @IsTest
    static void getVehicleFueltypesTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleFueltypes('TEST00', 'Test','TEST00', 'Gas', 'TEST00', 'TEST00');
        Test.stopTest();
    }
    @IsTest
    static void getVehicleEnginesTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleEngines('TEST00', 'CBU', 'T201','T','Test', 'TEST00','TEST');
        KASOmultiVehicleCaseController.getVehicleEngines('TEST00', 'CBU', 'T201','T','Test', '','TEST');

        Test.stopTest();
    }

    @IsTest
    static void getVehicleTransmissionsTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleTransmissions('TEST00', 'CBU', 'T201','T','Test','TEST00','','test');
        KASOmultiVehicleCaseController.getVehicleTransmissions('TEST00', 'CBU', 'T201','T','Test','','','test');
        Test.stopTest();
    }

    @IsTest
    static void getVehicleUpdateOptionsTest(){
        Test.startTest();
        KASOmultiVehicleCaseController.getVehicleUpdateOptions( 'TEST00', '2010', 'TEST', 'ALL TEST DRIVE', 'Gas', 'TEST', 'Auto', 'true', 'CBU', 'T00', 'T');
        Test.stopTest();
    }

    @IsTest
    static void saveVehiclesTest(){
        Id caseId = [
                SELECT  Id, Subject
                FROM    Case
                WHERE   Subject = 'Testing Case Insert'
                LIMIT   1
        ].Id;

        Test.startTest();
        HMCReferenceData__c HyundaiReferenceData = new HMCReferenceData__c();
        HyundaiReferenceData.CBU_CKD__c = 'cbu';
        HyundaiReferenceData.ProdCorp__c = 't201';
        HyundaiReferenceData.VehicleType__c = 't';
        HyundaiReferenceData.VehicleModel__c = 'test';
        HyundaiReferenceData.EngineDescription__c = '1.2L TEST TURBO';
        HyundaiReferenceData.ModelCode__c = 'test00';
        HyundaiReferenceData.TransmissionDescription__c = 'test00';
        HyundaiReferenceData.Make__c = 'hyundai';
        HyundaiReferenceData.Year__c = '2023';
        HyundaiReferenceData.DrivetrainDescription__c = 'test00';
        insert HyundaiReferenceData;
        KASOmultiVehicleCaseController.saveVehicles(String.valueOf(caseId), 'Hyundai', '2010', 'TEST', 'ALL TEST DRIVE', 'Gas', 'TEST', 'Auto', 'TEST00', 'CBU', 'T201', 'T');
        Test.stopTest();
    }
    @IsTest
    static void getCVMapKeyTest(){
        Id caseId = [
                SELECT  Id, Subject
                FROM    Case
                WHERE   Subject = 'Testing Case Insert'
                LIMIT   1
        ].Id;


        Test.startTest();
        KASOmultiVehicleCaseController.updateCaseVehicleInfo(String.valueOf(caseId));
        Test.stopTest();
    }

    @IsTest
    static void deleteVehiclesTest(){
        Id caseId = [
                SELECT  Id, Subject
                FROM    Case
                WHERE   Subject = 'Testing Case Insert'
                LIMIT   1
        ].Id;

        Id vehicleId = [
                SELECT  Id, DrivetrainDescription__c, EngineDescription__c
                FROM    KASOCaseVehicle__c
                WHERE   DrivetrainDescription__c = 'ALL TEST DRIVE' AND EngineDescription__c = 'TEST'
        ].Id;

        Test.startTest();
        KASOmultiVehicleCaseController.deleteVehicles(String.valueOf(vehicleId), String.valueOf(caseId));
        KASOmultiVehicleCaseController.deleteAllVehicles( String.valueOf(caseId));

        Test.stopTest();
    }
}