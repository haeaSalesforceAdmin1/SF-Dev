/**
     * [Class Description] Test class for ErrorMessageControleer class
     * Created by [MinheeKim] on [2024-05-01] for [DPM-5400]
    */
@isTest
public class ErrorMessageControllerTest {
    @isTest
    static void testGetEventData() {
        Profile prof = [Select Id from Profile Where Name = 'DPM Partner Community (Hyundai)'];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        List<Contact> conList = new List<Contact>();
        Contact con =new Contact(FirstName = 'Test',LastName = 'Contact', AccountId =acc.Id, Email='test@test.com');
        Contact con2 =new Contact(FirstName = 'Test2',LastName = 'Contact', AccountId =acc.Id, Email='test22@test.com');
        conList.add(con);
        conList.add(con2);
        insert conList;

        
        User inactiveUser  = new User(
            ProfileId = prof.Id,
            FirstName = 'Inactive',
            LastName = 'User',
            Email = 'testuser@test.com',
            Username = 'testuser@test.com' + System.currentTimeMillis(),
            CompanyName = 'Test Company',
            ContactId=con2.Id,
            Title = 'Test Title',
            Alias = 'TUser',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey='en_US',
            IsActive=false
        );
        insert inactiveUser;
        
        
        Action_Plan__c actionPlan = new Action_Plan__c(
            Name = 'Test Action Plan',
            Original_Partner_User_ID__c =inactiveUser.Id
        );
        Action_PlanTriggerHandler.run=false;
        insert actionPlan;
        Action_PlanTriggerHandler.run=true;

        Id recordId = actionPlan.Id;


        User testUser  = new User(
            ProfileId = prof.Id,
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser2@test.com',
            Username = 'testuser2@test.com' + System.currentTimeMillis(),
            CompanyName = 'Test Company',
            ContactId=con.Id,
            Title = 'Test Title2',
            Alias = 'TUser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey='en_US',
            IsActive=true
        );
        insert testUser;



        Test.startTest();

        String errorMessage = ErrorMessageController.getEventData(recordId);
        Test.stopTest();


        System.assertEquals('The new owner of this Evaluation/Action Plan does not have proper DPM access. Please contact DPM Support (DPMSupport@hmausa.com) with details.', errorMessage, 'The new owner of this Evaluation/Action Plan does not have proper DPM access. Please contact DPM Support (DPMSupport@hmausa.com) with details.');

        
    }

    /**
     * [Class Description] Test method for action plan which of approval status is 'Submitted for regional approval'
     * Created by [MinheeKim] on [2024-05-01] for [DPM-5400]
     * Edited by [MinheeKim] on [2024-05-21] for [DPM-5533] added logic for checking the owner is active or not when RM clicked send back
    */
    @isTest
    static void testRegionalSendBack() {
        Profile prof = [Select Id from Profile Where Name = 'DPM Partner Community (Hyundai)'];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        List<Contact> conList = new List<Contact>();
        Contact con =new Contact(FirstName = 'Test',LastName = 'Contact', AccountId =acc.Id, Email='test@test.com');
        Contact con2 =new Contact(FirstName = 'Test2',LastName = 'Contact', AccountId =acc.Id, Email='test22@test.com');
        conList.add(con);
        conList.add(con2);
        insert conList;

        
        User inactiveUser  = new User(
            ProfileId = prof.Id,
            FirstName = 'Inactive',
            LastName = 'User',
            Email = 'testuser@test.com',
            Username = 'testuser@test.com' + System.currentTimeMillis(),
            CompanyName = 'Test Company',
            ContactId=con2.Id,
            Title = 'Test Title',
            Alias = 'TUser',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey='en_US',
            IsActive=false
        );
        insert inactiveUser;
        
        
        Action_Plan__c actionPlan = new Action_Plan__c(
            Name = 'Test Action Plan',
            OwnerId = inactiveUser.Id,
            ApprovalStatus__c = 'Submitted for Regional Approval'
        );
        Action_PlanTriggerHandler.run=false;
        insert actionPlan;
        Action_PlanTriggerHandler.run=true;

        Id recordId = actionPlan.Id;


        User testUser  = new User(
            ProfileId = prof.Id,
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser2@test.com',
            Username = 'testuser2@test.com' + System.currentTimeMillis(),
            CompanyName = 'Test Company',
            ContactId=con.Id,
            Title = 'Test Title2',
            Alias = 'TUser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey='en_US',
            IsActive=true
        );
        insert testUser;



        Test.startTest();

        String errorMessage = ErrorMessageController.getEventData(recordId);
        Test.stopTest();

        
    }
}