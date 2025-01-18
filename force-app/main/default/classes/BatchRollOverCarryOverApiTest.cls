@isTest
public class BatchRollOverCarryOverApiTest {

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
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, TestUtility.DEALER_CODE);

        ContactTriggerHandler.run = false;
        Contact contact = new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test1@email.com');
        insert contact;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='test3@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        //account.GenesisAreaManager__c = contact.Id;
        account.DealerPrincipal__c = contact.Id;
        account.MarketManager__c = user2.Id;
       //account.GenesisAreaManager__c = user3.Id;
        HMAObjectService.dbUpdate(account);

        User user4 = TestUtility.createExternalUser(contacts[1].Id, 'TestF2', 'TestL2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRO/' + TestUtility.DEALER_CODE);

       // GenesisArea__c genArea = TestUtility.createGenesisArea('GMA SOUTH', 'GS', user2.Id, genOrg.Id);
        HyundaiArea__c hyundaiArea = TestUtility.createHyundaiArea('Test Hyundai Area', '234', hyundaiOrg.Id, regions[0].Id);

        //District__c genesisDistrict = new District__c(Name = 'SELECT SOUTH 2', Organization__c = genOrg.Id, GenesisArea__c = genArea.Id );
       // insert genesisDistrict;
    }
    
    private static testMethod void testBatchRollOverCarryOverAPToNextQuarter(){
        
       List<Organization__c> organization = [select Id from Organization__c where Name = :TestUtility.GENESIS_ORG ];
      //  List<GenesisArea__c> genesisAreas = [select Id from GenesisArea__c]; 
        List<District__c> genesisDistricts = [select Id from District__c where Name = 'SELECT SOUTH 2']; 


        Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);
        account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
       // account.GenesisArea__c = genesisAreas[0].Id;
        //account.Market__c = genesisDistricts[0].Id;
        update account;
        
        System.assert(account != NULL);
        
        Survey__c surveyTemplate = new Survey__c();
        surveyTemplate.IsTemplate__c = TRUE;
        surveyTemplate.EndDate__c = System.now().date().addDays(92);
        surveyTemplate.Evaluation_Date__c = System.now().date().addDays(60);
        insert surveyTemplate;
		
		        Survey__c surveyTemplate1= new Survey__c();
        surveyTemplate1.IsTemplate__c = TRUE;
        surveyTemplate1.EndDate__c = System.now().date().addDays(192);
        surveyTemplate1.Evaluation_Date__c = System.now().date().addDays(150);
        insert surveyTemplate1;        
        System.assert(surveyTemplate != NULL);

        Survey__c survey = new Survey__c(Dealer__c = account.Id, ApexJobId__c = '1', SurveyTemplate__c = surveyTemplate.Id);
        survey.EndDate__c = System.now().date().addDays(92);
        insert survey;
        Survey__c survey1 = new Survey__c(Dealer__c = account.Id, ApexJobId__c = '1', SurveyTemplate__c = surveyTemplate1.Id);
        survey1.EndDate__c = System.now().date().addDays(92);
        insert survey1;
        
        System.assert(survey != NULL);
         Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey1.Id, Table_Columns__c = 'Test1;Test2;Test3', Response__c = 'No',Question_Number_Text__c='1');
        insert surveyQuestion;
        
        Contact contact = [select Id from Contact where LastName = 'TestL2' limit 1];

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id, PrimaryContact__c = contact.Id, survey__c = survey1.Id);
        eval.EndDate__c=System.now().date().addDays(50);
        eval.StartDate__c = System.now().date().addDays(52);
        insert eval;

        List<Evaluation__c> evals = [select Id, PrimaryContactUserId__c from Evaluation__c];
        
        System.assertNotEquals(null, evals[0].PrimaryContactUserId__c);

        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Account__c = account.Id,  RegionRef__c = account.Region__c, Evaluation__c = evals[0].Id);
        insert actionPlan;
        
        System.assert(actionPlan != NULL);
        actionPlan.RelatedSurvey__c=survey.id;
        actionPlan.Is_Carry_Over_Button_Clicked__c = TRUE;
        actionPlan.Status__c = 'Carry Over';
        actionPlan.DueDate__c = System.now().date().addDays(90) ;
                actionPlan.EndDate__c = System.now().date().addDays(92) ;
        actionPlan.Question_Failed__c='1';
        actionPlan.ApprovalStatus__c = 'District Approved';

           Test.startTest();
        update actionPlan;
        SchedulerRollOverCarryOverAPToNextQtr sc = new SchedulerRollOverCarryOverAPToNextQtr();
        system.schedule('test', '0 0 0 ? * * *', sc);
       // BatchRollOverCarryOverAPToNextQuarter batchObjecShares = new BatchRollOverCarryOverAPToNextQuarter('');
     
       // Database.executeBatch(batchObjecShares, 1);
        Test.stopTest();
        System.assert(actionPlan != NULL);
        
    }

}