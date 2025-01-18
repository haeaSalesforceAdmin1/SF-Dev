// Test Class: HCUV_TestContentDocumentLinkTrigger
public class HCUV_ContentDocumentLinkTriggerHandler {
    

    public static void beforeInsert(List<ContentDocumentLink> cdlObjList) {       
        updateVisibility(cdlObjList);
    }
    
    public static void afterInsert(List<ContentDocumentLink> cdlObjList) {
        createContentDistribution(cdlObjList);
    }
    
    public static void updateVisibility(List<ContentDocumentLink> cdlObjList) {
        String linkedEntityId;
        
        for(ContentDocumentLink cdlObj : cdlObjList) {
            linkedEntityId = cdlObj.LinkedEntityId;
            
            if(String.isNotBlank(linkedEntityId))
                cdlObj.Visibility = HCUV_Constants.ContentDocument_Visibility_AllUsers;
        }
    }
    
    public static void createContentDistribution(List<ContentDocumentLink> cdlObjList) {
        List<String> conDocIds = new List<String> ();
        String linkedEntityId;
        
        for(ContentDocumentLink cdlObj : cdlObjList) {
            linkedEntityId = cdlObj.LinkedEntityId;
            
            if(String.isNotBlank(linkedEntityId))
                conDocIds.add(cdlObj.ContentDocumentId);
        }
        
        if(!conDocIds.isEmpty()) {
            List<ContentVersion> cvObjList = [Select Id, ContentDocumentId, Title from ContentVersion 
                                              WHERE ContentDocumentId IN :conDocIds];
            
            conDocIds.clear();
            
            for(ContentVersion cvObj : cvObjList) {
                conDocIds.add(cvObj.ContentDocumentId);
            }
            
            List<ContentDistribution> cdObjList = new List<ContentDistribution>();
            
            for(ContentVersion cvObj : cvObjList) {
                if(conDocIds.contains(cvObj.ContentDocumentId)) {
                    cdObjList.add(
                        new ContentDistribution(
                            ContentVersionId = cvObj.Id,
                            Name = cvObj.Title,
                            PreferencesNotifyOnVisit = false,
                            PreferencesAllowViewInBrowser = true,
                            PreferencesAllowOriginalDownload=true
                        )
                    );
                }
            }
            insert cdObjList;
        }
    }
    
}