@isTest
private class GetSTILTestLeadUsersTest {

    @isTest
    static void getSTILTestLeadUserListTest() {
        // Create test data - PermissionSetAssignment
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Label='STIL - Test Lead'];
        User testUser = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator' ORDER BY CreatedDate LIMIT 1];
        System.debug(testUser.Name);
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId=testUser.Id, PermissionSetId=ps.Id);
        insert psa;

        // Call the method under test
        Test.startTest();
        List<List<User>> userList = GetSTILTestLeadUsers.getSTILTestLeadUserList();
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(0, userList.size(), 'List should have at least 1 user');
        List<User> users = userList[0];
        System.assertNotEquals(null, users, 'List of users should not be null');
    }
}