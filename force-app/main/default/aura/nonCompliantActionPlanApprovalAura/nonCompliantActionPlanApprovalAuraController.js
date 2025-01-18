({
    myAction : function(component, event, helper) {

    },

    handleApprovalComplete : function(component, event, helper) {
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
        
        component.set("v.showSpinner", false);
    }
})