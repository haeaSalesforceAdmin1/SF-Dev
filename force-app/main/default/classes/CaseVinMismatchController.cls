public class CaseVinMismatchController {

    @AuraEnabled
    public static String getVehicleData(String caseId) {
        System.debug('getVehicleData START');

        List<String> mismatchAttributes = new List<String>();
        DataWrapper vehicleDtWrapper = new DataWrapper();

        
        // // KASO.2023.05.06 복구시 주석 처리 필요 (1/3 시작)
        Case[] caseRecord = [Select id, CaseNumber, Case_Own_Org__c, CaseOwner__c, OwnerId from Case Where Id = :caseId];
        String caseOwnOrg;
        Boolean kasoCheck = false;

        if(caseRecord.size() > 0) {
            caseOwnOrg = caseRecord[0].Case_Own_Org__c;
            kasoCheck = caseOwnOrg.containsIgnoreCase('KASO');
        } else {
            kasoCheck = false;
        }  

        if (kasoCheck){ // KASO.2023.05.06 복구시 주석 처리 필요 (1/3)
    
            try {
                Case c = [
                        SELECT
                                Id,
                                KASO_VIN__c,
                                Make__c,
                                VehicleModel__c,
                                MY__c,
                                Trans__c,
                                Fuel_Type__c,
                                Drivetrain__c,
                                NAVEXValidatorStatus__c,
                                KASO_VIN__r.Make__c,
                                KASO_VIN__r.ModelDesc__c,
                                KASO_VIN__r.ModelYear__c,
                                KASO_VIN__r.TransmissionDesc__c,
                                KASO_VIN__r.FuelType__c,
                                KASO_VIN__r.DrivetrainDesc__c
                        FROM Case
                        WHERE Id = :caseId
                ];
                // Make, Model, Year, Trans, Fuel Type
                if (c <> null) {
                    if(c.KASO_VIN__c == null){
                        c.NAVEXValidatorStatus__c = 'Not Required';
                        update c;

                        System.debug('Updated Case (NO VIN):: ' + JSON.serializePretty(c));

                        return null;
                    }

                    if (!isMatch(c.Make__c, c.KASO_VIN__r.Make__c)) {
                        mismatchAttributes.add('Make');
                    }
                    if (!isMatch(c.VehicleModel__c, c.KASO_VIN__r.ModelDesc__c)) {
                        mismatchAttributes.add('Model');
                    }
                    if (!isMatch(c.MY__c, c.KASO_VIN__r.ModelYear__c)) {
                        mismatchAttributes.add('Year');
                    }
                    if (!isMatch(c.Trans__c, c.KASO_VIN__r.TransmissionDesc__c)) {
                        mismatchAttributes.add('Transmission');
                    }
                    if (!isMatch(c.Fuel_Type__c, c.KASO_VIN__r.FuelType__c)) {
                        mismatchAttributes.add('Fuel Type');
                    }
                    if (!isMatch(c.Drivetrain__c, c.KASO_VIN__r.DrivetrainDesc__c)) {
                        mismatchAttributes.add('Drivetrain');
                    }

                    System.debug('Navex Status:: ' + c.NAVEXValidatorStatus__c + ', Number of mismatches:: ' + mismatchAttributes.size());
                    if(c.NAVEXValidatorStatus__c == null && mismatchAttributes.size() == 0){
                        c.NAVEXValidatorStatus__c = 'Not Required';
                        update c;

                        System.debug('Updated Case (NO MISMATCH):: ' + JSON.serializePretty(c));

                        return null;
                    }

                    vehicleDtWrapper.mismatchFields = String.join(mismatchAttributes, ', ');

                    vehicleDtWrapper.caseMake = String.valueOf(c.Make__c);
                    vehicleDtWrapper.caseModel = String.valueOf(c.VehicleModel__c);
                    vehicleDtWrapper.caseModelYear = String.valueOf(c.MY__c);
                    vehicleDtWrapper.caseModelYear_formatted = CaseVehicleUtil.getFormattedYearsString(String.valueOf(c.MY__c));
                    vehicleDtWrapper.caseTransmission = String.valueOf(c.Trans__c);
                    vehicleDtWrapper.caseFuelType = String.valueOf(c.Fuel_Type__c);
                    vehicleDtWrapper.caseDrivetrain = String.valueOf(c.Drivetrain__c);

                    vehicleDtWrapper.vinMake = String.valueOf(c.KASO_VIN__r.Make__c);
                    vehicleDtWrapper.vinModel = String.valueOf(c.KASO_VIN__r.ModelDesc__c);
                    vehicleDtWrapper.vinModelYear = String.valueOf(c.KASO_VIN__r.ModelYear__c);
                    vehicleDtWrapper.vinModelYear_formatted= CaseVehicleUtil.getFormattedYearsString(String.valueOf(c.KASO_VIN__r.ModelYear__c));
                    vehicleDtWrapper.vinTransmission = String.valueOf(c.KASO_VIN__r.TransmissionDesc__c);
                    vehicleDtWrapper.vinFuelType = String.valueOf(c.KASO_VIN__r.FuelType__c);
                    vehicleDtWrapper.vinDrivetrain = String.valueOf(c.KASO_VIN__r.DrivetrainDesc__c);
                }
            } catch (Exception e) {
                System.debug('EXCEPTION:: ' + e.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }

        } else { // KASO.2023.05.06 복구시 주석 처리 필요 (1/3)
 
            try {
                Case c = [
                        SELECT
                                Id,
                                VIN__c,
                                Make__c,
                                VehicleModel__c,
                                MY__c,
                                Trans__c,
                                Fuel_Type__c,
                                Drivetrain__c,
                                NAVEXValidatorStatus__c,
                                VIN__r.Make__c,
                                VIN__r.ModelDesc__c,
                                VIN__r.ModelYear__c,
                                VIN__r.TransmissionDesc__c,
                                VIN__r.FuelType__c,
                                VIN__r.DrivetrainDesc__c
                        FROM Case
                        WHERE Id = :caseId
                ];
                // Make, Model, Year, Trans, Fuel Type
                if (c <> null) {
                    if(c.VIN__c == null){
                        c.NAVEXValidatorStatus__c = 'Not Required';
                        update c;

                        System.debug('Updated Case (NO VIN):: ' + JSON.serializePretty(c));

                        return null;
                    }

                    if (!isMatch(c.Make__c, c.VIN__r.Make__c)) {
                        mismatchAttributes.add('Make');
                    }
                    if (!isMatch(c.VehicleModel__c, c.VIN__r.ModelDesc__c)) {
                        mismatchAttributes.add('Model');
                    }
                    if (!isMatch(c.MY__c, c.VIN__r.ModelYear__c)) {
                        mismatchAttributes.add('Year');
                    }
                    if (!isMatch(c.Trans__c, c.VIN__r.TransmissionDesc__c)) {
                        mismatchAttributes.add('Transmission');
                    }
                    if (!isMatch(c.Fuel_Type__c, c.VIN__r.FuelType__c)) {
                        mismatchAttributes.add('Fuel Type');
                    }
                    if (!isMatch(c.Drivetrain__c, c.VIN__r.DrivetrainDesc__c)) {
                        mismatchAttributes.add('Drivetrain');
                    }

                    System.debug('Navex Status:: ' + c.NAVEXValidatorStatus__c + ', Number of mismatches:: ' + mismatchAttributes.size());
                    if(c.NAVEXValidatorStatus__c == null && mismatchAttributes.size() == 0){
                        c.NAVEXValidatorStatus__c = 'Not Required';
                        update c;

                        System.debug('Updated Case (NO MISMATCH):: ' + JSON.serializePretty(c));

                        return null;
                    }

                    vehicleDtWrapper.mismatchFields = String.join(mismatchAttributes, ', ');

                    vehicleDtWrapper.caseMake = String.valueOf(c.Make__c);
                    vehicleDtWrapper.caseModel = String.valueOf(c.VehicleModel__c);
                    vehicleDtWrapper.caseModelYear = String.valueOf(c.MY__c);
                    vehicleDtWrapper.caseModelYear_formatted = CaseVehicleUtil.getFormattedYearsString(String.valueOf(c.MY__c));
                    vehicleDtWrapper.caseTransmission = String.valueOf(c.Trans__c);
                    vehicleDtWrapper.caseFuelType = String.valueOf(c.Fuel_Type__c);
                    vehicleDtWrapper.caseDrivetrain = String.valueOf(c.Drivetrain__c);

                    vehicleDtWrapper.vinMake = String.valueOf(c.VIN__r.Make__c);
                    vehicleDtWrapper.vinModel = String.valueOf(c.VIN__r.ModelDesc__c);
                    vehicleDtWrapper.vinModelYear = String.valueOf(c.VIN__r.ModelYear__c);
                    vehicleDtWrapper.vinModelYear_formatted= CaseVehicleUtil.getFormattedYearsString(String.valueOf(c.VIN__r.ModelYear__c));
                    vehicleDtWrapper.vinTransmission = String.valueOf(c.VIN__r.TransmissionDesc__c);
                    vehicleDtWrapper.vinFuelType = String.valueOf(c.VIN__r.FuelType__c);
                    vehicleDtWrapper.vinDrivetrain = String.valueOf(c.VIN__r.DrivetrainDesc__c);
                }
            } catch (Exception e) {
                System.debug('EXCEPTION:: ' + e.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }

        } // KASO.2023.05.06 복구시 주석 처리 필요 (1/3 끝)

        return JSON.serializePretty(vehicleDtWrapper);
    }

    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-23
    * @tecket no: SO-311
    */
    @AuraEnabled
    public static String getNASOData(String caseId) {
        NasoDataWrapper NasoDataWrapper = new NasoDataWrapper();
        try {
            Case c = [
                    SELECT
                            Subject,
                            Description,
                            NHTSA_TREAD_Category__c
                    FROM Case
                    WHERE Id = :caseId
            ];
            NasoDataWrapper.caseSubject = String.valueOf(c.Subject);
            NasoDataWrapper.caseDescription = String.valueOf(c.Description);
            NasoDataWrapper.caseNHTSATREADCategory = String.valueOf(c.NHTSA_TREAD_Category__c);
        } catch (Exception e) {
            System.debug('EXCEPTION:: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serializePretty(NasoDataWrapper);
    }

    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-23
    * @tecket no: SO-311
    */
    @AuraEnabled
    public static Boolean getFiltervisblity(String caseId) {
        Boolean filterVisblit = false;
        Case[] caseObject = [SELECT Id
                            FROM Case 
                            WHERE Id=:caseId 
                            AND Stage__c = 'DA' 
                            AND NAVEXValidatorStatus__c != 'Not Required' 
                            AND NAVEXValidatorStatus__c != 'Accepted' 
                            AND NAVEXValidatorStatus__c != 'Rejected' 
                            AND Status = 'Open'
                            AND CaseID__c != null];

                            System.debug('caseObject:::'+caseObject.size());
        if(caseObject.size() > 0) {
            filterVisblit = true;
        }

        return filterVisblit;
    }

    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */
    @AuraEnabled
    public static Boolean checkCaseOwnOrg(String caseId) {
        Case[] caseRecord = [Select recordType.DeveloperName,DAOwner__c from Case Where Id = :caseId and recordType.DeveloperName='DA' and FirstReportSource__c = 'Speak Up For Safety' and NAVEXEPRSNumber__c != null];
        Boolean nasoCheck = false;
        Id profileId = UserInfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id=:profileId].Name; 
        if(caseRecord.size() > 0 && ( caseRecord[0].DAOwner__c == UserInfo.getUserId() || FeatureManagement.checkPermission('SC_Safety_DA_Engineer') || FeatureManagement.checkPermission('Service_Cloud_Safety_Admin') || FeatureManagement.checkPermission('SC_Safety_DA_Manager') || profileName.equalsIgnoreCase('System Administrator'))) {
            nasoCheck = true;
        }
        return nasocheck;
    }

    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */
    @AuraEnabled(cacheable=true)
    public static List<SelectOptionWrapper> getNHTSATREADCategory(String caseId){
        List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
        String ObjName = Id.valueOf(caseId).getSobjectType().getDescribe().getName();
        Schema.DescribeFieldResult FieldResult = Schema.getGlobalDescribe().get(ObjName).getDescribe().fields.getMap().get('NHTSA_TREAD_Category__c').getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : picklistValues){
            options.add(new SelectOptionWrapper(entry.getValue(), entry.getLabel()));

        }
        return options;

    }
    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */
    @AuraEnabled
    public static void updateMisMatchCase(Object category, String subject, String description, String caseId){
        try{
            String categoryStr = String.valueOf(category);
            categoryStr = categoryStr.startsWith('(') && categoryStr.endsWith(')') ? categoryStr.removeStart(categoryStr.left(1)).removeEnd(categoryStr.right(1)).replace(',',';') : categoryStr.removeStart(categoryStr.left(1)).removeEnd(categoryStr.right(1)).replace(',',';');

            Case caseobj = [
                SELECT
                    NHTSA_TREAD_Category__c,
                    Subject,
                    Description,
                    NAVEXValidatorStatus__c
                FROM Case
                WHERE Id = :CaseId
            ];

            if(caseobj != null){
                caseobj.NHTSA_TREAD_Category__c = categoryStr;
                caseobj.Subject = subject;
                caseobj.Description = description;

                update caseobj;
            
            }
        }catch(Exception e){
            System.debug('Exception => ' + e);
        }
                
    }
    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */
    @AuraEnabled
    public static void updateRejectMisMatchCase(Object category, String subject, String description, String caseId) {
        String categoryStr = String.valueOf(category);
        categoryStr = categoryStr.startsWith('(') && categoryStr.endsWith(')') ? categoryStr.removeStart(categoryStr.left(1)).removeEnd(categoryStr.right(1)).replace(',',';') : categoryStr.removeStart(categoryStr.left(1)).removeEnd(categoryStr.right(1)).replace(',',';');

        try {
            Case c = [SELECT Id, VIN__c, NAVEXValidatorStatus__c, Subject, Description, NHTSA_TREAD_Category__c FROM Case WHERE Id = :caseId AND VIN__c <> NULL];
            c.NAVEXValidatorStatus__c = 'Rejected';
            c.NHTSA_TREAD_Category__c = categoryStr;
            c.Subject = subject;
            c.Description = description;
            update c;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */
    @AuraEnabled
    public static void updateAcceptMisMatchCase(Object category, String subject, String description, String caseId){
        String categoryStr = String.valueOf(category);
        categoryStr = categoryStr.startsWith('(') && categoryStr.endsWith(')') ? categoryStr.removeStart(categoryStr.left(1)).removeEnd(categoryStr.right(1)).replace(',',';') : categoryStr.removeStart(categoryStr.left(1)).removeEnd(categoryStr.right(1)).replace(',',';');
        try{
            Case c = [
                SELECT
                        Id,
                        VIN__c,
                        NAVEXValidatorStatus__c,
                        Make__c,
                        VehicleModel__c,
                        ModelCode__c,
                        MY__c,
                        Trans__c,
                        Fuel_Type__c,
                        Drivetrain__c,
                        Engine__c,
                        Subject,
                        Description,
                        NHTSA_TREAD_Category__c,
                        VIN__r.Make__c,
                        VIN__r.ModelDesc__c,
                        VIN__r.PQMSModelCode__c,
                        VIN__r.ModelYear__c,
                        VIN__r.TransmissionDesc__c,
                        VIN__r.FuelType__c,
                        VIN__r.DrivetrainDesc__c,
                        VIN__r.EngineDesc__c, (
                        SELECT
                                Id,
                                Make__c,
                                Model__c,
                                ModelCode__c,
                                VehicleYear__c,
                                TransmissionDescription__c,
                                FuelType__c,
                                DrivetrainDescription__c,
                                EngineDescription__c,
                                Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :caseId
                AND VIN__c <> NULL
        ];
        c.NAVEXValidatorStatus__c = 'Accepted';
        c.Make__c = c.VIN__r.Make__c;
        c.VehicleModel__c = c.VIN__r.ModelDesc__c;
        c.ModelCode__c = c.VIN__r.PQMSModelCode__c;
        c.MY__c = c.VIN__r.ModelYear__c;
        c.Trans__c = c.VIN__r.TransmissionDesc__c;
        c.Fuel_Type__c = c.VIN__r.FuelType__c;
        c.Drivetrain__c = c.VIN__r.DrivetrainDesc__c;
        c.Engine__c = c.VIN__r.EngineDesc__c;
        c.NHTSA_TREAD_Category__c = categoryStr;
        c.Subject = subject;
        c.Description = description;



        if (c.CaseVehicles__r.size() > 0) {
            List<CaseVehicle__c> caseVehicles = c.CaseVehicles__r;
            for (CaseVehicle__c cv : caseVehicles) {
                cv.Make__c = c.VIN__r.Make__c;
                cv.Model__c = c.VIN__r.ModelDesc__c;
                cv.ModelCode__c = c.VIN__r.PQMSModelCode__c;
                cv.VehicleYear__c = c.VIN__r.ModelYear__c;
                cv.TransmissionDescription__c = c.VIN__r.TransmissionDesc__c;
                cv.FuelType__c = c.VIN__r.FuelType__c;
                cv.DrivetrainDescription__c = c.VIN__r.DrivetrainDesc__c;
                cv.EngineDescription__c = c.VIN__r.EngineDesc__c;
                cv.Need_Review__c = false;
            }
            c.VehicleInfo__c = CaseVehicleUtil.GenerateVehicleInfo(caseVehicles);
            update c;
            update caseVehicles;
        }

        }catch(Exception e){
            System.debug(e.getMessage());
        }
                
    }
    

    @AuraEnabled
    public static void acceptBtnClicked(String caseId) {

        // KASO.2023.05.06 복구시 주석 처리 필요 (2/3 시작)
        Case[] caseRecord = [Select id, CaseNumber, Case_Own_Org__c, CaseOwner__c, OwnerId from Case Where Id = :caseId];
        String caseOwnOrg;
        Boolean kasoCheck = false;

        if(caseRecord.size() > 0) {
            caseOwnOrg = caseRecord[0].Case_Own_Org__c;
            kasoCheck = caseOwnOrg.containsIgnoreCase('KASO');
        } else {
            kasoCheck = false;
        }   

        if (kasoCheck){ // KASO.2023.05.06 복구시 주석 처리 필요 (2/3)

            try {
                Case c = [
                        SELECT
                                Id,
                                KASO_VIN__c,
                                NAVEXValidatorStatus__c,
                                Make__c,
                                VehicleModel__c,
                                ModelCode__c,
                                MY__c,
                                Trans__c,
                                Fuel_Type__c,
                                Drivetrain__c,
                                Engine__c,
                                KASO_VIN__r.Make__c,
                                KASO_VIN__r.ModelDesc__c,
                                KASO_VIN__r.PQMSModelCode__c,
                                KASO_VIN__r.ModelYear__c,
                                KASO_VIN__r.TransmissionDesc__c,
                                KASO_VIN__r.FuelType__c,
                                KASO_VIN__r.DrivetrainDesc__c,
                                KASO_VIN__r.EngineDesc__c, (
                                SELECT
                                        Id,
                                        Make__c,
                                        Model__c,
                                        ModelCode__c,
                                        VehicleYear__c,
                                        TransmissionDescription__c,
                                        FuelType__c,
                                        DrivetrainDescription__c,
                                        EngineDescription__c,
                                        Need_Review__c
                                FROM KASOCaseVehicles__r
                        )
                        FROM Case
                        WHERE Id = :caseId
                        AND KASO_VIN__c <> NULL
                ];

                c.NAVEXValidatorStatus__c = 'Accepted';
                c.Make__c = c.KASO_VIN__r.Make__c;
                c.VehicleModel__c = c.KASO_VIN__r.ModelDesc__c;
                c.ModelCode__c = c.KASO_VIN__r.PQMSModelCode__c;
                c.MY__c = c.KASO_VIN__r.ModelYear__c;
                c.Trans__c = c.KASO_VIN__r.TransmissionDesc__c;
                c.Fuel_Type__c = c.KASO_VIN__r.FuelType__c;
                c.Drivetrain__c = c.KASO_VIN__r.DrivetrainDesc__c;
                c.Engine__c = c.KASO_VIN__r.EngineDesc__c;


                if (c.KASOCaseVehicles__r.size() > 0) {
                    List<KASOCaseVehicle__c> caseVehicles = c.KASOCaseVehicles__r;
                    for (KASOCaseVehicle__c cv : caseVehicles) {
                        cv.Make__c = c.KASO_VIN__r.Make__c;
                        cv.Model__c = c.KASO_VIN__r.ModelDesc__c;
                        cv.ModelCode__c = c.KASO_VIN__r.PQMSModelCode__c;
                        cv.VehicleYear__c = c.KASO_VIN__r.ModelYear__c;
                        cv.TransmissionDescription__c = c.KASO_VIN__r.TransmissionDesc__c;
                        cv.FuelType__c = c.KASO_VIN__r.FuelType__c;
                        cv.DrivetrainDescription__c = c.KASO_VIN__r.DrivetrainDesc__c;
                        cv.EngineDescription__c = c.KASO_VIN__r.EngineDesc__c;
                        cv.Need_Review__c = false;
                    }
                    c.VehicleInfo__c = CaseVehicleUtil.GenerateVehicleInfo(caseVehicles);
                    update c;

                    update caseVehicles;
                }

            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else { // KASO.2023.05.06 추가, 복구시 주석 처리 필요 (2/3)

            try {
                Case c = [
                        SELECT
                                Id,
                                VIN__c,
                                NAVEXValidatorStatus__c,
                                Make__c,
                                VehicleModel__c,
                                ModelCode__c,
                                MY__c,
                                Trans__c,
                                Fuel_Type__c,
                                Drivetrain__c,
                                Engine__c,
                                VIN__r.Make__c,
                                VIN__r.ModelDesc__c,
                                VIN__r.PQMSModelCode__c,
                                VIN__r.ModelYear__c,
                                VIN__r.TransmissionDesc__c,
                                VIN__r.FuelType__c,
                                VIN__r.DrivetrainDesc__c,
                                VIN__r.EngineDesc__c, (
                                SELECT
                                        Id,
                                        Make__c,
                                        Model__c,
                                        ModelCode__c,
                                        VehicleYear__c,
                                        TransmissionDescription__c,
                                        FuelType__c,
                                        DrivetrainDescription__c,
                                        EngineDescription__c,
                                        Need_Review__c
                                FROM CaseVehicles__r
                        )
                        FROM Case
                        WHERE Id = :caseId
                        AND VIN__c <> NULL
                ];
                c.NAVEXValidatorStatus__c = 'Accepted';
                c.Make__c = c.VIN__r.Make__c;
                c.VehicleModel__c = c.VIN__r.ModelDesc__c;
                c.ModelCode__c = c.VIN__r.PQMSModelCode__c;
                c.MY__c = c.VIN__r.ModelYear__c;
                c.Trans__c = c.VIN__r.TransmissionDesc__c;
                c.Fuel_Type__c = c.VIN__r.FuelType__c;
                c.Drivetrain__c = c.VIN__r.DrivetrainDesc__c;
                c.Engine__c = c.VIN__r.EngineDesc__c;



                if (c.CaseVehicles__r.size() > 0) {
                    List<CaseVehicle__c> caseVehicles = c.CaseVehicles__r;
                    for (CaseVehicle__c cv : caseVehicles) {
                        cv.Make__c = c.VIN__r.Make__c;
                        cv.Model__c = c.VIN__r.ModelDesc__c;
                        cv.ModelCode__c = c.VIN__r.PQMSModelCode__c;
                        cv.VehicleYear__c = c.VIN__r.ModelYear__c;
                        cv.TransmissionDescription__c = c.VIN__r.TransmissionDesc__c;
                        cv.FuelType__c = c.VIN__r.FuelType__c;
                        cv.DrivetrainDescription__c = c.VIN__r.DrivetrainDesc__c;
                        cv.EngineDescription__c = c.VIN__r.EngineDesc__c;
                        cv.Need_Review__c = false;
                    }
                    c.VehicleInfo__c = CaseVehicleUtil.GenerateVehicleInfo(caseVehicles);
                    update c;
                    
                    update caseVehicles;
                }

            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } // KASO.2023.05.06 복구시 주석 처리 필요 (2/3 끝)
    }

    @AuraEnabled
    public static void rejectBtnClicked(String caseId) {

        // KASO.2023.05.06 복구시 주석 처리 필요 (3/3 시작)
        Case[] caseRecord = [Select id, CaseNumber, Case_Own_Org__c, CaseOwner__c, OwnerId from Case Where Id = :caseId];
        String caseOwnOrg;
        Boolean kasoCheck = false;

        if(caseRecord.size() > 0) {
            caseOwnOrg = caseRecord[0].Case_Own_Org__c;
            kasoCheck = caseOwnOrg.containsIgnoreCase('KASO');
        } else {
            kasoCheck = false;
        }   
          
        if (kasoCheck){ // KASO.2023.05.06 복구시 주석 처리 필요 (3/3)
        
            try {
                Case c = [SELECT Id, KASO_VIN__c, NAVEXValidatorStatus__c FROM Case WHERE Id = :caseId AND KASO_VIN__c <> NULL];
                c.NAVEXValidatorStatus__c = 'Rejected';
                update c;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            
        } else { // KASO.2023.05.06 복구시 주석 처리 필요 (3/3)

            try {
                Case c = [SELECT Id, VIN__c, NAVEXValidatorStatus__c FROM Case WHERE Id = :caseId AND VIN__c <> NULL];
                c.NAVEXValidatorStatus__c = 'Rejected';
                update c;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }

        } // KASO.2023.05.06 복구시 주석 처리 필요 (3/3 끝)
    }

    /*------------ Util methods ------------ */

    private static Boolean isMatch(String str1, String str2) {
        return str1?.equalsIgnoreCase(str2) == true; // the left side returns true, false, or null
    }

    /*------------ Wrapper Classes ------------ */
    public class DataWrapper {
        // Case Fields
        public String caseMake = '';
        public String caseModel = '';
        public String caseModelYear = '';
        public String caseModelYear_formatted = '';
        public String caseTransmission = '';
        public String caseFuelType = '';
        public String caseDrivetrain = '';


        // Vin Fields
        public String vinMake = '';
        public String vinModel = '';
        public String vinModelYear = '';
        public String vinModelYear_formatted = '';
        public String vinTransmission = '';
        public String vinFuelType = '';
        public String vinDrivetrain = '';

        public String mismatchFields = '';
    }

    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */    
    public class NasoDataWrapper {
        public String caseSubject = '';
        public String caseDescription = '';
        public String caseNHTSATREADCategory = '';
    }

    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */    
    public class SelectOptionWrapper {
        
        @AuraEnabled
        public string label{ get; set; }

        @AuraEnabled
        public string value{ get; set; }

        public SelectOptionWrapper(String value, String label){
            this.value = value;
            this.label = label;
        }
    }

    


//    public static void testClass(){
//        Integer i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//        i = 0;
//    }
}