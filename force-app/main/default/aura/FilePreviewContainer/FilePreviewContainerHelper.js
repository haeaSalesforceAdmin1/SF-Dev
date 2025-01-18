({
    init: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var recordId = pageReference.state.recordId;
        if (recordId) {
            component.set("v.recordId", recordId);
        }
    },

    getStatus: function(component, event, helper){
        var action = component.get("c.getStatus"); 
            action.setParams({
                recordId: component.get("v.recordId")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var status = response.getReturnValue();
                    if(status=='Completed'){
                        component.set("v.isCompleted", true);
                    }
                    
                    console.log("v.isCompleted" + component.get("v.isCompleted"));
                } else {
                    console.error("Failed to get status: " + response.getError());
                }
            });
            
            $A.enqueueAction(action);
    }
    
})