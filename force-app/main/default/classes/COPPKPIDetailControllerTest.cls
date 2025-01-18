@isTest
public class COPPKPIDetailControllerTest {
    
    @testSetup
    static void setup() {
        CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;

        TestUtility.createOrganizations();
        // List<Region__c> regions = TestUtility.createRegionsForOrganizations(TestUtility.GENESIS_ORG);
        // TestUtility.createDistrictsForRegions();

        //Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);

        Account acc = new Account(
            	Name = 'Test Account',
            	Organization__c = genOrg.Id,
                DealerCode__c = 'NY701'
        );
        insert acc;
        
        COPPInfo__c coppInfo = new COPPInfo__c(
            	Name = 'Test coppInfo',
            	COPP__c = true,
                Account__c = acc.Id
        );
        insert coppInfo;
        
        // Create test COPPKPI__c records
        List<COPPKPI__c> kpis = new List<COPPKPI__c>();
        for(Integer i = 0; i < 3; i++) {
            kpis.add(new COPPKPI__c(Name = 'KPI ' + i, Brand_Code__c = 'G', Section__c = 'Section ' + Math.mod( i, 2 ), KPI_Sequence__c = i));
        }
        insert kpis;

        // Create test COPPKPIDetail__c records
        List<COPPKPIDetail__c> kpiDetails = new List<COPPKPIDetail__c>();
        for(COPPKPI__c kpi : kpis) {
            kpiDetails.add(new COPPKPIDetail__c(Name = kpi.Name + ' Detail', COPP_KPI__c = kpi.Id, Account__c = acc.Id));
        }
        insert kpiDetails;
        
    }

    @isTest
    static void testGetKPIDetailsBySection() {
        // Retrieve test account
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<COPPKPI__c> kpis = [SELECT Id, Name FROM COPPKPI__c];
        
        Test.startTest();
        List<COPPKPIDetail__c> kpiDetails = new List<COPPKPIDetail__c>();
        for(COPPKPI__c kpi : kpis) {
            kpiDetails.add(new COPPKPIDetail__c(Name = kpi.Name + ' Detail2', COPP_KPI__c = kpi.Id, Account__c = acc.Id));
        }
        
        Map<String, List<COPPKPIDetailController.COPPKPIDetailWrapper>> result = COPPKPIDetailController.getKPIDetailsBySection(acc.Id);
        Test.stopTest();
        
        // Verify the result
        System.assert(result != null, 'Result should not be null');
        //System.assert(result.containsKey('Section 0'), 'Result should contain Section 0');
        //System.assert(result.containsKey('Section 1'), 'Result should contain Section 1');
        //System.assertEquals(2, result.get('Section 0').size(), 'Section 0 should have 2 items');
        //System.assertEquals(1, result.get('Section 1').size(), 'Section 1 should have 1 item');
    }

    @isTest
    static void testSaveKPIDetails() {
        // Retrieve test account and related COPPKPIDetail__c records
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<COPPKPIDetail__c> kpiDetails = [SELECT Id, Name, Initial_Score__c, Target_Score__c FROM COPPKPIDetail__c WHERE Account__c = :acc.Id];

        // Update some fields
        for (COPPKPIDetail__c detail : kpiDetails) {
            detail.Initial_Score__c = 100;
        }

        Test.startTest();
        COPPKPIDetailController.saveKPIDetails(kpiDetails);
        Test.stopTest();

        // Verify the update
        List<COPPKPIDetail__c> updatedDetails = [SELECT Id, Initial_Score__c, Target_Score__c FROM COPPKPIDetail__c WHERE Account__c = :acc.Id];
        for (COPPKPIDetail__c detail : updatedDetails) {
            System.assertEquals(100, detail.Initial_Score__c, 'Initial Score should be updated to 100');
        }
    }

    @isTest
    static void testGetFromAccount() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        COPPKPIDetailController.COPPInfoWrapper acc = COPPKPIDetailController.getFromCOPPInfo(testAccount.Id);
        Test.stopTest();

       
    }

    @isTest
    static void testUpdateAccount() {
        COPPInfo__c testCOPPInfo = [SELECT Id FROM COPPInfo__c LIMIT 1];
        testCOPPInfo.COPP_End_Date__c = System.today();

        Test.startTest();
        COPPKPIDetailController.updateCOPPInfo(testCOPPInfo);
        COPPKPIDetailController.compareDate('07-2023');
        Test.stopTest();


    }
    
    
    @isTest
    static void testGetWAVEs() {

        WAVE__c wave1 = new WAVE__c(
            Name = 'WAVE 1',
            Initial_Start_Month__c = '01-2024',
            Period_Number__c = 1,
            BrandCode__c ='G'
        );
        WAVE__c wave2 = new WAVE__c(
            Name = 'WAVE 2',
            Initial_Start_Month__c = '12-2023',
            Period_Number__c = 2,
            BrandCode__c='H'
        );
        WAVE__c wave3 = new WAVE__c(
            Name = 'WAVE 3',
            Initial_Start_Month__c = '02-2099',
            Period_Number__c = 3,
            BrandCode__c='H'
        );
        insert new List<WAVE__c>{wave1, wave2, wave3};

        Test.startTest();

        Map<String, List<String>> result = COPPKPIDetailController.getWAVEs('WAVE 1', 'G');
        Map<String, List<String>> result2 = COPPKPIDetailController.getWAVEs('WAVE 3', 'H');
        Map<String, String> result3 = COPPKPIDetailController.getAllWAVEs('H');
        Test.stopTest();


    }
}