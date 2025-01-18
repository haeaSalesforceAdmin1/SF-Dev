@IsTest
private class DNAMStandardProvisionsToDealerTest {
    private static final String HYUNDAI_ORG = 'Hyundai';
    private static final String DEALER_NAME = 'UTOPIA MOUNTAIN SUNRISE HYUNDAI';
    private static final String DISTRICT_NAME = 'ATLANTA';
    private static final String REGION_NAME = 'SOUTHERN REGION';
    private static final String REGION_CODE = 'SO';
    private static final String DEALER_CODE = 'GA999';
    
	@TestSetup
    static void setupData() {
        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations(HYUNDAI_ORG);
        TestUtility.createDistrictsForRegions();
        District__c district = TestUtility.getDistrict(DISTRICT_NAME, REGION_NAME, HYUNDAI_ORG);
        Account dealer = DNAMSPackageTestDataFactory.createNewDealer(DEALER_NAME, DEALER_CODE, district, REGION_CODE);

        Package__c pack = DNAMSPackageTestDataFactory.createNewPackage(dealer.Id);
		
        ContentVersion contentVer = new ContentVersion(
            Title = 'COPP_Tracker_Letter_',
            VersionData = Blob.valueOf('Test Content Data'),
            PathOnClient= 'COPP_Tracker_Letter_.pdf'
        );
        insert contentVer;
        
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion];
        ContentDocument cd  = [SELECT Id, Title FROM ContentDocument WHERE Id = : cv.ContentDocumentId];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = pack.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;
        
    }
    
    @IsTest static void testCopyFileToAccountMethod() {
        Package__c packageRec = [SELECT Id,Dealer__c FROM Package__c LIMIT 1];
        
        List<DNAMStandardProvisionsToDealerForClosure.InvocableInput> inputList = new List<DNAMStandardProvisionsToDealerForClosure.InvocableInput>();
        DNAMStandardProvisionsToDealerForClosure.InvocableInput input = new DNAMStandardProvisionsToDealerForClosure.InvocableInput();
        ContentDocument cd  = [SELECT Id, Title FROM ContentDocument Limit 1];
        input.recordId = packageRec.Id;
        input.accountId = packageRec.Dealer__c;
        input.contentDocuementId = cd.Id;
        inputList.add(input);
        DNAMStandardProvisionsToDealerForClosure.copyFileToAccount(inputList);
		List<ContentDocumentLink> conDocLink = [select LinkedEntity.Type, LinkedEntityId from contentDocumentLink where  LinkedEntityId =: packageRec.Dealer__c];
		System.assertEquals(conDocLink.size(),1,'File should be attached to the Dealer');         
    }
    
}