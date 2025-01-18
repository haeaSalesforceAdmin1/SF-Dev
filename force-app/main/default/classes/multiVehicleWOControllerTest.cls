@IsTest
private class multiVehicleWOControllerTest {
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
            HyundaiReferenceData.ModelCode__c = 'AD';

            referenceDataList.add(HyundaiReferenceData);

        }
        if (rType == ReferenceType.Both || rType == ReferenceType.Genesis) {
            HMAReferenceData__c genesisReferenceData = new HMAReferenceData__c();
            genesisReferenceData.Make__c = 'Genesis';
            genesisReferenceData.VehicleModel__c = 'G80';
            genesisReferenceData.Year__c = '2017';
            genesisReferenceData.ModelCode__c = 'DH';

            referenceDataList.add(genesisReferenceData);
        }
        return referenceDataList;
    }

    static WorkOrder makeWO() {
       WorkOrder wo = new WorkOrder();
       wo.Subject = 'Test STIL Project';
       wo.Description = 'Testing...';
       wo.Makes__c = 'Hyundai';
       wo.Model_Years__c = '2018';
       wo.Models__c = 'ELANTRA';
       wo.Report_Review_Comments__c = 'Test Comments';
       wo.Safety_Case_Number__c='test';
       wo.FailureDescAndRequestedTesting__c = '1';
       wo.Formal_Report_Requested__c = true;
       wo.Issue_being_Investigated__c = '1';
       wo.Part_Identification__c = '1';
       wo.Requested_Completion_Date__c = date.today();
       wo.Retain_Parts_Until__c = date.today();

       return wo;
    }

    @IsTest
    static void testGetVehicleMakes() {
        test.startTest(); // Added by LJ
        
        insert makeReferences(ReferenceType.Both);
        insert makeWO();

        String resultStr = multiVehicleWOController.getVehicleMakes('Hyundai');
        List<multiVehicleWOController.VehicleOptionsWrapper> result = (List<multiVehicleWOController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleWOController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleWOController.VehicleOptionsWrapper wrp : result) {
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
        insert makeWO();

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleWOController.getVehicleYears('Hyundai;Genesis', 'ELANTRA', '2017');
        List<multiVehicleWOController.VehicleOptionsWrapper> result = (List<multiVehicleWOController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleWOController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleWOController.VehicleOptionsWrapper wrp : result) {
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
        insert makeWO();
        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleWOController.getVehicleModels('Hyundai;Genesis', 'ELANTRA');
        List<multiVehicleWOController.VehicleOptionsWrapper> result = (List<multiVehicleWOController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleWOController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleWOController.VehicleOptionsWrapper wrp : result) {
            if (wrp.value == 'ELANTRA') {
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
        insert makeWO();
        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleWOController.getVehicleModelCodes('Hyundai;Genesis', '2018', 'ELANTRA', 'AD');
        List<multiVehicleWOController.VehicleOptionsWrapper> result = (List<multiVehicleWOController.VehicleOptionsWrapper>) JSON.deserialize(resultStr, List<multiVehicleWOController.VehicleOptionsWrapper>.class);
        System.assert(result.size() > 0);
        for (multiVehicleWOController.VehicleOptionsWrapper wrp : result) {
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
        insert makeWO();
        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleWOController.getVehicleUpdateOptions('Hyundai;Genesis', '2018', 'ELANTRA', 'AD');
        multiVehicleWOController.NewVehiclesWrapper result = (multiVehicleWOController.NewVehiclesWrapper) JSON.deserialize(resultStr, multiVehicleWOController.NewVehiclesWrapper.class);

        System.assert(result.make.size() > 0);
        System.assert(result.model.size() > 0);
        System.assert(result.year.size() > 0);
    }

    @IsTest
    static void testSaveAndDeleteVehicles() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeWO();
        test.stopTest(); // Added by LJ

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        String resultStr = multiVehicleWOController.saveVehicles(String.valueOf(wo.Id), 'Hyundai', '2018', 'ELANTRA', 'AD', false, null);
        List<LRVehicle__c> LRVehicles = [SELECT Id FROM LRVehicle__c WHERE WorkOrder__c = :wo.Id AND ModelCode__c = 'AD'];
        System.assertEquals(1, LRVehicles.size());
        multiVehicleWOController.deleteVehicles(String.valueOf(LRVehicles[0].Id), wo.Id);
        System.assertEquals(0, [SELECT Id FROM LRVehicle__c WHERE WorkOrder__c = :wo.Id AND ModelCode__c = 'AD'].size());
    }

    @IsTest
    static void testSaveAndDeleteAllVehicles() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeWO();
        test.stopTest(); // Added by LJ
        
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        String resultStr = multiVehicleWOController.saveVehicles(String.valueOf(wo.Id), 'Hyundai', '2018', 'ELANTRA', 'AD',false,null);
        List<LRVehicle__c> LRVehicles = [SELECT Id FROM LRVehicle__c WHERE WorkOrder__c = :wo.Id AND ModelCode__c = 'AD'];
        System.assertEquals(1, LRVehicles.size());
        multiVehicleWOController.deleteAllVehicles(wo.Id);
        System.assertEquals(0, [SELECT Id FROM LRVehicle__c WHERE WorkOrder__c = :wo.Id AND ModelCode__c = 'AD'].size());
    }

    @IsTest
    static void testSaveExistingVehicles() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeWO();
        test.stopTest(); // Added by LJ

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        String resultStr = multiVehicleWOController.saveVehicles(String.valueOf(wo.Id), 'Hyundai', '2018', 'ELANTRA', 'AD',false,null);
        List<LRVehicle__c> LRVehicles = [SELECT Id FROM LRVehicle__c WHERE WorkOrder__c = :wo.Id AND ModelCode__c = 'AD'];
        System.assertEquals(1, LRVehicles.size());

        // save the existing record
        resultStr = multiVehicleWOController.saveVehicles(String.valueOf(wo.Id), 'Hyundai', '2018', 'ELANTRA', 'AD',false,null);
        LRVehicles = [SELECT Id FROM LRVehicle__c WHERE WorkOrder__c = :wo.Id AND ModelCode__c = 'AD'];
        System.assertEquals(1, LRVehicles.size());
    }

    @IsTest
    static void testUpdateExistingVehicles() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        WorkOrder wo = makeWO();

        insert wo;

        List<LRVehicle__c> createdLRVehicles = [SELECT Id FROM LRVehicle__c WHERE WorkOrder__c = :wo.Id];
        if (createdLRVehicles.size() > 0) {
            delete createdLRVehicles;
        }

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleWOController.saveVehicles(String.valueOf(wo.Id), 'Hyundai', '2018', 'ELANTRA','',false,null);
        List<LRVehicle__c> LRVehicles = [SELECT Id FROM LRVehicle__c WHERE WorkOrder__c = :wo.Id];
        System.assertEquals(1, LRVehicles.size());

        // save the existing record
        resultStr = multiVehicleWOController.saveVehicles(String.valueOf(wo.Id), 'Hyundai', '2018', 'ELANTRA',  'AD',false,null);
        LRVehicles = [SELECT Id,ModelCode__c FROM LRVehicle__c WHERE WorkOrder__c = :wo.Id];
        System.assertEquals(1, LRVehicles.size());
        System.assertEquals('AD', LRVehicles[0].ModelCode__c);
    }

    @IsTest
    static void testSaveMultiReferenceDataMatch() {

        test.startTest(); // Added by LJ
        
        insert makeReferences(ReferenceType.Both);
        insert makeWO();
        HMAReferenceData__c referenceData = new HMAReferenceData__c();
        referenceData.Make__c = 'Hyundai';
        referenceData.VehicleModel__c = 'ELANTRA';
        referenceData.Year__c = '2019';
        referenceData.ModelCode__c = 'AD';

        insert referenceData;

        test.stopTest(); // Added by LJ

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        String resultStr = multiVehicleWOController.saveVehicles(String.valueOf(wo.Id), 'Hyundai', '2018;2019', 'ELANTRA', 'AD',false,null);
        List<LRVehicle__c> LRVehicles = [SELECT Id,Make__c,Model__c, VehicleYear__c, ModelCode__c FROM LRVehicle__c WHERE WorkOrder__c = :wo.Id AND ModelCode__c = 'AD'];
        System.assertEquals(1, LRVehicles.size());
    }

    @IsTest
    static void testGetAffectedVehicles() {

        test.startTest(); // Added by LJ

        insert makeReferences(ReferenceType.Both);
        insert makeWO();

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        test.stopTest(); // Added by LJ

        String resultStr = multiVehicleWOController.saveVehicles(String.valueOf(wo.Id), 'Hyundai', '2018', 'ELANTRA', 'AD',false,null);
        String affectedVhcStr = multiVehicleWOController.getAffectedVehicles(wo.Id);
        List<multiVehicleWOController.AffectedVehicleWrapper> affectedVhcLst = (List<multiVehicleWOController.AffectedVehicleWrapper>) JSON.deserialize(affectedVhcStr, List<multiVehicleWOController.AffectedVehicleWrapper>.class);
        System.assert(affectedVhcLst.size() > 0);
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
    }
}