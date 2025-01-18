/**
* @class : Get_KASO_VINInfo_API.cls
* @Author : JIHYE
* @Date : 2023-08-09, 수 오후 1:30
* @Version : 1.0
* @Method :
*
* @Modified
* ---------------------------------------------
* NO | Date | Modifier | Description
* ---------------------------------------------
* 1. | 2023-08-09 | JIHYE | 최초작성
* 2. | 2023-08-25 | jiae.tak@daeunextier.com | getGirRequiredPickListValue 추가
**/


public with sharing class girPreCheckController {
    
    @AuraEnabled(cacheable=true)
    public static List<string> getAffectedOffiesPickListValue(Id recordId){

        List<String> pickListValuesList= new List<String>();
        Case caseNumber = [SELECT SCSCaseNumber__c FROM Case WHERE id =:recordId];
        String caseNumberPrefix = caseNumber.SCSCaseNumber__c.substring(0,1) ;
       
        Schema.DescribeFieldResult fieldResult = Case.Other_Safety_Office_Potentially_Affected__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //Exclude the current case region and add the rest to the list
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getValue());

            if(caseNumberPrefix == pickListVal.getValue().substring(0,1) && pickListVal.getValue() != 'None')
                continue;
        
			pickListValuesList.add(pickListVal.getLabel());
		}     

        return pickListValuesList;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGirRequiredPickListValue(Id recordId){
        List<String> pickListValuesList = new List<String>();

        Schema.DescribeFieldResult fieldResult = Case.GIR_Required__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry pickListVal : ple){
            System.debug('GIR_Required__c :: ' + pickListVal.getValue());
            pickListValuesList.add(pickListVal.getLabel());

        }
        return pickListValuesList;
    }
}