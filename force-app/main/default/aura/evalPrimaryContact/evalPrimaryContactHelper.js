({
    getEvaluationDetails : function(component, event, helper) {
        var action = component.get("c.retrieveEvaluationDetails");
        var recordId = component.get("v.recordId");

        action.setParams({"recordId": recordId, launchedFromEval : true});
        action.setCallback(this, function(response) {
            var evaluation = response.getReturnValue();
            //DPM-5399 changed to check whether approval status is region approved instead of primary contact by Minhee - 24.03.07
            if(evaluation.ApprovalStatus__c == "Region Approved") {
                component.set("v.showPrimaryContact",false);
            }else if(evaluation.Survey__r.Status__c!="Completed" && evaluation.PrimaryContact__c==undefined){
                component.set("v.showPrimaryContact",false);
            }
            else{
                component.set("v.showPrimaryContact",true);
                component.set("v.primaryContact", evaluation.PrimaryContact__c);
            }
            //DPM-5399 end


            helper.getEvaluationAccountContacts(component, event, helper, evaluation.Account__c);
        });
        $A.enqueueAction(action);
    },

    getEvaluationAccountContacts : function(component, event, helper, accountId) {
        
        var evalContacts = [];
        
        var blankContact = {};

        var action = component.get("c.retrievEvaluationAccountContacts");
        
        action.setParams({"accountId": accountId });
        action.setCallback(this, function(response) {
            var evaluationContacts = response.getReturnValue();

            evaluationContacts.forEach(evalContact => {
            
                var contactObject = {};
                //Dhiraj Changes added for Primary contact with Email                     
                contactObject.label = evalContact.Name +' '+evalContact.Email;
                contactObject.value = evalContact.ContactId;
                evalContacts.push(contactObject);
            });
            component.set("v.evaluationAccountContacts", evalContacts);
        });
        $A.enqueueAction(action);
    },
    
})