/**
************************************************************************************************
* @classname         : ScheduleBatchCUVLibDeleteTest
* @description       : Testclass -  to test ScheduleBatchCUVLibDelete class
* @author            : Inho Kim
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       25th Jul 2024          Inho Kim             CCSOM-59        Initial Version
************************************************************************************************
**/
@IsTest
public with sharing class ScheduleBatchCUVLibDeleteTest {
    @IsTest
    static void ScheduleBatchCUVLibDeleteTestDo() {
            Test.startTest();
            ScheduleBatchCUVLibDelete scheduler = new ScheduleBatchCUVLibDelete();
            scheduler.execute(null);
            Test.stopTest();

    }
}