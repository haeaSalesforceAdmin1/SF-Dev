/**
 * @description       : CMT Test Data (Case, HMAReferenceData__c,VIN__c)
 * @author            : Bitna Seong (bseong@haeaus.com)
 * @last modified on  : 07-18-2023
 * @last modified by  :
**/
@isTest
public with sharing class CMT_DataFactory {
    

    /**
    * @description create test user
    * @author Bitna Seong (bseong@haeaus.com)
    * @param profileName 
    * @return User 
    **/
    public static User createUser(String profileName) {

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name=:profileName];     

        User user = new User();        
        user.FirstName = 'Test FristName';
        user.LastName = profileName;
        user.ProfileId = profile.Id;        
        user.Username = 'Test@test.com';
        user.Email = 'Test@test.com';
        user.Alias = 'test';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
		user.FederationIdentifier ='';

        return user;
    }

    /**
    * @description create test case
    * @author Bitna Seong (bseong@haeaus.com)
    * @param 
    * @return Case
    **/
    public static Case createCase(){

        Case testCase = new Case(
            FirstReportSource__c = 'HMC',
            MY__c = '2021;2022',
            Engine__c = '1.6L I4 GDI Gamma II Turbo HEV',
            Fuel_Type__c = 'HEV',
            Make__c = 'Hyundai',
            ModelCode__c = 'TME'
        );
        return testCase;
    }


    public static HMAReferenceData__c createHMAReferencee(){

        HMAReferenceData__c hmaReference = new HMAReferenceData__c();
        hmaReference.DrivetrainDescription__c = 'ALL WHEEL DRIVE';
        hmaReference.EngineDescription__c = '1.6L I4 GDI GAMMA II TURBO HEV';
        hmaReference.FuelType__c = 'HEV';
        hmaReference.Make__c = 'HYUNDAI';
        hmaReference.ModelCode__c = 'TME';
        hmaReference.TransmissionDescription__c = 'AUTO';
        hmaReference.VehicleModel__c = 'SANTA FE HEV';
        hmaReference.Year__c = '2021';

        return hmaReference;

    }


    public static VIN__c createVin (){

        VIN__c testVin = new VIN__c(
            Make__c = 'Hyundai',
            PQMSModelCode__c = 'TME',
            ModelYear__c = '2022',
            ModelDesc__c = 'SANTA FE HEV',
            EngineDesc__c = '1.6L I4 GDI Gamma II Turbo HEV',
            FuelType__c = 'HEV',
            DrivetrainDesc__c = 'ALL WHEEL DRIVE',
            TransmissionDesc__c = 'AUTO'
        );

        return testVin;
    }

}