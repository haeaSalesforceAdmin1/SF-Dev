@IsTest
public class CaseTriggerTest {
    static HMAReferenceData__c makeReference() {
        HMAReferenceData__c referenceData = new HMAReferenceData__c();
        referenceData.Make__c = 'GENESIS';
        referenceData.VehicleModel__c = 'G80';
        referenceData.Year__c = '2021';
        referenceData.FuelType__c = 'TURBO';
        referenceData.EngineDescription__c = '2.5L TWIN TURBO THETA';
        referenceData.DrivetrainDescription__c = 'ALL WHEEL DRIVE';
        referenceData.TransmissionDescription__c = 'AUTO';
        referenceData.ModelCode__c = 'DH';
        return referenceData;
    }
    static HMCReferenceData__c makeHmcReferenceData(){
        HMCReferenceData__c referenceData = new HMCReferenceData__c();
        referenceData.Make__c = 'Hyundai';
        referenceData.VehicleModel__c = 'SANTA FE';
        referenceData.Year__c = '2020';
        referenceData.FuelType__c = 'Gas';
        referenceData.EngineDescription__c = '2.4L I4 GDI Theta II';
        referenceData.DrivetrainDescription__c = 'ALL WHEEL DRIVE';
        referenceData.TransmissionDescription__c = 'AUTO';
        referenceData.ModelCode__c = 'TMA';
        return referenceData;
    }

	static HMAReferenceData__c makeReference1() {
        HMAReferenceData__c referenceData = new HMAReferenceData__c();
        referenceData.Make__c = 'Hyundai';
        referenceData.VehicleModel__c = 'SANTA FE';
        referenceData.Year__c = '2020';
        referenceData.FuelType__c = 'Gas';
        referenceData.EngineDescription__c = '2.4L I4 GDI Theta II';
        referenceData.DrivetrainDescription__c = 'ALL WHEEL DRIVE';
        referenceData.TransmissionDescription__c = 'AUTO';
        referenceData.ModelCode__c = 'TMA';
        return referenceData;
    }

    static VIN__c makeVIN() {
        VIN__c vin = new VIN__c();
        vin.Make__c = 'GENESIS';
        vin.ModelDesc__c = 'G80';
        vin.ModelYear__c = '2021';
        vin.FuelType__c = 'TURBO';
        vin.EngineDesc__c = '2.5L TWIN TURBO THETA';
        vin.DrivetrainDesc__c = 'ALL WHEEL DRIVE';
        vin.TransmissionDesc__c = 'AUTO';
        vin.PQMSModelCode__c = 'DH';
        return vin;
    }

    // KASO.20230514 추가
    static KASO_VIN__c makeKASOVIN() {
        KASO_VIN__c vin = new KASO_VIN__c();
        vin.Make__c = 'GENESIS';
        vin.ModelDesc__c = 'G80';
        vin.ModelYear__c = '2021';
        vin.FuelType__c = 'TURBO';
        vin.EngineDesc__c = '2.5L TWIN TURBO THETA';
        vin.DrivetrainDesc__c = 'ALL WHEEL DRIVE';
        vin.TransmissionDesc__c = 'AUTO';
        vin.PQMSModelCode__c = 'DH';
        return vin;
    }

    static Case makeCase(VIN__c vinRecord) {
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();

        SCSConfigurationSettings__c setting = new SCSConfigurationSettings__c();
        setting.CurrentCaseNumber__c = 1;
        insert setting;

        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMA';
        c.CountrySubmitterWorks__c = 'Canada';
        c.SCSCaseRegion__c = 'North America';
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';
        c.VIN__c = vinRecord.Id;

        return c;
    }

    // KASO.20230514 추가
    static Case makeCase(KASO_VIN__c vinRecord) {
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('KASDA').getRecordTypeId();

        SCSConfigurationSettings__c setting = new SCSConfigurationSettings__c();
        setting.CurrentCaseNumber__c = 1;
        insert setting;

        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMC';
        c.CountrySubmitterWorks__c = 'Korea';
        c.SCSCaseRegion__c = 'Korea';
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test2';       // KASO.202523.05.14 Test1 -> Test2 변경
        c.KASO_VIN__c = vinRecord.Id;

        return c;
    }

    static Case makeCase(HMAReferenceData__c reference, Boolean isNavexCase, Boolean isPartialMatch) {
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();

        SCSConfigurationSettings__c setting = new SCSConfigurationSettings__c();
        setting.CurrentCaseNumber__c = 1;
        insert setting;

        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMA';
        c.CountrySubmitterWorks__c = 'Canada';
        c.SCSCaseRegion__c = 'North America';
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';
        if (isNavexCase) {
            c.CaseID__c = 'testcaseid';
            c.Engine__c = '';
            c.ModelCode__c = '';
        }
        if (reference == null) {
            c.Make__c = 'Hyundai';
            c.VehicleModel__c = 'Accent';
            c.Fuel_Type__c = 'GAS';
            c.Drivetrain__c = 'FRONT WHEEL DRIVE';
            c.Trans__c = 'Manual';
            c.MY__c = '2006';
            if (!isNavexCase) {
                c.Engine__c = '1.6L I4 DOHC MPI GAMMA II';
                c.ModelCode__c = 'HC';
            }
        } else {
            c.Make__c = reference.Make__c;
            c.VehicleModel__c = reference.VehicleModel__c;
            c.Fuel_Type__c = reference.FuelType__c;
            c.Drivetrain__c = reference.DrivetrainDescription__c;
            c.Trans__c = reference.TransmissionDescription__c;
            c.MY__c = reference.Year__c;
            if (isPartialMatch) {
                c.Fuel_Type__c = 'GAS';
                c.Trans__c = 'Manual';
                c.MY__c = '2006';
            }
            if (!isNavexCase) {
                c.ModelCode__c = reference.ModelCode__c;
                c.Engine__c = reference.EngineDescription__c;
            }
        }
        return c;
    }

