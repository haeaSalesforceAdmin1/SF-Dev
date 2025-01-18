({    invoke : function(component, event, helper) {
    // Get the record ID attribute
    var record = component.get("v.recordId");
    /*
    // Get the Lightning event that opens a record in a new tab
    var redirect = $A.get("e.force:navigateToSObject");
    
    // Pass the record ID to the event
    redirect.setParams({
        "recordId": record,
        "slideDevName": "related"
    });
    
    // Define a callback function to execute after the record is opened
        var callback = function(response) {
            if (response.getState() === "SUCCESS") {
                // Log response or perform other actions after the record is opened
                console.log("Record opened successfully:", response.getReturnValue());
                // You can add more code here to execute after the record is opened
            } else if (response.getState() === "ERROR") {
                // Handle any errors that occurred during the navigation process
                var errors = response.getError();
                if (errors) {
                    for (var i = 0; i < errors.length; i++) {
                        console.error("Error message: " + errors[i].message);
                    }
                } else {
                    console.error("Unknown error");
                }
            }
        };
        
        // Add the callback function to be executed after the record is opened
        redirect.setCallback(this, callback);
       
    // Open the record
    redirect.fire();
    */
    
    // Construct the URL for navigating to the record
    var url = "/" + record;// DNA-988
        
    // Open the record in a new tab 
    window.open(url, '_self'); //DNA-988
        
        
}})