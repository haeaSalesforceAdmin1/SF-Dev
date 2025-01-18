/**
************************************************************************************************
* @classname         : ScheduleBatchCUVLibPublishTest
* @description       : Testclass -  to test ScheduleBatchCUVLibPublish class
* @author            : Inho Kim
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       25th Jul 2024          Inho Kim             CCSOM-59        Initial Version
************************************************************************************************
**/
@IsTest
public with sharing class ScheduleBatchCUVLibPublishTest {
    @IsTest
    static void ScheduleBatchCUVLibPublishTestDo() {
    
            Test.startTest();
            ScheduleBatchCUVLibPublish scheduler = new ScheduleBatchCUVLibPublish();
            scheduler.execute(null);
            Test.stopTest();

    }
}