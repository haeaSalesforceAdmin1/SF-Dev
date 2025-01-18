@isTest
public class COPPTrackerSaveControllerTest {

    @isTest
    static void testGeneratePDFAndSave() {
        // Create a mock Account for testing
        Account testAccount = new Account(
            Name = 'Test Account',
            DealerCode__c = 'D12345'
        );
        insert testAccount;

        // Prepare the request object
        COPPTrackerSaveController.Request request = new COPPTrackerSaveController.Request();
        request.accountId = testAccount.Id;
        request.letterDate = '2024-09-10';
        request.regionName = 'West Region';
        request.dealerPrincipalName = 'John Doe';
        request.dealershipName = 'Doe Motors';
        request.dealerShipAddress = '1234 Elm Street';
        request.cityStateZipCode = 'Los Angeles, CA 90001';
        request.emailAddress = 'johndoe@example.com';
        request.choosedTemplate = 'Hyundai Letter Template';
        request.brandCode = 'H';
        request.dealerCode = 'D12345';
        request.regionCode = 'WR123';
        request.salutation = 'Mr. ';
        request.onlyTracker = false;
        request.comments = 'Test';

        List<COPPTrackerSaveController.Request> requestList = new List<COPPTrackerSaveController.Request>{request};


        // Set up a test page and simulate the controller interaction
        PageReference testPage = new PageReference('/apex/COPPMonthlyTracker?recordId=' + testAccount.Id);
        Test.setCurrentPage(testPage);

        // Call the method under test
        Test.startTest();
        COPPTrackerSaveController.generatePDFAndSave(requestList);
        Test.stopTest();
    }

    @isTest
    static void testGeneratePDFAndSave_TrackerOnly() {
        // Create a mock Account for testing
        Account testAccount = new Account(
            Name = 'Test Account',
            DealerCode__c = 'D54321'
        );
        insert testAccount;

        // Prepare the request object with onlyTracker = true
        COPPTrackerSaveController.Request request = new COPPTrackerSaveController.Request();
        request.accountId = testAccount.Id;
        request.letterDate = '2024-09-10';
        request.regionName = 'East Region';
        request.dealerPrincipalName = 'Jane Smith';
        request.dealershipName = 'Smith Autos';
        request.dealerShipAddress = '5678 Oak Street';
        request.cityStateZipCode = 'New York, NY 10001';
        request.emailAddress = 'janesmith@example.com';
        request.choosedTemplate = 'Genesis Letter Template';
        request.brandCode = 'G';
        request.dealerCode = 'D54321';
        request.regionCode = 'ER456';
        request.salutation = 'Mr. '; //DPM-5861 added salutation
        request.onlyTracker = true;
        request.comments = 'Test';

        List<COPPTrackerSaveController.Request> requestList = new List<COPPTrackerSaveController.Request>{request};

        // Set up a test page and simulate the controller interaction
        PageReference testPage = new PageReference('/apex/COPPMonthlyTracker?recordId=' + testAccount.Id);
        Test.setCurrentPage(testPage);

        // Call the method under test
        Test.startTest();
        COPPTrackerSaveController.generatePDFAndSave(requestList);
        Test.stopTest();

    }
}