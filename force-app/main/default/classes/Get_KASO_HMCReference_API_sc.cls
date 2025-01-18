/*
String CRON_EXP1 = '0 0 21 * * ?'; 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.
System.schedule('Get_KASO_HMCReference_API Schdule',CRON_EXP1, new Get_KASO_HMCReference_API_sc());
*/
global without sharing class Get_KASO_HMCReference_API_sc implements Schedulable{
    global void execute(SchedulableContext sc) {
        Get_KASO_HMCReference_API.Get_KASO_HMCReference_Interface();
    }
}