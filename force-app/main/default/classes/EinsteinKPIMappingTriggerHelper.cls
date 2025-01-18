public with sharing class EinsteinKPIMappingTriggerHelper {

    public static void handlePopulateName(List<EinsteinKPIMapping__c> einsteinKPIMappings) {

        for(EinsteinKPIMapping__c mapping:einsteinKPIMappings) {
            String nameValue = '';
            if(!String.isBlank(mapping.KPIFieldDescription__c)) {
                nameValue = mapping.EinsteinKPIName__c + ' - ' + mapping.KPIFieldDescription__c;
            }
            else {
                nameValue = mapping.EinsteinKPIName__c + ' - ' + mapping.KPI_Field__c;
            }
            mapping.Name = nameValue.left(80);
        }
    }
}