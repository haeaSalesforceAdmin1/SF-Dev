@isTest
public without sharing class BatchProcessTopicSurveyAutomationTest {

    @TestSetup
    static void makeData(){
        TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');
        


        TestUtility.createDPMConfigurationSettings();
        TestUtility.createCurrentEnvironmentCustomSetting();

        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();
        TestUtility.createQuarterlySettings();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL1', FirstName = 'TestF1', Email = 'TestE1@Test.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email = 'TestE2@Test.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        User userGM = TestUtility.createExternalUser(contacts[0].Id, 'TestL1', 'TestF1', 'DPM Partner Community (Hyundai)');
        //User userDP = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');
        User userDP = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)', '');
        
        account.GeneralManager__c = contacts[0].Id;
        account.DealerPrincipal__c = contacts[1].Id;
        account.Active__c = true;
        update account;

        List<RecordType> recordTypes = [select Id from RecordType where RecordType.DeveloperName = 'Survey_Topic'];
        List<Organization__c> organizations = [select Id, Name from Organization__c where Name = 'Hyundai'];
    }

    static testMethod void testSurveyBatchProcessForSurvey() {

        List<RecordType> surveyRecordTypes = [select Id from RecordType where DeveloperName = 'HyundaiSalesSurveyTemplate' and SobjectType = 'Survey__c'];

        Survey__c templateSurvey = new Survey__c(Name = 'Test Survey Template', IsTemplate__c = true, RecordTypeId = surveyRecordTypes[0].Id);
        insert templateSurvey;

        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'Survey_Topic' and SobjectType = 'Topic__c'];
        List<Organization__c> organizations = [select Id, Name from Organization__c where Name = 'Hyundai'];

        Topic__c topic = new Topic__c(RecordTypeId = recordTypes[0].Id);
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'All Accounts in Organization';
        topic.CreateEvaluation__c = 'Yes';
        topic.Organization__c = organizations[0].Id;
        topic.HMASurvey__c = templateSurvey.Id;
        topic.RecordTypeId = recordTypes[0].Id;
        insert topic;

        List<Topic__c> topics = [select Id, NextRunDate__c from Topic__c];
        System.assertEquals(topics[0].NextRunDate__c, Date.today());

        Test.startTest();
        BatchProcessTopicSurveyAutomation surveyAutomation = new BatchProcessTopicSurveyAutomation();
        Database.executeBatch(surveyAutomation, 1);
        Test.stopTest();
    }
    
    

    static testMethod void testSurveyBatchProcessForSurveyAssignedToDealerPrincipal() {

        List<RecordType> surveyRecordTypes = [select Id from RecordType where DeveloperName = 'HyundaiServiceSurveyTemplate' and SobjectType = 'Survey__c'];

        Survey__c templateSurvey = new Survey__c(Name = 'Test Survey Template', IsTemplate__c = true, RecordTypeId = surveyRecordTypes[0].Id);
        insert templateSurvey;

        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'Survey_Topic' and SobjectType = 'Topic__c'];
        List<Organization__c> organizations = [select Id, Name from Organization__c where Name = 'Hyundai'];

        Topic__c topic = new Topic__c(RecordTypeId = recordTypes[0].Id);
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'All Accounts in Organization';
        topic.CreateEvaluation__c = 'Yes';
        topic.TopicOwner__c = 'District Manager';
        topic.Organization__c = organizations[0].Id;
        topic.HMASurvey__c = templateSurvey.Id;
        topic.RecordTypeId = recordTypes[0].Id;
        insert topic;
        
        List<Topic__c> topics = [select Id, NextRunDate__c from Topic__c];
        System.assertEquals(topics[0].NextRunDate__c, Date.today());

        Test.startTest();
        BatchProcessTopicSurveyAutomation surveyAutomation = new BatchProcessTopicSurveyAutomation();
        Database.executeBatch(surveyAutomation, 1);
        Test.stopTest();
    }

    static testMethod void testSurveyBatchProcessForSurveyAssignedToGeneralManager() {

        List<RecordType> surveyRecordTypes = [select Id from RecordType where DeveloperName = 'HyundaiServiceSurveyTemplate' and SobjectType = 'Survey__c'];

        Survey__c templateSurvey = new Survey__c(Name = 'Test Survey Template', IsTemplate__c = true, RecordTypeId = surveyRecordTypes[0].Id);
        insert templateSurvey;

        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = 'Survey_Topic' and SobjectType = 'Topic__c'];
        List<Organization__c> organizations = [select Id, Name from Organization__c where Name = 'Hyundai'];

        Topic__c topic = new Topic__c(RecordTypeId = recordTypes[0].Id);
        topic.Topic_Start_Date__c = Date.today();
        topic.Topic_End_Date__c = Date.today().addDays(1);
        topic.CreateRecordsFor__c = 'All Accounts in Organization';
        topic.CreateEvaluation__c = 'Yes';
        topic.TopicOwner__c = 'Market Manager';
        topic.Organization__c = organizations[0].Id;
        topic.HMASurvey__c = templateSurvey.Id;
        insert topic;
        
        List<Topic__c> topics = [select Id, NextRunDate__c from Topic__c];
        System.assertEquals(topics[0].NextRunDate__c, Date.today());

        Test.startTest();
        BatchProcessTopicSurveyAutomation surveyAutomation = new BatchProcessTopicSurveyAutomation();
        Database.executeBatch(surveyAutomation, 1);
        Test.stopTest();
    }

}