@isTest
public with sharing class HMAObjectServiceTest {

    static testMethod void testObjectService1() {
        Account account = new Account(Name='Test Account');
        HMAObjectService.dbInsert(new List<Account>{account});
    }

    static testMethod void testObjectService2() {
        Account account = new Account(Name='Test Account');
        HMAObjectService.dbInsert(new List<Account>{account}, true);
    }


    static testMethod void testObjectService3() {
        Account account = new Account(Name='Test Account');
        HMAObjectService.dbInsert(new List<Account>{account}, true);

        Test.startTest();
        HMAObjectService.dbDelete(account);
        Test.stopTest();
    }

    static testMethod void testObjectService4() {
        Account account = new Account(Name='Test Account');
        HMAObjectService.dbInsert(new List<Account>{account}, true);

        Test.startTest();
        HMAObjectService.dbDelete(new List<Account>{account});
        Test.stopTest();
    }

    static testMethod void testObjectService5() {
        Account account = new Account(Name='Test Account');
        HMAObjectService.dbInsert(new List<Account>{account}, true);

        Test.startTest();
        account.Name = null;
        HMAObjectService.updateRecordsAndReturnErrorMap(new List<Account>{account});
        Test.stopTest();
    }

    static testMethod void testObjectService6() {
        Account account = new Account(Name='Test Account');
        HMAObjectService.dbInsert(new List<Account>{account}, true);

        Test.startTest();
        account.Name = null;
        HMAObjectService.updateRecordsAndLogErrors(new List<Account>{account}, null, null);
        Test.stopTest();
    }

    static testMethod void testObjectService7() {
        Account account = new Account(Name=null);
        Test.startTest();
        HMAObjectService.insertRecordsAndLogErrors(new List<Account>{account}, null, null);
        Test.stopTest();
    }

    static testMethod void testObjectService8() {
        Account account = new Account(Name='Test');
        Test.startTest();
        HMAObjectService.insertRecordsAndLogErrors(new List<Account>{account}, null, null);
        HMAObjectService.dmlUpdate(new List<Account>{account});
        Test.stopTest();
    }

    static testMethod void testObjectService9() {
        Account account = new Account(Name='Test');
        Test.startTest();
        HMAObjectService.dmlInsert(new List<Account>{account});
        Test.stopTest();
    }

    static testMethod void testObjectService10() {
        Account account = new Account(Name='Test');
        Test.startTest();
        HMAObjectService.dbInsert(account);
        HMAObjectService.dbUpdate(account);
        Test.stopTest();
    }

    static testMethod void testObjectService11() {
        Account account = new Account(Name='Test');
        Test.startTest();
        HMAObjectService.dbInsert(account);
        HMAObjectService.dbUpdate(new List<Account>{account});
        Test.stopTest();
    }

    static testMethod void testObjectService12() {
        Account account = new Account(Name='Test');
        Test.startTest();
        HMAObjectService.dbInsert(account);
        HMAObjectService.dbUpdate(new List<Account>{account}, true);
        Test.stopTest();
    }
}