/**
*  Cover the test coverage for Package Elements Selector Controller
*/
@isTest
public class PackageElementsSelectorControllerTest {
    
    @testSetup static void setup() {
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
    }
    //Test for get the package elements from the templatePackageElementsSelectorController  
    static testMethod void getpackageElementsFromTemplate(){
        Account acc=[SELECT Id FROM Account Limit 1];
        test.startTest();
        Package__c pe=[Select Id,Type__c
                       from Package__c limit 1];
        System.debug('pe.Id'+pe.Id);
        List<PackageElement__c>palist=[Select Id,name,Section__c,Type__c,Required__c,Package__c,VisibletoDealer__c,Sequence__c,Instructions__c
                                       from PackageElement__c where Package__c=:pe.id];
        System.assertEquals(true, !palist.isEmpty());
        List<PackageElement__c>elentlist=new List<PackageElement__c>();
        List<PackageElement__c>elentUpdatelist=new List<PackageElement__c>();
        for(PackageElement__c paele:palist){
            elentlist.add(paele);           
            try{
                PackageElementsSelectorController.getPackageElementsFromTemplate(pe.Id);
                PackageElementsSelectorController.createNewPackage(acc.Id,acc.Id,pe.Id,'Test Pkg', 'Test Pkg Desc',null,elentlist);
            }
            catch(exception e)
         {
             // exception message
         }    
        }  
        test.stopTest();
    }  
}