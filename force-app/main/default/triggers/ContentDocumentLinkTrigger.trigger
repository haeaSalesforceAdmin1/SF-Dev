trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, before delete) {

    //Added by Egen Team --- To handle Files on PIR Elements Object based on Owner and status of Package Initiation Request 
    if (Trigger.isInsert && Trigger.isBefore) {
        //DNAMS_PIR_File_Handler.DNAMS_ContentDocumentLinkTrigger_BeforeInsert(Trigger.new);
        
        List<String> linkedIds = new List<String>();
        for(ContentDocumentLink c : Trigger.new){
            linkedIds.add(c.LinkedEntityId);
        }
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<PIR_Element__c> pirelementList= [select id from PIR_Element__c where id in: linkedIds];
        Set<Id> pirelementIds = new Set<Id>();
        
        for(PIR_Element__c p : pirelementList){
            pirelementIds.add(p.Id);
        }
        for(ContentDocumentLink c : Trigger.new){
            if(c.LinkedEntityId.getSObjectType() == PIR_Element__c.SObjectType && pirelementIds.contains(c.LinkedEntityId)){
                cdlList.add(c);
            }
        }
        system.debug('cdlList '+ cdlList);
        if(!cdlList.isEmpty()){
        DNAMS_PIR_File_Handler.DNAMS_ContentDocumentLinkTrigger_BeforeInsert(cdlList);
        }
      
    }
    
    //Added by Egen Team --- To handle Files on PIR Elements Object based on Owner and status of Package Initiation Request
    if (Trigger.isInsert && Trigger.isAfter) {
        //DNAMS_PIR_File_Handler.DNAMS_ContentDocumentLinkTrigger_AfterInsert(Trigger.new);
     	List<String> linkedIds = new List<String>();
        for(ContentDocumentLink c : Trigger.new){
            linkedIds.add(c.LinkedEntityId);
        }
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<PIR_Element__c> pirelementList= [select id from PIR_Element__c where Id in:linkedIds];
        Set<Id> pirelementIds = new Set<Id>();
        
        for(PIR_Element__c p : pirelementList){
            pirelementIds.add(p.Id);
        }
        for(ContentDocumentLink c : Trigger.new){
            if(pirelementIds.contains(c.LinkedEntityId)){
                cdlList.add(c);
            }
        }
        system.debug('cdlList '+ cdlList);
        if(!cdlList.isEmpty()){
        DNAMS_PIR_File_Handler.DNAMS_ContentDocumentLinkTrigger_AfterInsert(cdlList);
        }
    }
    
    //Added by Egen Team --- To handle Files on PIR Elements Object based on Owner and status of Package Initiation Request
    if (Trigger.isDelete) {
        //        DNAMS_PIR_File_Handler.DNAMS_ContentDocumentLinkTrigger_BeforeDelete(Trigger.old);
     	List<String> linkedIds = new List<String>();
        for(ContentDocumentLink c : Trigger.old){
            linkedIds.add(c.LinkedEntityId);
        }
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<PIR_Element__c> pirelementList= [select id from PIR_Element__c where Id in: linkedIds];
        Set<Id> pirelementIds = new Set<Id>();
        
        for(PIR_Element__c p : pirelementList){
            pirelementIds.add(p.Id);
        }
        for(ContentDocumentLink c : Trigger.old){
            if(pirelementIds.contains(c.LinkedEntityId)){
                cdlList.add(c);
            }
        }
        system.debug('cdlList '+ cdlList);
        if(!cdlList.isEmpty()){
        DNAMS_PIR_File_Handler.DNAMS_ContentDocumentLinkTrigger_BeforeDelete(cdlList);
        }
        
    }

    
    if (BypassTriggers__c.getInstance().ContentDocumentLinkTrigger__c) {
        System.Debug('ContentDocumentLink Trigger ByPassed.');
        return;
    }
        
    List<ID> sObjectIds = new List<Id>();
    String sObjName;
    String userObjName;
    String[] hcuv_Trigger_Objects=System.Label.HCUV_Trigger_Object.split(',');
    
        if(Trigger.isInsert){
            for (ContentDocumentLink cdLink : Trigger.new) {
                sObjectIds.add(cdLink.linkedEntityId);
            }
         
             if(!sObjectIds.isEmpty()){
                 if(sObjectIds.size()>0 && sObjectIds.get(0) !=null)
                     userObjName=(sObjectIds.get(0)).getSObjectType().getDescribe().getName();
                  if(sObjectIds.size()>1 && sObjectIds.get(1)!=null)
                    sObjName = (sObjectIds.get(1)).getSObjectType().getDescribe().getName();
            }
        }
        
        if(hcuv_Trigger_Objects.contains(sObjName) || hcuv_Trigger_Objects.contains(userObjName)){    
            if(Trigger.isBefore && Trigger.isInsert)
                HCUV_ContentDocumentLinkTriggerHandler.beforeInsert(Trigger.new);
    
            if(Trigger.isAfter && Trigger.isInsert)
                HCUV_ContentDocumentLinkTriggerHandler.afterInsert(Trigger.new);            
            
        }        
        else
        {
         Trigger_Framework.createHandler(ContentDocumentLink.SObjectType);
        }
    
}