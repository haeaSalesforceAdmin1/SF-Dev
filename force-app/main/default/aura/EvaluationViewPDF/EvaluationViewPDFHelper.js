({
    getURLAddressForPDF : function(component, event, helper) {
        var recordId = component.get("v.recordId");
    
        var action = component.get("c.getNetworkId");
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            /*if(result == null) {
                component.set("v.existingDocumentURL", "/apex/EvaluationPDF?id=" + component.get("v.recordId"));
            }
            else if(result == '0DB6g000000CcmHGAS'){
                //Hyundai
                component.set("v.existingDocumentURL", "https://stage-hmausa.cs123.force.com/hyundaidealer/apex/EvaluationPDF?id=" + component.get("v.recordId"));
            }
            else {
                //Genesis
                component.set("v.existingDocumentURL", "https://stage-hmausa.cs123.force.com/genesisdealer/apex/EvaluationPDF?id=" + component.get("v.recordId"));
            }*/
            component.set("v.existingDocumentURL", result + "/apex/EvaluationPDF?id=" + component.get("v.recordId"));
        });
        $A.enqueueAction(action);
    },


    launchGenerateEvaluationQueueable : function(component, event, helper) {

        var recordId = component.get("v.recordId");
    
        var action = component.get("c.launchQueueableForEvaluationGeneration");
        action.setParams({"evaluationId": recordId});
        action.setCallback(this, function(response) {
            var jobId = response.getReturnValue();
            helper.pollGenerateEvaluationQueueable(component, event, helper, jobId)
            

        });
        $A.enqueueAction(action);
    },

    pollGenerateEvaluationQueueable : function(component, event, helper, jobId) {
        
        var async;
        var actionGetStatus = component.get('c.getQueueableForEvaluationGenerationStatus');
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
                    helper.pollGenerateEvaluationQueueable(component, event, helper, jobId);
                }), 2000
            ); 
        }
        else {
            if(component.get("v.queueableCompleted")) {
                helper.handleGenerateEvaluationQueueableCompleted(component, event, helper);
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

    handleGenerateEvaluationQueueableCompleted : function(component, event, helper) {

        var recordId = component.get("v.recordId");
    
        var action = component.get("c.getEvaluationDetails");
        action.setParams({"evaluationId": recordId});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log(result);

            component.set("v.existingDocumentURL", "/sfc/servlet.shepherd/version/download/" + result.Latest_PDF_Version_Id__c);
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    }
})