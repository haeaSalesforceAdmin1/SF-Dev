/**
 * @description       : Case trigger util
 * @author            : bseong@haeaus.com(refactoring)
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : bseong@haeaus.com
 * Modifications Log
 * Ver   Date         Author                     Modification
 *       2023-08-18   Bitna Seong                Created 
**/
public with sharing class CaseTriggerUtil {


    /*** 
     * @description : query HMAReference__c object
     * @param queryFields, queryGroupBy, makeList, fuelTypeList, engineList, modelCodeList, myList
    **/
    public static List<AggregateResult> queryHMAReference(String queryFields,
            String queryGroupBy,
            List<String> makeList,
            List<String> fuelTypeList,
            List<String> engineList,
            List<String> modelCodeList,
            List<String> myList
    ) {

        String hMAFerenceQuery = 'SELECT ';
        hMAFerenceQuery += queryFields;
        hMAFerenceQuery += ' FROM HMAReferenceData__c WHERE Make__c IN : makeList AND FuelType__c IN : fuelTypeList AND EngineDescription__c IN : engineList AND ModelCode__c IN : modelCodeList AND Year__c IN : myList AND VehicleModel__c != NULL';
        hMAFerenceQuery += ' GROUP BY ';
        hMAFerenceQuery += queryGroupBy;
        return Database.query(hMAFerenceQuery);
    }


    public static List<AggregateResult> queryHMCReference(String queryFields,
            String queryGroupBy,
            List<String> makeList,
            List<String> modelCodeList
    ) {

        String hMCFerenceQuery = 'SELECT ';
        hMCFerenceQuery += queryFields;
        hMCFerenceQuery += ' FROM HMCReferenceData__c WHERE Make__c IN : makeList AND ModelCode__c IN : modelCodeList AND VehicleModel__c != NULL';
        hMCFerenceQuery += ' GROUP BY ';
        hMCFerenceQuery += queryGroupBy;
        return Database.query(hMCFerenceQuery);
    }

}