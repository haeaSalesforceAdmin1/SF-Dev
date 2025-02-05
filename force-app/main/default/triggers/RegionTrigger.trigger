trigger RegionTrigger on Region__c (before update, after update) {
     Trigger_Framework.createHandler(Region__c.sObjectType);
}