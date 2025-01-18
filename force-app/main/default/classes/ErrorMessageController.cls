/**
     * [Class Description] If Original_Partner_User_Id is inactive, publish the error to aura component
     * Created by [MinheeKim] on [2024-05-01] for [DPM-5400]
     * Edited by [MinheeKim] on [2024-05-21] for [DPM-5533] added logic for checking the owner is active or not when RM clicked send back
    */
public class ErrorMessageController {
    @AuraEnabled
    public static String getEventData(String recordId) {
        System.debug('recordId: '+recordId);
        Action_Plan__c actionplan = [Select Owner.IsActive, ApprovalStatus__c, Original_Partner_User_ID__c, Original_Partner_User_ID__r.IsActive  from Action_Plan__c where Id= :recordId Limit 1]; 
        Id originalUserId = actionplan.Original_Partner_User_ID__c;
        System.debug('originalUserId: '+originalUserId);
        String message ='';
        if(actionplan.ApprovalStatus__c != 'Submitted for Regional Approval'){
            Boolean active = false;
            if(originalUserId!=null){
                active =  actionplan.Original_Partner_User_ID__r.IsActive ;
            }
            
            if(!active){
                message = 'The new owner of this Evaluation/Action Plan does not have proper DPM access. Please contact DPM Support (DPMSupport@hmausa.com) with details.';
            }
        }else if(actionplan.ApprovalStatus__c == 'Submitted for Regional Approval'){ 
            if(!actionplan.Owner.IsActive) message = System.Label.ErrorMessageSendBack; //'Action Plan was unable to be sent back due to the recipient user being inactive. Please contact DPMSupport@hmausa.com and give direction as to who the new District/Market Manager should be so that Action Plans can be approved.';
        }
        
        return message;
    }
}