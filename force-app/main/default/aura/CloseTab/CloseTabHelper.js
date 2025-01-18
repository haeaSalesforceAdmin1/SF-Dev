/**
 * Created by baltamimi on 2022-02-23.
 */

({
    closeFocusedTab: function (component, caseId) {
        var workspaceAPI = component.find("createPackageWorkspace");
        workspaceAPI.openTab({
            url: '#/sObject/' + caseId + '/view',
            focus: true
        });
    },
});