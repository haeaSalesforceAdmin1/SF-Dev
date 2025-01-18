/*
Note: Code Coverage Error: Need to populate the System.Label.DNAMSAccountId & System.Label.DNAMSContactId on the Target Org sample data
*/
@isTest(SeeAllData=true)
public class DNAMSPackagesControllerTest {
    private static final String DEALER_REQUEST = 'Dealer Request';
    private static final String OBJECT_NAME = 'Package__c';
    private static final String STATUS_FIELD_NAME = 'Status__c';
    
    @IsTest
    static void testGetPackagesForRelated() {
        
        Account acc = [Select Id From Account Where Id=: System.Label.DNAMSAccountId];
        System.debug('BRBRBR=testGetPackagesForRelated()=acc='+acc);
        Package__c pa=new Package__c();
        pa.Type__c = 'Dealer principal change';
        pa.Classification__c = 'Major';
        pa.Description__c = 'This is sample package';
        pa.PackageDetail__c = 'New Dealer';
        pa.Sequence__c = 3;
        pa.Status__c = 'RMR Returned';
        pa.Dealer__c = acc.Id;
        //pa.ScanPkg__c = false;
        insert pa; 

        DNAMSPackagesController.allowForTest = true;
        Test.startTest();
            String result= DNAMSPackagesController.getPackagesForRelated(acc.Id);
            System.assertNotEquals(result, null, 'Should be able to get the Packages for perticular dealer.');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetPackages() {
        Account acc = [Select Id From Account Where Id=: System.Label.DNAMSAccountId];
        DNAMSPackagesController.allowForTest = true;
        Package__c pa=new Package__c();
        pa.Type__c = 'Dealer principal change';
        pa.Classification__c = 'Major';
        pa.Description__c = 'This is sample package';
        pa.PackageDetail__c = 'New Dealer';
        pa.Sequence__c = 3;
        pa.Status__c = 'Initiated';
        pa.Dealer__c = acc.Id;
        //pa.ScanPkg__c = false;
        insert pa; 
        Test.startTest();
            String result= DNAMSPackagesController.getPackages();
            System.assertNotEquals(result, null, 'Should be able to get the All Packages records.');
        Test.stopTest();
    }

}