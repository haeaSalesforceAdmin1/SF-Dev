/**
 * @description       : test class for CaseSodasAlertHelper.cls 
 * @author            : bseong@haeaus.com
 * @group             : 
 * @last modified on  : 08-23-2023
 * @last modified by  : bseong@haeaus.com
**/
@isTest
public class CaseSodasAlertHelperTest {
    static testMethod void setData() {
        List<Case> caseList = new List<Case>();
        Map<Id, Case> oldMapCases = new Map<Id, Case>();
        Map<Id, Case> newMapCases = new Map<Id, Case>();

        HMAReferenceData__c hmaReferenceTest = CMT_DataFactory.createHMAReferencee();
        insert hmaReferenceTest;

        Case newCase = CMT_DataFactory.createCase();
        newCase.MY__c ='2021';
        newCase.SODAS_Alert_ID__c = 'sodasAlertTest';
        caseList.add(newCase);

        insert newCase;

        //when SODAS alert is not empty
        //for same key of both oldMapCases and newMapCases, put same case Id even though value Case is different
        Case oldCase = CMT_DataFactory.createCase();
        oldCase.SODAS_Alert_ID__c = 'sodasAlertTest2';
        oldMapCases.put(newCase.Id, oldCase);
        newMapCases.put(newCase.Id, newCase);


        Test.startTest();
            CaseSodasAlertHelper.caseForSodasAlertInsert(caseList);

            //When SODAS alert is not empty
            CaseSodasAlertHelper.caseForSodasAlertUpdate(oldMapCases, newMapCases);

            //when SOdAS alert is empty
            oldCase.SODAS_Alert_ID__c = null;
            newCase.SODAS_Alert_ID__c = 'sodasAlertTest3';
            CaseSodasAlertHelper.caseForSodasAlertUpdate(oldMapCases, newMapCases);
        Test.stopTest();


    }
}