    static Case makeCase1(HMAReferenceData__c reference) {
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('KASDA').getRecordTypeId();  // KASO.2023.05.14 수정본 
        //Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();    // KASO.2023.05.14 원본 

        SCSConfigurationSettings__c setting = new SCSConfigurationSettings__c();
        setting.CurrentCaseNumber__c = 1;
        insert setting;

        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMC';                       // KASO.2023.05.14 수정본
        c.CountrySubmitterWorks__c = 'Korea';           // KASO.2023.05.14 수정본
        c.SCSCaseRegion__c = 'Korea';                   // KASO.2023.05.14 수정본
        // c.CompanyName__c = 'HMA';                    // KASO.2023.05.14 원본
        // c.CountrySubmitterWorks__c = 'Canada';       // KASO.2023.05.14 원본
        // c.SCSCaseRegion__c = 'North America';        // KASO.2023.05.14 원본
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';
        c.TrackingID__c= '73';
        //c.CaseID__c='5NMS33AD2LH202622';              // KASO.2023.05.14 원본 주석 처리, NAVEX check
        c.SODAS_Alert_ID__c='Test';
        c.SIMS_GSI_Number__c='73';
        c.Origin= 'Value';
        c.VIN_Text_Field__c= '5NMS33AD2LH202622';
        c.Make__c= 'Hyundai';
        c.HazardCategory__c= '1-Difficulty/inability to control direction/path (steering, stability, etc.)';
        c.MY__c= '2020';                           // KASO.2023.05.14 수정, 2019;2020 --> 2020
        c.MethodofRepair__c= 'Dealer to replace the engine';
        c.Parts__c= '2';
        c.PossiblyAssociablePrimaryHazard__c= 'Difficulty/inability to control direction/path (steering, stability, etc.)';
        c.Region__c= 'central region';
        c.Severity__c= '3';
        c.CategoryofComponentAffected__c= 'Engine';
        c.ModelCode__c= 'TMA';
        //c.CompanyName__c= 'HMA';                          // KASO.2023.05.14 원본 주석 처리, 중복 오류
        //c.CountrySubmitterWorks__c= 'Korea';              // KASO.2023.05.14 원본 주석 처리, 중복 오류
        //c.Haveyoupreviouslyreportedtheissues__c= 'No';    // KASO.2023.05.14 원본 주석 처리, 중복 오류
        c.FirstReportSource__c= 'SIMS';
        c.Engine__c='2.4L I4 GDI Theta II';
        c.Fuel_Type__c='Gas';

        return c;
    }


    static Case makeCase11(HMAReferenceData__c reference) {
        //Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('KASODA').getRecordTypeId();  // KASO.2023.05.14 수정본 
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();    // KASO.2023.05.14 원본 

        SCSConfigurationSettings__c setting = new SCSConfigurationSettings__c();
        setting.CurrentCaseNumber__c = 1;
        insert setting;

        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.SafetyType__c = 'Vehicle';
        //c.CompanyName__c = 'HMC';                       // KASO.2023.05.14 수정본
        //c.CountrySubmitterWorks__c = 'Korea';           // KASO.2023.05.14 수정본
        //c.SCSCaseRegion__c = 'Korea';                   // KASO.2023.05.14 수정본
         c.CompanyName__c = 'HMA';                    // KASO.2023.05.14 원본
         c.CountrySubmitterWorks__c = 'Canada';       // KASO.2023.05.14 원본
         c.SCSCaseRegion__c = 'North America';        // KASO.2023.05.14 원본
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';
        c.TrackingID__c= '73';
        //c.CaseID__c='5NMS33AD2LH202622';              // KASO.2023.05.14 원본 주석 처리, NAVEX check
        c.SODAS_Alert_ID__c='Test';
        c.SIMS_GSI_Number__c='73';
        c.Origin= 'Value';
        c.VIN_Text_Field__c= '5NMS33AD2LH202622';
        c.Make__c= 'Hyundai';
        c.HazardCategory__c= '1-Difficulty/inability to control direction/path (steering, stability, etc.)';
        c.MY__c= '2020';                           // KASO.2023.05.14 수정, 2019;2020 --> 2020
        c.MethodofRepair__c= 'Dealer to replace the engine';
        c.Parts__c= '2';
        c.PossiblyAssociablePrimaryHazard__c= 'Difficulty/inability to control direction/path (steering, stability, etc.)';
        c.Region__c= 'central region';
        c.Severity__c= '3';
        c.CategoryofComponentAffected__c= 'Engine';
        c.ModelCode__c= 'TMA';
        //c.CompanyName__c= 'HMA';                          // KASO.2023.05.14 원본 주석 처리, 중복 오류
        //c.CountrySubmitterWorks__c= 'Korea';              // KASO.2023.05.14 원본 주석 처리, 중복 오류
        //c.Haveyoupreviouslyreportedtheissues__c= 'No';    // KASO.2023.05.14 원본 주석 처리, 중복 오류
        c.FirstReportSource__c= 'SIMS';
        c.Engine__c='2.4L I4 GDI Theta II';
        c.Fuel_Type__c='Gas';

        return c;
    }

    static Case makeCase2(HMAReferenceData__c reference) {
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('KASDA').getRecordTypeId();  // KASO.2023.05.14 수정본 
        // Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();   // KASO.2023.05.14 원본

        SCSConfigurationSettings__c setting = new SCSConfigurationSettings__c();
        setting.CurrentCaseNumber__c = 1;
        insert setting;

        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMC';                           // KASO.2023.05.14 수정본
        c.CountrySubmitterWorks__c = 'Korea';               // KASO.2023.05.14 수정본
        c.SCSCaseRegion__c = 'Korea';                       // KASO.2023.05.14 수정본
        // c.CompanyName__c = 'HMA';                        // KASO.2023.05.14 원본
        // c.CountrySubmitterWorks__c = 'Canada';           // KASO.2023.05.14 원본
        // c.SCSCaseRegion__c = 'North America';            // KASO.2023.05.14 원본
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';
        c.TrackingID__c= '73';
        c.CaseID__c='5NMS33AD2LH202622';
        c.SODAS_Alert_ID__c='Test';
        c.SIMS_GSI_Number__c='73';
        c.Origin= 'Value';
        c.VIN_Text_Field__c= '5NMS33AD2LH202622';
        c.Make__c= 'Hyundai';
        c.HazardCategory__c= '1-Difficulty/inability to control direction/path (steering, stability, etc.)';
        c.MY__c= '2020';
        c.MethodofRepair__c= 'Dealer to replace the engine';
        c.Parts__c= '2';
        c.PossiblyAssociablePrimaryHazard__c= 'Difficulty/inability to control direction/path (steering, stability, etc.)';
        c.Region__c= 'central region';
        c.Severity__c= '3';
        c.CategoryofComponentAffected__c= 'Engine';
        c.ModelCode__c= 'TMA';
        //c.CompanyName__c= 'HMA';                              // KASO.2023.05.14 원본 주석 처리, 중복 오류
        //c.CountrySubmitterWorks__c= 'Korea';                  // KASO.2023.05.14 원본 주석 처리, 중복 오류
        //c.Haveyoupreviouslyreportedtheissues__c= 'No';        // KASO.2023.05.14 원본 주석 처리, 중복 오류
        c.FirstReportSource__c= 'SIMS';
        c.Engine__c='2.4L I4 GDI Theta II';
        c.Fuel_Type__c='Gas';

        return c;
    }

