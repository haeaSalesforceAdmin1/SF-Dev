/**
* @Created date 
* @Last updated date : 02-28-2025
* @description 
* History
* 1.1 Created
* 1.2 Edited by [Minhee Kim] on [12-11-2023] for [DPM-4454]
* 1.3 Edited by [Minhee Kim] on [04-26-2024] for [DPM-5400] added to change primary contact on eval when original one is deleted 
* 1.4 Edited by [Minhee Kim] on [06-28-2024] for [DPM-5613] Added deleteInactiveACR(newMap, oldMap);
* 1.5 Edited by [Areum Lee] on [12-11-2024] for [DPM-5979] Added the condition 'DNAMS_Active_User__c' 
* 1.6 Edited by [Minhee Kim] on [02-10-2025] for [DPM-6020] Changed to comment not to run DNAMSUserProvisioningServiceQueueable
* 1.7 Edited by [Minhee Kim] on [02-27-2025] for [DPM-6118] change the logic not to run compare accesstype when accesstype is not changed
*/
public class ContactTriggerHandler extends Trigger_Framework.baseHandler {

    public static Boolean run = true;
    public static boolean runByUserTrigger=false; //DPM-4454 Created to run contact trigger by MinheeKim - 2023-12-13

    public override void beforeInsert(List<SObject> newListGeneric){
        if(!run) {
            return;
        }
        List<Contact> newList = (List<Contact>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        
        /*BEFORE INSERT METHODS END*/
    }

    
    /**
     * [Method Description] Update for deleted access type  
     * Edited by [Minhee kim] on [2023-12-11] for [DPM-4454]
     * Edited by [Minhee Kim] on [02-28-2025] for [DPM-6118] Edit condition to run beforeupdate
    */
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        System.debug('Contact beforeupdate started');
        Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
        Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        if(runByUserTrigger || Test.isRunningTest()){ //DPM-6118
            ContactTriggerHelper.updateAccountId(newMap, oldMap);
        }
        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        if(!(run || runByUserTrigger)) {
            return;
        }
        Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/
        //DPM-5400 added to change primary contact on eval when original one is deleted by Minhee Kim - 24.04.26
        ContactTriggerHelper.changePrimaryContactOnEval(oldMap.values());
        /*BEFORE DELETE METHODS END*/
    }

    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        ContactTriggerHelper.handleExternalSharingForContacts(newMap.values());
        /*AFTER INSERT METHODS END*/
    }

    /**
     * [Method Description] ContactTriggerHandler after update
     * Edited by [Minhee Kim] on [02-10-2025] for [DPM-6020] Changed to comment not to run DNAMSUserProvisioningServiceQueueable
    */
    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
        Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/
        List<Contact> usersWithActiveFlagChecked = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), new Set<String> {'Active_DPM_User__c'}, true, false); //DPM-5301 changed from DPMActiveUser__c to Active_DPM_User__c by MinheeKim - 2024.05.29
        List<Contact> usersWithActiveFlagUnchecked = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), new Set<String> {'Active_DPM_User__c'}, false, true);
		//DPM-5979 Added the condition 'DNAMS_Active_User__c' by Areum - 12-11-2024
        List<Contact> usersWithDNAMSActiveFlagChecked = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), new Set<String> {'DNAMS_Active_User__c'}, true, false); //DNAMS PIR
        List<Contact> usersWithDNAMSActiveFlagUnchecked = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), new Set<String> {'DNAMS_Active_User__c'}, false, true);

        
        List<Contact> contactsToProcessSharing = new List<Contact>();
        contactsToProcessSharing.addAll(usersWithActiveFlagChecked);
        contactsToProcessSharing.addAll(usersWithActiveFlagUnchecked);
        //DPM-5979 Added the condition 'DNAMS_Active_User__c' by Areum - 12-11-2024
        contactsToProcessSharing.addAll(usersWithDNAMSActiveFlagChecked);
        contactsToProcessSharing.addAll(usersWithDNAMSActiveFlagUnchecked);


        ContactTriggerHelper.handleExternalSharingForContacts(contactsToProcessSharing);
        //ContactTriggerHelper.updateDNAMSActiveUser(newMap, oldMap); //Changed to comment not to run DNAMSUserProvisioningServiceQueueable
        ContactTriggerHelper.deleteInactiveACR(newMap, oldMap); //DPM-5613 Added by MinheeKim - 2024.06.28
       
        /*AFTER UPDATE METHODS END*/
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/

        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}