@isTest
public with sharing class EvaluationTriggerHandlerTest {

    
    @TestSetup
    static void makeData(){
       CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        insert CE;
        User user1 = TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');
        User user2 = TestUtility.createInternalUser('TestOwnerUser2', 'TestOwnerUser2', 'System Administrator');
        User user3 = TestUtility.createInternalUser('TestOwnerUser3', 'TestOwnerUser3', 'System Administrator');

        TestUtility.createOrganizations();
        List<Region__c> regions = TestUtility.createRegionsForOrganizations(TestUtility.HYUNDIA_ORG);
      // List<Region__c> regions1 = TestUtility.createRegionsForOrganizations(TestUtility.GENESIS_ORG);

        List<District__c> districts = TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);
        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, TestUtility.DEALER_CODE);
        ContactTriggerHandler.run = false;
        Contact contact = new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test@email.com');
        insert contact;

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL1', FirstName = 'TestF1', Email='test1@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='test2@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        //account.GenesisAreaManager__c = contact.Id;
        account.DealerPrincipal__c = contact.Id;
        account.MarketManager__c = user2.Id;
       // account.GenesisAreaManager__c = user3.Id;
        account.Region__c = regions[0].Id;
        HMAObjectService.dbUpdate(account);

        User user4 = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');

      //  GenesisArea__c genArea = TestUtility.createGenesisArea('GMA SOUTH', 'GS', user2.Id, genOrg.Id);
        HyundaiArea__c hyundaiArea = TestUtility.createHyundaiArea('Test Hyundai Area', '234', hyundaiOrg.Id, regions[0].Id);

        //District__c genesisDistrict = new District__c(Name = 'SELECT SOUTH 2', Organization__c = genOrg.Id, GenesisArea__c = genArea.Id );
        //insert genesisDistrict;
        Evaluation__c eval = new Evaluation__c(Name='GenesisEval',Account__c = account.Id, Organization__c = 'Genesis', Type__c='Service',MarketManager__c=user1.Id,OwnerId=user2.Id);
        insert eval;

        
        ContentVersion cv = new Contentversion();
        cv.title='COPP_Tracker_Letter_';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.VersionData = b;
        insert cv;


        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = account.Id;

        insert cdl;
    }

    static testMethod void testEvaluationHandler() {

        Account account = [select Id, Organization__c, Organization__r.Name from Account];
        User user = [select Id from User where LastName = 'TestOwnerUser' limit 1];
        Test.startTest();
        Evaluation__c eval = new Evaluation__c(Account__c = account.Id, OwnerId = user.Id);
        insert eval;
        Test.stopTest();

        List<Evaluation__c> evals = [select Id, Organization__c, OrganizationRef__c, Region__c, SalesDistrictName__c, ServiceDistrictName__c from Evaluation__c where Id = :eval.Id];
        System.assertEquals(1, evals.size());
        System.assertEquals(account.Organization__c, evals[0].OrganizationRef__c);
        System.assertEquals(account.Organization__r.Name, evals[0].Organization__c);
        System.assertEquals(TestUtility.REGION_NAME, evals[0].Region__c);
        System.assertEquals(TestUtility.SALES_DISTRICT_NAME, evals[0].SalesDistrictName__c);
        System.assertEquals(TestUtility.SERVICE_DISTRICT_NAME, evals[0].ServiceDistrictName__c);
    }

    static testMethod void testUpdateEvaluationHandlerCompliant() {

        Account account = [select Id from Account];

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id);
        insert eval;

        List<Evaluation__c> evals = [select Id, Organization__c, OrganizationRef__c, Region__c, SalesDistrictName__c, ServiceDistrictName__c, CreatedById, OwnerId, Aftersales_Market_Manager__c from Evaluation__c where Id = :eval.Id];
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];

        Test.startTest();
        evals[0].OwnerId = evals[0].CreatedById;
        evals[0].ApprovalStatus__c = 'District Approved';
        update evals;
        Test.stopTest();
    }

    static testMethod void testUpdateEvaluationHandler() {

        Account account = [select Id from Account];
        User user = [select Id from User where LastName = 'TestOwnerUser' limit 1];
        User dealer = [select Id from User where LastName = 'TestF2' limit 1];
        Evaluation__c eval = new Evaluation__c(Account__c = account.Id, Organization__c = 'Hyundai', DistrictManager__c=user.Id, AssignedDealer__c=dealer.Id);
        insert eval;

        List<Evaluation__c> evals = [select Id, Organization__c, OrganizationRef__c, Region__c, SalesDistrictName__c, ServiceDistrictName__c, CreatedById, OwnerId, Aftersales_Market_Manager__c from Evaluation__c where Id = :eval.Id];
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];

        Test.startTest();
        evals[0].OwnerId = testOwnerUser.Id;
        evals[0].ApprovalStatus__c = 'Not Submitted';
        update evals;

        evals[0].OwnerId = evals[0].CreatedById;
        evals[0].ApprovalStatus__c = 'Submitted for District Approval';
        update evals;

        evals[0].ApprovalStatus__c = 'Sent Back';
        update evals;

        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Organization__c='Hyundai',Evaluation__c = evals[0].Id, Account__c = account.Id, Status__c = 'Compliant', Division__c = 'Sales', RegionCode__c = 'SO',  Original_Partner_User_ID__c=dealer.Id , OwnerId=user.Id ));
        insert actionPlans;

        evals[0].Total_of_Related_Action_Plans__c=1;
        update evals;

        Test.stopTest();
    }

    static testMethod void testUpdateEvaluationHandler2() {

        Account account = [select Id from Account];
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        
        List<Evaluation__c> evals = [select Id, Organization__c, OrganizationRef__c, Region__c, SalesDistrictName__c, ServiceDistrictName__c, CreatedById, OwnerId, Aftersales_Market_Manager__c from Evaluation__c where Name = 'GenesisEval'];
        
        Test.startTest();
        HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');
        apexSharing.add(evals[0], testOwnerUser.Id, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
        apexSharing.share();
        
        evals[0].OwnerId = testOwnerUser.Id;
        evals[0].ApprovalStatus__c = 'Not Submitted';
        update evals;

        evals[0].OwnerId = evals[0].CreatedById;
        evals[0].ApprovalStatus__c = 'Submitted for District Approval';
        update evals;
        Test.stopTest();
    }

    static testMethod void testUpdateEvaluationHandlerForGenesisDealer() {
        Organization__c genesisOrg = TestUtility.getOrganization('Genesis');
       // GenesisArea__c genesisArea = new GenesisArea__c(Name = TestUtility.GENESIS_AREA, Organization__c = genesisOrg.Id);
       // insert genesisArea;
       Region__c regions = TestUtility.getRegion('SOUTHERN REGION',TestUtility.HYUNDIA_ORG);

        District__c genesisDistrict = New District__c(Name = 'SELECT SOUTH 2', Organization__c = genesisOrg.Id );
        insert genesisDistrict;
        Account accountGen = TestUtility.createAccountForDistrictRegionOrg('GenesisTest', TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.GENESIS_ORG, TestUtility.DEALER_CODE+1);
       
        Account account = [select Id from Account where name='GenesisTest' limit 1];
        account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
       // account.GenesisArea__c = genesisArea.Id;
        account.Market__c = genesisDistrict.Id;
        update account;

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id, Organization__c = 'Genesis', Type__c = 'Service');
        insert eval;

        List<Evaluation__c> evals = [select Id, MarketManager__c, CreatedById, OwnerId from Evaluation__c where Id = :eval.Id];
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];

        Test.startTest();
        evals[0].OwnerId = testOwnerUser.Id;
        update evals;

        evals[0].OwnerId = evals[0].CreatedById;
        evals[0].Organization__c = 'Genesis';
        evals[0].ApprovalStatus__c = 'Submitted for District Approval';
        evals[0].MarketManager__c = evals[0].CreatedById;
        update evals;

        Test.stopTest();
    }

    static testMethod void testDeleteForCoverage() {

        Account account = [select Id from Account];

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id);
        insert eval;

        delete eval;
   }
    
    static testMethod void testSharingBatch() {

        Account account = [select Id from Account];

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id);
        insert eval;

        Map<Id, Evaluation__c> evaluationMap = new Map<Id, Evaluation__c>([select Id from Evaluation__c]);

        Test.startTest();
        BatchProcessObjectShares objectShares = new BatchProcessObjectShares();
        objectShares.type = 'Evaluation';
        objectShares.objectIds  = evaluationMap.keySet();
        Database.executeBatch(objectShares, 2);
        Test.stopTest();
    }


    static testMethod void testChangePrimaryContact() {

        Account account = [select Id from Account];

        ContactTriggerHandler.run = false;
        Contact contact1 = new Contact(LastName='Test5', FirstName = 'Frent5', AccountId = account.Id, Email='test5@email.com');
        insert contact1;

        Contact contact2 = new Contact(LastName='Test6', FirstName = 'Frent6', AccountId = account.Id, Email='test6@email.com');
        insert contact2;
        ContactTriggerHandler.run = true;

        User user1 = TestUtility.createExternalUser(contact1.Id, 'Test1L', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        User user2 = TestUtility.createExternalUser(contact2.Id, 'Test1L2', 'TestF2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRE/A0001,DPM_Eval_ExtRead/A0001,DPM_SurvExtUsr/A0001');
        
//        User user1 = TestUtility.createExternalUser(contact1.Id, 'TestL5', 'TestF5', 'DPM Partner Community (Hyundai)');
//        User user2 = TestUtility.createExternalUser(contact2.Id, 'TestL6', 'TestF6', 'DPM Partner Community (Hyundai)');

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id, PrimaryContact__c = contact1.Id);
        insert eval;

        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Organization__c='Genesis',Evaluation__c = eval.Id, Account__c = account.Id, Status__c = 'Compliant', Division__c = 'Sales', RegionCode__c = 'SO',  Original_Partner_User_ID__c=user1.Id , OwnerId=user2.Id ));
        
        Action_PlanTriggerHandler.run = false;
        insert actionPlans;
        Action_PlanTriggerHandler.run = true;

        Test.startTest();
        eval.PrimaryContact__c = contact2.Id;
        update eval;
        Test.stopTest();

        /*EvaluationTriggerHandler.run = false;
        EvaluationContact__c evaluationContact = new EvaluationContact__c();
        evaluationContact.Evaluation__c = eval.Id;
        evaluationContact.Contact__c = contact1.Id;
        evaluationContact.IsPrimary__c = true;
        evaluationContact.Comments__c = 'Test';
        insert evaluationContact;*/



    }

     /**
     * [Method Description] COPP Project - Test class for testAttachTrackerOnEval
     * Created by [MinheeKim] on [2024-09-23] for [DPM-5709]
    */
    static testMethod void testAttachTrackerOnEval(){

        Account account = [SELECT Id FROM Account LIMIT 1];
        
        RecordType coppRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'COPP_Confidential' LIMIT 1];
        Evaluation__c coppEval = new Evaluation__c(Name='COPPEval',Account__c = account.Id, Organization__c = 'Genesis', Type__c='Service', RecordType=coppRecType);
        
        insert coppEval;

        COPPInfo__c coppInfo = new COPPInfo__c(Name='COPPInfo',Account__c = account.Id,COPP__c = true, Buy_Sell_COPP__c = true);
        insert coppInfo;

        List<Evaluation__c> testEvaluations = [SELECT Id, Account__c, RecordTypeId , DealerCode__c FROM Evaluation__c];

        Test.startTest();
        EvaluationTriggerHelper.attachTrackerOnEval(testEvaluations);
        Test.stopTest();
       
        
     }
	@isTest
    static void testEvaluationDPMRTopicChange() {
        // Step 1: Create a RecordType for Evaluation__c
        RecordType dpmrRecType = [SELECT Id FROM RecordType WHERE DeveloperName like '%DPMR%' LIMIT 1];
       

        // Step 2: Create a list of old evaluations
        Evaluation__c oldEvaluation = new Evaluation__c(
            Name = 'AL701 - Sales DPMR - Oct 2, 2024 - 2',
            RecordTypeId = dpmrRecType.Id,
            Topics_GmaSales__c = null,
            Topics_GmaService__c = 'Training',
            Topics_HmaSales__c ='BlueLink',
            Topics_HmaService__c = 'Commodities',
            PrimaryContactDate__c = Date.today()
        );
        insert oldEvaluation;

        Evaluation__c oldEvaluation2 = new Evaluation__c(
            Name = 'AL701 - Sales DPMR (FIN, SI) - Oct 2, 2024 - 5',
            RecordTypeId = dpmrRecType.Id,
            Topics_GmaSales__c = null,
            Topics_GmaService__c = null,
            Topics_HmaSales__c =null,
            Topics_HmaService__c = null,
            PrimaryContactDate__c = Date.today().addDays(-1)
        );
        insert oldEvaluation2;

        Evaluation__c oldEvaluation3 = new Evaluation__c(
            Name = 'AL701 - Sales DPMR - Oct 2, 2024 - 3',
            RecordTypeId = dpmrRecType.Id,
            Topics_GmaSales__c = null,
            Topics_GmaService__c = null,
            Topics_HmaSales__c =null,
            Topics_HmaService__c = null,
            PrimaryContactDate__c = Date.today().addDays(-2)
        );
        insert oldEvaluation3;

        Evaluation__c oldEvaluation4 = new Evaluation__c(
            Name = 'AL701 - Sales DPMR (FIN) - Oct 2, 2024 - 4',
            RecordTypeId = dpmrRecType.Id,
            Topics_GmaSales__c = null,
            Topics_GmaService__c = null,
            Topics_HmaSales__c =null,
            Topics_HmaService__c = null,
            PrimaryContactDate__c = Date.today().addDays(-3)
        );
        insert oldEvaluation4;

        // Step 3: Create a new evaluation with changed topics
        Evaluation__c newEvaluation = new Evaluation__c(
            Id = oldEvaluation.Id, // Use the same Id for the update
            Name = 'AL701 - Sales DPMR - Oct 2, 2024 - 1',
            RecordTypeId = dpmrRecType.Id,
            Topics_HmaSales__c = 'Financial Performance;Survey Integrity', // Changed topic
            Topics_GmaSales__c = null,
            Topics_GmaService__c = 'Financial Performance'
        );

        Evaluation__c newEvaluation2 = new Evaluation__c(
            Id = oldEvaluation2.Id, // Use the same Id for the update
            Name = 'AL701 - Sales DPMR - Oct 2, 2024 - 2',
            RecordTypeId = dpmrRecType.Id,
            Topics_HmaService__c = 'Survey Integrity', // Changed topic
            Topics_GmaSales__c = null,
            Topics_GmaService__c = null
        );

        Evaluation__c newEvaluation3 = new Evaluation__c(
            Id = oldEvaluation3.Id, // Use the same Id for the update
            Name = 'AL701 - Sales DPMR - Oct 2, 2024 - 3',
            RecordTypeId = dpmrRecType.Id,
            Topics_HmaSales__c = null,
            Topics_HmaService__c = null,
            Topics_GmaSales__c = null,
            Topics_GmaService__c = 'Financial Performance'
        );

        Evaluation__c newEvaluation4 = new Evaluation__c(
            Id = oldEvaluation4.Id, // Use the same Id for the update
            Name = 'AL701 - Sales DPMR (FIN) - Oct 2, 2024 - 3',
            RecordTypeId = dpmrRecType.Id,
            Topics_HmaSales__c = null,
            Topics_HmaService__c = null,
            Topics_GmaSales__c = '',
            Topics_GmaService__c = null
        );

        // Step 4: Create a map of old evaluations
        Map<Id, Evaluation__c> oldEvaluationsMap = new Map<Id, Evaluation__c>();
        oldEvaluationsMap.put(oldEvaluation.Id, oldEvaluation);
        oldEvaluationsMap.put(oldEvaluation2.Id, oldEvaluation2);
        oldEvaluationsMap.put(oldEvaluation3.Id, oldEvaluation3);
        oldEvaluationsMap.put(oldEvaluation4.Id, oldEvaluation4);

        // Step 5: Call the evaluationDPMRTopicChange method
        Test.startTest();
        List<Evaluation__c> newEvaluations = new List<Evaluation__c> { newEvaluation, newEvaluation2, newEvaluation3, newEvaluation4 };
        EvaluationTriggerHelper.evaluationDPMRTopicChange(newEvaluations, oldEvaluationsMap); // Call your method
        EvaluationTriggerHelper.preventDuplicateEvaluation(newEvaluations);
        Test.stopTest();

    }
    /*static testMethod void testChangePrimaryContactTwo() {

        Account account = [select Id from Account];

        Contact contact1 = new Contact(LastName='Test5', FirstName = 'Frent5', AccountId = account.Id);
        insert contact1;

        Contact contact2 = new Contact(LastName='Test6', FirstName = 'Frent6', AccountId = account.Id);
        insert contact2;

        User user1 = TestUtility.createExternalUser(contact1.Id, 'TestL5', 'TestF5', 'DPM Partner Community (Hyundai)');
        User user2 = TestUtility.createExternalUser(contact2.Id, 'TestL6', 'TestF6', 'DPM Partner Community (Hyundai)');

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id, PrimaryContact__c = contact1.Id);
        insert eval;


        EvaluationContact__c evaluationContact = new EvaluationContact__c();
        evaluationContact.Evaluation__c = eval.Id;
        evaluationContact.Contact__c = contact2.Id;
        evaluationContact.IsPrimary__c = true;
        evaluationContact.Comments__c = 'Test';
        insert evaluationContact;
    }*/

}