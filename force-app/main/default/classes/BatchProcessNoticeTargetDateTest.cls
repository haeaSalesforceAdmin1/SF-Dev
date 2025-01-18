/**
 * @description       : [CCSOM-12,CUVCPO]
 * @author            : inhokim
 * @group             : 
 * @last modified on  : 02-22-2024
 * @last modified by  : inhokim
**/
@IsTest
private class BatchProcessNoticeTargetDateTest {
    @IsTest
    static void BatchProcessNoticeTargetDateTestDo() {
        List<Notice__c> notices = new List<Notice__c>();
        for (Integer i = 0; i < 1; i++) {
            notices.add(new Notice__c(isVisible__c= true, Title__c = 'CUV', Content__c='testcontent', OffDate__c = (Date)Date.today().addDays(i)));
        }
        insert notices;
        
        BatchProcessNoticeTargetDate batch = new BatchProcessNoticeTargetDate();

        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

    }
}