public class multiVehicleCaseController {
    @AuraEnabled
    public static String getAffectedVehicles(Id caseId) {
        List<AffectedVehicleWrapper> affectedVehiclesWrapper = new List<AffectedVehicleWrapper>();
        for (CaseVehicle__c affectedVhc : [
                SELECT
                        Id, Name, Case__c, Make__c,
                        VehicleYear__c, Model__c, FuelType__c,
                        DrivetrainDescription__c, EngineDescription__c,
                        TransmissionDescription__c, ModelCode__c, Notes__c,
                        Need_Review__c
                FROM CaseVehicle__c
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
            List<AggregateResult> vehicleMakes = [SELECT Make__c, COUNT(Name) FROM HMAReferenceData__c GROUP BY Make__c ORDER BY Make__c ASC];
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
    public static String getVehicleYears(String makes, String models, String selectedYears) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> modelsLst = models.split(';');
            Set<String> selectedVhcYearsLst;
            if (String.isNotEmpty(selectedYears)) {
                selectedVhcYearsLst = new Set<String> (selectedYears.split(';'));
            }
            List<AggregateResult> vehicleModels = [SELECT Year__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND VehicleModel__c IN:modelsLst GROUP BY Year__c ORDER BY Year__c DESC];
            for (AggregateResult result : vehicleModels) {
                if (result.get('Year__c') <> null) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (selectedVhcYearsLst <> null && selectedVhcYearsLst.contains(String.valueOf(result.get('Year__c')))) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('Year__c'));
                    optWrapper.value = String.valueOf(result.get('Year__c'));
                    optionsWrapper.add(optWrapper);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleModels(String makes, String selectedVehicleModels) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            Set<String> selectedVhcModelsLst;
            if (String.isNotEmpty(selectedVehicleModels)) {
                selectedVhcModelsLst = new Set<String> (selectedVehicleModels.split(';'));
            }
            List<AggregateResult> models = [SELECT VehicleModel__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst GROUP BY VehicleModel__c ORDER BY VehicleModel__c ASC];
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
    public static String getVehicleModelcodes(String makes, String years, String models, String selectedModelcodes) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> yearsLst = years.split(';');
            List<String> modelsLst = models.split(';');
            Set<String> selectedVhcModelCodesLst;
            if (String.isNotEmpty(selectedModelCodes)) {
                selectedVhcModelCodesLst = new Set<String> (selectedModelCodes.split(';'));
            }
            List<AggregateResult> modelCodes = [SELECT ModelCode__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND Year__c IN:yearsLst AND VehicleModel__c IN:modelsLst GROUP BY ModelCode__c ORDER BY ModelCode__c ASC];
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
    public static String getVehicleDrivetrains(String makes, String years, String models, String modelcodes, String selectedDrivetrains) {
        System.debug('Vehicle Drivetrains Params:: ' + makes + ', ' + years + ', ' + models + ', ' + modelcodes + ', ' + selectedDrivetrains);
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> yearsLst = years.split(';');
            List<String> modelsLst = models.split(';');
            List<String> modelCodesLst = modelCodes.split(';');
            Set<String> selectedVhcDrivetrainsLst;
            if (String.isNotEmpty(selectedDrivetrains)) {
                selectedVhcDrivetrainsLst = new Set<String> (selectedDrivetrains.split(';'));
            }
            List<AggregateResult> drivetrains;
            if (!isEmpty(modelcodes) && modelcodes.trim().length() > 0) {
                drivetrains = [SELECT DrivetrainDescription__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND Year__c IN:yearsLst AND VehicleModel__c IN:modelsLst AND ModelCode__c IN:modelCodesLst GROUP BY DrivetrainDescription__c ORDER BY DrivetrainDescription__c ASC];
            } else {
                drivetrains = [SELECT DrivetrainDescription__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND Year__c IN:yearsLst AND VehicleModel__c IN:modelsLst GROUP BY DrivetrainDescription__c ORDER BY DrivetrainDescription__c ASC];
            }
            for (AggregateResult result : drivetrains) {
                if (result.get('DrivetrainDescription__c') <> null) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (selectedVhcDrivetrainsLst <> null && selectedVhcDrivetrainsLst.contains(String.valueOf(result.get('DrivetrainDescription__c')))) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('DrivetrainDescription__c'));
                    optWrapper.value = String.valueOf(result.get('DrivetrainDescription__c'));
                    optionsWrapper.add(optWrapper);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleFueltypes(String makes, String years, String models, String modelcodes, String selectedFuelTypes) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> yearsLst = years.split(';');
            List<String> modelsLst = models.split(';');
            List<String> modelCodesLst = modelCodes.split(';');
            Set<String> selectedVhcFuelTypesLst;
            if (String.isNotEmpty(selectedFuelTypes)) {
                selectedVhcFuelTypesLst = new Set<String> (selectedFuelTypes.split(';'));
            }
            List<AggregateResult> fuelTypes;
            if (!isEmpty(modelcodes) && modelcodes.trim().length() > 0) {
                fuelTypes = [SELECT FuelType__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND Year__c IN:yearsLst AND VehicleModel__c IN:modelsLst AND ModelCode__c IN:modelCodesLst GROUP BY FuelType__c ORDER BY FuelType__c ASC];
            } else {
                fuelTypes = [SELECT FuelType__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND Year__c IN:yearsLst AND VehicleModel__c IN:modelsLst GROUP BY FuelType__c ORDER BY FuelType__c ASC];
            }

            for (AggregateResult result : fuelTypes) {
                if (result.get('FuelType__c') <> null) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (selectedVhcFuelTypesLst <> null && selectedVhcFuelTypesLst.contains(String.valueOf(result.get('FuelType__c')))) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('FuelType__c'));
                    optWrapper.value = String.valueOf(result.get('FuelType__c'));
                    optionsWrapper.add(optWrapper);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String getVehicleEngines(String makes, String years, String models, String modelcodes, String selectedEngines) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> yearsLst = years.split(';');
            List<String> modelsLst = models.split(';');
            List<String> modelCodesLst = modelCodes.split(';');
            Set<String> selectedVhcEnginesLst;
            if (String.isNotEmpty(selectedEngines)) {
                selectedVhcEnginesLst = new Set<String> (selectedEngines.split(';'));
            }
            List<AggregateResult> engines;
            if (!isEmpty(modelcodes) && modelcodes.trim().length() > 0) {
                engines = [SELECT EngineDescription__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND Year__c IN:yearsLst AND VehicleModel__c IN:modelsLst AND ModelCode__c IN:modelCodesLst GROUP BY EngineDescription__c ORDER BY EngineDescription__c ASC];
            } else {
                engines = [SELECT EngineDescription__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND Year__c IN:yearsLst AND VehicleModel__c IN:modelsLst GROUP BY EngineDescription__c ORDER BY EngineDescription__c ASC];
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
    public static String getVehicleTransmissions(String makes, String years, String models, String modelcodes, String selectedTransmissions) {
        List<VehicleOptionsWrapper> optionsWrapper = new List<VehicleOptionsWrapper>();
        try {
            List<String> makesLst = makes.split(';');
            List<String> yearsLst = years.split(';');
            List<String> modelsLst = models.split(';');
            List<String> modelCodesLst = modelCodes.split(';');
            Set<String> selectedVhcTransmissionsLst;
            if (String.isNotEmpty(selectedTransmissions)) {
                selectedVhcTransmissionsLst = new Set<String> (selectedTransmissions.split(';'));
            }
            List<AggregateResult> transmissions;
            if (!isEmpty(modelcodes) && modelcodes.trim().length() > 0) {
                transmissions = [SELECT TransmissionDescription__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND Year__c IN:yearsLst AND VehicleModel__c IN:modelsLst AND ModelCode__c IN:modelCodesLst GROUP BY TransmissionDescription__c ORDER BY TransmissionDescription__c ASC];
            } else {
                transmissions = [SELECT TransmissionDescription__c, COUNT(Name) FROM HMAReferenceData__c WHERE Make__c IN:makesLst AND Year__c IN:yearsLst AND VehicleModel__c IN:modelsLst GROUP BY TransmissionDescription__c ORDER BY TransmissionDescription__c ASC];
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
    public static String getVehicleUpdateOptions(String makes, String years, String models, String drivetrains, String fueltypes, String engines, String transmissions, String modelcodes) {
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

            Set<String> makesLstAdded = new Set<String>();
            Set<String> yearsLstAdded = new Set<String>();
            Set<String> modelsLstAdded = new Set<String>();
            Set<String> drivetrainsLstAdded = new Set<String>();
            Set<String> fuelTypesLstAdded = new Set<String>();
            Set<String> enginesLstAdded = new Set<String>();
            Set<String> transmissionsLstAdded = new Set<String>();
            Set<String> modelCodesLstAdded = new Set<String>();

            // 2023-10-16 SO-268 Bug fix (Too many query rows: 50001) by Bitna Seong -start-
            // List<HMAReferenceData__c> hmaReferenceData = [
            //         SELECT Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c
            //         FROM HMAReferenceData__c
            //         WHERE Make__c IN:makesLst
            //         AND VehicleModel__c IN:modelsLst
            // ];
            List<AggregateResult> hmaReferenceData = [
                    SELECT COUNT(Name), Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c
                    FROM HMAReferenceData__c
                    WHERE Make__c IN:makesLst
                    AND VehicleModel__c IN:modelsLst
                    GROUP BY Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c
            ];

            // for (HMAReferenceData__c result : hmaReferenceData) {
            //     if (result.Make__c <> null && !makesLstAdded.contains(String.valueOf(result.Make__c).toLowerCase())) {
            //         VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
            //         if (makesLst <> null && makesLst.contains(String.valueOf(result.Make__c).toLowerCase())) {
            //             optWrapper.isSelected = true;
            //         } else {
            //             optWrapper.isSelected = false;
            //         }
            //         optWrapper.label = String.valueOf(result.Make__c);
            //         optWrapper.value = String.valueOf(result.Make__c);
            //         makesLstAdded.add(String.valueOf(result.Make__c).toLowerCase());
            //         optionsWrapper.make.add(optWrapper);
            //     } if (result.VehicleModel__c <> null && !modelsLstAdded.contains(String.valueOf(result.VehicleModel__c).toLowerCase())) {
            //         VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
            //         if (modelsLst <> null && modelsLst.contains(String.valueOf(result.VehicleModel__c).toLowerCase())) {
            //             optWrapper.isSelected = true;
            //         } else {
            //             optWrapper.isSelected = false;
            //         }
            //         optWrapper.label = String.valueOf(result.VehicleModel__c);
            //         optWrapper.value = String.valueOf(result.VehicleModel__c);
            //         modelsLstAdded.add(String.valueOf(result.VehicleModel__c).toLowerCase());
            //         optionsWrapper.model.add(optWrapper);
            //     }
            //     if (result.Make__c <> null && result.VehicleModel__c <> null
            //             && valueInSet(result.Make__c, makesLst) && valueInSet(result.VehicleModel__c, modelsLst)) { // Show related years only
            //         if (result.Year__c <> null && !yearsLstAdded.contains(String.valueOf(result.Year__c).toLowerCase())) {
            //             VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
            //             if (yearsLst <> null && yearsLst.contains(String.valueOf(result.Year__c).toLowerCase())) {
            //                 optWrapper.isSelected = true;
            //             } else {
            //                 optWrapper.isSelected = false;
            //             }
            //             optWrapper.label = String.valueOf(result.Year__c);
            //             optWrapper.value = String.valueOf(result.Year__c);
            //             yearsLstAdded.add(String.valueOf(result.Year__c).toLowerCase());
            //             optionsWrapper.year.add(optWrapper);
            //         }
            //     }
            //     if (result.Make__c <> null && result.VehicleModel__c <> null && result.Year__c <> null
            //             && valueInSet(result.Make__c, makesLst) && valueInSet(result.VehicleModel__c, modelsLst) && valueInSet(result.Year__c, yearsLst)) { // show related optional options only
            //         if (result.FuelType__c <> null && !fuelTypesLstAdded.contains(String.valueOf(result.FuelType__c).toLowerCase())) {
            //             VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
            //             if (fuelTypesLst <> null && fuelTypesLst.contains(String.valueOf(result.FuelType__c).toLowerCase())) {
            //                 optWrapper.isSelected = true;
            //             } else {
            //                 optWrapper.isSelected = false;
            //             }
            //             optWrapper.label = String.valueOf(result.FuelType__c);
            //             optWrapper.value = String.valueOf(result.FuelType__c);
            //             fuelTypesLstAdded.add(String.valueOf(result.FuelType__c).toLowerCase());
            //             optionsWrapper.fuelType.add(optWrapper);
            //         }
            //         if (result.EngineDescription__c <> null && !enginesLstAdded.contains(String.valueOf(result.EngineDescription__c).toLowerCase())) {
            //             VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
            //             if (enginesLst <> null && enginesLst.contains(String.valueOf(result.EngineDescription__c).toLowerCase())) {
            //                 optWrapper.isSelected = true;
            //             } else {
            //                 optWrapper.isSelected = false;
            //             }
            //             optWrapper.label = String.valueOf(result.EngineDescription__c);
            //             optWrapper.value = String.valueOf(result.EngineDescription__c);
            //             enginesLstAdded.add(String.valueOf(result.EngineDescription__c).toLowerCase());
            //             optionsWrapper.engine.add(optWrapper);
            //         }
            //         if (result.DrivetrainDescription__c <> null && !drivetrainsLstAdded.contains(String.valueOf(result.DrivetrainDescription__c).toLowerCase())) {
            //             VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
            //             if (drivetrainsLst <> null && drivetrainsLst.contains(String.valueOf(result.DrivetrainDescription__c).toLowerCase())) {
            //                 optWrapper.isSelected = true;
            //             } else {
            //                 optWrapper.isSelected = false;
            //             }
            //             optWrapper.label = String.valueOf(result.DrivetrainDescription__c);
            //             optWrapper.value = String.valueOf(result.DrivetrainDescription__c);
            //             drivetrainsLstAdded.add(String.valueOf(result.DrivetrainDescription__c).toLowerCase());
            //             optionsWrapper.drivetrain.add(optWrapper);
            //         }
            //         if (result.TransmissionDescription__c <> null && !transmissionsLstAdded.contains(String.valueOf(result.TransmissionDescription__c).toLowerCase())) {
            //             VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
            //             if (transmissionsLst <> null && transmissionsLst.contains(String.valueOf(result.TransmissionDescription__c).toLowerCase())) {
            //                 optWrapper.isSelected = true;
            //             } else {
            //                 optWrapper.isSelected = false;
            //             }
            //             optWrapper.label = String.valueOf(result.TransmissionDescription__c);
            //             optWrapper.value = String.valueOf(result.TransmissionDescription__c);
            //             transmissionsLstAdded.add(String.valueOf(result.TransmissionDescription__c).toLowerCase());
            //             optionsWrapper.transmission.add(optWrapper);
            //         }
            //         if (result.ModelCode__c <> null && !modelCodesLstAdded.contains(String.valueOf(result.ModelCode__c).toLowerCase())) {
            //             VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
            //             if (modelCodesLst <> null && modelCodesLst.contains(String.valueOf(result.ModelCode__c).toLowerCase())) {
            //                 optWrapper.isSelected = true;
            //             } else {
            //                 optWrapper.isSelected = false;
            //             }
            //             optWrapper.label = String.valueOf(result.ModelCode__c);
            //             optWrapper.value = String.valueOf(result.ModelCode__c);
            //             modelCodesLstAdded.add(String.valueOf(result.ModelCode__c).toLowerCase());
            //             optionsWrapper.modelCode.add(optWrapper);
            //         }
            //     }
            // }
            for (AggregateResult result : hmaReferenceData) {
                if (result.get('Make__c') <> null && !makesLstAdded.contains(String.valueOf(result.get('Make__c')).toLowerCase())) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (makesLst <> null && makesLst.contains(String.valueOf(result.get('Make__c')).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('Make__c'));
                    optWrapper.value = String.valueOf(result.get('Make__c'));
                    makesLstAdded.add(String.valueOf(result.get('Make__c')).toLowerCase());
                    optionsWrapper.make.add(optWrapper);
                } if (result.get('VehicleModel__c') <> null && !modelsLstAdded.contains(String.valueOf(result.get('VehicleModel__c') ).toLowerCase())) {
                    VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                    if (modelsLst <> null && modelsLst.contains(String.valueOf(result.get('VehicleModel__c') ).toLowerCase())) {
                        optWrapper.isSelected = true;
                    } else {
                        optWrapper.isSelected = false;
                    }
                    optWrapper.label = String.valueOf(result.get('VehicleModel__c') );
                    optWrapper.value = String.valueOf(result.get('VehicleModel__c') );
                    modelsLstAdded.add(String.valueOf(result.get('VehicleModel__c') ).toLowerCase());
                    optionsWrapper.model.add(optWrapper);
                }
                if (result.get('Make__c') <> null && result.get('VehicleModel__c')  <> null
                        && valueInSet(String.valueOf(result.get('Make__c')), makesLst) && valueInSet(String.valueOf(result.get('VehicleModel__c')) , modelsLst)) { // Show related years only
                    if (result.get('Year__c') <> null && !yearsLstAdded.contains(String.valueOf(result.get('Year__c') ).toLowerCase())) {
                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                        if (yearsLst <> null && yearsLst.contains(String.valueOf(result.get('Year__c') ).toLowerCase())) {
                            optWrapper.isSelected = true;
                        } else {
                            optWrapper.isSelected = false;
                        }
                        optWrapper.label = String.valueOf(result.get('Year__c') );
                        optWrapper.value = String.valueOf(result.get('Year__c') );
                        yearsLstAdded.add(String.valueOf(result.get('Year__c') ).toLowerCase());
                        optionsWrapper.year.add(optWrapper);
                    }
                }
                if (result.get('Make__c') <> null && result.get('VehicleModel__c')  <> null && result.get('Year__c')  <> null
                        && valueInSet( String.valueOf(result.get('Make__c')), makesLst) && valueInSet(String.valueOf(result.get('VehicleModel__c')) , modelsLst) && valueInSet(String.valueOf(result.get('Year__c')) , yearsLst)) { // show related optional options only
                    if (result.get('FuelType__c')  <> null && !fuelTypesLstAdded.contains(String.valueOf(result.get('FuelType__c')).toLowerCase())) {
                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                        if (fuelTypesLst <> null && fuelTypesLst.contains(String.valueOf(result.get('FuelType__c')).toLowerCase())) {
                            optWrapper.isSelected = true;
                        } else {
                            optWrapper.isSelected = false;
                        }
                        optWrapper.label = String.valueOf(result.get('FuelType__c'));
                        optWrapper.value = String.valueOf(result.get('FuelType__c'));
                        fuelTypesLstAdded.add(String.valueOf(result.get('FuelType__c')).toLowerCase());
                        optionsWrapper.fuelType.add(optWrapper);
                    }
                    if (result.get('EngineDescription__c') <> null && !enginesLstAdded.contains(String.valueOf(result.get('EngineDescription__c')).toLowerCase())) {
                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                        if (enginesLst <> null && enginesLst.contains(String.valueOf(result.get('EngineDescription__c')).toLowerCase())) {
                            optWrapper.isSelected = true;
                        } else {
                            optWrapper.isSelected = false;
                        }
                        optWrapper.label = String.valueOf(result.get('EngineDescription__c'));
                        optWrapper.value = String.valueOf(result.get('EngineDescription__c'));
                        enginesLstAdded.add(String.valueOf(result.get('EngineDescription__c')).toLowerCase());
                        optionsWrapper.engine.add(optWrapper);
                    }
                    if (result.get('DrivetrainDescription__c') <> null && !drivetrainsLstAdded.contains(String.valueOf(result.get('DrivetrainDescription__c')).toLowerCase())) {
                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                        if (drivetrainsLst <> null && drivetrainsLst.contains(String.valueOf(result.get('DrivetrainDescription__c')).toLowerCase())) {
                            optWrapper.isSelected = true;
                        } else {
                            optWrapper.isSelected = false;
                        }
                        optWrapper.label = String.valueOf(result.get('DrivetrainDescription__c'));
                        optWrapper.value = String.valueOf(result.get('DrivetrainDescription__c'));
                        drivetrainsLstAdded.add(String.valueOf(result.get('DrivetrainDescription__c')).toLowerCase());
                        optionsWrapper.drivetrain.add(optWrapper);
                    }
                    if (result.get('TransmissionDescription__c') <> null && !transmissionsLstAdded.contains(String.valueOf(result.get('TransmissionDescription__c')).toLowerCase())) {
                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                        if (transmissionsLst <> null && transmissionsLst.contains(String.valueOf(result.get('TransmissionDescription__c')).toLowerCase())) {
                            optWrapper.isSelected = true;
                        } else {
                            optWrapper.isSelected = false;
                        }
                        optWrapper.label = String.valueOf(result.get('TransmissionDescription__c'));
                        optWrapper.value = String.valueOf(result.get('TransmissionDescription__c'));
                        transmissionsLstAdded.add(String.valueOf(result.get('TransmissionDescription__c')).toLowerCase());
                        optionsWrapper.transmission.add(optWrapper);
                    }
                    if (result.get('ModelCode__c') <> null && !modelCodesLstAdded.contains(String.valueOf(result.get('ModelCode__c')).toLowerCase())) {
                        VehicleOptionsWrapper optWrapper = new VehicleOptionsWrapper();
                        if (modelCodesLst <> null && modelCodesLst.contains(String.valueOf(result.get('ModelCode__c')).toLowerCase())) {
                            optWrapper.isSelected = true;
                        } else {
                            optWrapper.isSelected = false;
                        }
                        optWrapper.label = String.valueOf(result.get('ModelCode__c'));
                        optWrapper.value = String.valueOf(result.get('ModelCode__c'));
                        modelCodesLstAdded.add(String.valueOf(result.get('ModelCode__c')).toLowerCase());
                        optionsWrapper.modelCode.add(optWrapper);
                    }
                }
            }
            // 2023-10-16 SO-268 Bug fix (Too many query rows: 50001) by Bitna Seong  -end-
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return JSON.serializePretty(optionsWrapper);
    }

    @AuraEnabled
    public static String saveVehicles(
            String caseid,
            String makes,
            String years,
            String models,
            String drivetrains,
            String fueltypes,
            String engines,
            String transmissions,
            String modelcodes
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

            returnStr += 'makesLst Size: ' + makesLst.size();
            returnStr += '\nyearsLst Size: ' + yearsLst.size();
            returnStr += '\nmodelsLst Size: ' + modelsLst.size();
            returnStr += '\ndrivetrainsLst Size: ' + drivetrainsLst.size();
            returnStr += '\nfuelTypesLst Size: ' + fuelTypesLst.size();
            returnStr += '\n' + JSON.serializePretty(fuelTypesLst);
            returnStr += '\nenginesLst Size: ' + enginesLst.size();
            returnStr += '\ntransmissionsLst Size: ' + transmissionsLst.size();
            returnStr += '\nmodelCodesLst Size: ' + modelCodesLst.size();

            List<CaseVehicle__c> existingCaseVehiclesLst = [
                    SELECT
                            Id, Name, Case__c, Make__c, Model__c, VehicleYear__c, EngineDescription__c, FuelType__c,
                            DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c, Notes__c
                    FROM CaseVehicle__c
                    WHERE Case__c = :caseId
                    AND Need_Review__c = FALSE
            ];
            returnStr += '\nexistingCaseVehicles Size: ' + existingCaseVehiclesLst.size();

            Map<String, CaseVehicle__c> existVehicleMap = new Map<String, CaseVehicle__c>();
            for (CaseVehicle__c caseVhc : existingCaseVehiclesLst) {

                String mapKey = getCVMapKey(caseVhc.Make__c, caseVhc.Model__c, caseVhc.ModelCode__c);

                if (!existVehicleMap.containsKey(mapKey)) {
                    caseVhc.VehicleYear__c = '';
                    caseVhc.FuelType__c = '';
                    caseVhc.EngineDescription__c = '';
                    caseVhc.DrivetrainDescription__c = '';
                    caseVhc.TransmissionDescription__c = '';
                    if (caseVhc.ModelCode__c == null) {
                        caseVhc.ModelCode__c = '';
                    }
                    existVehicleMap.put(mapKey, caseVhc);
                }
            }

            //San,Kang 23/10/16 : SO-268 too many soql Issue 
            List<AggregateResult> referenceData;
            String queryString = 'SELECT  count(Name), Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c,' +
                    'DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c\n' +
                    'FROM HMAReferenceData__c\n' +
                    'WHERE Make__c IN:makesLst\n' +
                    'AND VehicleModel__c IN:modelsLst\n' +
                    'AND Year__c IN :yearsLst';
            if (modelCodesLst.size() > 0) {
                queryString += ' AND ModelCode__c IN :modelCodesLst';
            }
                queryString += ' group by  Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c';

            referenceData = Database.query(queryString);

            returnStr += '\nreferenceData Size: ' + referenceData.size();

            Map<String, CaseVehicle__c> caseVehiclesToCreate = new Map<String, CaseVehicle__c>();
            Map<String, CaseVehicle__c> caseVehiclesToUpdate = new Map<String, CaseVehicle__c>();

            for (AggregateResult referenceRecord : referenceData) {
                for (String make : makesLst) {
                    for (String model : modelsLst) {

                        // Find a HMA Reference Data match
                        if (referenceRecord.get('Make__c') <> null && referenceRecord.get('VehicleModel__c') <> null
                                && String.valueOf(referenceRecord.get('Make__c')).equalsIgnoreCase(make) && String.valueOf(referenceRecord.get('VehicleModel__c')).equalsIgnoreCase(model)) {

                            String partialKey = getCVMapKey(String.valueOf(referenceRecord.get('Make__c')), String.valueOf(referenceRecord.get('VehicleModel__c')), null);

                            String mapKey = modelCodesLst.size() > 0 ?
                                    getCVMapKey(String.valueOf(referenceRecord.get('Make__c')), String.valueOf(referenceRecord.get('VehicleModel__c')), String.valueOf(referenceRecord.get('ModelCode__c'))) :
                                    getCVMapKey(String.valueOf(referenceRecord.get('Make__c')), String.valueOf(referenceRecord.get('VehicleModel__c')), null);

                            // If a model code is newly selected, attach the existing record to it.
                            if (existVehicleMap.containsKey(partialKey) && !partialKey.equals(mapKey)) {
                                CaseVehicle__c caseVhc = existVehicleMap.get(partialKey);
                                existVehicleMap.put(mapKey, caseVhc);
                                existVehicleMap.remove(partialKey);
                            }

                            // The Vehicle Case record exists in the system -> Update the existing record values
                            if (existVehicleMap.containsKey(mapKey)) {
                                CaseVehicle__c caseVhc = caseVehiclesToUpdate.containsKey(mapKey) ? caseVehiclesToUpdate.get(mapKey) : existVehicleMap.get(mapKey);
                                Set<String> caseVhcYearLst = convertMultiSelectStringToSet(caseVhc.VehicleYear__c);
                                Set<String> caseVhcFuelTypeLst = convertMultiSelectStringToSet(caseVhc.FuelType__c);
                                Set<String> caseVhcEngineLst = convertMultiSelectStringToSet(caseVhc.EngineDescription__c);
                                Set<String> caseVhcDrivetrainLst = convertMultiSelectStringToSet(caseVhc.DrivetrainDescription__c);
                                Set<String> caseVhcTransmissionLst = convertMultiSelectStringToSet(caseVhc.TransmissionDescription__c);
                                Set<String> caseVhcModelCodeLst = convertMultiSelectStringToSet(caseVhc.ModelCode__c);

                                if (String.valueOf(referenceRecord.get('Year__c')) <> null && yearsLst.contains(String.valueOf(referenceRecord.get('Year__c')).toLowerCase()) && !caseVhcYearLst.contains(String.valueOf(referenceRecord.get('Year__c')).toLowerCase().trim())) {
                                    caseVhc.VehicleYear__c += ';' + String.valueOf(referenceRecord.get('Year__c')).trim();
                                }
                                if (String.valueOf(referenceRecord.get('FuelType__c')) <> null && fuelTypesLst.contains(String.valueOf(referenceRecord.get('FuelType__c')).toLowerCase()) && !caseVhcFuelTypeLst.contains(String.valueOf(referenceRecord.get('FuelType__c')).toLowerCase().trim())) {
                                    caseVhc.FuelType__c += ';' + String.valueOf(referenceRecord.get('FuelType__c')).trim();
                                }
                                if (String.valueOf(referenceRecord.get('EngineDescription__c')) <> null && enginesLst.contains(String.valueOf(referenceRecord.get('EngineDescription__c')).toLowerCase()) && !caseVhcEngineLst.contains(String.valueOf(referenceRecord.get('EngineDescription__c')).toLowerCase().trim())) {
                                    caseVhc.EngineDescription__c += ';' + String.valueOf(referenceRecord.get('EngineDescription__c')).toLowerCase().trim();
                                }
                                if (String.valueOf(referenceRecord.get('DrivetrainDescription__c')) <> null && drivetrainsLst.contains(String.valueOf(referenceRecord.get('DrivetrainDescription__c')).toLowerCase()) && !caseVhcDrivetrainLst.contains(String.valueOf(referenceRecord.get('DrivetrainDescription__c')).toLowerCase().trim())) {
                                    caseVhc.DrivetrainDescription__c += ';' + String.valueOf(referenceRecord.get('DrivetrainDescription__c')).toLowerCase().trim();
                                }
                                if (String.valueOf(referenceRecord.get('TransmissionDescription__c')) <> null && transmissionsLst.contains(String.valueOf(referenceRecord.get('TransmissionDescription__c')).toLowerCase()) && !caseVhcTransmissionLst.contains(String.valueOf(referenceRecord.get('TransmissionDescription__c')).toLowerCase().trim())) {
                                    caseVhc.TransmissionDescription__c += ';' + String.valueOf(referenceRecord.get('TransmissionDescription__c')).toLowerCase().trim();
                                }
                                if (String.valueOf(referenceRecord.get('ModelCode__c')) <> null && modelCodesLst.contains(String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase()) && modelCodesLst.contains(String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase()) && !caseVhcModelCodeLst.contains(String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase().trim())) {
                                    caseVhc.ModelCode__c += ';' + String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase().trim();
                                }
                                caseVhc.HasModelCode__c = !String.isEmpty(caseVhc.ModelCode__c) ? true : false;
                                if (!caseVehiclesToUpdate.containsKey(mapKey)) {
                                    caseVehiclesToUpdate.put(mapKey, caseVhc);
                                }
                            }
                            // Remove any duplicate values in the new Case Vehicle records
                            else if (caseVehiclesToCreate.containsKey(mapKey)) {
                                CaseVehicle__c caseVhc = caseVehiclesToCreate.get(mapKey);
                                Set<String> caseVhcYearLst = convertMultiSelectStringToSet(caseVhc.VehicleYear__c);
                                Set<String> caseVhcFuelTypeLst = convertMultiSelectStringToSet(caseVhc.FuelType__c);
                                Set<String> caseVhcEngineLst = convertMultiSelectStringToSet(caseVhc.EngineDescription__c);
                                Set<String> caseVhcDrivetrainLst = convertMultiSelectStringToSet(caseVhc.DrivetrainDescription__c);
                                Set<String> caseVhcTransmissionLst = convertMultiSelectStringToSet(caseVhc.TransmissionDescription__c);
                                Set<String> caseVhcModelCodeLst = convertMultiSelectStringToSet(caseVhc.ModelCode__c);

                                if (String.valueOf(referenceRecord.get('Year__c')) <> null && !caseVhcYearLst.contains(String.valueOf(referenceRecord.get('Year__c'))) && yearsLst.contains(String.valueOf(referenceRecord.get('Year__c')))) {
                                    caseVhc.VehicleYear__c += ';' + String.valueOf(referenceRecord.get('Year__c'));
                                }
                                if (String.valueOf(referenceRecord.get('FuelType__c')) <> null && !caseVhcFuelTypeLst.contains(String.valueOf(referenceRecord.get('FuelType__c')).toLowerCase()) && fuelTypesLst.contains(String.valueOf(referenceRecord.get('FuelType__c')).toLowerCase())) {
                                    caseVhc.FuelType__c += ';' + String.valueOf(referenceRecord.get('FuelType__c'));
                                }
                                if (String.valueOf(referenceRecord.get('EngineDescription__c')) <> null && !caseVhcEngineLst.contains(String.valueOf(referenceRecord.get('EngineDescription__c')).toLowerCase()) && enginesLst.contains(String.valueOf(referenceRecord.get('EngineDescription__c')).toLowerCase())) {
                                    caseVhc.EngineDescription__c += ';' + String.valueOf(referenceRecord.get('EngineDescription__c'));
                                }
                                if (String.valueOf(referenceRecord.get('DrivetrainDescription__c')) <> null && !caseVhcDrivetrainLst.contains(String.valueOf(referenceRecord.get('DrivetrainDescription__c')).toLowerCase()) && drivetrainsLst.contains(String.valueOf(referenceRecord.get('DrivetrainDescription__c')).toLowerCase())) {
                                    caseVhc.DrivetrainDescription__c += ';' + String.valueOf(referenceRecord.get('DrivetrainDescription__c'));
                                }
                                if (String.valueOf(referenceRecord.get('TransmissionDescription__c')) <> null && !caseVhcTransmissionLst.contains(String.valueOf(referenceRecord.get('TransmissionDescription__c')).toLowerCase()) && transmissionsLst.contains(String.valueOf(referenceRecord.get('TransmissionDescription__c')).toLowerCase())) {
                                    caseVhc.TransmissionDescription__c += ';' + String.valueOf(referenceRecord.get('TransmissionDescription__c'));
                                }
                                if (String.valueOf(referenceRecord.get('ModelCode__c')) <> null && !caseVhcModelCodeLst.contains(String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase()) && modelCodesLst.contains(String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase())) {
                                    caseVhc.ModelCode__c += ';' + String.valueOf(referenceRecord.get('ModelCode__c'));
                                }
                                caseVhc.HasModelCode__c = !String.isEmpty(caseVhc.ModelCode__c) ? true : false;
                            }
                            // New Case Vehicle records -> Create new record
                            else {
                                CaseVehicle__c caseVhc = new CaseVehicle__c();
                                caseVhc.Case__c = caseid;

                                caseVhc.Make__c = valueInSet(String.valueOf(referenceRecord.get('Make__c')), makesLst) ? String.valueOf(referenceRecord.get('Make__c')) : '';
                                caseVhc.Model__c = valueInSet(String.valueOf(referenceRecord.get('VehicleModel__c')), modelsLst) ? String.valueOf(referenceRecord.get('VehicleModel__c')) : '';
                                caseVhc.VehicleYear__c = valueInSet(String.valueOf(referenceRecord.get('Year__c')), yearsLst) ? String.valueOf(referenceRecord.get('Year__c')) : '';
                                caseVhc.FuelType__c = valueInSet(String.valueOf(referenceRecord.get('FuelType__c')), fuelTypesLst) ? String.valueOf(referenceRecord.get('FuelType__c')) : '';
                                caseVhc.EngineDescription__c = valueInSet(String.valueOf(referenceRecord.get('EngineDescription__c')), enginesLst) ? String.valueOf(referenceRecord.get('EngineDescription__c')) : '';
                                caseVhc.DrivetrainDescription__c = valueInSet(String.valueOf(referenceRecord.get('DrivetrainDescription__c')), drivetrainsLst) ? String.valueOf(referenceRecord.get('DrivetrainDescription__c')) : '';
                                caseVhc.TransmissionDescription__c = valueInSet(String.valueOf(referenceRecord.get('TransmissionDescription__c')), transmissionsLst) ? String.valueOf(referenceRecord.get('TransmissionDescription__c')) : '';
                                caseVhc.ModelCode__c = valueInSet(String.valueOf(referenceRecord.get('ModelCode__c')), modelCodesLst) ? String.valueOf(referenceRecord.get('ModelCode__c')) : '';
                                caseVhc.HasModelCode__c = !String.isEmpty(caseVhc.ModelCode__c) ? true : false;

                                caseVehiclesToCreate.put(mapKey, caseVhc);
                            }
                        }
                    }
                }
            }
            // List<HMAReferenceData__c> referenceData;
            // String queryString = 'SELECT Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c,' +
            //         'DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c\n' +
            //         'FROM HMAReferenceData__c\n' +
            //         'WHERE Make__c IN:makesLst\n' +
            //         'AND VehicleModel__c IN:modelsLst\n' +
            //         'AND Year__c IN :yearsLst';
            // if (modelCodesLst.size() > 0) {
            //     queryString += ' AND ModelCode__c IN :modelCodesLst';
            // }

            // referenceData = Database.query(queryString);

            // returnStr += '\nreferenceData Size: ' + referenceData.size();

            // Map<String, CaseVehicle__c> caseVehiclesToCreate = new Map<String, CaseVehicle__c>();
            // Map<String, CaseVehicle__c> caseVehiclesToUpdate = new Map<String, CaseVehicle__c>();

            // for (HMAReferenceData__c referenceRecord : referenceData) {
            //     for (String make : makesLst) {
            //         for (String model : modelsLst) {

            //             // Find a HMA Reference Data match
            //             if (referenceRecord.Make__c <> null && referenceRecord.VehicleModel__c <> null
            //                     && referenceRecord.Make__c.equalsIgnoreCase(make) && referenceRecord.VehicleModel__c.equalsIgnoreCase(model)) {

            //                 String partialKey = getCVMapKey(referenceRecord.Make__c, referenceRecord.VehicleModel__c, null);

            //                 String mapKey = modelCodesLst.size() > 0 ?
            //                         getCVMapKey(referenceRecord.Make__c, referenceRecord.VehicleModel__c, referenceRecord.ModelCode__c) :
            //                         getCVMapKey(referenceRecord.Make__c, referenceRecord.VehicleModel__c, null);

            //                 // If a model code is newly selected, attach the existing record to it.
            //                 if (existVehicleMap.containsKey(partialKey) && !partialKey.equals(mapKey)) {
            //                     CaseVehicle__c caseVhc = existVehicleMap.get(partialKey);
            //                     existVehicleMap.put(mapKey, caseVhc);
            //                     existVehicleMap.remove(partialKey);
            //                 }

            //                 // The Vehicle Case record exists in the system -> Update the existing record values
            //                 if (existVehicleMap.containsKey(mapKey)) {
            //                     CaseVehicle__c caseVhc = caseVehiclesToUpdate.containsKey(mapKey) ? caseVehiclesToUpdate.get(mapKey) : existVehicleMap.get(mapKey);
            //                     Set<String> caseVhcYearLst = convertMultiSelectStringToSet(caseVhc.VehicleYear__c);
            //                     Set<String> caseVhcFuelTypeLst = convertMultiSelectStringToSet(caseVhc.FuelType__c);
            //                     Set<String> caseVhcEngineLst = convertMultiSelectStringToSet(caseVhc.EngineDescription__c);
            //                     Set<String> caseVhcDrivetrainLst = convertMultiSelectStringToSet(caseVhc.DrivetrainDescription__c);
            //                     Set<String> caseVhcTransmissionLst = convertMultiSelectStringToSet(caseVhc.TransmissionDescription__c);
            //                     Set<String> caseVhcModelCodeLst = convertMultiSelectStringToSet(caseVhc.ModelCode__c);

            //                     if (referenceRecord.Year__c <> null && yearsLst.contains(referenceRecord.Year__c.toLowerCase()) && !caseVhcYearLst.contains(referenceRecord.Year__c.toLowerCase().trim())) {
            //                         caseVhc.VehicleYear__c += ';' + referenceRecord.Year__c.trim();
            //                     }
            //                     if (referenceRecord.FuelType__c <> null && fuelTypesLst.contains(referenceRecord.FuelType__c.toLowerCase()) && !caseVhcFuelTypeLst.contains(referenceRecord.FuelType__c.toLowerCase().trim())) {
            //                         caseVhc.FuelType__c += ';' + referenceRecord.FuelType__c.trim();
            //                     }
            //                     if (referenceRecord.EngineDescription__c <> null && enginesLst.contains(referenceRecord.EngineDescription__c.toLowerCase()) && !caseVhcEngineLst.contains(referenceRecord.EngineDescription__c.toLowerCase().trim())) {
            //                         caseVhc.EngineDescription__c += ';' + referenceRecord.EngineDescription__c.toLowerCase().trim();
            //                     }
            //                     if (referenceRecord.DrivetrainDescription__c <> null && drivetrainsLst.contains(referenceRecord.DrivetrainDescription__c.toLowerCase()) && !caseVhcDrivetrainLst.contains(referenceRecord.DrivetrainDescription__c.toLowerCase().trim())) {
            //                         caseVhc.DrivetrainDescription__c += ';' + referenceRecord.DrivetrainDescription__c.toLowerCase().trim();
            //                     }
            //                     if (referenceRecord.TransmissionDescription__c <> null && transmissionsLst.contains(referenceRecord.TransmissionDescription__c.toLowerCase()) && !caseVhcTransmissionLst.contains(referenceRecord.TransmissionDescription__c.toLowerCase().trim())) {
            //                         caseVhc.TransmissionDescription__c += ';' + referenceRecord.TransmissionDescription__c.toLowerCase().trim();
            //                     }
            //                     if (referenceRecord.ModelCode__c <> null && modelCodesLst.contains(referenceRecord.ModelCode__c.toLowerCase()) && modelCodesLst.contains(referenceRecord.ModelCode__c.toLowerCase()) && !caseVhcModelCodeLst.contains(referenceRecord.ModelCode__c.toLowerCase().trim())) {
            //                         caseVhc.ModelCode__c += ';' + referenceRecord.ModelCode__c.toLowerCase().trim();
            //                     }
            //                     caseVhc.HasModelCode__c = !String.isEmpty(caseVhc.ModelCode__c) ? true : false;
            //                     if (!caseVehiclesToUpdate.containsKey(mapKey)) {
            //                         caseVehiclesToUpdate.put(mapKey, caseVhc);
            //                     }
            //                 }
            //                 // Remove any duplicate values in the new Case Vehicle records
            //                 else if (caseVehiclesToCreate.containsKey(mapKey)) {
            //                     CaseVehicle__c caseVhc = caseVehiclesToCreate.get(mapKey);
            //                     Set<String> caseVhcYearLst = convertMultiSelectStringToSet(caseVhc.VehicleYear__c);
            //                     Set<String> caseVhcFuelTypeLst = convertMultiSelectStringToSet(caseVhc.FuelType__c);
            //                     Set<String> caseVhcEngineLst = convertMultiSelectStringToSet(caseVhc.EngineDescription__c);
            //                     Set<String> caseVhcDrivetrainLst = convertMultiSelectStringToSet(caseVhc.DrivetrainDescription__c);
            //                     Set<String> caseVhcTransmissionLst = convertMultiSelectStringToSet(caseVhc.TransmissionDescription__c);
            //                     Set<String> caseVhcModelCodeLst = convertMultiSelectStringToSet(caseVhc.ModelCode__c);

            //                     if (referenceRecord.Year__c <> null && !caseVhcYearLst.contains(referenceRecord.Year__c) && yearsLst.contains(referenceRecord.Year__c)) {
            //                         caseVhc.VehicleYear__c += ';' + referenceRecord.Year__c;
            //                     }
            //                     if (referenceRecord.FuelType__c <> null && !caseVhcFuelTypeLst.contains(referenceRecord.FuelType__c.toLowerCase()) && fuelTypesLst.contains(referenceRecord.FuelType__c.toLowerCase())) {
            //                         caseVhc.FuelType__c += ';' + referenceRecord.FuelType__c;
            //                     }
            //                     if (referenceRecord.EngineDescription__c <> null && !caseVhcEngineLst.contains(referenceRecord.EngineDescription__c.toLowerCase()) && enginesLst.contains(referenceRecord.EngineDescription__c.toLowerCase())) {
            //                         caseVhc.EngineDescription__c += ';' + referenceRecord.EngineDescription__c;
            //                     }
            //                     if (referenceRecord.DrivetrainDescription__c <> null && !caseVhcDrivetrainLst.contains(referenceRecord.DrivetrainDescription__c.toLowerCase()) && drivetrainsLst.contains(referenceRecord.DrivetrainDescription__c.toLowerCase())) {
            //                         caseVhc.DrivetrainDescription__c += ';' + referenceRecord.DrivetrainDescription__c;
            //                     }
            //                     if (referenceRecord.TransmissionDescription__c <> null && !caseVhcTransmissionLst.contains(referenceRecord.TransmissionDescription__c.toLowerCase()) && transmissionsLst.contains(referenceRecord.TransmissionDescription__c.toLowerCase())) {
            //                         caseVhc.TransmissionDescription__c += ';' + referenceRecord.TransmissionDescription__c;
            //                     }
            //                     if (referenceRecord.ModelCode__c <> null && !caseVhcModelCodeLst.contains(referenceRecord.ModelCode__c.toLowerCase()) && modelCodesLst.contains(referenceRecord.ModelCode__c.toLowerCase())) {
            //                         caseVhc.ModelCode__c += ';' + referenceRecord.ModelCode__c;
            //                     }
            //                     caseVhc.HasModelCode__c = !String.isEmpty(caseVhc.ModelCode__c) ? true : false;
            //                 }
            //                 // New Case Vehicle records -> Create new record
            //                 else {
            //                     CaseVehicle__c caseVhc = new CaseVehicle__c();
            //                     caseVhc.Case__c = caseid;

            //                     caseVhc.Make__c = valueInSet(referenceRecord.Make__c, makesLst) ? referenceRecord.Make__c : '';
            //                     caseVhc.Model__c = valueInSet(referenceRecord.VehicleModel__c, modelsLst) ? referenceRecord.VehicleModel__c : '';
            //                     caseVhc.VehicleYear__c = valueInSet(referenceRecord.Year__c, yearsLst) ? referenceRecord.Year__c : '';
            //                     caseVhc.FuelType__c = valueInSet(referenceRecord.FuelType__c, fuelTypesLst) ? referenceRecord.FuelType__c : '';
            //                     caseVhc.EngineDescription__c = valueInSet(referenceRecord.EngineDescription__c, enginesLst) ? referenceRecord.EngineDescription__c : '';
            //                     caseVhc.DrivetrainDescription__c = valueInSet(referenceRecord.DrivetrainDescription__c, drivetrainsLst) ? referenceRecord.DrivetrainDescription__c : '';
            //                     caseVhc.TransmissionDescription__c = valueInSet(referenceRecord.TransmissionDescription__c, transmissionsLst) ? referenceRecord.TransmissionDescription__c : '';
            //                     caseVhc.ModelCode__c = valueInSet(referenceRecord.ModelCode__c, modelCodesLst) ? referenceRecord.ModelCode__c : '';
            //                     caseVhc.HasModelCode__c = !String.isEmpty(caseVhc.ModelCode__c) ? true : false;

            //                     caseVehiclesToCreate.put(mapKey, caseVhc);
            //                 }
            //             }
            //         }
            //     }
            // }

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

    private static String getCVMapKey(String make, String model, String modelCode) {
        if (modelCode <> null && String.isNotEmpty(modelCode)) {
            return String.valueOf(make).toLowerCase().trim() + '_' + String.valueOf(model).toLowerCase().trim() + '_' + String.valueOf(modelCode).toLowerCase().trim();
        }
        return String.valueOf(make).toLowerCase().trim() + '_' + String.valueOf(model).toLowerCase().trim();
    }

    public static void updateCaseVehicleInfo(String caseid) {
        List<CaseVehicle__c> affectedVehicles = [SELECT Id, Name, Case__c, Make__c, Model__c, VehicleYear__c, EngineDescription__c, FuelType__c, DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c, Notes__c FROM CaseVehicle__c WHERE Case__c = :caseId];

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

            for (CaseVehicle__c vhc : affectedVehicles) {
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
                List<CaseVehicle__c> caseVehicles = [SELECT Id FROM CaseVehicle__c WHERE Id IN:vehicleIdsList];
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
                List<CaseVehicle__c> caseVehicles = [SELECT Id FROM CaseVehicle__c WHERE Case__c = :caseId];
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