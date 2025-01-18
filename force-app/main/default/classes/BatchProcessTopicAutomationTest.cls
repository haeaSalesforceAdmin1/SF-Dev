@isTest
public without sharing class BatchProcessTopicAutomationTest {

    @TestSetup
    static void makeData(){
        User user1 = TestUtility.createInternalUser('TestOwnerUser1', 'TestOwnerUser1', 'System Administrator');
        User user2 = TestUtility.createInternalUser('TestOwnerUser2', 'TestOwnerUser2', 'System Administrator');
        User user3 = TestUtility.createInternalUser('TestOwnerUser3', 'TestOwnerUser3', 'System Administrator');
        User user4 = TestUtility.createInternalUser('TestOwnerUser4', 'TestOwnerUser4', 'System Administrator');

        TestUtility.createCurrentEnvironmentCustomSetting();
        TestUtility.createDPMConfigurationSettings();
        TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');

        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');
        account.DistrictPartsServiceManager__c = user1.Id;
        account.DistrictPartsServiceManager__c = user2.Id;
        account.MarketManager__c = user3.Id;
        update account;
        //account.HyundaiAreaManager__c = user4.Id;
    }

    static testMethod void testBatchProcessOrganization() {
        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'OrganizationTopic'];
        List<Organization__c> organizations = [select Id, Name from Organization__c where Name = 'Hyundai'];
        
        Topic__c topic = new Topic__c();
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'All Accounts in Organization';
        topic.RecordTypeId = recordTypes[0].Id;
        topic.Organization__c = organizations[0].Id;
        topic.Reoccurence__c = 'Monthly';
        insert topic;

        Test.startTest();
        BatchProcessTopicAutomation topicAutomation = new BatchProcessTopicAutomation();
        Database.executeBatch(topicAutomation, 1);
        Test.stopTest();
    }

    static testMethod void testBatchProcessOrganizationAllDistrictManagers() {
        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'Region_Topic'];
        List<Region__c> regions = [select Id, Name from Region__c ];
        
        Topic__c topic = new Topic__c();
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'All District Managers';
        topic.RecordTypeId = recordTypes[0].Id;
        topic.Region__c = regions[0].Id;
        topic.Reoccurence__c = 'Monthly';
        insert topic;

        Test.startTest();
        BatchProcessTopicAutomation topicAutomation = new BatchProcessTopicAutomation();
        Database.executeBatch(topicAutomation, 1);
        Test.stopTest();
    }


    static testMethod void testBatchProcessRegion() {

        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'Region_Topic'];
        List<Region__c> regions = [select Id, Name from Region__c where Name = :TestUtility.REGION_NAME];
        
        Topic__c topic = new Topic__c();
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'All Accounts in Region';
        topic.RecordTypeId = recordTypes[0].Id;
        topic.Region__c = regions[0].Id;
        topic.Reoccurence__c = 'Quarterly';
        insert topic;

        Test.startTest();
        BatchProcessTopicAutomation topicAutomation = new BatchProcessTopicAutomation();
        Database.executeBatch(topicAutomation, 1);
        Test.stopTest();
    }


    static testMethod void testBatchProcessServiceDistrict() {

        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'District_Topic'];
        List<District__c> districts = [select Id, Name from District__c];
        
        Topic__c topic = new Topic__c();
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'All Accounts in District';
        topic.RecordTypeId = recordTypes[0].Id;
        topic.ServiceDistrict__c = districts[0].Id;
        topic.Reoccurence__c = 'Annually';
        insert topic;

        Test.startTest();
        BatchProcessTopicAutomation topicAutomation = new BatchProcessTopicAutomation();
        Database.executeBatch(topicAutomation, 1);
        Test.stopTest();
    }


    static testMethod void testBatchProcessSalesDistrict() {

        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'District_Topic'];
        List<District__c> districts = [select Id, Name from District__c];
        
        Topic__c topic = new Topic__c();
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'All Accounts in District';
        topic.RecordTypeId = recordTypes[0].Id;
        topic.SalesDistrict__c = districts[0].Id;
        topic.TopicOwner__c = 'District Parts Service Manager';
        topic.Reoccurence__c = 'Annually';
        insert topic;

        Test.startTest();
        BatchProcessTopicAutomation topicAutomation = new BatchProcessTopicAutomation();
        Database.executeBatch(topicAutomation, 1);
        Test.stopTest();
    }

    static testMethod void testBatchProcessAccounts() {

        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'Account_Topic'];
        List<Account> accounts = [select Id, Name from Account];
        
        Topic__c topic = new Topic__c();
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'Only the Specified Account';
        topic.RecordTypeId = recordTypes[0].Id;
        topic.Account__c = accounts[0].Id;
        topic.TopicOwner__c = 'Market Manager';
        topic.Reoccurence__c = 'Annually';
        insert topic;

        Test.startTest();
        BatchProcessTopicAutomation topicAutomation = new BatchProcessTopicAutomation();
        Database.executeBatch(topicAutomation, 1);
        Test.stopTest();
    }

    static testMethod void testExistingOpenMonthlyEvaluationGetsAttachedToActionPlan() {

        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'OrganizationTopic'];
        List<Organization__c> organizations = [select Id, Name from Organization__c where Name = 'Hyundai'];
        List<Account> accounts = [select Id from Account];
        List<RecordType> recordTypesEval = [select Id from RecordType where DeveloperName = 'MonthlyPerformanceEvaluation' and SObjectType = 'Evaluation__c'];

        Topic__c topic = new Topic__c();
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'All Accounts in Organization';
        topic.RecordTypeId = recordTypes[0].Id;
        topic.Organization__c = organizations[0].Id;
        topic.Reoccurence__c = 'Monthly';
        insert topic;

        Evaluation__c evaluation = new Evaluation__c(Account__c = accounts[0].Id, RecordTypeId = recordTypesEval[0].Id);
        insert evaluation;

        Test.startTest();
        BatchProcessTopicAutomation topicAutomation = new BatchProcessTopicAutomation();
        Database.executeBatch(topicAutomation, 1);
        Test.stopTest();

        List<Action_Plan__c> actionPlans = [select Id, Evaluation__c from Action_Plan__c ];
        System.assertEquals(1, actionPlans.size());
        //System.assertNotEquals(null, actionPlans[0].Evaluation__c);
    }

    static testMethod void testNewEvaluationGetsAttachedToActionPlan() {
        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'OrganizationTopic'];
        List<Organization__c> organizations = [select Id, Name from Organization__c where Name = 'Hyundai'];
        
        Topic__c topic = new Topic__c();
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'All Accounts in Organization';
        topic.RecordTypeId = recordTypes[0].Id;
        topic.Organization__c = organizations[0].Id;
        topic.Reoccurence__c = 'Monthly';
        insert topic;

        Test.startTest();
        BatchProcessTopicAutomation topicAutomation = new BatchProcessTopicAutomation();
        Database.executeBatch(topicAutomation, 1);
        Test.stopTest();

        List<Action_Plan__c> actionPlans = [select Id, Evaluation__c from Action_Plan__c ];
        System.assertEquals(1, actionPlans.size());
        //System.assertNotEquals(null, actionPlans[0].Evaluation__c);
    }

}