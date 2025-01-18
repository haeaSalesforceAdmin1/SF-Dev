/**
 * Created by baltamimi on 2022-01-28.
 */

@IsTest
private class CaseVehicleBulkCreateBatchTest {
    @TestSetup
    private static void setup() {
        // Skip firing the Case Trigger to avoid creating Case Vehicle records
        Trigger_Settings__c ts = new Trigger_Settings__c(KillList__c = 'Case', KillSwitch__c = true);
        insert ts;

        List<HMAReferenceData__c> referenceData = new List<HMAReferenceData__c>{
                new HMAReferenceData__c(Make__c = 'HYUNDAI', VehicleModel__c = 'SONATA HYBRID', Year__c = '2011', FuelType__c = 'HEV', EngineDescription__c = '2.4L I4 THETA HYBRID', DrivetrainDescription__c = 'FRONT WHEEL DRIVE', TransmissionDescription__c = 'AUTO', ModelCode__c = 'YFE'),
                new HMAReferenceData__c(Make__c = 'HYUNDAI', VehicleModel__c = 'SONATA HYBRID', Year__c = '2014', FuelType__c = 'HEV', EngineDescription__c = '2.4L I4 THETA HYBRID', DrivetrainDescription__c = 'FRONT WHEEL DRIVE', TransmissionDescription__c = 'AUTO', ModelCode__c = 'YFE'),
                new HMAReferenceData__c(Make__c = 'HYUNDAI', VehicleModel__c = 'SONATA HYBRID', Year__c = '2015', FuelType__c = 'HEV', EngineDescription__c = '3.6L I5 THETA HYBRID', DrivetrainDescription__c = 'FRONT WHEEL DRIVE', TransmissionDescription__c = 'AUTO', ModelCode__c = 'YFE'),
                new HMAReferenceData__c(Make__c = 'HYUNDAI', VehicleModel__c = 'SONATA HYBRID', Year__c = '2019', FuelType__c = 'HEV', EngineDescription__c = '4.1L K3 THETA HYBRID', DrivetrainDescription__c = 'ALL WHEEL DRIVE', TransmissionDescription__c = 'AUTO', ModelCode__c = 'YFC'),
                new HMAReferenceData__c(Make__c = 'HYUNDAI', VehicleModel__c = 'SONATA', Year__c = '2011', FuelType__c = 'TURBO', EngineDescription__c = '2.0L I4 THETA TURBO', DrivetrainDescription__c = 'FRONT WHEEL DRIVE', TransmissionDescription__c = 'AUTO', ModelCode__c = 'YF')
        };
        insert referenceData;

        List<Case> existingCases = new List<Case>{
                new Case(Subject = 'SMNM', Make__c = 'HYUNDAI', VehicleModel__c = 'SONATA HYBRID', MY__c = '2014', Fuel_Type__c = 'HEV', Engine__c = '2.4L I4 THETA HYBRID', Drivetrain__c = 'FRONT WHEEL DRIVE', Trans__c = 'AUTO', ModelCode__c = 'YFE'), // Single values, Matched, no missing
                new Case(Subject = 'SMNMM', Make__c = '', VehicleModel__c = 'SONATA HYBRID', MY__c = '2014', Fuel_Type__c = 'HEV', Engine__c = '2.4L I4 THETA HYBRID', Drivetrain__c = 'FRONT WHEEL DRIVE', Trans__c = 'AUTO', ModelCode__c = 'YFE'), // Single values, Matched, Missing Make
                new Case(Subject = 'SMM', Make__c = 'HYUNDAI', VehicleModel__c = 'SONATA HYBRID', MY__c = '2014'),// Single values, Matched, Missing
                new Case(Subject = 'MMNM', Make__c = 'HYUNDAI', VehicleModel__c = 'SONATA HYBRID', MY__c = '2014;2015', Fuel_Type__c = 'HEV', Engine__c = '2.4L I4 THETA HYBRID;3.6L I5 THETA HYBRID', Drivetrain__c = 'FRONT WHEEL DRIVE', Trans__c = 'AUTO', ModelCode__c = 'YFE'), // Multi values, Matched, No Missing
                new Case(Subject = 'MPM', Make__c = 'HYUNDAI', VehicleModel__c = 'SONATA HYBRID', MY__c = '2010;2014;2015;2019', Engine__c = '2.4L I4 THETA HYBRID;3.6L I5 THETA HYBRID', Drivetrain__c = 'FRONT WHEEL DRIVE;ALL WHEEL DRIVE', ModelCode__c = 'YFE;YFC;YFD'), // Multi values, Partially Matched, missing
                new Case(Subject = 'NM', Make__c = 'HYUNDAI', VehicleModel__c = 'ACCENT', MY__c = '2010;2014;2015;2019', Drivetrain__c = 'FRONT WHEEL DRIVE;ALL WHEEL DRIVE'), // No match
                new Case(Subject = 'EC') // Empty Case
        };
        insert existingCases;

        System.assertEquals(0, [SELECT Id FROM CaseVehicle__c].size(), 'No Case Vehicle should be created at this point');

        // Re-enable the Case trigger
        ts.KillList__c = '';
        ts.KillSwitch__c = false;
        update ts;
    }

