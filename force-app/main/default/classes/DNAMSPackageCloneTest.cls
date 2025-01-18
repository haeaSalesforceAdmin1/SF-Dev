@isTest
public class DNAMSPackageCloneTest {
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
    
    //Test for get the Clone Package elements from the DNAMSPackageClone  
    static testMethod void clonePackages(){
        Account acc=[SELECT Id FROM Account Limit 1];
        test.startTest();
        Package__c pe=[Select Id,Type__c
                       from Package__c limit 1];
        System.debug('TEST=pe.Id'+pe.Id);
        Package__c clonnedPackage = pe.clone();
        clonnedPackage.Original_Package__c = pe.Id;
        insert clonnedPackage;
        System.debug('TEST=clonnedPackage'+clonnedPackage);
        List<PackageElement__c> clonedPElist = new List<PackageElement__c>();
        for(PackageElement__c peRecord:[Select Id,name,Section__c,Type__c,Required__c,Package__c,VisibletoDealer__c,Sequence__c,Instructions__c,OriginalPackageElementId__c
                                       from PackageElement__c where Package__c=:pe.id]){
            System.debug('TEST=peRecord'+peRecord);
            PackageElement__c tempRecord = peRecord.clone();
            tempRecord.OriginalPackageElementId__c = peRecord.Id;
            clonedPElist.add(tempRecord);
        }
        System.debug('TEST=clonedPElist.size()'+clonedPElist.size());
        if(clonedPElist.size() > 0){
            insert clonedPElist;
        }
        List<PackageElement__c> elentlist=new List<PackageElement__c>();
        List<PackageElement__c> elentUpdatelist=new List<PackageElement__c>();
                  
            try{
                List<DNAMSPackageClone.InvocableInput> requests= new List<DNAMSPackageClone.InvocableInput>();
                DNAMSPackageClone.InvocableInput invocableInputs = new DNAMSPackageClone.InvocableInput();
                invocableInputs.recordId = clonnedPackage.Id;
                invocableInputs.updatedPackageElements = clonedPElist;
                requests.add(invocableInputs);
                DNAMSPackageClone.clonePackages(requests);
                
            }
            catch(exception e){
                 System.debug('Exception='+e);
            }    
        
        test.stopTest();
    } 
    
    //Test for get the Clone Package elements from the DNAMSPackageClone  
    static testMethod void clonePackages_ForCanceledStatus(){
        Account acc=[SELECT Id FROM Account Limit 1];
        test.startTest();
        Package__c pe=[Select Id,Type__c,Status__c
                       from Package__c limit 1];
        System.debug('TEST=pe.Id'+pe.Id);
        pe.Status__c = 'Canceled';
        Package__c clonnedPackage = pe.clone();
        clonnedPackage.Original_Package__c = pe.Id;
        insert clonnedPackage;
        System.debug('TEST=clonnedPackage'+clonnedPackage);
        List<PackageElement__c> clonedPElist = new List<PackageElement__c>();
        for(PackageElement__c peRecord:[Select Id,name,Section__c,Type__c,Required__c,Package__c,VisibletoDealer__c,Sequence__c,Instructions__c,OriginalPackageElementId__c
                                       from PackageElement__c where Package__c=:pe.id]){
            System.debug('TEST=peRecord'+peRecord);
            PackageElement__c tempRecord = peRecord.clone();
            tempRecord.OriginalPackageElementId__c = peRecord.Id;
            clonedPElist.add(tempRecord);
        }
        System.debug('TEST=clonedPElist.size()'+clonedPElist.size());
        if(clonedPElist.size() > 0){
            insert clonedPElist;
        }
        List<PackageElement__c> elentlist=new List<PackageElement__c>();
        List<PackageElement__c> elentUpdatelist=new List<PackageElement__c>();
                  
            try{
                List<DNAMSPackageClone.InvocableInput> requests= new List<DNAMSPackageClone.InvocableInput>();
                DNAMSPackageClone.InvocableInput invocableInputs = new DNAMSPackageClone.InvocableInput();
                invocableInputs.recordId = clonnedPackage.Id;
                invocableInputs.updatedPackageElements = clonedPElist;
                requests.add(invocableInputs);
                DNAMSPackageClone.clonePackages(requests);
                
            }
            catch(exception e){
                 System.debug('Exception='+e);
            }    
        
        test.stopTest();
    }
    
    //Test for get the Clone Package elements from the DNAMSPackageClone  
    static testMethod void clonePackages_ForInitiateddStatus(){
        Account acc=[SELECT Id FROM Account Limit 1];
        test.startTest();
        Package__c pe=[Select Id,Type__c,Status__c
                       from Package__c limit 1];
        System.debug('TEST=pe.Id'+pe.Id);
        pe.Status__c = 'Canceled';
        Package__c clonnedPackage = pe.clone();
        clonnedPackage.Original_Package__c = pe.Id;
        insert clonnedPackage;
        System.debug('TEST=clonnedPackage'+clonnedPackage);
        List<PackageElement__c> clonedPElist = new List<PackageElement__c>();
        for(PackageElement__c peRecord:[Select Id,name,Section__c,Type__c,Required__c,Package__c,VisibletoDealer__c,Sequence__c,Instructions__c,OriginalPackageElementId__c
                                       from PackageElement__c where Package__c=:pe.id]){
            System.debug('TEST=peRecord'+peRecord);
            PackageElement__c tempRecord = peRecord.clone();
            tempRecord.OriginalPackageElementId__c = peRecord.Id;
            clonedPElist.add(tempRecord);
        }
        System.debug('TEST=clonedPElist.size()'+clonedPElist.size());
        if(clonedPElist.size() > 0){
            insert clonedPElist;
        }
        List<PackageElement__c> elentlist=new List<PackageElement__c>();
        List<PackageElement__c> elentUpdatelist=new List<PackageElement__c>();
                  
            try{
                List<DNAMSPackageClone.InvocableInput> requests= new List<DNAMSPackageClone.InvocableInput>();
                DNAMSPackageClone.InvocableInput invocableInputs = new DNAMSPackageClone.InvocableInput();
                invocableInputs.recordId = clonnedPackage.Id;
                invocableInputs.updatedPackageElements = clonedPElist;
                requests.add(invocableInputs);
                DNAMSPackageClone.clonePackages(requests);
                
            }
            catch(exception e){
                 System.debug('Exception='+e);
            }    
        
        test.stopTest();
    }  
}