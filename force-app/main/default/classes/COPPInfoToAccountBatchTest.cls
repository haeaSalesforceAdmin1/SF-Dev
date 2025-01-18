/**
     * [Method Description] COPP Project - test class for COPPInfoToAccountBatch
     * Created by [MinheeKim] on [2024-09-23] for [DPM-5709]
    */

@isTest
public class COPPInfoToAccountBatchTest {

    @testSetup
    static void setup() {
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i
            );
            accountList.add(acc);
        }
        insert accountList;

        // Create COPPInfo__c records linked to those accounts
        List<COPPInfo__c> coppInfoList = new List<COPPInfo__c>();
        for(Account acc : accountList) {
            COPPInfo__c coppInfo = new COPPInfo__c(
                COPP__c = true,
                Buy_Sell_COPP__c = true,
                Account__c = acc.Id
            );
            coppInfoList.add(coppInfo);
        }
        insert coppInfoList;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        // Run the batch
        COPPInfoToAccountBatch batch = new COPPInfoToAccountBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Fetch the updated Accounts
        List<Account> updatedAccounts = [SELECT Id, COPP__c, Buy_Sell_COPP__c FROM Account];

    }

    @isTest
    static void testErrorBatchExecution() {

        Account acc = [SELECT Id, COPP__c, Buy_Sell_COPP__c FROM Account Limit 1];
        // Create COPPInfo__c records linked to those accounts

        COPPInfo__c coppInfo = new COPPInfo__c(
            COPP__c = true,
            Buy_Sell_COPP__c = true,
            Account__c = acc.Id
        );
        COPPInfoTriggerHandler.run=false;
        insert coppInfo;
        COPPInfoTriggerHandler.run=true;
        Test.startTest();

        // Run the batch
        COPPInfoToAccountBatch batch = new COPPInfoToAccountBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Fetch the updated Accounts
        List<Account> updatedAccounts = [SELECT Id, COPP__c, Buy_Sell_COPP__c FROM Account];

    }

    @isTest
    static void testScheduler() {
        Test.startTest();
        // Schedule the job to run immediately
        String jobId = System.schedule('Test COPPInfoToAccountScheduler', System.now().addMinutes(1).format('s m H d M ? yyyy'), new COPPInfoToAccountScheduler());
        Test.stopTest();

    }
}