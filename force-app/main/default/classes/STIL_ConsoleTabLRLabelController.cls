/**
* @description : Changed Lab Request Detail page Tab Name
* @author San, Kang : SanKang@autoeveramerica.com | 2024-07-31
* @tecket no: OU24-127
*/
global class STIL_ConsoleTabLRLabelController {

    @AuraEnabled
    public static WorkOrder getLRObj(String recordId) {
        WorkOrder LRobj= new WorkOrder();
        try {
            LRobj = [
                SELECT
                Lab_Request_Number__c
                FROM WorkOrder
                WHERE Id = :recordId
            ];
        }
        catch (Exception ex) {
            System.debug('Exception => ' + ex);
        }
        return LRobj;
    }
}