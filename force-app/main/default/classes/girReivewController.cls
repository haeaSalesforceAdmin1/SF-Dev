/**
 * @description       : 
 * @author            : User.name
 * @group             : Hyundai-autoever
 * @last modified on  : 08-08-2023
 * @last modified by  : User.name
**/
public with sharing class girReivewController {

	@AuraEnabled(cacheable=TRUE)
    public static List<String> getPickListValuesIntoList(Id flowRecordId){
		
		List<String> pickListValuesList= new List<String>();
		Case caseRegion = [SELECT SCSCaseRegion__c FROM Case WHERE id =:flowRecordId];
        Schema.DescribeFieldResult fieldResult = Case.GIR_clone_regions__c.getDescribe();
		List<Schema.PicklistEntry> lstPickListValues = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : lstPickListValues){
                
			if(caseRegion.SCSCaseRegion__c == 'North America' && pickListVal.getValue() != 'NASO') {
                pickListValuesList.add(pickListVal.getValue());
            }
			if(caseRegion.SCSCaseRegion__c == 'Korea' && pickListVal.getValue() != 'KASO') {
				pickListValuesList.add(pickListVal.getValue());
            }
			if(caseRegion.SCSCaseRegion__c == 'Europe' && pickListVal.getValue() != 'EASO') {
				pickListValuesList.add(pickListVal.getValue());
            }
			if(caseRegion.SCSCaseRegion__c == 'Other' && pickListVal.getValue() != 'Other') {
               pickListValuesList.add(pickListVal.getValue());
            }
		}


		return pickListValuesList;
    }

	@AuraEnabled(cacheable=TRUE)
    public static String getSelectClonRegion(List<String> selectedValueString){
	
		String girCloneRegions = String.join(selectedValueString, ';');
		return girCloneRegions;
    }


	@AuraEnabled(cacheable=true)
    public static List<String> getSelectOtherSafetyOffice(Id recordId){

		Case getCaseValue = [SELECT Other_Safety_Office_Potentially_Affected__c FROM Case WHERE Id=:recordId];
		String OtherSafetyOfficeValue = getCaseValue.Other_Safety_Office_Potentially_Affected__c;
		List<String> OtherSafetyOfficeList = new List<String>();
		String[] splitStr = OtherSafetyOfficeValue.split(';');
		System.debug('splitStr'+splitStr);
		for(String str : splitStr){
    		OtherSafetyOfficeList.add(str);
		}

		return splitStr;
    }



}