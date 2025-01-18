({

    doInit : function(component, event, helper) {

        helper.getUploadedFiles(component);  

    },

    delFilesAction : function(component,event,helper){

        component.set("v.Spinner", true);
		//var documentId = event.currentTarget.id;        
		var documentId = component.get("v.currentDocId")
		helper.delUploadedfiles(component,documentId);

    },

    handleClick : function(component, event, helper) {

        helper.getUploadedFiles(component);

        $A.get('e.force:refreshView').fire();      

    },
    
    showConfirmationPopup: function(component, event, helper) {
        var documentId = event.currentTarget.id; 
        console.log('showConfirmationPopup=documentId='+documentId);
        component.set("v.currentDocId", documentId);
        component.set("v.showConfirmation", true);
        console.log('showConfirmationPopup');
    },

    hideConfirmationPopup: function(component, event, helper) {
        component.set("v.showConfirmation", false);
        console.log('hideConfirmationPopup');
        component.set("v.currentDocId", '');
    },
    //DNA-1073-Start
    hideShowErrorPopup : function(component, event, helper) {
        component.set("v.showErrorScreen", false);
        component.set("v.showConfirmation", false);
        console.log('hideShowErrorPopup');
        component.set("v.currentDocId", '');
    	component.set("v.errorMessage", '');
    }
	//DNA-1073-End

})