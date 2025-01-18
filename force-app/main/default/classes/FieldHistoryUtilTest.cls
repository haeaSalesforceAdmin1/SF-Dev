/**
 * Created by baltamimi on 2022-03-01.
 */

@IsTest
private class FieldHistoryUtilTest {

    @IsTest
    static void logCaseHistory_Mixed() {
        FieldHistorySelector.fieldHistorySettingsMock = mockFieldHistorySetting();

        Map<Id, Account> accountsMap = mockAccountRecords(new List<String>{
                'Name'
        }, 1);
        Account accountRecord = accountsMap.values()[0];
        Test.startTest();

        FieldHistoryUtil.FieldHistoryInvocableRequest startFlowFieldTracking = new FieldHistoryUtil.FieldHistoryInvocableRequest();
        startFlowFieldTracking.SObjectType = Account.getSObjectType().getDescribe().getName();
        startFlowFieldTracking.flowName = 'Test Flow';

        // Start Flow Field Tracking History
        FieldHistoryUtil.manageTracking(new List<FieldHistoryUtil.FieldHistoryInvocableRequest>{
                startFlowFieldTracking
        });

        // Simulate After Update Trigger
        FieldHistoryUtil.initReferences(new List<Account>{
                accountRecord
        });
        accountRecord.Name = 'Random';

        FieldHistoryUtil.trackUserChanges(new List<Account>{
                accountRecord
        });

        FieldHistoryUtil.setContext( // Try to override the context by the trigger
                FieldHistoryUtil.CONTEXT_TRIGGER,
                Account.getSObjectType().getDescribe().getName(),
                'AccountTriggerHandler'
        );
        accountRecord.Phone = '1231231234';

        FieldHistorySelector.mockRecords.put(accountRecord.Id, accountRecord);
        FieldHistoryUtil.takeSnapshots(accountsMap.keySet());

        System.assertEquals(1, FieldHistoryUtil.recordVersionsMap.size());
        System.assertEquals(3, FieldHistoryUtil.recordVersionsMap.get(accountRecord.Id).size());

        FieldHistoryUtil.commitLogs();
        FieldHistoryUtil.resetContext(FieldHistoryUtil.CONTEXT_TRIGGER);
        // End of Trigger After Update

        // Stop Flow field tracking history
        FieldHistoryUtil.FieldHistoryInvocableRequest stopFlowFieldTracking = new FieldHistoryUtil.FieldHistoryInvocableRequest();
        stopFlowFieldTracking.stopTracking = true;

        Test.stopTest();

        List<FieldHistory__c> mockedFieldHistory = FieldHistorySelector.mockFieldHistory;
        System.assert(mockedFieldHistory != null && mockedFieldHistory.size() > 0, 'Field History Records were not created, Expected: mockFieldHistoryRecords to be called');
    }

