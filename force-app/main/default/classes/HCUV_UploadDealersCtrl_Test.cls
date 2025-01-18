/**
************************************************************************************************
* @classname         : HCUV_UploadDealersCtrl_Test; being used for Code Coverage
* @description       : Test class for HCUV_UploadDealersCtrl
* @author            : Hemanth
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0          10 Aug 2023         Hemanth		         			      Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_UploadDealersCtrl_Test {
    
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        HCUV_TestDataFactory.createAccounts(1);
        HCUV_TestDataFactory.createContestsIncentives(1);
        HCUV_TestDataFactory.createDealerMessages(1);
        
//        HCUV_TestDataFactory.createInternalUser('Internal_UserF', 'Internal_UserL', HCUV_Constants.internalProfile);
    }
    
    /**
    * @description - Checking Dealer Group for Contests_Incentives
    * 
    */
    @isTest 
    static void testCreateDealerGroupCI() {
        List<HCUV_Contests_Incentives__c> ciObjList = [Select Id from HCUV_Contests_Incentives__c];
        
            Test.startTest();        
            HCUV_UploadDealersCtrl.createDealerGroup(ciObjList[0].Id, HCUV_Constants.Contests_Incentives_API_Name,
                                                     new List<Map<String, String>> {
                                                         new Map<String, String> {
                                                             'Dealer Code'=> 'TestCode1'
                                                                 }
                                                     });
            
            List<HCUV_Contest_Incentive_Member__c> dgObjList = [Select Id From HCUV_Contest_Incentive_Member__c];
            System.assert(dgObjList.size() > 0, 'Contest_Incentive_Members not found.');
            
            Test.stopTest();
    }
    
    /**
    * @description - Checking Dealer Group for Dealer_Message
    * 
    */
    @isTest 
    static void testCreateDealerGroupDM() {
        List<HCUV_Dealer_Message__c> dmObjList = [Select Id from HCUV_Dealer_Message__c];
        
            Test.startTest();        
            HCUV_UploadDealersCtrl.createDealerGroup(dmObjList[0].Id, HCUV_Constants.Dealer_Message_API_Name,
                                                     new List<Map<String, String>> {
                                                         new Map<String, String> {
                                                             'Dealer Code'=> 'TestCode1'
                                                                 }
                                                     });
            
            List<HCUV_Message_Audience__c> dgObjList = [Select Id From HCUV_Message_Audience__c];
            System.assert(dgObjList.size() > 0, 'Contest_Incentive_Members not found.');
            
            Test.stopTest();
    }
    
}