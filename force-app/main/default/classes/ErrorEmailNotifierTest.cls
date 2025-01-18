@isTest
public with sharing class ErrorEmailNotifierTest {

    @isTest
    static void testNotifyAdmins() {

        Test.startTest();
        try {
            
            throw new EvaluationTriggerHelper.evalNameDuplException('Test exception for ErrorEmailNotifier');
        } catch (Exception e) {
            
            ErrorEmailNotifier.notifyAdmins(e, 'ErrorEmailNotifierTest');
        }
        Test.stopTest();


    }
}