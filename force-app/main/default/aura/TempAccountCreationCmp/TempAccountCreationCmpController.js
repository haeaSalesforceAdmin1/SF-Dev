({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
         { name : "recordId", type : "String", value: component.get("v.recordId") }
       ];
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("DN_Create_Temp_Account");
    },

    handleStatusChange : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
          let outputVariables = event.getParam("outputVariables");
            if(outputVariables){
                for(let i = 0; i < outputVariables.length; i++) {
                    let outputVar = outputVariables[i];
                    if(outputVar.name === "tempDealerId") {
                        if(outputVar.value){
                            helper.closeFocusedTab(component, outputVar.value);
                        } else{
                            var workspaceAPI = component.find("tempAccountCreateWorkspace");
                            workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({tabId: focusedTabId});
              			})
                       }
                    }
                }
            }
        }
    },
});