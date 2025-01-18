/**
************************************************************************************************
* @classname         : multiVehicleWOController
* @description       : utility class used for STIL multiVehicleWOController 
* @author            : LJ ? 
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0           Aug 2024           San Kang              OU24-116          Initial Version
* 1.1       13th Aug 2024          Inho Kim              STIL-123          updated saveVehicles method 
************************************************************************************************
**/
public without sharing class multiVehicleWOController {
    @AuraEnabled
    public static String getAffectedVehicles(Id woId) {
        List<AffectedVehicleWrapper> affectedVehiclesWrapper = new List<AffectedVehicleWrapper>();
        for (LRVehicle__c affectedVhc : [
                SELECT
                        Id, Name, WorkOrder__c, Make__c,
                        VehicleYear__c, Model__c, ModelCode__c, Notes__c,
                        Need_Review__c, isOther__c 
                FROM LRVehicle__c
                WHERE WorkOrder__c = :woId
        ]) {
            AffectedVehicleWrapper vhcWrapper = new AffectedVehicleWrapper();// init new instance every loop 
            vhcWrapper.id = affectedVhc.Id;
            vhcWrapper.isOther = affectedVhc.isOther__c;
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

                vhcWrapper.formattedYear = getFormattedYearsString(affectedVhc.VehicleYear__c);
            }
            // Vehicle Fuel Type Options
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
    public static String getVehicleUpdateOptions(String makes, String years, String models, String modelcodes) {
        NewVehiclesWrapper optionsWrapper = new NewVehiclesWrapper();
        try {
            Set<String> makesLst = isEmpty(makes) ? new Set<String>() : new Set<String>(makes.toLowerCase().split(';'));
            Set<String> yearsLst = isEmpty(years) ? new Set<String>() : new Set<String>(years.toLowerCase().split(';'));
            Set<String> modelsLst = isEmpty(models) ? new Set<String>() : new Set<String>(models.toLowerCase().split(';'));
            Set<String> modelCodesLst = isEmpty(modelCodes) ? new Set<String>() : new Set<String>(modelCodes.toLowerCase().split(';'));

            Set<String> makesLstAdded = new Set<String>();
            Set<String> yearsLstAdded = new Set<String>();
            Set<String> modelsLstAdded = new Set<String>();
            Set<String> modelCodesLstAdded = new Set<String>();

            List<AggregateResult> hmaReferenceData = [
                    SELECT COUNT(Name), Make__c, VehicleModel__c, Year__c, ModelCode__c
                    FROM HMAReferenceData__c
                    WHERE Make__c IN:makesLst
                    AND VehicleModel__c IN:modelsLst
                    GROUP BY Make__c, VehicleModel__c, Year__c, ModelCode__c
            ];

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
            String woId,
            String makes,
            String years,
            String models,
            String modelcodes,
            Boolean textValue,
            String recordId
            // ,            String recordId
    ) {
        System.debug('woId::'+woId);
        System.debug('years::'+years);
        System.debug('makes::'+makes);
        System.debug('models::'+models);
        System.debug('modelcodes::'+modelcodes);
        // System.debug('recordId::'+recordId);
        String returnStr = '';
        List<String> summaryList = new List<String>();
        try {
            Set<String> makesLst = convertMultiSelectStringToSet(makes);
            Set<String> yearsLst = convertMultiSelectStringToSet(years);
            Set<String> modelsLst = convertMultiSelectStringToSet(models);
            Set<String> modelCodesLst = convertMultiSelectStringToSet(modelCodes);

            
            System.debug('makesLst::'+makesLst);
            System.debug('yearsLst::'+yearsLst);
            System.debug('modelsLst::'+modelsLst);
            System.debug('modelCodesLst::'+modelCodesLst);
    
            returnStr += 'makesLst Size: ' + makesLst.size();
            returnStr += '\nyearsLst Size: ' + yearsLst.size();
            returnStr += '\nmodelsLst Size: ' + modelsLst.size();
            returnStr += '\nmodelCodesLst Size: ' + modelCodesLst.size();

            List<LRVehicle__c> existingwoVehiclesLst = [
                    SELECT
                            Id, Name, WorkOrder__c, Make__c, Model__c, VehicleYear__c, ModelCode__c, Notes__c, isOther__c 
                    FROM LRVehicle__c
                    WHERE WorkOrder__c = :woId
                    AND Need_Review__c = FALSE
            ];
            returnStr += '\nexistingwoVehicles Size: ' + existingwoVehiclesLst.size();

            Map<String, LRVehicle__c> existVehicleMap = new Map<String, LRVehicle__c>();
            Map<String, LRVehicle__c> existVehicleOtherMap = new Map<String, LRVehicle__c>();
            Map<String, LRVehicle__c> existVehicleNewMap = new Map<String, LRVehicle__c>();
            for (LRVehicle__c woVhc : existingwoVehiclesLst) {
                System.debug('SAVE LOOP START');
                System.debug(woVhc);

                String mapKey = getCVMapKey(woVhc.Make__c, woVhc.Model__c, woVhc.ModelCode__c);
                String recIdKey = woVhc.Id;
                System.debug('mapKey');
                System.debug(mapKey);
                System.debug('recIdKey');
                System.debug(recIdKey);

                if (!existVehicleMap.containsKey(mapKey)) {
                    woVhc.VehicleYear__c = '';
                    if (woVhc.ModelCode__c == null) {
                        woVhc.ModelCode__c = '';
                    }
                    existVehicleMap.put(mapKey, woVhc);// map 에 넣는 시점에 일단 지우고 넣어버리기. 
                    System.debug('existVehicleMap.put(mapKey, woVhc);');
                    System.debug(mapKey);
                    System.debug(woVhc);
                }


                if (!existVehicleOtherMap.containsKey(recIdKey) && woVhc.isOther__c ) {
                    // woVhc.VehicleYear__c = '';
                    // if (woVhc.ModelCode__c == null) {
                    //     woVhc.ModelCode__c = '';
                    // }
                    existVehicleOtherMap.put(recIdKey, woVhc);// map 에 넣는 시점에 일단 지우고 넣어버리기. 
                    System.debug('existVehicleOtherMap.put(mapKey, woVhc);');// isOther 해당 될때만 put 해놔라. 
                    System.debug(recIdKey);
                    System.debug(woVhc);
                }
            }// first loop (existingwoVehiclesLst) ended

            /**
             * ['Allow users with Test Lead/Requester or Lab Manager/Requestor permissions to manually enter contact info] 
             * Created by [San,Kang] on [24/07/17] for [Ticket OU24-116]
             * Edited by [San,Kang] on [24/07/18] for [Ticket OU24-116]
            */
            if(textValue == true  ){
                System.debug( ' textValue == true !!  ' ); 
                List<LRVehicle__c> woVehiclesToCreateList = new List<LRVehicle__c>();// summarhy text 용인데 왜 여기에서만 선언? 
                List<LRVehicle__c> woVehiclesToUpdateList = new List<LRVehicle__c>();
                // String mapKey = getCVMapKey(makes, models, null);// 왜 
                // System.debug('mapKey from isOther');
                // System.debug(mapkey);
                // String matchingKeys = '';
                // System.debug('mapKey::'+mapKey);
                // System.debug('mapKey get:'+existVehicleOtherMap);
                // System.debug('existVehicleOtherMap keys get:'+existVehicleOtherMap.keySet());
                // System.debug('mapKey contains:'+existVehicleOtherMap.containsKey(mapKey));
                // for (String key : existVehicleOtherMap.keySet()) {
                //     if (key.contains(mapKey)) {
                //         matchingKeys = key;
                //     }
                // }
                
                System.debug('existVehicleOtherMap - GET MAP AND CHECK');
                System.debug(existVehicleOtherMap);
                // System.debug(matchingKeys);
                // System.debug(  ! existVehicleMap.containsKey(matchingKeys) );
                if (  
                    //existVehicleOtherMap.containsKey(matchingKeys) || 
                recordId == null) {
                    LRVehicle__c woVhc = new LRVehicle__c();
                    woVhc.WorkOrder__c = woId;
                    woVhc.Make__c = makes;
                    woVhc.Model__c =models;
                    woVhc.VehicleYear__c = years;
                    woVhc.ModelCode__c = modelCodes != null ? modelCodes : '';
                    woVhc.HasModelCode__c = !String.isEmpty(woVhc.ModelCode__c) ? true : false;
                    woVhc.isOther__c  = true;
                    woVehiclesToCreateList.add(woVhc);
                    if (woVehiclesToCreateList.size() > 0) {
                        insert woVehiclesToCreateList;
                        summaryList.add('Total Vehicles added: ' + woVehiclesToCreateList.size());
                    }
                }else{
                    LRVehicle__c woVhc = [SELECT Id, Make__c, Model__c , VehicleYear__c, ModelCode__c FROM LRVehicle__c WHERE Id =  :recordId];
                    if(woVhc != null){
                        if(woVhc.Make__c != makes) {woVhc.Make__c = makes;}
                        if(woVhc.Model__c != models) {woVhc.Model__c = models;}
                        if(woVhc.VehicleYear__c != years) {woVhc.VehicleYear__c = years;}
                        if(woVhc.ModelCode__c != modelCodes) {woVhc.ModelCode__c = modelCodes;}
                        woVehiclesToUpdateList.add(woVHC);
                        if (woVehiclesToUpdateList.size() > 0) {
                            update woVehiclesToUpdateList;
                        }
                    }
                }

                return JSON.serializePretty(summaryList);// END of when other vehicle insert/update logic
            }

            

            System.debug( ' textValue == fallse !!  ' ); 
            System.debug('existVehicleMap'+existVehicleMap);
            System.debug('existingwoVehiclesLst'+existingwoVehiclesLst);
            System.debug('existingwoVehiclesLst'+existingwoVehiclesLst.size());
            
            //San,Kang 23/10/16 : SO-268 too many soql Issue 
            List<AggregateResult> referenceData;
            String queryString = 'SELECT  count(Name), Make__c, VehicleModel__c, Year__c, ModelCode__c\n' +
                    'FROM HMAReferenceData__c\n' +
                    'WHERE Make__c IN:makesLst\n' +
                    'AND VehicleModel__c IN:modelsLst\n' +
                    'AND Year__c IN :yearsLst';
            if (modelCodesLst.size() > 0) {
                queryString += ' AND ModelCode__c IN :modelCodesLst';
            }
                queryString += ' group by  Make__c, VehicleModel__c, Year__c, ModelCode__c';

            referenceData = Database.query(queryString);

            returnStr += '\nreferenceData Size: ' + referenceData.size();

            Map<String, LRVehicle__c> woVehiclesToCreate = new Map<String, LRVehicle__c>();
            Map<String, LRVehicle__c> woVehiclesToUpdate = new Map<String, LRVehicle__c>();
            
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
                                LRVehicle__c woVhc = existVehicleMap.get(partialKey);
                                existVehicleMap.put(mapKey, woVhc);
                                existVehicleMap.remove(partialKey);
                            }

                            // The Vehicle wo record exists in the system -> Update the existing record values
                            if (existVehicleMap.containsKey(mapKey)) {
                                System.debug('existVehicleMap>>>>>>>>>   contains mapKey '); 
                                System.debug(existVehicleMap); 
                                System.debug(mapKey);
                                LRVehicle__c woVhc = woVehiclesToUpdate.containsKey(mapKey) ? woVehiclesToUpdate.get(mapKey) : existVehicleMap.get(mapKey);
                                Set<String> woVhcYearLst = convertMultiSelectStringToSet(woVhc.VehicleYear__c);
                                Set<String> woVhcModelCodeLst = convertMultiSelectStringToSet(woVhc.ModelCode__c);

                                if (String.valueOf(referenceRecord.get('Year__c')) <> null && yearsLst.contains(String.valueOf(referenceRecord.get('Year__c')).toLowerCase()) && !woVhcYearLst.contains(String.valueOf(referenceRecord.get('Year__c')).toLowerCase().trim())) {
                                    woVhc.VehicleYear__c += ';' + String.valueOf(referenceRecord.get('Year__c')).trim();
                                }
                                if (String.valueOf(referenceRecord.get('ModelCode__c')) <> null && modelCodesLst.contains(String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase()) && modelCodesLst.contains(String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase()) && !woVhcModelCodeLst.contains(String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase().trim())) {
                                    woVhc.ModelCode__c += ';' + String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase().trim();
                                }
                                woVhc.HasModelCode__c = !String.isEmpty(woVhc.ModelCode__c) ? true : false;



                                if (!woVehiclesToUpdate.containsKey(mapKey)) {

                                    woVehiclesToUpdate.put(mapKey, woVhc);
                                    System.debug('key is not found??? ');
                                    System.debug(woVehiclesToUpdate); 
                                }
                            }
                            // Remove any duplicate values in the new wo Vehicle records
                            else if (woVehiclesToCreate.containsKey(mapKey)) {
                                LRVehicle__c woVhc = woVehiclesToCreate.get(mapKey);
                                Set<String> woVhcYearLst = convertMultiSelectStringToSet(woVhc.VehicleYear__c);
                                Set<String> woVhcModelCodeLst = convertMultiSelectStringToSet(woVhc.ModelCode__c);

                                if (String.valueOf(referenceRecord.get('Year__c')) <> null && !woVhcYearLst.contains(String.valueOf(referenceRecord.get('Year__c'))) && yearsLst.contains(String.valueOf(referenceRecord.get('Year__c')))) {
                                    woVhc.VehicleYear__c += ';' + String.valueOf(referenceRecord.get('Year__c'));
                                }
                                if (String.valueOf(referenceRecord.get('ModelCode__c')) <> null && !woVhcModelCodeLst.contains(String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase()) && modelCodesLst.contains(String.valueOf(referenceRecord.get('ModelCode__c')).toLowerCase())) {
                                    woVhc.ModelCode__c += ';' + String.valueOf(referenceRecord.get('ModelCode__c'));
                                }
                                woVhc.HasModelCode__c = !String.isEmpty(woVhc.ModelCode__c) ? true : false;
                            }
                            // New wo Vehicle records -> Create new record
                            else {
                                LRVehicle__c woVhc = new LRVehicle__c();
                                woVhc.WorkOrder__c = woId;

                                woVhc.Make__c = valueInSet(String.valueOf(referenceRecord.get('Make__c')), makesLst) ? String.valueOf(referenceRecord.get('Make__c')) : '';
                                woVhc.Model__c = valueInSet(String.valueOf(referenceRecord.get('VehicleModel__c')), modelsLst) ? String.valueOf(referenceRecord.get('VehicleModel__c')) : '';
                                woVhc.VehicleYear__c = valueInSet(String.valueOf(referenceRecord.get('Year__c')), yearsLst) ? String.valueOf(referenceRecord.get('Year__c')) : '';
                                woVhc.ModelCode__c = valueInSet(String.valueOf(referenceRecord.get('ModelCode__c')), modelCodesLst) ? String.valueOf(referenceRecord.get('ModelCode__c')) : '';
                                woVhc.HasModelCode__c = !String.isEmpty(woVhc.ModelCode__c) ? true : false;

                                woVehiclesToCreate.put(mapKey, woVhc);
                            }
                        }
                    }
                }
            }
            System.debug('textValue');
            System.debug(textValue);

            System.debug('wo to create:: ' + woVehiclesToCreate.size());
            System.debug(JSON.serializePretty(woVehiclesToCreate));

            returnStr += '\nwoVehiclesToCreate Size: ' + woVehiclesToCreate.size();
            returnStr += '\nwoVehiclesToUpdate Size: ' + woVehiclesToUpdate.size();

            if (woVehiclesToCreate.size() > 0) {
                insert woVehiclesToCreate.values();
                summaryList.add('Vehicles added: ' + woVehiclesToCreate.size());
            }

            if (woVehiclesToUpdate.size() > 0) {
                update woVehiclesToUpdate.values();
                summaryList.add('Vehicles updated: ' + woVehiclesToUpdate.size());
            }
            updatewoVehicleInfo(woId);

            returnStr += '\nwo Id: ' + woId;
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

    public static void updatewoVehicleInfo(String woId) {
        List<LRVehicle__c> affectedVehicles = [SELECT Id, Name, WorkOrder__c, Make__c, Model__c, VehicleYear__c, ModelCode__c, Notes__c FROM LRVehicle__c WHERE WorkOrder__c = :woId];

        // Update wo values based on the newly selected wo Vehicle records
        if (affectedVehicles.size() > 0) {
            Set<String> vhcMakes = new Set<String>();
            Set<String> vhcModels = new Set<String>();
            Set<String> vhcModelCodes = new Set<String>();
            Set<String> vhcYears = new Set<String>();

            for (LRVehicle__c vhc : affectedVehicles) {
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
            }

        }
    }

    @AuraEnabled
    public static String deleteVehicles(String vehicleIds, String woId) {
        String returnStr = '';
        try {
            if (String.isNotEmpty(vehicleIds)) {
                List<String> vehicleIdsList = vehicleIds.split(';');
                List<LRVehicle__c> woVehicles = [SELECT Id FROM LRVehicle__c WHERE Id IN:vehicleIdsList];
                if (woVehicles.size() > 0) {
                    delete woVehicles;
                    returnStr = woVehicles.size() + ' Affected Vehicles deleted';
                    updatewoVehicleInfo(woId);
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
    public static String deleteAllVehicles(String woId) {
        String returnStr = '';
        try {
            if (String.isNotEmpty(woId)) {
                List<LRVehicle__c> woVehicles = [SELECT Id FROM LRVehicle__c WHERE WorkOrder__c = :woId];
                if (woVehicles.size() > 0) {
                    delete woVehicles;
                    returnStr = woVehicles.size() + ' Affected Vehicles deleted';

                    // WorkOrder wo = new WorkOrder(Id = woId);
                    // wo.VehicleInfo__c = '';
                    // update wo;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }

        return returnStr;
    }


    public static String getFormattedYearsString(String vehicleYears) {
        List<String> yearsStrings = !String.isEmpty(vehicleYears) && vehicleYears.trim().length() > 0 ? vehicleYears.split(';') : new List<String>();

        if (yearsStrings.size() == 0) {
            return '';
        }

        yearsStrings.sort();
        List<String> formattedList = new List<String>();

        for (Integer i = 0; i < yearsStrings.size(); i++) {
            String startValue = yearsStrings[i];
            String endValue = startValue;
            for (Integer j = i + 1; j < yearsStrings.size(); j++) {
                if (Integer.valueOf(endValue) == Integer.valueOf(yearsStrings[j]) - 1) {
                    endValue = yearsStrings[j];
                } else {
                    break;
                }
                i++;
            }

            formattedList.add((startValue.equalsIgnoreCase(endValue) ? startValue : startValue + '-' + endValue));
        }

        return String.join(formattedList, '; ');
    }


    /* -------- Util Methods -------- */
    private static Boolean isEmpty(String str) {
        return String.isBlank(str) || (str.trim().equals(';'));
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
        public VehiclePropertyWrapper modelCode = new VehiclePropertyWrapper();

        public Boolean isOther;
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