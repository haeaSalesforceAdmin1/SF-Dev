/**
 * Created by dw.lee on 2023-10-25.
 */

@IsTest
public with sharing class HMCReferenceDataInsert_sc_Test {

    @IsTest
    static void runTest(){
        Test.startTest();
        String CRON_EXP1 = '0 15 21 * * ?';
        System.schedule('HMCReferenceDataInsert_sc_Test',CRON_EXP1, new HMCReferenceDataInsert_sc());
        Test.stopTest();
    }

}