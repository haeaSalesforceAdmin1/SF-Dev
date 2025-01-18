({
    myAction : function(component, event, helper) {

    },

    deleteFile : function(component, event, helper) {
        if(confirm('Are you sure you want to delete this file?')) {
            helper.deleteFile(component, event);
        }
    },

    defaultCloseAction : function(component, event, helper) {
		component.set("v.isHidden", true);
	},

	fireSaveEvent : function(component, event, helper) {
		var event = component.getEvent("onSaveClick");
        event.fire();
	},

	fireCancelEvent : function(component, event, helper) {
		var event = component.getEvent("onCancelClick");
        event.fire();
	},

	changeVisibility: function(component, event, helper) {
		var isShow = event.getParam('arguments').isShow;
		console.log("isShow ==>",isShow);
		component.set("v.isHidden", !isShow);
	}
})