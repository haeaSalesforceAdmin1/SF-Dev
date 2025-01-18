public Class RedirectController {
    public String currentRecordId {get;set;}
 public RedirectController(ApexPages.StandardSetController controller) {}

    public PageReference DRCHomeRedirect()
   {
       
       String recordTypeId = Schema.SObjectType.DRCDocument__c.getRecordTypeInfosByName().get('Meeting Document').getRecordTypeId();
       String url = '/lightning/o/DRCDocument__c/new?recordTypeId='+recordTypeId;
        System.debug('url : ' + url );
     PageReference newMeeting = new PageReference(url);
     newMeeting.setRedirect(true);
     return newMeeting ;
  
   }
      public PageReference DRCCaseRedirect()
   {
       currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
       String recordTypeId = Schema.SObjectType.DRCDocument__c.getRecordTypeInfosByName().get('Case Document').getRecordTypeId();
       String url = '/lightning/o/DRCDocument__c/new?recordTypeId='+recordTypeId+'&defaultFieldValues=Case__c='+currentRecordId;
        System.debug('url : ' + url );
     PageReference newDRC = new PageReference(url);
     newDRC.setRedirect(true);
     return newDRC ;
  
   }
    public PageReference TRCHomeRedirect()
   {
       String recordTypeId = Schema.SObjectType.TRCDocument__c.getRecordTypeInfosByName().get('Meeting Document').getRecordTypeId();
       String url = '/lightning/o/TRCDocument__c/new?recordTypeId='+recordTypeId;
        System.debug('url : ' + url );
     PageReference newMeeting = new PageReference(url);
     newMeeting.setRedirect(true);
     return newMeeting ;
  
   }
      public PageReference TRCCaseRedirect()
   {
       currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
       String recordTypeId = Schema.SObjectType.TRCDocument__c.getRecordTypeInfosByName().get('Case Document').getRecordTypeId();
       String url = '/lightning/o/TRCDocument__c/new?recordTypeId='+recordTypeId+'&defaultFieldValues=Case__c='+currentRecordId;
        System.debug('url : ' + url );
     PageReference newTRC = new PageReference(url);
     newTRC.setRedirect(true);
     return newTRC ;
  
   }
    public PageReference NASDAHomeRedirect()
   {
       String recordTypeId = Schema.SObjectType.NASDADocument__c.getRecordTypeInfosByName().get('Meeting Document').getRecordTypeId();
       String url = '/lightning/o/NASDADocument__c/new?recordTypeId='+recordTypeId;
        System.debug('url : ' + url );
     PageReference newMeeting = new PageReference(url);
     newMeeting.setRedirect(true);
     return newMeeting ;
  
   }
      public PageReference NASDACaseRedirect()
   {
       currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
       String recordTypeId = Schema.SObjectType.NASDADocument__c.getRecordTypeInfosByName().get('Case Document').getRecordTypeId();
       String url = '/lightning/o/NASDADocument__c/new?recordTypeId='+recordTypeId+'&defaultFieldValues=Case__c='+currentRecordId;
        System.debug('url : ' + url );
     PageReference newNASDA = new PageReference(url);
     newNASDA.setRedirect(true);
     return newNASDA ;
  
   }
}