({
    init : function (component) {
        //DNA 728 
        //code developed to disable create package when the users are not DND1 or RMR
        var action = component.get("c.checkPermissionSet");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == false) {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"error",
                        "title": "Error!",
                        "message": "Only RMR and DND1 users can create package!!"
                    });
                    //close the tab if throwing an toast even
                     var workspaceAPI = component.find("createPackageWorkspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    //redirect back after throwing toast event
                    history.back();
                    toastEvent.fire();
                } else {  // user has the right permission set
                    // Find the dealer ID passed from the list view button as a URL param.
                    var pageRef = component.get("v.pageReference");
                    var dealerId = '';

                    if(pageRef !== null && pageRef.state !== null) {
                        dealerId = pageRef.state.c__dealerId;
                        console.log(dealerId);
                    }
                    
                    // Find the component whose aura:id is "flowData"
                    var flow = component.find("flowData");

                    // Flow input initialize
                    var inputVariables = [
                        { name : "recordId", type : "String", value: dealerId }
                    ];
                    
                    // Start the DNA_Create_New_Package flow
                    flow.startFlow("DNA_Create_New_Package", inputVariables);
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleStatusChange : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
            let outputVariables = event.getParam("outputVariables");
            if(outputVariables){
                for(let i = 0; i < outputVariables.length; i++) {
                    let outputVar = outputVariables[i];
                    if(outputVar.name === "packageRecordId") {
                        if(outputVar.value){
                            helper.closeFocusedTab(component, outputVar.value);
                        }
                    }
                }
            }
        }
    },
});