/**********************************************************************
* Name : CaseVehicleTrigger
* Author: Pratz Joshi
* Description : Apex Trigger which executes on the event of CaseVehicle__c record creation
* Project : SODAS/CMT Integration
* Date Created : 06/16/2022
**********************************************************************/
trigger CaseVehicleTrigger on CaseVehicle__c (after insert) {    
    //Call Method which updates Case.VehicleInfo__c field with the Make/Model/Year info from CaseVehicle__c record/s created through SODAS Integration
    CaseVehicleTriggerHandler.updateCaseVehicleInfoField(Trigger.new);
}