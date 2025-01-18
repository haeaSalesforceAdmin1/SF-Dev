({
    doInit : function(component, event, helper) {
        //helper.checkSurveyPDF(component, event, helper);
        component.set("v.existingDocumentURL", "/apex/SurveyQuestionCompPDF?id=" + component.get("v.recordId"));
    },

    handleCloseClicked : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})