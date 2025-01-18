({
    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [Minhee Kim] on [2024-04-17] for [DPM-5507] added to close the modal
    */
    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        //DPM-5507 added to close the modal by MinheeKim - 24.04.17
        try {
            component.find("overlayLib").notifyClose();

        }
        catch(e) {
            console.log(e);
        }
    },

    handleConfirm : function(component, event, helper) {

        //var compEvent = component.getEvent("submitEvent");
        var appEvent = $A.get("e.c:submitSurveyEvent");

        try {
            appEvent.fire();
            component.find("overlayLib").notifyClose();
        }
        catch(e) {
            console.log(e);
        }
    },
})