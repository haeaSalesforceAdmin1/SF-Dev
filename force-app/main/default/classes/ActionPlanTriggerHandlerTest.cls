@isTest
public with sharing class ActionPlanTriggerHandlerTest {

    @TestSetup
    static void makeData(){
 		CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;
        User user1 = TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');
        User user2 = TestUtility.createInternalUser('TestOwnerUser2', 'TestOwnerUser2', 'System Administrator');
        // User user3 = TestUtility.createInternalUser('TestOwnerUser3', 'TestOwnerUser3', 'System Administrator');

        TestUtility.createOrganizations();
        List<Region__c> regions = TestUtility.createRegionsForOrganizations(TestUtility.HYUNDIA_ORG);
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, TestUtility.DEALER_CODE);

        ContactTriggerHandler.run = false;
        Contact contact = new Contact(AccountId = account.Id, LastName = 'TestL11', FirstName = 'TestF11', Email='test11@email.com');
        insert contact;

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id, PrimaryContact__c = contact.Id);
        insert eval;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL22', FirstName = 'TestF22', Email='test22@email.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL33', FirstName = 'TestF33', Email='test33@email.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        //account.GenesisAreaManager__c = contact.Id;
        account.DealerPrincipal__c = contact.Id;
        account.MarketManager__c = user2.Id;
       // account.GenesisAreaManager__c = user3.Id;
        account.Region__c = regions[0].Id;
        HMAObjectService.dbUpdate(account);

