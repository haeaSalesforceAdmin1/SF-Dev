@isTest(seeAlldata=false)               
public class PackageElementsViewerControllerTest {
    private static final String HYUNDAI_ORG = 'Hyundai';
    private static final String DEALER_NAME = 'UTOPIA MOUNTAIN SUNRISE HYUNDAI';
    private static final String DISTRICT_NAME = 'ATLANTA';
    private static final String REGION_NAME = 'SOUTHERN REGION';
    private static final String REGION_CODE = 'SO';
    private static final String DEALER_CODE = 'GA999';

    @TestSetup
    static void makeData() {
        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations(HYUNDAI_ORG);
        TestUtility.createDistrictsForRegions();

        District__c district = TestUtility.getDistrict(DISTRICT_NAME, REGION_NAME, HYUNDAI_ORG);
        Account dealer = DNAMSPackageTestDataFactory.createNewDealer(DEALER_NAME, DEALER_CODE, district, REGION_CODE);

        Package__c p = DNAMSPackageTestDataFactory.createNewPackage(dealer.Id);
        List<PackageElement__c> lstPEs = new List<PackageElement__c>();
        for(Integer i = 0; i < 10; i++) {
            lstPEs.add(DNAMSPackageTestDataFactory.getNewPackageElement(p.Id, dealer.Id));
        }
        insert lstPEs;
    }
    
    @IsTest
    static void retrievePackagesTestInternal() {
        List<Package__c> lstPackages = [SELECT Id FROM Package__c LIMIT 1];
        
        Test.startTest();
        
        String strUserRole = PackageElementsViewerController.getCurrentUserRole();
        String strData = PackageElementsViewerController.getPackageElements(lstPackages[0].Id, strUserRole);

        List<PackageElement__c> lstPEs = [SELECT Id FROM PackageElement__c WHERE Required__c = TRUE LIMIT 10];
        System.AssertEquals(10, lstPEs.size(), 'Error in makeData(). Expected to have 10 Package Elements with Required flag = TRUE');
        List<PackageElementsViewerController.PackageElementWrapper> lstWrappers = (List<PackageElementsViewerController.PackageElementWrapper>)
                                                                                JSON.deserialize(
                                                                                    strData,
                                                                                    List<PackageElementsViewerController.PackageElementWrapper>.class
                                                                                );
        for(PackageElementsViewerController.PackageElementWrapper pew : lstWrappers) {
            pew.Required = false;
        }
        String strResult = PackageElementsViewerController.updatePackageElements(lstWrappers);
        
        Test.stopTest();

        lstPEs = [SELECT Id FROM PackageElement__c WHERE Required__c = FALSE LIMIT 10];
        System.AssertEquals(10, lstPEs.size(), 'Error in PackageElementsViewerController.updatePackageElements(). Expected to have 10 Package Elements with Required flag = FALSE');
    }

    @IsTest
    static void retrievePackagesTestDealer() {
        List<Package__c> lstPackages = [SELECT Id FROM Package__c LIMIT 1];
        String strUserRole = PackageElementsViewerController.getCurrentUserRole();
        String strData = PackageElementsViewerController.getPackageElements(lstPackages[0].Id, strUserRole);

        List<PackageElementsViewerController.PackageElementWrapper> lstWrappers = (List<PackageElementsViewerController.PackageElementWrapper>)
                                                                                JSON.deserialize(
                                                                                    strData,
                                                                                    List<PackageElementsViewerController.PackageElementWrapper>.class
                                                                                );
        for(PackageElementsViewerController.PackageElementWrapper pew : lstWrappers) {
            pew.VisibletoDealer = false;
        }
        String strResult = PackageElementsViewerController.updatePackageElements(lstWrappers);
        
        Test.startTest();

        String strDataForDealer = PackageElementsViewerController.getPackageElements(lstPackages[0].Id, 'dealer');
        lstWrappers = (List<PackageElementsViewerController.PackageElementWrapper>)
                    JSON.deserialize(
                        strDataForDealer,
                        List<PackageElementsViewerController.PackageElementWrapper>.class
                    );

        System.debug(lstWrappers.size());

        Test.stopTest();

        System.AssertEquals(TRUE, lstWrappers.isEmpty(), 'Package Elements visible to dealer even after attempting to update Visible to Dealer flag on Package Elements.');
    }
}