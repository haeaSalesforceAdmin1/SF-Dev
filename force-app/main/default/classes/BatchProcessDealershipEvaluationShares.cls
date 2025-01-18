public with sharing class BatchProcessDealershipEvaluationShares implements Database.Batchable<SObject> {

    public String query;
    public List<HMAUserProvisioningDealerWrapper> dealerProvisionWrappers;
    public Set<String> dealerCodes; 
    public Map<String, ObjectAccess__mdt> objectAccessMap; 
    public Map<String, List<String>> userIdDealerCodeMap;

    private static final String EVALUATION_COMPLETED_STATUS = 'Completed';

    public BatchProcessDealershipEvaluationShares(List<HMAUserProvisioningDealerWrapper> dealerProvisionWrappers, Set<String> dealerCodes, Map<String, ObjectAccess__mdt> objectAccessMap, Map<String, List<String>> userIdDealerCodeMap) {
        this.dealerProvisionWrappers = dealerProvisionWrappers;
        this.dealerCodes = dealerCodes;
        this.objectAccessMap = objectAccessMap;
        this.userIdDealerCodeMap = userIdDealerCodeMap;

        this.dealerCodes.addAll(getDealerCodesForExistingShares());
    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        Set<String> userIds = userIdDealerCodeMap.keySet();
        query = 'select Id, Account__r.DealerCode__c, OwnerId from Evaluation__c ';
        query += ' where Account__r.DealerCode__c in :dealerCodes ';

        return Database.getQueryLocator(query);
    }

    private Set<String> getDealerCodesForExistingShares() {
        List<AggregateResult> results = [select Parent.Account__r.DealerCode__c DealerCode from Evaluation__Share where UserOrGroupId in :userIdDealerCodeMap.keySet() group by Parent.Account__r.DealerCode__c];
        Set<String> dealerCodes = new Set<String>();

        for(AggregateResult result:results) {
            dealerCodes.add((String)result.get('DealerCode'));
        }
        return dealerCodes;
    }

    public void execute(Database.BatchableContext BC, List<Evaluation__c> evaluations) {

        Map<String, Map<Id, Evaluation__c>> evaluationDealerMap = getDealerEvaluationMap(evaluations);
        Map<String, Map<String, List<Evaluation__Share>>> existingShareMapForEvaluationShares = getMapOfExistingEvaluationSharesForUserByDealerCode(evaluations, userIdDealerCodeMap.keyset());

        HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__c');

        for(HMAUserProvisioningDealerWrapper dealerProvisionWrapper:dealerProvisionWrappers) {
            for(HMADealerObjectAccessWrapper dealerWrapper:dealerProvisionWrapper.objectAccessTypes) {   
                if(objectAccessMap.containsKey(dealerWrapper.objectAccessType) && !String.isBlank(objectAccessMap.get(dealerWrapper.objectAccessType).ObjectAPINames__c) && objectAccessMap.get(dealerWrapper.objectAccessType).ObjectAPINames__c.contains('Evaluation__c')) {
                    if(evaluationDealerMap.containsKey(dealerWrapper.dealerCode)) {
                        for(Evaluation__c evaluation:evaluationDealerMap.get(dealerWrapper.dealerCode).values()) {
                            String accessLevel = objectAccessMap.get(dealerWrapper.objectAccessType).AccessLevel__c;
                            apexSharing.add(evaluation, dealerProvisionWrapper.userProvision.User__c, accessLevel, Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c );
                        }
                        if(existingShareMapForEvaluationShares.containskey(dealerProvisionWrapper.userProvision.User__c)) {
                            existingShareMapForEvaluationShares.get(dealerProvisionWrapper.userProvision.User__c).remove(dealerWrapper.dealerCode);
                        }
                    }
                }
            }
        }
        apexSharing.share();

        for(String existingShareKeyUser:existingShareMapForEvaluationShares.keySet()) {
            for(String existingShareKeyDealer:existingShareMapForEvaluationShares.get(existingShareKeyUser).keySet()) {
                for(Evaluation__Share evaluationShare:existingShareMapForEvaluationShares.get(existingShareKeyUser).get(existingShareKeyDealer)) {
                    Evaluation__c evaluation = evaluationDealerMap.get(existingShareKeyDealer).get(evaluationShare.ParentId);
                    apexSharing.remove(evaluation, existingShareKeyUser, evaluationShare.AccessLevel, Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c);
                }
            }
        }
        apexSharing.unshare();
    }
    
    private static Map<String, Map<String, List<Evaluation__Share>>> getMapOfExistingEvaluationSharesForUserByDealerCode(List<Evaluation__c> evaluations, Set<String> userIds) {
        Map<String, Map<String, List<Evaluation__Share>>> existingShareMapForAllEvaluationShares = new Map<String, Map<String, List<Evaluation__Share>>>();

        System.debug(LoggingLevel.ERROR, userIds);
        List<Evaluation__Share> evaluationShares = [select Id, Parent.Account__r.DealerCode__c, UserOrGroupId, AccessLevel from Evaluation__Share 
                                                    where ParentId in :evaluations and UserOrGroupId in :userIds 
                                                    and Parent.Status__c = :EVALUATION_COMPLETED_STATUS];

        for(Evaluation__Share evaluationShare:evaluationShares) {
            if(!existingShareMapForAllEvaluationShares.containsKey(evaluationShare.UserOrGroupId)) {
                existingShareMapForAllEvaluationShares.put(evaluationShare.UserOrGroupId, new Map<String, List<Evaluation__Share>>());
            }

            if(!existingShareMapForAllEvaluationShares.get(evaluationShare.UserOrGroupId).containsKey(evaluationShare.Parent.Account__r.DealerCode__c)) {
                existingShareMapForAllEvaluationShares.get(evaluationShare.UserOrGroupId).put(evaluationShare.Parent.Account__r.DealerCode__c, new List<Evaluation__Share>());
            }
            existingShareMapForAllEvaluationShares.get(evaluationShare.UserOrGroupId).get(evaluationShare.Parent.Account__r.DealerCode__c).add(evaluationShare);
        }

        System.debug(LoggingLevel.ERROR, existingShareMapForAllEvaluationShares);
        return existingShareMapForAllEvaluationShares;
    }

    private Map<String, Map<Id, Evaluation__c>> getDealerEvaluationMap(List<Evaluation__c> evaluations) {
        
        Map<String, Map<Id, Evaluation__c>> dealerEvaluationMap = new Map<String, Map<Id, Evaluation__c>>();
        for(Evaluation__c evaluation:evaluations) {
            if(!dealerEvaluationMap.containskey(evaluation.Account__r.DealerCode__c)) {
                dealerEvaluationMap.put(evaluation.Account__r.DealerCode__c,  new Map<Id, Evaluation__c>());
            }
            dealerEvaluationMap.get(evaluation.Account__r.DealerCode__c).put(evaluation.Id, evaluation);
        }
        return dealerEvaluationMap;
    }

    public void finish(Database.BatchableContext BC){

    }
}