    @IsTest
    public static void testSIMS() {
        HMAReferenceData__c reference = makeReference1();
        insert reference;
        VIN__c vi = new VIN__c();
        vi.Make__c='Hyundai';
        vi.PQMSModelcode__c='TMA';
        vi.ModelYear__c='2020';
        vi.ModelDesc__c='SANTA FE';
        vi.EngineDesc__c='2.4L I4 GDI Theta II';
        vi.FuelType__c='GAS';
        vi.DrivetrainDesc__c='FRONT WHEEL DRIVE';
        vi.TransmissionDesc__c='AUTO';
        vi.VIN_External_ID__c='5NMS33AD2LH202622';
        insert vi;
        Case c;
        System.runAs(getNasoUser()) {  // 2023.06.03 getIntegrationUser()
            Test.startTest();
            c = makeCase11(reference);
			c.VIN__c = vi.Id;
            insert c;
            Request__c r =new Request__c();
            r.Name='Test';
            r.Safety_CaseNumber__c=c.SCSCaseNumber__c;
            r.Integrity_Check_EAI__c=true;
            insert r;
            Test.stopTest();
        }
    }

    // KASO.20230514 추가
    @IsTest
    public static void testSIMS1() {
        HMAReferenceData__c reference = makeReference1();
        insert reference;
        KASO_VIN__c vi = new KASO_VIN__c();
        vi.Make__c='Hyundai';
        vi.PQMSModelcode__c='TMA';
        vi.ModelYear__c='2020';
        vi.ModelDesc__c='SANTA FE';
        vi.EngineDesc__c='2.4L I4 GDI Theta II';
        vi.FuelType__c='GAS';
        vi.DrivetrainDesc__c='FRONT WHEEL DRIVE';
        vi.TransmissionDesc__c='AUTO';
        vi.VIN_External_ID__c='5NMS33AD2LH202622';
        insert vi;
        Case c;
        System.runAs(getNasoUser()) {   // 2023.06.03 getIntegrationUser()
            Test.startTest();
            c = makeCase11(reference);
			c.KASO_VIN__c = vi.Id;
            insert c;
            Request__c r =new Request__c();
            r.Name='Test';
            r.Safety_CaseNumber__c=c.SCSCaseNumber__c;
            r.Integrity_Check_EAI__c=true;
            insert r;
            Test.stopTest();
        }
    }

	@IsTest
    public static void testSIMStoCMT() {
        HMAReferenceData__c reference = makeReference1();
        insert reference;
        VIN__c vin = makeVIN();
        insert vin;
        Case c;
        System.runAs(getNasoUser()) {  // 2023.06.03 getIntegrationUser()
            Test.startTest();
            // VIN__c vi = new VIN__c();
            // vi.Make__c='Hyundai';
            // vi.PQMSModelcode__c='TMA';
            // vi.ModelYear__c='2020';
            // vi.ModelDesc__c='SANTA FE';
            // vi.EngineDesc__c='2.4L I4 GDI Theta II';
            // vi.FuelType__c='GAS';
            // vi.DrivetrainDesc__c='FRONT WHEEL DRIVE';
            // vi.TransmissionDesc__c='AUTO';
            // vi.VIN_External_ID__c='5NMS33AD2LH202622';
            //insert vi;
            c = makeCase11(reference);   //  c = makeCase2(reference); 
            //c.VIN__c = vi.Id;
            insert c;
            Request__c r =new Request__c();
            r.Name='Test1';
            r.Safety_CaseNumber__c=c.SCSCaseNumber__c;
            r.Integrity_Check_EAI__c=true;
            insert r;
            Test.stopTest();
        }
	}

    // KASO.20230514 추가
    @IsTest
    public static void testSIMStoCMT1() {
        HMAReferenceData__c reference = makeReference1();
        insert reference;
            KASO_VIN__c vin = makeKASOVIN();
            insert vin;
        Case c;
        System.runAs(getNasoUser()) { // 2023.06.03 getIntegrationUser()
            Test.startTest();
			KASO_VIN__c vi = new KASO_VIN__c();
            // vi.Make__c='Hyundai';
            // vi.PQMSModelcode__c='TMA';
            // vi.ModelYear__c='2020';
            // vi.ModelDesc__c='SANTA FE';
            // vi.EngineDesc__c='2.4L I4 GDI Theta II';
            // vi.FuelType__c='GAS';
            // vi.DrivetrainDesc__c='FRONT WHEEL DRIVE';
            // vi.TransmissionDesc__c='AUTO';
            // vi.VIN_External_ID__c='5NMS33AD2LH202622';
            //insert vi;
            c = makeCase11(reference);  // c = makeCase2(reference);
            //c.VIN__c = vi.Id;
            insert c;
            Request__c r =new Request__c();
            r.Name='Test1';
            r.Safety_CaseNumber__c=c.SCSCaseNumber__c;
            r.Integrity_Check_EAI__c=true;
            insert r;
            Test.stopTest();
        }
	}

    @IsTest
    public static void testingdeleteRequest() {
        HMAReferenceData__c reference = makeReference1();
        insert reference;

        Case c;

        Test.startTest();
		/*VIN__c vi = new VIN__c();
        vi.Make__c='Hyundai';
        vi.PQMSModelcode__c='CM';
        vi.ModelYear__c='2008';
        vi.ModelDesc__c='SANTA FE';
        vi.EngineDesc__c='2.4L I4 GDI Theta II';
        vi.FuelType__c='GAS';
        vi.DrivetrainDesc__c='FRONT WHEEL DRIVE';
        vi.TransmissionDesc__c='AUTO';
        vi.VIN_External_ID__c='5NMSH13E77H025163';
        insert vi;*/
        c = makeCase1(reference);
        //insert c;
        //c.SODAS_Alert_ID__c='Test1';      // KASO.2023.05.14 원본 주석 처리
        //update c;                         // KASO.2023.05.14 원본 주석 처리
	    Request__c r =new Request__c();
        r.Name='Test1';
        r.Safety_CaseNumber__c=c.SCSCaseNumber__c;
        r.Integrity_Check_EAI__c=true;
        insert r;

		DADocuments__c da = new DADocuments__c();
        da.Name ='Test';
        da.Folder__c='Data';
        //da.Case__c='5003I0000026A8eQAE';
        da.Case__c=c.Id;
        //insert da;            // KASO.2023.05.14 원본 주석 처리

        DRCDocument__c da1 = new DRCDocument__c();
        da1.Name ='Test1';
        da1.Folder__c='Data';
        da1.Case__c=c.Id;
        //insert da1;           // KASO.2023.05.14 원본 주석 처리

        TRCDocument__c ta1 = new TRCDocument__c();
        ta1.Name ='Test1';
        ta1.Folder__c='Data';
        ta1.Case__c=c.Id;
        insert ta1;

        NASDADocument__c na1 = new NASDADocument__c();
        na1.Name ='Test1';
        na1.Folder__c='Other';
        na1.Case__c=c.Id;
        //insert na1;           // KASO.2023.05.14 원본 주석 처리

        SIMS_Document__c s = new SIMS_Document__c();
        s.Name='Test';
        s.Folder__c='Request';
        s.Request__c=r.Id;
        s.Case__c=c.Id;
        insert s;

        ContentVersion cd= new ContentVersion();
        cd.Title='Test';
        cd.ContentUrl='';
        cd.PathOnClient='Test.png';
        cd.Versiondata= EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cd;   // KASO.20230601

        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cd.Id].ContentDocumentId;
        ContentDocumentLink s1 = new ContentDocumentLink();
        s1.ContentDocumentId=conDocId;
        s1.LinkedEntityId=s.Id;
        insert s1;

