({
    myAction : function(component, event, helper) {

    },

    deleteFile : function(component, event, helper) {
        if(confirm('Are you sure you want to delete this file?')) {
            helper.deleteFile(component, event);
        }
    }
})