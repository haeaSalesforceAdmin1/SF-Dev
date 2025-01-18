@isTest
public without sharing class Trigger_DiffRecordTest {


    static testMethod void testTriggerDiffRecord1() {
        Account account = new Account(Name = 'Test');
        insert account;

        Map<Id, Account> oldMap = new Map<Id, Account>();
        oldMap.put(account.Id, account);

        Map<Id, Account> newMap = new Map<Id, Account>();
        newMap.put(account.Id, account);

        Trigger_DiffRecord.getRecordsWithDiff(oldMap, newMap, 'Name');
    }

    static testMethod void testTriggerDiffRecord2() {
        Account account = new Account(Name = 'Test');
        insert account;

        List<Account> oldList = new List<Account>();
        List<Account> newList = new List<Account>();
        Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, 'Name');

        oldList.add(account);
        try{
            Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, 'Name');
        }
        catch(Exception e) {

        }

        newList.add(account);
        Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, 'Name');
    }

    static testMethod void testTriggerDiffRecord3() {
        Account account = new Account(Name = 'Test');
        insert account;

        List<Account> oldList = new List<Account>();
        oldList.add(account);

        List<Account> newList = new List<Account>();
        newList.add(account);

        Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, 'Name', 'Test');
    }

    static testMethod void testTriggerDiffRecord4() {
        Account account = new Account(Name = 'Test');
        insert account;

        List<Account> oldList = new List<Account>();
        List<Account> newList = new List<Account>();
        Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, 'Name', 'Test2');
        oldList.add(account);

        try{
            Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, 'Name', 'Test2');
        }
        catch(Exception e) {
            
        }
        newList.add(new Account(Id = account.Id, Name = 'Test2'));

        Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, 'Name', 'Test2');
    }

    static testMethod void testTriggerDiffRecord5() {
        Account account = new Account(Name = 'Test');
        insert account;

        List<Account> oldList = new List<Account>();
        oldList.add(account);

        List<Account> newList = new List<Account>();
        newList.add(new Account(Id = account.Id, Name = 'Test2'));

        Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, new Set<String>{'Name'});
    }

    static testMethod void testTriggerDiffRecord6() {
        Account account = new Account(Name = 'Test');
        insert account;

        List<Account> oldList = new List<Account>();
        List<Account> newList = new List<Account>();
        Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, new Set<String>{'Name'}, 'Test2', 'Test');
        oldList.add(account);
        try{
            Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, new Set<String>{'Name'}, 'Test2', 'Test');
        }
        catch(Exception e) {

        }
        newList.add(new Account(Id = account.Id, Name = 'Test2'));

        Trigger_DiffRecord.getRecordsWithDiff(oldList, newList, new Set<String>{'Name'}, 'Test2', 'Test');
    }
}