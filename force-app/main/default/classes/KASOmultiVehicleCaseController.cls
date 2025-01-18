public class KASOmultiVehicleCaseController {
    @AuraEnabled
    public static String getAffectedVehicles(Id caseId) {
        List<AffectedVehicleWrapper> affectedVehiclesWrapper = new List<AffectedVehicleWrapper>();
        for (KASOCaseVehicle__c affectedVhc : [
                SELECT
                        Id, Name, Case__c, Make__c,
                        VehicleYear__c, Model__c, FuelType__c,
                        DrivetrainDescription__c, EngineDescription__c,
                        TransmissionDescription__c, ModelCode__c, Notes__c,
                        Need_Review__c, CBU_CKD__c, ProdCorp__c, VehicleType__c
                FROM KASOCaseVehicle__c
                WHERE Case__c = :caseId
        ]) {
            AffectedVehicleWrapper vhcWrapper = new AffectedVehicleWrapper();
            vhcWrapper.id = affectedVhc.Id;
            vhcWrapper.notes = affectedVhc.Notes__c;
            vhcWrapper.needReview = affectedVhc.Need_Review__c;
            // Vehicle Make Options
            if (affectedVhc.Make__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.Make__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    options.add(currentOptionWrapper);
                    vpwWrapper.selectedValue = str;
                }
                vpwWrapper.options = options;
                vhcWrapper.make = vpwWrapper;
            }
            // Vehicle Model Options
            if (affectedVhc.Model__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.Model__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    vpwWrapper.selectedValue = str;
                    options.add(currentOptionWrapper);
                }
                vpwWrapper.options = options;
                vhcWrapper.model = vpwWrapper;
            }
            // Vehicle Year Options
            if (affectedVhc.VehicleYear__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.VehicleYear__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    options.add(currentOptionWrapper);
                }
                vpwWrapper.options = options;
                vhcWrapper.year = vpwWrapper;

                vhcWrapper.formattedYear = CaseVehicleUtil.getFormattedYearsString(affectedVhc.VehicleYear__c);
            }
            // Vehicle Fuel Type Options
            if (affectedVhc.FuelType__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.FuelType__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    options.add(currentOptionWrapper);
                }
                vpwWrapper.options = options;
                vhcWrapper.fuelType = vpwWrapper;
            }
            // Vehicle Drivetrain Options
            if (affectedVhc.DrivetrainDescription__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.DrivetrainDescription__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    options.add(currentOptionWrapper);
                }
                vpwWrapper.options = options;
                vhcWrapper.drivetrain = vpwWrapper;
            }
            // Vehicle Engine Options
            if (affectedVhc.EngineDescription__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.EngineDescription__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    options.add(currentOptionWrapper);
                }
                vpwWrapper.options = options;
                vhcWrapper.engine = vpwWrapper;
            }
            // Vehicle transmission Options
            if (affectedVhc.TransmissionDescription__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.TransmissionDescription__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    options.add(currentOptionWrapper);
                }
                vpwWrapper.options = options;
                vhcWrapper.transmission = vpwWrapper;
            }
            // Vehicle model code Options
            if (affectedVhc.ModelCode__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.ModelCode__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    options.add(currentOptionWrapper);
                }
                vpwWrapper.options = options;
                vhcWrapper.modelCode = vpwWrapper;
            }

            // Vehicle CBU_CKD Options
            if (affectedVhc.CBU_CKD__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.CBU_CKD__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    options.add(currentOptionWrapper);
                }
                vpwWrapper.options = options;
                vhcWrapper.CBUCKD = vpwWrapper;
            }
            // Vehicle ProdCorp Options
            if (affectedVhc.ProdCorp__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.ProdCorp__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    options.add(currentOptionWrapper);
                }
                vpwWrapper.options = options;
                vhcWrapper.prodCorp = vpwWrapper;
            }
            // Vehicle VehicleType Options
            if (affectedVhc.VehicleType__c <> null) {
                VehiclePropertyWrapper vpwWrapper = new VehiclePropertyWrapper();
                List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
                List<String> strList = String.valueOf(affectedVhc.VehicleType__c).split(';');
                for (String str : strList) {
                    VehicleOptionsWrapper currentOptionWrapper = new VehicleOptionsWrapper();
                    currentOptionWrapper.isSelected = true;
                    currentOptionWrapper.label = str;
                    currentOptionWrapper.value = str;
                    options.add(currentOptionWrapper);
                }
                vpwWrapper.options = options;
                vhcWrapper.vehicleType = vpwWrapper;
            }

            affectedVehiclesWrapper.add(vhcWrapper);
        }

        return JSON.serializePretty(affectedVehiclesWrapper);
    }

    @AuraEnabled
    public static String getVehicleMakes(String selectedMakes) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            Set<String> selectedVhcMakesLst;
            if (String.isNotEmpty(selectedMakes)) {
                selectedVhcMakesLst = new Set<String> (selectedMakes.split(';'));
            }
            List<AggregateResult> vehicleMakes = [SELECT Make__c, COUNT(Name) FROM HMCReferenceData__c GROUP BY Make__c ORDER BY Make__c ASC];
            for (AggregateResult make : vehicleMakes) {
                VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                if (selectedVhcMakesLst <> null && selectedVhcMakesLst.contains(String.valueOf(make.get('Make__c')))) {
                    optWrapper.isSelected = true;
                } else {
                    optWrapper.isSelected = false;
                }
                optWrapper.label = String.valueOf(make.get('Make__c'));
                optWrapper.value = String.valueOf(make.get('Make__c'));
                optionsWrapper.add(optWrapper);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleCBUCKDs(String makes, String selectedCBUCKDs) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            Set<String> selectedVhcCBUCKDsLst;
            if (String.isNotEmpty(selectedCBUCKDs)) {
                selectedVhcCBUCKDsLst = new Set<String> (selectedCBUCKDs.split(';'));
            }
            List<AggregateResult> CBUCKDs= [SELECT CBU_CKD__c, COUNT(Name) FROM HMCReferenceData__c WHERE Make__c IN:makesLst GROUP BY CBU_CKD__c ORDER BY CBU_CKD__c ASC];
            for (AggregateResult result : CBUCKDs) {
                if (result.get('CBU_CKD__c') <> null) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (selectedVhcCBUCKDsLst <> null && selectedVhcCBUCKDsLst.contains(String.valueOf(result.get('CBU_CKD__c')))) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('CBU_CKD__c'));
                    optWrapper.value = String.valueOf(result.get('CBU_CKD__c'));
                    optionsWrapper.add(optWrapper);
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleProdCorps(String makes, String CBUCKDs, String selectedProdCorps) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> CBUCKDsLst = CBUCKDs.split(';');
            Set<String> selectedVhcProdCorpsLst;
            if (String.isNotEmpty(selectedProdCorps)) {
                selectedVhcProdCorpsLst = new Set<String> (selectedProdCorps.split(';'));
            }
            List<AggregateResult> prodCorps= [SELECT ProdCorp__c, COUNT(Name) FROM HMCReferenceData__c WHERE Make__c IN:makesLst AND CBU_CKD__c IN:CBUCKDsLst GROUP BY ProdCorp__c ORDER BY ProdCorp__c ASC];
            for (AggregateResult result : prodCorps) {
                if (result.get('ProdCorp__c') <> null) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (selectedVhcProdCorpsLst <> null && selectedVhcProdCorpsLst.contains(String.valueOf(result.get('ProdCorp__c')))) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('ProdCorp__c'));
                    optWrapper.value = String.valueOf(result.get('ProdCorp__c'));
                    optionsWrapper.add(optWrapper);
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleTypes(String makes, String CBUCKDs, String prodCorps, String selectedVehicleTypes) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> CBUCKDsLst = CBUCKDs.split(';');
            List<String> prodCorpsLst = prodCorps.split(';');
            Set<String> selectedVhcTypesLst;
            if (String.isNotEmpty(selectedVehicleTypes)) {
                selectedVhcTypesLst = new Set<String> (selectedVehicleTypes.split(';'));
            }
            List<AggregateResult> vehicleTypes= [SELECT VehicleType__c, COUNT(Name) FROM HMCReferenceData__c WHERE Make__c IN:makesLst AND CBU_CKD__c IN:CBUCKDsLst AND ProdCorp__c IN:prodCorpsLst GROUP BY VehicleType__c ORDER BY VehicleType__c ASC];

            List<String> orderStting = new List<String>{'승용(Passenger)', 'SUV', 'MPV', '소상(Small Commercial)', '버스(Bus)', '트럭(Truck)', '군용(Military)', 'ETC'};

            for(String sorting : orderStting){
                for (AggregateResult result : vehicleTypes) {
                    if (result.get('VehicleType__c') <> null) {

                        if(sorting == result.get('VehicleType__c')){
                            VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                            if (selectedVhcTypesLst <> null && selectedVhcTypesLst.contains(String.valueOf(result.get('VehicleType__c')))) {
                                optWrapper.isSelected = true;
                            } else {
                                optWrapper.isSelected = false;
                            }
                            optWrapper.label = String.valueOf(result.get('VehicleType__c'));
                            optWrapper.value = String.valueOf(result.get('VehicleType__c'));
                            optionsWrapper.add(optWrapper);
                        }

                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleYears(String makes, String models, String selectedYears) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {

            Date today = Date.today();
            Date maxDate = today.addYears(+1);

            Integer startYear = 2000;
            Integer endYear = maxDate.year();

            for(Integer i = endYear; i >= startYear; i--){
                VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                optWrapper.isSelected = false;
                optWrapper.label = String.valueOf(i);
                optWrapper.value = String.valueOf(i);
                optionsWrapper.add(optWrapper);
            }

//            List<String> makesLst = makes.split(';');
//            List<String> modelsLst = models.split(';');
//            Set<String> selectedVhcYearsLst;
//            if (String.isNotEmpty(selectedYears)) {
//                selectedVhcYearsLst = new Set<String> (selectedYears.split(';'));
//            }
//            List<AggregateResult> vehicleModels = [SELECT Year__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND VehicleModel__c IN:modelsLst GROUP BY Year__c ORDER BY Year__c DESC];
//            for (AggregateResult result : vehicleModels) {
//                if (result.get('Year__c') <> null) {
//                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                    if (selectedVhcYearsLst <> null && selectedVhcYearsLst.contains(String.valueOf(result.get('Year__c')))) {
//                        optWrapper.isSelected = true;
//                    } else {
//                        optWrapper.isSelected = false;
//                    }
//                    optWrapper.label = String.valueOf(result.get('Year__c'));
//                    optWrapper.value = String.valueOf(result.get('Year__c'));
//                    optionsWrapper.add(optWrapper);
//                }
//            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleModels(String makes, String CBUCKDs, String prodCorps, String vehicleTypes, String selectedVehicleModels) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> cbuckdLst = CBUCKDs.split(';');
            List<String> prodcorpLst = prodCorps.split(';');
            List<String> vehicletypeLst = vehicleTypes.split(';');

            Set<String> selectedVhcModelsLst;
            if (String.isNotEmpty(selectedVehicleModels)) {
                selectedVhcModelsLst = new Set<String> (selectedVehicleModels.split(';'));
            }
            List<AggregateResult> models = [
                    SELECT VehicleModel__c, COUNT(Name)
                    FROM HMCReferenceData__c
                    WHERE Make__c IN:makesLst
                    AND CBU_CKD__c IN:cbuckdLst
                    AND ProdCorp__c IN:prodcorpLst
                    AND VehicleType__c IN:vehicletypeLst
                    GROUP BY VehicleModel__c ORDER BY VehicleModel__c ASC];
            for (AggregateResult result : models) {
                if (result.get('VehicleModel__c') <> null) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (selectedVhcModelsLst <> null && selectedVhcModelsLst.contains(String.valueOf(result.get('VehicleModel__c')))) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('VehicleModel__c'));
                    optWrapper.value = String.valueOf(result.get('VehicleModel__c'));
                    optionsWrapper.add(optWrapper);
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleModelcodes(String makes, String CBUCKDs, String prodCorps, String vehicleTypes, String models, String selectedModelcodes) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> cbuckdLst = CBUCKDs.split(';');
            List<String> prodcorpLst = prodCorps.split(';');
            List<String> vehicletypeLst = vehicleTypes.split(';');
            List<String> modelsLst = models.split(';');

            Set<String> selectedVhcModelCodesLst;
            if (String.isNotEmpty(selectedModelCodes)) {
                selectedVhcModelCodesLst = new Set<String> (selectedModelCodes.split(';'));
            }
            List<AggregateResult> modelCodes = [
                    SELECT ModelCode__c, COUNT(Name)
                    FROM HMCReferenceData__c
                    WHERE Make__c IN:makesLst
                    AND CBU_CKD__c IN:cbuckdLst
                    AND ProdCorp__c IN:prodcorpLst
                    AND VehicleType__c IN:vehicletypeLst
                    AND VehicleModel__c IN:modelsLst
                    GROUP BY ModelCode__c ORDER BY ModelCode__c ASC
            ];
            for (AggregateResult result : modelCodes) {
                if (result.get('ModelCode__c') <> null) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (selectedVhcModelCodesLst <> null && selectedVhcModelCodesLst.contains(String.valueOf(result.get('ModelCode__c')))) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('ModelCode__c'));
                    optWrapper.value = String.valueOf(result.get('ModelCode__c'));
                    optionsWrapper.add(optWrapper);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleDrivetrains(String selectedDrivetrains) {
        System.debug('Vehicle Drivetrains Params:: ' + selectedDrivetrains);
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            Set<String> selectedVhcDrivetrainsLst;
            if (String.isNotEmpty(selectedDrivetrains)) {
                selectedVhcDrivetrainsLst = new Set<String> (selectedDrivetrains.split(';'));
            }
            
            Schema.DescribeFieldResult fieldResult = HMCReferenceData__c.DrivetrainDescription__c.getDescribe();
            List<Schema.PicklistEntry> drivetrains = fieldResult.getPicklistValues();

            for (Schema.PicklistEntry result : drivetrains) {
               
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (selectedVhcDrivetrainsLst <> null && selectedVhcDrivetrainsLst.contains(result.getValue())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = result.getValue();
                    optWrapper.value = result.getValue();
                    optionsWrapper.add(optWrapper);
                
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }
        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleFueltypes(String makes, String models, String modelcodes, String engines, String transmissions, String selectedFuelTypes) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            Set<String> selectedVhcDrivetrainsLst;
            if (String.isNotEmpty(selectedFuelTypes)) {
                selectedVhcDrivetrainsLst = new Set<String> (selectedFuelTypes.split(';'));
            }

            List<String> modelsLst = models.split(';');

            List<AggregateResult> listFuelMapping = new List<AggregateResult>([
                SELECT  FuelType__c fuelType
                FROM    KASO_VIN_Mapping__c
                WHERE   Model__c IN :modelsLst
                Group By FuelType__c
            ]);

            if(!listFuelMapping.isEmpty()){
                for (AggregateResult result : listFuelMapping) {
                    List<String> strFuelType = String.valueOf(result.get('fuelType')).split(';') ;
                    for(String fuel : strFuelType){
                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                        if (selectedVhcDrivetrainsLst <> null && selectedVhcDrivetrainsLst.contains(fuel)) {
                            optWrapper.isSelected = true;
                        } else {
                            optWrapper.isSelected = false;
                        }
                        optWrapper.label = fuel;
                        optWrapper.value = fuel;
                        optionsWrapper.add(optWrapper);
                    }
                }
            }

//            Set<String> selectedVhcDrivetrainsLst;
//            if (String.isNotEmpty(selectedFuelTypes)) {
//                selectedVhcDrivetrainsLst = new Set<String> (selectedFuelTypes.split(';'));
//            }
//
//            Schema.DescribeFieldResult fieldResult = HMCReferenceData__c.FuelType__c.getDescribe();
//            List<Schema.PicklistEntry> fueltypes = fieldResult.getPicklistValues();
//
//            for (Schema.PicklistEntry result : fueltypes) {
//
//                VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                if (selectedVhcDrivetrainsLst <> null && selectedVhcDrivetrainsLst.contains(result.getValue())) {
//                    optWrapper.isSelected = true;
//                } else {
//                    optWrapper.isSelected = false;
//                }
//                optWrapper.label = result.getValue();
//                optWrapper.value = result.getValue();
//                optionsWrapper.add(optWrapper);
//
//            }
//            List<String> makesLst = makes.split(';');
//            List<String> modelsLst = models.split(';');
//            List<String> modelCodesLst = modelCodes.split(';');
//            Set<String> selectedVhcFuelTypesLst;
//            if (String.isNotEmpty(selectedFuelTypes)) {
//                selectedVhcFuelTypesLst = new Set<String> (selectedFuelTypes.split(';'));
//            }
//            List<AggregateResult> fuelTypes;
//            if (!isEmpty(modelcodes) && modelcodes.trim().length() > 0) {
//                fuelTypes = [SELECT FuelType__c, COUNT(Name) FROM HMCReferenceData__c WHERE Make__c IN:makesLst AND VehicleModel__c IN:modelsLst AND ModelCode__c IN:modelCodesLst GROUP BY FuelType__c ORDER BY FuelType__c ASC];
//            } else {
//                fuelTypes = [SELECT FuelType__c, COUNT(Name) FROM HMCReferenceData__c WHERE Make__c IN:makesLst AND VehicleModel__c IN:modelsLst GROUP BY FuelType__c ORDER BY FuelType__c ASC];
//            }
//
//            for (AggregateResult result : fuelTypes) {
//                if (result.get('FuelType__c') <> null) {
//                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                    if (selectedVhcFuelTypesLst <> null && selectedVhcFuelTypesLst.contains(String.valueOf(result.get('FuelType__c')))) {
//                        optWrapper.isSelected = true;
//                    } else {
//                        optWrapper.isSelected = false;
//                    }
//                    optWrapper.label = String.valueOf(result.get('FuelType__c'));
//                    optWrapper.value = String.valueOf(result.get('FuelType__c'));
//                    optionsWrapper.add(optWrapper);
//                }
//            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleEngines(String makes, String CBUCKDs, String prodCorps, String vehicleTypes, String models, String modelcodes, String selectedEngines) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> cbuckdLst = CBUCKDs.split(';');
            List<String> prodcorpLst = prodCorps.split(';');
            List<String> vehicletypeLst = vehicleTypes.split(';');
            List<String> modelsLst = models.split(';');
            List<String> modelCodesLst = modelCodes.split(';');
            Set<String> selectedVhcEnginesLst;
            if (String.isNotEmpty(selectedEngines)) {
                selectedVhcEnginesLst = new Set<String> (selectedEngines.split(';'));
            }
            List<AggregateResult> engines;
            if (!isEmpty(modelcodes) && modelcodes.trim().length() > 0) {
                engines = [
                        SELECT EngineDescription__c, COUNT(Name)
                        FROM HMCReferenceData__c
                        WHERE Make__c IN:makesLst
                        AND CBU_CKD__c IN:cbuckdLst
                        AND ProdCorp__c IN:prodcorpLst
                        AND VehicleType__c IN:vehicletypeLst
                        AND VehicleModel__c IN:modelsLst
                        AND ModelCode__c IN:modelCodesLst
                        GROUP BY EngineDescription__c
                        ORDER BY EngineDescription__c ASC
                ];
            } else {
                engines = [
                        SELECT EngineDescription__c, COUNT(Name)
                        FROM HMCReferenceData__c
                        WHERE Make__c IN:makesLst
                        AND CBU_CKD__c IN:cbuckdLst
                        AND ProdCorp__c IN:prodcorpLst
                        AND VehicleType__c IN:vehicletypeLst
                        AND VehicleModel__c IN:modelsLst
                        GROUP BY EngineDescription__c
                        ORDER BY EngineDescription__c ASC
                ];
            }
            for (AggregateResult result : engines) {
                if (result.get('EngineDescription__c') <> null) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (selectedVhcEnginesLst <> null && selectedVhcEnginesLst.contains(String.valueOf(result.get('EngineDescription__c')))) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('EngineDescription__c'));
                    optWrapper.value = String.valueOf(result.get('EngineDescription__c'));
                    optionsWrapper.add(optWrapper);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleTransmissions(String makes, String CBUCKDs, String prodCorps, String vehicleTypes, String models, String modelcodes, String engines, String selectedTransmissions) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> cbuckdLst = CBUCKDs.split(';');
            List<String> prodcorpLst = prodCorps.split(';');
            List<String> vehicletypeLst = vehicleTypes.split(';');
            List<String> modelsLst = models.split(';');
            List<String> modelCodesLst = modelCodes.split(';');
            List<String> engineLst = engines.split(';');
            Set<String> selectedVhcTransmissionsLst;
            if (String.isNotEmpty(selectedTransmissions)) {
                selectedVhcTransmissionsLst = new Set<String> (selectedTransmissions.split(';'));
            }
            List<AggregateResult> transmissions;
            if (!isEmpty(modelcodes) && modelcodes.trim().length() > 0) {
                transmissions = [
                        SELECT TransmissionDescription__c, COUNT(Name)
                        FROM HMCReferenceData__c
                        WHERE Make__c IN:makesLst
                        AND CBU_CKD__c IN:cbuckdLst
                        AND ProdCorp__c IN:prodcorpLst
                        AND VehicleType__c IN:vehicletypeLst
                        AND VehicleModel__c IN:modelsLst
                        AND ModelCode__c IN:modelCodesLst
                        AND TransmissionDescription__c != 'N/A'
//                        AND EngineDescription__c IN:engineLst
                        GROUP BY TransmissionDescription__c
                        ORDER BY TransmissionDescription__c ASC
                ];
            } else {
                transmissions = [
                        SELECT TransmissionDescription__c, COUNT(Name)
                        FROM HMCReferenceData__c
                        WHERE Make__c IN:makesLst
                        AND CBU_CKD__c IN:cbuckdLst
                        AND ProdCorp__c IN:prodcorpLst
                        AND VehicleType__c IN:vehicletypeLst
                        AND VehicleModel__c IN:modelsLst
                        AND TransmissionDescription__c != 'N/A'
//                        AND EngineDescription__c IN:engineLst
                        GROUP BY TransmissionDescription__c
                        ORDER BY TransmissionDescription__c ASC
                ];
            }
            for (AggregateResult result : transmissions) {
                if (result.get('TransmissionDescription__c') <> null) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (selectedVhcTransmissionsLst <> null && selectedVhcTransmissionsLst.contains(String.valueOf(result.get('TransmissionDescription__c')))) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('TransmissionDescription__c'));
                    optWrapper.value = String.valueOf(result.get('TransmissionDescription__c'));
                    optionsWrapper.add(optWrapper);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleUpdateOptions(
            String makes
            , String years
            , String models
            , String drivetrains
            , String fueltypes
            , String engines
            , String transmissions
            , String modelcodes
            , String cbuckds
            , String prodcorps
            , String vehicletypes
    ) {
        NewVehiclesWrapper optionsWrapper = new NewVehiclesWrapper();
        try {
            Set<String> makesLst = isEmpty(makes) ? new Set<String>() : new Set<String>(makes.toLowerCase().split(';'));
            Set<String> yearsLst = isEmpty(years) ? new Set<String>() : new Set<String>(years.toLowerCase().split(';'));
            Set<String> modelsLst = isEmpty(models) ? new Set<String>() : new Set<String>(models.toLowerCase().split(';'));
            Set<String> drivetrainsLst = isEmpty(drivetrains) ? new Set<String>() : new Set<String>(drivetrains.toLowerCase().split(';'));
            Set<String> fuelTypesLst = isEmpty(fuelTypes) ? new Set<String>() : new Set<String>(fuelTypes.toLowerCase().split(';'));
            Set<String> enginesLst = isEmpty(engines) ? new Set<String>() : new Set<String>(engines.toLowerCase().split(';'));
            Set<String> transmissionsLst = isEmpty(transmissions) ? new Set<String>() : new Set<String>(transmissions.toLowerCase().split(';'));
            Set<String> modelCodesLst = isEmpty(modelCodes) ? new Set<String>() : new Set<String>(modelCodes.toLowerCase().split(';'));
            Set<String> cbuckdsLst = isEmpty(cbuckds) ? new Set<String>() : new Set<String>(cbuckds.toLowerCase().split(';'));
            Set<String> prodcorpsLst = isEmpty(prodcorps) ? new Set<String>() : new Set<String>(prodcorps.toLowerCase().split(';'));
            Set<String> vehicletypesLst = isEmpty(vehicletypes) ? new Set<String>() : new Set<String>(vehicletypes.toLowerCase().split(';'));

            Set<String> makesLstAdded = new Set<String>();
            Set<String> yearsLstAdded = new Set<String>();
            Set<String> modelsLstAdded = new Set<String>();
            Set<String> drivetrainsLstAdded = new Set<String>();
            Set<String> fuelTypesLstAdded = new Set<String>();
            Set<String> enginesLstAdded = new Set<String>();
            Set<String> transmissionsLstAdded = new Set<String>();
            Set<String> modelCodesLstAdded = new Set<String>();
            Set<String> cbuckdsLstAdded = new Set<String>();
            Set<String> prodcorpsLstAdded = new Set<String>();
            Set<String> vehicletypesLstAdded = new Set<String>();

            List<HMCReferenceData__c> hmaReferenceData;
            if (!isEmpty(modelcodes) && modelcodes.trim().length() > 0) {
                hmaReferenceData = [
                        SELECT  Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c
                                ,CBU_CKD__c, ProdCorp__c, VehicleType__c
                        FROM    HMCReferenceData__c
                        WHERE   Make__c IN:makesLst
                        AND     VehicleModel__c IN:modelsLst
                        AND     CBU_CKD__c IN:cbuckdsLst
                        AND     ProdCorp__c IN:prodcorpsLst
                        AND     VehicleType__c IN:vehicletypesLst
                        AND     ModelCode__c IN:modelCodesLst
                ];
            }
            else {
                hmaReferenceData = [
                        SELECT  Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c
                                ,CBU_CKD__c, ProdCorp__c, VehicleType__c
                        FROM    HMCReferenceData__c
                        WHERE   Make__c IN:makesLst
                        AND     VehicleModel__c IN:modelsLst
                        AND     CBU_CKD__c IN:cbuckdsLst
                        AND     ProdCorp__c IN:prodcorpsLst
                        AND     VehicleType__c IN:vehicletypesLst
                ];
            }

//            List<HMCReferenceData__c> hmaReferenceData = [
//                    SELECT  Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c
//                            ,CBU_CKD__c, ProdCorp__c, VehicleType__c
//                    FROM    HMCReferenceData__c
//                    WHERE   Make__c IN:makesLst
//                    AND     VehicleModel__c IN:modelsLst
//                    AND     CBU_CKD__c IN:cbuckdsLst
//                    AND     ProdCorp__c IN:prodcorpsLst
//                    AND     VehicleType__c IN:vehicletypesLst
//            ];

            Date today = Date.today();
            Date maxDate = today.addYears(+1);
            Integer startYear = 2000;
            Integer endYear = maxDate.year();
            for(Integer i = endYear; i >= startYear; i--){
                if(!yearsLstAdded.contains(String.valueOf(i).toLowerCase())){
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (yearsLst <> null && yearsLst.contains(String.valueOf(i).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(i);
                    optWrapper.value = String.valueOf(i);
                    yearsLstAdded.add(String.valueOf(i).toLowerCase());
                    optionsWrapper.year.add(optWrapper);
                }
            }

            List<AggregateResult> listFuelMapping = new List<AggregateResult>([
                    SELECT  FuelType__c fuelType
                    FROM    KASO_VIN_Mapping__c
                    WHERE   Model__c IN :modelsLst
                    Group By FuelType__c
            ]);

            if(!listFuelMapping.isEmpty()){
                for (AggregateResult result : listFuelMapping) {
                    List<String> strFuelType = String.valueOf(result.get('fuelType')).split(';') ;
                    for(String fuel : strFuelType) {
                            VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                            if (fuelTypesLst <> null && fuelTypesLst.contains(fuel.toLowerCase())) {
                                optWrapper.isSelected = true;
                            } else {
                                optWrapper.isSelected = false;
                            }
                            optWrapper.label = fuel;
                            optWrapper.value = fuel;
                            fuelTypesLstAdded.add(fuel);
                            optionsWrapper.fuelType.add(optWrapper);
                    }
                }
            }

            Schema.DescribeFieldResult drivetrainFieldResult = HMCReferenceData__c.DrivetrainDescription__c.getDescribe();
            List<Schema.PicklistEntry> pdrivetrains = drivetrainFieldResult.getPicklistValues();
            for (Schema.PicklistEntry result : pdrivetrains) {
                if(!drivetrainsLstAdded.contains(result.getValue())){
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (drivetrainsLst <> null && drivetrainsLst.contains(result.getValue().toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = result.getValue();
                    optWrapper.value = result.getValue();
                    drivetrainsLstAdded.add(result.getValue());
                    optionsWrapper.drivetrain.add(optWrapper);
                }
            }

            for (HMCReferenceData__c result : hmaReferenceData) {
                if (result.Make__c <> null && !makesLstAdded.contains(String.valueOf(result.Make__c).toLowerCase())) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (makesLst <> null && makesLst.contains(String.valueOf(result.Make__c).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.Make__c);
                    optWrapper.value = String.valueOf(result.Make__c);
                    makesLstAdded.add(String.valueOf(result.Make__c).toLowerCase());
                    optionsWrapper.make.add(optWrapper);
                }
                if (result.CBU_CKD__c <> null && !cbuckdsLstAdded.contains(String.valueOf(result.CBU_CKD__c).toLowerCase())) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (cbuckdsLst <> null && cbuckdsLst.contains(String.valueOf(result.CBU_CKD__c).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.CBU_CKD__c);
                    optWrapper.value = String.valueOf(result.CBU_CKD__c);
                    cbuckdsLstAdded.add(String.valueOf(result.CBU_CKD__c).toLowerCase());
                    optionsWrapper.CBUCKD.add(optWrapper);
                }
                if (result.ProdCorp__c <> null && !prodcorpsLstAdded.contains(String.valueOf(result.ProdCorp__c).toLowerCase())) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (prodcorpsLst <> null && prodcorpsLst.contains(String.valueOf(result.ProdCorp__c).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.ProdCorp__c);
                    optWrapper.value = String.valueOf(result.ProdCorp__c);
                    prodcorpsLstAdded.add(String.valueOf(result.ProdCorp__c).toLowerCase());
                    optionsWrapper.prodCorp.add(optWrapper);
                }
                if (result.VehicleType__c <> null && !vehicletypesLstAdded.contains(String.valueOf(result.VehicleType__c).toLowerCase())) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (vehicletypesLst <> null && vehicletypesLst.contains(String.valueOf(result.VehicleType__c).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.VehicleType__c);
                    optWrapper.value = String.valueOf(result.VehicleType__c);
                    vehicletypesLstAdded.add(String.valueOf(result.VehicleType__c).toLowerCase());
                    optionsWrapper.vehicleType.add(optWrapper);
                }
                if (result.VehicleModel__c <> null && !modelsLstAdded.contains(String.valueOf(result.VehicleModel__c).toLowerCase())) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (modelsLst <> null && modelsLst.contains(String.valueOf(result.VehicleModel__c).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.VehicleModel__c);
                    optWrapper.value = String.valueOf(result.VehicleModel__c);
                    modelsLstAdded.add(String.valueOf(result.VehicleModel__c).toLowerCase());
                    optionsWrapper.model.add(optWrapper);
                }
//                if (result.Year__c <> null && !yearsLstAdded.contains(String.valueOf(result.Year__c).toLowerCase())) {
//                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                    if (yearsLst <> null && yearsLst.contains(String.valueOf(result.Year__c).toLowerCase())) {
//                        optWrapper.isSelected = true;
//                    } else {
//                        optWrapper.isSelected = false;
//                    }
//                    optWrapper.label = String.valueOf(result.Year__c);
//                    optWrapper.value = String.valueOf(result.Year__c);
//                    yearsLstAdded.add(String.valueOf(result.Year__c).toLowerCase());
//                    optionsWrapper.year.add(optWrapper);
//                }
//                if (result.FuelType__c <> null && !fuelTypesLstAdded.contains(String.valueOf(result.FuelType__c).toLowerCase())) {
//                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                    if (fuelTypesLst <> null && fuelTypesLst.contains(String.valueOf(result.FuelType__c).toLowerCase())) {
//                        optWrapper.isSelected = true;
//                    } else {
//                        optWrapper.isSelected = false;
//                    }
//                    optWrapper.label = String.valueOf(result.FuelType__c);
//                    optWrapper.value = String.valueOf(result.FuelType__c);
//                    fuelTypesLstAdded.add(String.valueOf(result.FuelType__c).toLowerCase());
//                    optionsWrapper.fuelType.add(optWrapper);
//                }
                if (result.EngineDescription__c <> null && !enginesLstAdded.contains(String.valueOf(result.EngineDescription__c).toLowerCase())) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (enginesLst <> null && enginesLst.contains(String.valueOf(result.EngineDescription__c).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.EngineDescription__c);
                    optWrapper.value = String.valueOf(result.EngineDescription__c);
                    enginesLstAdded.add(String.valueOf(result.EngineDescription__c).toLowerCase());
                    optionsWrapper.engine.add(optWrapper);
                }
//                if (result.DrivetrainDescription__c <> null && !drivetrainsLstAdded.contains(String.valueOf(result.DrivetrainDescription__c).toLowerCase())) {
//                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                    if (drivetrainsLst <> null && drivetrainsLst.contains(String.valueOf(result.DrivetrainDescription__c).toLowerCase())) {
//                        optWrapper.isSelected = true;
//                    } else {
//                        optWrapper.isSelected = false;
//                    }
//                    optWrapper.label = String.valueOf(result.DrivetrainDescription__c);
//                    optWrapper.value = String.valueOf(result.DrivetrainDescription__c);
//                    drivetrainsLstAdded.add(String.valueOf(result.DrivetrainDescription__c).toLowerCase());
//                    optionsWrapper.drivetrain.add(optWrapper);
//                }
                if (result.TransmissionDescription__c <> null && result.TransmissionDescription__c != 'N/A' && !transmissionsLstAdded.contains(String.valueOf(result.TransmissionDescription__c).toLowerCase())) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (transmissionsLst <> null && transmissionsLst.contains(String.valueOf(result.TransmissionDescription__c).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.TransmissionDescription__c);
                    optWrapper.value = String.valueOf(result.TransmissionDescription__c);
                    transmissionsLstAdded.add(String.valueOf(result.TransmissionDescription__c).toLowerCase());
                    optionsWrapper.transmission.add(optWrapper);
                }
                if (result.ModelCode__c <> null && !modelCodesLstAdded.contains(String.valueOf(result.ModelCode__c).toLowerCase())) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (modelCodesLst <> null && modelCodesLst.contains(String.valueOf(result.ModelCode__c).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.ModelCode__c);
                    optWrapper.value = String.valueOf(result.ModelCode__c);
                    modelCodesLstAdded.add(String.valueOf(result.ModelCode__c).toLowerCase());
                    optionsWrapper.modelCode.add(optWrapper);
                }
            }

//            for (HMCReferenceData__c result : hmaReferenceData) {
//                if (result.Make__c <> null && !makesLstAdded.contains(String.valueOf(result.Make__c).toLowerCase())) {
//                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                    if (makesLst <> null && makesLst.contains(String.valueOf(result.Make__c).toLowerCase())) {
//                        optWrapper.isSelected = true;
//                    } else {
//                        optWrapper.isSelected = false;
//                    }
//                    optWrapper.label = String.valueOf(result.Make__c);
//                    optWrapper.value = String.valueOf(result.Make__c);
//                    makesLstAdded.add(String.valueOf(result.Make__c).toLowerCase());
//                    optionsWrapper.make.add(optWrapper);
//                }
//                if (result.VehicleModel__c <> null && !modelsLstAdded.contains(String.valueOf(result.VehicleModel__c).toLowerCase())) {
//                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                    if (modelsLst <> null && modelsLst.contains(String.valueOf(result.VehicleModel__c).toLowerCase())) {
//                        optWrapper.isSelected = true;
//                    } else {
//                        optWrapper.isSelected = false;
//                    }
//                    optWrapper.label = String.valueOf(result.VehicleModel__c);
//                    optWrapper.value = String.valueOf(result.VehicleModel__c);
//                    modelsLstAdded.add(String.valueOf(result.VehicleModel__c).toLowerCase());
//                    optionsWrapper.model.add(optWrapper);
//                }
//                if (result.Make__c <> null && result.VehicleModel__c <> null
//                        && valueInSet(result.Make__c, makesLst) && valueInSet(result.VehicleModel__c, modelsLst)) { // Show related years only
//                    if (result.Year__c <> null && !yearsLstAdded.contains(String.valueOf(result.Year__c).toLowerCase())) {
//                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                        if (yearsLst <> null && yearsLst.contains(String.valueOf(result.Year__c).toLowerCase())) {
//                            optWrapper.isSelected = true;
//                        } else {
//                            optWrapper.isSelected = false;
//                        }
//                        optWrapper.label = String.valueOf(result.Year__c);
//                        optWrapper.value = String.valueOf(result.Year__c);
//                        yearsLstAdded.add(String.valueOf(result.Year__c).toLowerCase());
//                        optionsWrapper.year.add(optWrapper);
//                    }
//                }
//                if (result.Make__c <> null && result.VehicleModel__c <> null && result.Year__c <> null
//                        && valueInSet(result.Make__c, makesLst) && valueInSet(result.VehicleModel__c, modelsLst) && valueInSet(result.Year__c, yearsLst)) { // show related optional options only
//                    if (result.FuelType__c <> null && !fuelTypesLstAdded.contains(String.valueOf(result.FuelType__c).toLowerCase())) {
//                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                        if (fuelTypesLst <> null && fuelTypesLst.contains(String.valueOf(result.FuelType__c).toLowerCase())) {
//                            optWrapper.isSelected = true;
//                        } else {
//                            optWrapper.isSelected = false;
//                        }
//                        optWrapper.label = String.valueOf(result.FuelType__c);
//                        optWrapper.value = String.valueOf(result.FuelType__c);
//                        fuelTypesLstAdded.add(String.valueOf(result.FuelType__c).toLowerCase());
//                        optionsWrapper.fuelType.add(optWrapper);
//                    }
//                    if (result.EngineDescription__c <> null && !enginesLstAdded.contains(String.valueOf(result.EngineDescription__c).toLowerCase())) {
//                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                        if (enginesLst <> null && enginesLst.contains(String.valueOf(result.EngineDescription__c).toLowerCase())) {
//                            optWrapper.isSelected = true;
//                        } else {
//                            optWrapper.isSelected = false;
//                        }
//                        optWrapper.label = String.valueOf(result.EngineDescription__c);
//                        optWrapper.value = String.valueOf(result.EngineDescription__c);
//                        enginesLstAdded.add(String.valueOf(result.EngineDescription__c).toLowerCase());
//                        optionsWrapper.engine.add(optWrapper);
//                    }
//                    if (result.DrivetrainDescription__c <> null && !drivetrainsLstAdded.contains(String.valueOf(result.DrivetrainDescription__c).toLowerCase())) {
//                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                        if (drivetrainsLst <> null && drivetrainsLst.contains(String.valueOf(result.DrivetrainDescription__c).toLowerCase())) {
//                            optWrapper.isSelected = true;
//                        } else {
//                            optWrapper.isSelected = false;
//                        }
//                        optWrapper.label = String.valueOf(result.DrivetrainDescription__c);
//                        optWrapper.value = String.valueOf(result.DrivetrainDescription__c);
//                        drivetrainsLstAdded.add(String.valueOf(result.DrivetrainDescription__c).toLowerCase());
//                        optionsWrapper.drivetrain.add(optWrapper);
//                    }
//                    if (result.TransmissionDescription__c <> null && !transmissionsLstAdded.contains(String.valueOf(result.TransmissionDescription__c).toLowerCase())) {
//                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                        if (transmissionsLst <> null && transmissionsLst.contains(String.valueOf(result.TransmissionDescription__c).toLowerCase())) {
//                            optWrapper.isSelected = true;
//                        } else {
//                            optWrapper.isSelected = false;
//                        }
//                        optWrapper.label = String.valueOf(result.TransmissionDescription__c);
//                        optWrapper.value = String.valueOf(result.TransmissionDescription__c);
//                        transmissionsLstAdded.add(String.valueOf(result.TransmissionDescription__c).toLowerCase());
//                        optionsWrapper.transmission.add(optWrapper);
//                    }
//                    if (result.ModelCode__c <> null && !modelCodesLstAdded.contains(String.valueOf(result.ModelCode__c).toLowerCase())) {
//                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
//                        if (modelCodesLst <> null && modelCodesLst.contains(String.valueOf(result.ModelCode__c).toLowerCase())) {
//                            optWrapper.isSelected = true;
//                        } else {
//                            optWrapper.isSelected = false;
//                        }
//                        optWrapper.label = String.valueOf(result.ModelCode__c);
//                        optWrapper.value = String.valueOf(result.ModelCode__c);
//                        modelCodesLstAdded.add(String.valueOf(result.ModelCode__c).toLowerCase());
//                        optionsWrapper.modelCode.add(optWrapper);
//                    }
//                }
//            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String saveVehicles(
            String caseid
            , String makes
            , String years
            , String models
            , String drivetrains
            , String fueltypes
            , String engines
            , String transmissions
            , String modelcodes
            , String cbuckd
            , String prodcorp
            , String vehicletype
    ) {
        String returnStr = '';
        List<String> summaryList = new List<String>();
        try {
            Set<String> makesLst = convertMultiSelectStringToSet(makes);
            Set<String> yearsLst = convertMultiSelectStringToSet(years);
            Set<String> modelsLst = convertMultiSelectStringToSet(models);
            Set<String> drivetrainsLst = convertMultiSelectStringToSet(drivetrains);
            Set<String> fuelTypesLst = convertMultiSelectStringToSet(fuelTypes);
            Set<String> enginesLst = convertMultiSelectStringToSet(engines);
            Set<String> transmissionsLst = convertMultiSelectStringToSet(transmissions);
            Set<String> modelCodesLst = convertMultiSelectStringToSet(modelCodes);

            Set<String> cbuckdsLst = convertMultiSelectStringToSet(cbuckd);
            Set<String> prodcorpsLst = convertMultiSelectStringToSet(prodcorp);
            Set<String> vehicletypesLst = convertMultiSelectStringToSet(vehicletype);

            returnStr += 'makesLst Size: ' + makesLst.size();
            returnStr += '\nyearsLst Size: ' + yearsLst.size();
            returnStr += '\nmodelsLst Size: ' + modelsLst.size();
            returnStr += '\ndrivetrainsLst Size: ' + drivetrainsLst.size();
            returnStr += '\nfuelTypesLst Size: ' + fuelTypesLst.size();
            returnStr += '\n' + JSON.serializePretty(fuelTypesLst);
            returnStr += '\nenginesLst Size: ' + enginesLst.size();
            returnStr += '\ntransmissionsLst Size: ' + transmissionsLst.size();
            returnStr += '\nmodelCodesLst Size: ' + modelCodesLst.size();
            returnStr += '\ncbuckdsLst Size: ' + cbuckdsLst.size();
            returnStr += '\nprodcorpsLst Size: ' + prodcorpsLst.size();
            returnStr += '\nvehicletypesLst Size: ' + vehicletypesLst.size();

            List<KASOCaseVehicle__c> existingCaseVehiclesLst = [
                    SELECT
                            Id, Name, Case__c, Make__c, Model__c, VehicleYear__c, EngineDescription__c, FuelType__c,
                            DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c, Notes__c, CBU_CKD__c, ProdCorp__c, VehicleType__c
                    FROM KASOCaseVehicle__c
                    WHERE Case__c = :caseId
                    AND Need_Review__c = FALSE
            ];
            returnStr += '\nexistingCaseVehicles Size: ' + existingCaseVehiclesLst.size();

            Map<String, KASOCaseVehicle__c> existVehicleMap = new Map<String, KASOCaseVehicle__c>();
            for (KASOCaseVehicle__c caseVhc : existingCaseVehiclesLst) {

                String mapKey = getCVMapKey(caseVhc.Make__c, caseVhc.CBU_CKD__c, caseVhc.ProdCorp__c, caseVhc.VehicleType__c, caseVhc.Model__c, caseVhc.ModelCode__c);

                if (!existVehicleMap.containsKey(mapKey)) {
                    caseVhc.VehicleYear__c = '';
                    caseVhc.FuelType__c = '';
                    caseVhc.EngineDescription__c = '';
                    caseVhc.DrivetrainDescription__c = '';
                    caseVhc.TransmissionDescription__c = '';
//                    caseVhc.CBU_CKD__c = '';
//                    caseVhc.ProdCorp__c = '';
//                    caseVhc.VehicleType__c = '';
                    if (caseVhc.ModelCode__c == null) {
                        caseVhc.ModelCode__c = '';
                    }
                    existVehicleMap.put(mapKey, caseVhc);
                }
            }

            List<HMCReferenceData__c> referenceData;
            String queryString = 'SELECT Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c,' +
                    'DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c, CBU_CKD__c, ProdCorp__c, VehicleType__c\n' +
                    'FROM HMCReferenceData__c\n' +
                    'WHERE Make__c IN:makesLst\n' +
                    'AND CBU_CKD__c IN:cbuckdsLst\n' +
                    'AND ProdCorp__c IN:prodcorpsLst\n' +
                    'AND VehicleType__c IN:vehicletypesLst\n' +
                    'AND VehicleModel__c IN:modelsLst';
//                    'AND Year__c IN :yearsLst';
            if (modelCodesLst.size() > 0) {
                queryString += ' AND ModelCode__c IN :modelCodesLst';
            }

            referenceData = Database.query(queryString);

            returnStr += '\nreferenceData Size: ' + referenceData.size();

            Map<String, KASOCaseVehicle__c> caseVehiclesToCreate = new Map<String, KASOCaseVehicle__c>();
            Map<String, KASOCaseVehicle__c> caseVehiclesToUpdate = new Map<String, KASOCaseVehicle__c>();

            for (HMCReferenceData__c referenceRecord : referenceData) {
                for (String make : makesLst) {
                    for(String tarcbuckd : cbuckdsLst) {
                        for (String tarprodcorp : prodcorpsLst){
                            for(String tarvehicletype : vehicletypesLst){
                                for (String model : modelsLst) {
                                    // Find a HMA Reference Data match
                                    if (referenceRecord.Make__c <> null && referenceRecord.VehicleModel__c <> null &&
                                        referenceRecord.CBU_CKD__c <> null && referenceRecord.ProdCorp__c <> null &&
                                        referenceRecord.VehicleType__c <> null
                                        && referenceRecord.Make__c.equalsIgnoreCase(make) && referenceRecord.VehicleModel__c.equalsIgnoreCase(model)
                                        && referenceRecord.CBU_CKD__c.equalsIgnoreCase(tarcbuckd) && referenceRecord.ProdCorp__c.equalsIgnoreCase(tarprodcorp)
                                        && referenceRecord.VehicleType__c.equalsIgnoreCase(tarvehicletype)

                                    ) {

                                        String partialKey = getCVMapKey(
                                                referenceRecord.Make__c
                                                , referenceRecord.CBU_CKD__c
                                                , referenceRecord.ProdCorp__c
                                                , referenceRecord.VehicleType__c
                                                , referenceRecord.VehicleModel__c
                                                , null
                                        );

                                        String mapKey = modelCodesLst.size() > 0 ?
                                                getCVMapKey(
                                                        referenceRecord.Make__c
                                                        , referenceRecord.CBU_CKD__c
                                                        , referenceRecord.ProdCorp__c
                                                        , referenceRecord.VehicleType__c
                                                        , referenceRecord.VehicleModel__c
                                                        , referenceRecord.ModelCode__c

                                                ) :
                                                getCVMapKey(
                                                        referenceRecord.Make__c
                                                        , referenceRecord.CBU_CKD__c
                                                        , referenceRecord.ProdCorp__c
                                                        , referenceRecord.VehicleType__c
                                                        , referenceRecord.VehicleModel__c
                                                        , null
                                                );

                                        // If a model code is newly selected, attach the existing record to it.
                                        if (existVehicleMap.containsKey(partialKey) && !partialKey.equals(mapKey)) {
                                            KASOCaseVehicle__c caseVhc = existVehicleMap.get(partialKey);
                                            existVehicleMap.put(mapKey, caseVhc);
                                            existVehicleMap.remove(partialKey);
                                        }

                                        // The Vehicle Case record exists in the system -> Update the existing record values
                                        if (existVehicleMap.containsKey(mapKey)) {
                                            KASOCaseVehicle__c caseVhc = caseVehiclesToUpdate.containsKey(mapKey) ? caseVehiclesToUpdate.get(mapKey) : existVehicleMap.get(mapKey);
                                            Set<String> caseVhcYearLst = convertMultiSelectStringToSet(caseVhc.VehicleYear__c);
                                            Set<String> caseVhcFuelTypeLst = convertMultiSelectStringToSet(caseVhc.FuelType__c);
                                            Set<String> caseVhcEngineLst = convertMultiSelectStringToSet(caseVhc.EngineDescription__c);
                                            Set<String> caseVhcDrivetrainLst = convertMultiSelectStringToSet(caseVhc.DrivetrainDescription__c);
                                            Set<String> caseVhcTransmissionLst = convertMultiSelectStringToSet(caseVhc.TransmissionDescription__c);
                                            Set<String> caseVhcModelCodeLst = convertMultiSelectStringToSet(caseVhc.ModelCode__c);

                                            if(!yearsLst.isEmpty()){
                                                for(String tarYears : yearsLst){
                                                    if(tarYears != 'All'){
                                                        if(!caseVhcYearLst.contains(tarYears))
                                                            caseVhc.VehicleYear__c += ';' + tarYears;
                                                    }
                                                }
                                            }

                                            if(!fuelTypesLst.isEmpty()){
                                                for(String tarFuelType : fuelTypesLst){
                                                    if(tarFuelType != 'All'){
                                                        if (!caseVhcFuelTypeLst.contains(tarFuelType)) {
                                                            caseVhc.FuelType__c += ';' + tarFuelType;
                                                        }
                                                    }
                                                }
                                            }

                                            if(!drivetrainsLst.isEmpty()){
                                                for(String tarDrivtrain : drivetrainsLst){
                                                    if(tarDrivtrain != 'All'){
                                                        if(!caseVhcDrivetrainLst.contains(tarDrivtrain)){
                                                            caseVhc.DrivetrainDescription__c += ';' + tarDrivtrain;
                                                        }
                                                    }
                                                }
                                            }

                                            if (referenceRecord.EngineDescription__c <> null && enginesLst.contains(referenceRecord.EngineDescription__c.toLowerCase()) && !caseVhcEngineLst.contains(referenceRecord.EngineDescription__c.toLowerCase().trim())) {
//                                                caseVhc.EngineDescription__c += ';' + referenceRecord.EngineDescription__c.toLowerCase().trim();
                                                caseVhc.EngineDescription__c += ';' + referenceRecord.EngineDescription__c;
                                            }
                                            if (referenceRecord.TransmissionDescription__c <> null && transmissionsLst.contains(referenceRecord.TransmissionDescription__c.toLowerCase()) && !caseVhcTransmissionLst.contains(referenceRecord.TransmissionDescription__c.toLowerCase().trim())) {
//                                                caseVhc.TransmissionDescription__c += ';' + referenceRecord.TransmissionDescription__c.toLowerCase().trim();
                                                caseVhc.TransmissionDescription__c += ';' + referenceRecord.TransmissionDescription__c;
                                            }
                                            if (referenceRecord.ModelCode__c <> null && modelCodesLst.contains(referenceRecord.ModelCode__c.toLowerCase()) && modelCodesLst.contains(referenceRecord.ModelCode__c.toLowerCase()) && !caseVhcModelCodeLst.contains(referenceRecord.ModelCode__c.toLowerCase().trim())) {
//                                                caseVhc.ModelCode__c += ';' + referenceRecord.ModelCode__c.toLowerCase().trim();
                                                caseVhc.ModelCode__c += ';' + referenceRecord.ModelCode__c;
                                            }
            //                                if (referenceRecord.CBU_CKD__c <> null && cbuckdsLst.contains(referenceRecord.CBU_CKD__c.toLowerCase()) && cbuckdsLst.contains(referenceRecord.CBU_CKD__c.toLowerCase()) && !caseVhcCBUCKDLst.contains(referenceRecord.CBU_CKD__c.toLowerCase().trim())) {
            //                                    caseVhc.CBU_CKD__c += ';' + referenceRecord.CBU_CKD__c.toLowerCase().trim();
            //                                }
            //                                if (referenceRecord.ProdCorp__c <> null && prodcorpsLst.contains(referenceRecord.ProdCorp__c.toLowerCase()) && prodcorpsLst.contains(referenceRecord.ProdCorp__c.toLowerCase()) && !caseVhcProdCorpLst.contains(referenceRecord.ProdCorp__c.toLowerCase().trim())) {
            //                                    caseVhc.ProdCorp__c += ';' + referenceRecord.ProdCorp__c.toLowerCase().trim();
            //                                }
            //                                if (referenceRecord.VehicleType__c <> null && vehicletypesLst.contains(referenceRecord.VehicleType__c.toLowerCase()) && vehicletypesLst.contains(referenceRecord.VehicleType__c.toLowerCase()) && !caseVhcTypeLst.contains(referenceRecord.VehicleType__c.toLowerCase().trim())) {
            //                                    caseVhc.VehicleType__c += ';' + referenceRecord.VehicleType__c.toLowerCase().trim();
            //                                }

                                            caseVhc.HasModelCode__c = !String.isEmpty(caseVhc.ModelCode__c) ? true : false;
                                            if (!caseVehiclesToUpdate.containsKey(mapKey)) {
                                                caseVehiclesToUpdate.put(mapKey, caseVhc);
                                            }
                                        }
                                        // Remove any duplicate values in the new Case Vehicle records
                                        else if (caseVehiclesToCreate.containsKey(mapKey)) {
                                            KASOCaseVehicle__c caseVhc = caseVehiclesToCreate.get(mapKey);
                                            Set<String> caseVhcYearLst = convertMultiSelectStringToSet(caseVhc.VehicleYear__c);
                                            Set<String> caseVhcFuelTypeLst = convertMultiSelectStringToSet(caseVhc.FuelType__c);
                                            Set<String> caseVhcEngineLst = convertMultiSelectStringToSet(caseVhc.EngineDescription__c);
                                            Set<String> caseVhcDrivetrainLst = convertMultiSelectStringToSet(caseVhc.DrivetrainDescription__c);
                                            Set<String> caseVhcTransmissionLst = convertMultiSelectStringToSet(caseVhc.TransmissionDescription__c);
                                            Set<String> caseVhcModelCodeLst = convertMultiSelectStringToSet(caseVhc.ModelCode__c);

            //                                Set<String> caseVhcCBUCKDLst = convertMultiSelectStringToSet(caseVhc.CBU_CKD__c);
            //                                Set<String> caseVhcProdCorpLst = convertMultiSelectStringToSet(caseVhc.ProdCorp__c);
            //                                Set<String> caseVhcTypeLst = convertMultiSelectStringToSet(caseVhc.VehicleType__c);

            //                                if (referenceRecord.CBU_CKD__c <> null && !caseVhcCBUCKDLst.contains(referenceRecord.CBU_CKD__c.toLowerCase()) && cbuckdsLst.contains(referenceRecord.CBU_CKD__c.toLowerCase())) {
            //                                    caseVhc.CBU_CKD__c += ';' + referenceRecord.CBU_CKD__c;
            //                                }
            //                                if (referenceRecord.ProdCorp__c <> null && !caseVhcProdCorpLst.contains(referenceRecord.ProdCorp__c.toLowerCase()) && prodcorpsLst.contains(referenceRecord.ProdCorp__c.toLowerCase())) {
            //                                    caseVhc.ProdCorp__c += ';' + referenceRecord.ProdCorp__c;
            //                                }
            //                                if (referenceRecord.VehicleType__c <> null && !caseVhcTypeLst.contains(referenceRecord.VehicleType__c.toLowerCase()) && vehicletypesLst.contains(referenceRecord.VehicleType__c.toLowerCase())) {
            //                                    caseVhc.VehicleType__c += ';' + referenceRecord.VehicleType__c;
            //                                }

                                            if (referenceRecord.Year__c <> null && !caseVhcYearLst.contains(referenceRecord.Year__c) && yearsLst.contains(referenceRecord.Year__c)) {
                                                caseVhc.VehicleYear__c += ';' + referenceRecord.Year__c;
                                            }
                                            if (referenceRecord.FuelType__c <> null && !caseVhcFuelTypeLst.contains(referenceRecord.FuelType__c.toLowerCase()) && fuelTypesLst.contains(referenceRecord.FuelType__c.toLowerCase())) {
                                                caseVhc.FuelType__c += ';' + referenceRecord.FuelType__c;
                                            }
                                            if (referenceRecord.EngineDescription__c <> null && !caseVhcEngineLst.contains(referenceRecord.EngineDescription__c.toLowerCase()) && enginesLst.contains(referenceRecord.EngineDescription__c.toLowerCase())) {
                                                caseVhc.EngineDescription__c += ';' + referenceRecord.EngineDescription__c;
                                            }
                                            if (referenceRecord.DrivetrainDescription__c <> null && !caseVhcDrivetrainLst.contains(referenceRecord.DrivetrainDescription__c.toLowerCase()) && drivetrainsLst.contains(referenceRecord.DrivetrainDescription__c.toLowerCase())) {
                                                caseVhc.DrivetrainDescription__c += ';' + referenceRecord.DrivetrainDescription__c;
                                            }
                                            if (referenceRecord.TransmissionDescription__c <> null && !caseVhcTransmissionLst.contains(referenceRecord.TransmissionDescription__c.toLowerCase()) && transmissionsLst.contains(referenceRecord.TransmissionDescription__c.toLowerCase())) {
                                                caseVhc.TransmissionDescription__c += ';' + referenceRecord.TransmissionDescription__c;
                                            }
                                            if (referenceRecord.ModelCode__c <> null && !caseVhcModelCodeLst.contains(referenceRecord.ModelCode__c.toLowerCase()) && modelCodesLst.contains(referenceRecord.ModelCode__c.toLowerCase())) {
                                                caseVhc.ModelCode__c += ';' + referenceRecord.ModelCode__c;
                                            }
                                            caseVhc.HasModelCode__c = !String.isEmpty(caseVhc.ModelCode__c) ? true : false;
                                        }
                                        // New Case Vehicle records -> Create new record
                                        else {
                                            KASOCaseVehicle__c caseVhc = new KASOCaseVehicle__c();
                                            caseVhc.Case__c = caseid;

                                            caseVhc.Make__c = valueInSet(referenceRecord.Make__c, makesLst) ? referenceRecord.Make__c : '';
                                            caseVhc.Model__c = valueInSet(referenceRecord.VehicleModel__c, modelsLst) ? referenceRecord.VehicleModel__c : '';
                                            caseVhc.EngineDescription__c = valueInSet(referenceRecord.EngineDescription__c, enginesLst) ? referenceRecord.EngineDescription__c : '';

                                            String strYears = '';
                                            if(!yearsLst.isEmpty()){
                                                for(String tarYears : yearsLst){
                                                    if(tarYears != 'All'){
                                                        strYears += ';' + tarYears;
                                                    }
                                                }
                                            }
                                            caseVhc.VehicleYear__c = strYears;

                                            String strFuelTypes = '';
                                            for(String tarFuelType : fuelTypesLst){
                                                if(tarFuelType != 'All'){
                                                    strFuelTypes += ';' + tarFuelType;
                                                }
                                            }
                                            caseVhc.FuelType__c = strFuelTypes;

                                            String strDrivtrain = '';
                                            for(String tarDrivtrain : drivetrainsLst){
                                                if(tarDrivtrain != 'All'){
                                                    strDrivtrain += ';' + tarDrivtrain;
                                                }
                                            }
                                            caseVhc.DrivetrainDescription__c = strDrivtrain;

                                            caseVhc.TransmissionDescription__c = valueInSet(referenceRecord.TransmissionDescription__c, transmissionsLst) ? referenceRecord.TransmissionDescription__c : '';
                                            caseVhc.ModelCode__c = valueInSet(referenceRecord.ModelCode__c, modelCodesLst) ? referenceRecord.ModelCode__c : '';
                                            caseVhc.HasModelCode__c = !String.isEmpty(caseVhc.ModelCode__c) ? true : false;

                                            caseVhc.CBU_CKD__c = valueInSet(referenceRecord.CBU_CKD__c, cbuckdsLst) ? referenceRecord.CBU_CKD__c : '';
                                            caseVhc.ProdCorp__c = valueInSet(referenceRecord.ProdCorp__c, prodcorpsLst) ? referenceRecord.ProdCorp__c : '';
                                            caseVhc.VehicleType__c = valueInSet(referenceRecord.VehicleType__c, vehicletypesLst) ? referenceRecord.VehicleType__c : '';

                                            caseVehiclesToCreate.put(mapKey, caseVhc);
                                        }
                                    }
                                }
                            }

                        }
                    }
                }
            }

            System.debug('Case to create:: ' + caseVehiclesToCreate.size());
            System.debug(JSON.serializePretty(caseVehiclesToCreate));

            returnStr += '\ncaseVehiclesToCreate Size: ' + caseVehiclesToCreate.size();
            returnStr += '\ncaseVehiclesToUpdate Size: ' + caseVehiclesToUpdate.size();

            if (caseVehiclesToCreate.size() > 0) {
                insert caseVehiclesToCreate.values();
                summaryList.add('Total Vehicles added: ' + caseVehiclesToCreate.size());
            }

            if (caseVehiclesToUpdate.size() > 0) {
                update caseVehiclesToUpdate.values();
                summaryList.add('Total Vehicles updated: ' + caseVehiclesToUpdate.size());
            }
            updateCaseVehicleInfo(caseId);

            returnStr += '\nCase Id: ' + caseId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(summaryList);
    }

    private static String getCVMapKey(String make, String cbuckd, String prodcorp, String vehicletype, String model, String modelCode) {
        if (modelCode <> null && String.isNotEmpty(modelCode)) {
            return String.valueOf(make).toLowerCase().trim()
                    + '_'
                    + String.valueOf(cbuckd).toLowerCase().trim()
                    + '_'
                    + String.valueOf(prodcorp).toLowerCase().trim()
                    + '_'
                    + String.valueOf(vehicletype).toLowerCase().trim()
                    + '_'
                    + String.valueOf(model).toLowerCase().trim()
                    + '_'
                    + String.valueOf(modelCode).toLowerCase().trim();
        }
        return String.valueOf(make).toLowerCase().trim() +
                '_' + String.valueOf(cbuckd).toLowerCase().trim() +
                '_' + String.valueOf(prodcorp).toLowerCase().trim() +
                '_' + String.valueOf(vehicletype).toLowerCase().trim() +
                '_' + String.valueOf(model).toLowerCase().trim();
    }

    public static void updateCaseVehicleInfo(String caseid) {
        List<KASOCaseVehicle__c> affectedVehicles = [SELECT Id, Name, Case__c, Make__c, Model__c, VehicleYear__c, EngineDescription__c, FuelType__c, DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c, Notes__c FROM KASOCaseVehicle__c WHERE Case__c = :caseId];

        // Update Case values based on the newly selected Case Vehicle records
        if (affectedVehicles.size() > 0) {
            Set<String> vhcMakes = new Set<String>();
            Set<String> vhcModels = new Set<String>();
            Set<String> vhcModelCodes = new Set<String>();
            Set<String> vhcYears = new Set<String>();
            Set<String> vhcEngines = new Set<String>();
            Set<String> vhcDrivetrains = new Set<String>();
            Set<String> vhcTransmissions = new Set<String>();
            Set<String> vhcFuelTypes = new Set<String>();

            for (KASOCaseVehicle__c vhc : affectedVehicles) {
                if (vhc.Make__c <> null) {
                    vhcMakes.addAll(vhc.Make__c.split(';'));
                }
                if (vhc.Model__c <> null) {
                    vhcModels.addAll(vhc.Model__c.split(';'));
                }
                if (vhc.ModelCode__c <> null) {
                    vhcModelCodes.addAll(vhc.ModelCode__c.split(';'));
                }
                if (vhc.VehicleYear__c <> null) {
                    vhcYears.addAll(vhc.VehicleYear__c.split(';'));
                }
                if (vhc.EngineDescription__c <> null) {
                    vhcEngines.addAll(vhc.EngineDescription__c.split(';'));
                }
                if (vhc.DrivetrainDescription__c <> null) {
                    vhcDrivetrains.addAll(vhc.DrivetrainDescription__c.split(';'));
                }
                if (vhc.TransmissionDescription__c <> null) {
                    vhcTransmissions.addAll(vhc.TransmissionDescription__c.split(';'));
                }
                if (vhc.FuelType__c <> null) {
                    vhcFuelTypes.addAll(vhc.FuelType__c.split(';'));
                }
            }

            Case c = new Case(Id = caseid);
            c.VehicleInfo__c = CaseVehicleUtil.GenerateVehicleInfo(affectedVehicles);

            // Make
            c.Make__c = convertListToString(new List<String>(vhcMakes));

            // Model
            c.VehicleModel__c = convertListToString(new List<String>(vhcModels));

            // Model Codes
            c.ModelCode__c = convertListToString(new List<String>(vhcModelCodes));

            // Years
            c.MY__c = convertListToString(new List<String>(vhcYears));
            // Engines
            c.Engine__c = convertListToString(new List<String>(vhcEngines));

            // Drivetrains
            c.Drivetrain__c = convertListToString(new List<String>(vhcDrivetrains));

            // Transmissions
            c.Trans__c = convertListToString(new List<String>(vhcTransmissions));

            // Fuel Type
            c.Fuel_Type__c = convertListToString(new List<String>(vhcFuelTypes));

            update c;
        }
    }

    @AuraEnabled
    public static String deleteVehicles(String vehicleIds, String caseid) {
        String returnStr = '';
        try {
            if (String.isNotEmpty(vehicleIds)) {
                List<String> vehicleIdsList = vehicleIds.split(';');
                List<KASOCaseVehicle__c> caseVehicles = [SELECT Id FROM KASOCaseVehicle__c WHERE Id IN:vehicleIdsList];
                if (caseVehicles.size() > 0) {
                    delete caseVehicles;
                    returnStr = caseVehicles.size() + ' Affected Vehicles deleted';
                    updateCaseVehicleInfo(caseId);
                }
            }
        } catch (Exception e) {
            System.debug('MESSAGE:: ' + e.getMessage());
            System.debug('TYPE:: ' + e.getTypeName());
            System.debug('CAUSE:: ' + e.getCause());
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return returnStr;
    }

    @AuraEnabled
    public static String deleteAllVehicles(String caseId) {
        String returnStr = '';
        try {
            if (String.isNotEmpty(caseId)) {
                List<KASOCaseVehicle__c> caseVehicles = [SELECT Id FROM KASOCaseVehicle__c WHERE Case__c = :caseId];
                if (caseVehicles.size() > 0) {
                    delete caseVehicles;
                    returnStr = caseVehicles.size() + ' Affected Vehicles deleted';

                    Case c = new Case(Id = caseId);
                    c.VehicleInfo__c = '';
                    update c;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return returnStr;
    }

    /* -------- Util Methods -------- */
    private static Boolean isEmpty(String str) {
        return String.isBlank(str) || (str.trim().equals(';'));
    }

    private static String convertListToString(List<String> strList) {
        if (strList.size() > 0) {
            return String.join(new List<String>(strList), ';');
        }
        return '';
    }

    private static Set<String> convertMultiSelectStringToSet(String sValue) {
        return isEmpty(sValue) ? new Set<String>() : new Set<String>(sValue.toLowerCase().split(';'));
    }

    public static Boolean valueInSet(String value, Set<String> vSet) {
        return value <> null && vSet.contains(value.trim().toLowerCase());
    }

    /* -------- Wrapper Classes -------- */
    public class NewVehiclesWrapper {
        public List<VehicleOptionsWrapper> make = new List<VehicleOptionsWrapper>();
        public List<VehicleOptionsWrapper> model = new List<VehicleOptionsWrapper>();
        public List<VehicleOptionsWrapper> year = new List<VehicleOptionsWrapper>();
        public List<VehicleOptionsWrapper> drivetrain = new List<VehicleOptionsWrapper>();
        public List<VehicleOptionsWrapper> fuelType = new List<VehicleOptionsWrapper>();
        public List<VehicleOptionsWrapper> engine = new List<VehicleOptionsWrapper>();
        public List<VehicleOptionsWrapper> transmission = new List<VehicleOptionsWrapper>();
        public List<VehicleOptionsWrapper> modelCode = new List<VehicleOptionsWrapper>();
        public List<VehicleOptionsWrapper> CBUCKD = new List<VehicleOptionsWrapper>();
        public List<VehicleOptionsWrapper> prodCorp = new List<VehicleOptionsWrapper>();
        public List<VehicleOptionsWrapper> vehicleType = new List<VehicleOptionsWrapper>();
    }

    public class AffectedVehicleWrapper {
        public String id = '';
        public String notes = '';
        public Boolean needReview = false;
        public String formattedYear = '';
        public VehiclePropertyWrapper make = new VehiclePropertyWrapper();
        public VehiclePropertyWrapper model = new VehiclePropertyWrapper();
        public VehiclePropertyWrapper year = new VehiclePropertyWrapper();
        public VehiclePropertyWrapper drivetrain = new VehiclePropertyWrapper();
        public VehiclePropertyWrapper fuelType = new VehiclePropertyWrapper();
        public VehiclePropertyWrapper engine = new VehiclePropertyWrapper();
        public VehiclePropertyWrapper transmission = new VehiclePropertyWrapper();
        public VehiclePropertyWrapper modelCode = new VehiclePropertyWrapper();
        public VehiclePropertyWrapper CBUCKD = new VehiclePropertyWrapper();
        public VehiclePropertyWrapper prodCorp = new VehiclePropertyWrapper();
        public VehiclePropertyWrapper vehicleType = new VehiclePropertyWrapper();
    }

    public class VehiclePropertyWrapper {
        public String selectedValue = '';
        public List<VehicleOptionsWrapper> options = new List<VehicleOptionsWrapper>();
    }

    public class VehicleOptionsWrapper {
        public String label = '';
        public String value = '';
        public Boolean isSelected = false;
    }
}