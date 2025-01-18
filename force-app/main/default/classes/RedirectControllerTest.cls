@isTest
private class RedirectControllerTest
{
private static testMethod void testMethod1() {

List<DRCDocument__c> drc= new List<DRCDocument__c>(); 
   PageReference pageRef = Page.DRCHomeRedirect;
   Test.setCurrentPage(pageRef);
   String recordTypeId = Schema.SObjectType.DRCDocument__c.getRecordTypeInfosByName().get('Meeting Document').getRecordTypeId();
   DRCDocument__c drcc= new DRCDocument__c();
   drcc.recordTypeId=recordTypeId;
   drcc.Name='test';
   drcc.MeetingDate__c=Date.newInstance(2022, 12, 12);
   drcc.Folder__c='Data';
    drc.add(drcc);
   insert drc;
   ApexPages.standardSetController sc = new ApexPages.standardSetController(drc);
   RedirectController  controller = new RedirectController(sc);
   System.assertNotEquals(null,controller.DRCHomeRedirect());
   
}
    
private static testMethod void testMethod2() {

List<DRCDocument__c> drc= new List<DRCDocument__c>(); 
   PageReference pageRef = Page.DRCCaseRedirect;
   Test.setCurrentPage(pageRef);
   String recordTypeId = Schema.SObjectType.DRCDocument__c.getRecordTypeInfosByName().get('Case Document').getRecordTypeId();
   DRCDocument__c drcc= new DRCDocument__c();
   drcc.recordTypeId=recordTypeId;
   drcc.Name='test';
   drcc.Folder__c='Data';
   drc.add(drcc);
   insert drc;
   ApexPages.standardSetController sc = new ApexPages.standardSetController(drc);
   RedirectController  controller = new RedirectController(sc);
   System.assertNotEquals(null,controller.DRCCaseRedirect());
   
}
    private static testMethod void testMethod3() {

List<TRCDocument__c> trc= new List<TRCDocument__c>(); 
   PageReference pageRef = Page.TRCHomeRedirect;
   Test.setCurrentPage(pageRef);
   String recordTypeId = Schema.SObjectType.TRCDocument__c.getRecordTypeInfosByName().get('Meeting Document').getRecordTypeId();
   TRCDocument__c trcc= new TRCDocument__c();
   trcc.recordTypeId=recordTypeId;
   trcc.Name='test';
   trcc.MeetingDate__c=Date.newInstance(2022, 12, 12);
   trcc.Folder__c='Data';
    trc.add(trcc);
   insert trc;
   ApexPages.standardSetController sc = new ApexPages.standardSetController(trc);
   RedirectController  controller = new RedirectController(sc);
   System.assertNotEquals(null,controller.TRCHomeRedirect());
   
}
    
private static testMethod void testMethod4() {

List<TRCDocument__c> trc= new List<TRCDocument__c>(); 
   PageReference pageRef = Page.TRCCaseRedirect;
   Test.setCurrentPage(pageRef);
   String recordTypeId = Schema.SObjectType.TRCDocument__c.getRecordTypeInfosByName().get('Case Document').getRecordTypeId();
   TRCDocument__c trcc= new TRCDocument__c();
   trcc.recordTypeId=recordTypeId;
   trcc.Name='test';
   trcc.Folder__c='Data';
   trc.add(trcc);
   insert trc;
   ApexPages.standardSetController sc = new ApexPages.standardSetController(trc);
   RedirectController  controller = new RedirectController(sc);
   System.assertNotEquals(null,controller.TRCCaseRedirect());
   
}

private static testMethod void testMethod5() {

List<NASDADocument__c> trc= new List<NASDADocument__c>(); 
   PageReference pageRef = Page.NASDAHomeRedirect;
   Test.setCurrentPage(pageRef);
   String recordTypeId = Schema.SObjectType.NASDADocument__c.getRecordTypeInfosByName().get('Meeting Document').getRecordTypeId();
   NASDADocument__c trcc= new NASDADocument__c();
   trcc.recordTypeId=recordTypeId;
   trcc.Name='test';
   trcc.MeetingDate__c=Date.newInstance(2022, 12, 12);
   trcc.Folder__c='Other';
    trc.add(trcc);
   insert trc;
   ApexPages.standardSetController sc = new ApexPages.standardSetController(trc);
   RedirectController  controller = new RedirectController(sc);
   System.assertNotEquals(null,controller.NASDAHomeRedirect());
   
}
    
private static testMethod void testMethod6() {

List<NASDADocument__c> trc= new List<NASDADocument__c>(); 
   PageReference pageRef = Page.NASDACaseRedirect;
   Test.setCurrentPage(pageRef);
   String recordTypeId = Schema.SObjectType.NASDADocument__c.getRecordTypeInfosByName().get('Case Document').getRecordTypeId();
   NASDADocument__c trcc= new NASDADocument__c();
   trcc.recordTypeId=recordTypeId;
   trcc.Name='test';
   trcc.Folder__c='Other';
   trc.add(trcc);
   insert trc;
   ApexPages.standardSetController sc = new ApexPages.standardSetController(trc);
   RedirectController  controller = new RedirectController(sc);
   System.assertNotEquals(null,controller.NASDACaseRedirect());
   
}

}