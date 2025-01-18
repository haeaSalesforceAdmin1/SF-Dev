public with sharing class TopicTriggerHelper {

    public static void handleBeforeInsertTopic(List<Topic__c> topics) {

        for(Topic__c topic:topics) {
            topic.NextRunDate__c = HMATopicService.calculateNextRunDate(topic);
        }
    }

    public static void handleBeforeUpdateTopic(List<Topic__c> topics) {

        for(Topic__c topic:topics) {
            if(topic.LastRunDate__c != null) {
                topic.NextRunDate__c = HMATopicService.calculateNextRunDate(topic);
            }
        }
    }
}