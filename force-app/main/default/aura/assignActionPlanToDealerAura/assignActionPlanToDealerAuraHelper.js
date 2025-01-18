({
    getActionPlanDetailsAura : function(component, event, helper) {

        var action = component.get("c.getActionPlanDetails");
        var recordId = component.get("v.recordId");

        console.log('recordId: ' + recordId);
        
        action.setParams({"actionPlanId": recordId });
        action.setCallback(this, function(response) {
            let actionPlan = response.getReturnValue();
            component.set("v.actionPlan", actionPlan);
            //component.set("v.primaryContact", evaluation.PrimaryContact__c);
            if(actionPlan.Evaluation__r.PrimaryContact__c != undefined && actionPlan.Evaluation__r.PrimaryContact__c != null) {
                helper.getPrimaryContactUser(component, event, helper, actionPlan.Evaluation__r.PrimaryContact__c);
            }

            helper.getEvaluationAccountContacts(component, event, helper, actionPlan.Evaluation__r.Account__c);
        });
        $A.enqueueAction(action);
    },

    getPrimaryContactUser : function(component, event, helper, contactId) {
        
        var action = component.get("c.getPrimaryContactUserId");
        action.setParams({"contactId": contactId });
        action.setCallback(this, function(response) {
            //alert('getPrimaryContactUser ' +  contactId);
            console.log(response.getReturnValue());
            if(response.getReturnValue() != null) {
                //alert(response.getReturnValue().Id );
                component.set("v.selectedOwnerId", response.getReturnValue().Id);
                component.set("v.primaryContact", response.getReturnValue().Id);
            }
        });
        $A.enqueueAction(action);
    },

    getEvaluationAccountContacts : function(component, event, helper, accountId) {

        var evalContacts = [];
        
        var blankContact = {};
        blankContact.label = '--None--';
        blankContact.value = null;
        evalContacts.push(blankContact);

        var action = component.get("c.retrievEvaluationAccountContacts");
        
        action.setParams({"accountId": accountId });
        action.setCallback(this, function(response) {
            var evaluationContacts = response.getReturnValue();

            evaluationContacts.forEach(evalContact => {
                var contactObject = {};
                contactObject.label = evalContact.Name;
                contactObject.value = evalContact.Id;
                evalContacts.push(contactObject);
            });
            component.set("v.evaluationAccountContacts", evalContacts);
            component.set("v.showSpinner", false);
            helper.getSurveyQuestions(component, event, helper);
        });
        $A.enqueueAction(action);
    },

    /*assignToDealer : function(component, event, helper) {
        
        console.log('assignToDealer');
        var action = component.get("c.getActionPlansToAssignOwner");
        var evaluation = component.get("v.evaluation");
        var actionPlanIds = [];

        var selfEval = component.find("selfEval").get("v.checked");

        action.setParams({"evaluationId": evaluation.Id });
        action.setCallback(this, function(response) {
            var actionPlanIds = response.getReturnValue();
            if(actionPlanIds.length > 0) {
                helper.updateOwnerActionPlans(component, event, helper, actionPlanIds, 0, selfEval);
            }
            else{
                if(selfEval) {
                    helper.updateOwnerEvaluation(component, event, helper);
                }
                else {
                    component.set("v.showSpinner", false);

                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(action);
    },*/

    updateOwnerActionPlans : function(component, event, helper, actionPlanIds, currentIndex, selfEval) {
        console.log('updateOwnerActionPlans');
        var actionPlanObject = {};
        actionPlanObject.Id = component.get("v.recordId");
        actionPlanObject.OwnerId = component.get("v.selectedOwnerId");

        console.log(component.get("v.selectedOwnerId"));

        var action = component.get("c.updateActionPlanOwnerId");
        action.setParams({"actionPlanObjectJSON": JSON.stringify(actionPlanObject)});
        action.setCallback(this, function(response) {

            component.set("v.showSpinner", false);
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();

        });
        $A.enqueueAction(action);
    },
    
        /*updateOwnerEvaluation : function(component, event, helper) {
            console.log('updateOwnerEvaluation');
            let selectedOwnerId = component.get("v.selectedOwnerId");
            let evaluation = component.get("v.evaluation");
           
            var evaluationObject = {};
            evaluationObject.Id = evaluation.Id;
            evaluationObject.OwnerId = component.get("v.selectedOwnerId");
            evaluationObject.IsSelfReview__c = true;
            var action = component.get("c.updateEvaluationOwnerId");
            action.setParams({"evaluationObjectJSON": JSON.stringify(evaluationObject)});
            action.setCallback(this, function(response) {        
                if(evaluation.Survey__c != undefined && evaluation.Survey__c != null ) {
                    helper.updateOwnerSurvey(component, event, helper);
                }
                else {
                    component.set("v.showSpinner", false);
    
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
    
        },
    
        updateOwnerSurvey : function(component, event, helper) {
            console.log('updateOwnerSurvey');
            let selectedOwnerId = component.get("v.selectedOwnerId");
            let evaluation = component.get("v.evaluation");
           
            var surveyObject = {};
            surveyObject.Id = evaluation.Survey__c;
            surveyObject.OwnerId = component.get("v.selectedOwnerId");
    
            var action = component.get("c.updateSurveyOwnerId");
            action.setParams({"surveyObjectJSON": JSON.stringify(surveyObject)});
            action.setCallback(this, function(response) {        
                component.set("v.showSpinner", false);
    
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
    
            });
            $A.enqueueAction(action);
    
        }
    })*/
    
})