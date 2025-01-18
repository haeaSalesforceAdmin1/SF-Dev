/**
************************************************************************************************
* @classname         : HCUV_UploadDistrictsCtrl_Test; being used for Code Coverage
* @description       : Test class for HCUV_UploadDistrictsCtrl
* @author            : Hemanth
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0          21 Sep 2023         Hemanth		         			      Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_UploadDistrictsCtrl_Test {
    
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        HCUV_TestDataFactory.createAccounts(1);
        HCUV_TestDataFactory.createContestsIncentives(1);
        HCUV_TestDataFactory.createDealerMessages(1);
        
        insert new District__c(Name = 'NO CHICAGO', DistrictCode__c = 'CE1', Active__c = true);
                           
        HCUV_TestDataFactory.createInternalUser('Internal_UserF', 'Internal_UserL', HCUV_Constants.internalProfile);
    }
    
    /**
    * @description - Update District on HCUV_Contests_Incentives
    * 
    */
    @isTest 
    static void testUpdateDistrictsCI() {
        List<HCUV_Contests_Incentives__c> ciObjList = [Select Id from HCUV_Contests_Incentives__c];
        
        User internalUser = [SELECT Id FROM User WHERE LastName = 'Internal_UserL' LIMIT 1];
        
        System.runAs(internalUser) {
            Test.startTest();        
            Integer count = HCUV_UploadDistrictsCtrl.updateDistricts(ciObjList[0].Id, HCUV_Constants.Contests_Incentives_API_Name,
                                                     new List<Map<String, String>> {
                                                         new Map<String, String> {
                                                             'Market Code'=> 'CE1'
                                                                 }
                                                     });
            System.assert(count > 0, 'Contests_Incentives_Audience_Market not found.');
            
            Test.stopTest();
        }
    }
     /**
    * @description - Update District on HCUV_Contests_Incentives - Duplicate check
    * 
    */
    @isTest 
    static void testUpdateDistrictsCIDuplicateCheck() {
        List<HCUV_Contests_Incentives__c> ciObjList = [Select Id from HCUV_Contests_Incentives__c];
        
        User internalUser = [SELECT Id FROM User WHERE LastName = 'Internal_UserL' LIMIT 1];
        
        System.runAs(internalUser) {
            Test.startTest();
            HCUV_UploadDistrictsCtrl.updateDistricts(ciObjList[0].Id, HCUV_Constants.Contests_Incentives_API_Name,
                                                     new List<Map<String, String>> {
                                                         new Map<String, String> {
                                                             'Market Code'=> 'CE1'
                                                                 }
                                                     });           
            Integer count = HCUV_UploadDistrictsCtrl.updateDistricts(ciObjList[0].Id, HCUV_Constants.Contests_Incentives_API_Name,
                                                     new List<Map<String, String>> {
                                                         new Map<String, String> {
                                                             'Market Code'=> 'CE1'
                                                                 }
                                                     });            
            System.assert(count == 0, 'Contests_Incentives_Audience_Market duplicate check failed.');
            Test.stopTest();
        }
    }
    
    /**
    * @description - Update District on HCUV_Dealer_Message
    * 
    */
    @isTest 
    static void testUpdateDistrictsDM() {
        List<HCUV_Dealer_Message__c> dmObjList = [Select Id from HCUV_Dealer_Message__c];
        
        User internalUser = [SELECT Id FROM User WHERE LastName = 'Internal_UserL' LIMIT 1];
        
        System.runAs(internalUser) {
            Test.startTest();        
            Integer count =  HCUV_UploadDistrictsCtrl.updateDistricts(dmObjList[0].Id, HCUV_Constants.Dealer_Message_API_Name,
                                                     new List<Map<String, String>> {
                                                         new Map<String, String> {
                                                             'Market Code'=> 'CE1'
                                                                 }
                                                     });
            System.assert(count > 0, 'HCUV_Message_Audience_Markets not found.');
            
            Test.stopTest();
        }
    }
    
}