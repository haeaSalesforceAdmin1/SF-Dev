@isTest
public class STIL_UtilityTest {


    @TestSetup
    static void makeData(){
        
        Id oneCaseId = createCaseReturnId('N-015-0001');
        Id secondCaseId = createCaseReturnId('K-015-0001');
        System.debug(  String.valueOf( oneCaseId ) );
        List<Case> caseList = STIL_Utility.getCasesByKeywordInCreationFlow('N-015');
        System.debug(caseList);

        // Create test data
        List<User> users = new List<User>();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1 ];  
        for (Integer i = 0; i < 5; i++) {
            User u = new User();
            u.FirstName = 'Test';
            u.LastName = 'User ' + i;
            u.Email = 'testuser' + i + '@example.com';
            u.ProfileId = profile.Id;        
            u.Username = 'Test@test.co.kr'+ i;
            u.Email = 'Test@test.com';
            u.Alias = 'test';
            u.TimeZoneSidKey = 'America/New_York';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.LanguageLocaleKey = 'en_US';
            u.FederationIdentifier ='';            
            users.add(u);
        }
        insert users;

        // Assign permission set to users












    }


    @isTest
    static void testGetProd(){





    }


    static Workorder createLR(){
        WorkOrder wo = new WorkOrder();
        wo.Status = 'New';
        wo.Priority = 'Low';
        wo.Subject = 'Test';
        return wo;
    }

    static Id createCaseReturnId(String caseNum){//'N-015-0001'
        // #NOTE has dependency to CMT_DataFactory
        Case oneCase = CMT_DataFactory.createCase();
        oneCase.SCSCaseNumber__c = caseNum;// just a sample real number by numbering rule 
        Database.SaveResult caseSr = Database.insert(oneCase, false);
        Id caseId;
        if(caseSr.isSuccess()){
            System.debug('Successfully inserted WO. WO ID: ' + caseSr.getId());
            caseId = caseSr.getId();
        } 
        return caseId;
        
    }


    @isTest
    static void testRetrieveRequestorForLRCreationFlow() {

        // List<User> users = [SELECT Id FROM User LIMIT 5];

        // List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        // PermissionSet ps =[SELECT Id FROM PermissionSet WHERE Name = 'STIL_Requestor']; 
        // for( User i : users){
        //     PermissionSetAssignment psa = new PermissionSetAssignment();
        //     // psa.AssigneeId = UserInfo.getUserId();
        //     psa.AssigneeId = i.Id;
        //     psa.PermissionSetId = ps.Id;
        //     psaList.add(psa);
        // }   
        // insert psaList;

        Test.startTest();

        // Call the method under test
        List<String> userIdStringList = new List<String>();
        List<List<User>> result = STIL_Utility.retrieveRequestorForLRCreationFlow( userIdStringList );
        userIdStringList.add(UserInfo.getUserId()); 
        List<List<User>> result2 = STIL_Utility.retrieveRequestorForLRCreationFlow( userIdStringList );

        // Perform assertions
        System.assertEquals(1, result.size());
        // System.assertEquals(5, result[0].size());
        // for (Integer i = 0; i < 5; i++) {
        //     System.assertEquals('Test User ' + i, result[0][i].Name);
        // }
        Test.stopTest();
    }

    // @istest
    // static void testRetrieveRequestorForLRCreationFlow() {
    //     // Create test data
    //     List<User> users = new List<User>();
    //     for (Integer i = 0; i < 5; i++) {
    //         User u = new User();
    //         u.FirstName = 'Test';
    //         u.LastName = 'User ' + i;
    //         u.Email = 'testuser' + i + '@example.com';
    //         users.add(u);
    //     }
    //     insert users;

    //     // Call the method under test
    //     List<List<User>> result = STIL_Utility.retrieveRequestorForLRCreationFlow(new List<String>());

    //     // Perform assertions
    //     System.assertEquals(1, result.size());
    //     System.assertEquals(5, result[0].size());
    //     for (Integer i = 0; i < 5; i++) {
    //         System.assertEquals('Test User ' + i, result[0][i].Name);
    //     }
    // }



}