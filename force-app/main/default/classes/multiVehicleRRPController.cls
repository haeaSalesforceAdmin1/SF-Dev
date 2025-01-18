/**
* @description : RRP Project
* @author San, Kang : SanKang@autoeveramerica.com 
*/
public with sharing class multiVehicleRRPController {

    private static String getSObjectType(String recordId) {
        RRP__c rrpObj = [SELECT SafetyCase__r.Case_Own_Org__c FROM RRP__c WHERE Id =:recordId];
        
        return (String)rrpObj.SafetyCase__r.Case_Own_Org__c;
    }

    @AuraEnabled
    public static List<SObject> getVehicleRRP(String caseId) {
        System.debug('RRPId'+caseId);
        String obj = getSObjectType(caseId);
        List<SObject> VehicleList = new List<SObject>();
        String SelectQuery = '';
        String FromQuery = '';
        String WhereQuery = '';
        try{
            RRP__c rrpObj  = [SELECT SafetyCase__c FROM RRP__c WHERE id =:caseId ];
            Id caseobjId = rrpObj.SafetyCase__c;
            SelectQuery = 'SELECT Make__c,Model__c,VehicleYear__c,ModelCode__c,FuelType__c,EngineDescription__c,TransmissionDescription__c ,DrivetrainDescription__c  FROM ';
            FromQuery = ' CaseVehicle__c ';
            if (obj == 'KASO') {
                FromQuery = ' KASOCaseVehicle__c ';
            }
            WhereQuery = ' WHERE Case__c =:caseobjId ';
            
            VehicleList = Database.query(SelectQuery + FromQuery + WhereQuery);

            for(SObject sobjectObj : VehicleList) {
                sobjectObj.put('VehicleYear__c',getFormattedYearsString(String.valueOf(sobjectObj.get('VehicleYear__c'))));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n\n' + e.getStackTraceString());
        }
        return VehicleList;
    }
    
    public static String getFormattedYearsString(String vehicleYears) {
        List<String> yearsStrings = !String.isEmpty(vehicleYears) && vehicleYears.trim().length() > 1 ? vehicleYears.split(';') : new List<String>();

        if (yearsStrings.size() == 0) {
            return '';
        }

        yearsStrings.sort();
        List<String> formattedList = new List<String>();

        for (Integer i = 0; i < yearsStrings.size(); i++) {
            String startValue = yearsStrings[i];
            String endValue = startValue;
            for (Integer j = i + 1; j < yearsStrings.size(); j++) {
                if (Integer.valueOf(endValue) == Integer.valueOf(yearsStrings[j]) - 1) {
                    endValue = yearsStrings[j];
                } else {
                    break;
                }
                i++;
            }

            formattedList.add((startValue.equalsIgnoreCase(endValue) ? startValue : startValue + '-' + endValue));
        }

        return String.join(formattedList, '; ');
    }
}