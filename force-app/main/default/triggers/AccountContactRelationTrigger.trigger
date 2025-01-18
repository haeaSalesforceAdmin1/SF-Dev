trigger AccountContactRelationTrigger on AccountContactRelation (after update) {
    if(Trigger.isAfter && Trigger.isUpdate) {
        //DPM-5979 issue #3 and issue#5 - Comment out the newly created ACR Trigger by Areum - 12-11-2024
        //AccountContactRelationTriggerHandler.updateContactDNAMSRole(Trigger.new);
        //AccountContactRelationTriggerHandler.handleDNAMSAccessUpdate(Trigger.new, Trigger.oldMap);
    }
}