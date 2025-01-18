({
    invoke : function(cmp, event, helper) {
        helper.getFiles(cmp, cmp.get("v.contentDocumentIds"));
    }
})