/**
 * @description       : update Case for SODAS
 * @author            : bseong@haeaus.com(refactoring)
 * @group             : 
 * @last modified on  : 08-22-2023
 * @last modified by  : bseong@haeaus.com
 * Modifications Log
 * Ver   Date         Author                     Modification
 *       2023-08-22   Bitna Seong                Refactoring   
**/

public with sharing class CaseSodasAlertHelper {

    /*** 
     * @description : check SODAS alerts (before insert)
     * @param newCaseList
    **/
    public static void caseForSodasAlertInsert(List<Case> newCaseList){

        for(Case caseObj : newCaseList){
            if(caseObj.SODAS_Alert_ID__c != null) caseObj.SODAS_Multiple_Alerts__c = caseObj.SODAS_Alert_ID__c ;
        }
    }

    /*** 
     * @description : check SODAS alerts and update SODAS multiple alert (before update)
     * @param oldMapCases, newMapCases
    **/
    public static void caseForSodasAlertUpdate( Map<Id, Case> oldMapCases, Map<Id, Case> newMapCases){

        for(Case newCaseObj : newMapCases.values()){
            Case oldCaseObj = oldMapCases.get(newCaseObj.Id);

            if( newCaseObj.SODAS_Alert_ID__c != oldCaseObj.SODAS_Alert_ID__c){
               String oldSodasMultipleAlert = oldCaseObj.SODAS_Multiple_Alerts__c;
               if(oldSodasMultipleAlert==null){
                    newCaseObj.SODAS_Multiple_Alerts__c = newCaseObj.SODAS_Alert_ID__c ;
                }else{
                    newCaseObj.SODAS_Multiple_Alerts__c = oldSodasMultipleAlert+';'+newCaseObj.SODAS_Alert_ID__c ;
                }
            }

        }
    }
}