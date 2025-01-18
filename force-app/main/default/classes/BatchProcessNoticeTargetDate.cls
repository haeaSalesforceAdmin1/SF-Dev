/**
 * @description       : 
 * @author            : inhokim
 * @group             : 
 * @last modified on  : 02-22-2024
 * @last modified by  : inhokim
**/
public class BatchProcessNoticeTargetDate implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date todayVar = Date.today() ;  //Date.today().format('MM/dd/YYYY');
        System.debug('BatchProcessNoticeTargetDate started.');
        String query = 'SELECT Id, isVisible__c, OffDate__c ' +
                        ' FROM Notice__c ' +
                        ' WHERE OffDate__c <= :todayVar '+
                        ' AND isVisible__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> records) {
        try {
            System.debug('Update ' + records.size() + ' records to be invisible');
            List<Notice__c> notices = (List<Notice__c>)records;
            for(Notice__c notice : notices){
                notice.isVisible__c = false;
            }
            update records;
        } catch (Exception e) {
                return;
            }

        // Date today = Date.today();
        // try {
        // List<Notice__c>  recordsToUpdate = [SELECT Id, isVisible__c, OffDate__c
        //                FROM Notice__c WHERE OffDate__c <= :today AND isVisible__c = true];
        //     for(Notice__c record : recordsToUpdate) {
        //         record.isVisible__c = false;
        //     }
        //     update recordsToUpdate;
        // } catch (Exception e) {
        //     return;
        // }


    }

    public void finish(Database.BatchableContext BC) {
        System.debug('BatchProcessNoticeTargetDate finished.');
    }
}