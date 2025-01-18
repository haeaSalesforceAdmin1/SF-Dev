({
    /**
     * [Method Description] 
     * Created by [MinheeKim] on [2024-01-17] for [DPM-5633]
    */
    deleteFile : function(component) {

        //DPM-5264 Add to temporarly by MH - 2024.01.16
        component.set("v.temporaryDelete", false);
        
        var FileDeletedEvent = component.getEvent("fileDeletedEvent");
        FileDeletedEvent.setParams({"deletedfileId" : component.get("v.fileId"), "deletedFileparentId": component.get("v.parentId")  });
        FileDeletedEvent.fire();

        
     
    }
})