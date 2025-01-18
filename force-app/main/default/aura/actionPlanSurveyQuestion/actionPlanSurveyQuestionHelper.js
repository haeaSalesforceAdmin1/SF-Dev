/**
 * Created by user on 2023-08-01.
 */

({
    getSurveyQuestions : function(component, event, helper) {
        var action = component.get("c.getSurveyQuestions");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response.getReturnValue() : '+JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                component.set("v.surveyQuestions", response.getReturnValue());
                component.set("v.isLoading", false);
            } else {
                console.error("Failed with state: " + state);
            }
        });
        var currentPath = window.location.pathname;
        var isInExperience = currentPath.includes('/hyundaidealer/s/') || currentPath.includes('/genesisdealer/s/');
        component.set("v.isInExperience", isInExperience);
        $A.enqueueAction(action);
    },
});