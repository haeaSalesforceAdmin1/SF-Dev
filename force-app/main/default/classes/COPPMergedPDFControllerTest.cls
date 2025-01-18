@isTest
public class COPPMergedPDFControllerTest {
    private static final String HYUNDAI_ORG = 'Hyundai';
    @testSetup
    static void setupTestData() {
        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(HYUNDAI_ORG);

        Account acc = new Account(
            Name = 'Test Account',
            DealerCode__c = 'D12345',
            SalesDistrictCode__c = 'WE1',
            BillingState = 'CA',
            Organization__c = hyundaiOrg.Id
        );
        insert acc;
        
        COPPInfo__c coppInfo = new COPPInfo__c(
            Account__c = acc.Id,
            Performance_Period__c = '032023',
            COPP_Performance_Reporting_Month__c = '202309',
            Scorecard1__c='1/2/3/4/5/6',
            Scorecard2__c='1/2/3/4/5/6',
            Scorecard3__c='1/2/3/4/5/6',
            Scorecard4__c='1/2/3/4/5/6',
            Scorecard5__c='1/2/3/4/5/6',
            Scorecard6__c='1/2/3/4/5/6'
        );
        insert coppInfo;
        COPPKPI__c coppkpi = new COPPKPI__c(Name = 'KPI 1', Section__c = 'Section 1', isPercent__c = true, isInteger__c = true, Key__c='H515');
        insert coppkpi;
        
        COPPKPIDetail__c kpiDetail1 = new COPPKPIDetail__c(
            Account__c = acc.Id,
            COPP_KPI__c = coppkpi.Id,
            Initial_Score__c = 90,
            Target_Score__c = 95,
            Month1__c = '85.5',
            Month2__c = '87.3',
            Month3__c = '89.2',
            Month4__c = '90.0',
            Month5__c = '91.5',
            Month6__c = '93.1',
            Visiblity__c = true
        );
        insert kpiDetail1;

        COPPKPI__c coppkpi2 = new COPPKPI__c(Name = 'KPI 1', Section__c = 'Section 1', isPercent__c = true, isInteger__c = false, Key__c='H300');
        insert coppkpi2;
        
        COPPKPIDetail__c kpiDetail2 = new COPPKPIDetail__c(
            Account__c = acc.Id,
            COPP_KPI__c = coppkpi2.Id,
            Initial_Score__c = 90,
            Target_Score__c = 95,
            Month1__c = '85.5',
            Month2__c = '87.3',
            Month3__c = '89.2',
            Month4__c = '90.0',
            Month5__c = '91.5',
            Month6__c = '93.1',
            Visiblity__c = true
        );
        insert kpiDetail2;
    }

    @isTest
    static void testHandleLoad() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        COPPMergedPDFController controller = new COPPMergedPDFController();
        controller.ChoosedTemplate = 'Genesis1';
        
        Test.startTest();
        controller.handleLoad();
        Test.stopTest();
        
    }

    @isTest
    static void testGetAccount() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        Test.startTest();
        Account acc = COPPMergedPDFController.getAccount(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, acc, 'Account should not be null');
        System.assertEquals('D12345', acc.DealerCode__c, 'Dealer Code should be D12345');
    }

    @isTest
    static void testGetCOPPInfo() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        Test.startTest();
        COPPInfo__c coppInfo = COPPMergedPDFController.getCOPPInfo(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, coppInfo, 'COPPInfo should not be null');
        System.assertEquals('032023', coppInfo.Performance_Period__c, 'Performance Period should be 032023');
    }
    
    @isTest
    static void testSetMonth() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        COPPInfo__c coppInfo = COPPMergedPDFController.getCOPPInfo(testAccount.Id);
        coppInfo.BrandImageCheckedDate__c = Date.newInstance(2023, 9, 11);
        
        Test.startTest();
        COPPMergedPDFController controller = new COPPMergedPDFController();
        controller.setBrandImage(coppInfo);
        coppInfo.BrandImageCheckedDate__c = Date.newInstance(2023, 8, 11);
        controller.setBrandImage(coppInfo);
        coppInfo.BrandImageCheckedDate__c = Date.newInstance(2023, 7, 11);
        controller.setBrandImage(coppInfo);
        coppInfo.BrandImageCheckedDate__c = Date.newInstance(2023, 6, 11);
        controller.setBrandImage(coppInfo);
        coppInfo.BrandImageCheckedDate__c = Date.newInstance(2023, 5, 11);
        controller.setBrandImage(coppInfo);
        coppInfo.BrandImageCheckedDate__c = Date.newInstance(2023, 4, 11);
        controller.setBrandImage(coppInfo);
        coppInfo.BrandImageCheckedDate__c = Date.newInstance(2023, 3, 11);
        controller.setBrandImage(coppInfo);
        Test.stopTest();

    }
    
    @isTest
    static void testGetCOPPKPI() {

        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
		COPPKPI__c coppkpi = [SELECT Id , isPercent__c FROM COPPKPI__c WHERE Key__c='H300'];
        ApexPages.StandardController stdController = new ApexPages.StandardController(acc);
        COPPMonthlyTrackerController controller = new COPPMonthlyTrackerController(stdController);
        controller.recordId = acc.Id;
		
        
        Test.startTest();
        controller.getCOPPKPI();
		coppkpi.isPercent__c = false;   
        update coppkpi;
        controller.getCOPPKPI();
        Test.stopTest();

    }

    @isTest
    static void testGetCOPPKPI2() {

        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
		COPPKPI__c coppkpi = [SELECT Id , isPercent__c FROM COPPKPI__c WHERE Key__c='H515'];
        ApexPages.StandardController stdController = new ApexPages.StandardController(acc);
        COPPMonthlyTrackerController controller = new COPPMonthlyTrackerController(stdController);
        controller.recordId = acc.Id;
		
        
        Test.startTest();
        controller.getCOPPKPI();
		coppkpi.isPercent__c = false;   
        update coppkpi;
        controller.getCOPPKPI();
        Test.stopTest();

    }
    
    @isTest
    static void testCalculatteCOPPKPI() {

        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
		COPPKPI__c coppkpi = [SELECT Id , isPercent__c FROM COPPKPI__c LIMIT 1];
        COPPKPIDetail__c kpiDetail = [SELECT id, Month1__c, Month2__c, Month3__c, Month4__c, Month5__c, Month6__c FROM COPPKPIDetail__c WHERE COPP_KPI__c =:coppkpi.Id LIMIT 1];

        COPPMergedPDFController controller = new COPPMergedPDFController();
        controller.recordId = acc.Id;
		
        
        Test.startTest();
        controller.getCOPPKPI();
        kpiDetail.Month6__c = null;
        update kpiDetail;
        controller.getCOPPKPI();
        kpiDetail.Month5__c = null;
        update kpiDetail;
        controller.getCOPPKPI();
        kpiDetail.Month4__c = null;
        update kpiDetail;
        controller.getCOPPKPI();
        kpiDetail.Month3__c = null;
        update kpiDetail;
        controller.getCOPPKPI();
        kpiDetail.Month2__c = null;
        update kpiDetail;
        controller.getCOPPKPI();
        kpiDetail.Month1__c = null;
        update kpiDetail;
        controller.getCOPPKPI();
		coppkpi.isPercent__c = false;   
        update coppkpi;
        controller.getCOPPKPI();
        
        Test.stopTest();

    }
}