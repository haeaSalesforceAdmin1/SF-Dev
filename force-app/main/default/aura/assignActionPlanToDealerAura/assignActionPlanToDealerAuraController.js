({
    doInit : function(component, event, helper) {
        helper.getActionPlanDetailsAura(component, event, helper);
    },

    handleAssignToDealer : function(component, event, helper) {
        
        component.set("v.showSpinner", true);
        helper.updateOwnerActionPlans(component, event, helper);
    },

    handleCancel : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    },
})