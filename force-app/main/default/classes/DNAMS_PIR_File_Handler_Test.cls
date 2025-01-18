@isTest
public class DNAMS_PIR_File_Handler_Test {
    
    @isTest
    public static void testdata(){
        try{
        test.startTest();
        Account acc = new Account(Name = 'Test Account '+ DateTime.now());
        insert acc;
        Package_Initiation__c p = new Package_Initiation__c();
        p.Dealer_Name__c = acc.Id;
        p.PIR_Status__c = 'Draft';
        p.Name = 'test';
        p.PIR_Type__c = 'Buy/Sell';
        insert p;
        
        // List<PIR_Element__c> elementList = new List<PIR_Element__c>();
        PIR_Element__c element1 = new PIR_Element__c(PIR__c = p.Id, Name = 'PIR Element '+ DateTime.now());
        PIR_Element__c element2 = new PIR_Element__c(PIR__c = p.Id, Name = 'PIR Element '+ DateTime.now());
        
        insert element1;
        insert element2;
        
        
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test';
        cv.PathOnClient = 'Test.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = element1.id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test';
        cv1.PathOnClient = 'Test.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
        
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =:conDocId  limit 1][0];
        
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = element1.id;
        cdl1.ContentDocumentId = conDocId1;
        cdl1.shareType = 'V';
        Insert cdl1;
            
            ContentDocumentLink cdl12 = New ContentDocumentLink();
        cdl12.LinkedEntityId = element2.id;
        cdl12.ContentDocumentId = conDocId1;
        cdl12.shareType = 'V';
        Insert cdl12;
            delete cdl12;
        
        delete cd;
            
            Package_Initiation__c p1 = new Package_Initiation__c();
            p1.PIR_Status__c = 'Cleared';
            p1.Id = p.id;
            update p1;
            
            ContentDocument cd1 = [SELECT Id FROM ContentDocument WHERE Id =:conDocId1  limit 1][0];
            delete cd1;
            
            delete cdl1;
            
            
        
        test.StopTest();
        }
        catch(Exception e){
            
        }
           
    }
    @isTest
    public static void testdata2(){
        try{
            test.startTest();
            
            Account acc = new Account(Name = 'Test Account '+ DateTime.now());
        	insert acc;
        	Package_Initiation__c pir = new Package_Initiation__c();
        	pir.Dealer_Name__c = acc.Id;
        	pir.PIR_Status__c = 'Cleared';
        	pir.Name = 'test';
        	pir.PIR_Type__c = 'Buy/Sell';
        	insert pir;
            
            String pir_id = pir.Id;
            
            
            List<PIR_Element__c> pele_list = [select id from PIR_Element__c where PIR__c =: pir_id];
            List<ID> pele_id_list = new List<ID>();
            for(PIR_Element__c p : pele_list){
                pele_id_list.add(p.id);
            }
            
            ContentVersion cv1 = new ContentVersion();
            cv1.Title = 'Test123';
            cv1.PathOnClient = 'Test123.pdf';
            cv1.VersionData = Blob.valueOf('Test Content123');
            cv1.IsMajorVersion = true;
            
            Insert cv1;
            
            Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
            
            ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =:conDocId1  limit 1][0];
            
            ContentDocumentLink cdl1 = New ContentDocumentLink();
            cdl1.LinkedEntityId = pele_id_list[0];
            cdl1.ContentDocumentId = conDocId1;
            cdl1.shareType = 'V';
            Insert cdl1;
            
            test.StopTest();
        }
        catch(Exception e){
            system.debug(e);
            
        }
        
        
        
         
        
        
    }
    
    @isTest
    public static void testdata3(){
        try{
        test.startTest();
        Account acc = new Account(Name = 'Test Account '+ DateTime.now());
        insert acc;
        Package_Initiation__c p = new Package_Initiation__c();
        p.Dealer_Name__c = acc.Id;
        p.PIR_Status__c = 'Draft';
        p.Name = 'test';
        p.PIR_Type__c = 'Buy/Sell';
        insert p;
        
        // List<PIR_Element__c> elementList = new List<PIR_Element__c>();
        PIR_Element__c element1 = new PIR_Element__c(PIR__c = p.Id, Name = 'PIR Element '+ DateTime.now());
        PIR_Element__c element2 = new PIR_Element__c(PIR__c = p.Id, Name = 'PIR Element '+ DateTime.now());
        
        insert element1;
        insert element2;
        
        //Test.StartTest();
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test';
        cv.PathOnClient = 'Test.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = element1.id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test';
        cv1.PathOnClient = 'Test.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
        
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =:conDocId  limit 1][0];
        
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = element1.id;
        cdl1.ContentDocumentId = conDocId1;
        cdl1.shareType = 'V';
        Insert cdl1;
        
        delete cd;
            
            Package_Initiation__c p1 = new Package_Initiation__c();
            p1.PIR_Status__c = 'Cleared';
            p1.Id = p.id;
            update p1;
            
            //ContentDocument cd1 = [SELECT Id FROM ContentDocument WHERE Id =:conDocId1  limit 1][0];
            //delete cd1;
            
            delete cdl1;
            
            
        
        test.StopTest();
        }
        catch(Exception e){
            
        }

       
    }
    
}