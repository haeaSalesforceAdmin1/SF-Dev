public without sharing class CaseTriggerHelper {

    public static void handleAfterInsertUpdate(Map<Id, Case> cases) {
        List<Case> casesWithTags = populateCaseTags(cases.keySet(), 'RecommendedCaseTagsLong__c');
        if (!casesWithTags.isEmpty()) update casesWithTags;

        //List<Case> casesConcatVehcInfo =  concatenateVehicleInfo(cases.keySet());
        //if(!casesConcatVehcInfo.isEmpty()) update casesConcatVehcInfo;
    }

    public static void caseInsertIncrementUserCases(Map<Id, Case> newCasesMap) {
        Set<Id> users = new Set<Id>();
        if (newCasesMap <> null && !newCasesMap.isEmpty()) {
            for (Case c : newCasesMap.values()) {
                if (String.valueOf(c.OwnerId).startsWith('005')) {
                    users.add(c.OwnerId);
                }
            }
        }

        Map<Id, User> affectedUsers = new Map<Id, User>([SELECT Id, AssignedCases__c FROM User WHERE Id IN:users]);

        Map<Id, User> usersToUpdate = new Map<Id, User>();
        // Logic when new case is inserted
        for (Case c : newCasesMap.values()) {
            if (String.valueOf(c.OwnerId).startsWith('005')) {
                User caseUser = usersToUpdate.containsKey(c.OwnerId) ? usersToUpdate.get(c.OwnerId) : affectedUsers.get(c.OwnerId);
                if (caseUser.AssignedCases__c == null) {
                    caseUser.AssignedCases__c = 1;
                } else {
                    caseUser.AssignedCases__c += 1;
                }

                usersToUpdate.put(caseUser.Id, caseUser);
            }
        }
        if (!usersToUpdate.isEmpty()) update usersToUpdate.values();
    }

    public static void caseDeleteDecrementUserCases(Map<Id, Case> oldCasesMap) {
        Set<Id> users = new Set<Id>();
        if (oldCasesMap <> null && !oldCasesMap.isEmpty()) {
            for (Case c : oldCasesMap.values()) {
                if (String.valueOf(c.OwnerId).startsWith('005')) {
                    users.add(c.OwnerId);
                }
            }
        }

        Map<Id, User> affectedUsers = new Map<Id, User>([SELECT Id, AssignedCases__c FROM User WHERE Id IN:users]);

        Map<Id, User> usersToUpdate = new Map<Id, User>();
        for (Case c : oldCasesMap.values()) {
            if (String.valueOf(c.OwnerId).startsWith('005')) {
                User caseUser = usersToUpdate.containsKey(c.OwnerId) ? usersToUpdate.get(c.OwnerId) : affectedUsers.get(c.OwnerId);
                if (caseUser.AssignedCases__c <> null && caseUser.AssignedCases__c <> 0) {
                    caseUser.AssignedCases__c -= 1;
                }

                usersToUpdate.put(caseUser.Id, caseUser);
            }
        }
        if (!usersToUpdate.isEmpty()) update usersToUpdate.values();
    }

    public static void caseUpdateTotalUserCases(Map<Id, Case> newCasesMap, Map<Id, Case> oldCasesMap) {
        // Get All the required users
        Set<Id> users = new Set<Id>();
        if (newCasesMap <> null && !newCasesMap.isEmpty()) {
            for (Case c : newCasesMap.values()) {
                if (String.valueOf(c.OwnerId).startsWith('005')) {
                    users.add(c.OwnerId);
                }
            }
        }
        if (oldCasesMap <> null && !oldCasesMap.isEmpty()) {
            for (Case c : oldCasesMap.values()) {
                if (String.valueOf(c.OwnerId).startsWith('005')) {
                    users.add(c.OwnerId);
                }
            }
        }
        Map<Id, User> affectedUsers = new Map<Id, User>([SELECT Id, AssignedCases__c FROM User WHERE Id IN:users]);
        Map<Id, User> usersToUpdate = new Map<Id, User>();
        for (Case c : newCasesMap.values()) {
            Case oldCase = oldCasesMap.get(c.Id);
            User newCaseOwner = usersToUpdate.containsKey(c.OwnerId) ? usersToUpdate.get(c.OwnerId) : affectedUsers.get(c.OwnerId);
            User oldCaseOwner = usersToUpdate.containsKey(oldCase.OwnerId) ? usersToUpdate.get(oldCase.OwnerId) : affectedUsers.get(oldCase.OwnerId);
            if (c.IsClosed && !oldCase.IsClosed && String.valueOf(c.OwnerId).startsWith('005')) {
                // Case Closed Decrement
                User caseUser = usersToUpdate.containsKey(c.OwnerId) ? usersToUpdate.get(c.OwnerId) : affectedUsers.get(c.OwnerId);
                if (caseUser.AssignedCases__c <> null && caseUser.AssignedCases__c <> 0) {
                    caseUser.AssignedCases__c -= 1;
                    usersToUpdate.put(caseUser.Id, caseUser);
                }
            } else if (!c.IsClosed && c.OwnerId <> oldCase.OwnerId && String.valueOf(c.OwnerId).contains('005') && String.valueOf(oldCase.OwnerId).contains('005')) {
                // Owner is Change, New Owner User, Prior Owner User
                if (newCaseOwner.AssignedCases__c == null || newCaseOwner.AssignedCases__c == 0) {
                    newCaseOwner.AssignedCases__c = 1;
                    usersToUpdate.put(newCaseOwner.Id, newCaseOwner);
                } else {
                    newCaseOwner.AssignedCases__c += 1;
                    usersToUpdate.put(newCaseOwner.Id, newCaseOwner);
                }

                if (oldCaseOwner.AssignedCases__c <> null || oldCaseOwner.AssignedCases__c <> 0) {
                    oldCaseOwner.AssignedCases__c -= 1;
                    usersToUpdate.put(oldCaseOwner.Id, oldCaseOwner);
                }
            } else if (!c.IsClosed && c.OwnerId <> oldCase.OwnerId && !String.valueOf(c.OwnerId).contains('005') && String.valueOf(oldCase.OwnerId).contains('005')) {
                // Owner Change, New Owner Queue,  Prior Owner User
                if (oldCaseOwner.AssignedCases__c <> null && oldCaseOwner.AssignedCases__c <> 0) {
                    oldCaseOwner.AssignedCases__c -= 1;
                    usersToUpdate.put(oldCaseOwner.Id, oldCaseOwner);
                }
            } else if (!c.IsClosed && c.OwnerId <> oldCase.OwnerId && String.valueOf(c.OwnerId).contains('005') && !String.valueOf(oldCase.OwnerId).contains('005')) {
                // Owner Change, New Owner User,  Prior Owner Queue
                if (newCaseOwner.AssignedCases__c <> null && newCaseOwner.AssignedCases__c <> 0) {
                    newCaseOwner.AssignedCases__c += 1;
                    usersToUpdate.put(newCaseOwner.Id, newCaseOwner);
                } else {
                    newCaseOwner.AssignedCases__c = 1;
                    usersToUpdate.put(newCaseOwner.Id, newCaseOwner);
                }
            } else if (!c.IsClosed && oldCase.IsClosed && String.valueOf(c.OwnerId).contains('005')) {
                // Case is re-opened
                if (newCaseOwner.AssignedCases__c <> null && newCaseOwner.AssignedCases__c <> 0) {
                    newCaseOwner.AssignedCases__c += 1;
                    usersToUpdate.put(newCaseOwner.Id, newCaseOwner);
                } else {
                    newCaseOwner.AssignedCases__c = 1;
                    usersToUpdate.put(newCaseOwner.Id, newCaseOwner);
                }
            }
        }

        if (!usersToUpdate.isEmpty()) update usersToUpdate.values();
    }

    public static List<Case> populateCaseTags(Set<Id> caseIds, String tagFieldName) {
        List<Object_Tag_Setting__mdt> tagMdtData = ObjectTagDataHelper.getObjectTagSettings('Case');
        Map<String, String> fieldNamesWithSeparator = ObjectTagDataHelper.getFieldNamesWithSaparator();
        List<String> fields = new List<String>(fieldNamesWithSeparator.keySet());
        String query = 'SELECT Id, ' + tagFieldName + ', ' + String.join(fields, ',') + ' FROM Case WHERE Id IN: caseIds';
        List<Case> cases = Database.query(query);
        List<Case> casesWithUpdatedTags = new List<Case>();
        if (!tagMdtData.isEmpty()) {
            for (Case c : cases) {
                Set<String> recommendedTags = new Set<String>();
                for (String field : fields) {
                    String fieldValue = '';
                    if (field.contains('.')) {
                        List<String> relatedField = field.split('\\.');
                        System.debug('Related Field Found: ' + field + ' - ' + JSON.serializePretty(relatedField));
                        System.debug('Related Field Size: ' + relatedField.size());
                        System.debug('Related Field Object: ' + relatedField[0]);
                        System.debug('Related Field Name: ' + relatedField[1]);
                        if (relatedField.size() == 2) {
                            if (c.getSObject(relatedField[0]) <> null && c.getSObject(relatedField[0]).get(relatedField[1]) <> null) {
                                fieldValue = (String) c.getSObject(relatedField[0]).get(relatedField[1]);
                            }
                        }
                    } else if (c.get(field) <> null) {
                        fieldValue = (String) c.get(field);
                    }

                    if (String.isNotEmpty(fieldValue)) {
                        if (String.isNotEmpty(fieldNamesWithSeparator.get(field))) {
                            List<String> valuesSplit = fieldValue.split(fieldNamesWithSeparator.get(field));
                            if (field.equalsIgnoreCase('MY__c') && !valuesSplit.isEmpty()) {
                                valuesSplit.sort();
                                Integer minYear = Integer.valueOf(valuesSplit[0]);
                                Integer maxYear = Integer.valueOf(valuesSplit[valuesSplit.size() - 1]);
                                valuesSplit.add(String.valueOf(minYear - 1));
                                valuesSplit.add(String.valueOf(minYear - 2));
                                valuesSplit.add(String.valueOf(minYear - 3));
                                valuesSplit.add(String.valueOf(maxYear + 1));
                                valuesSplit.add(String.valueOf(maxYear + 2));
                                valuesSplit.add(String.valueOf(maxYear + 3));
                            }
                            valuesSplit.sort();
                            recommendedTags.addAll(valuesSplit);

                        } else {
                            recommendedTags.add(fieldValue);
                        }
                    }
                }


                if (recommendedTags.size() > 0) {
                    String recommendedTagStr = String.join(new List<String>(recommendedTags), '<n>');
                    if (!recommendedTagStr.equalsIgnoreCase((String) c.get(tagFieldName))) {
                        c.put(tagFieldName, recommendedTagStr);
                        casesWithUpdatedTags.add(c);
                    }
                } else {
                    c.put(tagFieldName, '');
                }
            }
        }

        return casesWithUpdatedTags;
    }
    // Generate Safety Case Number when cases are inserted
    public static void handleSafetyCaseNumberInsert(Map<Id, Case> casesMap) {
        Map<Id, Case> cases = new Map<Id, Case>([SELECT Id, SCSCaseRegion__c, SCSCaseNumber__c, SafetyReference__c FROM Case WHERE Id IN:casesMap.keySet()]);
        SCSConfigurationSettings__c sSafetyConfig = SCSConfigurationSettings__c.getOrgDefaults();
        Integer initialSafetyCaseNumber = Test.isRunningTest() ? 1 : sSafetyConfig.CurrentCaseNumber__c.intValue();
        // Map of Case Id and Safety Number
        Map<Id, SafetyNumber__c> safetyNumbers = new Map<Id, SafetyNumber__c>();
        for (Case c : cases.values()) {
            if (String.isEmpty(c.SCSCaseNumber__c)) {

                String safetyCaseNumber = generateSafetyCaseNumber(c, String.valueOf(initialSafetyCaseNumber));
                c.SCSCaseNumber__c = safetyCaseNumber;
                SafetyNumber__c sftNumber = new SafetyNumber__c(Name = safetyCaseNumber);
                safetyNumbers.put(c.Id, sftNumber);
                initialSafetyCaseNumber += 1;
            }
        }

        if (!safetyNumbers.isEmpty()) insert safetyNumbers.values();
        sSafetyConfig.CurrentCaseNumber__c = initialSafetyCaseNumber;
        if (!Test.isRunningTest()) update sSafetyConfig;
        for (Id caseId : safetyNumbers.keySet()) {
            cases.get(caseId).SafetyReference__c = safetyNumbers.get(caseId).Id;
        }
        if (!Test.isRunningTest()) update cases.values();
    }
    /**
    * @description : Stage Case Creation Error - Via API Calls by Integration User
    * @author San, Kang : SanKang@autoeveramerica.com | 2023-01-11 ~ 2023-01-12
    * @tecket no: SO-319
    */
    // Update Safety Case Number when Case Region is Changed
    public static void handleSafetyCaseNumberUpdate(Map<Id, Case> newCasesMap, Map<Id, Case> oldCasesMap) {

        Boolean CheckSCSCaseRegion = false;
        for(Case newcasobj : newCasesMap.values()){
            for(Case oldcaseobj : oldCasesMap.values()){
                if (oldcaseobj.Id == newcasobj.Id &&(newcasobj.SCSCaseRegion__c <> null && newcasobj.SCSCaseRegion__c <> oldcaseobj.SCSCaseRegion__c)) {
                    CheckSCSCaseRegion = true;
                }
            }
        }
        if(CheckSCSCaseRegion){
            
            List<Case> updatedCases = [SELECT Id, SCSCaseRegion__c, SCSCaseNumber__c, SafetyReference__r.Id, SafetyReference__r.Name FROM Case WHERE Id IN:newCasesMap.keySet()];
            List<Case> casesToUpdate = new List<Case>();
            List<SafetyNumber__c> sftNumbersToUpdate = new List<SafetyNumber__c>();
            for (Case c : updatedCases) {
                Case oldCase = oldCasesMap.get(c.Id);
                if (c.SCSCaseRegion__c <> null && c.SCSCaseRegion__c <> oldCase.SCSCaseRegion__c) {

                    String safetyCaseNumber = c.SCSCaseNumber__c;
                    String caseRegionFirstChr = c.SCSCaseRegion__c.substring(0, 1);
                    safetyCaseNumber = caseRegionFirstChr + c.SCSCaseNumber__c.substring(1, c.SCSCaseNumber__c.length());
                    c.SCSCaseNumber__c = safetyCaseNumber;
                    if (c.SafetyReference__r <> null) {
                        c.SafetyReference__r.Name = safetyCaseNumber;
                        sftNumbersToUpdate.add(c.SafetyReference__r);
                    }
                    casesToUpdate.add(c);
                }

            }
            if (!sftNumbersToUpdate.isEmpty()) update sftNumbersToUpdate;
            if (!casesToUpdate.isEmpty()) update casesToUpdate;
        }
    }

    public static String generateSafetyCaseNumber(Case caseRecord, String configSafetyCaseNumber) {
        // Example:
        // Region: North America
        // Current Year: 2021
        // Case Number From Setting
        // Setting Case Number == 1 Character: ---> N-021-0001
        // Setting Case Number == 2 Character: ---> N-021-0010
        // Setting Case Number == 3 Character: ---> N-021-0100
        // Setting Case Number == 4 Character: ---> N-021-1000

        switch on configSafetyCaseNumber.length() {
            when 1 {
                configSafetyCaseNumber = '000' + configSafetyCaseNumber;
            }
            when 2 {
                configSafetyCaseNumber = '00' + configSafetyCaseNumber;
            }
            when 3 {
                configSafetyCaseNumber = '0' + configSafetyCaseNumber;
            }
        }
        // Get last three digit of current year
        String yearStr = String.valueOf(System.today().year()).right(3);
        // Get Case Region First Character
        String caseRegionFirstChr = String.valueOf(caseRecord.SCSCaseRegion__c).left(1);

        return caseRegionFirstChr + '-' + yearStr + '-' + configSafetyCaseNumber;
    }

    public static void createCaseVehicles(Set<Id> caseIds) {
        // KASO.2023.05.07 복구시 아래 쿼리에서 KASO_VIN__c, Case_Own_Org__c 삭제 필요 (1/6)
        List<Case> cases = [
                SELECT Id,
                        Make__c, MY__c, VehicleModel__c, Drivetrain__c, Fuel_Type__c,
                        Engine__c, Trans__c, ModelCode__c, VIN__c, CaseID__c,FirstReportSource__c, Cloned_from_NASDA__c, KASO_VIN__c, Case_Own_Org__c
                FROM Case
                WHERE Id IN:caseIds
        ];

        List<CaseVehicle__c> caseVehiclesToCreate = new List<CaseVehicle__c>();
        List<KASOCaseVehicle__c> KASOCaseVehiclesToCreate = new List<KASOCaseVehicle__c>();
        List<Case> casesToUpdate = new List<Case>();

        for (Case caseRecord : cases) {
            if (!caseRecord.Cloned_from_NASDA__c) {
                // KASO.2023.05.07 복구시 아래 if-else 문 주석 처리 필요 (2/6)
                if(caseRecord.Case_Own_Org__c.containsIgnoreCase('KASO')) {

                    if (caseRecord.KASO_VIN__c != null || (caseRecord.Make__c <> null && caseRecord.VehicleModel__c <> null)) {
                        System.debug('Creating Vehicles');

                        SObject newCaseVehicle = makeNewCaseVehicle(caseRecord);
                        if(newCaseVehicle!=NULL){
                            KASOCaseVehicle__c objKASOCaseVehicle = (KASOCaseVehicle__c) newCaseVehicle;
                            KASOCaseVehiclesToCreate.add(objKASOCaseVehicle);
                            String vehicleInfo = CaseVehicleUtil.GenerateVehicleInfo(new List<KASOCaseVehicle__c>{
                                    objKASOCaseVehicle
                            });

                            if (!String.isEmpty(vehicleInfo)) {
                                caseRecord.VehicleInfo__c = vehicleInfo;
                                caseRecord.ModelCode__c = String.isEmpty(caseRecord.ModelCode__c) && !String.isEmpty(objKASOCaseVehicle.ModelCode__c) ? objKASOCaseVehicle.ModelCode__c : caseRecord.ModelCode__c;
                                caseRecord.Engine__c = String.isEmpty(caseRecord.Engine__c) && !String.isEmpty(objKASOCaseVehicle.EngineDescription__c) ? objKASOCaseVehicle.EngineDescription__c : caseRecord.Engine__c;
                                casesToUpdate.add(caseRecord);
                            }
                        }
                    } else {
                        System.debug('Ignored: Make or Model fields are null and No KASO_VIN was provided');
                    }

                } else {
                    if (caseRecord.VIN__c != null || (caseRecord.Make__c <> null && caseRecord.VehicleModel__c <> null)) {
                        System.debug('Creating Vehicles');

                        SObject newCaseVehicle = makeNewCaseVehicle(caseRecord);
                        if(newCaseVehicle!=NULL){
                            CaseVehicle__c objCaseVehicle = (CaseVehicle__c) newCaseVehicle;
                            caseVehiclesToCreate.add(objCaseVehicle);
                            String vehicleInfo = CaseVehicleUtil.GenerateVehicleInfo(new List<CaseVehicle__c>{
                                    objCaseVehicle
                            });

                            if (!String.isEmpty(vehicleInfo)) {
                                caseRecord.VehicleInfo__c = vehicleInfo;
                                caseRecord.ModelCode__c = String.isEmpty(caseRecord.ModelCode__c) && !String.isEmpty(objCaseVehicle.ModelCode__c) ? objCaseVehicle.ModelCode__c : caseRecord.ModelCode__c;
                                caseRecord.Engine__c = String.isEmpty(caseRecord.Engine__c) && !String.isEmpty(objCaseVehicle.EngineDescription__c) ? objCaseVehicle.EngineDescription__c : caseRecord.Engine__c;
                                casesToUpdate.add(caseRecord);
                            }
                        }
                    } else {
                        System.debug('Ignored: Make or Model fields are null and No VIN was provided');
                    }
                }

                // KASO.2023.05.07 복구시 아래 주석 제거 필요 (3/6)
                /*
                if (caseRecord.VIN__c != null || (caseRecord.Make__c <> null && caseRecord.VehicleModel__c <> null)) {
                    System.debug('Creating Vehicles');

                    CaseVehicle__c newCaseVehicle = makeNewCaseVehicle(caseRecord);
                    if(newCaseVehicle!=NULL){
                        caseVehiclesToCreate.add(newCaseVehicle);
                        String vehicleInfo = CaseVehicleUtil.GenerateVehicleInfo(new List<CaseVehicle__c>{
                                newCaseVehicle
                        });

                        if (!String.isEmpty(vehicleInfo)) {
                            caseRecord.VehicleInfo__c = vehicleInfo;
                            caseRecord.ModelCode__c = String.isEmpty(caseRecord.ModelCode__c) && !String.isEmpty(newCaseVehicle.ModelCode__c) ? newCaseVehicle.ModelCode__c : caseRecord.ModelCode__c;
                            caseRecord.Engine__c = String.isEmpty(caseRecord.Engine__c) && !String.isEmpty(newCaseVehicle.EngineDescription__c) ? newCaseVehicle.EngineDescription__c : caseRecord.Engine__c;
                            casesToUpdate.add(caseRecord);
                        }
                    }
                } else {
                    System.debug('Ignored: Make or Model fields are null and No VIN was provided');
                }
                */

            } else if (caseRecord.Cloned_from_NASDA__c) {
                System.debug('Ignored: Cloned from NASDA');
            }
        }

        if (caseVehiclesToCreate.size() > 0) {
            insert caseVehiclesToCreate;
        }
        if(!KASOCaseVehiclesToCreate.isEmpty()){
            insert KASOCaseVehiclesToCreate;
        }
        if (casesToUpdate.size() > 0) {
            update casesToUpdate;
        }
    }

    public static SObject makeNewCaseVehicle(Case caseRecord) {

        // KASO.2023.05.07 복구시 아래 if-else 문 주석 처리 필요 (4/6)
        if(caseRecord.Case_Own_Org__c.containsIgnoreCase('KASO')) {

            if (caseRecord.KASO_VIN__c != null) {
                KASO_VIN__c sourceVIN = [
                        SELECT
                                Id,
                                Make__c,
                                ModelDesc__c,
                                ModelYear__c,
                                DrivetrainDesc__c,
                                FuelType__c,
                                TransmissionDesc__c,
                                PQMSModelCode__c,
                                EngineDesc__c,
                                CBU_CKD__c,
                                ProdCorp__c,
                                VehicleType__c
                        FROM KASO_VIN__c
                        WHERE Id = :caseRecord.KASO_VIN__c
                ];

                if (!String.isEmpty(caseRecord.Make__c) &&
                        !String.isEmpty(caseRecord.VehicleModel__c) &&
                        !String.isEmpty(caseRecord.MY__c) &&
                        !String.isEmpty(caseRecord.Drivetrain__c) &&
                        !String.isEmpty(caseRecord.Fuel_Type__c) &&
                        !String.isEmpty(caseRecord.Trans__c)) {

                    // check if the incoming values matches the Source VIN
                    if (caseRecord.Make__c.equalsIgnoreCase(sourceVIN.Make__c) &&
                            caseRecord.VehicleModel__c.equalsIgnoreCase(sourceVIN.ModelDesc__c) &&
                            caseRecord.MY__c.equals(sourceVIN.ModelYear__c) &&
                            caseRecord.Drivetrain__c.equalsIgnoreCase(sourceVIN.DrivetrainDesc__c) &&
                            caseRecord.Fuel_Type__c.equalsIgnoreCase(sourceVIN.FuelType__c) &&
                            caseRecord.Trans__c.equalsIgnoreCase(sourceVIN.TransmissionDesc__c)) {
                        System.debug('Navex case data matches KASO_VIN data');
//                        return createCaseVehicleRecord(caseRecord, false, 'KASO');
///////////////////////////////수정한부분
                        return createCaseVehicleRecord(caseRecord, sourceVIN);
                    }
                } else if (caseRecord.CaseID__c == null && caseRecord.Make__c == null && caseRecord.VehicleModel__c == null) {
                    System.debug('Create Internal case w/VIN');
                    return createCaseVehicleRecord(caseRecord, sourceVIN);
                }
            }

        } else {

            if (caseRecord.VIN__c != null && caseRecord.FirstReportSource__c!='SIMS' && caseRecord.FirstReportSource__c!='Shared KIA Common Issue') {
                VIN__c sourceVIN = [
                        SELECT
                                Id,
                                Make__c,
                                ModelDesc__c,
                                ModelYear__c,
                                DrivetrainDesc__c,
                                FuelType__c,
                                TransmissionDesc__c,
                                PQMSModelCode__c,
                                EngineDesc__c
                        FROM VIN__c
                        WHERE Id = :caseRecord.VIN__c
                ];

                if (!String.isEmpty(caseRecord.Make__c) &&
                        !String.isEmpty(caseRecord.VehicleModel__c) &&
                        !String.isEmpty(caseRecord.MY__c) &&
                        !String.isEmpty(caseRecord.Drivetrain__c) &&
                        !String.isEmpty(caseRecord.Fuel_Type__c) &&
                        !String.isEmpty(caseRecord.Trans__c)) {

                    // check if the incoming values matches the Source VIN
                    if (caseRecord.Make__c.equalsIgnoreCase(sourceVIN.Make__c) &&
                            caseRecord.VehicleModel__c.equalsIgnoreCase(sourceVIN.ModelDesc__c) &&
                            caseRecord.MY__c.equals(sourceVIN.ModelYear__c) &&
                            caseRecord.Drivetrain__c.equalsIgnoreCase(sourceVIN.DrivetrainDesc__c) &&
                            caseRecord.Fuel_Type__c.equalsIgnoreCase(sourceVIN.FuelType__c) &&
                            caseRecord.Trans__c.equalsIgnoreCase(sourceVIN.TransmissionDesc__c)) {
                        System.debug('Navex case data matches VIN data');
                        return createCaseVehicleRecord(caseRecord, false, '');
                    }
                } else if (caseRecord.CaseID__c == null && caseRecord.Make__c == null && caseRecord.VehicleModel__c == null) {
                    System.debug('Create Internal case w/VIN');
                    return createCaseVehicleRecord(caseRecord, sourceVIN);
                }
            }

            // KASO.2023.05.07 복구시 아래 주석 제거 필요 (5/6)
            /*
            if (caseRecord.VIN__c != null && caseRecord.FirstReportSource__c!='SIMS' && caseRecord.FirstReportSource__c!='Shared KIA Common Issue') {
                VIN__c sourceVIN = [
                        SELECT
                                Id,
                                Make__c,
                                ModelDesc__c,
                                ModelYear__c,
                                DrivetrainDesc__c,
                                FuelType__c,
                                TransmissionDesc__c,
                                PQMSModelCode__c,
                                EngineDesc__c
                        FROM VIN__c
                        WHERE Id = :caseRecord.VIN__c
                ];


                if (!String.isEmpty(caseRecord.Make__c) &&
                        !String.isEmpty(caseRecord.VehicleModel__c) &&
                        !String.isEmpty(caseRecord.MY__c) &&
                        !String.isEmpty(caseRecord.Drivetrain__c) &&
                        !String.isEmpty(caseRecord.Fuel_Type__c) &&
                        !String.isEmpty(caseRecord.Trans__c)) {

                    // check if the incoming values matches the Source VIN
                    if (caseRecord.Make__c.equalsIgnoreCase(sourceVIN.Make__c) &&
                            caseRecord.VehicleModel__c.equalsIgnoreCase(sourceVIN.ModelDesc__c) &&
                            caseRecord.MY__c.equals(sourceVIN.ModelYear__c) &&
                            caseRecord.Drivetrain__c.equalsIgnoreCase(sourceVIN.DrivetrainDesc__c) &&
                            caseRecord.Fuel_Type__c.equalsIgnoreCase(sourceVIN.FuelType__c) &&
                            caseRecord.Trans__c.equalsIgnoreCase(sourceVIN.TransmissionDesc__c)) {
                        System.debug('Navex case data matches VIN data');
                        return createCaseVehicleRecord(caseRecord, false);
                    }
                } else if (caseRecord.CaseID__c == null && caseRecord.Make__c == null && caseRecord.VehicleModel__c == null) {
                    System.debug('Create Internal case w/VIN');
                    return createCaseVehicleRecord(caseRecord, sourceVIN);
                }
            }
            */

        }



        if (!String.isEmpty(caseRecord.Make__c)
                && !String.isEmpty(caseRecord.VehicleModel__c)
                && !String.isEmpty(caseRecord.MY__c)) {

            if(caseRecord.Case_Own_Org__c.containsIgnoreCase('KASO')) {
                String query = 'SELECT Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c,\n' +
                        '                            DrivetrainDescription__c, TransmissionDescription__c\n' +
                        '                    FROM HMCReferenceData__c\n' +
                        '                    WHERE Make__c LIKE \'' + caseRecord.Make__c + '\'\n' +
                        '                    AND VehicleModel__c LIKE \'' + caseRecord.VehicleModel__c + '\'\n';
//                        '                    AND Year__c LIKE \'' + caseRecord.MY__c + '\'\n';

//                query += !String.isEmpty(caseRecord.Drivetrain__c) ? 'AND DrivetrainDescription__c LIKE \'' + caseRecord.Drivetrain__c + '\'\n' : '';
//                query += !String.isEmpty(caseRecord.Fuel_Type__c) ? 'AND FuelType__c LIKE \'' + caseRecord.Fuel_Type__c + '\'\n' : '';
                query += !String.isEmpty(caseRecord.Trans__c) ? 'AND TransmissionDescription__c LIKE \'' + caseRecord.Trans__c + '\'\n' : '';
                query += 'LIMIT 1';

                // Look for a record match in the HMA Reference Data table
                List<HMCReferenceData__c> referenceData = Database.query(query);
                if (referenceData.size() > 0) {
                    System.debug('Navex case, HMA reference match');
                    ////////////////수정한부분
                    return createCaseVehicleRecord(caseRecord, false, 'KASO');
                }
            }
            else {
                String query = 'SELECT Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c,\n' +
                        '                            DrivetrainDescription__c, TransmissionDescription__c\n' +
                        '                    FROM HMAReferenceData__c\n' +
                        '                    WHERE Make__c LIKE \'' + caseRecord.Make__c + '\'\n' +
                        '                    AND VehicleModel__c LIKE \'' + caseRecord.VehicleModel__c + '\'\n' +
                        '                    AND Year__c LIKE \'' + caseRecord.MY__c + '\'\n';

                query += !String.isEmpty(caseRecord.Drivetrain__c) ? 'AND DrivetrainDescription__c LIKE \'' + caseRecord.Drivetrain__c + '\'\n' : '';
                query += !String.isEmpty(caseRecord.Fuel_Type__c) ? 'AND FuelType__c LIKE \'' + caseRecord.Fuel_Type__c + '\'\n' : '';
                query += !String.isEmpty(caseRecord.Trans__c) ? 'AND TransmissionDescription__c LIKE \'' + caseRecord.Trans__c + '\'\n' : '';
                query += 'LIMIT 1';

                // Look for a record match in the HMA Reference Data table
                List<HMAReferenceData__c> referenceData = Database.query(query);
                if (referenceData.size() > 0) {
                    System.debug('Navex case, HMA reference match');
                    return createCaseVehicleRecord(caseRecord, false, '');
                }
            }

//            String query = 'SELECT Id, Name, Make__c, VehicleModel__c, Year__c, FuelType__c,\n' +
//                    '                            DrivetrainDescription__c, TransmissionDescription__c\n' +
//                    '                    FROM HMAReferenceData__c\n' +
//                    '                    WHERE Make__c LIKE \'' + caseRecord.Make__c + '\'\n' +
//                    '                    AND VehicleModel__c LIKE \'' + caseRecord.VehicleModel__c + '\'\n' +
//                    '                    AND Year__c LIKE \'' + caseRecord.MY__c + '\'\n';
//
//            query += !String.isEmpty(caseRecord.Drivetrain__c) ? 'AND DrivetrainDescription__c LIKE \'' + caseRecord.Drivetrain__c + '\'\n' : '';
//            query += !String.isEmpty(caseRecord.Fuel_Type__c) ? 'AND FuelType__c LIKE \'' + caseRecord.Fuel_Type__c + '\'\n' : '';
//            query += !String.isEmpty(caseRecord.Trans__c) ? 'AND TransmissionDescription__c LIKE \'' + caseRecord.Trans__c + '\'\n' : '';
//            query += 'LIMIT 1';
//
//            // Look for a record match in the HMA Reference Data table
//            List<HMAReferenceData__c> referenceData = Database.query(query);
//            if (referenceData.size() > 0) {
//                System.debug('Navex case, HMA reference match');
//                return createCaseVehicleRecord(caseRecord, false);
//            }
        }


        System.debug('Create Case: No VIN, no HMA reference match');
        if(caseRecord.Case_Own_Org__c.containsIgnoreCase('KASO')) {
                return createCaseVehicleRecord(caseRecord, true, 'KASO');
        }
        else if(caseRecord.FirstReportSource__c!='SIMS' && caseRecord.FirstReportSource__c!='Shared KIA Common Issue'){
                return createCaseVehicleRecord(caseRecord, true, '');
        }
//            return createCaseVehicleRecord(caseRecord, true);

        return null;
    }

    private static SObject createCaseVehicleRecord(Case sourceCase, Boolean needReview, String strType) {
        if(strType == 'KASO'){
            return new KASOCaseVehicle__c(
                    Case__c = sourceCase.Id,
                    Make__c = sourceCase.Make__c,
                    Model__c = sourceCase.VehicleModel__c,
                    VehicleYear__c = sourceCase.MY__c,
                    ModelCode__c = sourceCase.ModelCode__c,
                    EngineDescription__c = sourceCase.Engine__c,
                    DrivetrainDescription__c = sourceCase.Drivetrain__c,
                    FuelType__c = sourceCase.Fuel_Type__c,
                    TransmissionDescription__c = sourceCase.Trans__c,
                    HasModelCode__c = (!String.isEmpty(sourceCase.ModelCode__c) ? true : false),
                    Need_Review__c = needReview
            );
        }
        else {
            return new CaseVehicle__c(
                    Case__c = sourceCase.Id,
                    Make__c = sourceCase.Make__c,
                    Model__c = sourceCase.VehicleModel__c,
                    VehicleYear__c = sourceCase.MY__c,
                    ModelCode__c = sourceCase.ModelCode__c,
                    EngineDescription__c = sourceCase.Engine__c,
                    DrivetrainDescription__c = sourceCase.Drivetrain__c,
                    FuelType__c = sourceCase.Fuel_Type__c,
                    TransmissionDescription__c = sourceCase.Trans__c,
                    HasModelCode__c = (!String.isEmpty(sourceCase.ModelCode__c) ? true : false),
                    Need_Review__c = needReview
            );
        }

//        return new CaseVehicle__c(
//                Case__c = sourceCase.Id,
//                Make__c = sourceCase.Make__c,
//                Model__c = sourceCase.VehicleModel__c,
//                VehicleYear__c = sourceCase.MY__c,
//                ModelCode__c = sourceCase.ModelCode__c,
//                EngineDescription__c = sourceCase.Engine__c,
//                DrivetrainDescription__c = sourceCase.Drivetrain__c,
//                FuelType__c = sourceCase.Fuel_Type__c,
//                TransmissionDescription__c = sourceCase.Trans__c,
//                HasModelCode__c = (!String.isEmpty(sourceCase.ModelCode__c) ? true : false),
//                Need_Review__c = needReview
//        );
    }

    private static CaseVehicle__c createCaseVehicleRecord(Case sourceCase, VIN__c sourceVIN) {
        return new CaseVehicle__c(
                Case__c = sourceCase.Id,
                Make__c = sourceVIN.Make__c,
                Model__c = sourceVIN.ModelDesc__c,
                VehicleYear__c = sourceVIN.ModelYear__c,
                ModelCode__c = sourceVIN.PQMSModelCode__c,
                EngineDescription__c = sourceVIN.EngineDesc__c,
                DrivetrainDescription__c = sourceVIN.DrivetrainDesc__c,
                FuelType__c = sourceVIN.FuelType__c,
                TransmissionDescription__c = sourceVIN.TransmissionDesc__c,
                HasModelCode__c = (!String.isEmpty(sourceVIN.PQMSModelCode__c) ? true : false),
                Need_Review__c = false
        );
    }

    // KASO.2023.05.07 복구시 아래 함수 주석 처리 필요 (6/6)
    private static KASOCaseVehicle__c createCaseVehicleRecord(Case sourceCase, KASO_VIN__c sourceVIN) {
        return new KASOCaseVehicle__c(
                Case__c = sourceCase.Id,
                Make__c = sourceVIN.Make__c,
                Model__c = sourceVIN.ModelDesc__c,
                VehicleYear__c = sourceVIN.ModelYear__c,
                ModelCode__c = sourceVIN.PQMSModelCode__c,
                EngineDescription__c = sourceVIN.EngineDesc__c,
                DrivetrainDescription__c = sourceVIN.DrivetrainDesc__c,
                FuelType__c = sourceVIN.FuelType__c,
                TransmissionDescription__c = sourceVIN.TransmissionDesc__c,
                HasModelCode__c = (!String.isEmpty(sourceVIN.PQMSModelCode__c) ? true : false),
                Need_Review__c = false,
                CBU_CKD__c = sourceVIN.CBU_CKD__c,
                ProdCorp__c = sourceVIN.ProdCorp__c,
                VehicleType__c = sourceVIN.VehicleType__c
        );
    }
    /**
    * @description : Update fields when a case is updated
    * @author San, Kang : SanKang@autoeveramerica.com | 2023-12-01 ~ 2023-12-04
    * @tecket no: SO-299
    */
    public static void UpdateSearchVin(Map<Id, Case> newCasesMap, Map<Id, Case> oldCasesMap) {
        try{
            if(oldCasesMap.values()[0].Case_Own_Org__c.containsIgnoreCase('NASO') && newCasesMap.values()[0].Vin__c != null){
				if(oldCasesMap.values()[0].Search_Vin__c == null || newCasesMap.values()[0].VIN__c != oldCasesMap.values()[0].VIN__c){

                    String VinName;
                    Set<String> VinIdSet = new Set<String>();
                    
                    List<Case> CaseList = [SELECT Id, Search_Vin__c FROM Case WHERE Id =:newCasesMap.keySet()];
                    
                    for(Case CaseObj : CaseList){
                        if(newCasesMap.get(CaseObj.Id).VIN__c != null){
                            VinIdSet.add(newCasesMap.get(CaseObj.Id).VIN__c);
                        }
                    }
                    
                    List<Vin__c> VinList = [SELECT Id, Name FROM Vin__c WHERE Id IN :VinIdSet];
                
                    if(VinList.size()>0){
                        for(Vin__c vinObj : VinList){
                            VinName = vinObj.Name;
                        }
                    }
                    if(CaseList[0].Search_Vin__c != VinName)  {
                        List<Case> updateCaseList = new List<Case>();
                        for(Case CaseObj : CaseList){
                            //Created Case Source Vin                                                               //Updated Case, Source Vin
                            if((newCasesMap.get(CaseObj.Id).VIN__c == oldCasesMap.get(CaseObj.Id).VIN__c) || newCasesMap.get(CaseObj.Id).VIN__c != oldCasesMap.get(CaseObj.Id).VIN__c ){
                                CaseObj.Search_Vin__c  = VinName;
                                updateCaseList.add(CaseObj);
                            }
                        }
                        if(updateCaseList.size() >0){
                            update updateCaseList;
                        }           
                    }
                }
            }
            }catch(Exception e){
                System.debug('Exception => ' + e);
        }
    }
    
    /**
     * Converts a given date to UTC DateTime
     * Created by Areum on 2024-07-17 for SO-409
    */
    public static void convertToUTC(Map<Id, Case> caseMap) {
    	for (Case caseRecord : caseMap.values()) {
            if (caseRecord.FirstReportDate__c != null) {
                 // Get the user's input date from the FirstReportDate field and set the time to midnight (00:00:00)
            	DateTime userInputDate = DateTime.newInstance(caseRecord.FirstReportDate__c.year(), caseRecord.FirstReportDate__c.month(), caseRecord.FirstReportDate__c.day());

                // Get the user's time zone
                TimeZone userTimeZone = UserInfo.getTimezone();
                Integer offsetMilliseconds = userTimeZone.getOffset(userInputDate);
                Integer offsetHours = offsetMilliseconds / 3600000; // Convert milliseconds to hours
    
                // Convert the input date to UTC
                DateTime utcDateTime = userInputDate.addHours(-offsetHours);
                caseRecord.UTC_FirstReportDate__c = utcDateTime;
                System.debug('409 utcDateTime : ' + utcDateTime);
            }
        }
	}

}