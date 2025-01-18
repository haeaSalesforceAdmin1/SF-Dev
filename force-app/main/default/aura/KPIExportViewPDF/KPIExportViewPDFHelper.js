({
	 getURLAddressForPDF : function(component, event, helper) {
        var recordId = component.get("v.recordId");
    	component.set("v.showSpinner",true);
        var action = component.get("c.getNetworkId");
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var urlNew= '';
            if (result != undefined && result != null){
                urlNew= result + "/apex/KPIPDFExport?id=" + component.get("v.recordId");
             component.set("v.existingDocumentURL", result + "/apex/KPIPDFExport?id=" + component.get("v.recordId"));
             component.set("v.showSpinner",false);   
                window.open(urlNew,'_blank');
                $A.get("e.force:closeQuickAction").fire();
            } else {
             component.set("v.showSpinner",false);  
               $A.get("e.force:closeQuickAction").fire();
            }
            
            
        });
        $A.enqueueAction(action);
    }
})