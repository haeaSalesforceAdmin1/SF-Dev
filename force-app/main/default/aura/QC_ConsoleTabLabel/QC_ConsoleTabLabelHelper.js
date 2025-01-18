//  @description : Changed Lab Request Detail page Tab Name
//  @author San, Kang : SanKang@autoeveramerica.com | 2024-09-06
//  @tecket no: SO-462
({
    handleLabelChange : function(component, event, helper){
        var action = component.get("c.getQCObj");
        var recordId = component.get("v.recordId");

        action.setParams({"recordId": recordId });
        action.setCallback(this, function(response) {
            let rtnValue = response.getReturnValue();
            // console.log('rtnValue',rtnValue);
            let workspaceAPI = component.find("workspace");
            if(rtnValue != null){
                console.log('rtnValue',rtnValue.SCSCaseNumber__c);

                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    let focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: rtnValue.SCSCaseNumber__c
                    });
                    workspaceAPI.setTabHighlighted({
                        tabId: focusedTabId,
                        highlighted: true,
                        options: {
                            pulse: true,
                            state: "warning"
                    }
                    });
                });
            }
           
        });
        $A.enqueueAction(action);

        
    }
    
})