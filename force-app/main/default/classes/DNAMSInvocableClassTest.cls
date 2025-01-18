@isTest
private class DNAMSInvocableClassTest {
    @testSetup static void setup() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;
 
        Account acc=new Account(Name='test');
        insert acc;
        Package__c pa=new Package__c();
        pa.Type__c ='Renewal';
        pa.Classification__c='Major';
        pa.Description__c='This is sample package';
        pa.PackageDetail__c='New Dealer';
        pa.Sequence__c=3;
        pa.Status__c='Draft';
        pa.Dealer__c=acc.Id;
        insert pa; 
        
        List<PackageElement__c>elelist=new List<PackageElement__c>();
        
        for(Integer i=0;i<2;i++) {
            PackageElement__c ele= new PackageElement__c();  
            ele.Name='test';
            ele.Section__c='section one';
            ele.Type__c='Form';
            ele.Required__c=true;
            ele.VisibletoDealer__c=true;
            ele.Sequence__c=3;
            ele.Package__c=pa.Id;
            ele.Status__c = 'Region Market Admin Pre Review';
            ele.RMAStatus__c = 'Under Review';
            ele.Instructions__c = 'Test instructions';
            
            elelist.add(ele);
            
        }
        insert elelist;
        ContentVersion contentVersionForPE = ContentDocumentTestFactory.makeContentVersion(elelist[0].Id);
        insert contentVersionForPE;
    }
    
    //Test to delete the invoke the DNAMSInvocableClass  
    static testMethod void dnamsInvocableClassTest(){
        Account acc=[SELECT Id FROM Account Limit 1];
        test.startTest();
        Package__c pe=[Select Id,Type__c
                       from Package__c limit 1];
        System.debug('TEST=pe.Id'+pe.Id);
        Map<Id,PackageElement__c> sourcePRElement = new Map<Id,PackageElement__c>([Select Id,name,Section__c,Type__c,Required__c,Package__c,VisibletoDealer__c,Sequence__c,Instructions__c,OriginalPackageElementId__c
                                       from PackageElement__c where Package__c=:pe.id]);
        try{
            String recordId = pe.Id;
            List<DNAMSInvocableClass.InvocableInput> requests= new List<DNAMSInvocableClass.InvocableInput>();
                DNAMSInvocableClass.InvocableInput invocableInputs = new DNAMSInvocableClass.InvocableInput();
                invocableInputs.recordId = pe.Id;
                requests.add(invocableInputs);
            
                DNAMSDeleteRecordsQueueable.disableEnqueueJobForTest = true; // To avoid System.AsyncException: Maximum stack depth has been reached.
                DNAMSInvocableClass.invoke(requests);
        }
        catch(exception e){
            System.debug('Exception='+e);
        }    
        
        test.stopTest();
    }  
}