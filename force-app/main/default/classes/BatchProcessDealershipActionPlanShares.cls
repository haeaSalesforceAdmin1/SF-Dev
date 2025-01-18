public without sharing class BatchProcessDealershipActionPlanShares implements Database.Batchable<SObject> {
    
    public String query;
    public List<HMAUserProvisioningDealerWrapper> dealerProvisionWrappers;
    public Set<String> dealerCodes; 
    public Map<String, ObjectAccess__mdt> objectAccessMap; 
    public Map<String, List<String>> userIdDealerCodeMap;

    private static final String ACTION_PLAN_DRAFT_STATUS = 'Draft - Awaiting Signoff';
    private static final String ACTION_PLAN_IN_PROGRESS_STATUS = 'In Progress - Signed-off';
 

    public BatchProcessDealershipActionPlanShares(List<HMAUserProvisioningDealerWrapper> dealerProvisionWrappers, Set<String> dealerCodes, Map<String, ObjectAccess__mdt> objectAccessMap, Map<String, List<String>> userIdDealerCodeMap) {
        this.dealerProvisionWrappers = dealerProvisionWrappers;
        this.dealerCodes = dealerCodes;
        this.objectAccessMap = objectAccessMap;
        this.userIdDealerCodeMap = userIdDealerCodeMap;

        this.dealerCodes.addAll(getDealerCodesForExistingShares());
    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        Set<String> userIds = userIdDealerCodeMap.keySet();
        query = 'select Id, Account__r.DealerCode__c, OwnerId from Action_Plan__c ';
        query += ' where Account__r.DealerCode__c in :dealerCodes ';
        query += ' and Status__c != :ACTION_PLAN_DRAFT_STATUS';
        query += ' and Status__c != :ACTION_PLAN_IN_PROGRESS_STATUS';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Action_Plan__c> actionPlans) {

        Map<String, Map<Id, Action_Plan__c>> actionPlanDealerMap = getDealerActionPlanMap(actionPlans);
        Map<String, Map<String, List<Action_Plan__Share>>> existingShareMapForAllActionPlanShares = getMapOfExistingActionPlanSharesForUserByDealerCode(actionPlans, userIdDealerCodeMap.keyset());

        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__c');

        for(HMAUserProvisioningDealerWrapper dealerProvisionWrapper:dealerProvisionWrappers) {
            for(HMADealerObjectAccessWrapper dealerWrapper:dealerProvisionWrapper.objectAccessTypes) {   
                if(objectAccessMap.containsKey(dealerWrapper.objectAccessType) && !String.isBlank(objectAccessMap.get(dealerWrapper.objectAccessType).ObjectAPINames__c) && objectAccessMap.get(dealerWrapper.objectAccessType).ObjectAPINames__c.contains('Action_Plan__c')) {
                    if(actionPlanDealerMap.containsKey(dealerWrapper.dealerCode)) {
                        for(Action_Plan__c actionPlan:actionPlanDealerMap.get(dealerWrapper.dealerCode).values()) {
                            String accessLevel = objectAccessMap.get(dealerWrapper.objectAccessType).AccessLevel__c;
                            apexSharing.add(actionPlan, dealerProvisionWrapper.userProvision.User__c, accessLevel, Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c );
                        }
                        if(existingShareMapForAllActionPlanShares.containskey(dealerProvisionWrapper.userProvision.User__c)) {
                            existingShareMapForAllActionPlanShares.get(dealerProvisionWrapper.userProvision.User__c).remove(dealerWrapper.dealerCode);
                        }
                    }
                }
            }
        }
        apexSharing.share();

        for(String existingShareKeyUser:existingShareMapForAllActionPlanShares.keySet()) {
            for(String existingShareKeyDealer:existingShareMapForAllActionPlanShares.get(existingShareKeyUser).keySet()) {
                for(Action_Plan__Share actionPlanShare:existingShareMapForAllActionPlanShares.get(existingShareKeyUser).get(existingShareKeyDealer)) {
                    Action_Plan__c actionPlan = actionPlanDealerMap.get(existingShareKeyDealer).get(actionPlanShare.ParentId);
                    apexSharing.remove(actionPlan, existingShareKeyUser, actionPlanShare.AccessLevel, Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
                }
            }
        }
        apexSharing.unshare();
    }
    
    private static Map<String, Map<String, List<Action_Plan__Share>>> getMapOfExistingActionPlanSharesForUserByDealerCode(List<Action_Plan__c> actionPlans, Set<String> userIds) {
        Map<String, Map<String, List<Action_Plan__Share>>> existingShareMapForAllActionPlanShares = new Map<String, Map<String, List<Action_Plan__Share>>>();

        System.debug(LoggingLevel.ERROR, userIds);
        List<Action_Plan__Share> actionPlanShares = [select Id, Parent.Account__r.DealerCode__c, UserOrGroupId, AccessLevel from Action_Plan__Share 
                                                    where ParentId in :actionPlans and UserOrGroupId in :userIds 
                                                    and Parent.Status__c != :ACTION_PLAN_DRAFT_STATUS and Parent.Status__c != :ACTION_PLAN_IN_PROGRESS_STATUS];

        for(Action_Plan__Share actionPlanShare:actionPlanShares) {
            if(!existingShareMapForAllActionPlanShares.containsKey(actionPlanShare.UserOrGroupId)) {
                existingShareMapForAllActionPlanShares.put(actionPlanShare.UserOrGroupId, new Map<String, List<Action_Plan__Share>>());
            }

            if(!existingShareMapForAllActionPlanShares.get(actionPlanShare.UserOrGroupId).containsKey(actionPlanShare.Parent.Account__r.DealerCode__c)) {
                existingShareMapForAllActionPlanShares.get(actionPlanShare.UserOrGroupId).put(actionPlanShare.Parent.Account__r.DealerCode__c, new List<Action_Plan__Share>());
            }
            existingShareMapForAllActionPlanShares.get(actionPlanShare.UserOrGroupId).get(actionPlanShare.Parent.Account__r.DealerCode__c).add(actionPlanShare);
        }

        System.debug(LoggingLevel.ERROR, existingShareMapForAllActionPlanShares);
        return existingShareMapForAllActionPlanShares;
    }

    private Map<String, Map<Id, Action_Plan__c>>  getDealerActionPlanMap(List<Action_Plan__c> actionPlans) {
        
        Map<String, Map<Id, Action_Plan__c>> dealerActionPlanMap = new Map<String, Map<Id, Action_Plan__c>>();
        for(Action_Plan__c actionPlan:actionPlans) {
            if(!dealerActionPlanMap.containskey(actionPlan.Account__r.DealerCode__c)) {
                dealerActionPlanMap.put(actionPlan.Account__r.DealerCode__c,  new Map<Id, Action_Plan__c>());
            }
            dealerActionPlanMap.get(actionPlan.Account__r.DealerCode__c).put(actionPlan.Id, actionPlan);
        }
        return dealerActionPlanMap;
    }

    private Set<String> getDealerCodesForExistingShares() {
        List<AggregateResult> results = [select Parent.Account__r.DealerCode__c DealerCode from Action_Plan__Share where UserOrGroupId in :userIdDealerCodeMap.keySet() 
                                            and Parent.Status__c != :ACTION_PLAN_DRAFT_STATUS 
                                            and Parent.Status__c != :ACTION_PLAN_IN_PROGRESS_STATUS group by Parent.Account__r.DealerCode__c];
        Set<String> dealerCodes = new Set<String>();

        for(AggregateResult result:results) {
            dealerCodes.add((String)result.get('DealerCode'));
        }
        return dealerCodes;
    }

    public void finish(Database.BatchableContext BC){
        BatchProcessDealershipEvaluationShares batchProcessActionPlans = new BatchProcessDealershipEvaluationShares(dealerProvisionWrappers, dealerCodes, objectAccessMap, userIdDealerCodeMap);
        Database.executeBatch(batchProcessActionPlans);
    }
}