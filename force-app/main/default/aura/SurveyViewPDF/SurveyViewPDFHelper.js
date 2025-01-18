({
    checkSurveyPDF : function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
    
        var action = component.get("c.checkIfSurveyHasRecentSurveyPDF");
        action.setParams({"surveyId": recordId});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
           
            if(result == "Generate New") {
                helper.launchGenerateSurveyQueueable(component, event, helper);
            }
            else {
                if(result == 'Generate New Version') { 
                    //helper.launchGenerateSurveyQueueable(component, event, helper)
                    component.set("v.showGenerateNewVersion", true);
                }
                helper.launchGenerateSurveyQueueable(component, event, helper);
                //alert('view');
            }
        });
        $A.enqueueAction(action);
    },

    launchGenerateSurveyQueueable : function(component, event, helper) {

        var recordId = component.get("v.recordId");
    
        var action = component.get("c.launchQueueableForSurveyGeneration");
        action.setParams({"surveyId": recordId});
        action.setCallback(this, function(response) {
            var jobId = response.getReturnValue();
            helper.pollGenerateSurveyQueueable(component, event, helper, jobId)
            

        });
        $A.enqueueAction(action);
    },

    pollGenerateSurveyQueueable : function(component, event, helper, jobId) {
        
        var async;
        var actionGetStatus = component.get('c.getQueueableForSurveyGenerationStatus');
        actionGetStatus.setParams({jobId : jobId });
        actionGetStatus.setCallback(this, function(response) {
            async = response.getReturnValue();
            if(response.getReturnValue().Status == 'Completed') {
                component.set("v.queueableCompleted", true);
            }
            else if(response.getReturnValue().Status == 'Failed') {
                component.set("v.queueableErrors", async.ExtendedStatus);
                component.set("v.queueableCompleted", false);
                component.set("v.queueableFailed", true);
            }
        });

        if(!component.get("v.queueableCompleted") && !component.get("v.queueableFailed") && component.get("v.pollCount") < 100) {
            $A.enqueueAction(actionGetStatus);
            window.setTimeout(
                $A.getCallback(function() {
                    var pollCount = component.get("v.pollCount");
                    component.set("v.pollCount", pollCount + 1);
                    console.error(component.get("v.pollCount"));
                    helper.pollGenerateSurveyQueueable(component, event, helper, jobId);
                }), 2000
            ); 
        }
        else {
            if(component.get("v.queueableCompleted")) {
                helper.handleGenerateSurveyQueueableCompleted(component, event, helper);
            }
            else if(component.get("v.queueableFailed")) {
                alert('failed');
                //helper.handleError(component, "Error", component.get("v.queueableErrors"), null);
            }
            else {
                alert('failed');
                //helper.handleError(component, "Error", 'There was an unhandled error, please contact IT Support.', null);
            }
        }
    },

    handleGenerateSurveyQueueableCompleted : function(component, event, helper) {

        var recordId = component.get("v.recordId");
    
        var action = component.get("c.getSurveyDetails");
        action.setParams({"surveyId": recordId});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log(result);

            component.set("v.existingDocumentURL", "/sfc/servlet.shepherd/version/download/" + result.Latest_PDF_Version_Id__c);
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    }
})