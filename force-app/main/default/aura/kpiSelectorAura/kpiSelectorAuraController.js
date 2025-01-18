({
    myAction : function(component, event, helper) {

    },


    handleCloseQuickAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})