/*
 * @description:    When Dealer Code on a temporary dealer account gets updated, all community users under the account
 *                  will be assigned DNAMS Enforce SSO permission set, which will prevent non-SSO login to the DNAMS portal.
 * @author:         Salesforce Professional Services
 * @date:           12/20/2022
 */
public without sharing class DNAMSEnforceSSOPermSetQueueable implements Queueable {

    public static final String DNAMS_ENFORCE_SSO_PERM_SET = 'DNAMS_Enforce_SSO';
    public Set<Id> setDealerCodeUpdatedAccIds;

    /* Constructor */
    public DNAMSEnforceSSOPermSetQueueable(Set<Id> setDealerCodeUpdatedAccIds) {
        this.setDealerCodeUpdatedAccIds = setDealerCodeUpdatedAccIds;
    }

    /* Queueable Execute */
    public void execute(QueueableContext context) {
        List<PermissionSetAssignment> lstPermSetAssignments = new List<PermissionSetAssignment>();

        //Query the permission set with name DNAMS_ENFORCE_SSO_PERM_SET
        List<PermissionSet> enforceSSOPermSet = [SELECT Id FROM PermissionSet WHERE Name = :DNAMS_ENFORCE_SSO_PERM_SET LIMIT 1];

        //If a valid enforceSSOPermSet exists, proceed with Permission Set Assignment creations.
        if(!enforceSSOPermSet.isEmpty()) {

            //Query active users with AccountId matching the setDealerCodeUpdatedAccIds and without enforceSSOPermSet assigned.
            for (User usr : [SELECT Id
                             FROM User
                             WHERE
                                Id NOT IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :enforceSSOPermSet[0].Id)
                                AND
                                AccountId IN :setDealerCodeUpdatedAccIds
                                AND
                                IsActive = true
                            LIMIT 10000]) {

                //Create Permission Set Assignment and add to lstPermSetAssignments.
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = enforceSSOPermSet[0].Id, AssigneeId = usr.Id);
                lstPermSetAssignments.add(psa);
            }
        }

        //Insert the Permission Set Assignments
        if(!lstPermSetAssignments.isEmpty()) {
            insert lstPermSetAssignments;
        }
    }
}