@isTest(SeeAllData=true)
public class DNAMSAgreementDocumentsControllerTest {
    
    private static final String DEALER_REQUEST = 'Dealer Request';
    private static final String OBJECT_NAME = 'Package__c';
    private static final String STATUS_FIELD_NAME = 'Status__c';
    
    @IsTest
    static void testGetRelatedFilesByRecordId() {
        
        Account acc = [Select Id From Account Where Id=: System.Label.DNAMSAccountId];
        System.debug('BRBRBR=testGetPackagesForRelated()=acc='+acc);
        
        DNAMSAgreementDocumentsController.allowForTest = true;
        Test.startTest();
            String result= DNAMSAgreementDocumentsController.getRelatedFilesByRecordId(acc.Id);
            System.assertNotEquals(result, null, 'Should be able to get the Files for perticular dealer.');
        Test.stopTest();
    }
}