/**
 * @description       : 
 * @author            : inhokim
 * @group             : 
 * Created by [inho kim] on [01-18-2024] for []
 * Edited by [Minhee Kim] on [12-03-2924] for [DPM-5934] Insert Dealer Code and RolebyAccesstype to CRMALog obj
**/
@RestResource(urlMapping='/CRMALogger')
global with sharing class CRMALogger {

    /**
     * Description: 
     * Created by [inho kim] on [01-18-2024] for []
     * Edited by [Minhee Kim] on [12-03-2924] for [DPM-5934] Insert Dealer Code and RolebyAccesstype to CRMALog obj
    */
    @HttpPost  
    global static String logCRMAInteraction() {
        System.debug('CRMA  Logging Apex called');
        try{
            ApexStepRequest stepRequest = new ApexStepRequest(new ApexStepRequest.Parameter[]{
                new ApexStepRequest.Parameter('interactionType', ApexStepRequest.ParameterType.STRING_PARAM),
                    new ApexStepRequest.Parameter('interaction', ApexStepRequest.ParameterType.STRING_PARAM),
                    new ApexStepRequest.Parameter('interactionDetail', ApexStepRequest.ParameterType.STRING_PARAM),
                    new ApexStepRequest.Parameter('interactionMetric', ApexStepRequest.ParameterType.STRING_PARAM),
                    new ApexStepRequest.Parameter('url', ApexStepRequest.ParameterType.STRING_PARAM),
                    new ApexStepRequest.Parameter('dealerCode', ApexStepRequest.ParameterType.STRING_PARAM), //Added to get accountId by MinheeKim -12.03.2024 - DPM-5934
                    new ApexStepRequest.Parameter('appType', ApexStepRequest.ParameterType.STRING_PARAM)
                    });
            String interactionType= stepRequest.getStringParam('interactionType', null);
            String interaction= stepRequest.getStringParam('interaction', null);
            String interactionDetail= stepRequest.getStringParam('interactionDetail', null);
            String interactionMetric = stepRequest.getStringParam('interactionMetric', null);
            String url = stepRequest.getStringParam('url', null);
            String dealerCode = stepRequest.getStringParam('dealerCode', null);
            String appType = stepRequest.getStringParam('appType', null);
            System.debug('CRMA  interaction type :'+interactionType);
            System.debug('CRMA  interaction url :'+url);
            System.debug('CRMA  appType :'+appType);
            
            //create log entry
            CRMALog__c crmaLog = new CRMALog__c();
            crmaLog.Interaction_Type__c =interactionType;
            crmaLog.Interaction_Value__c=interaction;
            crmaLog.Interaction_Detail__c = interactionDetail;
            crmaLog.Interaction_Metric__c = interactionMetric;
            crmaLog.UserSession__c=UserInfo.getSessionId();
            crmaLog.DealerCode__c = dealerCode;//Added to update dealer code by Minheekim - DPM-5934 12.03.2024
            crmaLog.Role__c = [SELECT RoleByAccesstype__c FROM User WHERE Id = :UserInfo.getUserId()].RoleByAccesstype__c; //Added to update Role by Minheekim - DPM-5934 12.03.2024
            //Added by Areum on 2024-01-23 For HVM-459
            crmaLog.AppType__c = appType == 'CUV' ? 'CUV' : appType;
            insert crmaLog;
            
            
            Integer returnVal =1;
            //create return
            List<Map<String, Object>> returnItems = new List<Map<String, Object>>();
            Map<String, Object> curRow = new Map<String, Object>();
            curRow.put('all', 'all');
            curRow.put('Log', returnVal);
            returnItems.add(curRow);
                
            
            return JSON.serialize(new ApexStepResponse(returnItems));
            
        } 
        catch(Exception ex){
            
            //Catch but do not throw - log is not critical
            System.debug('Error in logging CRMA interaction : '+ex);
            return '';
        }
    }


    //import getRelatedContacts from '@salesforce/apex/CRMALogger.fetchLogRecord';
    @AuraEnabled//fetchLogRecord
    public static String fetchLogRecord(String interactionType, String interaction, String interactionDetail, String interactionMetric,String url, String appType) {
		
        //create log entry
        CRMALog__c crmaLog = new CRMALog__c();
        crmaLog.Interaction_Type__c =interactionType;
        crmaLog.Interaction_Value__c=interaction;
        crmaLog.Interaction_Detail__c = interactionDetail;
        crmaLog.Interaction_Metric__c = interactionMetric;
        crmaLog.UserSession__c=UserInfo.getSessionId();
        crmaLog.AppType__c = appType;
        insert crmaLog;

        Integer returnVal =1;
        //create return
        List<Map<String, Object>> returnItems = new List<Map<String, Object>>();
        Map<String, Object> curRow = new Map<String, Object>();
        curRow.put('all', 'all');
        curRow.put('Log', returnVal);
        returnItems.add(curRow);
        return JSON.serialize(returnItems);
        

    }
}