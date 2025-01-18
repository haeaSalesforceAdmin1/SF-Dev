/**
 * Created by dw.lee on 2023-10-25.
 */

/*
String CRON_EXP1 = '0 15 21 * * ?'; 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.
System.schedule('HMCReferenceDataInsert_ba Schdule',CRON_EXP1, new Get_KASO_HMCReference_API_sc());
*/
global without sharing class HMCReferenceDataInsert_sc implements Schedulable{
    global void execute(SchedulableContext sc) {
        HMCReferenceDataInsert_ba ba = new HMCReferenceDataInsert_ba();
        Database.executeBatch(ba, 100);
    }
}