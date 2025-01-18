public without sharing class HMAUtility {


    public static String getCurrentEnvironment() {

        CurrentEnvironment__c currentEnvironment = CurrentEnvironment__c.getInstance();
        System.debug(LoggingLevel.ERROR, currentEnvironment);
        return currentEnvironment.Environment__c;
    }

    public static String getRecordTypeIdForOrg(String recordTypeName, String objectPrefix) {

        String currentEnvironment = getCurrentEnvironment();
        if(test.isRunningTest()){
            currentEnvironment='PROD';
        }
        String fieldName =  currentEnvironment + '' + 'RecordTypeID' + objectPrefix + recordTypeName + '__c';
        DPMConfigurationSettings__c dpmConfigurationSettings = DPMConfigurationSettings__c.getInstance();



        return (String)dpmConfigurationSettings.get(fieldName);
    }


    public static String getRecordTypeIdForObjectDeveloperName(String objectName, String developerName) {

        List<RecordType> recordTypes = [select Id from RecordType where SObjectType = :objectName and DeveloperName = :developerName];

        if(!recordTypes.isEmpty()) {
            return recordTypes[0].Id;
        }
        return null;
    }

    /**
    * [Method Description] Fetch the community name based on argument networkId
    * Created by [MinheeKim] on [2024-06-17] for [DPM-4035]
    */
    public static String getCommunityName(String networkId){
        String communityName = '';
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Id = :networkId];
        if(!netObjList.isEmpty()){
            communityName = netObjList[0].Name;
        }
        
        if(String.isBlank(communityName) && Test.isRunningTest()){
            return HMAConstants.HMA_COMMUNITY_NAME;
        } 
        return communityName;
    }

    
}