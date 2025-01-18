public without sharing class FilePreviewController {

    @AuraEnabled
    public static void deleteContentDocument(Id ContentDocumentId) {
        Database.delete(ContentDocumentId);
    }

    //DPM-5633
    @AuraEnabled
    public static String getFileId(Id recordId) {
        return [SELECT ActionPlanFileId__c FROM  Evaluation__c  WHERE Id =:recordId LIMIT 1].ActionPlanFileId__c;
    }

    //DPM-5633
    @AuraEnabled
    public static String getStatus(Id recordId) {
        return [SELECT Action_Plan_Status__c FROM  Evaluation__c  WHERE Id =:recordId AND ActionPlanFileId__c !=null LIMIT 1].Action_Plan_Status__c;
    }

}