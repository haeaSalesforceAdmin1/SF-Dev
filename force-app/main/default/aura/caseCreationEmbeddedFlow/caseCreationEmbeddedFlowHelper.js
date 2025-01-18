({
    closeFocusedTab : function(component, caseId) {
        var workspaceAPI = component.find("createCaseWorkspace");
        if(component.get("v.showCancelBtn") === "true"){
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.openTab({
                    url: '#/sObject/' + caseId + '/view',
                    focus: true
                }).then(function(openResponse) {
                    console.log("Opened: ");
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                })
                .catch(function(error) {
                    console.error("ERROR => ",error);
                });
                
            })
            .catch(function(error) {
                console.log(error);
            });
        } else {
            workspaceAPI.openTab({
                url: '#/sObject/' + caseId + '/view',
                focus: true
            });
        }
        
    },

    renameFocusedTab: function(component){
        var workspaceAPI = component.find("createCaseWorkspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "New Case"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:case",
                iconAlt: "Case"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
})