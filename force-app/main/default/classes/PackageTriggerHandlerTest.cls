@IsTest
 public class PackageTriggerHandlerTest {
     @IsTest
     static void testCDLVisibilityForCommunity() {
                 
        Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
        
        Contact c = new Contact(); //Insert contact for email
        c.FirstName = 'TestFirstname';
        c.LastName = 'TestLastname';
        c.Email = 'test3423423@gmail.com';
        insert c;
        APXTConga4__Conga_Template__c congt = new APXTConga4__Conga_Template__c();
        congt.DNA_Email_List__c = 'test323@gmail.com';
        insert congt;

        Package__c pac = new Package__c();
        pac.Dealer__c = acc.id;
        pac.RecordTypeId = Schema.Package__c.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('PackageTemplate').recordTypeId;
        pac.Status__c = 'Active';
        insert pac;

        PackageElement__c pacEle = new PackageElement__c();
        pacEle.Package__c = pac.id;
        pacEle.Dealer__c = acc.id;
        pacEle.VisibletoDealer__c = true;
        pacEle.Required__c = true;
        pacEle.Conga_Template__c = congt.id;
        insert pacEle;

        Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
        p.PackageTemplate__c = pac.id;
        update p;
        PackageElement__c pe = DNAMSPackageTestDataFactory.createNewPackageElement(p.Id, acc.Id);
        pe.TemplatePackageElement__c = pacEle.id;
        update pe;
        
        Test.startTest();
        ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(p.Id);
        ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pe.Id);
        List<ContentVersion> lstCVs = new List<ContentVersion>();
        lstCVs.add(cv1);
        lstCVs.add(cv2);
        
        insert lstCVs;
        p.status__c = 'Closed';
        update p;
     }
 
 
 }