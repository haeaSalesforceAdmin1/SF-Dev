/**
 * @description       : CMTChangeOwnerController TestClass
 * @author            : San,Kang
 * @group             : 
 * @last modified on  : 11-20-2024
**/
@isTest
private class CMTChangeOwnerControllerTest {

    static Map<String,Object> dataGroup = new Map<String,Object>();
    static Map<String,Object> SaveDataGroup = new Map<String,Object>();
    static User user1;
    static Case case1;
    // static List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
    static {
        user1 = ContentDocumentTestFactory.makeUser();
        insert user1;
        case1 = ContentDocumentTestFactory.makeCase();
        insert case1;
    }
    
    /**
    * @description 
    * @author San, Kang | 11-20-2024 
    * @return testMethod 
    **/
    static testMethod void myUnitTest() {

        SaveDataGroup.put('type','User');
        SaveDataGroup.put('userId',user1.Id);

        dataGroup.put('currentOwner','testUser');
        dataGroup.put('userEmail',user1.Email);
        dataGroup.put('userName',user1.Name);
        dataGroup.put('userId',user1.Id);
        dataGroup.put('targetobj','Case');
        dataGroup.put('recordId',case1.Id);
        dataGroup.put('sendEmail',true);
        dataGroup.put('type','User');
        dataGroup.put('caseNumber','N-024-0001');
    
        Test.startTest();
        CMTChangeOwnerController.doInit(String.valueOf(case1.Id));
    
        CMTChangeOwnerController.onSave(SaveDataGroup);
        CMTChangeOwnerController.updateUser(dataGroup);
        Test.stopTest();    
        
    }

}