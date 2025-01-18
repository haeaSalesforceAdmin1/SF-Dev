public without sharing class AssignToDealerController {

    @AuraEnabled
    public static Evaluation__c getEvaluationDetails(String evaluationId){
        return [select Id, Account__c, Latest_PDF_Version_Date__c, Latest_PDF_Version_Id__c, PrimaryContact__c, Survey__c from Evaluation__c where Id = :evaluationId];
    }

    @AuraEnabled
    public static Action_Plan__c getActionPlanDetails(String actionPlanId){
        return [select Id, Account__c, Evaluation__r.Account__c, Evaluation__r.PrimaryContact__c from Action_Plan__c where Id = :actionPlanId];
    }

    @AuraEnabled
    public static User getPrimaryContactUserId(String contactId){
        System.debug(loggingLevel.ERROR, contactId);
        return [select Id, ContactId from User where ContactId = :contactId];
    }

    @AuraEnabled
    public static List<User> retrievEvaluationAccountContacts(String accountId) {

        //AccountContactRelation
        List<String> contactIds = new List<String>();
        List<AccountContactRelation> accountContactRelations = [select Id, ContactId from AccountContactRelation where AccountId = :accountId];
        for(AccountContactRelation accountContactRelation:accountContactRelations) {
            contactIds.add(accountContactRelation.ContactId);
        }
        //List<Contact> contacts = [select Id, Name from Contact where AccountId = :accountId];
        List<User> users = [select Id, Name from User where ContactId in :contactIds];

        Set<Id> permissionSetIds = new Set<Id>();  
        for (SetupEntityAccess access:[SELECT ParentId FROM SetupEntityAccess WHERE SetupEntityId IN (SELECT Id   
                                                            FROM CustomPermission WHERE DeveloperName = 'Action_Plan_External_User')]) {  
            permissionSetIds.add(access.ParentId);  
        }                                                        
        List<User> userList = [SELECT Id, Name, ContactId FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment  
                            WHERE PermissionSetId IN :permissionSetIds AND AssigneeId in :users ) ];  

        return userList;
    }

    @AuraEnabled
    public static List<String> getActionPlansToAssignOwner(String evaluationId){

        List<String> actionPlanIds = new List<String>();
        List<Action_Plan__c> actionPlans = [select Id from Action_Plan__c where Evaluation__c = :evaluationId];

        for(Action_Plan__c actionPlan:actionPlans) {
            actionPlanIds.add(actionPlan.Id);
        }

        return actionPlanIds;
    }

    @AuraEnabled
    public static void updateActionPlanOwnerId(String actionPlanObjectJSON){

        System.debug(LoggingLevel.ERROR, actionPlanObjectJSON);
        Action_Plan__c updatedActionPlan = (Action_Plan__c)System.JSON.deserializeStrict(actionPlanObjectJSON, Action_Plan__c.class);

        /*HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__Share');
        Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(new List<SObject>{updatedActionPlan}, Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
        System.debug(LoggingLevel.ERROR, existingSharesMap);
        if(existingSharesMap.containsKey(updatedActionPlan.Id)) {
            if(!existingSharesMap.get(updatedActionPlan.Id).containsKey(updatedActionPlan.OwnerId)) {

                apexSharing.add(updatedActionPlan, updatedActionPlan.OwnerId, 'Read', Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
            }
        }
        else {
            apexSharing.add(updatedActionPlan, updatedActionPlan.OwnerId, 'Read', Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
        }
        System.debug(LoggingLevel.ERROR, apexSharing);
        apexSharing.share();*/

        update updatedActionPlan;
    }

    @AuraEnabled
    public static void updateEvaluationOwnerId(String evaluationObjectJSON){

        Evaluation__c updatedEvaluation = (Evaluation__c)System.JSON.deserializeStrict(evaluationObjectJSON, Evaluation__c.class);
        update updatedEvaluation;
    }

    @AuraEnabled
    public static void updateSurveyOwnerId(String surveyObjectJSON){

        Survey__c updatedSurvey = (Survey__c)System.JSON.deserializeStrict(surveyObjectJSON, Survey__c.class);
        update updatedSurvey;
    }
}