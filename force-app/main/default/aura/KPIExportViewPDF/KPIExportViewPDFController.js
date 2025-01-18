({
	 doInit : function(component, event, helper) {

        helper.getURLAddressForPDF(component, event, helper);
    }, 

    handleCloseClicked : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})