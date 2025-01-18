@IsTest
public class cqb_RelatedCase_CT_Test {
    private enum Similarity {Exact, Partial, Different}
    static void makeData(Similarity howSimilar){

        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('KASDA').getRecordTypeId();      // KASO.2023.05.11 복구시 주석 처리 필요 (1/26)
        //Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();        // KASO.2023.05.11 복구시 주석 제거 필요 (2/26)

        SCSConfigurationSettings__c setting = new SCSConfigurationSettings__c();
        setting.CurrentCaseNumber__c = 1;
        insert setting;

        Case c = new Case();
        c.Subject = 'Test Hyundai G80 Car';
        c.Description = 'Hyundai G80';
        c.Make__c = 'Hyundai';
        c.VehicleModel__c = 'G80';
        c.MY__c = '2021';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMC';                               // KASO.2023.05.11 복구시 주석 처리 필요 (3/26)
        c.CountrySubmitterWorks__c = 'Korea';                   // KASO.2023.05.11 복구시 주석 처리 필요 (4/26)
        c.SCSCaseRegion__c = 'Korea';                           // KASO.2023.05.11 복구시 주석 처리 필요 (5/26)
        //c.CompanyName__c = 'HMA';                             // KASO.2023.05.11 복구시 주석 제거 필요 (6/26)
        //c.CountrySubmitterWorks__c = 'Canada';                // KASO.2023.05.11 복구시 주석 제거 필요 (7/26)
        //c.SCSCaseRegion__c = 'North America';                 // KASO.2023.05.11 복구시 주석 제거 필요 (8/26)
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';
        c.MethodofRepair__c = 'Changed Hyundai G80 Engine';
        c.IncidentswithFires__c = '10';

        c.Drivetrain__c = 'REAR WHEEL DRIVE';
        c.PossiblyAssociablePrimaryHazard__c = 'Difficulty/inability to control direction/path (steering, stability, etc.)';
        c.CategoryofComponentAffected__c = 'Brakes';
        c.Trans__c = 'Auto';
        c.Engine__c = '5.0L V8 DOHC GDI Tau';
        c.ModelCode__c = 'DH';
        insert c;

        Case c2 = new Case();
        if(howSimilar == Similarity.Exact){
            c2.Subject = 'steer control locked';
            c2.Description = 'Hyundai G80 control locked due to power loss';
            c2.Make__c = 'Hyundai';
            c2.VehicleModel__c = 'G80';
            c2.MY__c = '2021';
            c2.SafetyType__c = 'Vehicle';
            c2.CompanyName__c = 'HMC';                               // KASO.2023.05.11 복구시 주석 처리 필요 (9/26)
            c2.CountrySubmitterWorks__c = 'Korea';                   // KASO.2023.05.11 복구시 주석 처리 필요 (10/26)
            c2.SCSCaseRegion__c = 'Korea';                           // KASO.2023.05.11 복구시 주석 처리 필요 (11/26)
            //c2.CompanyName__c = 'HMA';                             // KASO.2023.05.11 복구시 주석 제거 필요 (12/26)
            //c2.CountrySubmitterWorks__c = 'Canada';                // KASO.2023.05.11 복구시 주석 제거 필요 (13/26)
            //c2.SCSCaseRegion__c = 'North America';                 // KASO.2023.05.11 복구시 주석 제거 필요 (14/26)
            c2.Haveyoupreviouslyreportedtheissues__c = 'No';
            c2.RecordTypeId = recordTypeId;
            c2.SCSCaseNumber__c = 'Test2';
            c2.MethodofRepair__c = 'assist the power source control';
            c2.IncidentswithFires__c = '10';

            c2.Drivetrain__c = 'REAR WHEEL DRIVE';
            c2.PossiblyAssociablePrimaryHazard__c = 'Difficulty/inability to control direction/path (steering, stability, etc.)';
            c2.CategoryofComponentAffected__c = 'Brakes';
            c2.Trans__c = 'Auto';
            c2.Engine__c = '5.0L V8 DOHC GDI Tau';
            c2.ModelCode__c = 'DH';
        }
        else if(howSimilar == Similarity.Partial) {
            c2.SCSCaseNumber__c = 'Test 2';
            c2.Subject = 'Test Hyundai G80 Car';
            c2.Description = 'Hyundai G80';
            c2.Make__c = 'Hyundai';
            c2.VehicleModel__c = 'G80';
            c2.MY__c = '2021';
            c2.SafetyType__c = 'Vehicle';
            c2.CompanyName__c = 'HMC';                           // KASO.2023.05.11 복구시 주석 처리 필요 (15/26)
            c2.CountrySubmitterWorks__c = 'Korea';               // KASO.2023.05.11 복구시 주석 처리 필요 (16/26)
            c2.SCSCaseRegion__c = 'Korea';                       // KASO.2023.05.11 복구시 주석 처리 필요 (17/26)
            //c2.CompanyName__c = 'HMA';                         // KASO.2023.05.11 복구시 주석 제거 필요 (18/26)
            //c2.CountrySubmitterWorks__c = 'Canada';            // KASO.2023.05.11 복구시 주석 제거 필요 (19/26)
            //c2.SCSCaseRegion__c = 'North America';             // KASO.2023.05.11 복구시 주석 제거 필요 (20/26)
            c2.Haveyoupreviouslyreportedtheissues__c = 'No';
            c2.MethodofRepair__c = 'Changed Hyundai G80 Engine';
            c2.IncidentswithFires__c = '11';

            c2.Drivetrain__c = 'REAR WHEEL DRIVE';
            c2.PossiblyAssociablePrimaryHazard__c = 'Difficulty/inability to control direction/path (steering, stability, etc.)';
            c2.CategoryofComponentAffected__c = 'Steering';
            c2.Trans__c = 'Auto';
            c2.Engine__c = '5.0L V8 DOHC GDI Tau';
            c2.ModelCode__c = 'DH';
        }
        else {
            c2.SCSCaseNumber__c = 'Test 2';
            c2.Subject = 'Test Genesis Car';
            c2.Description = 'Airbag non-deployment after a crash';
            c2.Make__c = 'Genesis';
            c2.VehicleModel__c = 'Elantra';
            c2.MY__c = '2016';
            c2.SafetyType__c = 'Vehicle';
            c2.CompanyName__c = 'HMC';                              // KASO.2023.05.11 복구시 주석 처리 필요 (21/26)
            c2.CountrySubmitterWorks__c = 'Korea';                  // KASO.2023.05.11 복구시 주석 처리 필요 (22/26)
            c2.SCSCaseRegion__c = 'Korea';                          // KASO.2023.05.11 복구시 주석 처리 필요 (23/26)
            //c2.CompanyName__c = 'HMA';                            // KASO.2023.05.11 복구시 주석 제거 필요 (24/26)
            //c2.CountrySubmitterWorks__c = 'United States';        // KASO.2023.05.11 복구시 주석 제거 필요 (25/26)
            //c2.SCSCaseRegion__c = 'Other';                        // KASO.2023.05.11 복구시 주석 제거 필요 (26/26)
            c2.Haveyoupreviouslyreportedtheissues__c = 'Yes';

            c2.Drivetrain__c = 'FRONT WHEEL DRIVE';
            c2.CategoryofComponentAffected__c = 'Body Exterior';
            c2.Trans__c = 'Manual';
            c2.Engine__c = '2.4L I4 GDI Theta II';
            c2.ModelCode__c = 'MD;UD';
        }
        insert c2;

    }

