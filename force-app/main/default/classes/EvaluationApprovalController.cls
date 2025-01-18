public without sharing class EvaluationApprovalController {

    @AuraEnabled
    public static String handleEvaluationApprovals(String evaluationId, String action, String comments, String status) {
    
        String contactErrMsg = NULL;
        try {
            Evaluation__c evaluation = [select Id, Total_of_Related_Action_Plans__c, PrimaryContact__c, PrimaryContactName__c, ApprovalStatus__c from Evaluation__c where Id = :evaluationId]; 
            
            Profile prof = [SELECT Id,Name 
                            FROM Profile 
                            WHERE Id=:userinfo.getProfileId()];

            List<UserRole> roles = [select Id, Name, DeveloperName from UserRole where Id = :UserInfo.getUserRoleId()];

            if ((prof.Name != 'System Administrator' && prof.Name != 'Integration User' 
                && evaluation != NULL && evaluation.PrimaryContact__c == NULL 
                && evaluation.PrimaryContactName__c == NULL)){
                contactErrMsg = System.Label.Msg_Primary_Contact_Is_Required;
                throw new CustomException(contactErrMsg);    
            }
            Boolean evaluationUpdated = false;               
            if(evaluation.Total_of_Related_Action_Plans__c == 0){
                evaluation.Status__c = status;
                evaluationUpdated = true;
            }       

            if(evaluation.ApprovalStatus__c == 'Not Submitted' && !roles.isEmpty() && roles[0].DeveloperName != 'Region_Managers') {
                evaluation.ApprovalStatus__c = 'District Approved';
                evaluation.DistrictApprovalDate__c = Date.today();
                evaluationUpdated = true;
            }
            else if(evaluation.ApprovalStatus__c == 'Not Submitted' && !roles.isEmpty() && (roles[0].DeveloperName == 'Region_Managers')) {
                evaluation.ApprovalStatus__c = 'Region Approved';
                evaluationUpdated = true;
            }
           /* this code commented by neeraj sharma for 3423 ticket 
            *  else if(evaluation.ApprovalStatus__c == 'Not Submitted' && !roles.isEmpty() && (roles[0].DeveloperName == 'Genesis_Area_Manager')) {
                evaluation.ApprovalStatus__c = 'Genesis Area Approved';
                evaluationUpdated = true;
            }*/

            if(evaluationUpdated) {
                update evaluation;
            }

            Set<Id> pIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId = :evaluationId])).keySet();
            Set<Id> pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds])).keySet();

            List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>(); 
            for (Id pInstanceWorkitemsId:pInstanceWorkitems){
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setComments(comments);
                req2.setAction(action); //to approve use 'Approve'
                req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});

                // Use the ID from the newly created item to specify the item to be worked
                req2.setWorkitemId(pInstanceWorkitemsId);

                // Add the request for approval
                allReq.add(req2);
            }
            Approval.ProcessResult[] result2 =  Approval.process(allReq);
        }
        catch(Exception e) {

            if (String.isNotBlank(contactErrMsg)) {
                return e.getMessage();
            } else {
                return 'Error: ' + e.getMessage();
            }
            
                
                        
        }

        return 'Success';
    }

    public class CustomException extends Exception {} 
}