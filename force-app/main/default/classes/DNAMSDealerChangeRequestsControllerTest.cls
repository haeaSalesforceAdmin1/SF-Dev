@isTest(SeeAllData=true)
public class DNAMSDealerChangeRequestsControllerTest {
    private static final String DEALER_REQUEST = 'Dealer Request';
    private static final String OBJECT_NAME = 'PackageRequest__c';
    private static final String STATUS_FIELD_NAME = 'Status__c';
    
    @IsTest
    static void testGetRecordType() {
        Test.startTest();
            String recordTypeId = DNAMSDealerChangeRequestsController.getRecordTypeId(DEALER_REQUEST);
            System.assertNotEquals(recordTypeId, null, 'Record Id should not be blank.');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetPicklistValues() {
        Test.startTest();
            Map<String,String> picklistValues = DNAMSDealerChangeRequestsController.getPicklistValues(OBJECT_NAME, STATUS_FIELD_NAME);
            System.assertNotEquals(picklistValues.size(), 0, 'Should be able to get the Status picklist values.');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetDealerChangeRequestsForRelatedList() {
        Account acc = [Select Id From Account Where Id=: System.Label.DNAMSAccountId];
        System.debug('BRBRBR=testGetDealerChangeRequestsForRelatedList()=acc='+acc);
        
        DNAMSDealerChangeRequestsController.allowForTest = true;
        Test.startTest();
            String result= DNAMSDealerChangeRequestsController.getDealerChangeRequestsForRelatedList(acc.Id);
            System.assertNotEquals(result, null, 'Should be able to get the Dealer Change Requests records for perticular dealer.');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetDealerChangeRequests() {
        DNAMSDealerChangeRequestsController.allowForTest = true;
        Test.startTest();
            String result= DNAMSDealerChangeRequestsController.getDealerChangeRequests();
            System.assertNotEquals(result, null, 'Should be able to get the All Dealer Change Requests records.');
        Test.stopTest();
    }
}