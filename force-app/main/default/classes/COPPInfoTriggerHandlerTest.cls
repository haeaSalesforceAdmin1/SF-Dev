@isTest
public with sharing class COPPInfoTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        COPPInfo__c coppInfo1 = new COPPInfo__c(
            Name = 'Test COPP Info 1',
            GDSI2Commitment__c = false,
            GRDCommitment__c = false,
            COPP_End_Date__c = null
        );
        insert coppInfo1;
        
        COPPInfo__c coppInfo2 = new COPPInfo__c(
            Name = 'Test COPP Info 2',
            GDSI2Commitment__c = false,
            GRDCommitment__c = false,
            COPP_End_Date__c = null
        );
        insert coppInfo2;

        CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;

        TestUtility.createOrganizations();
    
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);
        Account acc = new Account(
            	Name = 'Test Account',
            	Organization__c = genOrg.Id,
                DealerCode__c = 'NY701'
        );
        insert acc;
    }
    
    @isTest
    static void testHandleBeforeInsertUpdateWithGDSI2CommitmentTrue() {
        COPPInfo__c coppInfo = [SELECT Id, GDSI2Commitment__c, GRDCommitment__c, COPP__c, COPP_End_Date__c, BrandImageCheckedDate__c FROM COPPInfo__c LIMIT 1];
        coppInfo.GDSI2Commitment__c = true;

        Test.startTest();

        update coppInfo;

        Test.stopTest();

        COPPInfo__c updatedCoppInfo = [SELECT BrandImageCheckedDate__c FROM COPPInfo__c WHERE Id = :coppInfo.Id];
     }
    
    @isTest
    static void testHandleBeforeInsertUpdateWithGRDCommitmentTrue() {
        COPPInfo__c coppInfo = [SELECT Id, GDSI2Commitment__c, GRDCommitment__c, COPP__c, COPP_End_Date__c, BrandImageCheckedDate__c FROM COPPInfo__c LIMIT 1];

        coppInfo.GRDCommitment__c = true;

        Test.startTest();

        update coppInfo;

        Test.stopTest();

        COPPInfo__c updatedCoppInfo = [SELECT BrandImageCheckedDate__c FROM COPPInfo__c WHERE Id = :coppInfo.Id];
     }
    
    @isTest
    static void testHandleBeforeInsertUpdateWithNoCommitment() {

        COPPInfo__c coppInfo = [SELECT Id, GDSI2Commitment__c, GRDCommitment__c, COPP_End_Date__c, BrandImageCheckedDate__c FROM COPPInfo__c LIMIT 1];

        coppInfo.GDSI2Commitment__c = false;
        coppInfo.GRDCommitment__c = false;

        Test.startTest();

        update coppInfo;

        Test.stopTest();

        COPPInfo__c updatedCoppInfo = [SELECT BrandImageCheckedDate__c FROM COPPInfo__c WHERE Id = :coppInfo.Id];

    }

    @isTest
    static void testHandleBeforeInsertUpdateWithEndDate() {

        COPPInfo__c coppInfo = [SELECT Id, COPP__c, COPP_End_Date__c FROM COPPInfo__c LIMIT 1];

        coppInfo.COPP_End_Date__c = Date.today();

        Test.startTest();

        update coppInfo;

        Test.stopTest();

        COPPInfo__c updatedCoppInfo = [SELECT COPP__c FROM COPPInfo__c WHERE Id = :coppInfo.Id];

    }

    /**
     * [Method Description] 
     * Created by [MinheeKim] on [2024-11-08] for [DPM-5926] Prevent to update COPPInfo if both COPP and Buy/Sell COPP is not checked, but COPP Start Date is not null
    */   
    // @isTest
    // static void testCOPPflagStartDate() {

    //     COPPInfo__c coppInfo = [SELECT Id, COPP__c, COPP_End_Date__c FROM COPPInfo__c LIMIT 1];

    //     coppInfo.COPP_Start_Date__c = Date.today();
    //     coppInfo.COPP__c = false;
    //     coppInfo.Buy_Sell_COPP__c = false;

    //     Test.startTest();
    //     try {
    //         update coppInfo;
    //     } catch (DmlException e) {
    //         // Ensure the exception is properly handled
    //         System.assertEquals('COPP start date has been set but no relevant flags have been checked.', e.getMessage());
    //     }
    //     Test.stopTest();

    // }

    @isTest
    static void testCommitment() {
        
        COPPInfo__c coppInfo = [SELECT Id, COPP__c, GDSI2Commitment__c FROM COPPInfo__c WHERE GDSI2Commitment__c = false LIMIT 1];

        coppInfo.GDSI2Commitment__c =true;

        Test.startTest();
        update coppInfo;
        Test.stopTest();

    }

    @isTest
    static void testDuplicateCOPPInfo() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        COPPInfo__c coppInfo = new COPPInfo__c(
            Name = 'Test COPP Info 2',
            Account__c = acc.Id,
            COPP__c = false,
            Buy_Sell_COPP__c = false,
            COPP_Start_Date__c = Date.today()
        );


        Test.startTest();
        insert coppInfo;
        Test.stopTest();

    }
}