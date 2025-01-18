trigger CommonSELCheck on ContentVersion (after insert){
    
    for(ContentVersion cdl: Trigger.new){   
        User IntegrationUser = [SELECT Id FROM User WHERE UserName =:Label.lblIntegrationUserName];
        String objType=String.valueOf(cdl.FirstPublishLocationId.getsobjecttype());
        if(objType=='DADocuments__c'){
            DADocuments__c da =[SELECT Id,Case__c,CreatedById,Folder__c FROM DADocuments__c where Id = : cdl.FirstPublishLocationId];
            if(da!=null){
                Case c = [SELECT Id, FirstReportSource__c,Common_SEL_Report_Included__c FROM Case WHERE Id = :da.Case__c ];
                if(c.FirstReportSource__c=='Shared KIA Common Issue' && da.CreatedById == IntegrationUser.Id && da.Folder__c=='SIMS Common SEL Report'){
                    
                    c.Common_SEL_Report_Included__c= true;
                    update c; 
                }
                
            }
        }               
    }
}