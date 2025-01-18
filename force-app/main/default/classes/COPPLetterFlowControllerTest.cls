@isTest
public class COPPLetterFlowControllerTest {

    @isTest
    static void testCOPPLetterFlowController() {
        // Mock the page and parameters
        PageReference pageRef = Page.COPPLetter; 
        Test.setCurrentPage(pageRef);

        // Set parameters to mimic the Visualforce page request
        ApexPages.currentPage().getParameters().put('LetterDate', '2024-09-10');
        ApexPages.currentPage().getParameters().put('regionName', 'West Region');
        ApexPages.currentPage().getParameters().put('regionCode', 'WR123');
        ApexPages.currentPage().getParameters().put('DealerPrincipalName', 'John Doe');
        ApexPages.currentPage().getParameters().put('DealershipName', 'Doe Motors');
        ApexPages.currentPage().getParameters().put('DealerShip_Address', '1234 Elm Street');
        ApexPages.currentPage().getParameters().put('City_State_Zip_Code', 'Los Angeles, CA 90001');
        ApexPages.currentPage().getParameters().put('Email_Address', 'johndoe@example.com');
        ApexPages.currentPage().getParameters().put('ChoosedTemplate', 'Hyundai Letter Template');

        // Instantiate the controller
        COPPLetterFlowController controller = new COPPLetterFlowController();

        // Assert that the today field is set correctly (formatted as MM-DD-YYYY)
        Date today = Date.today();
        String expectedToday = String.format('{0}-{1}-{2}', 
            new List<String>{
                String.valueOf(today.month()).leftPad(2, '0'),
                String.valueOf(today.day()).leftPad(2, '0'),
                String.valueOf(today.year())
            }
        );
        System.assertEquals(expectedToday, controller.today);
    }

    @isTest
    static void testCOPPLetterFlowController_GenesisTemplate() {
        // Mock the page and parameters
        PageReference pageRef = Page.COPPLetter; 
        Test.setCurrentPage(pageRef);

        // Set parameters with Genesis template
        ApexPages.currentPage().getParameters().put('ChoosedTemplate', 'Genesis Letter Template');

        // Instantiate the controller
        COPPLetterFlowController controller = new COPPLetterFlowController();

    }
}