public with sharing class GetSTILTestLeadUsers {
    @InvocableMethod(label = 'Get STIL Test Lead Users')
    public static List<List<User>> getSTILTestLeadUserList() {

       List<PermissionSetAssignment> pUserList = 
            [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId 
                IN (SELECT Id FROM PermissionSet WHERE Label='STIL - Test Lead')];

        List<Id> userIds = new List<Id>();
        for(PermissionSetAssignment pUser : pUserList){
            userIds.add(pUser.AssigneeId);
        }

        List<List<User>> result = new List<List<User>>();
        List<User> userList = [SELECT Id, Name FROM User WHERE Id IN :userIds];
        result.add(userList);
        return result;
    }
}