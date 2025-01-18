@isTest
public with sharing class TestObjectTagSetting {
    @isTest
    public static void testObjectTagPopulation(){
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

        Case createdCase = [SELECT ID, RecommendedCaseTagsLong__c FROM Case WHERE Id =: c.Id];
        system.assert(createdCase.RecommendedCaseTagsLong__c <> NULL);
        system.assert(createdCase.RecommendedCaseTagsLong__c.contains('Hyundai'));
        system.assert(createdCase.RecommendedCaseTagsLong__c.contains('G80'));
    }
}