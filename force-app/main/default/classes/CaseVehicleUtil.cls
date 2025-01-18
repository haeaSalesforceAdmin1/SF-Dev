/**
 * Created by baltamimi on 2022-01-12.
 */

public without sharing class CaseVehicleUtil {
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

    public static String GenerateVehicleInfo(List<CaseVehicle__c> caseVehicles) {

        String finalVehicleInfo = '';
        for (CaseVehicle__c vhc : caseVehicles) {
            String vehicleInfo = '';
            if (vhc.Make__c <> null) {
                vehicleInfo += '<p><b>Make:</b> ' + String.join(vhc.Make__c.split(';'), ',') + '</p>';
            }
            if (vhc.Model__c <> null) {
                vehicleInfo += '<p><b>Model Name:</b> ' + String.join(vhc.Model__c.split(';'), ',') + '</p>';
            }
            if (vhc.VehicleYear__c <> null) {
                String formattedString = CaseVehicleUtil.getFormattedYearsString(vhc.VehicleYear__c);

                vehicleInfo += '<p><b>Year:</b> ' + formattedString + '</p>';
            }
            if (vhc.ModelCode__c <> null) {
                vehicleInfo += '<p><b>Model Code:</b> ' + String.join(vhc.ModelCode__c.split(';'), ',') + '</p>';
            }

            if (!String.isEmpty(vehicleInfo)) {
                finalVehicleInfo += vehicleInfo + '<br>';
            }

        }
        
        return finalVehicleInfo;
    }

    // KASO.2023.10.03 복구시 아래 함수 주석 처리 필요
    public static String GenerateVehicleInfo(List<KASOCaseVehicle__c> caseVehicles) {

        String finalVehicleInfo = '';
        for (KASOCaseVehicle__c vhc : caseVehicles) {
            String vehicleInfo = '';
            if (vhc.Make__c <> null) {
                vehicleInfo += '<p><b>Make:</b> ' + String.join(vhc.Make__c.split(';'), ',') + '</p>';
            }
            if (vhc.Model__c <> null) {
                vehicleInfo += '<p><b>Model Name:</b> ' + String.join(vhc.Model__c.split(';'), ',') + '</p>';
            }
            if (vhc.VehicleYear__c <> null) {
                String formattedString = CaseVehicleUtil.getFormattedYearsString(vhc.VehicleYear__c);

                vehicleInfo += '<p><b>Year:</b> ' + formattedString + '</p>';
            }
            if (vhc.ModelCode__c <> null) {
                vehicleInfo += '<p><b>Model Code:</b> ' + String.join(vhc.ModelCode__c.split(';'), ',') + '</p>';
            }

            if (!String.isEmpty(vehicleInfo)) {
                finalVehicleInfo += vehicleInfo + '<br>';
            }

        }
        
        return finalVehicleInfo;
    }
}