    @IsTest
    public static void linkCasesTest(){
        makeData(Similarity.Partial);
        List<Case> cases = [SELECT Id FROM Case LIMIT 2];
        cqb_RelatedCase_CT.linkCases(cases[0].Id, new List<String>{cases[1].Id});
        //linkCases(cases[0].Id, new List<String>{cases[1].Id});
        System.assertEquals(1, [SELECT Id FROM RelatedCase__c].size());
    }

    @IsTest
    public static void getRelatedCasesTest_ExactMatch(){
        makeData(Similarity.Exact);

        Case c = [SELECT Id FROM Case WHERE SCSCaseNumber__c = 'Test1' LIMIT 1];
        cqb_RelatedCase_CT.cqbWrapRecord[] recommendedrelatedCases = cqb_RelatedCase_CT.getRelatedCasesEnhanced(c.Id);
        System.assertEquals(1, recommendedrelatedCases.size());

        System.debug('RESULT:: ' + JSON.serializePretty(recommendedrelatedCases));
        System.assertEquals(100, recommendedrelatedCases[0].mPercent);
    }

    @IsTest
    public static void getRelatedCasesTest_PartialMatch(){
        makeData(Similarity.Partial);

        Case c = [SELECT Id FROM Case LIMIT 1];
        cqb_RelatedCase_CT.cqbWrapRecord[] recommendedrelatedCases = cqb_RelatedCase_CT.getRelatedCasesEnhanced(c.Id);
        System.assertEquals(1, recommendedrelatedCases.size());

        System.debug('RESULT:: ' + JSON.serializePretty(recommendedrelatedCases));
        System.assertEquals(56, recommendedrelatedCases[0].mPercent);
    }

    @IsTest
    public static void getRelatedCasesTest_NoMatch(){
        makeData(Similarity.Different);

        Case c = [SELECT Id FROM Case LIMIT 1];
        cqb_RelatedCase_CT.cqbWrapRecord[] recommendedrelatedCases = cqb_RelatedCase_CT.getRelatedCasesEnhanced(c.Id);
        System.assertEquals(0, recommendedrelatedCases.size());
    }
}