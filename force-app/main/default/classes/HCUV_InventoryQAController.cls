/**
************************************************************************************************
* @classname         : HCUV_InventoryQAController; being used in lwc hcuvInventoryQuickAction 
* @description       : Get the Inventory Record Detail
* @author            : Smriti Gupta
* Test Class		 : HCUV_ContestsIncentivesDataCtrl_Test
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       24th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
public class HCUV_InventoryQAController {
    /**
    * @description - Fetch Inventory record
    * @param - recordId
    * @return HCUV_Inventory__c
    */
	@AuraEnabled(cacheable=true)
    public static HCUV_Inventory__c getInventoryDetail(String recordId){
        HCUV_Inventory__c invRecord = [SELECT Id, Name, StatusDescription__c, Dealer__r.RecordType.DeveloperName, Dealer_Code__c from HCUV_Inventory__c where Id = :recordId];
        return invRecord;
    }
}