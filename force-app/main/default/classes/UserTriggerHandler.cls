public class UserTriggerHandler extends Trigger_Framework.baseHandler {

    public static boolean run = true;
    public static boolean runByUserTrigger = true; //DPM-4454 Created to run contact trigger by MinheeKim - 2023-12-13

    public override void beforeInsert(List<SObject> newListGeneric){
        if(!run) {
            return;
        }
        List<User> newList = (List<User>) newListGeneric;
        
        
        /*BEFORE INSERT METHODS START*/
        
        /*BEFORE INSERT METHODS END*/
    }

    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
       //System.debug('Dhiraj beforeUpdate User');
        if(!run) {
            return;
        }
        Map<Id, User> oldMap = (Map<Id, User>) oldMapGeneric;
        Map<Id, User> newMap = (Map<Id, User>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/

        /**
         * [Method Description] UserTriggerHelper  DNAMsIUActive
         * Created by [Jonghoon Kim] on [24.08.28] for [DPM-5754]
         * Edited by Areum on 11-01-2024 for DNAMS PIR
        */
        //UserTriggerHelper.DNAMsIUActive(oldMap, newMap);

        //* LJ: DPM-4846 DetachRole and Rest Accees Type
        UserTriggerHelper.detachRole(oldMap, newMap);
        UserTriggerHelper.blankAccessType(oldMap, newMap);

        //* JK : DPM-4944 FederationIdentifier
        UserTriggerHelper.blankFederationIdentifier(oldMap, newMap);
        
        //* SY: DPM-4944 Disable Portal for inactive users
        UserTriggerHelper.disablePortal(oldMap, newMap);
    

        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        if(!run) {
            return;
        }
        Map<Id, User> oldMap = (Map<Id, User>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/

        /*BEFORE DELETE METHODS END*/
    }

     /**
         * [Method Description] UserTriggerHandler  after insert
         * Created by 
         * Edited by [Minhee Kim] on [02-10-2025] for [DPM-6020] Changed to comment not to run DNAMSUserProvisioningServiceQueueable
         * Edited by [Minhee Kim] on [02-10-2025] for [DPM-6020] Consolidate DNAMS flag fields
        */
    public override void afterInsert(Map<Id, SObject> newMapGeneric){

        Map<Id, User> newMap = (Map<Id, User>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        
        UserTriggerHelper.handleProvisionFlagSetForUsers(newMap.values());
        UserTriggerHelper.updateAccessTypeOnContact(newMap.values(),NULL);
        UserTriggerHelper.updateUserAppType(newMap.values(),NULL);
        
        //Soyeon Kim Changes for DPM-4702
        UserTriggerHelper.updatePublicGroup(newMap.values());
        
        //UserTriggerHelper.updateDNAMSUserCheck(newMap); // Changed to comment not to run DNAMSUserProvisioningServiceQueueable by MinheeKim for DPM-6020 on 02-10-2025
        /*AFTER INSERT METHODS END*/

        // Edited by Areum on 11-01-2024 for DNAMS PIR
        //UserTriggerHelper.updateDNAMSRoleOnContact(newMap.values(), null);
    }

    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){

        if(!run) {
            return;
        }
        Map<Id, User> oldMap = (Map<Id, User>) oldMapGeneric;
        Map<Id, User> newMap = (Map<Id, User>) newMapGeneric;
        
        /*AFTER UPDATE METHODS START*/

        List<User> usersWithProvisionFlagChecked = Trigger_DiffRecord.getRecordsWithDiff(oldMap.values(), newMap.values(), new Set<String> {'Autoprovision__c'}, true, false);      
        if(!usersWithProvisionFlagChecked.isEmpty()) {
            UserTriggerHelper.handleProvisionFlagSetForUsers(usersWithProvisionFlagChecked);
        }
        //* SY: DPM-4944 delete contact for inactive users
        UserTriggerHelper.isInactivating(newMap.values());
        
        UserTriggerHelper.updateAccessTypeOnContact(newMap.values(),oldMap);
        //UserTriggerHelper.updateLoginHistoryTrack(newMap.values(),oldMap);
        UserTriggerHelper.updateUserAppType(newMap.values(),oldMap);
       // UserTriggerHelper.updateContactAccRelation(newMap.values(),oldMap);
        
        //Soyeon Kim Changes for DPM-4702
        UserTriggerHelper.updatePublicGroup(newMap.values());
        /*AFTER UPDATE METHODS END*/

        //* MH : DPM-4455 update owner of action plan when the old user lose the permission about action plan
        UserTriggerHelper.updateOwnerOnActionPlan(newMap.values(),oldMap); 

        // Edited by Areum on 11-01-2024 for DNAMS PIR
        //UserTriggerHelper.updateDNAMSRoleOnContact(newMap.values(), null);
    }

    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, User> oldMap = (Map<Id, User>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/

        /*AFTER DELETE METHODS END*/
    }

    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, User> newMap = (Map<Id, User>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/

        /*AFTER UNDELETE METHODS END*/
    }
}