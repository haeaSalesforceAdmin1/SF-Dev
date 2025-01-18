@isTest
public with sharing class TopicTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        TestUtility.createTopic('Test Topic', Date.today(), Date.today().addDays(1));
    }

    static testMethod void testTopicTriggerHandlerInsertUpdate() {

        List<Topic__c> topics = [select Id from Topic__c];
        System.assertEquals(1, topics.size());

        update topics;
    }

    static testMethod void testTopicTriggerHandlerDelete() {

        List<Topic__c> topics = [select Id from Topic__c];
        System.assertEquals(1, topics.size());

        delete topics;
    }

    static testMethod void testTopicTriggerHandlerUnDelete() {
        TopicTriggerHandler topicTriggerHandler = new TopicTriggerHandler();
        topicTriggerHandler.afterUndelete(null);
    }

}