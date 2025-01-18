/**
************************************************************************************************
* @classname         : HCUV_QuickLinksController; being used in lwc hcuv_QuickLinks 
* @description       : Get the Quick Links Records
* @author            : Smriti Gupta
* Test Class 		 : HCUV_QuickLinksController_Test
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       18th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
public with sharing class HCUV_QuickLinksController {
    /**
    * @description - Fetch quick links Information
    * @param - networkId
    * @return List<HCUV_Quick_Link__c>
    */
    @AuraEnabled(cacheable=true)   
    public static List<HCUV_Quick_Link__c> getQuickLinks(String networkId) {
        List<String> recordTypeList= HCUV_Utility.getRecordTypeList (HCUV_Constants.QL_Object_API_Name, networkId, '');
        //fetch the quick link records
        List<HCUV_Quick_Link__c> quickLinkLists = [Select Id, Name, Link__c 
                                                   FROM HCUV_Quick_Link__c 
                                                   WHERE RecordType.DeveloperName IN:recordTypeList ORDER BY Name];
        return quickLinkLists;
    }
}