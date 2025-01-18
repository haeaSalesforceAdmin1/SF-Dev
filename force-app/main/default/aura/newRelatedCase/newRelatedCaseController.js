({
	doInit : function(component, event, helper) {
	    let pageReference = component.get("v.pageReference");	
        let base64Context  = pageReference.state.inContextOfRef.substring(2);
        let addressableContext = JSON.parse(window.atob(base64Context));
        let inputVariables = [
        	{
           	 name: 'caseId',
           	 type: 'String',
	         value: addressableContext.attributes.recordId
        	},
        ];
		let objFlow = component.find("flowData");
        objFlow.startFlow("Create_New_Related_Case",inputVariables);
	}

})