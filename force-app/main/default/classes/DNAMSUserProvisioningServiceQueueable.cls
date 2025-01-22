/*
 * @description:    When a DNAMS Dealer User gets created and if the related partner contact has DNAMS Active User
 *                  checkbox selected, this Queueable Apex will provision the basic permission set and public group
 *                  memberships required for the user. When an existing Dealer Contact's DNAMS Active User checkbox
 *                  gets updated, this Queueable Apex will add/remove the provisioned Public Group memberships
 *                  and Permission Set Assignments.
 * @author:         Salesforce Professional Services
 * @date:           12/22/2022
 */
public without sharing class DNAMSUserProvisioningServiceQueueable implements Queueable {
    
    public static final String DNAMS_EXTERNAL_USER_PERM_SET = 'DNAMSBasicExternal';
    public static final String DNAMS_GROUP_HYUNDAI_EXTERNAL = 'Hyundai_External_User';
    public static final String DNAMS_GROUP_GENESIS_EXTERNAL = 'Genesis_External_User';
    public static final List<String> DNA_PUBLIC_GROUP_LIST = new List<String>{ DNAMS_GROUP_HYUNDAI_EXTERNAL,
                                                                               DNAMS_GROUP_GENESIS_EXTERNAL };
    
    public Set<Id> setNewDealerUserIds = new Set<Id>(); //DNAMS Dealer User Ids that require provisioning.
    public Set<Id> setRevokedDealerUserIds = new Set<Id>(); //Dealer User Ids whose DNAMS provisioning needs to be removed.
    public List<PermissionSet> lstDNAPermSets =  new List<PermissionSet>();
    public List<Group> lstDNAPublicGroups = new List<Group>();

    /* Constructor - Invoked from UserTriggerHelper */
    public DNAMSUserProvisioningServiceQueueable(Set<Id> setDealerUsers) {
        setNewDealerUserIds = setDealerUsers; //New users who needs to be provisioned in DNAMS.
    }

    /* Constructor - Invoked from ContactTriggerHelper */
    public DNAMSUserProvisioningServiceQueueable(Map<Id, Boolean> mapUserDNAMSFlag) {

        for(Id userId : mapUserDNAMSFlag.keySet()) {
            if(mapUserDNAMSFlag.get(userId) == TRUE) { //New or updated users who needs to be provisioned in DNAMS.
                setNewDealerUserIds.add(userId);
            }
            else { //Existing DNAMS Users whose provisioning needs to be removed.
                setRevokedDealerUserIds.add(userId);
            }
        }
    }

    /* Queueable Execute */
    public void execute(QueueableContext context) {

        //Query Permission Sets and Public Groups
        queryPermSetsAndGroups();

        if(!setNewDealerUserIds.isEmpty()) {
            //Provision new dealer user records
            //provisionNewDealerUsers(setNewDealerUserIds); //Changed to comments - DPM-6020 by MinheeKim 01.21.2025
        }
        if(!setRevokedDealerUserIds.isEmpty()) {
            //Remove provisioned permission sets and public groups from dealer records.
            revokeDealerUsers(setRevokedDealerUserIds);
        }
    }

    /*
     * @description:    Query Permission Sets with name DNAMS_EXTERNAL_USER_PERM_SET
     *                  Query Public Groups with name matching DNA_PUBLIC_GROUP_LIST
     * @params:         None
     */
    public void queryPermSetsAndGroups() {
        //Query the Permission Set with the name DNAMS_EXTERNAL_USER_PERM_SET
        lstDNAPermSets = [SELECT Id FROM PermissionSet WHERE Name = :DNAMS_EXTERNAL_USER_PERM_SET LIMIT 1];

        //Query the Public Groups with names matching DNA_PUBLIC_GROUP_LIST
        lstDNAPublicGroups = [SELECT Id FROM Group WHERE DeveloperName IN :DNA_PUBLIC_GROUP_LIST LIMIT 1000];
    }

    /*
     * @description:    Create permission sets and assign public group memberships for new DNAMS Dealer Users
     * @params:         setNewDealerUserIds - Set of User IDs
     * Changed to comments - DPM-6020 by MinheeKim 01.21.2025
     */
    // public void provisionNewDealerUsers(Set<Id> setNewDealerUserIds) {
        
    //     List<PermissionSetAssignment> lstPermissionSets = new List<PermissionSetAssignment>();
    //     List<GroupMember> lstDNAGroupMembers = new List<GroupMember>();
        
    //     //Query existing PermissionSetAssignments and construct a unique tag for each assignment.
    //     Set<String> strPermSetAssigneeCombo = new Set<String>();
    //     for(PermissionSetAssignment psa : [SELECT Id, PermissionSetId, AssigneeId
    //                                         FROM PermissionSetAssignment
    //                                         WHERE PermissionSetId IN :lstDNAPermSets AND AssigneeId IN :setNewDealerUserIds
    //                                         LIMIT 1000]) {
    //         strPermSetAssigneeCombo.add(psa.PermissionSetId + '-' + psa.AssigneeId);
    //     }

    //     //Query existing GroupMembers and construct a unique tag for each group member.
    //     Set<String> strGroupUserCombo = new Set<String>();
    //     for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId
    //                             FROM GroupMember
    //                             WHERE GroupId IN :lstDNAPublicGroups AND UserOrGroupId IN :setNewDealerUserIds
    //                             LIMIT 1000]) {
    //         strGroupUserCombo.add(gm.GroupId + '-' + gm.UserOrGroupId);
    //     }

    //     //Query active users with ID in setNewDealerUserIds
    //     for (User u : [SELECT Id
    //                     FROM User
    //                     WHERE Id IN :setNewDealerUserIds AND IsActive = true
    //                     LIMIT 10000]) {

    //         //Create Permission Set Assignment and add to lstPermissionSets.
    //         for(PermissionSet ps : lstDNAPermSets) {
    //             //If the PermissionSetAssignment already exists, skip to the next record in FOR loop.
    //             if(strPermSetAssigneeCombo.contains(ps.Id + '-' + u.Id)) {
    //                 continue;
    //             }

    //             //Duplicates avoided. Proceed with creating PermissionSetAssignment records.
    //             PermissionSetAssignment psa = new PermissionSetAssignment();
    //             psa.PermissionSetId = ps.Id;
    //             psa.AssigneeId = u.Id;

    //             lstPermissionSets.add(psa);
    //         }

    //         //Create GroupMembers and add to lstDNAGroupMembers.
    //         for(Group g : lstDNAPublicGroups) {
    //             //If the GroupMember already exists, skip to the next record in FOR loop.
    //             if(strGroupUserCombo.contains(g.Id + '-' + u.Id)) {
    //                 continue;
    //             }

    //             //Duplicates avoided. Proceed with creating GroupMember records.
    //             GroupMember gm = new GroupMember();
    //             gm.GroupId = g.Id;
    //             gm.UserOrGroupId = u.Id;

    //             lstDNAGroupMembers.add(gm);
    //         }
    //     }

    //     //Insert the Permission Set Assignments
    //     if(!lstPermissionSets.isEmpty()) { 
    //         insert lstPermissionSets;  
    //     }

    //     //Insert the public group memberships
    //     if(!lstDNAGroupMembers.isEmpty()) {
    //         insert lstDNAGroupMembers;  
    //     }
    // }

    /*
     * @description:    Remove previously provisioned permission sets and public group assignments for dealer users
     * @params:         setRevokedDealerUserIds - Set of User IDs
     */
    public void revokeDealerUsers(Set<Id> setRevokedDealerUserIds) {

        List<PermissionSetAssignment> lstDNAPermAssignments = [SELECT Id
                                                                FROM PermissionSetAssignment
                                                                WHERE PermissionSetId IN :lstDNAPermSets AND AssigneeId IN :setRevokedDealerUserIds
                                                                LIMIT 1000];
        if(!lstDNAPermAssignments.isEmpty()) {
            delete lstDNAPermAssignments;
        }

        List<GroupMember> lstDNAGroupMemberships = [SELECT Id
                                                    FROM GroupMember
                                                    WHERE GroupId IN :lstDNAPublicGroups AND UserOrGroupId IN :setRevokedDealerUserIds
                                                    LIMIT 1000];
        if(!lstDNAGroupMemberships.isEmpty()) {
            delete lstDNAGroupMemberships;
        }
    }
}