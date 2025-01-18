({
    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-01-17] for [DPM-5264]
    */
    deleteFile : function(component) {

        //DPM-5264 Add to temporarly by MH - 2024.01.16
        component.set("v.temporaryDelete", false);
        
        var FileDeletedEvent = component.getEvent("fileDeletedEvent");
        FileDeletedEvent.setParams({"deletedfileId" : component.get("v.fileId"), "deletedFileparentId": component.get("v.parentId")  });
        FileDeletedEvent.fire();

        
        //DPM-5264 Changed to comments by MH - 2024.01.16
        // var action = component.get("c.deleteContentDocument");

        // action.setParams({"ContentDocumentId": component.get("v.fileId")});
        // action.setCallback(this, function (response) {
        //     var compEvent = component.getEvent("fileDeletedEvent");
        //     compEvent.setParams({"fileId" : component.get("v.fileId"), "parentId": component.get("v.parentId") });
        //     compEvent.fire();
        // });
        // $A.enqueueAction(action);
    }
})