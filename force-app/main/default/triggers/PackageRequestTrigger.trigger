trigger PackageRequestTrigger on PackageRequest__c (before delete) {
    /*if(trigger.isDelete && trigger.isBefore){
        DNAMSDealerTriggerHandler.handleDelete(trigger.old);
    }*/
    Trigger_Framework.createHandler(PackageRequest__c.sObjectType);
}