/**
 * Created by baltamimi on 2022-01-28.
 */

public without sharing class CaseVehicleBulkCreateBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Integer batchNumber = 0;
    public Integer numberAttempted = 0;
    public Integer numberFailed = 0;

    private Boolean runMissingCVOnly;

    private CaseVehicleBulkCreateBatch() {

    }
    private CaseVehicleBulkCreateBatch(Boolean runMissingCVOnly) {
        this.runMissingCVOnly = runMissingCVOnly;
    }

    public static Id runJob(Integer batchSize, Boolean missingCaseVehicleOnly) {
        return Database.executeBatch(new CaseVehicleBulkCreateBatch(missingCaseVehicleOnly), batchSize);
    }
    public static Id runJob(Boolean missingCaseVehicleOnly) {
        return runJob(20, missingCaseVehicleOnly);
    }

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        if (runMissingCVOnly) {
            return Database.getQueryLocator([
                    SELECT
                            Id,
                            Make__c,
                            VehicleModel__c,
                            ModelCode__c,
                            MY__c,
                            Drivetrain__c,
                            Fuel_Type__c,
                            Trans__c,
                            Engine__c
                    FROM Case
                    WHERE Id NOT IN (SELECT Case__c FROM CaseVehicle__c)
            ]);
        }
        return Database.getQueryLocator([
                SELECT
                        Id,
                        Make__c,
                        VehicleModel__c,
                        ModelCode__c,
                        MY__c,
                        Drivetrain__c,
                        Fuel_Type__c,
                        Trans__c,
                        Engine__c
                FROM Case
        ]);
    }

    public void execute(Database.BatchableContext ctx, List<Case> cases) {
        List<CaseVehicle__c> caseVehiclesToInsert = new List<CaseVehicle__c>();
        List<Case> casesToUpdate = new List<Case>();

        batchNumber += 1;
        numberAttempted += cases.size();
        for (Case c : cases) {
            try {
                List<CaseVehicle__c> cvToCreate = generateCaseVehicles(c);
                if (cvToCreate.size() > 0) {
                    caseVehiclesToInsert.addAll(cvToCreate);
                    Case updatedCase = updateCaseFields(c, cvToCreate);
                    casesToUpdate.add(updatedCase);
                }
            } catch (Exception err) {
                System.debug('Error on processing record "' + c.Id + '". Error Details:');
                System.debug('Message: ' + err.getMessage());
                System.debug('Line Number: ' + err.getLineNumber());
                System.debug('Stacktrace: ' + err.getStackTraceString());

                numberFailed += 1;
            }
        }

        if (caseVehiclesToInsert.size() > 0) {
            insert caseVehiclesToInsert;
        }
        if (casesToUpdate.size() > 0) {
            update casesToUpdate;
        }
    }

    public void finish(Database.BatchableContext ctx) {
        System.debug('-----------------------');
        System.debug('Finished Processing batch #' + batchNumber);
        System.debug('Number of records attempted: ' + numberAttempted);
        System.debug('Number of records Processed Successfully: ' + (numberAttempted - numberFailed));
        System.debug('Number of records Failed to be processed: ' + numberFailed);
        System.debug('-----------------------');

    }

    private List<CaseVehicle__c> generateCaseVehicles(Case sourceCase) {
        String caseId = sourceCase.Id;

        Set<String> makesLst = convertMultiSelectStringToSet(sourceCase.Make__c);
        if (makesLst.size() == 0) {
            makesLst = new Set<String>{
                    'hyundai', 'genesis'
            };
        }
        Set<String> yearsLst = convertMultiSelectStringToSet(sourceCase.MY__c);
        Set<String> modelsLst = convertMultiSelectStringToSet(sourceCase.VehicleModel__c);
        Set<String> drivetrainsLst = convertMultiSelectStringToSet(sourceCase.Drivetrain__c);
        Set<String> fuelTypesLst = convertMultiSelectStringToSet(sourceCase.Fuel_Type__c);
        Set<String> enginesLst = convertMultiSelectStringToSet(sourceCase.Engine__c);
        Set<String> transmissionsLst = convertMultiSelectStringToSet(sourceCase.Trans__c);
        Set<String> modelCodesLst = convertMultiSelectStringToSet(sourceCase.ModelCode__c);

        List<HMAReferenceData__c> referenceData;
        String queryString = 'SELECT Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c,' +
                'DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c\n' +
                'FROM HMAReferenceData__c\n' +
                'WHERE Make__c IN:makesLst\n' +
                'AND VehicleModel__c IN:modelsLst\n' +
                'AND Year__c IN :yearsLst';
        if (modelCodesLst.size() > 0) {
            queryString += ' AND ModelCode__c IN :modelCodesLst';
        }

        referenceData = Database.query(queryString);

        Map<String, CaseVehicle__c> caseVehiclesToCreate = new Map<String, CaseVehicle__c>();

        for (HMAReferenceData__c referenceRecord : referenceData) {
            for (String make : makesLst) {
                for (String model : modelsLst) {

                    // Find a HMA Reference Data match
                    if (referenceRecord.Make__c <> null && referenceRecord.VehicleModel__c <> null
                            && referenceRecord.Make__c.equalsIgnoreCase(make) && referenceRecord.VehicleModel__c.equalsIgnoreCase(model)) {

                        String mapKey = modelCodesLst.size() > 0 ?
                                getCVMapKey(referenceRecord.Make__c, referenceRecord.VehicleModel__c, referenceRecord.ModelCode__c) :
                                getCVMapKey(referenceRecord.Make__c, referenceRecord.VehicleModel__c, null);

                        // Remove any duplicate values in the new Case Vehicle records
                        if (caseVehiclesToCreate.containsKey(mapKey)) {
                            CaseVehicle__c caseVhc = caseVehiclesToCreate.get(mapKey);
                            Set<String> caseVhcYearLst = convertMultiSelectStringToSet(caseVhc.VehicleYear__c);
                            Set<String> caseVhcFuelTypeLst = convertMultiSelectStringToSet(caseVhc.FuelType__c);
                            Set<String> caseVhcEngineLst = convertMultiSelectStringToSet(caseVhc.EngineDescription__c);
                            Set<String> caseVhcDrivetrainLst = convertMultiSelectStringToSet(caseVhc.DrivetrainDescription__c);
                            Set<String> caseVhcTransmissionLst = convertMultiSelectStringToSet(caseVhc.TransmissionDescription__c);
                            Set<String> caseVhcModelCodeLst = convertMultiSelectStringToSet(caseVhc.ModelCode__c);

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
                            CaseVehicle__c caseVhc = new CaseVehicle__c();
                            caseVhc.Case__c = caseId;

                            caseVhc.Make__c = valueInSet(referenceRecord.Make__c, makesLst) ? referenceRecord.Make__c : '';
                            caseVhc.Model__c = valueInSet(referenceRecord.VehicleModel__c, modelsLst) ? referenceRecord.VehicleModel__c : '';
                            caseVhc.VehicleYear__c = valueInSet(referenceRecord.Year__c, yearsLst) ? referenceRecord.Year__c : '';
                            caseVhc.FuelType__c = valueInSet(referenceRecord.FuelType__c, fuelTypesLst) ? referenceRecord.FuelType__c : '';
                            caseVhc.EngineDescription__c = valueInSet(referenceRecord.EngineDescription__c, enginesLst) ? referenceRecord.EngineDescription__c : '';
                            caseVhc.DrivetrainDescription__c = valueInSet(referenceRecord.DrivetrainDescription__c, drivetrainsLst) ? referenceRecord.DrivetrainDescription__c : '';
                            caseVhc.TransmissionDescription__c = valueInSet(referenceRecord.TransmissionDescription__c, transmissionsLst) ? referenceRecord.TransmissionDescription__c : '';
                            caseVhc.ModelCode__c = valueInSet(referenceRecord.ModelCode__c, modelCodesLst) ? referenceRecord.ModelCode__c : '';
                            caseVhc.HasModelCode__c = !String.isEmpty(caseVhc.ModelCode__c) ? true : false;
                            caseVehiclesToCreate.put(mapKey, caseVhc);
                        }
                    }
                }
            }
        }

        System.debug('Case to create:: ' + caseVehiclesToCreate.size());
        System.debug(JSON.serializePretty(caseVehiclesToCreate));


        return caseVehiclesToCreate.values();

    }

    public Case updateCaseFields(Case c, List<CaseVehicle__c> affectedVehicles) {
        // Update Case values based on the newly selected Case Vehicle records
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

        Case updatedCase = new Case(Id = c.Id);
        updatedCase.VehicleInfo__c = CaseVehicleUtil.GenerateVehicleInfo(affectedVehicles);

        // Make
        updatedCase.Make__c = convertListToString(new List<String>(vhcMakes));

        // Model
        updatedCase.VehicleModel__c = convertListToString(new List<String>(vhcModels));

        // Model Codes
        updatedCase.ModelCode__c = convertListToString(new List<String>(vhcModelCodes));

        // Years
        updatedCase.MY__c = convertListToString(new List<String>(vhcYears));
        // Engines
        updatedCase.Engine__c = convertListToString(new List<String>(vhcEngines));

        // Drivetrains
        updatedCase.Drivetrain__c = convertListToString(new List<String>(vhcDrivetrains));

        // Transmissions
        updatedCase.Trans__c = convertListToString(new List<String>(vhcTransmissions));

        // Fuel Type
        updatedCase.Fuel_Type__c = convertListToString(new List<String>(vhcFuelTypes));

        return updatedCase;

    }

    private String convertListToString(List<String> strList) {
        if (strList.size() > 0) {
            return String.join(new List<String>(strList), ';');
        }
        return '';
    }

    private Set<String> convertMultiSelectStringToSet(String sValue) {
        return isEmpty(sValue) ? new Set<String>() : new Set<String>(sValue.toLowerCase().split(';'));
    }

    private Boolean isEmpty(String str) {
        return String.isBlank(str) || (str.trim().equals(';'));
    }

    public Boolean valueInSet(String value, Set<String> vSet) {
        return value <> null && vSet.contains(value.trim().toLowerCase());
    }

    private String getCVMapKey(String make, String model, String modelCode) {
        if (modelCode <> null && String.isNotEmpty(modelCode)) {
            return String.valueOf(make).toLowerCase().trim() + '_' + String.valueOf(model).toLowerCase().trim() + '_' + String.valueOf(modelCode).toLowerCase().trim();
        }
        return String.valueOf(make).toLowerCase().trim() + '_' + String.valueOf(model).toLowerCase().trim();
    }

}