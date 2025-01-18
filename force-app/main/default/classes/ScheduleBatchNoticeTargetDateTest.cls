/**
 * @description       : [CCSOM-12,CUVCPO]
 * @author            : inhokim
 * @group             : 
 * @last modified on  : 02-19-2024
 * @last modified by  : inhokim
**/
@IsTest
public with sharing class ScheduleBatchNoticeTargetDateTest {
    @IsTest
    static void ScheduleBatchNoticeTargetDateTestDo() {
            // Create sample CRMALog data
            List<Notice__c> notices = new List<Notice__c>();
            for (Integer i = 0; i < 1; i++) {
                notices.add(new Notice__c(isVisible__c= true, Title__c = 'CUV', Content__c='testcontent', OffDate__c = (Date)System.today().addDays(i)));
            }
            insert notices;
    
            Test.startTest();
            ScheduleBatchNoticeTargetDate scheduler = new ScheduleBatchNoticeTargetDate();
            scheduler.execute(null);
            Test.stopTest();

    }
}