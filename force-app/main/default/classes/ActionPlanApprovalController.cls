public without sharing class ActionPlanApprovalController {

    @AuraEnabled 
    public static String handleActionPlanApprovals(String actionPlanId, String action, String comments, String status) {
    
        try {
            Action_Plan__c actionPlan = [select Id, Status__c, ApprovalStatus__c, OwnerId, OrganizationRef__r.Name, Division__c, DistrictManager__c, DistrictSalesManager__c, 
                                            AssignedDealer__c, DistrictPartsServiceManager__c, MarketManager__c, Aftersales_Market_Manager__c, Is_Region_Sent_Back__c,Is_District_Sent_Back__c from Action_Plan__c where Id = :actionPlanId];

           
            List<UserRole> roles = [select Id, Name, DeveloperName from UserRole where Id = :UserInfo.getUserRoleId()];
            System.debug(LoggingLevel.ERROR, 'action: ' + action);
            System.debug(LoggingLevel.ERROR, 'actionPlan.ApprovalStatus__c: ' + actionPlan.ApprovalStatus__c);
            System.debug(LoggingLevel.ERROR, 'actionPlan.ApprovalStatus__c: ' + actionPlan.Status__c );

            
            
            if(action != 'Reject') {
                if(!roles.isEmpty() && ((roles[0].DeveloperName == 'Region_Managers')|| (roles[0].DeveloperName == 'Genesis_Region_Manager'))) {
                    actionPlan.ApprovalStatus__c = 'Region Approved';
                }
              /* following code is commented by neeraj for 3523 ticket  
               * else if(!roles.isEmpty()  && (roles[0].DeveloperName == 'Genesis_Area_Manager')) {
                    actionPlan.ApprovalStatus__c = 'Genesis Area Approved';
                }*/
                else if(((actionPlan.ApprovalStatus__c == 'Submitted for District Approval')  || (actionPlan.ApprovalStatus__c == 'Sent Back' && actionPlan.Status__c == 'Pending') ) && !roles.isEmpty() && roles[0].DeveloperName != 'Region_Managers') {
 
                    actionPlan.ApprovalStatus__c = 'District Approved';
                    actionPlan.DistrictApprovalDate__c = Date.today();
                    System.debug(LoggingLevel.ERROR, 'Made it here');
                }
                
                	
                else if(((actionPlan.ApprovalStatus__c == 'District Approved') || ((actionPlan.ApprovalStatus__c == 'Non-Compliant' && actionPlan.Status__c == 'Completed')  || (actionPlan.ApprovalStatus__c == 'Compliant' && actionPlan.Status__c == 'Completed') ))  && !roles.isEmpty() && roles[0].DeveloperName != 'Region_Managers') {
                    actionPlan.ApprovalStatus__c = 'Submitted for Regional Approval';
                    //actionPlan.Is_Region_Sent_Back__c=false;
                    //actionPlan.Is_District_Sent_Back__c=false;
                    //actionPlan.ShowComplianceButtons__c=false;
                }
                
                
            }
            
            
            
            if (actionPlan.Is_Region_Sent_Back__c && action == 'Reject' && actionPlan.ApprovalStatus__c == 'Sent Back' ) {
                actionPlan.ApprovalStatus__c = 'Sent Back To Dealer';
                actionPlan.Phase__c = 'Open'; 
                actionPlan.DistrictApprovalDate__c = NULL;
            } 
            else if (actionPlan.Is_District_Sent_Back__c&& actionPlan.ApprovalStatus__c == 'District Approved' && action == 'Reject'){
                actionPlan.ApprovalStatus__c = 'Sent Back To Dealer';
                actionPlan.Phase__c = 'Open'; 
                actionPlan.DistrictApprovalDate__c = NULL;
            }
            if (actionPlan.Status__c != 'Carry Over') {
                actionPlan.Status__c = status;
            } 
            
            //flip to the assigned deal on send back
            // only when submitted to district approval

            //no actioplan and Approval Status is submitted to Submitted For District Approval

            update actionPlan;

            Set<Id> pIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId = :actionPlanId])).keySet();
            Set<Id> pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds])).keySet();

            List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>(); 
            for (Id pInstanceWorkitemsId:pInstanceWorkitems){
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setComments(comments);       req2.setAction(action); //to approve use 'Approve'
                req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});

                // Use the ID from the newly created item to specify the item to be worked
                req2.setWorkitemId(pInstanceWorkitemsId);

                // Add the request for approval
                allReq.add(req2);
            }
            Approval.ProcessResult[] result2 =  Approval.process(allReq);
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getLineNumber() + ex.getMessage() );
            return 'Error: ' + ex.getMessage();

        }

        return 'Success';

    }
}