    private static List<FieldHistorySetting__mdt> mockFieldHistorySetting() {
        List<FieldHistorySetting__mdt> fhs = new List<FieldHistorySetting__mdt>();
        fhs.add(new FieldHistorySetting__mdt(
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
        FieldHistorySelector.fieldHistorySettingsMock = mockFieldHistorySetting();

        Map<Id, Account> accountsMap = mockAccountRecords(new List<String>{
                'Name'
        }, 1);
        Account accountRecord = accountsMap.values()[0];
        Test.startTest();

        // Simulate After Update Trigger
        FieldHistoryUtil.initReferences(new List<Account>{
                accountRecord
        });
        accountRecord.Name = 'Random';

        FieldHistoryUtil.trackUserChanges(new List<Account>{
                accountRecord
        });

        FieldHistoryUtil.setContext( // Try to override the context by the trigger
                FieldHistoryUtil.CONTEXT_TRIGGER,
                Account.getSObjectType().getDescribe().getName(),
                'AccountTriggerHandler'
        );
        accountRecord.Phone = '1231231234';

        FieldHistorySelector.mockRecords.put(accountRecord.Id, accountRecord);
        FieldHistoryUtil.takeSnapshots(accountsMap.keySet());

        System.assertEquals(1, FieldHistoryUtil.recordVersionsMap.size());
        System.assertEquals(3, FieldHistoryUtil.recordVersionsMap.get(accountRecord.Id).size());

        FieldHistoryUtil.commitLogs();
        FieldHistoryUtil.resetContext(FieldHistoryUtil.CONTEXT_TRIGGER);
        // End of Trigger After Update

        Test.stopTest();

        List<FieldHistory__c> mockedFieldHistory = FieldHistorySelector.mockFieldHistory;
        System.assert(mockedFieldHistory != null && mockedFieldHistory.size() > 0, 'Expected: Create new Field History Records, Actual: Created Field History list is empty');
    }

    @IsTest
    static void logCaseHistory_User_emptyTrigger() {
        FieldHistorySelector.fieldHistorySettingsMock = mockFieldHistorySetting();

        Map<Id, Account> accountsMap = mockAccountRecords(new List<String>{
                'Name'
        }, 1);
        Account accountRecord = accountsMap.values()[0];
        Test.startTest();

        // Simulate After Update Trigger
        FieldHistoryUtil.initReferences(new List<Account>{
                accountRecord
        });
        accountRecord.Name = 'Random';

        FieldHistoryUtil.trackUserChanges(new List<Account>{
                accountRecord
        });

        System.assertEquals(1, FieldHistoryUtil.recordVersionsMap.size());
        System.assertEquals(2, FieldHistoryUtil.recordVersionsMap.get(accountRecord.Id).size());

        FieldHistoryUtil.setContext(Account.getSObjectType().getDescribe().getName());

        FieldHistoryUtil.commitLogs();
        FieldHistoryUtil.resetContext(FieldHistoryUtil.CONTEXT_TRIGGER);
        // End of Trigger After Update

        Test.stopTest();

        List<FieldHistory__c> mockedFieldHistory = FieldHistorySelector.mockFieldHistory;
        System.assert(mockedFieldHistory != null && mockedFieldHistory.size() > 0, 'Expected: Create new Field History Records, Actual: Created Field History list is empty');
    }

    @IsTest
    static void logCaseHistory_User_disabled() {
        FieldHistorySelector.fieldHistorySettingsMock = mockFieldHistorySetting();

        FieldHistorySetting.FieldHistorySetting = new FieldHistorySetting.FieldHistory(true, new Set<String>(), '', '');

        Map<Id, Account> accountsMap = mockAccountRecords(new List<String>{
                'Name'
        }, 1);
        Account accountRecord = accountsMap.values()[0];
        Test.startTest();

        // Simulate After Update Trigger
        FieldHistoryUtil.initReferences(new List<Account>{
                accountRecord
        });
        accountRecord.Name = 'Random';

        FieldHistoryUtil.trackUserChanges(new List<Account>{
                accountRecord
        });

        FieldHistoryUtil.setContext( // Try to override the context by the trigger
                FieldHistoryUtil.CONTEXT_TRIGGER,
                Account.getSObjectType().getDescribe().getName(),
                'AccountTriggerHandler'
        );
        accountRecord.Phone = '1231231234';

        FieldHistorySelector.mockRecords.put(accountRecord.Id, accountRecord);
        FieldHistoryUtil.takeSnapshots(accountsMap.keySet());

        System.assertEquals(0, FieldHistoryUtil.recordVersionsMap.size());

        FieldHistoryUtil.commitLogs();
        FieldHistoryUtil.resetContext(FieldHistoryUtil.CONTEXT_TRIGGER);
        // End of Trigger After Update

        Test.stopTest();

        List<FieldHistory__c> mockedFieldHistory = FieldHistorySelector.mockFieldHistory;
        System.assertEquals(null, mockedFieldHistory, 'Expected: commitLogs to be ignored, Actual: Field History Records were created');
    }

    @IsTest
    static void replaceIdWithName() {
        FieldHistorySelector.fieldHistorySettingsMock = mockFieldHistorySetting();

        Map<Id, Account> accountsMap = mockAccountRecords(new List<String>{
                'Name'
        }, 1);
        Account accountRecord = accountsMap.values()[0];

        FieldHistory__c fieldHistory = FieldHistorySelector.mockFieldHistoryRecords()[0];
        fieldHistory.OriginalValue__c = '';
        fieldHistory.NewValue__c = accountRecord.Id;

        FieldHistorySelector.mockFieldHistory = new List<FieldHistory__c>{
                fieldHistory
        };

        List<Id> historyIds = new List<Id>{
                fieldHistory.Id
        };

        Test.startTest();
        FieldHistoryUtil.replaceIdsWithName(historyIds);
        Test.stopTest();

        List<FieldHistory__c> updatedFieldHistories = FieldHistoryUtil.fieldHistoriesToUpdate;
        System.assertEquals(1, updatedFieldHistories.size());
        System.assertEquals('', updatedFieldHistories[0].OriginalValue__c);
        System.assertEquals('test string', updatedFieldHistories[0].NewValue__c);
    }

    private static Map<Id, Account> mockAccountRecords(List<String> fields, Integer numberOfRecords) {
        List<Id> recordsIds = new List<Id>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            recordsIds.add(FieldHistorySelector.mockId(Account.getSObjectType(), i));
        }

        Map<Id, SObject> rawMockRecords = FieldHistorySelector.mockSObjectRecords(
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