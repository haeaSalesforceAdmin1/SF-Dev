public with sharing class chageOwnerController {
    @AuraEnabled
    public static void changeOwner(List<Id> recordIds, Id newOwnerId) {
        if (recordIds == null || recordIds.isEmpty() || newOwnerId == null) {
            throw new AuraHandledException('레코드와 새로운 소유자를 올바르게 선택하세요.');
        }
        
        List<Evaluation__c> evaluations = [SELECT Id, OwnerId FROM Evaluation__c WHERE Id IN :recordIds];

        for (Evaluation__c eval : evaluations) {
            eval.OwnerId = newOwnerId;
        }

        update evaluations;
    }
}