({
    closePopup: function(component, event, helper) { 
        $A.get( "e.force:closeQuickAction" ).fire();  
    },
    /*handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        //window.open('https://staging.wdcs.hyundaidealer.com/irj/portal/webdcs#/vehicleinfoPop/' + component.get("v.simpleRecord.Name"));
        window.open('https://stage.hyundaidealer.com/_layouts/SSOSharepointSolution/SSORedirect.aspx?id=WEBDCS_SRDR_allowCU_V2_STG');
        $A.get("e.force:closeQuickAction").fire();
    }*/
})