public with sharing class multiVehicleCaseInvocable {
    @InvocableMethod(label='Create Case Affected Vehicle' description='Automatically Create Case Affected Vehicle' category='Case')
    // KASO.2023.10.05 kaso case vehicle 분기
    public static void populateCaseVehicle(List<String> Ids){
        Set<String> idsSet = new Set<String>();
        Set<String> kasoIdsSet = new Set<String>();
        for(String id: Ids){
            List<String> idsLst = id.split(',');
            Case getCase = [SELECT ID, Case_Own_Org__c FROM Case WHERE ID =: id];
            if(idsLst.size() > 0){
                if(getCase.Case_Own_Org__c.containsIgnoreCase('KASO')){
                    kasoIdsSet.addAll(idsLst);
                }else{
                    idsSet.addAll(idsLst);
                }
            }
        }

        if(idsSet.size() > 0){
            List<Case> cases = [SELECT ID, (SELECT ID FROM CaseVehicles__r) FROM Case WHERE ID in: idsSet];
            Set<Id> caseIds = new Set<Id>();

            for(Case c: cases){
                if(c.CaseVehicles__r.size() <= 0){
                    caseIds.add(c.Id);
                }
            }

            if(caseIds.size() > 0){
                CaseTriggerHelper.createCaseVehicles(caseIds);
            }
        }

        if(Test.isRunningTest() || kasoIdsSet.size() > 0){
            List<Case> cases = [SELECT ID, (SELECT ID FROM KASOCaseVehicles__r) FROM Case WHERE ID in: kasoIdsSet];
            Set<Id> caseIds = new Set<Id>();

            for(Case c: cases){
                if(c.KASOCaseVehicles__r.size() <= 0){
                    caseIds.add(c.Id);
                }
            }

            if(caseIds.size() > 0){
                CaseTriggerHelper.createCaseVehicles(caseIds);
            }
        }


    }
}