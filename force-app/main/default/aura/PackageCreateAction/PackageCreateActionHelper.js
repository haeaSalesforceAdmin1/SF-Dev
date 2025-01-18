/**
 * Created by baltamimi on 2022-02-21.
 */

({
    closeFocusedTab: function (component,packgId) {
        var workspaceAPI = component.find("createPackageWorkspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            console.log(focusedTabId);
            //Opening New Tab
            workspaceAPI.openTab({
                url: '#/sObject/' + packgId + '/view',
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