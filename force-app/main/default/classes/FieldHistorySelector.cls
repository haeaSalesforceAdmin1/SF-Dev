/**
 * Created by baltamimi on 2022-03-15.
 */

public inherited sharing class FieldHistorySelector {
    public static List<FieldHistory__c> getFieldHistories(List<Id> recordIds) {
        return (!Test.isRunningTest() ? [
                SELECT
                        Id,
                        OriginalValue__c,
                        NewValue__c
                FROM FieldHistory__c
                WHERE Id IN :recordIds
        ] : mockFieldHistoryRecords());
    }

    public static Map<Id, SObject> getSObjects(String sObjectType, List<String> fields, List<Id> recordIds) {
        String query = String.format('SELECT {0} FROM {1} WHERE Id IN :recordIds',
                new List<String>{
                        String.join(fields, ','),
                        sObjectType
                });
        System.debug('FieldHistorySelector/getSObjects query:: ' + query);
        return (!Test.isRunningTest() ?
                new Map<Id, SObject>(Database.query(query)) :
                mockSObjectRecords(sObjectType, fields, recordIds));
    }

    public static List<FieldHistorySetting__mdt> getFieldHistorySetting(String sObjectType) {
        return (!Test.isRunningTest() ? [
                SELECT
                        FieldsNames__c,
                        DisableHistoryTracking__c,
                        FieldHistoryLookupField__c,
                        AppName__c
                FROM FieldHistorySetting__mdt
                WHERE DeveloperName LIKE :sObjectType
        ] : mockFieldHistorySetting(sObjectType));
    }

    @TestVisible
    private static List<FieldHistorySetting__mdt> fieldHistorySettingsMock;
    private static List<FieldHistorySetting__mdt> mockFieldHistorySetting(String sObjectType) {
        if(fieldHistorySettingsMock != null && fieldHistorySettingsMock.size() > 0){
            return fieldHistorySettingsMock;
        }


        return new List<FieldHistorySetting__mdt>();
    }

    @TestVisible
    private static Map<Id, SObject> mockRecords { get; set; }
    @TestVisible
    private static Map<Id, SObject> mockSObjectRecords(String sObjectType, List<String> fields, List<Id> recordIds) {
        if (mockRecords != null) {
            return mockRecords;
        }

        mockRecords = new Map<Id, SObject>();
        for (Id recordId : recordIds) {
            SObject record = (SObject) Type.forName(sObjectType).newInstance();
            for (String fieldName : fields) {
                String fieldType = getFieldType(sObjectType, fieldName);
                if (fieldType.equalsIgnoreCase('REFERENCE')) {
                    record.put(fieldName, mockId(record.getSObjectType(), 1));
                } else {
                    Object randomValue = generateInitialRandomValue(fieldType);
                    record.put(fieldName, randomValue);
                }
            }
            record.put('Id', recordId);
            mockRecords.put(record.Id, record);
        }

        return mockRecords;
    }

    private static Object generateInitialRandomValue(String fieldType) {
        switch on fieldType {
            when 'STRING' {
                return 'test string';
            } when 'PHONE' {
                return '3432023795';
            }
            // Uncomment field types from the list below when necessary to cover additional future test cases
//            when 'EMAIL' {
//                return 'test@email.com';
//            } when 'BOOLEAN' {
//                return false;
//            } when 'INTEGER' {
//                return 1;
//            }
        }
        return null;
    }

    private static String getFieldType(String sObjectTypeName, String fieldName) {
        SObjectType sobjectType = ((SObject) Type.forName(sObjectTypeName).newInstance()).getSObjectType();

        Map<String, Schema.SObjectField> fields = sobjectType.getDescribe().fields.getMap();
        String fieldType = fields.get(fieldName)?.getDescribe()?.getType()?.name();
        return !String.isEmpty(fieldType) ? fieldType : '';
    }

    @TestVisible
    private static List<FieldHistory__c> mockFieldHistory;
    @TestVisible
    private static List<FieldHistory__c> mockFieldHistoryRecords() {
        if (mockFieldHistory != null) {
            return mockFieldHistory;
        }
        mockFieldHistory = new List<FieldHistory__c>{
                new FieldHistory__c(Id = mockId(FieldHistory__c.getSObjectType(), 0), FieldName__c = 'Phone', OriginalValue__c = '', NewValue__c = '1231231234', RunningContext__c = FieldHistoryUtil.CONTEXT_TRIGGER, UpdatedByContext__c = 'AccountTriggerHandler', TrackedByAppName__c = 'testApp'),
                new FieldHistory__c(Id = mockId(FieldHistory__c.getSObjectType(), 1), FieldName__c = 'Name', OriginalValue__c = 'Test0', NewValue__c = 'Random', RunningContext__c = FieldHistoryUtil.CONTEXT_FLOW, UpdatedByContext__c = 'Test Flow', TrackedByAppName__c = 'testApp')
        };

        return mockFieldHistory;
    }

    @TestVisible
    private static String mockId(SObjectType sObjectType, Integer index) {
        return sObjectType.getDescribe().getKeyPrefix().rightPad(15 - (String.valueOf(index).length()), '0') + String.valueOf(index);
    }
}