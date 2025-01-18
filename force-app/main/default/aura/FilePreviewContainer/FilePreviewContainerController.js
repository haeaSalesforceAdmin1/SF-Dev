// DPM-5633

({
    doInit: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var recordId = component.get("v.recordId");
        console.log("v.recordId" + component.get("v.recordId"));
        if (recordId) {
            component.set("v.recordId", recordId);

            var action = component.get("c.getFileId"); 
            action.setParams({
                recordId: component.get("v.recordId")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var fileId = response.getReturnValue();
                    component.set("v.fileId", fileId);
                    console.log("v.fileId" + component.get("v.fileId"));
                } else {
                    console.error("Failed to get file ID: " + response.getError());
                }
            });
            
            $A.enqueueAction(action);

            helper.getStatus(component, event, helper);
        }
    },
    
    openModal : function(component, event, helper) {
        component.set("v.isModalHidden", false);
    },

    onConfirm: function(component, event, helper) {
        console.log('Will be called when confirm button is clicked on modal');
        component.set("v.isModalHidden", true);
    },

    onCancel: function(component, event, helper) {
        console.log('Will be called when cancel button is clicked on modal');
        component.set("v.isModalHidden", true);
    }
})