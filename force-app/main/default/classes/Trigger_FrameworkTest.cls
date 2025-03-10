@isTest
public with sharing class Trigger_FrameworkTest {


    private static Trigger_Framework.Parameters params;
    private static Trigger_Settings__c cs = Trigger_Framework.getConfiguration();

    private static void setup(){
        list<Account> triggerOld, triggerNew;
        map<id,Account> oldmap, newmap;
        Boolean isBefore,isAfter,isDelete,isInsert,isUpdate,isUndelete,isExecuting=true;
        isBefore=true;
        isInsert=true;
        triggerNew = new list<Account>{new Account()};
        params = new Trigger_Framework.Parameters(triggerOld, triggerNew, oldmap, newmap, isBefore,isAfter,isDelete,isInsert,isUpdate,isUndelete,isExecuting);
        Trigger_Framework.testContext = params;

        cs.EnableDiagnostics__c = true;
        insert cs;
        cs = Trigger_Framework.getConfiguration();
    }

    /**
    * @date 11/9/2020
    * @description This method tests the framework using the sample account trigger.
    */
    @isTest
    public static void testDebugInfoTrigger() {
        Debug_Info__c testRecord = new Debug_Info__c();

        insert testRecord;

        system.debug(cs);
        cs.KillList__c = 'Account';
        cs.KillSwitch__c = true;
        insert cs;

        update testRecord;

        cs.KillSwitch__c = false;
        cs.EmailDebugInfoLog__c = true;
        cs.MaxDebugInfoRecords__c = 7;
        cs.DebugInfoRecipientEmails__c = 'test@test.com';
        update cs;
        update testRecord;

        update testRecord;
        delete testRecord;
        undelete testRecord;

        baseHandler handler = new baseHandler('beforeInsert');

        String idPrefix = Schema.SObjectType.Debug_Info__c.getKeyPrefix();
        Map<Id, Debug_Info__c> mapForTest = new Map<Id, Debug_Info__c>(new List<Debug_Info__c>{
                new Debug_Info__c(Id = idPrefix+'000000000000')
        });

        Trigger_Framework.Parameters tp = new Trigger_Framework.Parameters(mapForTest.values(), mapForTest.values(), mapForTest, mapForTest,
                true, true, true,
                true, true, true, true);


        handler.execute(tp, 'beforeInsert');
    }

    @IsTest
    public static void testMissingHandler(){
        try {
            //ApexClass used as example of sobject that will not have trigger handler.
            Trigger_Framework.createHandler(ApexClass.getSObjectType());
        }
        catch(Trigger_Framework.FrameworkException ex){
            system.assertequals('No Trigger handler registered for Object Type: ApexClass',ex.getMessage());
        }
    }


    //verifies that trigger factory calls the correct handler method. asserts are in base handler inner class.
    @IsTest
    public static void testBaseTriggerFlow(){
        setup();

        params.tEvent = Trigger_Framework.TriggerEvent.beforeInsert;
        Trigger_Framework.dispatchHandler(Account.sObjectType,new baseHandler('beforeInsert'));

        params.tEvent = Trigger_Framework.TriggerEvent.afterInsert;
        Trigger_Framework.dispatchHandler(Account.sObjectType,new baseHandler('afterInsert'));

        params.tEvent = Trigger_Framework.TriggerEvent.beforeUpdate;
        Trigger_Framework.dispatchHandler(Account.sObjectType,new baseHandler('beforeUpdate'));

        params.tEvent = Trigger_Framework.TriggerEvent.afterUpdate;
        Trigger_Framework.dispatchHandler(Account.sObjectType,new baseHandler('afterUpdate'));

        params.tEvent = Trigger_Framework.TriggerEvent.beforeDelete;
        Trigger_Framework.dispatchHandler(Account.sObjectType,new baseHandler('beforeDelete'));

        params.tEvent = Trigger_Framework.TriggerEvent.afterDelete;
        Trigger_Framework.dispatchHandler(Account.sObjectType,new baseHandler('afterDelete'));

        params.tEvent = Trigger_Framework.TriggerEvent.afterUndelete;
        Trigger_Framework.dispatchHandler(Account.sObjectType,new baseHandler('afterUndelete'));

        system.debug(Trigger_Framework.CurrentLog());
        list<String> curLog = Trigger_Framework.CurrentLog().split('\n');
        system.assert(curLog[0].endsWith('beforeInsert Trigger for Account Object'));
        system.assert(curLog[1].endsWith('AccountTriggerhandler.bulkBefore'));
        system.assert(curLog[2].endsWith('AccountTriggerDispatcher.beforeInsert'));

        system.assert(curLog[3].endsWith('afterInsert Trigger for Account Object'));
        system.assert(curLog[4].endsWith('AccountTriggerhandler.bulkAfter'));
        system.assert(curLog[5].endsWith('AccountTriggerDispatcher.afterInsert'));

        system.assert(curLog[6].endsWith('beforeUpdate Trigger for Account Object'));
        system.assert(curLog[7].endsWith('AccountTriggerhandler.bulkBefore'));
        system.assert(curLog[8].endsWith('AccountTriggerDispatcher.beforeUpdate'));

        system.assert(curLog[9].endsWith('afterUpdate Trigger for Account Object'));
        system.assert(curLog[10].endsWith('AccountTriggerhandler.bulkAfter'));
        system.assert(curLog[11].endsWith('AccountTriggerDispatcher.afterUpdate'));

        system.assert(curLog[12].endsWith('beforeDelete Trigger for Account Object'));
        system.assert(curLog[13].endsWith('AccountTriggerhandler.bulkBefore'));
        system.assert(curLog[14].endsWith('AccountTriggerDispatcher.beforeDelete'));

        system.assert(curLog[15].endsWith('afterDelete Trigger for Account Object'));
        system.assert(curLog[16].endsWith('AccountTriggerhandler.bulkAfter'));
        system.assert(curLog[17].endsWith('AccountTriggerDispatcher.afterDelete'));

        system.assert(curLog[18].endsWith('afterUndelete Trigger for Account Object'));
        system.assert(curLog[19].endsWith('AccountTriggerhandler.bulkAfter'));
        system.assert(curLog[20].endsWith('AccountTriggerDispatcher.afterUndelete'));
    }

    @IsTest
    public static void testRecursiveTriggerFlow(){
        setup();

        params.tEvent = Trigger_Framework.TriggerEvent.afterInsert;
        Trigger_Framework.dispatchHandler(Account.sObjectType,new accountHandler('afterInsert'));


        //another after insert (should not kick off recursion).
        params.tEvent = Trigger_Framework.TriggerEvent.afterInsert;
        Trigger_Framework.dispatchHandler(Account.sObjectType,new accountHandler('afterInsert'));

        list<String> curLog = Trigger_Framework.CurrentLog().split('\n');
        system.assert(curLog[0].endswith('afterInsert Trigger for Account Object'));
        system.assert(curLog[1].endswith('AccountTriggerhandler.bulkAfter'));
        system.assert(curLog[2].endswith('AccountTriggerDispatcher.afterInsert'));
        system.assert(curLog[3].endswith('afterInsert Trigger for Contact Object'));
        system.assert(curLog[4].endswith('ContactTriggerhandler.bulkAfter'));
        system.assert(curLog[5].endswith('ContactTriggerDispatcher.afterInsert'));
        system.assert(curLog[6].endswith('afterInsert Trigger for Account Object'));
        system.assert(curLog[7].endswith('AccountTriggerhandler.bulkAfter'));
        system.assert(curLog[8].endswith('AccountTriggerDispatcher.afterInsertRecursion'));
        system.assert(curLog[9].endswith('afterUpdate Trigger for Account Object'));
        system.assert(curLog[10].endswith('AccountTriggerhandler.bulkAfter'));
        system.assert(curLog[11].endswith('AccountTriggerDispatcher.afterUpdate'));
    }

    @IsTest
    public static void testMaxDebugLog(){
        setup();

        cs.EmailDebugInfoLog__c = true;
        cs.DebugInfoRecipientEmails__c = 'test@texample.com';
        update cs;
        cs = Trigger_Framework.getConfiguration();

        list<Debug_Info__c> existingRecords = new list<Debug_Info__c>();
        for(Integer i=0;i<200;i++){
            existingRecords.add(new Debug_Info__c());
        }
        insert existingRecords;

        Test.startTest();
        Trigger_Framework.CheckDebugInfoLog();
        Test.stopTest();

        existingRecords = [select id from Debug_Info__c];

        system.assertequals(100,existingRecords.size(),'Excepted 100 debug entries remaining which is the default maximum.');

        //scenario 3: validate that the email message with deleted debug logs is sent to the appropriate emails based on the custom setting.
    }

    @IsTest
    public static void testOldDebugLog(){
        setup();

        cs.EmailDebugInfoLog__c = true;
        cs.DebugInfoRecipientEmails__c = 'test@texample.com';
        update cs;
        cs = Trigger_Framework.getConfiguration();

        Debug_Info__c di = new Debug_Info__c();
        insert di;
        Test.setCreatedDate(di.id,DateTime.newInstance(2016,01,01));

        Test.startTest();
        Trigger_Framework.CheckDebugInfoLog();
        Test.stopTest();

        list<Debug_Info__c> existingRecords = [select id from Debug_Info__c];

        system.assert(existingRecords.isEmpty(),'Debug entries greater than 365 days old should be deleted.');

        //scenario 3: validate that the email message with deleted debug logs is sent to the appropriate emails based on the custom setting.
    }

    @IsTest
    public static void testHandlerWithException(){
        setup();

        cs.EmailDebugInfoLog__c = true;
        cs.DebugInfoRecipientEmails__c = 'test@texample.com';
        update cs;
        cs = Trigger_Framework.getConfiguration();


        Test.startTest();
        try{
            params.tEvent = Trigger_Framework.TriggerEvent.beforeInsert;
            params.triggerObject = 'Account';
            Trigger_Framework.dispatchHandler(Account.sObjectType,new exceptionHandler());
        }
        catch(Exception ex) {
            System.assertEquals('Divide by 0',ex.getMessage());
        }
        Test.stopTest();

        list<Debug_Info__c> existingRecords = [select id, DebugData__c from Debug_Info__c];
        system.assertEquals(1, existingRecords.size());
        list<String> debugInfo = existingRecords[0].DebugData__c.split('\n');
        system.debug(debugInfo);
        system.assert(debugInfo[0].endsWith('beforeInsert Trigger for Account Object'));
        system.assert(debugInfo[1].endsWith('AccountTriggerhandler.bulkBefore'));
        system.assert(debugInfo[2].endsWith('AccountTriggerDispatcher.beforeInsert'));
        system.assert(debugInfo[3].contains('Divide by 0'));

    }



    /**
     * review uses of Test.IsRunningTest()
     * verify bulkBefore and bulkAfter
     */


    /**
    * @date 3/26/2018
    * @description This method tests getting the handler names.

    //TODO: implement this test method properly. Need to break up getTriggerHandler method.
    @isTest
    public static void test_getTriggerHandlerName(){
        System.assertEquals('AccountTriggerHandler', Trigger_Factory.getTriggerHandler(Account));
        System.assertEquals('Debug_InfoTriggerHandler', Trigger_Factory.getTriggerHandler(Debug_Info__c));
        String longName = 'AReallyLongObjectNameGreaterThan23Characters__c';
        String result = ''+ longName.substring(0, 23)+'TriggerHandler';
        System.assertEquals(result, Trigger_Factory.getTriggerHandler(CollaborationGroupMemberRequest));
    }
    */



    //used to verify execution flow of the trigger framework.
    static boolean runbulkBefore=false;
    static boolean runbulkAfter=false;
    public class baseHandler extends Trigger_Framework.BaseHandler {
        private string executing;
        public baseHandler(string methodToExecute){
            this.executing = methodToExecute;
        }


        public override void bulkBefore(){
           // system.assert(!runbulkBefore,'bulkBefore has already run.');
            runbulkBefore=true;
        }

        public override void bulkAfter(){
           // system.assert(!runbulkAfter,'bulkAfter has already run.');
            runbulkAfter=true;
        }

        public override void beforeInsert(List<SObject> newList){System.assertEquals('beforeInsert',executing);}
        public override void afterInsert(Map<Id, SObject> newMap){System.assertEquals('afterInsert',executing);}

        public override void beforeDelete(Map<Id, SObject> oldMap){System.assertEquals('beforeDelete',executing);}
        public override void afterDelete(Map<Id, SObject> oldMap){System.assertEquals('afterDelete',executing);}

        public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){System.assertEquals('afterUpdate',executing);}
        public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){System.assertEquals('beforeUpdate',executing);}

        public override void afterUndelete(Map<Id, SObject> newMap){System.assertEquals('afterUndelete',executing);}
    }

    //used to verify recursion logic of the trigger framework
    public class accountHandler extends Trigger_Framework.BaseHandler {
        private string executing;
        public accountHandler(string methodToExecute){
            this.executing = methodToExecute;
        }

        public override void afterInsert(Map<Id, SObject> newMap){
            System.assertEquals('afterInsert',executing);

            //"insert" of Contact. Should NOT go into recursive method as top-level trigger is Account.
            params.tEvent = Trigger_Framework.TriggerEvent.afterInsert;
            params.triggerObject = 'Contact';
            Trigger_Framework.dispatchHandler(Contact.sObjectType,new baseHandler('afterInsert'));

            //"insert" of Account. SHOULD go into recursive method.
            params.tEvent = Trigger_Framework.TriggerEvent.afterInsert;
            params.triggerObject = 'Account';
            Trigger_Framework.dispatchHandler(Account.sObjectType,new accountHandler('afterInsertRecursive'));

            //"update" of Account. Should not go into Recursive as initiated DML was afterInsert.
            params.tEvent = Trigger_Framework.TriggerEvent.afterUpdate;
            params.triggerObject = 'Account';
            Trigger_Framework.dispatchHandler(Account.sObjectType,new accountHandler('afterUpdate'));

        }
        public override void afterInsertRecursive(Map<Id, SObject> newMap){System.assertEquals('afterInsertRecursive',executing);}


        public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){System.assertEquals('afterUpdate',executing);}
    }

    public class exceptionHandler extends Trigger_Framework.BaseHandler {

        public override void beforeInsert(list<Sobject> newObjects){
            //do some stuff. throw exception
            integer i = 1/0;
        }
    }


}