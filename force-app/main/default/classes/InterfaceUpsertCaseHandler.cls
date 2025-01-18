/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-12-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class InterfaceUpsertCaseHandler {

    private static InterfaceUpsertCaseHandler instance;

    public InterfaceUpsertCaseHandler() {

    }

    public static InterfaceUpsertCaseHandler getInstance() {
        if (instance == null) {
            instance = new InterfaceUpsertCaseHandler();
        }
        return instance;
    }

    public InterfaceUpsertCaseController.Input pre(RestRequest request) {
        InterfaceUpsertCaseController.Input input = null;
        String requestBody = request.requestBody.toString();
        System.debug('requestBody =====> ' + requestBody);
        input = (InterfaceUpsertCaseController.Input) JSON.deserialize(
            requestBody,
            InterfaceUpsertCaseController.Input.class
        );

        return input;
    }

    public InterfaceUpsertCaseController.Output post(InterfaceUpsertCaseController.Input input) {
        InterfaceUpsertCaseController.Output output = new InterfaceUpsertCaseController.Output();
        InterfaceUpsertCaseController.OutputBody outputBody = output.payload;
        List<InterfaceUpsertCaseController.OutputItem> outputItemList =outputBody.data;
      

        Case caseRecord = null;
        List<Case> insertCaseList = null;
        String errMsg;
        String saveVehicleResult='';
        String ownerId;
        InterfaceUpsertCaseController.OutputItem outputItem = null;

        try {
            InterfaceUpsertCaseController.InputItem item = input.parameter;
            if (item == null) {
                outputBody.result = 'F';
                outputBody.message = 'Invalid Arguments Exception - empty itemList'; 
                System.debug('Invalid Arguments Exception - empty itemList');
                return output;
            }

                System.debug(LoggingLevel.DEBUG, 'InputItem =====> ' + JSON.serialize(item));
                outputItem = new InterfaceUpsertCaseController.OutputItem();


                Alert__c alert = [SELECT Id, Case__c, Model_Year__c, Project_Vhclmodel_Cd_Val__c, Name FROM Alert__c WHERE Warning_Alarm_Id__c =: item.alertId LIMIT 1];
                if(alert == null){
                    outputBody.result = 'F';
                    outputBody.message = 'Alert__c not found - ' + item.alertId;
                    System.debug('Alert__c not found - ' + item.alertId);
                    return output;
                }

                String validMsg = validateFields(item);
                if (!String.isBlank(validMsg)) {
                    outputBody.result = 'F';
                    outputBody.message = validMsg;
                    return output;
                }
                
                List<User> UserLi = [SELECT Id FROM User WHERE EmployeeNumber =: item.alertAssignee LIMIT 1]; 
                if (UserLi.size()==0) {
                    
                    outputBody.result = 'F';
                    outputBody.message = 'EmployeeNumber not found- ' + item.alertAssignee;
                    System.debug('EmployeeNumber not found- ' + item.alertAssignee);
                    return output;
                }
                ownerId = UserLi.get(0).Id;
                
                if(String.isBlank(item.caseNumber)){ //insert

                    caseRecord = new Case();
                    caseRecord.Subject = alert.Name;
                    caseRecord.Status = 'Open';
                    caseRecord.Stage__c = 'DA';     
                    caseRecord.CountryofOrigin__c = 'Korea';
                    caseRecord.SCSCaseRegion__c = 'Korea';
                    caseRecord.CompanyName__c = 'HMC'; 
                    // caseRecord.Severity__c = '5';
                    caseRecord.Haveyoupreviouslyreportedtheissues__c = item.issueYn == 'Y' ? 'Yes' : 'No';
                    caseRecord.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName ='KASODA'].Id;
                    caseRecord.OwnerId = ownerId;
                    insert caseRecord;

                    alert.Case__c = caseRecord.Id;
                    outputBody.type = 'insert';
                    
                    caseRecord = [SELECT Id, CaseNumber, SCSCaseNumber__c, SCSCaseRegion__c, OwnerId, Owner.Name, Stage__c, Status, Subject, CountryofOrigin__c 
                                    ,(SELECT Id FROM KASOCaseVehicles__r)
                                    FROM Case WHERE Id =: caseRecord.Id LIMIT 1];
                    
                }else{  //update
                    caseRecord = [SELECT Id, CaseNumber, SCSCaseNumber__c, SCSCaseRegion__c, OwnerId, Owner.Name, Stage__c, Status, Subject, CountryofOrigin__c 
                                    ,(SELECT Id FROM KASOCaseVehicles__r)
                                    FROM Case WHERE SCSCaseNumber__c =: item.caseNumber LIMIT 1];
                    ownerId = caseRecord.OwnerId;
                    if(caseRecord == null){
                        outputBody.result = 'F';
                        outputBody.message = 'Case not found - ' + item.caseNumber;
                        System.debug('Case not found - ' + item.caseNumber);
                        return output;
                    }
                    alert.Case__c = caseRecord.Id;
                    outputBody.type = 'update';
              
                }
                update alert;

                outputItem.caseId = caseRecord.Id;
                outputItem.caseNo = caseRecord.SCSCaseNumber__c;
                outputItem.caseOwner = caseRecord.Owner.Name;
                outputItem.country = caseRecord.CountryofOrigin__c;
                outputItem.region = caseRecord.SCSCaseRegion__c;
                outputItem.stage = caseRecord.Stage__c;
                outputItem.status = caseRecord.Status;
                outputItem.subject = caseRecord.Subject;

                if(caseRecord.KASOCaseVehicles__r.size() == 0) {
                    saveVehicleResult = 'Vehicle save result : ' + save_Kaso_Vehicle(alert);
                    caseRecord.OwnerId = ownerId;
                    update caseRecord;
                }

                outputBody.result = 'S';
                outputBody.message = 'Successfully ' +outputBody.type+ ' Case, ' + saveVehicleResult;
                outputItemList.add(outputItem);
                
                return output;

        } catch (Exception e) {
            
            outputBody.result = 'F';
            outputBody.message = e.getMessage();
            System.debug(e.getMessage());
            return output;
            
        }

        
    }

    //필드 유효성 검사 
	private String validateFields(InterfaceUpsertCaseController.InputItem item) {
		String validMsg = null;
        if(item.alertAssignee == null || item.alertId ==null || item.caseNumber ==null || item.issueYn == null){
            validMsg = 'Please ensure all mandatory fields are included in the request body.';
        }
        return validMsg;
	}

    private String save_Kaso_Vehicle(Alert__c alert){

        String resultMessage = '';
        List<HMCReferenceData__c> objLi = [SELECT  Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c, CBU_CKD__c, ProdCorp__c, VehicleType__c  FROM  HMCReferenceData__c  where ModelCode__c =: alert.Project_Vhclmodel_Cd_Val__c LIMIT 1];
       
        if(objLi.size() == 0){
            resultMessage = 'The save was successful; however, the affected vehicle was not saved due to the absence of a vehicle model. - ' + alert.Project_Vhclmodel_Cd_Val__c;
            System.debug('The save was successful; however, the affected vehicle was not saved due to the absence of a vehicle model. - ' + alert.Project_Vhclmodel_Cd_Val__c);
        }else{
            HMCReferenceData__c obj = objLi.get(0);
            String caseId = alert.Case__c;
            String makes= obj.Make__c;
            String years= alert.Model_Year__c ?? '';
            String models= obj.VehicleModel__c;
            String drivetrains= '';
            String fueltypes= '';
            String engines= '';
            String transmissions= '';
            String modelcodes= obj.ModelCode__c;
            String cbuckd= obj.CBU_CKD__c;
            String prodcorp= obj.ProdCorp__c;
            String vehicletype= obj.VehicleType__c;
    
            String result = saveVehicles(
                caseid
                ,  makes
                ,  years
                ,  models
                ,  drivetrains
                ,  fueltypes
                ,  engines
                ,  transmissions
                ,  modelcodes
                ,  cbuckd
                ,  prodcorp
                ,  vehicletype
            );

            resultMessage = result;
        }
        
     
       return resultMessage;
    }
    
    //KASOmultiVehicleCaseController 의 Exception Type Error로 인해 복사
    private String saveVehicles(
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
                                      
                                        }
                                        // Remove any duplicate values in the new Case Vehicle records
                                        else if (caseVehiclesToCreate.containsKey(mapKey)) {
   
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
            KASOmultiVehicleCaseController.updateCaseVehicleInfo(caseId);

            returnStr += '\nCase Id: ' + caseId;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        return JSON.serializePretty(summaryList);
    }

    private static Set<String> convertMultiSelectStringToSet(String sValue) {
        return isEmpty(sValue) ? new Set<String>() : new Set<String>(sValue.toLowerCase().split(';'));
    }
    private static Boolean isEmpty(String str) {
        return String.isBlank(str) || (str.trim().equals(';'));
    }
    public static Boolean valueInSet(String value, Set<String> vSet) {
        return value <> null && vSet.contains(value.trim().toLowerCase());
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

    
}