({
	/*handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        window.open('https://www.carfax.com/VehicleHistory/p/Report.cfx?partner=HYU_0&vin=' + component.get("v.simpleRecord.Name") + '&source=BUP');
        $A.get("e.force:closeQuickAction").fire();
    }*/
    
    doInit : function(component, helper) {
        console.log('inside initialize' + component.get("v.recordId"));
        component.set("v.spinnervisible",true);

        var action = component.get("c.getCarFaxURL");
        action.setParams({
            "invId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response = ' + response.getReturnValue());
                if(response.getReturnValue() && response.getReturnValue() != '') {
                    window.open(response.getReturnValue());
                    $A.get("e.force:closeQuickAction").fire();   
                }
                else {
                    component.set("v.error", "Error while processing the request.");
                    $A.get("e.force:closeQuickAction").fire(); 
                }
            } else {
                let message = '';
                let errors = response.getError();
                if (errors && errors.length > 0)
                    message = message + errors[0].message;
                //console.log("Error in loading Lightning Component: " + message);
                //component.set("v.error", message);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "message": message,
                    "type": "error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire(); 
            }
            component.set("v.spinnervisible", false);
        });
        $A.enqueueAction(action);
    }
    
})