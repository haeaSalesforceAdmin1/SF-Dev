/**
 * @description       : [CCSOM-12,CUVCPO]
 * @author            : inhokim
 * @group             : 
 * @last modified on  : 02-22-2024
 * @last modified by  : inhokim
**/
@isTest
public class NoticeTriggerHandlerTest {

    static testMethod void testNoticeTriggerHandlerInsertMultiVisible() {
        Notice__c notice = new Notice__c(Title__c = 'Test Notice1' , isVisible__c = false, appType__c = 'CUV', TargetUser__c = 'INTERNAL USER');
        HMAObjectService.dbInsert(notice);
        Notice__c notice2 = new Notice__c(Title__c = 'Test Notice2' , isVisible__c = false, appType__c = 'CUV', TargetUser__c = 'INTERNAL USER');
        HMAObjectService.dbInsert(notice2);
        Notice__c notice3 = new Notice__c(Title__c = 'Test Notice3' , isVisible__c = false, appType__c = 'CUV', TargetUser__c = 'ALL');
        HMAObjectService.dbInsert(notice3);
        Notice__c notice4 = new Notice__c(Title__c = 'Test Notice4' , isVisible__c = false, appType__c = 'CUV', TargetUser__c =  'ALL');
        HMAObjectService.dbInsert(notice4);
        
        List<Notice__c> notices_before = [select Id from Notice__c];
        System.assertEquals(4, notices_before.size());

    }

    static testMethod void testNoticeTriggerHandlerUpdateMultiVisible() {
        Notice__c notice2 = new Notice__c(Title__c = 'test2' ,Content__c ='cont' , isVisible__c = false, appType__c = 'CUV', TargetUser__c ='INTERNAL USER');
        insert notice2;
        notice2.Title__c = 'test22';
        update notice2; // it will not fail
        List<Notice__c> notices_after = [select Id from Notice__c WHERE isVisible__c = true];
        System.assertEquals(0, notices_after.size());

    }
    static testMethod void controllerTest(){
        Notice__c notice5 = new Notice__c(Title__c = 'Test Notice5' , isVisible__c = false, appType__c = 'CUV', TargetUser__c =  'ALL');
        HMAObjectService.dbInsert(notice5);
        Notice__c notice3 = [select Id from Notice__c WHERE isVisible__c = false LIMIT 1];
        NoticeController.retrieveNoticeDetail('CUV' ,'INTERNAL USER');
    }
    @IsTest(SeeAllData=true)
    static void controllerTestAll(){
        Notice__c notice4 = new Notice__c(Title__c = 'test2' ,Content__c ='cont' , isVisible__c = false, appType__c = 'CUV', TargetUser__c ='ALL');
        insert notice4;
        Notice__c notice5 = new Notice__c(Title__c = 'test2' ,Content__c ='cont' , isVisible__c = true, appType__c = 'CUV', TargetUser__c ='INTERNAL USER');
        insert notice5;
        NoticeController.retrieveNoticeDetail('CUV' ,'ALL');
        NoticeController.retrieveNoticeDetail('CUV' ,'INTERNAL USER');
        NoticeController.getCurrentAppLightningPage();
    }


}