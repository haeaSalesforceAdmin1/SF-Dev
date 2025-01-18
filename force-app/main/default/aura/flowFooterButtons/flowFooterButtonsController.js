({
	invoke : function(component, event, helper) {
   		// Get the record ID attribute
	    let url = component.get("v.recordId");
        let buttonType = component.get("v.buttonType");
        let redirect = $A.get("e.force:navigateToSObject");
        console.log('버튼타입이???? ' + buttonType);

        let workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let focusedTabId = response.tabId;

            if(buttonType == 'Save' || buttonType =='Next'){ //create form tab close + new Related Case tab open (focus)

                workspaceAPI.openSubtab({
                    parentTabId : focusedTabId,
                    recordId : url,
                    focus: true
                }).then(function(response) {

                    workspaceAPI.getTabInfo({
                        tabId: response
                    }).then(function(tabInfo) {
                        console.log("The url for this tab is: " + tabInfo.url);
                    });

                    workspaceAPI.closeTab({tabId: focusedTabId});

                })
                .catch(function(error) {
                    console.log(error);
                });

            }else if(buttonType == 'Save & New'){ //new Related Case tab + create form tab (focus)

                workspaceAPI.openSubtab({
                    parentTabId : focusedTabId,
                    recordId : url,
                    focus: false
                }).then(function(response) {
    
                    workspaceAPI.getTabInfo({
                          tabId: response
                    }).then(function(tabInfo) {
                    console.log("The url for this tab is: " + tabInfo.url);
                    });
                })
                .catch(function(error) {
                       console.log(error);
                });

            }else if(buttonType == 'Cancel' ){ // craete form tab close 

               let focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            }else if(buttonType == 'Modal_Cancel' ){ // craete form tab close 

            //    window.location.reload();
            }
    
         })
         .catch(function(error) {
             console.log(error);
         });  

	}
})