//        User user4 = TestUtility.createExternalUser(contacts[1].Id, 'TestF2', 'TestL2', 'DPM Partner Community (Hyundai)', 'DPM_AP_ExtRO/' + TestUtility.DEALER_CODE);

       // GenesisArea__c genArea = TestUtility.createGenesisArea('GMA SOUTH', 'GS', user2.Id, genOrg.Id);
        HyundaiArea__c hyundaiArea = TestUtility.createHyundaiArea('Test Hyundai Area', '234', hyundaiOrg.Id, regions[0].Id);

        //District__c genesisDistrict = new District__c(Name = 'SELECT SOUTH 2', Organization__c = genOrg.Id, GenesisArea__c = genArea.Id );
       // insert genesisDistrict;

       
    }


    static testMethod void testActionPlanTrigger() {
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        List<Account> accounts = [select Id from Account];
        List<User> users = [select Id from User];
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Account__c = accounts[0].Id, OwnerId = testOwnerUser.Id, FollowUpDate__c = System.now().date(), Organization__c = 'Hyundai', Division__c = 'Service');
        insert actionPlan;
    }

    static testMethod void testUpdateActionPlanHandler() {

        Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);

        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        Action_Plan__c actionPlan = new Action_Plan__c(Account__c = account.Id, OwnerId = testOwnerUser.Id);
        insert actionPlan;

        List<Action_Plan__c> actionPlans = [select Id, Organization__c, OrganizationRef__c, Region__c, SalesDistrictName__c, ServiceDistrictName__c, CreatedById, OwnerId from Action_Plan__c where Id = :actionPlan.Id];
        

        Test.startTest();
        actionPlans[0].OwnerId = testOwnerUser.Id;
        update actionPlans;

        actionPlans[0].OwnerId = actionPlans[0].CreatedById;
        update actionPlans;
        Test.stopTest();
    }

    static testMethod void testEvaluationPriaryContact() {

        List<Organization__c> organization = [select Id from Organization__c where Name = :TestUtility.GENESIS_ORG ];
      //  List<GenesisArea__c> genesisAreas = [select Id from GenesisArea__c]; 
        List<District__c> genesisDistricts = [select Id from District__c where Name = 'SELECT SOUTH 2']; 


    //     Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);
    //     account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
    //    // account.GenesisArea__c = genesisAreas[0].Id;
    //    // account.Market__c = genesisDistricts[0].Id;
    //     update account;

    //     // Contact contact = [select Id from Contact where LastName = 'TestL22' limit 1];


        List<Evaluation__c> evals = [select Id, Account__c, PrimaryContactUserId__c from Evaluation__c];
//        System.debug(LoggingLevel.ERROR, evals);
//        System.assertNotEquals(null, evals[0].PrimaryContactUserId__c);


        Test.startTest();

        Action_Plan__c actionPlan = new Action_Plan__c(Account__c = evals[0].Account__c, Evaluation__c = evals[0].Id);
        insert actionPlan;

        Test.stopTest();
    }

    static testMethod void testUpdateActionPlanHandlerForHyundaiDealer() {

        List<Organization__c> organization = [select Id from Organization__c where Name = :TestUtility.GENESIS_ORG ];
        // List<GenesisArea__c> genesisAreas = [select Id from GenesisArea__c];
        List<District__c> genesisDistricts = [select Id from District__c where Name = 'SELECT SOUTH 2'];


        Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);
        account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
        // account.GenesisArea__c = genesisAreas[0].Id;
        // account.Market__c = genesisDistricts[0].Id;
        update account;
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser']; //DPM-5411 testOwnerUser를 AP의 owner 로 넣어서 read 권한 줌.

        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', OwnerId =testOwnerUser.Id, Organization__c = 'Hyundai', Account__c = account.Id,  RegionRef__c = account.Region__c);
        insert actionPlan;

        List<Action_Plan__c> actionPlans = [select Id, Organization__c, OrganizationRef__c, Region__c, SalesDistrictName__c, ServiceDistrictName__c, CreatedById, OwnerId from Action_Plan__c where Id = :actionPlan.Id];
        
        // actionPlans[0].OwnerId = testOwnerUser.Id;
        actionPlans[0].ApprovalStatus__c='Submitted for District Approval';
        update actionPlans;

        Test.startTest();

        actionPlans[0].OwnerId = actionPlans[0].CreatedById;
        actionPlans[0].DistrictManager__c = actionPlans[0].CreatedById;
        actionPlans[0].Organization__c = 'Hyundai';
        actionPlans[0].ApprovalStatus__c='District Approved';
        update actionPlans;

        Test.stopTest();
    }

    static testMethod void testUpdateActionPlanHandlerForHyundaiDealer2() {

        List<Organization__c> organization = [select Id from Organization__c where Name = :TestUtility.GENESIS_ORG ];
        // List<GenesisArea__c> genesisAreas = [select Id from GenesisArea__c];
        List<District__c> genesisDistricts = [select Id from District__c where Name = 'SELECT SOUTH 2'];


        Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);
        account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
        // account.GenesisArea__c = genesisAreas[0].Id;
        // account.Market__c = genesisDistricts[0].Id;
        update account;

        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Organization__c = 'Hyundai', Account__c = account.Id,  RegionRef__c = account.Region__c);
        insert actionPlan;

        Test.startTest();

        List<Action_Plan__c> actionPlans = [select Id, Organization__c, OrganizationRef__c, Region__c, SalesDistrictName__c, ServiceDistrictName__c, CreatedById, OwnerId from Action_Plan__c where Id = :actionPlan.Id];
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];

        actionPlans[0].OwnerId = testOwnerUser.Id;
        actionPlans[0].DistrictManager__c = actionPlans[0].CreatedById;
        actionPlans[0].ApprovalStatus__c='Submitted for District Approval';
        update actionPlans;

        Test.stopTest();
    }

    static testMethod void testUpdateActionPlanHandlerForGenesisDealer() {

        List<Organization__c> organization = [select Id from Organization__c where Name = :TestUtility.GENESIS_ORG ];
        // List<GenesisArea__c> genesisAreas = [select Id from GenesisArea__c];
        List<District__c> genesisDistricts = [select Id from District__c where Name = 'SELECT SOUTH 2'];


        Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);
        account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
        // account.GenesisArea__c = genesisAreas[0].Id;
        // account.Market__c = genesisDistricts[0].Id;
        update account;

        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', OwnerId = testOwnerUser.Id, Organization__c = 'Genesis', Division__c = 'Sales', Account__c = account.Id,  RegionRef__c = account.Region__c);
        insert actionPlan;

        Test.startTest();

        List<Action_Plan__c> actionPlans = [select Id, Organization__c, OrganizationRef__c, Region__c, SalesDistrictName__c, ServiceDistrictName__c, CreatedById, OwnerId from Action_Plan__c where Id = :actionPlan.Id];
        

        actionPlans[0].OwnerId = testOwnerUser.Id;
        actionPlans[0].MarketManager__c = actionPlans[0].CreatedById;
        actionPlans[0].ApprovalStatus__c='Submitted for District Approval';
        update actionPlans;

        Test.stopTest();
    }

    static testMethod void testUpdateActionPlanHandlerForGenesisDealer2() {

        List<Organization__c> organization = [select Id from Organization__c where Name = :TestUtility.GENESIS_ORG ];
      // List<GenesisArea__c> genesisAreas = [select Id from GenesisArea__c]; 
        List<District__c> genesisDistricts = [select Id from District__c where Name = 'SELECT SOUTH 2']; 


        Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);
        account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
       // account.GenesisArea__c = genesisAreas[0].Id;
       // account.Market__c = genesisDistricts[0].Id;
        update account;
        
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser']; //DPM-5411 Added testOwnerUser, OwnerId = testOwnerUser.Id, 
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', OwnerId = testOwnerUser.Id, Organization__c = 'Genesis', Account__c = account.Id,  RegionRef__c = account.Region__c);
        insert actionPlan;

        Test.startTest();

        List<Action_Plan__c> actionPlans = [select Id, Organization__c, OrganizationRef__c, Region__c, SalesDistrictName__c, ServiceDistrictName__c, CreatedById, OwnerId from Action_Plan__c where Id = :actionPlan.Id];
        // User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser']; DPM-5411 changed to comments

        actionPlans[0].OwnerId = testOwnerUser.Id;
        actionPlans[0].Is_Region_Sent_Back__c = true;
        actionPlans[0].ApprovalStatus__c='Sent Back To Dealer';
        update actionPlans;

        Test.stopTest();
    }

    static testMethod void testUndelete() {
        Action_PlanTriggerHandler triggerHandler = new Action_PlanTriggerHandler();
        triggerHandler.afterUndelete(null);
    }

    static testMethod void testActionPlanTriggerWithRunFalse() {
        Action_PlanTriggerHandler.run = false;
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        List<Account> accounts = [select Id, Region__c from Account];
        List<User> users = [select Id from User];
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Account__c = accounts[0].Id, OwnerId = testOwnerUser.Id, RegionRef__c = accounts[0].Region__c);
        insert actionPlan;
        Action_PlanTriggerHandler.run = true;
        Test.startTest();
        delete actionPlan;
        Test.stopTest();

    }

    static testMethod void testCalculateActionPlanSharingBatch() {
        Action_PlanTriggerHandler.run = false;
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        
        List<Account> accounts = [select Id, Region__c, RegionCodePicklist__c, ServiceDistrictCodePicklist__c, SalesDistrictCode__c, ServiceDistrict__c, SalesDistrict__c from Account];
        List<User> users = [select Id from User];
        System.debug(LoggingLevel.ERROR, accounts[0].Region__c);
        System.debug(LoggingLevel.ERROR, accounts[0].SalesDistrictCode__c);
        System.debug(LoggingLevel.ERROR, accounts[0].ServiceDistrictCodePicklist__c);
        
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Account__c = accounts[0].Id,  RegionRef__c = accounts[0].Region__c, RegionCode__c = accounts[0].RegionCodePicklist__c, ServiceDistrict__c = accounts[0].ServiceDistrict__c);
        actionPlan.ServiceDistrictCode__c = accounts[0].ServiceDistrictCodePicklist__c;
        actionPlan.SalesDistrict__c = accounts[0].SalesDistrict__c;
        actionPlan.SalesDistrictCode__c = accounts[0].SalesDistrictCode__c;
        insert actionPlan;

        Action_PlanTriggerHandler.run = true;

        Map<Id, Action_Plan__c> actionPlansMap = new Map<Id, Action_Plan__c>([select Id, RegionRef__c, RegionCode__c, SalesDistrictCode__c, ServiceDistrictCode__c, SalesDistrict__c, ServiceDistrict__c from Action_Plan__c]);
        
        Test.startTest();
        BatchProcessObjectShares batchObjecShares = new BatchProcessObjectShares();
        batchObjecShares.type = 'Action Plan';
        batchObjecShares.objectIds = actionPlansMap.keySet();
        Database.executeBatch(batchObjecShares, 1);
        Test.stopTest();
    }



    static testMethod void testCalculateActionPlanSharingBatch2() {
        Action_PlanTriggerHandler.run = false;
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        
        List<Account> accounts = [select Id, Region__c, RegionCodePicklist__c, ServiceDistrictCodePicklist__c, SalesDistrictCode__c, ServiceDistrict__c, SalesDistrict__c from Account];
        List<User> users = [select Id from User];
        System.debug(LoggingLevel.ERROR, accounts[0].Region__c);
        System.debug(LoggingLevel.ERROR, accounts[0].SalesDistrictCode__c);
        System.debug(LoggingLevel.ERROR, accounts[0].ServiceDistrictCodePicklist__c);
        
        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Account__c = accounts[0].Id,  RegionRef__c = accounts[0].Region__c, RegionCode__c = accounts[0].RegionCodePicklist__c, ServiceDistrict__c = accounts[0].ServiceDistrict__c);
        actionPlan.ServiceDistrictCode__c = accounts[0].ServiceDistrictCodePicklist__c;
        actionPlan.SalesDistrict__c = accounts[0].SalesDistrict__c;
        actionPlan.SalesDistrictCode__c = accounts[0].SalesDistrictCode__c;
        insert actionPlan;

        Action_PlanTriggerHandler.run = true;

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        apexSharing.add(actionPlan, users[0].Id, 'Edit', Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
        apexSharing.share();

        Map<Id, Action_Plan__c> actionPlansMap = new Map<Id, Action_Plan__c>([select Id, RegionRef__c, RegionCode__c, SalesDistrictCode__c, ServiceDistrictCode__c, SalesDistrict__c, ServiceDistrict__c from Action_Plan__c]);
        
        Test.startTest();
        BatchProcessObjectShares batchObjecShares = new BatchProcessObjectShares();
        batchObjecShares.type = 'Action Plan';
        batchObjecShares.objectIds = actionPlansMap.keySet();
        Database.executeBatch(batchObjecShares, 1);
        Test.stopTest();
    }

    static testMethod void testProcessKPICalculationsForActionsPlans() {
        Test.startTest();
        KPI__c kpi = TestUtility.createKPI('TestKPI');
        EinsteinKPI__c einsteinKPI = TestUtility.createAPEinsteinKPI('TestKPI', kpi.Id);

        List<Account> accounts = [select Id, Region__c from Account];
        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c from EinsteinKPI__c where Active__c = true];

        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label1_Value_Num__c');
        insert mapping;
        
        KPIThreshold__c threshold = new KPIThreshold__c(KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPIMapping__c = mapping.Id, ActualObjectiveComparator__c = 'greater than', 
                                                            AbsoluteValueNumber__c = 122, EndDate__c = Date.today().addDays(30), EffectiveDate__c = Date.today().addDays(-30), 
                                                            Account__c = accounts[0].Id, AutoGenerateActionPlanForFailure__c = true);
        insert threshold;

        Evaluation__c evaluation = new Evaluation__c(Account__c = accounts[0].Id);
        insert evaluation;

        Action_Plan__c actionPlan = new Action_Plan__c(Evaluation__c = evaluation.Id, KPI__c = einsteinKPIs[0].KPI__c, Account__c = accounts[0].Id);
        insert actionPlan;

        Map<Id, Action_Plan__c> actionPlanMap= new Map<Id, Action_Plan__c>();
        actionPlanMap.put(actionPlan.Id, actionPlan);

        // Test.startTest();
        ActionPlanTriggerHelper.processKPICalculationsForActionsPlans(actionPlanMap);
        Test.stopTest();
    }

    // [TBD] query limit 012225
    static testMethod void testProcessKPICalculationsForActionsPlans2() {
        Test.startTest();
        KPI__c kpi = TestUtility.createKPI('TestKPI');
        EinsteinKPI__c einsteinKPI = TestUtility.createAPEinsteinKPI('TestKPI', kpi.Id);

        List<Account> accounts = [select Id, Region__c from Account];
        List<EinsteinKPI__c> einsteinKPIs = [select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c,KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, ActualObjectiveComparator__c, 
                                                KPI__r.Category__c, KPI__r.SubCategory__c, TotalSAQLsToExecute__c from EinsteinKPI__c where Active__c = true];

        EinsteinKPIMapping__c mapping = new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIs[0].Id, Key_Value__c = true, Type__c = 'Number', Object_Field__c = 'Label1_Value_Num__c');
        insert mapping;
        
        KPIThreshold__c threshold = new KPIThreshold__c(KPI__c = einsteinKPIs[0].KPI__c, EinsteinKPIMapping__c = mapping.Id, ActualObjectiveComparator__c = 'greater than', 
                                                            AbsoluteValueNumber__c = 122, EndDate__c = Date.today().addDays(30), EffectiveDate__c = Date.today().addDays(-30), 
                                                            Account__c = accounts[0].Id, AutoGenerateActionPlanForFailure__c = true);
        insert threshold;

        Evaluation__c evaluation = new Evaluation__c(Account__c = accounts[0].Id);
        insert evaluation;


        Action_PlanTriggerHandler.run = false;
        Action_Plan__c actionPlan = new Action_Plan__c(Evaluation__c = evaluation.Id, KPI__c = einsteinKPIs[0].KPI__c, Account__c = accounts[0].Id);
        insert actionPlan;

        Map<Id, Action_Plan__c> newActionPlanMap = new Map<Id, Action_Plan__c>();
        Map<Id, Action_Plan__c> oldActionPlanMap = new Map<Id, Action_Plan__c>();
        actionPlan.RefreshKPI__c = false;
        oldActionPlanMap.put(actionPlan.Id, actionPlan);
        Action_Plan__c newActionPlan = new Action_PLan__c(Id = actionPlan.Id, KPI__c = einsteinKPIs[0].KPI__c);
        newActionPlan.RefreshKPI__c = true;
        newActionPlanMap.put(newActionPlan.Id, newActionPlan);
        Action_PlanTriggerHandler.run = true;
        // Test.startTest();
                ActionPlanTriggerHelper.processKPICalculationsForActionsPlans(newActionPlanMap);

        ActionPlanTriggerHelper.processRefreshKPICalculationsForActionsPlans(newActionPlanMap, oldActionPlanMap );
        Test.stopTest();
    }
    
    // [TBD] query limit 012225
    // private static testMethod void testCarryOver(){
    //     Test.startTest();
    // //    List<Organization__c> organization = [select Id from Organization__c where Name = :TestUtility.GENESIS_ORG ];
    // //    // List<GenesisArea__c> genesisAreas = [select Id from GenesisArea__c]; 
    // //     List<District__c> genesisDistricts = [select Id from District__c where Name = 'SELECT SOUTH 2']; 

    // //     Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);
    // //     account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
    // //    // account.GenesisArea__c = genesisAreas[0].Id;
    // //     //account.Market__c = genesisDistricts[0].Id;
    // //     update account;

    //     Contact contact = [select Id , AccountId from Contact where LastName = 'TestL22' limit 1];
    //     Survey__c surveyTemplate = new Survey__c();
    //     surveyTemplate.IsTemplate__c = TRUE;
    //     surveyTemplate.EndDate__c = System.now().date().addDays(92);
    //     surveyTemplate.Evaluation_Date__c = System.now().date().addDays(60);
    //     insert surveyTemplate;

    //     Survey__c survey = new Survey__c(Dealer__c = contact.AccountId, ApexJobId__c = '1', SurveyTemplate__c = surveyTemplate.Id);
    //     survey.EndDate__c = System.now().date().addDays(92);
    //     insert survey;

    //     Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3', Response__c = 'No',Question_Number_Text__c='1');
    //     insert surveyQuestion;

        

    //     Evaluation__c eval = new Evaluation__c(Account__c = contact.AccountId, PrimaryContact__c = contact.Id, survey__c = survey.Id);
    //     insert eval;

    //     List<Evaluation__c> evals = [select Id, PrimaryContactUserId__c from Evaluation__c];

    //     Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Account__c = contact.AccountId,   Evaluation__c = evals[0].Id); //RegionRef__c = account.Region__c,
    //     insert actionPlan;
    //     // Test.startTest();

    //     actionPlan.Is_Carry_Over_Button_Clicked__c = TRUE;
    //     // actionPlan.Status__c = 'Carry Over';
    //     actionPlan.HMASurveyQuestion__c = surveyQuestion.Id;
    //     actionPlan.DueDate__c = System.now().date().addDays(90) ;
        
    //     update actionPlan;

    //     Test.stopTest();
    // }

    private static testMethod void testRegionApproved(){
        Test.startTest();
        List<Organization__c> organization = [select Id from Organization__c where Name = :TestUtility.GENESIS_ORG ];
        // List<GenesisArea__c> genesisAreas = [select Id from GenesisArea__c];
        List<District__c> genesisDistricts = [select Id from District__c where Name = 'SELECT SOUTH 2'];

        Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);
        account.RecordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Account', 'GenesisRetailer');
        // account.GenesisArea__c = genesisAreas[0].Id;
        //account.Market__c = genesisDistricts[0].Id;
        update account;

        Survey__c surveyTemplate = new Survey__c();
        surveyTemplate.IsTemplate__c = TRUE;
        surveyTemplate.EndDate__c = System.now().date().addDays(92);
        surveyTemplate.Evaluation_Date__c = System.now().date().addDays(60);
        insert surveyTemplate;

        Survey__c survey = new Survey__c(Dealer__c = account.Id, ApexJobId__c = '1', SurveyTemplate__c = surveyTemplate.Id);
        survey.EndDate__c = System.now().date().addDays(92);
        insert survey;

        Contact contact = [select Id from Contact where LastName = 'TestL22' limit 1];

        Evaluation__c eval = new Evaluation__c(Account__c = account.Id, PrimaryContact__c = contact.Id, survey__c = survey.Id);
        insert eval;

        List<Evaluation__c> evals = [select Id, PrimaryContactUserId__c from Evaluation__c];

        Action_Plan__c actionPlan = new Action_Plan__c(Name = 'Test Action Plan', Account__c = account.Id,  RegionRef__c = account.Region__c, Evaluation__c = evals[0].Id);
        insert actionPlan;

        // Test.startTest();

        actionPlan.Status__c = 'Region Approved';
        update actionPlan;

        Test.stopTest();
    }
  /*  private static testMethod void testBatchRollOverCarryOverAPToNextQuarter(){
        
       List<Organization__c> organization = [select Id from Organization__c where Name = :TestUtility.GENESIS_ORG ];
        List<GenesisArea__c> genesisAreas = [select Id from GenesisArea__c]; 
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

           Test.startTest();
        update actionPlan;
        
        BatchRollOverCarryOverAPToNextQuarter batchObjecShares = new BatchRollOverCarryOverAPToNextQuarter('');
     
        Database.executeBatch(batchObjecShares, 1);
        Test.stopTest();
        System.assert(actionPlan != NULL);
    }*/
    static testMethod void testActionPlanService7() {
        Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);

        List<Contact> contacts = [SELECT Id FROM Contact];

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        List<User> users = [SELECT Id FROM User WHERE Name like '%Test%'];
        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;
		
        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        //[TBD] query limit 012225
        // actionPlans.add(new Action_Plan__c(Name = 'Test Action Plan123', Original_Partner_User_ID__c= users[0].Id,Organization__c= 'Hyundai',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = users[0].Id, DistrictSalesManager__c = users[1].Id, MarketManager__c = users[1].Id, ApprovalStatus__c = 'Submitted for District Approval'));
        // actionPlans.add(new Action_Plan__c(Name = 'Test Action Plan12', Original_Partner_User_ID__c= users[0].Id,Organization__c= 'Genesis',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = users[0].Id, DistrictSalesManager__c = users[1].Id, MarketManager__c = users[1].Id, ApprovalStatus__c = 'Submitted for District Approval'));
        // end
        actionPlans.add(new Action_Plan__c(Name = 'Test Action Plan1',Division__c='Service', Original_Partner_User_ID__c= users[0].Id,Organization__c= 'Genesis',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = users[0].Id, DistrictSalesManager__c = users[1].Id, Aftersales_Market_Manager__c = users[1].Id, ApprovalStatus__c = 'Submitted for District Approval'));
        actionPlans.add(new Action_Plan__c(Name = 'Test Action Plan2',Division__c='Sales', Original_Partner_User_ID__c= users[0].Id,Organization__c= 'Genesis',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = users[0].Id, DistrictSalesManager__c = users[1].Id, MarketManager__c = users[1].Id, ApprovalStatus__c = 'Submitted for District Approval'));
        insert actionPlans;
        Test.startTest();
        Action_PlanTriggerHandler.run = true;
        actionPlans[0].ApprovalStatus__c = 'District Approved';
        actionPlans[1].ApprovalStatus__c = 'Sent Back To Dealer';
        // actionPlans[2].ApprovalStatus__c = 'District Approved'; [TBD] query limit 012225
        // actionPlans[3].ApprovalStatus__c = 'District Approved'; [TBD] query limit 012225
        update actionPlans;

        Test.stopTest();
    }
    /*static testmethod void testContact(){
        
    //For contact coverage
    	Action_PlanTriggerHandler.run = false;
        
        //List<Account> accounts = [select Id, Region__c, RegionCodePicklist__c, ServiceDistrictCodePicklist__c, SalesDistrictCode__c, ServiceDistrict__c, SalesDistrict__c from Account];
        List<User> users = [select Id from User where LastName = 'TestL2'];
        
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([select Id, account.Region__c, account.RegionCodePicklist__c,account.SalesDistrictCode__c, account.ServiceDistrict__c, account.SalesDistrict__c, account.ServiceDistrictCodePicklist__c from Contact]);
        
        Test.startTest();
        BatchProcessObjectShares batchObjecShares = new BatchProcessObjectShares();
        batchObjecShares.type = 'Contact';
        batchObjecShares.objectIds = contactsMap.keySet();
        Database.executeBatch(batchObjecShares, 1);
        Test.stopTest();
		//
    }*/
    static testmethod void testBatchProcessObjectShares(){
        BatchProcessObjectShares BatchProcess = new BatchProcessObjectShares();
    }
     //[TBD] query limit 012225
    // static testmethod void testCallEvaluation(){
    //     Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);

    //     List<Contact> contacts = [SELECT Id FROM Contact];

    //     Survey__c survey = new Survey__c(Dealer__c = account.Id);
    //     insert survey;

    //     Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
    //     insert evaluation;

    //     List<Id> listEvaluationIds = new List<Id>();
    //     listEvaluationIds.add(evaluation.Id);

    //     Action_Plan__c objActionPlan = new Action_Plan__c(Name = 'Test Action Plan123',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant');
    //     insert objActionPlan;

    //     Test.startTest();
    //     ActionPlanTriggerHelper.handleActionPlanApprovalChange(listEvaluationIds);
    //     Test.stopTest();
    // }

     //[TBD] query limit 012225
    // static testmethod void testCallEvaluationStatus(){
    //     Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);

    //     List<Contact> contacts = [SELECT Id FROM Contact];

    //     Survey__c survey = new Survey__c(Dealer__c = account.Id);
    //     insert survey;

    //     Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
    //     insert evaluation;

    //     List<Id> listEvaluationIds = new List<Id>();
    //     listEvaluationIds.add(evaluation.Id);

    //     Action_Plan__c objActionPlan = new Action_Plan__c(Name = 'Test Action Plan123',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant');
    //     insert objActionPlan;

    //     Test.startTest();
    //     Action_Plan__c objUpActionPlan = [SELECT Name, Evaluation__c, Account__c, Status__c, ApprovalStatus__c FROM Action_Plan__c WHERE Name = 'Test Action Plan123'];
    //     Action_PlanTriggerHandler.run = false;
    //     objUpActionPlan.ApprovalStatus__c = 'Submitted for Regional Approval';
    //     update objUpActionPlan;
    //     Action_PlanTriggerHandler.run = true;
    //     Test.stopTest();
    // }

    static testMethod void testUpdateActionPlanHandlerNotInsert() {

        Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);
        User testOwnerUser = [select Id from User where LastName = 'TestOwnerUser'];
        Action_Plan__c actionPlan = new Action_Plan__c(Account__c = account.Id, OwnerId = testOwnerUser.Id);
        insert actionPlan;

        List<Action_Plan__c> actionPlans = [select Id, Organization__c, OrganizationRef__c, Region__c, SalesDistrictName__c, ServiceDistrictName__c, CreatedById, OwnerId from Action_Plan__c where Id = :actionPlan.Id];
        

        Test.startTest();
        Action_PlanTriggerHandler.isInserting = false;
        actionPlans[0].OwnerId = actionPlans[0].CreatedById;
        update actionPlans;
        Test.stopTest();
    }

    static testMethod void testActionPlanService6() {
        Account account = TestUtility.getAccountByName(TestUtility.DEALER_NAME);

        List<Contact> contacts = [SELECT Id FROM Contact];

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        List<User> users = [SELECT Id FROM User WHERE Name like '%Test%'];
        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id, PrimaryContact__c = contacts[0].Id);
        insert evaluation;
		
        Action_PlanTriggerHandler.run = false;
        List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
        actionPlans.add(new Action_Plan__c(Name = 'Test Action Plan123',Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = users[0].Id, DistrictSalesManager__c = users[1].Id, MarketManager__c = users[1].Id/*, GenesisAreaManager__c = user4.Id*/));
     //   insert actionPlans;
        Action_PlanTriggerHandler.run = true;
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Started';
        actionPlans[0].HasDealerSummary__c=true;
        actionPlans[0].HasActionPlanFile__c=true;
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Started';
        actionPlans[0].HasDealerSummary__c=true;
        actionPlans[0].HasActionPlanFile__c=false;
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Started';
        actionPlans[0].HasDealerSummary__c=true;
        actionPlans[0].HasActionPlanFile__c=false;
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null); actionPlans[0].Phase__c='Completed';
        actionPlans[0].Status__c='Compliant';
        Test.startTest(); ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Completed';
        actionPlans[0].Status__c='Non-Compliant';
        
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        actionPlans[0].Phase__c='Completed';
        actionPlans[0].Status__c='Non-Compliant1';
        ActionPlanTriggerHelper.UpdateDealerIndicator(actionPlans, null);
        Test.stopTest();
    }
}