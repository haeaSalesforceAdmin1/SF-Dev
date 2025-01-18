/**
* @description : Changed Lab Request Detail page Tab Name
* @author San, Kang : SanKang@autoeveramerica.com | 2024-07-31
* @tecket no: OU24-127
*/
({
    handleLabelChange : function(component, event, helper){
        var action = component.get("c.getLRObj");
        var recordId = component.get("v.recordId");

        action.setParams({"recordId": recordId });
        action.setCallback(this, function(response) {
            let rtnValue = response.getReturnValue();
            // console.log('rtnValue',rtnValue);
            let workspaceAPI = component.find("workspace");

            if(rtnValue.Lab_Request_Number__c != null){
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    let focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: rtnValue.Lab_Request_Number__c
                    });
                });
            }
           
        });
        $A.enqueueAction(action);
    }
    
})