    @IsTest
    static void testBatchJob() {
        Test.startTest();
        CaseVehicleBulkCreateBatch.runJob(false);
        Test.stopTest();

        List<Case> updatedCasesWithCVs = [
                SELECT
                        Id,Subject,Make__c,VehicleModel__c,MY__c,Fuel_Type__c,Engine__c,Drivetrain__c,Trans__c,ModelCode__c,VehicleInfo__c, (
                        SELECT
                                Id, Name, Make__c, Model__c, VehicleYear__c, FuelType__c, EngineDescription__c,DrivetrainDescription__c, TransmissionDescription__c, ModelCode__c, HasModelCode__c
                        FROM CaseVehicles__r
                )
                FROM Case
        ];

        for (Case updatedCase : updatedCasesWithCVs) {
            List<CaseVehicle__c> createdCaseVehicles = updatedCase.CaseVehicles__r;

            if (updatedCase.Subject.equalsIgnoreCase('SMNM')) {
                // Assert Case Updated Values
                System.assertEquals(true, updatedCase.Make__c.containsIgnoreCase('HYUNDAI'), generateErrorMessage('HYUNDAI', updatedCase.Make__c));
                System.assertEquals(true, updatedCase.VehicleModel__c.containsIgnoreCase('SONATA HYBRID'), generateErrorMessage('SONATA HYBRID', updatedCase.VehicleModel__c));
                System.assertEquals(true, updatedCase.MY__c.containsIgnoreCase('2014'), generateErrorMessage('2014', updatedCase.MY__c));
                System.assertEquals(true, updatedCase.Fuel_Type__c.containsIgnoreCase('HEV'), generateErrorMessage('HEV', updatedCase.Fuel_Type__c));
                System.assertEquals(true, updatedCase.Engine__c.containsIgnoreCase('2.4L I4 THETA HYBRID'), generateErrorMessage('2.4L I4 THETA HYBRID', updatedCase.Engine__c));
                System.assertEquals(true, updatedCase.Drivetrain__c.containsIgnoreCase('FRONT WHEEL DRIVE'), generateErrorMessage('FRONT WHEEL DRIVE', updatedCase.Drivetrain__c));
                System.assertEquals(true, updatedCase.Trans__c.containsIgnoreCase('AUTO'), generateErrorMessage('AUTO', updatedCase.Trans__c));
                System.assertEquals(true, updatedCase.ModelCode__c.containsIgnoreCase('YFE'), generateErrorMessage('YFE', updatedCase.ModelCode__c));

                // Assert Case Vehicle Info field value
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.Make__c), generateErrorMessage(updatedCase.Make__c, updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.VehicleModel__c), generateErrorMessage(updatedCase.VehicleModel__c, updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.MY__c), generateErrorMessage(updatedCase.MY__c, updatedCase.VehicleInfo__c));

                // Asset Created Case Vehicle values
                System.assertEquals(1, createdCaseVehicles.size(), 'Unexpected number of Case Vehicles');

                System.assertEquals(true, createdCaseVehicles[0].Make__c.containsIgnoreCase('HYUNDAI'), generateErrorMessage('HYUNDAI', createdCaseVehicles[0].Make__c));
                System.assertEquals(true, createdCaseVehicles[0].Model__c.containsIgnoreCase('SONATA HYBRID'), generateErrorMessage('SONATA HYBRID', createdCaseVehicles[0].Model__c));
                System.assertEquals(true, createdCaseVehicles[0].VehicleYear__c.containsIgnoreCase('2014'), generateErrorMessage('2014', createdCaseVehicles[0].VehicleYear__c));
                System.assertEquals(true, createdCaseVehicles[0].FuelType__c.containsIgnoreCase('HEV'), generateErrorMessage('HEV', createdCaseVehicles[0].FuelType__c));
                System.assertEquals(true, createdCaseVehicles[0].EngineDescription__c.containsIgnoreCase('2.4L I4 THETA HYBRID'), generateErrorMessage('2.4L I4 THETA HYBRID', createdCaseVehicles[0].EngineDescription__c));
                System.assertEquals(true, createdCaseVehicles[0].DrivetrainDescription__c.containsIgnoreCase('FRONT WHEEL DRIVE'), generateErrorMessage('FRONT WHEEL DRIVE', createdCaseVehicles[0].DrivetrainDescription__c));
                System.assertEquals(true, createdCaseVehicles[0].TransmissionDescription__c.containsIgnoreCase('AUTO'), generateErrorMessage('AUTO', createdCaseVehicles[0].TransmissionDescription__c));
                System.assertEquals(true, createdCaseVehicles[0].ModelCode__c.containsIgnoreCase('YFE'), generateErrorMessage('YFE', createdCaseVehicles[0].ModelCode__c));
                System.assertEquals(true, createdCaseVehicles[0].HasModelCode__c);
            } else if (updatedCase.Subject.equalsIgnoreCase('SMNMM')) {
                // Assert Case Updated Values
                System.assertEquals(true, updatedCase.Make__c.containsIgnoreCase('HYUNDAI'), generateErrorMessage('HYUNDAI', updatedCase.Make__c));
                System.assertEquals(true, updatedCase.VehicleModel__c.containsIgnoreCase('SONATA HYBRID'), generateErrorMessage('SONATA HYBRID', updatedCase.VehicleModel__c));
                System.assertEquals(true, updatedCase.MY__c.containsIgnoreCase('2014'), generateErrorMessage('2014', updatedCase.MY__c));
                System.assertEquals(true, updatedCase.Fuel_Type__c.containsIgnoreCase('HEV'), generateErrorMessage('HEV', updatedCase.Fuel_Type__c));
                System.assertEquals(true, updatedCase.Engine__c.containsIgnoreCase('2.4L I4 THETA HYBRID'), generateErrorMessage('2.4L I4 THETA HYBRID', updatedCase.Engine__c));
                System.assertEquals(true, updatedCase.Drivetrain__c.containsIgnoreCase('FRONT WHEEL DRIVE'), generateErrorMessage('FRONT WHEEL DRIVE', updatedCase.Drivetrain__c));
                System.assertEquals(true, updatedCase.Trans__c.containsIgnoreCase('AUTO'), generateErrorMessage('AUTO', updatedCase.Trans__c));
                System.assertEquals(true, updatedCase.ModelCode__c.containsIgnoreCase('YFE'), generateErrorMessage('YFE', updatedCase.ModelCode__c));

                // Assert Case Vehicle Info field value
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.Make__c), generateErrorMessage(updatedCase.Make__c, updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.VehicleModel__c), generateErrorMessage(updatedCase.VehicleModel__c, updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.MY__c), generateErrorMessage(updatedCase.MY__c, updatedCase.VehicleInfo__c));

                // Asset Created Case Vehicle values
                System.assertEquals(1, createdCaseVehicles.size(), 'Unexpected number of Case Vehicles');

                System.assertEquals(true, createdCaseVehicles[0].Make__c.containsIgnoreCase('HYUNDAI'), generateErrorMessage('HYUNDAI', createdCaseVehicles[0].Make__c));
                System.assertEquals(true, createdCaseVehicles[0].Model__c.containsIgnoreCase('SONATA HYBRID'), generateErrorMessage('SONATA HYBRID', createdCaseVehicles[0].Model__c));
                System.assertEquals(true, createdCaseVehicles[0].VehicleYear__c.containsIgnoreCase('2014'), generateErrorMessage('2014', createdCaseVehicles[0].VehicleYear__c));
                System.assertEquals(true, createdCaseVehicles[0].FuelType__c.containsIgnoreCase('HEV'), generateErrorMessage('HEV', createdCaseVehicles[0].FuelType__c));
                System.assertEquals(true, createdCaseVehicles[0].EngineDescription__c.containsIgnoreCase('2.4L I4 THETA HYBRID'), generateErrorMessage('2.4L I4 THETA HYBRID', createdCaseVehicles[0].EngineDescription__c));
                System.assertEquals(true, createdCaseVehicles[0].DrivetrainDescription__c.containsIgnoreCase('FRONT WHEEL DRIVE'), generateErrorMessage('FRONT WHEEL DRIVE', createdCaseVehicles[0].DrivetrainDescription__c));
                System.assertEquals(true, createdCaseVehicles[0].TransmissionDescription__c.containsIgnoreCase('AUTO'), generateErrorMessage('AUTO', createdCaseVehicles[0].TransmissionDescription__c));
                System.assertEquals(true, createdCaseVehicles[0].ModelCode__c.containsIgnoreCase('YFE'), generateErrorMessage('YFE', createdCaseVehicles[0].ModelCode__c));
                System.assertEquals(true, createdCaseVehicles[0].HasModelCode__c);
            } else if (updatedCase.Subject.equalsIgnoreCase('SMM')) {

                // Assert Case Updated Values
                System.assertEquals(true, updatedCase.Make__c.containsIgnoreCase(''), generateErrorMessage('', updatedCase.Make__c));
                System.assertEquals(true, updatedCase.VehicleModel__c.containsIgnoreCase(''), generateErrorMessage('', updatedCase.VehicleModel__c));
                System.assertEquals(true, updatedCase.MY__c.containsIgnoreCase(''), generateErrorMessage('', updatedCase.MY__c));
                System.assertEquals(null, updatedCase.Fuel_Type__c);
                System.assertEquals(null, updatedCase.Engine__c);
                System.assertEquals(null, updatedCase.Drivetrain__c);
                System.assertEquals(null, updatedCase.Trans__c);
                System.assertEquals(null, updatedCase.ModelCode__c);

                // Assert Case Vehicle Info field value
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.Make__c), generateErrorMessage(updatedCase.Make__c, updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.VehicleModel__c), generateErrorMessage(updatedCase.VehicleModel__c, updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.MY__c), generateErrorMessage(updatedCase.MY__c, updatedCase.VehicleInfo__c));

                // Asset Created Case Vehicle values
                System.assertEquals(1, createdCaseVehicles.size(), 'Unexpected number of Case Vehicles');

                System.assertEquals(true, createdCaseVehicles[0].Make__c.containsIgnoreCase(''), generateErrorMessage('', createdCaseVehicles[0].Make__c));
                System.assertEquals(true, createdCaseVehicles[0].Model__c.containsIgnoreCase(''), generateErrorMessage('', createdCaseVehicles[0].Model__c));
                System.assertEquals(true, createdCaseVehicles[0].VehicleYear__c.containsIgnoreCase(''), generateErrorMessage('', createdCaseVehicles[0].VehicleYear__c));
                System.assertEquals(null, createdCaseVehicles[0].FuelType__c);
                System.assertEquals(null, createdCaseVehicles[0].EngineDescription__c);
                System.assertEquals(null, createdCaseVehicles[0].DrivetrainDescription__c);
                System.assertEquals(null, createdCaseVehicles[0].TransmissionDescription__c);
                System.assertEquals(null, createdCaseVehicles[0].ModelCode__c);
                System.assertEquals(false, createdCaseVehicles[0].HasModelCode__c);
            } else if (updatedCase.Subject.equalsIgnoreCase('MMNM')) {

                // Assert Case Updated Values
                System.assertEquals(true, updatedCase.Make__c.containsIgnoreCase('HYUNDAI'), generateErrorMessage('HYUNDAI', updatedCase.Make__c));
                System.assertEquals(true, updatedCase.VehicleModel__c.containsIgnoreCase('SONATA HYBRID'), generateErrorMessage('SONATA HYBRID', updatedCase.VehicleModel__c));
                System.assertEquals(true, updatedCase.MY__c.containsIgnoreCase('2014'), generateErrorMessage('2014', updatedCase.MY__c));
                System.assertEquals(true, updatedCase.MY__c.containsIgnoreCase('2015'), generateErrorMessage('2015', updatedCase.MY__c));
                System.assertEquals(true, updatedCase.Fuel_Type__c.containsIgnoreCase('HEV'), generateErrorMessage('HEV', updatedCase.Fuel_Type__c));
                System.assertEquals(true, updatedCase.Engine__c.containsIgnoreCase('2.4L I4 THETA HYBRID'), generateErrorMessage('2.4L I4 THETA HYBRID', updatedCase.Engine__c));
                System.assertEquals(true, updatedCase.Engine__c.containsIgnoreCase('3.6L I5 THETA HYBRID'), generateErrorMessage('3.6L I5 THETA HYBRID', updatedCase.Engine__c));
                System.assertEquals(true, updatedCase.Drivetrain__c.containsIgnoreCase('FRONT WHEEL DRIVE'), generateErrorMessage('FRONT WHEEL DRIVE', updatedCase.Drivetrain__c));
                System.assertEquals(true, updatedCase.Trans__c.containsIgnoreCase('AUTO'), generateErrorMessage('AUTO', updatedCase.Trans__c));
                System.assertEquals(true, updatedCase.ModelCode__c.containsIgnoreCase('YFE'), generateErrorMessage('YFE', updatedCase.ModelCode__c));

                // Assert Case Vehicle Info field value
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.Make__c), generateErrorMessage(updatedCase.Make__c, updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.VehicleModel__c), generateErrorMessage(updatedCase.VehicleModel__c, updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase('2014-2015'), generateErrorMessage('2014-2015', updatedCase.VehicleInfo__c));

                // Asset Created Case Vehicle values
                System.assertEquals(1, createdCaseVehicles.size(), 'Unexpected number of Case Vehicles');

                System.assertEquals(true, createdCaseVehicles[0].Make__c.containsIgnoreCase('HYUNDAI'), generateErrorMessage('HYUNDAI', createdCaseVehicles[0].Make__c));
                System.assertEquals(true, createdCaseVehicles[0].Model__c.containsIgnoreCase('SONATA HYBRID'), generateErrorMessage('SONATA HYBRID', createdCaseVehicles[0].Model__c));
                System.assertEquals(true, createdCaseVehicles[0].VehicleYear__c.containsIgnoreCase('2014'), generateErrorMessage('2014', createdCaseVehicles[0].VehicleYear__c));
                System.assertEquals(true, createdCaseVehicles[0].VehicleYear__c.containsIgnoreCase('2015'), generateErrorMessage('2015', createdCaseVehicles[0].VehicleYear__c));
                System.assertEquals(true, createdCaseVehicles[0].FuelType__c.containsIgnoreCase('HEV'), generateErrorMessage('HEV', createdCaseVehicles[0].FuelType__c));
                System.assertEquals(true, createdCaseVehicles[0].EngineDescription__c.containsIgnoreCase('2.4L I4 THETA HYBRID'), generateErrorMessage('2.4L I4 THETA HYBRID', createdCaseVehicles[0].EngineDescription__c));
                System.assertEquals(true, createdCaseVehicles[0].EngineDescription__c.containsIgnoreCase('3.6L I5 THETA HYBRID'), generateErrorMessage('3.6L I5 THETA HYBRID', createdCaseVehicles[0].EngineDescription__c));
                System.assertEquals(true, createdCaseVehicles[0].DrivetrainDescription__c.containsIgnoreCase('FRONT WHEEL DRIVE'), generateErrorMessage('FRONT WHEEL DRIVE', createdCaseVehicles[0].DrivetrainDescription__c));
                System.assertEquals(true, createdCaseVehicles[0].TransmissionDescription__c.containsIgnoreCase('AUTO'), generateErrorMessage('AUTO', createdCaseVehicles[0].TransmissionDescription__c));
                System.assertEquals(true, createdCaseVehicles[0].ModelCode__c.containsIgnoreCase('YFE'), generateErrorMessage('YFE', createdCaseVehicles[0].ModelCode__c));
                System.assertEquals(true, createdCaseVehicles[0].HasModelCode__c);

            } else if (updatedCase.Subject.equalsIgnoreCase('MPM')) {

                // Assert Case Updated Values
                System.assertEquals(true, updatedCase.Make__c.containsIgnoreCase('HYUNDAI'), generateErrorMessage('HYUNDAI', updatedCase.Make__c));
                System.assertEquals(true, updatedCase.VehicleModel__c.containsIgnoreCase('SONATA HYBRID'), generateErrorMessage('SONATA HYBRID', updatedCase.VehicleModel__c));
                System.assertEquals(true, contains('2014;2015;2019', updatedCase.MY__c), generateErrorMessage('2014;2015;2019', updatedCase.MY__c));
                System.assertEquals(null, updatedCase.Fuel_Type__c);
                System.assertEquals(true, contains('2.4L I4 THETA HYBRID;3.6L I5 THETA HYBRID', updatedCase.Engine__c), generateErrorMessage('2.4L I4 THETA HYBRID;3.6L I5 THETA HYBRID', updatedCase.Engine__c));
                System.assertEquals(true, contains('FRONT WHEEL DRIVE;ALL WHEEL DRIVE', updatedCase.Drivetrain__c), generateErrorMessage('FRONT WHEEL DRIVE;ALL WHEEL DRIVE', updatedCase.Drivetrain__c));
                System.assertEquals(null, updatedCase.Trans__c);
                System.assertEquals(true, updatedCase.ModelCode__c.containsIgnoreCase(''), generateErrorMessage('', updatedCase.ModelCode__c));

                // Assert Case Vehicle Info field value
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.Make__c), generateErrorMessage(updatedCase.Make__c, updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase(updatedCase.VehicleModel__c), generateErrorMessage(updatedCase.VehicleModel__c, updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase('2014-2015'), generateErrorMessage('2014-2015', updatedCase.VehicleInfo__c));
                System.assertEquals(true, updatedCase.VehicleInfo__c.containsIgnoreCase('2019'), generateErrorMessage('2019', updatedCase.VehicleInfo__c));

                // Asset Created Case Vehicle values
                System.assertEquals(2, createdCaseVehicles.size(), 'Unexpected number of Case Vehicles');

                for (CaseVehicle__c caseVehicle : createdCaseVehicles) {
                    if (caseVehicle.ModelCode__c.equalsIgnoreCase('YFE')) {
                        System.assertEquals(true, caseVehicle.Make__c.containsIgnoreCase('HYUNDAI'), generateErrorMessage('HYUNDAI', caseVehicle.Make__c));
                        System.assertEquals(true, caseVehicle.Model__c.containsIgnoreCase('SONATA HYBRID'), generateErrorMessage('SONATA HYBRID', caseVehicle.Model__c));
                        System.assertEquals('2014;2015', getSortedString(caseVehicle.VehicleYear__c), generateErrorMessage('2014;2015', getSortedString(caseVehicle.VehicleYear__c)));
                        System.assertEquals(null, caseVehicle.FuelType__c);
                        System.assertEquals(true, contains('2.4L I4 THETA HYBRID;3.6L I5 THETA HYBRID', caseVehicle.EngineDescription__c), generateErrorMessage('2.4L I4 THETA HYBRID;3.6L I5 THETA HYBRID', caseVehicle.EngineDescription__c));
                        System.assertEquals(true, caseVehicle.DrivetrainDescription__c.containsIgnoreCase('FRONT WHEEL DRIVE'), generateErrorMessage('FRONT WHEEL DRIVE', caseVehicle.DrivetrainDescription__c));
                        System.assertEquals(null, caseVehicle.TransmissionDescription__c);
                        System.assertEquals(true, caseVehicle.HasModelCode__c);
                    } else if (caseVehicle.ModelCode__c.equalsIgnoreCase('YFC')) {
                        System.assertEquals(true, caseVehicle.Make__c.containsIgnoreCase('HYUNDAI'), generateErrorMessage('HYUNDAI', caseVehicle.Make__c));
                        System.assertEquals(true, caseVehicle.Model__c.containsIgnoreCase('SONATA HYBRID'), generateErrorMessage('SONATA HYBRID', caseVehicle.Model__c));
                        System.assertEquals(true, caseVehicle.VehicleYear__c.containsIgnoreCase('2019'), generateErrorMessage('2019', caseVehicle.VehicleYear__c));
                        System.assertEquals(null, caseVehicle.FuelType__c);
                        System.assertEquals(null, caseVehicle.EngineDescription__c);
                        System.assertEquals(true, caseVehicle.DrivetrainDescription__c.containsIgnoreCase('ALL WHEEL DRIVE'), generateErrorMessage('ALL WHEEL DRIVE', caseVehicle.DrivetrainDescription__c));
                        System.assertEquals(null, caseVehicle.TransmissionDescription__c);
                        System.assertEquals(true, caseVehicle.HasModelCode__c);
                    } else {
                        System.assertEquals(false, true, 'Unexpected model code ' + caseVehicle.ModelCode__c);
                    }
                }
            } else if (updatedCase.Subject.equalsIgnoreCase('NM')) {

                // Assert Case Updated Values
                System.assertEquals(true, updatedCase.Make__c.containsIgnoreCase('HYUNDAI'), generateErrorMessage('HYUNDAI', updatedCase.Make__c));
                System.assertEquals(true, updatedCase.VehicleModel__c.containsIgnoreCase('ACCENT'), generateErrorMessage('ACCENT', updatedCase.VehicleModel__c));
                System.assertEquals(true, updatedCase.MY__c.containsIgnoreCase('2010;2014;2015;2019'), generateErrorMessage('2010;2014;2015;2019', updatedCase.MY__c));
                System.assertEquals(null, updatedCase.Fuel_Type__c);
                System.assertEquals(null, updatedCase.Engine__c);
                System.assertEquals(true, contains('FRONT WHEEL DRIVE;ALL WHEEL DRIVE', updatedCase.Drivetrain__c), generateErrorMessage('FRONT WHEEL DRIVE;ALL WHEEL DRIVE', updatedCase.Drivetrain__c));
                System.assertEquals(null, updatedCase.Trans__c);
                System.assertEquals(null, updatedCase.ModelCode__c);

                // Assert Case Vehicle Info field value
                System.assertEquals(null, updatedCase.VehicleInfo__c);

                // Asset Created Case Vehicle values
                System.assertEquals(0, createdCaseVehicles.size(), 'Unexpected number of Case Vehicles');

            } else if (updatedCase.Subject.equalsIgnoreCase('EC')) {

                // Assert Case Updated Values
                System.assertEquals(null, updatedCase.Make__c);
                System.assertEquals(null, updatedCase.VehicleModel__c);
                System.assertEquals(null, updatedCase.MY__c);
                System.assertEquals(null, updatedCase.Fuel_Type__c);
                System.assertEquals(null, updatedCase.Engine__c);
                System.assertEquals(null, updatedCase.Drivetrain__c);
                System.assertEquals(null, updatedCase.Trans__c);
                System.assertEquals(null, updatedCase.ModelCode__c);

                // Assert Case Vehicle Info field value
                System.assertEquals(null, updatedCase.VehicleInfo__c);

                // Asset Created Case Vehicle values
                System.assertEquals(0, createdCaseVehicles.size(), 'Unexpected number of Case Vehicles');

            } else {
                System.assertEquals(false, true, 'Unexpected case');
            }
        }
    }

    @IsTest
    static void testBatchJob_MissingCVOnly() {
        Test.startTest();
        CaseVehicleBulkCreateBatch.runJob(true);
        Test.stopTest();

        List<CaseVehicle__c> createdCV = [SELECT Id FROM CaseVehicle__c];
        System.assertNotEquals(0, createdCV.size());
    }
    private static String getSortedString(String yearStr) {
        List<String> yearsStrings = yearStr.split(';');
        yearsStrings.sort();
        return String.join(yearsStrings, ';');
    }

    private static String generateErrorMessage(String expected, String actualValue) {
        return String.format('Expect Contains: {0}, Actual Field Value: {1}', new List<String>{
                expected, actualValue
        });
    }

    private static Boolean contains(String expectedValues, String actualValues) {
        List<String> expectedList = expectedValues.split(';');
        Set<String> expectedSet = new Set<String>();
        for (String str : expectedList) {
            expectedSet.add(str.trim().toLowerCase());
        }

        List<String> actual = actualValues.split(';');

        for (String value : actual) {
            if (!expectedSet.contains(value.trim().toLowerCase())) {
                return false;
            }
        }
        return true;
    }
}