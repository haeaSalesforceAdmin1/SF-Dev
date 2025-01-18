@isTest
public class RecommendCaseEngineerTest {
    @TestSetup
    static void makeData(){
        SCSConfigurationSettings__c setting = new SCSConfigurationSettings__c();
        setting.CurrentCaseNumber__c = 1;
        insert setting;
        Profile p = [SELECT Id FROM Profile WHERE Name='Safety Service Engineer']; 
        List<User> usersToInsert = new List<User>();
        for(Integer i = 0; i < 5; i++){
            User u = new User();
            u.FirstName = 'Test';
            u.LastName = 'User ' + i;
            u.Alias = 'TUser ' + i;
            u.Username = 'testUser_Hyundai' + i + '@test.com';
            u.Email = 'test' + i + '@test.com';
            u.CommunityNickname  = 'TUser ' + i;
            u.SCSafetySkills__c = 'Chassis: Brakes; Chassis: Steering; Power Train: Hybrid; Power Train: Engine';
            u.SafetyTeamDesignations__c = 'DA, TRC';
            u.ProfileId = p.Id;
            u.EmailEncodingKey='UTF-8';
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey='en_US';
            u.TimeZoneSidKey='America/Los_Angeles';
            usersToInsert.add(u);
        }
        insert usersToInsert;
    }

    @IsTest
    public static void testGetRecommendedEngineers(){
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();
        Case c = new Case();
        c.Subject = 'Hyundai Hybrid Engine Issue';
        c.Description = 'Hyundai G80 Body';
        c.Make__c = 'Hyundai';
        c.VehicleModel__c = 'G80';
        c.MY__c = '2021';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMA';
        c.CountrySubmitterWorks__c = 'Canada';
        c.SCSCaseRegion__c = 'North America';
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';
        insert c;

        List<List<User>> recommendedEngineers = RecommendCaseEngineer.getRecommendedEngineers(new List<Id>{c.Id});
        system.assert(recommendedEngineers[0].size() >= 5);
    }
}