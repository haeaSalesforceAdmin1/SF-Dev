({
    handleUploadFinished: function (component, event) {
        var uploadedFiles = event.getParam("files");
        var firstFile = uploadedFiles[0];
        component.set('v.documentId', firstFile.documentId);
        var documentIds = [];
        uploadedFiles.forEach(uploadedFile => {
            documentIds.push(uploadedFile.documentId);
        });
        
               var action = component.get("c.getContentVersionId");
        action.setParams({"contentDocumentId" : firstFile.documentId});
        action.setCallback(this, function(response) {
		    var contentVersionId = response.getReturnValue();
            component.set('v.pictureSrc',
                          '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId='
                          + contentVersionId);
		});
        $A.enqueueAction(action);


        //component.set('v.pictureSrc', '/servlet/servlet.FileDownload?file='
        //              + firstFile.documentId);
        //component.set('v.pictureSrc', '/sfc/servlet.shepherd/version/download/'
        //              + '0682C000000p7BVQAY');

       

       var actionCheckFileSize = component.get("c.checkFileSize");
       actionCheckFileSize.setParams({ "documentIds" : documentIds });
       actionCheckFileSize.setCallback(this, function(response) {
            console.log(response);
            var state = response.getState();
            console.log('state--',state);
            if (state == "SUCCESS") {
                var tempList = response.getReturnValue();
                if (tempList != null && tempList != undefined) {

                if(tempList.response == 'SUCCESS'){
                    var compEvent = component.getEvent("documentUploadFinished");
                    compEvent.setParams({"parentId" : component.get("v.recordId"), "documentIds" : documentIds });
                    compEvent.fire();
                }
                else{
                    var errMsg = tempList.response;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": errMsg,
                        "type" : "error",
                        "mode" : "sticky"
                    });
                    toastEvent.fire();
                    var tmpArrIds = [];
                    documentIds.forEach(key =>{
                        if (!(tempList.deletedFiles).includes(key)) {
                            tmpArrIds.push(key);
                        }
                    });
                    var compEvent = component.getEvent("documentUploadFinished");
                    compEvent.setParams({"parentId" : component.get("v.recordId"), "documentIds" : tmpArrIds });
                    compEvent.fire();
                }
            }
            } else {
                var compEvent = component.getEvent("documentUploadFinished");
                compEvent.setParams({"parentId" : component.get("v.recordId"), "documentIds" : documentIds });
                compEvent.fire();
            }
        });
        $A.enqueueAction(actionCheckFileSize);
    
        /*var compEvent = component.getEvent("documentUploadFinished");
        compEvent.setParams({"parentId" : component.get("v.recordId"), "documentIds" : documentIds });
        compEvent.fire();*/
    }
})