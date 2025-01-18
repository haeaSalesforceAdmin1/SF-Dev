/**
 * @description       : To test multiVehicleCaseController.cls
 * @Created Author    : LJ: liamjeong@haeaus.com
 * @last modified on  : 2023-07-05
 * @last modified by  : LJ: liamjeong@haeaus.com
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   2023-07-05   LJ: liamjeong@haeaus.com   Initial Version
**/
@IsTest
private class multiVehicleCaseControllerTest {
    enum ReferenceType {
        Hyundai, Genesis, Both
    }
    static List<HMAReferenceData__c> makeReferences(ReferenceType rType) {
        List<HMAReferenceData__c> referenceDataList = new List<HMAReferenceData__c>();
        if (rType == ReferenceType.Both || rType == ReferenceType.Hyundai) {
            HMAReferenceData__c HyundaiReferenceData = new HMAReferenceData__c();
            HyundaiReferenceData.Make__c = 'Hyundai';
            HyundaiReferenceData.VehicleModel__c = 'ELANTRA';
            HyundaiReferenceData.Year__c = '2018';
            HyundaiReferenceData.FuelType__c = 'TURBO';
            HyundaiReferenceData.EngineDescription__c = '1.6L I4 Gamma Turbo';
            HyundaiReferenceData.DrivetrainDescription__c = 'FRONT WHEEL DRIVE';
            HyundaiReferenceData.TransmissionDescription__c = 'MANUAL';
            HyundaiReferenceData.ModelCode__c = 'AD';

            referenceDataList.add(HyundaiReferenceData);

        }
        if (rType == ReferenceType.Both || rType == ReferenceType.Genesis) {
            HMAReferenceData__c genesisReferenceData = new HMAReferenceData__c();
            genesisReferenceData.Make__c = 'Genesis';
            genesisReferenceData.VehicleModel__c = 'G80';
            genesisReferenceData.Year__c = '2017';
            genesisReferenceData.FuelType__c = 'GAS';
            genesisReferenceData.EngineDescription__c = '3.8L V6 DOHC GDI Lambda II';
            genesisReferenceData.DrivetrainDescription__c = 'REAR WHEEL DRIVE';
            genesisReferenceData.TransmissionDescription__c = 'AUTO';
            genesisReferenceData.ModelCode__c = 'DH';

            referenceDataList.add(genesisReferenceData);
        }
        return referenceDataList;
    }

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
        return c;
    }

    @IsTest
    static void testGetVehicleMakes() {
        test.startTest(); // Added by LJ
        
        insert makeReferences(ReferenceType.Both);
        insert makeCase();

        String resultStr = multiVehicleCaseController.getVehicleMakes('Hyundai');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == 'Hyundai') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }

        test.stopTest(); // Added by LJ
    }

    @IsTest
    static void testGetVehicleYears() {
        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleYears('Hyundai;Genesis', 'ELANTRA', '2017');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == '2017') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }

        
    }

    @IsTest
    static void testGetVehicleModels() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();
        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleModels('Hyundai;Genesis', 'ELANTRA');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == 'ELANTRA') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }
    }

    @IsTest
    static void testGetVehicleDrivetrains() {
        
        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleDrivetrains('Hyundai;Genesis', '2018', 'ELANTRA', 'AD', 'FRONT WHEEL DRIVE');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == 'FRONT WHEEL DRIVE') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }
    }

    @IsTest
    static void testGetVehicleDrivetrains_NoModelCode() {
        
        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleDrivetrains('Hyundai;Genesis', '2018', 'ELANTRA', '', 'FRONT WHEEL DRIVE');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == 'FRONT WHEEL DRIVE') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }
    }

    @IsTest
    static void testGetVehicleFuelTypes() {
        
        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleFuelTypes('Hyundai;Genesis', '2018', 'ELANTRA', 'AD', 'TURBO');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == 'TURBO') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }
    }

    @IsTest
    static void testGetVehicleFuelTypes_NoModelCode() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleFuelTypes('Hyundai;Genesis', '2018', 'ELANTRA', '', 'TURBO');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == 'TURBO') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }
    }

    @IsTest
    static void testGetVehicleEngines() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleEngines('Hyundai;Genesis', '2018', 'ELANTRA', 'AD', '1.6L I4 Gamma Turbo');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == '1.6L I4 Gamma Turbo') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }
    }

    @IsTest
    static void testGetVehicleEngines_NoModelCode() {
        
        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();
        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleEngines('Hyundai;Genesis', '2018', 'ELANTRA', '', '1.6L I4 Gamma Turbo');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == '1.6L I4 Gamma Turbo') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }
    }

    @IsTest
    static void testGetVehicleTransmissions() {
        
        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();
        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleTransmissions('Hyundai;Genesis', '2018', 'ELANTRA', 'AD', 'MANUAL');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == 'MANUAL') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }
    }

    @IsTest
    static void testGetVehicleTransmissions_NoModelCode() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();
        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleTransmissions('Hyundai;Genesis', '2018', 'ELANTRA', '', 'MANUAL');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == 'MANUAL') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }
    }

    @IsTest
    static void testGetVehicleModelCodes() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();
        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleModelCodes('Hyundai;Genesis', '2018', 'ELANTRA', 'AD');
        List<multiVehicleCaseController.VehicleOptionsWrapper> result = (List<multiVehicleCaseController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleCaseController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleCaseController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == 'AD') {
                System.assert(wrp.isSelected);
            } else {
                System.assert(wrp.isSelected == false);
            }
        }
    }

    @IsTest
    static void testGetVehicleUpdateOptions() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();
        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.getVehicleUpdateOptions('Hyundai;Genesis', '2018', 'ELANTRA', 'FRONT WHEEL DRIVE', 'TURBO', '1.6L I4 Gamma Turbo', 'MANUAL', 'AD');
        multiVehicleCaseController.NewVehiclesWrapper result = (multiVehicleCaseController.NewVehiclesWrapper) JSON.deserialize(resultStr, multiVehicleCaseController.NewVehiclesWrapper.class);

        System.assert(result.make.size() > 0);
        System.assert(result.model.size() > 0);
        System.assert(result.year.size() > 0);
    }

    @IsTest
    static void testSaveAndDeleteVehicles() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();
        test.stopTest(); // Added by LJ

        Case c = [SELECT Id FROM Case LIMIT 1];
        String resultStr = multiVehicleCaseController.saveVehicles(String.valueOf(c.Id), 'Hyundai', '2018', 'ELANTRA', 'FRONT WHEEL DRIVE', 'TURBO', '1.6L I4 Gamma Turbo', 'MANUAL', 'AD');
        List<CaseVehicle__c> cVehicles = [SELECT Id FROM CaseVehicle__c WHERE Case__c = :c.Id AND ModelCode__c = 'AD'];
        System.assertEquals(1, cVehicles.size());
        multiVehicleCaseController.deleteVehicles(String.valueOf(cVehicles[0].Id), c.Id);
        System.assertEquals(0, [SELECT Id FROM CaseVehicle__c WHERE Case__c = :c.Id AND ModelCode__c = 'AD'].size());
    }

    @IsTest
    static void testSaveAndDeleteAllVehicles() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();
        test.stopTest(); // Added by LJ
        
        Case c = [SELECT Id FROM Case LIMIT 1];
        String resultStr = multiVehicleCaseController.saveVehicles(String.valueOf(c.Id), 'Hyundai', '2018', 'ELANTRA', 'FRONT WHEEL DRIVE', 'TURBO', '1.6L I4 Gamma Turbo', 'MANUAL', 'AD');
        List<CaseVehicle__c> cVehicles = [SELECT Id FROM CaseVehicle__c WHERE Case__c = :c.Id AND ModelCode__c = 'AD'];
        System.assertEquals(1, cVehicles.size());
        multiVehicleCaseController.deleteAllVehicles(c.Id);
        System.assertEquals(0, [SELECT Id FROM CaseVehicle__c WHERE Case__c = :c.Id AND ModelCode__c = 'AD'].size());
    }

    @IsTest
    static void testSaveExistingVehicles() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();
        test.stopTest(); // Added by LJ

        Case c = [SELECT Id FROM Case LIMIT 1];
        String resultStr = multiVehicleCaseController.saveVehicles(String.valueOf(c.Id), 'Hyundai', '2018', 'ELANTRA', 'FRONT WHEEL DRIVE', 'TURBO', '1.6L I4 Gamma Turbo', 'MANUAL', 'AD');
        List<CaseVehicle__c> cVehicles = [SELECT Id FROM CaseVehicle__c WHERE Case__c = :c.Id AND ModelCode__c = 'AD'];
        System.assertEquals(1, cVehicles.size());

        // save the existing record
        resultStr = multiVehicleCaseController.saveVehicles(String.valueOf(c.Id), 'Hyundai', '2018', 'ELANTRA', 'FRONT WHEEL DRIVE', 'TURBO', '1.6L I4 Gamma Turbo', 'MANUAL', 'AD');
        cVehicles = [SELECT Id FROM CaseVehicle__c WHERE Case__c = :c.Id AND ModelCode__c = 'AD'];
        System.assertEquals(1, cVehicles.size());
    }

    @IsTest
    static void testUpdateExistingVehicles() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        Case c = makeCase();

        insert c;

        List<CaseVehicle__c> createdCaseVehicles = [SELECT Id FROM CaseVehicle__c WHERE Case__c = :c.Id];
        if (createdCaseVehicles.size() > 0) {
            delete createdCaseVehicles;
        }

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.saveVehicles(String.valueOf(c.Id), 'Hyundai', '2018', 'ELANTRA', '', '', '', '', '');
        List<CaseVehicle__c> cVehicles = [SELECT Id FROM CaseVehicle__c WHERE Case__c = :c.Id];
        System.assertEquals(1, cVehicles.size());

        // save the existing record
        resultStr = multiVehicleCaseController.saveVehicles(String.valueOf(c.Id), 'Hyundai', '2018', 'ELANTRA', 'FRONT WHEEL DRIVE', 'TURBO', '1.6L I4 Gamma Turbo', 'MANUAL', 'AD');
        cVehicles = [SELECT Id,ModelCode__c FROM CaseVehicle__c WHERE Case__c = :c.Id];
        System.assertEquals(1, cVehicles.size());
        System.assertEquals('AD', cVehicles[0].ModelCode__c);
    }

    @IsTest
    static void testSaveMultiReferenceDataMatch() {

        test.startTest(); // Added by LJ
        
        insert makeReferences(ReferenceType.Both);
        insert makeCase();
        HMAReferenceData__c referenceData = new HMAReferenceData__c();
        referenceData.Make__c = 'Hyundai';
        referenceData.VehicleModel__c = 'ELANTRA';
        referenceData.Year__c = '2019';
        referenceData.FuelType__c = 'GAS';
        referenceData.EngineDescription__c = '2.0L I4 NU MPI';
        referenceData.DrivetrainDescription__c = 'FRONT WHEEL DRIVE';
        referenceData.TransmissionDescription__c = 'AUTO';
        referenceData.ModelCode__c = 'AD';

        insert referenceData;

        test.stopTest(); // Added by LJ

        Case c = [SELECT Id FROM Case LIMIT 1];
        String resultStr = multiVehicleCaseController.saveVehicles(String.valueOf(c.Id), 'Hyundai', '2018;2019', 'ELANTRA', 'FRONT WHEEL DRIVE', 'TURBO;GAS', '1.6L I4 Gamma Turbo;2.0L I4 NU MPI', 'MANUAL;AUTO', 'AD');
        List<CaseVehicle__c> cVehicles = [SELECT Id,Make__c,Model__c, VehicleYear__c, ModelCode__c FROM CaseVehicle__c WHERE Case__c = :c.Id AND ModelCode__c = 'AD'];
        System.assertEquals(1, cVehicles.size());
    }

    @IsTest
    static void testGetAffectedVehicles() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeCase();

        Case c = [SELECT Id FROM Case LIMIT 1];

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleCaseController.saveVehicles(String.valueOf(c.Id), 'Hyundai', '2018', 'ELANTRA', 'FRONT WHEEL DRIVE', 'TURBO', '1.6L I4 Gamma Turbo', 'MANUAL', 'AD');
        String affectedVhcStr = multiVehicleCaseController.getAffectedVehicles(c.Id);
        List<multiVehicleCaseController.AffectedVehicleWrapper> affectedVhcLst = (List<multiVehicleCaseController.AffectedVehicleWrapper>) JSON.deserialize(affectedVhcStr, List<multiVehicleCaseController.AffectedVehicleWrapper>.class);
        System.assert(affectedVhcLst.size() > 0);
    }

    @IsTest
    static void testPopulateCaseVehicle() {
        
        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        Case c = makeCase();
        insert c;

        test.stopTest(); // Added by LJ
        
        List<String> idsList = new List<String>();

        idsList.add(c.Id);

        multiVehicleCaseInvocable.populateCaseVehicle(idsList);
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
            String formattedYearsString = CaseVehicleUtil.getFormattedYearsString(yearsStrings[i]);
            System.assertEquals(formattedYearsStrings[i], formattedYearsString);
        }
    }


}