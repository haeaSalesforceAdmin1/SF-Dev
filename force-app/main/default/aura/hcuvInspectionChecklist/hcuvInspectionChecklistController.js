({
    doInit : function(component, helper) {
        var action = component.get("c.getInspectionChecklistQA");
        action.setParams({
            "invId": component.get("v.recordId"),
            "communityUrl":window.location.href
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.open(response.getReturnValue());
            }
            else{
                let message = '';
                let errors = response.getError();
                if (errors && errors.length > 0){
                    message = message + errors[0].message;
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "message": message,
                    "type": "error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire(); 
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
    }
})