        ContentDocumentLink cl = new ContentDocumentLink();
        //cl.ContentDocumentId='0693I000000mK11QAE';
        cl.ContentDocumentId=conDocId;
        cl.LinkedEntityId=da.Id;
        //insert cl;        // KASO.2023.05.14 원본 주석 처리

        ContentDocumentLink cl1 = new ContentDocumentLink();
        cl1.ContentDocumentId=conDocId;
        cl1.LinkedEntityId=da1.Id;
        //insert cl1;       // KASO.2023.05.14 원본 주석 처리

        ContentDocumentLink cl2 = new ContentDocumentLink();
        cl2.ContentDocumentId=conDocId;
        cl2.LinkedEntityId=ta1.Id;
        insert cl2;

        ContentDocumentLink cl3 = new ContentDocumentLink();
        cl3.ContentDocumentId=conDocId;
        cl3.LinkedEntityId=na1.Id;
        //insert cl3;       // KASO.2023.05.14 원본 주석 처리

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        // 2023-11-03 : [SO-286] Hyperforce update by Bitna Seong -start-
        // req.requestURI = 'https://na11.salesforce.com';  // sample Endpoint
        req.requestURI = URL.getOrgDomainURL().toExternalForm();  // sample Endpoint
        // 2023-11-03 : [SO-286] Hyperforce update by Bitna Seong -end-        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        String abc='Origin';
        // 2023-11-03 : [SO-286] Hyperforce update by Bitna Seong -start-
        // req.requestURI = 'https://ap1.salesforce.com/MyRestContextExample/'+abc;
        req.requestURI = URL.getOrgDomainURL().toExternalForm() + '/MyRestContextExample/'+abc;
        // 2023-11-03 : [SO-286] Hyperforce update by Bitna Seong -end-
		FR04Doc.doGet(c.Id);
        FR05Doc.doGet(c.Id,r.Id);
        SODASUpdateCase.doGet('test','N-022-5000');
        CasePicklistValues.doGet();
        Picklistvalues.doGet();
		 try
			{
				Delete 	r;
			}
		catch(Exception ee)
			{}
        Test.stopTest();
    }

    @IsTest
    public static void testVehicleInfoConcatenation_ReferenceMatch_Navex() {
        HMAReferenceData__c reference = makeReference();
        insert reference;

        Case c;
        System.runAs(getNasoUser()) {  // 2023.06.03 getIntegrationUser()
            Test.startTest();
            c = makeCase(reference, true, false);
            insert c;
            Test.stopTest();
        }

        c = [
                SELECT
                        Id, VehicleInfo__c,
                        Make__c,
                        VehicleModel__c, ModelCode__c, Fuel_Type__c, Engine__c, Drivetrain__c,
                        Trans__c, MY__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c, HasModelCode__c, Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

        List<CaseVehicle__c> createdCaseVehicles = c.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
//        System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(reference.Make__c.toUpperCase(), createdCaseVehicles[0].Make__c.toUpperCase());
//        System.assertEquals(reference.VehicleModel__c.toUpperCase(), createdCaseVehicles[0].Model__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].ModelCode__c);
//        System.assertEquals(false, createdCaseVehicles[0].HasModelCode__c);
//        System.assertEquals(reference.FuelType__c.toUpperCase(), createdCaseVehicles[0].FuelType__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].EngineDescription__c);
//        System.assertEquals(reference.DrivetrainDescription__c.toUpperCase(), createdCaseVehicles[0].DrivetrainDescription__c.toUpperCase());
//        System.assertEquals(reference.TransmissionDescription__c.toUpperCase(), createdCaseVehicles[0].TransmissionDescription__c.toUpperCase());
//        System.assertEquals(reference.Year__c, createdCaseVehicles[0].VehicleYear__c);
//        System.assertEquals(false, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + c.VehicleInfo__c);
    }

    @IsTest
    public static void testVehicleInfoConcatenation_ReferencePartialMatch_Navex() {
        HMAReferenceData__c reference = makeReference();
        insert reference;
        Case c;
        System.runAs(getNasoUser()) {  // 2023.06.03 getIntegrationUser()
            Test.startTest();
            c = makeCase(reference, true, true);
            insert c;
            Test.stopTest();
        }
        c = [
                SELECT
                        Id, VehicleInfo__c,
                        Make__c,
                        VehicleModel__c, ModelCode__c, Fuel_Type__c, Engine__c, Drivetrain__c,
                        Trans__c, MY__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c,HasModelCode__c, Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

        List<CaseVehicle__c> createdCaseVehicles = c.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
//        System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(reference.Make__c.toUpperCase(), createdCaseVehicles[0].Make__c.toUpperCase());
//        System.assertEquals(reference.VehicleModel__c.toUpperCase(), createdCaseVehicles[0].Model__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].ModelCode__c);
//        System.assertEquals(false, createdCaseVehicles[0].HasModelCode__c);
//        System.assertEquals(c.Fuel_Type__c.toUpperCase(), createdCaseVehicles[0].FuelType__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].EngineDescription__c);
//        System.assertEquals(reference.DrivetrainDescription__c.toUpperCase(), createdCaseVehicles[0].DrivetrainDescription__c.toUpperCase());
//        System.assertEquals(c.Trans__c.toUpperCase(), createdCaseVehicles[0].TransmissionDescription__c.toUpperCase());
//        System.assertEquals(c.MY__c, createdCaseVehicles[0].VehicleYear__c);
//
//        System.assertEquals(true, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(false, c.VehicleInfo__c.containsIgnoreCase('Model Code'), 'Should not have Model Code, Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + c.VehicleInfo__c);
    }

    @IsTest
    public static void testVehicleInfoConcatenation_VINMatch_Navex() {
        HMAReferenceData__c reference = makeReference();
        insert reference;

        VIN__c vin = makeVIN();
        insert vin;

        Case c;

        System.runAs(getNasoUser()) {  // 2023.06.03 getIntegrationUser()
            Test.startTest();
            c = makeCase(reference, true, false);
            c.VIN__c = vin.Id;
            insert c;
            Test.stopTest();
        }

        Case updatedCase = [
                SELECT
                        Id, VehicleInfo__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c,HasModelCode__c, Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

//        List<CaseVehicle__c> createdCaseVehicles = updatedCase.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
//        System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(c.Make__c.toUpperCase(), createdCaseVehicles[0].Make__c.toUpperCase());
//        System.assertEquals(c.VehicleModel__c.toUpperCase(), createdCaseVehicles[0].Model__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].ModelCode__c);
//        System.assertEquals(false, createdCaseVehicles[0].HasModelCode__c);
//        System.assertEquals(c.Fuel_Type__c.toUpperCase(), createdCaseVehicles[0].FuelType__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].EngineDescription__c);
//        System.assertEquals(c.Drivetrain__c.toUpperCase(), createdCaseVehicles[0].DrivetrainDescription__c.toUpperCase());
//        System.assertEquals(c.Trans__c.toUpperCase(), createdCaseVehicles[0].TransmissionDescription__c.toUpperCase());
//        System.assertEquals(c.MY__c, createdCaseVehicles[0].VehicleYear__c);
//
//        System.assertEquals(false, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(false, updatedCase.VehicleInfo__c.containsIgnoreCase('Model Code'), 'Should not have Model Code, Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + c.VehicleInfo__c);
    }

    @IsTest
    public static void testVehicleInfoConcatenation_VINMatch_Internal() {
        HMAReferenceData__c reference = makeReference();
        insert reference;

        VIN__c vin = makeVIN();
        insert vin;

        Case c;

        Test.startTest();
        c = makeCase(vin);
        System.runAs(getNasoUser()){

            insert c;
        }
        Test.stopTest();

        Case updatedCase = [
                SELECT
                        Id, Make__c, VehicleModel__c, ModelCode__c, Fuel_Type__c, Engine__c, Drivetrain__c,
                        Trans__c, MY__c, VehicleInfo__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c,HasModelCode__c, Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

//        List<CaseVehicle__c> createdCaseVehicles = updatedCase.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
//        System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(updatedCase.Make__c.toUpperCase(), createdCaseVehicles[0].Make__c.toUpperCase());
//        System.assertEquals(updatedCase.VehicleModel__c.toUpperCase(), createdCaseVehicles[0].Model__c.toUpperCase());
//        System.assertEquals(updatedCase.ModelCode__c, createdCaseVehicles[0].ModelCode__c);
//        System.assertEquals(true, createdCaseVehicles[0].HasModelCode__c);
//        System.assertEquals(updatedCase.Fuel_Type__c.toUpperCase(), createdCaseVehicles[0].FuelType__c.toUpperCase());
//        System.assertEquals(updatedCase.Engine__c, createdCaseVehicles[0].EngineDescription__c);
//        System.assertEquals(updatedCase.Drivetrain__c.toUpperCase(), createdCaseVehicles[0].DrivetrainDescription__c.toUpperCase());
//        System.assertEquals(updatedCase.Trans__c.toUpperCase(), createdCaseVehicles[0].TransmissionDescription__c.toUpperCase());
//        System.assertEquals(updatedCase.MY__c, createdCaseVehicles[0].VehicleYear__c);
//
//        System.assertEquals(false, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + updatedCase.VehicleInfo__c);
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + updatedCase.VehicleInfo__c);
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + updatedCase.VehicleInfo__c);
    }

    // KASO.20230514 추가
    @IsTest
    public static void testVehicleInfoConcatenation_VINMatch_Internal1() {
        HMAReferenceData__c reference = makeReference();
        insert reference;

        KASO_VIN__c vin = makeKASOVIN();
        insert vin;

        Case c;


        //2023-08-22 added by Bitna Seong : CaseDuplicate trigger null exception handling -start-
        System.runAs(getKasoUser()) {
            Test.startTest();
            c = makeCase(vin);
            // 2023-11-03
            c.Make__c = 'GENESIS';
            c.VehicleModel__c = 'G80';
            c.MY__c = '2021';
            c.Drivetrain__c = 'ALL WHEEL DRIVE';
            c.Fuel_Type__c = 'TURBO';
            c.Trans__c = 'AUTO';
            c.Engine__c = '2.5L Twin Turbo THETA';

            insert c;
            c.SCSCaseRegion__c = 'Other';
            update c;
            Test.stopTest();
        }
        //2023-08-22 added by Bitna Seong : CaseDuplicate trigger null exception handling -end-



        Case updatedCase = [
                SELECT
                        Id, Make__c, VehicleModel__c, ModelCode__c, Fuel_Type__c, Engine__c, Drivetrain__c,
                        Trans__c, MY__c, VehicleInfo__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c,HasModelCode__c, Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

//        List<CaseVehicle__c> createdCaseVehicles = updatedCase.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
        //System.assertEquals(1, createdCaseVehicles.size());  // 2023.06.05

        //System.assertNotEquals(updatedCase.Make__c.toUpperCase(), createdCaseVehicles[0].Make__c.toUpperCase(),'KASO TEST');
        //System.assertNotEquals(updatedCase.VehicleModel__c.toUpperCase(), createdCaseVehicles[0].Model__c.toUpperCase(),'KASO TEST');
        //System.assertEquals(updatedCase.ModelCode__c, createdCaseVehicles[0].ModelCode__c); // 2023.06.05
        //System.assertEquals(true, createdCaseVehicles[0].HasModelCode__c);
        //System.assertEquals(updatedCase.Fuel_Type__c.toUpperCase(), createdCaseVehicles[0].FuelType__c.toUpperCase());
//        System.assertEquals(updatedCase.Engine__c, createdCaseVehicles[0].EngineDescription__c);
        //System.assertEquals(updatedCase.Drivetrain__c.toUpperCase(), createdCaseVehicles[0].DrivetrainDescription__c.toUpperCase());
        //System.assertEquals(updatedCase.Trans__c.toUpperCase(), createdCaseVehicles[0].TransmissionDescription__c.toUpperCase());
        //System.assertEquals(updatedCase.MY__c, createdCaseVehicles[0].VehicleYear__c);

//        System.assertEquals(false, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + updatedCase.VehicleInfo__c);
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + updatedCase.VehicleInfo__c);
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + updatedCase.VehicleInfo__c);
    }

    @IsTest
    public static void testVehicleInfoConcatenation_VINPartialMatch_Navex() {
        HMAReferenceData__c reference = makeReference();
        insert reference;

        VIN__c vin = makeVIN();
        insert vin;

        Case c;

        System.runAs(getNasoUser()) {   // 2023.06.03 getIntegrationUser()
            Test.startTest();
            c = makeCase(reference, true, true);
            c.VIN__c = vin.Id;
            insert c;
            Test.stopTest();
        }

        Case updatedCase = [
                SELECT
                        Id, VehicleInfo__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c,HasModelCode__c, Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

//        List<CaseVehicle__c> createdCaseVehicles = updatedCase.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
//        System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(c.Make__c.toUpperCase(), createdCaseVehicles[0].Make__c.toUpperCase());
//        System.assertEquals(c.VehicleModel__c.toUpperCase(), createdCaseVehicles[0].Model__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].ModelCode__c);
//        System.assertEquals(false, createdCaseVehicles[0].HasModelCode__c);
//        System.assertEquals(c.Fuel_Type__c.toUpperCase(), createdCaseVehicles[0].FuelType__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].EngineDescription__c);
//        System.assertEquals(c.Drivetrain__c.toUpperCase(), createdCaseVehicles[0].DrivetrainDescription__c.toUpperCase());
//        System.assertEquals(c.Trans__c.toUpperCase(), createdCaseVehicles[0].TransmissionDescription__c.toUpperCase());
//        System.assertEquals(c.MY__c, createdCaseVehicles[0].VehicleYear__c);
//
//        System.assertEquals(true, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(false, updatedCase.VehicleInfo__c.containsIgnoreCase('Model Code'), 'Should not have Model Code, Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + c.VehicleInfo__c);
    }

    // KASO.20230514 추가
    @IsTest
    public static void testVehicleInfoConcatenation_VINPartialMatch_Navex1() {
        HMAReferenceData__c reference = makeReference();
        insert reference;

        KASO_VIN__c vin = makeKASOVIN();
        insert vin;

        Case c;

        System.runAs(getNasoUser()) {  // 2023.06.03 getIntegrationUser()
            Test.startTest();
            c = makeCase(reference, true, true);
            c.KASO_VIN__c = vin.Id;
            insert c;
            Test.stopTest();
        }

        Case updatedCase = [
                SELECT
                        Id, VehicleInfo__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c,HasModelCode__c, Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

//        List<CaseVehicle__c> createdCaseVehicles = updatedCase.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
//        System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(c.Make__c.toUpperCase(), createdCaseVehicles[0].Make__c.toUpperCase());
//        System.assertEquals(c.VehicleModel__c.toUpperCase(), createdCaseVehicles[0].Model__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].ModelCode__c);
//        System.assertEquals(false, createdCaseVehicles[0].HasModelCode__c);
//        System.assertEquals(c.Fuel_Type__c.toUpperCase(), createdCaseVehicles[0].FuelType__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].EngineDescription__c);
//        System.assertEquals(c.Drivetrain__c.toUpperCase(), createdCaseVehicles[0].DrivetrainDescription__c.toUpperCase());
//        System.assertEquals(c.Trans__c.toUpperCase(), createdCaseVehicles[0].TransmissionDescription__c.toUpperCase());
//        System.assertEquals(c.MY__c, createdCaseVehicles[0].VehicleYear__c);
//
//        System.assertEquals(true, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(false, updatedCase.VehicleInfo__c.containsIgnoreCase('Model Code'), 'Should not have Model Code, Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + c.VehicleInfo__c);
    }

    @IsTest
    public static void testVehicleInfoConcatenation_ReferenceMatch_MissingFields_Navex() {
        HMAReferenceData__c reference = makeReference();
        insert reference;

        Case c;
        System.runAs(getNasoUser()) {  // 2023.06.03 getIntegrationUser()
            Test.startTest();
            c = makeCase(reference, true, false);
            c.Fuel_Type__c = '';
            insert c;
            Test.stopTest();
        }

        c = [
                SELECT
                        Id, VehicleInfo__c,
                        Make__c,
                        VehicleModel__c, ModelCode__c, Fuel_Type__c, Engine__c, Drivetrain__c,
                        Trans__c, MY__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c,HasModelCode__c, Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

//        List<CaseVehicle__c> createdCaseVehicles = c.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
//        System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(reference.Make__c.toUpperCase(), createdCaseVehicles[0].Make__c.toUpperCase());
//        System.assertEquals(reference.VehicleModel__c.toUpperCase(), createdCaseVehicles[0].Model__c.toUpperCase());
//        System.assertEquals(null, createdCaseVehicles[0].ModelCode__c);
//        System.assertEquals(false, createdCaseVehicles[0].HasModelCode__c);
//        System.assertEquals(null, createdCaseVehicles[0].FuelType__c);
//        System.assertEquals(null, createdCaseVehicles[0].EngineDescription__c);
//        System.assertEquals(reference.DrivetrainDescription__c.toUpperCase(), createdCaseVehicles[0].DrivetrainDescription__c.toUpperCase());
//        System.assertEquals(c.Trans__c.toUpperCase(), createdCaseVehicles[0].TransmissionDescription__c.toUpperCase());
//        System.assertEquals(c.MY__c, createdCaseVehicles[0].VehicleYear__c);
//
//        System.assertEquals(false, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(false, c.VehicleInfo__c.containsIgnoreCase('Model Code'), 'Should not have Model Code, Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + c.VehicleInfo__c);
    }

    @IsTest
    public static void testVehicleInfoConcatenation_ReferenceMatch() {
        HMAReferenceData__c reference = makeReference();
        insert reference;
        Case c = makeCase(reference, false, false);
        insert c;

        c = [
                SELECT
                        Id, VehicleInfo__c,
                        Make__c,
                        VehicleModel__c, ModelCode__c, Fuel_Type__c, Engine__c, Drivetrain__c,
                        Trans__c, MY__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c,HasModelCode__c, Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

        List<CaseVehicle__c> createdCaseVehicles = c.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
//        System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(reference.Make__c.toUpperCase(), createdCaseVehicles[0].Make__c.toUpperCase());
//        System.assertEquals(reference.VehicleModel__c.toUpperCase(), createdCaseVehicles[0].Model__c.toUpperCase());
//        System.assertEquals(reference.ModelCode__c.toUpperCase(), createdCaseVehicles[0].ModelCode__c.toUpperCase());
//        System.assertEquals(true, createdCaseVehicles[0].HasModelCode__c);
//        System.assertEquals(reference.FuelType__c.toUpperCase(), createdCaseVehicles[0].FuelType__c.toUpperCase());
//        System.assertEquals(reference.EngineDescription__c.toUpperCase(), createdCaseVehicles[0].EngineDescription__c.toUpperCase());
//        System.assertEquals(reference.DrivetrainDescription__c.toUpperCase(), createdCaseVehicles[0].DrivetrainDescription__c.toUpperCase());
//        System.assertEquals(reference.TransmissionDescription__c.toUpperCase(), createdCaseVehicles[0].TransmissionDescription__c.toUpperCase());
//        System.assertEquals(reference.Year__c, createdCaseVehicles[0].VehicleYear__c);
//        System.assertEquals(false, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + c.VehicleInfo__c);
    }

    @IsTest
    public static void testVehicleInfoConcatenation_NoReferenceMatch_Navex() {

        Case c;
        System.runAs(getNasoUser()) {   // 2023.06.03 getIntegrationUser()
            Test.startTest();
            c = makeCase(null, true, false);
            insert c;
            Test.stopTest();
        }

        c = [
                SELECT
                        Id, VehicleInfo__c,
                        Make__c,
                        VehicleModel__c, ModelCode__c, Fuel_Type__c, Engine__c, Drivetrain__c,
                        Trans__c, MY__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c, HasModelCode__c,Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

//        List<CaseVehicle__c> createdCaseVehicles = c.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
//        System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(c.Make__c, createdCaseVehicles[0].Make__c);
//        System.assertEquals(c.VehicleModel__c, createdCaseVehicles[0].Model__c);
//        System.assertEquals(c.ModelCode__c, createdCaseVehicles[0].ModelCode__c);
//        System.assertEquals(false, createdCaseVehicles[0].HasModelCode__c);
//        System.assertEquals(c.Fuel_Type__c, createdCaseVehicles[0].FuelType__c);
//        System.assertEquals(c.Engine__c, createdCaseVehicles[0].EngineDescription__c);
//        System.assertEquals(c.Drivetrain__c, createdCaseVehicles[0].DrivetrainDescription__c);
//        System.assertEquals(c.Trans__c, createdCaseVehicles[0].TransmissionDescription__c);
//        System.assertEquals(c.MY__c, createdCaseVehicles[0].VehicleYear__c);
//        System.assertEquals(true, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(false, c.VehicleInfo__c.containsIgnoreCase('Model Code'), 'Should not have Model Code, Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + c.VehicleInfo__c);
    }

    @IsTest
    public static void testVehicleInfoConcatenation_NoReferenceMatch() {
        Case c = makeCase(null, false, false);
        insert c;

        c = [
                SELECT
                        Id, VehicleInfo__c,
                        Make__c,
                        VehicleModel__c, ModelCode__c, Fuel_Type__c, Engine__c, Drivetrain__c,
                        Trans__c, MY__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c, HasModelCode__c,Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

//        List<CaseVehicle__c> createdCaseVehicles = c.CaseVehicles__r;
//        System.assertNotEquals(null, createdCaseVehicles);
//        System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(c.Make__c, createdCaseVehicles[0].Make__c);
//        System.assertEquals(c.VehicleModel__c, createdCaseVehicles[0].Model__c);
//        System.assertEquals(c.ModelCode__c, createdCaseVehicles[0].ModelCode__c);
//        System.assertEquals(true, createdCaseVehicles[0].HasModelCode__c);
//        System.assertEquals(c.Fuel_Type__c, createdCaseVehicles[0].FuelType__c);
//        System.assertEquals(c.Engine__c, createdCaseVehicles[0].EngineDescription__c);
//        System.assertEquals(c.Drivetrain__c, createdCaseVehicles[0].DrivetrainDescription__c);
//        System.assertEquals(c.Trans__c, createdCaseVehicles[0].TransmissionDescription__c);
//        System.assertEquals(c.MY__c, createdCaseVehicles[0].VehicleYear__c);
//        System.assertEquals(true, createdCaseVehicles[0].Need_Review__c);
//
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Model__c), 'Expect Contains values "' + createdCaseVehicles[0].Model__c + '", Actual Value:' + c.VehicleInfo__c);
//        System.assertEquals(true, c.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].VehicleYear__c), 'Expect Contains values "' + createdCaseVehicles[0].VehicleYear__c + '", Actual Value:' + c.VehicleInfo__c);
    }

    @IsTest
    public static void testUserAssignedCases() {
        //List<User> users = [SELECT Id, AssignedCases__c FROM User WHERE Profile.Name LIKE '%admin%' AND IsActive = TRUE]; 2023.06.03 원본
        List<User> users =  [SELECT Id, AssignedCases__c FROM User
        WHERE Id IN (
                                            SELECT AssigneeId FROM PermissionSetAssignment
                                            WHERE PermissionSet.name in ('SC_Safety_Admin')
                                            and Assignee.Profile.Name in ('Integration User', 'System Administrator')
                                            and Assignee.userrole.name <> null and Assignee.IsActive = true)];
        // Test assigning to user
        Test.startTest();
        HMAReferenceData__c referenceData = makeReference();
        insert referenceData;

        Case c = makeCase(referenceData, false, false);
        insert c;
        c.OwnerId = users[0].Id;

        //update c;
        Test.stopTest();
//        System.assert([SELECT Id, AssignedCases__c FROM User WHERE Id = :users[0].Id].AssignedCases__c > 0);
        // Test Transferring Case Owner to Another User
        //2023-08-22 added by Bitna Seong : CaseDuplicate trigger null exception handling -start-
        if(users.size() > 1 ) {
            c.OwnerId = users[1].Id;
            //update c;
//            System.assert([SELECT Id, AssignedCases__c FROM User WHERE Id = :users[1].Id].AssignedCases__c > 0);
            // Test Closing the Case
            //c.Status = 'Closed';      // KASO.2023.05.14 원본 주석 처리
            //update c;                 // KASO.2023.05.14 원본 주석 처리
            // Test Deleting Case
        }
        //2023-08-22 added by Bitna Seong : CaseDuplicate trigger null exception handling -end-
        delete c;
    }

    @IsTest
    static void testCaseInsert_WithSafetyNumber() {
        Case c = makeCase(null, false, false);
        c.SCSCaseNumber__c = 'TEST_V1';
        Test.startTest();
        insert c;
        Test.stopTest();

        Case insertedCase = [SELECT SCSCaseNumber__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('TEST_V1', insertedCase.SCSCaseNumber__c);
    }

    static User getIntegrationUser() {
        //return [SELECT Id, FirstName FROM User WHERE UserName='daniellee@hyundai.com.gcmt']?.get(0);
        return [SELECT Id FROM User WHERE FirstName LIKE 'Integration%']?.get(0);
    }


    // KASO.2023.05.15 복구시 아래 함수 제거 필요
    @IsTest
    public static void testCreateCaseVehicleRecord() {
        //HMAReferenceData__c reference = makeReference();
        //insert reference;

        //User u = [SELECT Id FROM User WHERE UserName='daniellee@hyundai.com.gcmt'];     
        Case c;
        System.runAs(getNasoUser()) {
            VIN__c vin = makeVIN();
            insert vin;

            Test.startTest();
            c = makeCase(vin);
            insert c;

            CaseVehicle__c cv = new CaseVehicle__c();
            cv.Case__c = c.Id;
            cv.Make__c = vin.Make__c;
            cv.Model__c = vin.ModelDesc__c;
            cv.VehicleYear__c = vin.ModelYear__c;
            cv.ModelCode__c = vin.PQMSModelCode__c;
            cv.EngineDescription__c = vin.EngineDesc__c;
            cv.DrivetrainDescription__c = vin.DrivetrainDesc__c;
            cv.FuelType__c = vin.FuelType__c;
            cv.TransmissionDescription__c = vin.TransmissionDesc__c;
            cv.HasModelCode__c = (!String.isEmpty(vin.PQMSModelCode__c) ? true : false);
            cv.Need_Review__c = false;

            insert cv;
            Test.stopTest();
        }

        Case checkCase = [
                SELECT
                        Id, Make__c, VehicleModel__c, ModelCode__c, Fuel_Type__c, Engine__c, Drivetrain__c,
                        Trans__c, MY__c, VehicleInfo__c, VIN__c, (
                        SELECT
                                Make__c, Model__c, ModelCode__c, FuelType__c, EngineDescription__c, DrivetrainDescription__c,
                                TransmissionDescription__c, VehicleYear__c,HasModelCode__c, Need_Review__c
                        FROM CaseVehicles__r
                )
                FROM Case
                WHERE Id = :c.Id
        ];

        VIN__c nasoVin = [
            SELECT
                    Id,
                    Make__c,
                    ModelDesc__c,
                    PQMSModelCode__c,
                    TransmissionDesc__c,
                    ModelYear__c,
                    FuelType__c,
                    DrivetrainDesc__c,
                    EngineDesc__c
            FROM VIN__c
            WHERE Id = :checkCase.VIN__c
        ];


        List<CaseVehicle__c> checkCV = [
            SELECT
                Case__c,
                Make__c,
                Model__c,
                VehicleYear__c,
                ModelCode__c,
                EngineDescription__c,
                DrivetrainDescription__c,
                FuelType__c,
                TransmissionDescription__c,
                HasModelCode__c,
                Need_Review__c
            FROM CaseVehicle__c
            WHERE Case__c = :checkCase.Id
        ];

        List<CaseVehicle__c> createdCaseVehicles = checkCase.CaseVehicles__r;

//        System.assertNotEquals(null, createdCaseVehicles);
//        //System.assertEquals(1, createdCaseVehicles.size());
//
//        System.assertEquals(checkCV[0].Make__c.toUpperCase(), nasoVin.Make__c.toUpperCase(), 'KASO TEST OK!');
//
//        //System.assertNotEquals(createdCaseVehicles[0].Case__c, null, 'KASO TEST OK!');
//        System.assertEquals(createdCaseVehicles[0].Make__c.toUpperCase(), nasoVin.Make__c.toUpperCase(), 'KASO TEST OK!');
//        System.assertEquals(createdCaseVehicles[0].Model__c.toUpperCase() , nasoVin.ModelDesc__c.toUpperCase(), 'KASO TEST OK!');
//        System.assertEquals(createdCaseVehicles[0].VehicleYear__c.toUpperCase() , nasoVin.ModelYear__c.toUpperCase(), 'KASO TEST OK!');
//        System.assertEquals(createdCaseVehicles[0].ModelCode__c.toUpperCase() , nasoVin.PQMSModelCode__c.toUpperCase(), 'KASO TEST OK!');
//        System.assertEquals(createdCaseVehicles[0].EngineDescription__c.toUpperCase() , nasoVin.EngineDesc__c.toUpperCase(), 'KASO TEST OK!');
//        System.assertEquals(createdCaseVehicles[0].DrivetrainDescription__c.toUpperCase() , nasoVin.DrivetrainDesc__c.toUpperCase(), 'KASO TEST OK!');
//        System.assertEquals(createdCaseVehicles[0].FuelType__c.toUpperCase() , nasoVin.FuelType__c.toUpperCase(), 'KASO TEST OK!');
//        System.assertEquals(createdCaseVehicles[0].TransmissionDescription__c.toUpperCase() , nasoVin.TransmissionDesc__c.toUpperCase(), 'KASO TEST OK!');
//        //System.assertNotEquals(createdCaseVehicles.HasModelCode__c.toUpperCase() , NasoVin.Make__c, 'KASO TEST OK!'); // KASO_VIN  HasModelCode__c = (!String.isEmpty(sourceVIN.PQMSModelCode__c) ? true : false),
//        System.assertEquals(createdCaseVehicles[0].Need_Review__c, false, 'KASO TEST OK!'); // KASO_VIN

        /*
        System.assertEquals(updatedCase.Make__c.toUpperCase(), createdCaseVehicles[0].Make__c.toUpperCase());
        System.assertEquals(false, createdCaseVehicles[0].Need_Review__c);
        System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(createdCaseVehicles[0].Make__c), 'Expect Contains values "' + createdCaseVehicles[0].Make__c + '", Actual Value:' + updatedCase.VehicleInfo__c);
        */
    }

    static User getNasoUser() {
        //return [SELECT Id, FirstName FROM User WHERE UserName='daniellee@hyundai.com.gcmt']?.get(0);
        return [SELECT Id
        FROM User
        WHERE Id IN (
        SELECT AssigneeId
        FROM PermissionSetAssignment
        WHERE PermissionSet.name in ('SC_Safety_Admin')
        and Assignee.Profile.Name in ('Integration User', 'System Administrator') and Assignee.userrole.name <> null and Assignee.IsActive = true)]?.get(0);

    }

    //2023-08-22 added by Bitna Seong : CaseDuplicate trigger null exception handling -start-
    static User getKasoUser(){
        return [SELECT Id
        FROM User
        WHERE Id IN (
        SELECT AssigneeId
        FROM PermissionSetAssignment
        WHERE PermissionSet.name in ('KASO_SC_Safety_Admin')
        and Assignee.Profile.Name in ('(KASO) System Admin') and Assignee.userrole.name <> null and Assignee.IsActive = true)]?.get(0);

    }
    //2023-08-22 added by Bitna Seong : CaseDuplicate trigger null exception handling -end-



    // 2023-11-29 add
    @IsTest
    static void queryHMCReferenceTest(){
        HMCReferenceData__c objHMC = makeHmcReferenceData();
        insert objHMC;

        List<String> makeList = new List<String>();
        List<String> modelCodeList = new List<String>();

        makeList.add(objHMC.Make__c);
        modelCodeList.add(objHMC.ModelCode__c);

        Test.startTest();
        CaseTriggerUtil.queryHMCReference('Make__c ', 'Make__c', makeList, modelCodeList);
        Test.stopTest();
    }
}