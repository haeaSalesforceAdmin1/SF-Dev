({
    init : function(component, event, helper) {
        console.log('recordId',component.get('v.recordId'));
        helper.getEvaluationDetails(component, event, helper);
    },

    handleSaveEvaluationDetailsClick : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var evalObject = {};
        evalObject.Id = component.get("v.recordId");
        evalObject.PrimaryContact__c = component.get("v.primaryContact");

        var action = component.get("c.saveEvaluationDetails");
        action.setParams({"evaluationJSONString": JSON.stringify(evalObject)});
        action.setCallback(this, function(response) { 
            $A.get('e.force:refreshView').fire();
            helper.getEvaluationDetails(component, event, helper);
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },

    headerClick : function(component, event, helper) {
        var isToggled = component.get("v.clickIcon");
        component.set("v.clickIcon", !isToggled);
    }
})