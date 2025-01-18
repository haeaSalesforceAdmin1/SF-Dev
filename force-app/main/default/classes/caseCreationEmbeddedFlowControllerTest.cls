/**
 * Created by baltamimi on 2022-03-07.
 */

@IsTest
private class caseCreationEmbeddedFlowControllerTest {

    static Case makeCase() {
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('KASDA').getRecordTypeId();

        SCSConfigurationSettings__c setting = new SCSConfigurationSettings__c();
        setting.CurrentCaseNumber__c = 1;
        insert setting;

        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.SafetyType__c = 'Vehicle';
        c.CompanyName__c = 'HMC';                   // KASO.2023.05.12 복구시 주석 처리 필요 (1/16)
        c.CountrySubmitterWorks__c = 'Korea';       // KASO.2023.05.12 복구시 주석 처리 필요 (2/16)
        c.SCSCaseRegion__c = 'Korea';               // KASO.2023.05.12 복구시 주석 처리 필요 (3/16)
        //c.CompanyName__c = 'HMA';                 // KASO.2023.05.12 복구시 주석 제거 필요 (4/16)
        //c.CountrySubmitterWorks__c = 'Canada';    // KASO.2023.05.12 복구시 주석 제거 필요 (5/16)
        //c.SCSCaseRegion__c = 'North America';     // KASO.2023.05.12 복구시 주석 제거 필요 (6/16)
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        c.RecordTypeId = recordTypeId;
        c.SCSCaseNumber__c = 'Test1';

        return c;
    }
 

    @IsTest
    static void testCaseInsert_Owner() {
        //User otherUser = [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name LIKE '%Admin%' LIMIT 1];     // KASO.2023.05.18 복구시 주석 제거 필요 (7/16)
        //List<Group> daManagerQueue = [SELECT Id FROM Group WHERE DeveloperName = 'KASOSCSafetyDA'];   // KASO.2023.05.10 주석 유지
        //List<Group> daManagerQueue = [SELECT Id FROM Group WHERE DeveloperName = 'SCSafetyDA'];       // KASO.2023.05.18 복구시 주석 제거 필요 (8/16)
        //System.assertEquals(1, daManagerQueue.size());

        Case c = makeCase();
        insert c;
        //c.OwnerId = otherUser.Id;         // KASO.2023.05.18 복구시 주석 제거 필요 (9/16)
        //update c;                         // KASO.2023.05.18 복구시 주석 제거 필요 (10/16)

        // KASO.2023.05.13 복구시 주석 처리 필요 (11/16)
        ///*
        c.SCSCaseRegion__c = 'Europe';
        update c;

        c.SCSCaseRegion__c = 'Other';
        update c;
        //*/
        
        Case insertedCase = [SELECT OwnerId FROM Case WHERE Id = :c.Id];
        //System.assertNotEquals(daManagerQueue[0].Id, insertedCase.OwnerId);       // KASO.2023.05.18 복구시 주석 제거 필요 (12/16)
        

        Test.startTest();
        caseCreationEmbeddedFlowController.updateOwner(insertedCase.Id);
        User u = caseCreationEmbeddedFlowController.fetchUser();                    // KASO.2023.05.10 복구시 주석 처리 필요 (13/16)
        Test.stopTest();

        //System.assertNotEquals(daManagerQueue[0].Id, u.id,'KASO TEST');           // KASO.2023.05.10 복구시 주석 제거 필요 (14/16)

        //Case updatedCase = [SELECT OwnerId FROM Case WHERE Id = :c.Id];                 // KASO.2023.05.18 복구시 주석 제거 필요 (15/16)
        //System.assertNotEquals(daManagerQueue[0].Id, updatedCase.OwnerId,'KASO TEST');  // KASO.2023.05.18 주석 유지
        //System.assertEquals(daManagerQueue[0].Id, updatedCase.OwnerId);                 // KASO.2023.05.18 복구시 주석 제거 필요 (16/16)
    }
}