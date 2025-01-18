/**
     * [Class Description] Test class for COPPDownloadController
     * Created by [MinheeKim] on [2024-10-08] for [DPM-5701]
    */
@isTest
public class COPPDownloadControllerTest {
    
    private static Account createTestAccount() {
        Account acc = new Account(
            Name = 'Test Dealership',
            DealerCode__c = '12345',
            BillingStreet = '1234 Test St',
            BillingCity = 'Test City',
            BillingState = 'TS',
            BillingPostalCode = '12345',
            BillingCountry = 'USA'
        );
        insert acc;
        return acc;
    }
    
    @isTest
    static void testGenerateCombined() {
        Account testAccount = createTestAccount();
        String recordId = testAccount.Id;
        String letterDate = '2024-10-07';
        String regionName = 'Test Region';
        String dealershipName = 'Test Dealership';
        String dealershipAddress = '1234 Test St, Test City, TS, 12345';
        String cityStateZipCode = 'Test City, TS, 12345';
        String emailAddress = 'testdealer@test.com';
        String dealerPrincipalName = 'John Doe';
        String choosedTemplate = 'Template A';
        String regionCode = 'WE';
        String salutation = 'Mr. ';
        String comments = 'Test Comments';


        Test.startTest();
        String contentDocumentId = COPPDownloadController.generateCombined(
            recordId, letterDate, regionName, dealershipName, 
            dealershipAddress, cityStateZipCode, emailAddress, 
            dealerPrincipalName, choosedTemplate, regionCode, salutation, comments
        );
        Test.stopTest();

    }
    
    @isTest
    static void testGenerateTracker() {
        // Setup test data
        Account testAccount = createTestAccount();
        String recordId = testAccount.Id;
        String comments = '';

        // Test method
        Test.startTest();
        String contentDocumentId = COPPDownloadController.generateTracker(recordId, 'COPP_Tracker', comments);
        Test.stopTest();

    }

    @isTest
    static void testGenerateGMScorecard() {
        // Setup test data
        Account testAccount = createTestAccount();
        String recordId = testAccount.Id;
        String comments = 'Test Comments';

        // Test method
        Test.startTest();
        String contentDocumentId = COPPDownloadController.generateTracker(recordId, 'GM_Scorecard', comments);
        Test.stopTest();

    }

    @isTest
    static void testGenerateLetter() {
        Account testAccount = createTestAccount();
        String recordId = testAccount.Id;
        String letterDate = '2024-10-07';
        String regionName = 'Test Region';
        String dealershipName = 'Test Dealership';
        String dealershipAddress = '1234 Test St, Test City, TS, 12345';
        String cityStateZipCode = 'Test City, TS, 12345';
        String emailAddress = 'testdealer@test.com';
        String dealerPrincipalName = 'John Doe';
        String choosedTemplate = 'Template A';
        String regionCode = 'WE';
        String salutation = 'Mr. '; //DPM-5861 added salutation

        Test.startTest();
        String contentDocumentId = COPPDownloadController.generateLetter(
            letterDate, regionName, dealershipName, dealershipAddress, 
            cityStateZipCode, emailAddress, dealerPrincipalName, 
            choosedTemplate, regionCode, salutation, recordId 
        );
        Test.stopTest();


    }
}