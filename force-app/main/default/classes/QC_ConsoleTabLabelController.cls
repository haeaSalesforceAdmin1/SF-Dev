//  @description : Changed Lab Request Detail page Tab Name
//  @author San, Kang : SanKang@autoeveramerica.com | 2024-09-06
//  @tecket no: SO-462

global class QC_ConsoleTabLabelController {

    @AuraEnabled
    public static Case getQCObj(String recordId) {
        Case QualityCaseObject = new Case();
        try {
            QualityCaseObject = [
                SELECT
                SCSCaseNumber__c
                FROM Case
                WHERE Id = :recordId AND RecordType.DeveloperName IN ('Q_DA','SCDC')
                ];
            }
        catch (Exception ex) {
            System.debug('Exception => ' + ex);
        }
        return QualityCaseObject;
    }
}