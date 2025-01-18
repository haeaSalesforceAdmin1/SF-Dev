/**
 * Created by baltamimi on 2021-12-22.
 */

 @IsTest
 private class ContentDocumentTriggerTest {
     
      @IsTest
    public static void testDeleteEvluationContentDocumentAdmin() {
         // Create a test evaluation record
        Evaluation__c eval = new Evaluation__c(Name = 'Test Evaluation', Status__c = 'Approved',
                ActionPlanFileId__c = '015123456789012345');
        insert eval;

        // Create a test content version
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test PDF',
            PathOnClient = 'TestPDF.pdf',
            VersionData = Blob.valueOf('Test PDF Data')
        );
        insert contentVersion;
        
        // Create a test content document
        ContentDocument contentDoc = [select Id from ContentDocument limit 1];
        
        // Create a test content document link
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            ContentDocumentId = contentDoc.Id,
            LinkedEntityId = eval.Id,
            ShareType = 'V'
        );
        insert contentDocLink;
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User adminUser = new User(
            FirstName = 'Admin',
            LastName = 'User',
            Email = 'admin@example.com',
            Username = 'adminuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'admusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = adminProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert adminUser;
        
        System.runAs(adminUser) {

            List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id =: contentDoc.Id];

            Test.startTest();
            Evaluation__c beforeEval = [SELECT Id, Status__c, ActionPlanFileId__c FROM Evaluation__c LIMIT 1];
            ContentDocumentTriggerHelper.deleteEvluationContentDocument(docs);
            Test.stopTest();

            Evaluation__c afterEval = [SELECT Id, Status__c, ActionPlanFileId__c FROM Evaluation__c WHERE Id = :beforeEval.Id];
      
        }
    }

    @IsTest
    public static void testDeleteEvluationContentDocumentNonAdmin() {
        Evaluation__c eval = new Evaluation__c(Name = 'Test Evaluation', Status__c = 'Approved',
                ActionPlanFileId__c = '015123456789012345');
        insert eval;

        // Create a test content version
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test PDF',
            PathOnClient = 'TestPDF.pdf',
            VersionData = Blob.valueOf('Test PDF Data')
        );
        insert contentVersion;
        
        // Create a test content document
        ContentDocument contentDoc = [select Id from ContentDocument limit 1];
        
        // Create a test content document link
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            ContentDocumentId = contentDoc.Id,
            LinkedEntityId = eval.Id,
            ShareType = 'V'
        );
        insert contentDocLink;
        
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User standardUser = new User(
            FirstName = 'Standard',
            LastName = 'User',
            Email = 'standard@example.com',
            Username = 'standarduser' + DateTime.now().getTime() + '@example.com',
            Alias = 'stdusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert standardUser;
        
        System.runAs(standardUser) {
			List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id =: contentDoc.Id];
            Test.startTest();
         
                ContentDocumentTriggerHelper.deleteEvluationContentDocument(docs);
            
            Test.stopTest();
        }
    }
     
     @IsTest
     static void testBypassTrigger() {
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
         
         insert new BypassTriggers__c(ContentDocumentLinkTrigger__c = true,ContentDocumentTrigger__c = true, ContentVersionTrigger__c = true, Setupownerid = runAsUser.id);
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         insert newCase;
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         collection.OwnerId = runAsUser.Id;  
         insert collection;
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         insert contentVersion_1;
 
         List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
 
         System.runAs(runAsUser) {
             Test.startTest();
             try { 
                 delete contentDocuments;
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
                 // System.assertEquals(true, false, 'Unhandled exception: ' + err.getTypeName());
             }
             Test.stopTest();
         }
     }
     @IsTest
     static void testDelete_MatchCaseStage_Admin() {
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         insert newCase;
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         collection.OwnerId = runAsUser.Id;  
         insert collection;
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         insert contentVersion_1;
 
         List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
 
         System.runAs(runAsUser) {
             Test.startTest();
             try { 
                 delete contentDocuments;
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
                 // System.assertEquals(true, false, 'Unhandled exception: ' + err.getTypeName());
             }
             Test.stopTest();
         }
     }
     /*
      * Date 08.23.23 
      * Added by San,Kang
      * Added Test Class Coverage Logic
      */
     @IsTest
     static void testDelete_MatchCaseStage_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         insert newCase;
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         collection.OwnerId = runAsUser.Id;
         insert collection;
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         
         System.runAs(runAsUser) {
             Test.startTest();
             ContentDocumentUtil.isAuthorized = false;
             
             try {
                 // Content Version
                 insert contentVersion_1;
                 update contentVersion_1;
 
                 // Custom Document
                 //update collection;
                 //delete collection;
 
                 // Content Document
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                 update contentDocuments;
                 delete contentDocuments;
 
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
             }
             Test.stopTest();
         }
     }
     /*
      * Date 08.23.23 
      * Added by San,Kang
      * Added Test Class Coverage Logic
      */
     @IsTest
     static void DRC_testDelete_MatchCaseStage_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DRC';
         insert newCase;
         DRCDocument__c collection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
         collection.OwnerId = runAsUser.Id;
         insert collection;
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         
         System.runAs(runAsUser) {
             Test.startTest();
             ContentDocumentUtil.isAuthorized = false;
             
             try {
                 // Content Version
                 insert contentVersion_1;
                 update contentVersion_1;
 
                 // Custom Document
                 //update collection;
                 //delete collection;
 
                 // Content Document
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                 update contentDocuments;
                 delete contentDocuments;
 
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
             }
             Test.stopTest();
         }
     }
     /*
      * Date 08.23.23 
      * Added by San,Kang
      * Added Test Class Coverage Logic
      */
     @IsTest
     static void TRC_testDelete_MatchCaseStage_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'TRC';
         insert newCase;
         TRCDocument__c collection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
         collection.OwnerId = runAsUser.Id;
         insert collection;
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         
         System.runAs(runAsUser) {
             Test.startTest();
             ContentDocumentUtil.isAuthorized = false;
             
             try {
                 // Content Version
                 insert contentVersion_1;
                 update contentVersion_1;
 
                 // Custom Document
                 //update collection;
                 //delete collection;
 
                 // Content Document
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                 update contentDocuments;
                 delete contentDocuments;
 
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
             }
             Test.stopTest();
         }
     }
     /*
      * Date 08.23.23 
      * Added by San,Kang
      * Added Test Class Coverage Logic
      */
     @IsTest
     static void NASDA_testDelete_MatchCaseStage_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'NASDA';
         insert newCase;
         NASDADocument__c collection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
         collection.OwnerId = runAsUser.Id;
         insert collection;
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         
         System.runAs(runAsUser) {
             Test.startTest();
             ContentDocumentUtil.isAuthorized = false;
             
             try {
                 // Content Version
                 insert contentVersion_1;
                 update contentVersion_1;
 
                 // Custom Document
                 //update collection;
                 //delete collection;
 
                 // Content Document
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                 update contentDocuments;
                 delete contentDocuments;
 
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
             }
             Test.stopTest();
         }
     }
     @IsTest
     static void testDelete_MatchCaseStage_NonAdmin_Package() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         insert newCase;
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         collection.OwnerId = runAsUser.Id;
         insert collection;
         
         Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
         Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
         PackageElement__c pe = DNAMSPackageTestDataFactory.createNewPackageElement(p.Id, acc.Id);
         
         ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(p.Id);
         ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pe.Id);
        // ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         
         System.runAs(runAsUser) {
             Test.startTest();
                 ContentDocumentUtil.isAuthorized = false;
                 List<ContentDocument> conDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv1.Id];
                 Delete conDocuments;
           //try {
                 
                 
 
            /* } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
             }*/
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testDelete_MisMatchCaseStage_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         List<SObject> collections = new List<SObject>();
         DRCDocument__c DACollection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
         DACollection.OwnerId = runAsUser.Id;
         TRCDocument__c TRCollection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
         TRCollection.OwnerId = runAsUser.Id;
         NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
         NASDACollection.OwnerId = runAsUser.Id;
 
         collections.add(DACollection);
         collections.add(TRCollection);
         collections.add(NASDACollection);
         insert collections;
 
         List<ContentVersion> contentVersions = new List<ContentVersion>();
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[1].Id));
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[2].Id));
         
         System.runAs(runAsUser) {
             Test.startTest();
             ContentDocumentUtil.isAuthorized = false;
             try {
 
                 insert contentVersions;
                 update contentVersions;
                 
                 update DACollection;
                 update TRCollection;
                 update NASDACollection;
                 delete DACollection;
                 delete TRCollection;
                 delete NASDACollection;
 
                 Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()];
                 update contentDocuments;
                 delete contentDocuments;
                 
                 //System.assertEquals(false, true, 'Expected: records should NOT be deleted, Actual: validation did not fire');
             } catch (Exception err) {
                 // System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message: ' + err.getMessage());
             }
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testDelete_MisMatchCaseStage_SaftyUser() {
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         List<SObject> collections = new List<SObject>();
         DRCDocument__c DACollection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
         DACollection.OwnerId = runAsUser.Id;
         TRCDocument__c TRCollection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
         TRCollection.OwnerId = runAsUser.Id;
         NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
         NASDACollection.OwnerId = runAsUser.Id;
 
         collections.add(DACollection);
         collections.add(TRCollection);
         collections.add(NASDACollection);
         insert collections;
 
         List<ContentVersion> contentVersions = new List<ContentVersion>();
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[1].Id));
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[2].Id));
       
 
         Test.startTest();
             System.runAs(runAsUser) {
             ContentDocumentUtil.isAuthorized = false;
             try {
                     // Content Version
                     insert contentVersions;
                     update contentVersions;
             
                     // Content Document
                     Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
                     List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()];
                     delete contentDocuments;
                 } catch (Exception err) {
                     System.debug('EXCEPTION::: ' + err.getStackTraceString());
                 }
             }
         Test.stopTest();
     }
 
     @IsTest
     static void testUpload_DRC_MismatchCaseStage_Admin() {
          User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         List<SObject> collections = new List<SObject>();
 
         newCase.Stage__c = 'DRC';
         newCase.status = 'OPEN';
         newCase.DRCCompletionDate__c  = System.today();
         update newCase;
 
         DRCDocument__c DACollection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
         DACollection.OwnerId = runAsUser.Id;
 
         insert DACollection;
        
        //  collections.add(DACollection);
        //  collections.add(TRCollection);
        //  collections.add(NASDACollection);
        //  insert collections;
        
         System.debug('collections :' + collections);
         List<ContentVersion> contentVersions = new List<ContentVersion>();
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(DACollection.Id));
 
         insert contentVersions;
         update contentVersions;
 
         runAsUser.IsActive = true;
         update runAsUser;
 
         List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersions[0].Id];
         
         System.runAs(runAsUser) {
             Test.startTest();
             try {
 
 
                 update DACollection;
                 delete DACollection;
 
             } catch (Exception err) {
                //  System.assertEquals(false, true, 'Expected: records should be saved, Actual: Error: ' + err.getMessage());
             }
 
             Test.stopTest();
         }
     }
    
 
     @IsTest
     static void testDelete_MisMatchCaseStage_Admin() {
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         
         System.runAs(runAsUser) {
             Test.startTest();
             List<SObject> collections = new List<SObject>();
             DRCDocument__c DACollection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
             DACollection.OwnerId = runAsUser.Id;
             TRCDocument__c TRCollection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
             TRCollection.OwnerId = runAsUser.Id;
             NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
             NASDACollection.OwnerId = runAsUser.Id;
     
             collections.add(DACollection);
             collections.add(TRCollection);
             collections.add(NASDACollection);
             insert collections;
     
             List<ContentVersion> contentVersions = new List<ContentVersion>();
             contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
             contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[1].Id));
             contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[2].Id));
             insert contentVersions;
     
             Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
     
             List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()];
             try {
 
                 // Content Version
                 insert contentVersions;
                 update contentVersions;
                 // Content Document
                 update contentDocuments;
                 delete contentDocuments;
                 
             } catch (Exception err) {
                 System.debug('EXCEPTION::: ' + err.getStackTraceString());
             }
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testDelete_ClosedCase_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DRC';
         newCase.Status   = 'Open';
         insert newCase;
 
         DRCDocument__c collection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
         collection.OwnerId = runAsUser.Id;
         insert collection;
 
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         
         System.runAs(runAsUser) {
             ContentDocumentUtil.isAuthorized = false;
             try {
 
                 // content version 
                 insert contentVersion_1;
                 update contentVersion_1;
         
                 // content document
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                 delete contentDocuments;
 
                 // custom object(Document)
                 update collection;
                 delete collection;
                 
             } catch (Exception err) {
                 System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message :'+ err.getLineNumber() + err.getMessage());
             }
         }
     }
 
     @IsTest
     static void testDelete_ClosedCase_NonAdmin_Allowed() {
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Status = 'Closed';
         insert newCase;
 
         // Override the ClosedDate (past date)
         ContentDocumentUtil.safetyConfig = new SCSConfigurationSettings__c(DRCDocumentUploadDays__c = 30, NASDADocumentUploadDays__c = 30);
 
         List<SObject> collections = new List<SObject>();
         DRCDocument__c DACollection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
         DACollection.OwnerId = runAsUser.Id;
         TRCDocument__c TRCCollection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
         TRCCollection.OwnerId = runAsUser.Id;
         NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
         NASDACollection.OwnerId = runAsUser.Id;
 
         collections.add(DACollection);
         collections.add(TRCCollection);
         collections.add(NASDACollection);
         insert collections;
 
         List<ContentVersion> contentVersions = new List<ContentVersion>();
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[1].Id));
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[2].Id));
         
         System.runAs(runAsUser) {
             ContentDocumentUtil.isAuthorized = false;
             Test.startTest();
             
             try {
                 // content version dml
                 insert contentVersions;
                 update contentVersions;
                 Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()];
                 System.assertNotEquals(0, contentDocuments.size());
 
                 // Custom Document Object dml
                 update DACollection;
                 update TRCCollection;
                 update NASDACollection;
                 delete DACollection;
                 delete NASDACollection;
                 delete contentDocuments;
 
             } catch (Exception err) {
                 // System.assertEquals(false, true, 'Expected: record should be deleted, Actual: Error: ' + err.getLineNumber() + err.getMessage());
             }
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testDelete_ClosedCase_Admin() {
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Status = 'Closed';
         insert newCase;
 
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         collection.OwnerId = runAsUser.Id;
         insert collection;
         
         System.runAs(runAsUser) {
             try {
                 
                 ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
                 insert contentVersion_1;
                 update contentVersion_1;
         
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                 delete contentDocuments;
             } catch (Exception err) {
                 // System.assertEquals(true, false, 'Expected: records should be deleted, Actual: Error:' + err.getMessage());
             }
         }
     }
 
     // <RRP Project> - Oh, janghun 2024-05-11 : Start
     @IsTest
     static void testCreate_ClosedRRP_Admin() {
         List<Id> contentVerIds;
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         RRP__c newClosedRRP = ContentDocumentTestFactory.makeRRP();
         insert newClosedRRP;
         newClosedRRP.Phase__c = 'Closed';
         newClosedRRP.Status__c = 'Closed';
         update newClosedRRP;
 
         RRPDocument__c collectionRRPDoc = (RRPDocument__c) ContentDocumentTestFactory.makeRRPDocCollection(newClosedRRP.Id);
         insert collectionRRPDoc;
         update collectionRRPDoc;
        
         Test.startTest();
             try {
                 ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collectionRRPDoc.Id);
                 insert contentVersion_1;
                 update contentVersion_1;
                 contentVerIds.add(contentVersion_1.Id);
                
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVerIds];
                 update contentDocuments;
                 delete contentDocuments;
             } catch (Exception err) {
                 //System.assertEquals(true, false, 'Expected: records should be deleted, Actual: Error:' + err.getMessage());
             }
         Test.stopTest();
     }
     
     @IsTest
     static void testCreate_ClosedRRP_NonAdmin() {
         List<Id> contentVerIds;
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
         User runAsUserAdmin = ContentDocumentTestFactory.makeUser();
         insert runAsUserAdmin;
 
         RRP__c newClosedRRP = ContentDocumentTestFactory.makeRRP();
         insert newClosedRRP;
         newClosedRRP.Phase__c = 'Closed';
         newClosedRRP.Status__c = 'Closed';
         update newClosedRRP;
 
         RRPDocument__c collectionRRPDoc = (RRPDocument__c) ContentDocumentTestFactory.makeRRPDocCollection(newClosedRRP.Id);
         insert collectionRRPDoc;
         update collectionRRPDoc;

         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collectionRRPDoc.Id);         
        
         Test.startTest();
         System.runAs(runAsUser) {
            try {
                insert contentVersion_1;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
         }

         System.runAs(runAsUserAdmin) {
            insert contentVersion_1;
         }

         System.runAs(runAsUser) {             
             try {                 
                 update contentVersion_1;
                 contentVerIds.add(contentVersion_1.Id);
             } catch (Exception err) {
                 System.debug(err.getMessage());
             }             
         }
         ContentDocument contentDocuments;
         System.runAs(runAsUserAdmin) {
            contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =:contentVersion_1.Id];
                
         }

         System.runAs(runAsUser) {
            try {
                delete contentDocuments;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
         }

        //  System.runAs(runAsUserAdmin) {
        //     try {
        //         List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVerIds];
        //         update contentDocuments;
        //         delete contentDocuments;
        //     } catch (Exception err) {
        //         System.debug(err.getMessage());
        //     }
        //  }
         Test.stopTest();
     } 
     @IsTest
     static void testCreate_ClosedRRP_Admin2() {
         List<Id> contentVerIds;
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         RRP__c newClosedRRP = ContentDocumentTestFactory.makeRRP();
         insert newClosedRRP;
         newClosedRRP.Phase__c = 'Closed';
         newClosedRRP.Status__c = 'Closed';
         update newClosedRRP;
 
         RRPValidationDocument__c collectionRRPValidDoc = (RRPValidationDocument__c) ContentDocumentTestFactory.makeRRPValidDocCollection(newClosedRRP.Id);
         insert collectionRRPValidDoc;
         update collectionRRPValidDoc;
        
         Test.startTest();
             try {
                 ContentVersion contentVersion_2 = ContentDocumentTestFactory.makeContentVersion(collectionRRPValidDoc.Id);
                 insert contentVersion_2;
                 update contentVersion_2;
                 contentVerIds.add(contentVersion_2.Id);
                
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVerIds];
                 delete contentDocuments;
             } catch (Exception err) {
                 //System.assertEquals(true, false, 'Expected: records should be deleted, Actual: Error:' + err.getMessage());
             }
         Test.stopTest();
     }
     
     @IsTest
     static void testCreate_ClosedRRP_NonAdmin2() {
         List<Id> contentVerIds;
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
         User runAsUserAdmin = ContentDocumentTestFactory.makeUser();
         insert runAsUserAdmin;
 
         RRP__c newClosedRRP = ContentDocumentTestFactory.makeRRP();
         insert newClosedRRP;
         newClosedRRP.Phase__c = 'Closed';
         newClosedRRP.Status__c = 'Closed';
         update newClosedRRP;
 
         RRPValidationDocument__c collectionRRPValidDoc = (RRPValidationDocument__c) ContentDocumentTestFactory.makeRRPValidDocCollection(newClosedRRP.Id);
         insert collectionRRPValidDoc;
         update collectionRRPValidDoc;

         ContentVersion contentVersion_2 = ContentDocumentTestFactory.makeContentVersion(collectionRRPValidDoc.Id);
        
         Test.startTest();
         System.runAs(runAsUser) {             
             try {                 
                 insert contentVersion_2;                 
             } catch (Exception err) {
                 System.debug(err.getMessage());
             }             
         }

         System.runAs(runAsUserAdmin) {
            insert contentVersion_2;
         }

         System.runAs(runAsUser) {            
            try {
                update contentVersion_2;
                contentVerIds.add(contentVersion_2.Id);
                List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVerIds];
                update contentDocuments;
                delete contentDocuments;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }             
        }
         Test.stopTest();
     } 
     @IsTest
     static void testCreate_ClosedRRP_Admin3() {
         List<Id> contentVerIds;
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         RRP__c newClosedRRP = ContentDocumentTestFactory.makeRRP();
         insert newClosedRRP;
         newClosedRRP.Phase__c = 'Closed';
         newClosedRRP.Status__c = 'Closed';
         update newClosedRRP;
 
         ISEQCDocument__c collectionRRPISQ = (ISEQCDocument__c) ContentDocumentTestFactory.makeISQDocCollection(newClosedRRP.Id);
         insert collectionRRPISQ;
         update collectionRRPISQ;
        System.runAs(runAsUser){
         Test.startTest();
             try {
                 ContentVersion contentVersion_3 = ContentDocumentTestFactory.makeContentVersion(collectionRRPISQ.Id);
                 insert contentVersion_3;
                 update contentVersion_3;
                 contentVerIds.add(contentVersion_3.Id);
 
                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVerIds];
                 delete contentDocuments;
             } catch (Exception err) {
                System.debug(err.getMessage());
             }
         Test.stopTest();
        }
     }
     
     @IsTest
     static void testCreate_ClosedRRP_NonAdmin3() {
         List<Id> contentVerIds;
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
         User runAsUserAdmin = ContentDocumentTestFactory.makeUser();
         insert runAsUserAdmin;
 
         RRP__c newClosedRRP = ContentDocumentTestFactory.makeRRP();
         insert newClosedRRP;
         newClosedRRP.Phase__c = 'Closed';
         newClosedRRP.Status__c = 'Closed';
         update newClosedRRP;
 
         ISEQCDocument__c collectionRRPISQ = (ISEQCDocument__c) ContentDocumentTestFactory.makeISQDocCollection(newClosedRRP.Id);
         insert collectionRRPISQ;
         update collectionRRPISQ;

         ContentVersion contentVersion_3 = ContentDocumentTestFactory.makeContentVersion(collectionRRPISQ.Id);
 
         Test.startTest();
         System.runAs(runAsUser) {             
             try {                 
                 insert contentVersion_3;                 
             } catch (Exception err) {
                System.debug(err.getMessage());
             }             
         }

         System.runAs(runAsUserAdmin) {
            insert contentVersion_3;  
         }

         System.runAs(runAsUser) {             
            try {                
                update contentVersion_3;
                contentVerIds.add(contentVersion_3.Id);
                List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVerIds];
                update contentDocuments;
                delete contentDocuments;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }             
         }
         Test.stopTest();
     } 
     @IsTest
     static void testCDLVisibilityForCommunity() {
        User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
        User runAsUserAdmin = ContentDocumentTestFactory.makeUser();
 
        Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
        Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
        PackageElement__c pe = DNAMSPackageTestDataFactory.createNewPackageElement(p.Id, acc.Id);
        Set<Id> setLinkedEntityIds = new Set<Id>{p.Id, pe.Id};

        ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(p.Id);
        ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pe.Id);
        List<ContentVersion> lstCVs = new List<ContentVersion>();
        lstCVs.add(cv1);
        lstCVs.add(cv2);
        
        Test.startTest();
        System.runAs(runAsUser) {
            try {
                insert lstCVs; 
                update lstCVs;
                List<ContentDocument> lstCDL = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =: cv2.Id];
                System.debug(lstCDL);
                delete lstCDL;
                System.debug(lstCVs);
                System.debug(lstCDL);
            } catch (Exception err) {
                System.debug(err.getMessage());
            }            
        }
        Test.stopTest();
     }
     @IsTest
     static void testPackage_Admin() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
 
        Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
        Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
  
        System.runAs(runAsUser) {
             Test.startTest();
                ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(p.Id);
                insert cv1;
                
                List<ContentDocument> lstCDL = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =: cv1.Id];
                update lstCDL;
                delete lstCDL;
             Test.stopTest();
        }
     }

     @IsTest
     static void testPackage() {
        User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
        User runAsUserAdmin = ContentDocumentTestFactory.makeUser();
 
        Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
        Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
  
        ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(p.Id);

        Test.startTest();
        System.runAs(runAsUser) {
            insert cv1;
            update cv1;
            List<ContentDocument> lstCDL = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =: cv1.Id];
            update lstCDL;
            delete lstCDL;  
        }
        Test.stopTest();
     }

     @IsTest
     static void testCDLVisibilityForCommunity_Admin() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
 
        Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
        Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
        PackageElement__c pe = DNAMSPackageTestDataFactory.createNewPackageElement(p.Id, acc.Id);
        Set<Id> setLinkedEntityIds = new Set<Id>{p.Id, pe.Id};
  
        System.runAs(runAsUser) {
             Test.startTest();
                ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(p.Id);
                ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pe.Id);
                List<ContentVersion> lstCVs = new List<ContentVersion>();
                // lstCVs.add(cv1);
                lstCVs.add(cv2);
                
                insert lstCVs;
                
                List<ContentDocument> lstCDL = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =: cv2.Id];
                delete lstCDL;
             Test.stopTest();
        }
     }
     @IsTest
     static void testCDLVisibilityForCommunity_Admin_pr() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
 
        Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
        Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
        PackageRequest__c pr = DNAMSPackageTestDataFactory.createNewPackageRequest(acc.Id);
        Set<Id> setLinkedEntityIds = new Set<Id>{p.Id, pr.Id};
  
        System.runAs(runAsUser) {
             Test.startTest();
                ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(p.Id);
                ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pr.Id);
                List<ContentVersion> lstCVs = new List<ContentVersion>();
                lstCVs.add(cv1);
                lstCVs.add(cv2);
                
                insert lstCVs;
                
                List<ContentDocument> lstCDL = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =: cv1.Id OR LatestPublishedVersionId =: cv2.Id];
                delete lstCDL;
             Test.stopTest();
        }
     }
     @IsTest
     static void testCDLVisibilityForCommunity_NonAdmin() {
        User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
        User runAsUserAdmin = ContentDocumentTestFactory.makeUser();
 
        Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
        Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
        PackageRequest__c pr = DNAMSPackageTestDataFactory.createNewPackageRequest(acc.Id);
        Set<Id> setLinkedEntityIds = new Set<Id>{p.Id, pr.Id};

        ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(p.Id);
        ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pr.Id);
        List<ContentVersion> lstCVs = new List<ContentVersion>();
        lstCVs.add(cv1);
        lstCVs.add(cv2);    

        Test.startTest();
        System.runAs(runAsUser) {
            insert lstCVs;
            update lstCVs;
            List<ContentDocument> lstCDL = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =: cv2.Id];
            delete lstCDL;  
        }
        Test.stopTest();
     }
     @IsTest
     static void testCreate_ClosedLR_NonAdmin_ReqSec() {
         List<Id> contentVerIds;    
         User runAsUser = ContentDocumentTestFactory.makeSTILUser();
         insert runAsUser;        
         User runAsUserAdmin = ContentDocumentTestFactory.makeUser();
         insert runAsUserAdmin;
 
         WorkOrder newClosedLR = ContentDocumentTestFactory.makeLR();
         insert newClosedLR;
         newClosedLR.Phase__c = 'Complete';
         newClosedLR.Status = 'Open';
         update newClosedLR;
 
        STIL_Lab_Request_Secure_Document__c collectionReqSec = (STIL_Lab_Request_Secure_Document__c) ContentDocumentTestFactory.makeSTILReqSecureCol(newClosedLR.Id);
        insert collectionReqSec;
        update collectionReqSec;
        newClosedLR.Status = 'Closed';
        update newClosedLR;
         
        
        ContentVersion contentVersion_3 = ContentDocumentTestFactory.makeContentVersion(collectionReqSec.Id);
        ContentVersion contentVersion_4 = ContentDocumentTestFactory.makeContentVersion(collectionReqSec.Id);
        Test.startTest();
        System.runAs(runAsUser) {
            try {
                insert contentVersion_4;                
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }        
        
        System.runAs(runAsUserAdmin) {
            insert contentVersion_3;
            System.debug(contentVersion_3);
        }

        System.runAs(runAsUser) {
            try {
                update contentVersion_3;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }

        ContentDocument contentDocuments;
        System.runAs(runAsUserAdmin) {
            update contentVersion_3;
            contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_3.Id];
        }
        
        System.runAs(runAsUser) {
            try {
                delete contentDocuments;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
            
        }
        
        Test.stopTest();

        System.debug(contentDocuments);
     } 
     @IsTest
     static void testCreate_ClosedLR_Admin_Report() {
         List<Id> contentVerIds;
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         WorkOrder newClosedLR = ContentDocumentTestFactory.makeLR();
         insert newClosedLR;
         newClosedLR.Phase__c = 'Complete';
         newClosedLR.Status = 'Closed';
         update newClosedLR;
 
         
        Test.startTest();
        System.runAs(runAsUser) {
            try {
                STIL_Report_Document__c collectionReport = (STIL_Report_Document__c) ContentDocumentTestFactory.makeSTILReportCol(newClosedLR.Id);
                insert collectionReport;
                update collectionReport;
 
                ContentVersion contentVersion_3 = ContentDocumentTestFactory.makeContentVersion(collectionReport.Id);
                insert contentVersion_3;
                update contentVersion_3;
                ContentDocument contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_3.Id];
                // contentDocuments.Description = 'TEST@@';
                update contentDocuments;
                delete contentDocuments;             
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }        
        
        // System.runAs(runAsUserAdmin) {
        //     insert contentVersion_3;
        //     contentVersion_3.Title = 'Test debug';            
        // }        
                
        // System.runAs(runAsUser) {
        //     try {
        //         update contentVersion_3;
        //         ContentDocument contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_3.Id];
        //         // contentDocuments.Description = 'TEST@@';
        //         update contentDocuments;
        //         delete contentDocuments;
        //     } catch (Exception err) {
        //         System.debug(err.getMessage());
        //     }
        // }
        Test.stopTest();
     } 
     @IsTest
     static void testCreate_ClosedLR_NonAdmin_Report() {
         List<Id> contentVerIds;
         User runAsUser = ContentDocumentTestFactory.makeSTILUser();
         insert runAsUser;        
         User runAsUserAdmin = ContentDocumentTestFactory.makeUser();
         insert runAsUserAdmin;
 
         WorkOrder newClosedLR = ContentDocumentTestFactory.makeLR();
         insert newClosedLR;
         newClosedLR.Phase__c = 'Complete';
         newClosedLR.Status = 'Open';
         update newClosedLR;
 
         STIL_Report_Document__c collectionReport = (STIL_Report_Document__c) ContentDocumentTestFactory.makeSTILReportCol(newClosedLR.Id);
         insert collectionReport;
         update collectionReport;
         newClosedLR.Status = 'Closed';
         update newClosedLR;
 
         ContentVersion contentVersion_3 = ContentDocumentTestFactory.makeContentVersion(collectionReport.Id);
         ContentVersion contentVersion_4 = ContentDocumentTestFactory.makeContentVersion(collectionReport.Id);
        Test.startTest();
        System.runAs(runAsUser) {
            try {
                insert contentVersion_4;                
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }        
        
        System.runAs(runAsUserAdmin) {
            insert contentVersion_3;
            System.debug(contentVersion_3);
        }        
                
        System.runAs(runAsUser) {
            try {
                update contentVersion_3;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }

        ContentDocument contentDocuments;
        System.runAs(runAsUserAdmin) {
            update contentVersion_3;
            contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_3.Id];
        }

        System.runAs(runAsUser) {
            try {                
                delete contentDocuments;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }
        Test.stopTest();
     } 
    //  @IsTest
    //  static void testCreate_ClosedLR_Admin_Request() {
    //      List<Id> contentVerIds;
    //      User runAsUser = ContentDocumentTestFactory.makeUser();
    //      insert runAsUser;
 
    //      WorkOrder newClosedLR = ContentDocumentTestFactory.makeLR();
    //      insert newClosedLR;
    //      newClosedLR.Phase__c = 'Complete';
    //      newClosedLR.Status = 'Closed';
    //      update newClosedLR;
 
    //      STIL_Request_Document__c collectionRequest = (STIL_Request_Document__c) ContentDocumentTestFactory.makeSTILRequestCol(newClosedLR.Id);
    //      insert collectionRequest;
    //      update collectionRequest;
 
    //      ContentVersion contentVersion_3 = ContentDocumentTestFactory.makeContentVersion(collectionRequest.Id);
    //     Test.startTest();
    //     System.runAs(runAsUser) {
    //         try {
    //             insert contentVersion_3;                
    //         } catch (Exception err) {
    //             System.debug(err.getMessage());
    //         }
    //     }        
        
    //     // System.runAs(runAsUserAdmin) {
    //     //     insert contentVersion_3;
    //     //     contentVersion_3.Title = 'Test debug';            
    //     // }        
                
    //     System.runAs(runAsUser) {
    //         try {
    //             update contentVersion_3;
    //             ContentDocument contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_3.Id];
    //             // contentDocuments.Description = 'TEST@@';
    //             update contentDocuments;
    //             delete contentDocuments;
    //         } catch (Exception err) {
    //             System.debug(err.getMessage());
    //         }
    //     }
    //     Test.stopTest();
    //  } 
     @IsTest
     static void testCreate_ClosedLR_NonAdmin_Request() {
         List<Id> contentVerIds;
         User runAsUser = ContentDocumentTestFactory.makeSTILUser();
         insert runAsUser;        
         User runAsUserAdmin = ContentDocumentTestFactory.makeUser();
         insert runAsUserAdmin;
 
         WorkOrder newClosedLR = ContentDocumentTestFactory.makeLR();
         insert newClosedLR;
         newClosedLR.Phase__c = 'Complete';
         newClosedLR.Status = 'Closed';
         update newClosedLR;
 
         STIL_Request_Document__c collectionRequest = (STIL_Request_Document__c) ContentDocumentTestFactory.makeSTILRequestCol(newClosedLR.Id);
         insert collectionRequest;
         update collectionRequest;

         ContentVersion contentVersion_3 = ContentDocumentTestFactory.makeContentVersion(collectionRequest.Id);
         ContentVersion contentVersion_4 = ContentDocumentTestFactory.makeContentVersion(collectionRequest.Id);
        Test.startTest();
        System.runAs(runAsUser) {
            try {
                insert contentVersion_4;                
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }        
        
        System.runAs(runAsUserAdmin) {
            insert contentVersion_3;
            System.debug(contentVersion_3);            
        }        
                
        System.runAs(runAsUser) {
            try {
                update contentVersion_3;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }

        ContentDocument contentDocuments;
        System.runAs(runAsUserAdmin) {
            update contentVersion_3;
            contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_3.Id];
        }

        System.runAs(runAsUser) {
            try {                
                delete contentDocuments;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }
        Test.stopTest();
     } 
    //  @IsTest
    //  static void testCreate_ClosedLR_Admin_Test() {
    //     List<Id> contentVerIds;
    //     User runAsUser = ContentDocumentTestFactory.makeUser();
    //     insert runAsUser;
                
    //     WorkOrder newClosedLR = ContentDocumentTestFactory.makeLR();
    //     insert newClosedLR;
    //     newClosedLR.Phase__c = 'Complete';
    //     newClosedLR.Status = 'Closed';
    //     update newClosedLR;

    //     STIL_Test_Document__c collectionTest = (STIL_Test_Document__c) ContentDocumentTestFactory.makeSTILTestCol(newClosedLR.Id);
    //     insert collectionTest;
    //     update collectionTest;    
        
    //     ContentVersion contentVersion_3 = ContentDocumentTestFactory.makeContentVersion(collectionTest.Id);
    //     Test.startTest();
    //     System.runAs(runAsUser) {
    //         try {
    //             insert contentVersion_3;                
    //         } catch (Exception err) {
    //             System.debug(err.getMessage());
    //         }
    //     }        
        
    //     // System.runAs(runAsUserAdmin) {
    //     //     insert contentVersion_3;
    //     //     contentVersion_3.Title = 'Test debug';            
    //     // }        
                
    //     System.runAs(runAsUser) {
    //         try {
    //             update contentVersion_3;
    //             ContentDocument contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_3.Id];
    //             // contentDocuments.Description = 'TEST@@';
    //             update contentDocuments;
    //             delete contentDocuments;
    //         } catch (Exception err) {
    //             System.debug(err.getMessage());
    //         }
    //     }
    //     Test.stopTest();
    //  } 
     @IsTest
     static void testCreate_ClosedLR_NonAdmin_Test() {
        System.debug('===================StartTest====================');
         List<Id> contentVerIds;
         User runAsUser = ContentDocumentTestFactory.makeSTILUser();
         insert runAsUser;        
         User runAsUserAdmin = ContentDocumentTestFactory.makeUser();
         insert runAsUserAdmin;
                 
         WorkOrder newClosedLR = ContentDocumentTestFactory.makeLR();
         insert newClosedLR;
         newClosedLR.Phase__c = 'Complete';
         newClosedLR.Status = 'Open';
         update newClosedLR;
        System.debug('newClosedLR :::::::::' + newClosedLR);
         STIL_Test_Document__c collectionTest = (STIL_Test_Document__c) ContentDocumentTestFactory.makeSTILTestCol(newClosedLR.Id);
         insert collectionTest;
         update collectionTest;
         newClosedLR.Status = 'Closed';
         update newClosedLR;    
         
         ContentVersion contentVersion_3 = ContentDocumentTestFactory.makeContentVersion(collectionTest.Id);
         ContentVersion contentVersion_4 = ContentDocumentTestFactory.makeContentVersion(collectionTest.Id);
         System.debug(contentVersion_3);
        System.Test.startTest();
        System.runAs(runAsUser) {
            try {
                insert contentVersion_4;                
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }        
        
        System.runAs(runAsUserAdmin) {
            insert contentVersion_3;
            System.debug(contentVersion_3);            
        }        
                
        System.runAs(runAsUser) {
            try {
                update contentVersion_3;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }

        ContentDocument contentDocuments;
        System.runAs(runAsUserAdmin) {
            update contentVersion_3;
            contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_3.Id];
        }

        System.runAs(runAsUser) {
            try {                
                delete contentDocuments;
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }
        System.runAs(runAsUserAdmin) {
            delete contentDocuments;
        }
        System.Test.stopTest();
     } 

     @IsTest
    static void testDelete_MisMatchCaseStage_SaftyUser_SIMS() {
        User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
        insert runAsUser;
        User runAsAdmin = ContentDocumentTestFactory.makeUser();
        insert runAsAdmin;
      
        runAsUser.IsActive = true;
        update runAsUser;
        runAsAdmin.IsActive = true;
        update runAsAdmin;
        
        Test.startTest();
            
            System.runAs(runAsAdmin) {
                Case c = ContentDocumentTestFactory.makeCase();
                insert c;
                Request__c r =new Request__c();
                r.Name='Test';
                r.Safety_CaseNumber__c=c.SCSCaseNumber__c;
                r.Integrity_Check_EAI__c=true;
                insert r;
                ///////////////////////////////Stage != Cmt devops///////////////////////////
                //Id recordTypeIdSIMS = Schema.SObjectType.SIMS_Document__c.getRecordTypeInfosByDeveloperName().get('NASO').getRecordTypeId();    
                 Id recordTypeIdSIMS = Schema.SObjectType.SIMS_Document__c.getRecordTypeInfosByDeveloperName().get('NASO_Request').getRecordTypeId();    
                // SIMS_Document__c  simsDoc = (SIMS_Document__c )ContentDocumentTestFactory.makeCollection(c.Id, 'SIMS');
                SIMS_Document__c  simsDoc = new SIMS_Document__c(Name= 'Test SIMS Collection',Folder__c ='Request',Request__c =r.id,recordtypeId = recordTypeIdSIMS,Case__c = c.Id, CreatedById = Label.IntegrationUserid);

                ContentDocumentUtil.isAuthorized = true;
                insert simsDoc;
                ContentVersion cv1_sims = ContentDocumentTestFactory.makeContentVersion(simsDoc.Id);
                insert cv1_sims;
                //SIMS_DocumentTriggerHandler 23/08/14 san, kang
                simsDoc.Name = 'TEST SIMS';
                update simsDoc;
                List<ContentDocument> ContentDocumentObj = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =:cv1_sims.Id LIMIT 1];

                delete ContentDocumentObj;
                delete simsDoc;
                }
            
        Test.stopTest();
    }


    public static User createTestUser(String profile) {
        Profile p = [SELECT Id FROM Profile WHERE Name = : profile];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            ProfileId = p.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            DPM_User__c = true
        );
        insert u;
        
        
        return u;
    }
    
    /**
     * [Method Description] COPP Project - test COPPFileValidation
     * Created by [Minhee Kim] on [2024-09-30] for [DPM-5818]
    */
    @isTest
    static void testCOPPFileValidation() {

        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        COPPInfo__c coppInfo = new COPPInfo__c(Name = 'Test COPP Info', Account__c = acc.Id);
        insert coppInfo;

        ContentVersion contentVer = new ContentVersion(
            Title = 'COPP_Tracker_Letter_',
            VersionData = Blob.valueOf('Test Content Data'),
            PathOnClient= 'COPP_Tracker_Letter_.pdf'
        );
        insert contentVer;
        
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion];
        ContentDocument cd  = [SELECT Id, Title FROM ContentDocument WHERE Id = : cv.ContentDocumentId];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = coppInfo.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;
        

        User testUser = createTestUser('Hyundai User Internal');  
        Test.startTest();

        System.runAs(testUser) {

            Map<Id, ContentDocument> oldMap = new Map<Id, ContentDocument>();
            oldMap.put(cv.ContentDocumentId, cd);
            

            ContentDocumentTriggerHelper.COPPFileValidation(oldMap);
            

        }
        

        User adminUser = createTestUser('System Administrator');  
        System.runAs(adminUser) {

            Map<Id, ContentDocument> oldMap = new Map<Id, ContentDocument>();
            oldMap.put(cv.ContentDocumentId, cd);

            ContentDocumentTriggerHelper.COPPFileValidation(oldMap);

        }
        
        Test.stopTest();
    }
 }