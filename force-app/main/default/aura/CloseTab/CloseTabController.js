/**
 * Created by baltamimi on 2022-02-15.
 */

({
    invoke: function (component, event, helper) {
    let workspaceAPI = component.find("workspace");
    console.log('WORKSPACE:: ' + (workspaceAPI !== undefined));
    
    workspaceAPI.getFocusedTabInfo().then(function (response) {
        let focusedTabId = response.tabId;
        console.log('Focused tab:: ' + focusedTabId);
        workspaceAPI.closeTab({tabId: focusedTabId});
    })
    .catch(function (error) {
            console.log('ERROR!!');
            console.error(error);
    });
}
});