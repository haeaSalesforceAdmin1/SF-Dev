/**
 * Created by baltamimi on 2022-03-01.
 */

 @IsTest
 private class RRPFieldHistoryUtilTest {
 
     @IsTest
     static void logCaseHistory_Mixed() {
         RRPFieldHistorySelector.fieldHistorySettingsMock = mockFieldHistorySetting();
 
         Map<Id, Account> accountsMap = mockAccountRecords(new List<String>{
                 'Name'
         }, 1);
         Account accountRecord = accountsMap.values()[0];
         Test.startTest();
 
         RRPFieldHistoryUtil.FieldHistoryInvocableRequest startFlowFieldTracking = new RRPFieldHistoryUtil.FieldHistoryInvocableRequest();
         startFlowFieldTracking.SObjectType = Account.getSObjectType().getDescribe().getName();
         startFlowFieldTracking.flowName = 'Test Flow';
 
         // Start Flow Field Tracking History
         RRPFieldHistoryUtil.manageTracking(new List<RRPFieldHistoryUtil.FieldHistoryInvocableRequest>{
                 startFlowFieldTracking
         });
 
         // Simulate After Update Trigger
         RRPFieldHistoryUtil.initReferences(new List<Account>{
                 accountRecord
         });
         accountRecord.Name = 'Random';
 
         RRPFieldHistoryUtil.trackUserChanges(new List<Account>{
                 accountRecord
         });
 
         RRPFieldHistoryUtil.setContext( // Try to override the context by the trigger
                RRPFieldHistoryUtil.CONTEXT_TRIGGER,
                 Account.getSObjectType().getDescribe().getName(),
                 'AccountTriggerHandler'
         );
         accountRecord.Phone = '1231231234';
 
         RRPFieldHistorySelector.mockRecords.put(accountRecord.Id, accountRecord);
         RRPFieldHistoryUtil.takeSnapshots(accountsMap.keySet());
 
         System.assertEquals(1, RRPFieldHistoryUtil.recordVersionsMap.size());
         System.assertEquals(3, RRPFieldHistoryUtil.recordVersionsMap.get(accountRecord.Id).size());
 
         RRPFieldHistoryUtil.commitLogs();
         RRPFieldHistoryUtil.resetContext(RRPFieldHistoryUtil.CONTEXT_TRIGGER);
         // End of Trigger After Update
 
         // Stop Flow field tracking history
         RRPFieldHistoryUtil.FieldHistoryInvocableRequest stopFlowFieldTracking = new RRPFieldHistoryUtil.FieldHistoryInvocableRequest();
         stopFlowFieldTracking.stopTracking = true;
 
         Test.stopTest();
 
         List<FieldHistory__c> mockedFieldHistory = RRPFieldHistorySelector.mockFieldHistory;
         System.assert(mockedFieldHistory != null && mockedFieldHistory.size() > 0, 'Field History Records were not created, Expected: mockFieldHistoryRecords to be called');
     }
 
     private static List<CMTFieldHistorySetting__mdt> mockFieldHistorySetting() {
         List<CMTFieldHistorySetting__mdt> fhs = new List<CMTFieldHistorySetting__mdt>();
         fhs.add(new CMTFieldHistorySetting__mdt(
                 DeveloperName = 'Account',
                 FieldsNames__c = 'Name,Phone',
                 DisableHistoryTracking__c = false,
                 FieldHistoryLookupField__c = 'Account',
                 AppName__c = 'testApp'
         ));
 
         return fhs;
     }
 
     @IsTest
     static void logCaseHistory_User() {
         RRPFieldHistorySelector.fieldHistorySettingsMock = mockFieldHistorySetting();
 
         Map<Id, Account> accountsMap = mockAccountRecords(new List<String>{
                 'Name'
         }, 1);
         Account accountRecord = accountsMap.values()[0];
         Test.startTest();
 
         // Simulate After Update Trigger
         RRPFieldHistoryUtil.initReferences(new List<Account>{
                 accountRecord
         });
         accountRecord.Name = 'Random';
 
         RRPFieldHistoryUtil.trackUserChanges(new List<Account>{
                 accountRecord
         });
 
         RRPFieldHistoryUtil.setContext( // Try to override the context by the trigger
                RRPFieldHistoryUtil.CONTEXT_TRIGGER,
                 Account.getSObjectType().getDescribe().getName(),
                 'AccountTriggerHandler'
         );
         accountRecord.Phone = '1231231234';
 
         RRPFieldHistorySelector.mockRecords.put(accountRecord.Id, accountRecord);
         RRPFieldHistoryUtil.takeSnapshots(accountsMap.keySet());
 
         System.assertEquals(1, RRPFieldHistoryUtil.recordVersionsMap.size());
         System.assertEquals(3, RRPFieldHistoryUtil.recordVersionsMap.get(accountRecord.Id).size());
 
         RRPFieldHistoryUtil.commitLogs();
         RRPFieldHistoryUtil.resetContext(RRPFieldHistoryUtil.CONTEXT_TRIGGER);
         // End of Trigger After Update
 
         Test.stopTest();
 
         List<FieldHistory__c> mockedFieldHistory = RRPFieldHistorySelector.mockFieldHistory;
         System.assert(mockedFieldHistory != null && mockedFieldHistory.size() > 0, 'Expected: Create new Field History Records, Actual: Created Field History list is empty');
     }
 
     @IsTest
     static void logCaseHistory_User_emptyTrigger() {
         RRPFieldHistorySelector.fieldHistorySettingsMock = mockFieldHistorySetting();
 
         Map<Id, Account> accountsMap = mockAccountRecords(new List<String>{
                 'Name'
         }, 1);
         Account accountRecord = accountsMap.values()[0];
         Test.startTest();
 
         // Simulate After Update Trigger
         RRPFieldHistoryUtil.initReferences(new List<Account>{
                 accountRecord
         });
         accountRecord.Name = 'Random';
 
         RRPFieldHistoryUtil.trackUserChanges(new List<Account>{
                 accountRecord
         });
 
         System.assertEquals(1, RRPFieldHistoryUtil.recordVersionsMap.size());
         System.assertEquals(2, RRPFieldHistoryUtil.recordVersionsMap.get(accountRecord.Id).size());
 
         RRPFieldHistoryUtil.setContext(Account.getSObjectType().getDescribe().getName());
 
         RRPFieldHistoryUtil.commitLogs();
         RRPFieldHistoryUtil.resetContext(RRPFieldHistoryUtil.CONTEXT_TRIGGER);
         // End of Trigger After Update
 
         Test.stopTest();
 
         List<FieldHistory__c> mockedFieldHistory = RRPFieldHistorySelector.mockFieldHistory;
         System.assert(mockedFieldHistory != null && mockedFieldHistory.size() > 0, 'Expected: Create new Field History Records, Actual: Created Field History list is empty');
     }
 
     @IsTest
     static void logCaseHistory_User_disabled() {
         RRPFieldHistorySelector.fieldHistorySettingsMock = mockFieldHistorySetting();
 
         RRPFieldHistorySetting.RRPFieldHistorySetting = new RRPFieldHistorySetting.FieldHistory(true, new Set<String>(), '', '');
 
         Map<Id, Account> accountsMap = mockAccountRecords(new List<String>{
                 'Name'
         }, 1);
         Account accountRecord = accountsMap.values()[0];
         Test.startTest();
 
         // Simulate After Update Trigger
         RRPFieldHistoryUtil.initReferences(new List<Account>{
                 accountRecord
         });
         accountRecord.Name = 'Random';
 
         RRPFieldHistoryUtil.trackUserChanges(new List<Account>{
                 accountRecord
         });
 
         RRPFieldHistoryUtil.setContext( // Try to override the context by the trigger
                RRPFieldHistoryUtil.CONTEXT_TRIGGER,
                 Account.getSObjectType().getDescribe().getName(),
                 'AccountTriggerHandler'
         );
         accountRecord.Phone = '1231231234';
 
         RRPFieldHistorySelector.mockRecords.put(accountRecord.Id, accountRecord);
         RRPFieldHistoryUtil.takeSnapshots(accountsMap.keySet());
 
         System.assertEquals(0, RRPFieldHistoryUtil.recordVersionsMap.size());
 
         RRPFieldHistoryUtil.commitLogs();
         RRPFieldHistoryUtil.resetContext(RRPFieldHistoryUtil.CONTEXT_TRIGGER);
         // End of Trigger After Update
 
         Test.stopTest();
 
         List<FieldHistory__c> mockedFieldHistory = RRPFieldHistorySelector.mockFieldHistory;
         System.assertEquals(null, mockedFieldHistory, 'Expected: commitLogs to be ignored, Actual: Field History Records were created');
     }
 
     @IsTest
     static void replaceIdWithName() {
        RRPFieldHistorySelector.fieldHistorySettingsMock = mockFieldHistorySetting();
 
         Map<Id, Account> accountsMap = mockAccountRecords(new List<String>{
                 'Name'
         }, 1);
         Account accountRecord = accountsMap.values()[0];
 
         FieldHistory__c fieldHistory = RRPFieldHistorySelector.mockFieldHistoryRecords()[0];
         fieldHistory.OriginalValue__c = '';
         fieldHistory.NewValue__c = accountRecord.Id;
 
         RRPFieldHistorySelector.mockFieldHistory = new List<FieldHistory__c>{
                 fieldHistory
         };
 
         List<Id> historyIds = new List<Id>{
                 fieldHistory.Id
         };
 
         Test.startTest();
         RRPFieldHistoryUtil.replaceIdsWithName(historyIds);
         Test.stopTest();
 
         List<FieldHistory__c> updatedFieldHistories = RRPFieldHistoryUtil.fieldHistoriesToUpdate;
        //  System.assertEquals(1, updatedFieldHistories.size());
        //  System.assertEquals('', updatedFieldHistories[0].OriginalValue__c);
        //  System.assertEquals('test string', updatedFieldHistories[0].NewValue__c);
     }
 
     private static Map<Id, Account> mockAccountRecords(List<String> fields, Integer numberOfRecords) {
         List<Id> recordsIds = new List<Id>();
         for (Integer i = 0; i < numberOfRecords; i++) {
             recordsIds.add(RRPFieldHistorySelector.mockId(Account.getSObjectType(), i));
         }
 
         Map<Id, SObject> rawMockRecords = RRPFieldHistorySelector.mockSObjectRecords(
                 Account.getSObjectType().getDescribe().name,
                 fields,
                 recordsIds
         );
 
         Map<Id, Account> mockAccounts = new Map<Id, Account>();
         for (Id recordId : rawMockRecords.keySet()) {
             mockAccounts.put(recordId, (Account) rawMockRecords.get(recordId));
         }
 
         return mockAccounts;
     }
 }