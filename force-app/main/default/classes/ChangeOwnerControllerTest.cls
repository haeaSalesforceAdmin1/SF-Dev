/**
 * @description       : 
 * @author            : San,Kang
 * @group             : 
 * @last modified on  : 06-22-2023
**/
@isTest
private class ChangeOwnerControllerTest {

    static Map<String,Object> dataGroup = new Map<String,Object>();
    static User user1;
    static User user2;
    static User user3;
    static Contact con;
    static Account account;
    static Survey__c survey;
    static Evaluation__c evaluation;
    // static List<Action_Plan__c> actionPlans = new List<Action_Plan__c>();
    static {
    

        user1 = TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');
        user2 = TestUtility.createInternalUser('TestOwnerUser1', 'TestOwnerUser1', 'System Administrator');
        user3 = TestUtility.createInternalUser('TestOwnerUser2', 'TestOwnerUser2', 'System Administrator');

        account = new Account(
            Name = 'Test Account'
        );
        insert account;

        con = new Contact(            
            AccountId = account.id,
            lastname = 'testdata', 
            firstname ='testdata1',
            email='test11@gmail.com',
            Active_DPM_User__c = true,
            JobCode__c='DB'
        );
        insert con;

        survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;

        // actionPlans.add(new Action_Plan__c(Evaluation__c = evaluation.Id, Account__c = account.Id, Status__c = 'Compliant',  DistrictPartsServiceManager__c = user1.Id, DistrictSalesManager__c = user2.Id, MarketManager__c = user3.Id));
        // insert actionPlans;
        

    }

    /**
    * @description 
    * @author San, Kang | 06-21-2023  
    * @return testMethod 
    **/
    static testMethod void myUnitTest() {
        dataGroup.put('owner',user1.Id);
        dataGroup.put('userEmail',user1.Email);
        dataGroup.put('userName',user1.Name);
        dataGroup.put('userId',user1.Id);
        dataGroup.put('targetobj','evaluation');
        dataGroup.put('recordId',evaluation.Id);
        dataGroup.put('sendEmail',true);
    
        Test.startTest();
        ChangeOwnerController.doInit(String.valueOf(evaluation.Id));
    
        ChangeOwnerController.onSave(dataGroup);
        Test.stopTest();    
        
    }

}