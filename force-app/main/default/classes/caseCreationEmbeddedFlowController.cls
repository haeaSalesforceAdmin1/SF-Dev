/**
 * Created by baltamimi on 2022-03-07.
 */

public without sharing class caseCreationEmbeddedFlowController {
    @AuraEnabled
    public static void updateOwner(Id caseId) {
        System.debug('Values BEFORE:: ' + JSON.serializePretty([SELECT Id,IsAutomationBypassed__c,Owner.Name FROM Case WHERE Id = :caseId]));

        // KASO.2023.05.12 복구시 주석 처리 필요 (1/2)
        Case caseRecord = [Select id, CaseNumber, Case_Own_Org__c, CaseOwner__c, OwnerId, CountrySubmitterWorks__c, SCSCaseRegion__c from Case Where Id = :caseId];
        String caseOwnOrg = caseRecord.Case_Own_Org__c;
        String caseCountrySubmitterWorks = caseRecord.CountrySubmitterWorks__c;
        String caseSCSCaseRegion = caseRecord.SCSCaseRegion__c;
        List<Group> daManagerQueue;

        
        //2023.08.11 각 국가별 caseCountrySubmitterWorks 체크값
        Boolean caseKoreaSumitterWorksFlag = caseCountrySubmitterWorks.containsIgnoreCase('Korea');
        Boolean caseEuropeSumitterWorksFlag = caseCountrySubmitterWorks.containsIgnoreCase('Europe');

        if (caseOwnOrg.containsIgnoreCase('KASO'))
        {
            if (caseKoreaSumitterWorksFlag && caseSCSCaseRegion.containsIgnoreCase('Korea'))
            {
                System.debug('if-else 1');
                System.debug(caseCountrySubmitterWorks);
                System.debug(caseSCSCaseRegion);
                daManagerQueue = [SELECT Id FROM Group WHERE DeveloperName = 'KASOSCSafetyDA'];
            } else if((caseKoreaSumitterWorksFlag || caseEuropeSumitterWorksFlag) && caseSCSCaseRegion.containsIgnoreCase('Europe')) {
                System.debug('if-else 2');
                System.debug(caseCountrySubmitterWorks);
                System.debug(caseSCSCaseRegion);
                daManagerQueue = [SELECT Id FROM Group WHERE DeveloperName = 'KASOSCSafetyGlobalDA'];
            } else if((caseKoreaSumitterWorksFlag || caseEuropeSumitterWorksFlag) && caseSCSCaseRegion.containsIgnoreCase('Other')) {
                System.debug('if-else 3');
                System.debug(caseCountrySubmitterWorks);
                System.debug(caseSCSCaseRegion);
                daManagerQueue = [SELECT Id FROM Group WHERE DeveloperName = 'KASOSCSafetyGlobalDA'];
            } else {
                System.debug('else');
                System.debug(caseCountrySubmitterWorks);
                System.debug(caseSCSCaseRegion);
                //daManagerQueue = [SELECT Id FROM Group WHERE DeveloperName = 'KASOSCSafetyDA'];
                System.debug('caseCountrySubmitterWorks, caseSCSCaseRegion Not right');
            }
        } else {
            System.debug('false');
            System.debug(caseOwnOrg);
            daManagerQueue = [SELECT Id FROM Group WHERE DeveloperName = 'SCSafetyDA'];
        }
        
        // KASO.2023.05.06 ver1.0 소스
        /*
        // KASO.2023.05.06 복구시 주석 처리 필요 (1/2)
        Case caseRecord = [Select id, CaseNumber, Case_Own_Org__c, CaseOwner__c, OwnerId from Case Where Id = :caseId];
        String caseOwnOrg = caseRecord.Case_Own_Org__c;
        List<Group> daManagerQueue;

        if (caseOwnOrg.containsIgnoreCase('KASO'))
        {
            System.debug('true');
            System.debug(caseOwnOrg);
            daManagerQueue = [SELECT Id FROM Group WHERE DeveloperName = 'KASOSCSafetyDA'];
        } else {
            System.debug('false');
            System.debug(caseOwnOrg);
            daManagerQueue = [SELECT Id FROM Group WHERE DeveloperName = 'SCSafetyDA'];
        }
        */

        //KASO.2023.05.06 복구시 주석 제거 필요 (2/2) 
        //List<Group> daManagerQueue = [SELECT Id FROM Group WHERE DeveloperName = 'SCSafetyDA'];   

        if (daManagerQueue.size() > 0) {
            Case caseToUpdate = new Case(Id = caseId, IsAutomationBypassed__c = false, OwnerId = daManagerQueue[0].Id);
            update caseToUpdate;
            System.debug('Values AFTER:: ' + JSON.serializePretty([SELECT Id,IsAutomationBypassed__c,Owner.Name FROM Case WHERE Id = :caseId]));
        } else {
            throw new MissingQueueException('Queue "SCSafetyDA" can not be found, the queue developer name may have changed.');
        }
    }
    
    public class MissingQueueException extends Exception {
    }

    // KASO.2023.05.12 소스 변경!!
    @AuraEnabled 
    public static user fetchUser(){
       User u = [select Profile.Name from User where id =: userInfo.getUserId()];
    return u;
    }
}