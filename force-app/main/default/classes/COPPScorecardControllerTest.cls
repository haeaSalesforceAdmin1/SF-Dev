@isTest
public class COPPScorecardControllerTest {
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
     
    }

    @isTest
    static void testHandleLoad() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController(testAccount);
        
        COPPScorecardController controller = new COPPScorecardController(stdController);
        
        Test.startTest();
        controller.handleLoad();
        Test.stopTest();
        
    }

    
    
}