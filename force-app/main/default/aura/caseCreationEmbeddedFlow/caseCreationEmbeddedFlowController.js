({
    init: function (component, event, helper) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowPlaceHolder");
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("SC_Safety_Create_Case");
    },

    handleStatusChange: function (component, event, helper) {
        console.log('Flow Status Changed');
        console.log(event.getParam("status"));
        if (event.getParam("status") === "FINISHED") {
            var outputVariables = event.getParam("outputVariables");
            if (outputVariables) {
                for (var i = 0; i < outputVariables.length; i++) {
                    var outputVar = outputVariables[i];
                    if (outputVar.name === "CaseRecordID") {
                        if (outputVar.value) {
                            var sourceCaseId = outputVar.value;
                            // Update Case Owner
                            var updateOwnerAction = component.get("c.updateOwner");
                            updateOwnerAction.setParams({caseId: sourceCaseId});
                            updateOwnerAction.setCallback(this, function (response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    helper.closeFocusedTab(component, sourceCaseId);
                                } else {
                                    var errors = response.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                            console.log("Error message: " +
                                                errors[0].message);
                                        }
                                    } else {
                                        console.log("Unknown error");
                                    }
                                }
                            });
                            $A.enqueueAction(updateOwnerAction);
                        }
                    }
                }
            }
        } else if (event.getParam("status") === "STARTED") {
            if (window.location.href.includes('/one/one.app#')) {
                component.set("v.showCancelBtn", "true");
                helper.renameFocusedTab(component);
            } else {
                component.set("v.showCancelBtn", "false");
            }
        }
    },

    handleCancelBtn: function (component) {
        var workspaceAPI = component.find("createCaseWorkspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            }).then(function (closeResult) {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/lightning/o/Case/list"
                });
                urlEvent.fire();
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    }

})