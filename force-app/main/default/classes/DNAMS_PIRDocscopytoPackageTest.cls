@IsTest
private class DNAMS_PIRDocscopytoPackageTest {
    private static final String HYUNDAI_ORG = 'Hyundai';
    private static final String DEALER_NAME = 'UTOPIA MOUNTAIN SUNRISE HYUNDAI';
    private static final String DISTRICT_NAME = 'ATLANTA';
    private static final String REGION_NAME = 'SOUTHERN REGION';
    private static final String REGION_CODE = 'SO';
    private static final String DEALER_CODE = 'GA999';
    
    @IsTest
    static void setupData() {
        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations(HYUNDAI_ORG);
        TestUtility.createDistrictsForRegions();
        District__c district = TestUtility.getDistrict(DISTRICT_NAME, REGION_NAME, HYUNDAI_ORG);
       //Account dealer = DNAMSPackageTestDataFactory.createNewDealer(DEALER_NAME, DEALER_CODE, district, REGION_CODE);  
           Account dealer = new Account(Name = 'Test Account '+ DateTime.now());
        //create a package
        //Package__c pack = DNAMSPackageTestDataFactory.createNewPackage(dealer.Id);
        insert dealer;
                Package__c pack = new Package__c();
        pack.Dealer__c = dealer.id;
        pack.RecordTypeId = Schema.Package__c.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('DefaultPackage').recordTypeId;
        pack.Status__c = 'Initiated';
        insert pack;
        
        
        //create package-element related to package
        //PackageElement__c pkgele1 = DNAMSPackageTestDataFactory.getNewPackageElement(pack.id,dealer.id);
        PackageElement__c pkgele1 = new PackageElement__c();
        pkgele1.Name = 'DSSA or Amendment';
        pkgele1.Package__c = pack.id;
        pkgele1.Dealer__c = dealer.id;
        pkgele1.VisibletoDealer__c = true;
        pkgele1.Required__c = true;
        insert pkgele1;
        //PackageElement__c pkgele2 = DNAMSPackageTestDataFactory.getNewPackageElement(pack.id,dealer.id);
        PackageElement__c pkgele2 = new PackageElement__c();
        pkgele2.Name = 'DSSA or Amendment';
        pkgele2.Package__c = pack.id;
        pkgele2.Dealer__c = dealer.id;
        pkgele2.VisibletoDealer__c = true;
        pkgele2.Required__c = true;
        insert pkgele2;
        //PackageElement__c pkgele3 = DNAMSPackageTestDataFactory.getNewPackageElement(pack.id,dealer.id);
        PackageElement__c pkgele3 = new PackageElement__c();
        pkgele3.Name = 'Miscellaneous Documents';
        pkgele3.Package__c = pack.id;
        pkgele3.Dealer__c = dealer.id;
        pkgele3.VisibletoDealer__c = true;
        pkgele3.Required__c = true;
        insert pkgele3;
        //create a PIR
        Package_Initiation__c pir = new Package_Initiation__c();
                     pir.PIR_Type__c ='Successor';
                     pir.Dealer_Name__c = dealer.id;
                     pir.PIR_Status__c ='Draft';
                     pir.Name ='test';
        insert pir;
        //create a PIRElement
        List<PIR_Element__c> pireleList = new List<PIR_Element__c>{
            new PIR_Element__c(Name = 'DI Sheet of Dealer',Mapped_Package_Element__c ='DSSA or Amendment',PIR__c = pir.id),
            new PIR_Element__c(Name = 'PIR Summary Form',Mapped_Package_Element__c ='DSSA or Amendment Copy',PIR__c = pir.id),
            new PIR_Element__c(Name = 'Application',Mapped_Package_Element__c ='',PIR__c = pir.id)
        };
        insert pireleList;
        
        List<string> pkgeleListstring = new List<string>();
        pkgeleListstring.add(pkgele1.id);
        pkgeleListstring.add(pkgele2.id);
        pkgeleListstring.add(pkgele3.id);
        
        List<string> PIReleListstring = new List<string>();
        PIReleListstring.add(pireleList[0].id);
        PIReleListstring.add(pireleList[1].id);
        PIReleListstring.add(pireleList[2].id);
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test';
        cv1.PathOnClient = 'Test.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;

        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = pireleList[0].id;
        cdl1.ContentDocumentId = conDocId1;
        cdl1.shareType = 'V';
        Insert cdl1;
        
                ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Test1';
        cv2.PathOnClient = 'Test1.pdf';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;
        Insert cv2;
        
        Id conDocId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv2.Id].ContentDocumentId;

        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = pireleList[1].id;
        cdl2.ContentDocumentId = conDocId2;
        cdl2.shareType = 'V';
        Insert cdl2;
        
                ContentVersion cv3 = new ContentVersion();
        cv3.Title = 'Test';
        cv3.PathOnClient = 'Test.pdf';
        cv3.VersionData = Blob.valueOf('Test Content');
        cv3.IsMajorVersion = true;
        Insert cv3;
        
        Id conDocId3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv3.Id].ContentDocumentId;

        ContentDocumentLink cdl3 = New ContentDocumentLink();
        cdl3.LinkedEntityId = pireleList[2].id;
        cdl3.ContentDocumentId = conDocId3;
        cdl3.shareType = 'V';
        Insert cdl3;
        
        Package_Initiation__c pirnew = new Package_Initiation__c();
                     pirnew.PIR_Type__c ='Successor';
                     pirnew.Dealer_Name__c = dealer.id;
                     pirnew.PIR_Status__c ='cleared';
                     pirnew.id = pir.id;
        update pirnew;
        
        
        List<DNAMS_PIRDocscopytoPackage.InputsPassed> irInputs = new List<DNAMS_PIRDocscopytoPackage.InputsPassed>();
               DNAMS_PIRDocscopytoPackage.InputsPassed irInputs2 = new DNAMS_PIRDocscopytoPackage.InputsPassed();
                     irInputs2.PIRElements = PIReleListstring;
                     irInputs2.PackageElements = pkgeleListstring;
                     irInputs.add(irInputs2);
        DNAMS_PIRDocscopytoPackage.DNAMS_PIRDocscopytoPackagemethod(irInputs);
          
    }
}