@IsTest
public class CaseVinMismatchCtTest {
    @IsTest
    static void testRejectBtnClicked() {

        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('KASDA').getRecordTypeId(); // KASO.2023.05.10 복구시 주석 처리 필요
        Id recordTypeId1 = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();   // KASO.2023.05.10 복구시 주석 제거 필요
//        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Temp').getRecordTypeId(); // KASO.2023.05.10 복구시 주석 처리 필요

        KASO_VIN__c vin = new KASO_VIN__c(); // KASO.2023.05.10 복구시 주석 처리 필요
        vin.Make__c = 'Hyundai';
        vin.ModelDesc__c = 'G80';
        vin.PQMSModelCode__c = 'IK';
        vin.TransmissionDesc__c = 'AUTO';
        vin.ModelYear__c = '2021';
        vin.FuelType__c = 'GAS';
        vin.DrivetrainDesc__c = 'ALL WHEEL DRIVE';
        vin.EngineDesc__c = '3.8L V6 DOHC GDI Lambda II';

        Case c = new Case();
        c.Subject = 'Test Hyundai G80 Car';
        c.Description = 'Hyundai G80';
        c.MY__c = '2021';
        c.KASO_VIN__c = vin.Id;         // KASO.2023.05.10 복구시 주석 처리 필요
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMC';
        c.CountrySubmitterWorks__c = 'Korea';            // KASO.2023.05.10 복구시 주석 처리 필요
        c.SCSCaseRegion__c = 'Korea';                   // KASO.2023.05.10 복구시 주석 처리 필요
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';
        c.MethodofRepair__c = 'Changed Hyundai G80 Engine';
        c.IncidentswithFires__c = '10';
        c.Make__c = 'Hyundai';
        c.VehicleModel__c = 'G80';
        c.Trans__c = 'AUTO';
        c.Fuel_Type__c = 'GAS';
        c.Drivetrain__c = 'ALL WHEEL DRIVE';
        c.FirstReportSource__c = 'Speak Up For Safety';
        c.NAVEXValidatorStatus__c = 'Not Required';


        VIN__c vin1 = new VIN__c();
        vin1.Make__c = 'Hyundai';
        vin1.ModelDesc__c = 'G80';
        vin1.PQMSModelCode__c = 'IK';
        vin1.TransmissionDesc__c = 'AUTO';
        vin1.ModelYear__c = '2021';
        vin1.FuelType__c = 'GAS';
        vin1.DrivetrainDesc__c = 'ALL WHEEL DRIVE';
        vin1.EngineDesc__c = '3.8L V6 DOHC GDI Lambda II';

        Case c1 = new Case();
        c1.Subject = 'Test Hyundai G80 Car';
        c1.Description = 'Hyundai G80';
        c1.MY__c = '2021';
        c1.VIN__c = vin1.Id;
        c1.SafetyType__c = 'Vehicle';
        c1.CompanyName__c = 'HMA';
        c1.CountrySubmitterWorks__c = 'United States';
        c1.SCSCaseRegion__c = 'North America';
        c1.Haveyoupreviouslyreportedtheissues__c = 'No';
        c1.RecordTypeId = recordTypeId1;
        c1.SCSCaseNumber__c = 'Test2';
        c1.MethodofRepair__c = 'Changed Hyundai G80 Engine';
        c1.IncidentswithFires__c = '11';
        c1.Stage__c = 'DA';
        c1.Make__c = 'Hyundai';
        c1.VehicleModel__c = 'G80';
        c1.Trans__c = 'AUTO';
        c1.Fuel_Type__c = 'GAS';
        c1.Drivetrain__c = 'ALL WHEEL DRIVE';
        c1.FirstReportSource__c = 'Speak Up For Safety';
        c1.NAVEXValidatorStatus__c = 'Not Required';


        System.runAs(getNasoUser()) {
            insert vin1;
            c1.VIN__c = vin1.Id;
            insert c1;
        }

        
        System.runAs(getKasoUser()) {
        insert vin;
        c.KASO_VIN__c = vin.Id;
        insert c;
        }

        Test.startTest();
        CaseVinMismatchController.getVehicleData(c1.Id);
        CaseVinMismatchController.getVehicleData(c.Id);
        CaseVinMismatchController.acceptBtnClicked(c1.Id);
        CaseVinMismatchController.acceptBtnClicked(c.Id);
        CaseVinMismatchController.rejectBtnClicked(c1.Id);
        CaseVinMismatchController.rejectBtnClicked(c.Id);
        CaseVinMismatchController.checkCaseOwnOrg(c1.Id);
        CaseVinMismatchController.getNHTSATREADCategory(c1.Id);
        CaseVinMismatchController.updateRejectMisMatchCase('Suspension-02','','',c1.Id);
        CaseVinMismatchController.updateAcceptMisMatchCase('Suspension-02','','',c1.Id);
        CaseVinMismatchController.getNASOData(c1.Id);

//        CaseVinMismatchController.testClass();


        Test.stopTest();

    }


    static User getNasoUser() {
        return [
                SELECT Id
                FROM User
                WHERE Id IN (
                        SELECT AssigneeId
                        FROM PermissionSetAssignment
                        WHERE PermissionSet.name in ('SC_Safety_Admin')
                        and Assignee.Profile.Name in ('Integration User', 'System Administrator') and Assignee.userrole.name <> null and Assignee.IsActive = true
                )
        ]?.get(0);
    }

    static User getKasoUser() {
        return [
                SELECT Id
                FROM User
                WHERE Id IN (
                        SELECT AssigneeId
                        FROM PermissionSetAssignment
                        WHERE PermissionSet.name in ('KASO_SC_Safety_Admin')
                        and Assignee.Profile.Name in ('(KASO) System Admin') and Assignee.userrole.name <> null and Assignee.IsActive = true
                )
        ]?.get(0);

    }
}