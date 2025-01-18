/**
 * Created by baltamimi on 2022-02-23.
 */

({
    init: function (component) {
        console.log('record id: ' + component.get("v.recordId"));
        // Find the component whose aura:id is "flowData"
        let flow = component.find("flowData");
        let inputVariables = [
            {name: "recordId", type: "String", value: component.get("v.recordId")}
        ];
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("DNA_Approve_Package_Element", inputVariables);
    },

    handleStatusChange: function (component, event, helper) {
        console.log('Flow Status Changed');
        console.log(event.getParam("status"));
        if (event.getParam("status") === "FINISHED") {
            let outputVariables = event.getParam("outputVariables");
            if (outputVariables) {
                let nextPackageElementId = '';
                let sourcePackageId = '';
                for (let i = 0; i < outputVariables.length; i++) {
                    let outputVar = outputVariables[i];


                    if (outputVar.name === "nextPackageElementRecordId") {
                        nextPackageElementId = outputVar.value;
                        console.log('Next Package Element:: ' + outputVar.value);
                    } else if (outputVar.name === "packageId") {
                        sourcePackageId = outputVar.value;
                        console.log('Source Package:: ' + outputVar.value);
                    }
                }

                let navEvt = $A.get("e.force:navigateToSObject");
                if (nextPackageElementId) {
                    navEvt.setParams({
                        "recordId": nextPackageElementId
                    });
                } else {
                    navEvt.setParams({
                        "recordId": sourcePackageId
                    });
                }
                navEvt.fire();
            }
        }
    },
});