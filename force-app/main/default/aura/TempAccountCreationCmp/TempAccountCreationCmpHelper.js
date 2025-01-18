({
    closeFocusedTab: function (component,accountId) {
        var workspaceAPI = component.find("tempAccountCreateWorkspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            console.log(focusedTabId);
            //Opening New Tab
            workspaceAPI.openTab({
                url: '#/sObject/' + accountId + '/view',
            }).then(function(response) {
                workspaceAPI.focusTab({tabId : response});
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
        })
        .catch(function(error) {
            console.log(error);
        });
    },
});