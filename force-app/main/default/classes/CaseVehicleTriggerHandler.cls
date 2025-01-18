/**********************************************************************
* Name : CaseVehicleTriggerHandler
* Author: Pratz Joshi
* Description : Apex Class which updates Case.VehicleInfo__c field with 
* the Make/Model/Year info from CaseVehicle__c record/s created through
* SODAS Integration
* Project : SODAS/CMT Integration
* Date Created : 06/16/2022
**********************************************************************/
public class CaseVehicleTriggerHandler {
    public static void updateCaseVehicleInfoField (List<CaseVehicle__c> lstCaseVehicles){
        User IntegrationUser = [SELECT Id FROM User WHERE UserName =:Label.lblIntegrationUserName];
        //User TestUser = [SELECT Id FROM User WHERE Username = 'prathamesh.joshi@salesforce.com.stage'];
   
        //Get the Vehicle Info String using the Case Vehicle Data 
        List<CaseVehicle__c> lstCaseVehicles1 = new List<CaseVehicle__c>();
        List<CaseVehicle__c> lstCaseVehicles2 = new List<CaseVehicle__c>();
        String strVehicleInfo;
        Set<Id> setCaseIds = new Set<Id>();
        for(CaseVehicle__c cv: lstCaseVehicles){
            //if(cv.CreatedById == IntegrationUser.Id || cv.CreatedById == TestUser.Id){
            if(cv.CreatedById == IntegrationUser.Id){setCaseIds.add(cv.Case__c);}    
        }  
        if(!setCaseIds.isEmpty()){lstCaseVehicles1 = [SELECT Id, Make__c, Model__c, VehicleYear__c, ModelCode__c FROM CaseVehicle__c WHERE Case__c IN :setCaseIds];    }
        for(CaseVehicle__c cv: lstCaseVehicles){   
            //if((cv.CreatedById == IntegrationUser.Id || cv.CreatedById == TestUser.Id) && (!lstCaseVehicles1.isEmpty())){
            if((cv.CreatedById == IntegrationUser.Id) && (!lstCaseVehicles1.isEmpty())){
            for(CaseVehicle__c cvrecord:lstCaseVehicles1){lstCaseVehicles2.add(cvrecord);}   
        }
    }    
    if(!lstCaseVehicles2.isEmpty()){strVehicleInfo = CaseVehicleUtil.GenerateVehicleInfo(lstCaseVehicles2);    }
    
    //Update the Case's Vehicle Info field with the Case Vehicle Info string value
    Map<Id, Case> mapCases = new Map<Id, Case>();
    for(CaseVehicle__c record: lstCaseVehicles){
        //if(record.CreatedById == IntegrationUser.Id || record.CreatedById == TestUser.Id){
        if(record.CreatedById == IntegrationUser.Id){if(String.isNotBlank(strVehicleInfo)) {mapCases.put(record.Case__c, new Case(Id=record.Case__c,VehicleInfo__c=strVehicleInfo));}}   
    }
    if(!mapCases.isEmpty()){UPDATE mapCases.values();    }
        
  }
}