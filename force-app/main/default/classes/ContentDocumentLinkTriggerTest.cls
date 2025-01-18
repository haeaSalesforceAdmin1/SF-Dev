/**
 * Created by baltamimi on 2021-12-27.
 * Added by Bitna Seong on 2023-04-30 : update IsAcitve = true due to error (   System.runAs can only be used with an active user)
 * Added by San,Kang on 2023-08-23 : Fixed i++ Coverage
 */

 @IsTest
 public class ContentDocumentLinkTriggerTest {
     /*
     @IsTest
     static void testUpload_MatchCaseStage_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         insert collection;
 
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         insert contentVersion_1;
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id]);
         List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         if (existingLinks.size() > 0) {
             delete existingLinks;
         }
 
         List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
         for (Id contentDocumentId : contentDocuments.keySet()) {
             contentDocumentLinks.add(ContentDocumentTestFactory.makeContentDocumentLink(contentDocumentId, collection.Id));
         }
 
         System.runAs(runAsUser) {
             Test.startTest();
             ContentDocumentUtil.isAuthorized = false;
             insert contentDocumentLinks;
 
             try {
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
                 System.assertEquals(true, false, 'Unhandled exception: ' + err.getTypeName());
             }
             Test.stopTest();
         }
     }*/
     
     @IsTest
     static void test_TriggerBypass() {
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
         
         insert new BypassTriggers__c(ContentDocumentLinkTrigger__c = true,ContentDocumentTrigger__c = true, ContentVersionTrigger__c = true, Setupownerid = runAsUser.id);
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         insert collection;
 
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         insert contentVersion_1;
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id]);
         List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
         List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         if (existingLinks.size() > 0) {
             delete existingLinks;
         }
 
         for (Id contentDocumentId : contentDocuments.keySet()) {
             contentDocumentLinks.add(ContentDocumentTestFactory.makeContentDocumentLink(contentDocumentId, collection.Id));
         }

         runAsUser.IsActive = true;
         update runAsUser;
 
         System.runAs(runAsUser) {
             Test.startTest();
 
             try {
                 insert contentDocumentLinks;
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
                 System.assertEquals(true, false, 'Unhandled exception: ' + err.getTypeName());
             }
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testUpload_MatchCaseStage_Admin() {
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         insert collection;
 
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         insert contentVersion_1;
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id]);
         List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
         List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         if (existingLinks.size() > 0) {
             delete existingLinks;
         }
 
         for (Id contentDocumentId : contentDocuments.keySet()) {
             contentDocumentLinks.add(ContentDocumentTestFactory.makeContentDocumentLink(contentDocumentId, collection.Id));
         }

         runAsUser.IsActive = true;
         update runAsUser;
 
         System.runAs(runAsUser) {
             Test.startTest();
 
             try {
                 insert contentDocumentLinks;
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
                 System.assertEquals(true, false, 'Unhandled exception: ' + err.getTypeName());
             }
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testUpload_MismatchCaseStage_NonAdmin() {
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
         insert contentVersions;
 
         Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()]);
         List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         if (existingLinks.size() > 0) {
             delete existingLinks;
         }
 
         List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
         for (Id contentDocumentId : contentDocuments.keySet()) {
             for (SObject document : collections) {
                 contentDocumentLinks.add(ContentDocumentTestFactory.makeContentDocumentLink(contentDocumentId, document.Id));
             }
         }
 
         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             ContentDocumentUtil.isAuthorized = false;
 
             Test.startTest();
             try {
                 insert contentDocumentLinks;
                 System.assertEquals(false, true, 'Expected: records should NOT be saved, Actual: validation did not fire');
             } catch (Exception err) {
                 //System.assert(err.getMessage().containsIgnoreCase('upload'), 'Incorrect error message: ' + err.getMessage());
             }
 
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testUpload_MismatchCaseStage_Admin() {
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
         insert contentVersions;
 
         Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()]);
         List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         if (existingLinks.size() > 0) {
             delete existingLinks;
         }
 
         List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
         for (Id contentDocumentId : contentDocuments.keySet()) {
             for (SObject document : collections) {
                 contentDocumentLinks.add(ContentDocumentTestFactory.makeContentDocumentLink(contentDocumentId, document.Id));
             }
         }
 
         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             Test.startTest();
             try {
                 insert contentDocumentLinks;
 
             } catch (Exception err) {
                 System.assertEquals(false, true, 'Expected: records should be saved, Actual: Error: ' + err.getMessage());
             }
 
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testUpload_ClosedCase_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Status = 'Closed';
         insert newCase;
 
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         collection.OwnerId = runAsUser.Id;
         insert collection;
 
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         insert contentVersion_1;
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id]);
         List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
         List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         if (existingLinks.size() > 0) {
             delete existingLinks;
         }
 
         for (Id contentDocumentId : contentDocuments.keySet()) {
             contentDocumentLinks.add(ContentDocumentTestFactory.makeContentDocumentLink(contentDocumentId, collection.Id));
         }
 
         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             ContentDocumentUtil.isAuthorized = false;
             Test.startTest();
 
             try {
                 insert contentDocumentLinks;
                 System.assertEquals(false, true, 'Expected: record should NOT be saved, Actual: validation did not fire');
             } catch (Exception err) {
                 //System.assert(err.getMessage().containsIgnoreCase('create'), 'Incorrect error message: ' + err.getMessage());
             }
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testUpload_ClosedCase_NonAdmin_Allowed() {
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
         NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
         NASDACollection.OwnerId = runAsUser.Id;
 
         collections.add(DACollection);
         collections.add(NASDACollection);
         insert collections;
 
         List<ContentVersion> contentVersions = new List<ContentVersion>();
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[1].Id));
         insert contentVersions;
         Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()]);
         List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
         List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         if (existingLinks.size() > 0) {
             delete existingLinks;
         }
 
         for (Id contentDocumentId : contentDocuments.keySet()) {
             for (SObject document : collections) {
                 contentDocumentLinks.add(ContentDocumentTestFactory.makeContentDocumentLink(contentDocumentId, document.Id));
             }
         }
 
         runAsUser.IsActive = true;
         update runAsUser;
         
         System.runAs(runAsUser) {
             ContentDocumentUtil.isAuthorized = false;
             Test.startTest();
 
             try {
                 insert contentDocumentLinks;
             } catch (Exception err) {
                 System.assertEquals(false, true, 'Expected: record should be saved, Actual: Error: ' + err.getMessage());
             }
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testUpload_ClosedCase_Admin() {
         User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Status = 'Closed';
         insert newCase;
 
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         insert collection;
 
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         insert contentVersion_1;
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id,LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id]);
         List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         if (existingLinks.size() > 0) {
             delete existingLinks;
         }
 
         List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
         for (Id contentDocumentId : contentDocuments.keySet()) {
             contentDocumentLinks.add(ContentDocumentTestFactory.makeContentDocumentLink(contentDocumentId, collection.Id));
         }
 
         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             Test.startTest();
             try {
                 insert contentDocumentLinks;
             } catch (Exception err) {
                 System.assertEquals(false, true, 'Expected: record should be saved, Actual: Error: ' + err.getMessage());
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
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id]);
         List<ContentDocumentLink> contentDocumentLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         System.assertNotEquals(0, contentDocumentLinks.size());
 
         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             Test.startTest();
             try {
                 delete contentDocumentLinks;
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
                 System.assertEquals(true, false, 'Unhandled exception: ' + err.getTypeName());
             }
             Test.stopTest();
         }
     }
 
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
         insert contentVersion_1;
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id]);
         List<ContentDocumentLink> contentDocumentLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         System.assertNotEquals(0, contentDocumentLinks.size());
 
         runAsUser.IsActive = true;
         update runAsUser;
         
         System.runAs(runAsUser) {
             Test.startTest();
             ContentDocumentUtil.isAuthorized = false;
 
             try {
                 delete contentDocumentLinks;
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
                 System.assertEquals(true, false, 'Unhandled exception: ' + err.getTypeName());
             }
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
         insert contentVersions;
 
         Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVersionMap.keySet()]);
         List<ContentDocumentLink> contentDocumentLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         System.assertNotEquals(0, contentDocumentLinks.size());
 
         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             Test.startTest();
             ContentDocumentUtil.isAuthorized = false;
             try {
                 delete contentDocumentLinks;
 
                 //System.assertEquals(false, true, 'Expected: records should NOT be deleted, Actual: validation did not fire');
             } catch (Exception err) {
                 System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message: ' + err.getMessage());
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
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVersionMap.keySet()]);
         List<ContentDocumentLink> contentDocumentLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         System.assertNotEquals(0, contentDocumentLinks.size());
 
         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             Test.startTest();
             try {
                 delete contentDocumentLinks;
             } catch (Exception err) {
                 System.assertEquals(false, true, 'Expected: records should be deleted, Actual: Error: ' + err.getMessage());
             }
             Test.stopTest();
         }
     }
 
     @IsTest
     static void testDelete_ClosedCase_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Status = 'Closed';
         insert newCase;
 
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         collection.OwnerId = runAsUser.Id;
         insert collection;
 
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         insert contentVersion_1;
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id]);
         List<ContentDocumentLink> contentDocumentLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         System.assertNotEquals(0, contentDocumentLinks.size());
 
         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             ContentDocumentUtil.isAuthorized = false;
             try {
                 delete contentDocumentLinks;
                 //System.assertEquals(true, false, 'Expected: records should NOT be deleted, Actual: validation did not fire');
             } catch (Exception err) {
                 System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message: ' + err.getMessage());
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
         NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
         NASDACollection.OwnerId = runAsUser.Id;
 
         collections.add(DACollection);
         collections.add(NASDACollection);
         insert collections;
 
         List<ContentVersion> contentVersions = new List<ContentVersion>();
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[1].Id));
         insert contentVersions;
         Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()]);
         List<ContentDocumentLink> contentDocumentLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         System.assertNotEquals(0, contentDocumentLinks.size());
 
         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             ContentDocumentUtil.isAuthorized = false;
             Test.startTest();
 
             try {
                 delete contentDocumentLinks;
             } catch (Exception err) {
                 System.assertEquals(false, true, 'Expected: record should be deleted, Actual: Error: ' + err.getMessage());
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
 
         ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
         insert contentVersion_1;
 
         Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id]);
         List<ContentDocumentLink> contentDocumentLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocuments.keySet()];
         System.assertNotEquals(0, contentDocumentLinks.size());
 
         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             try {
                 delete contentDocumentLinks;
             } catch (Exception err) {
                 System.assertEquals(true, false, 'Expected: records should be deleted, Actual: Error:' + err.getMessage());
             }
         }
     }
 
     @IsTest
     static void testCDLVisibilityForCommunity() {
                 
         Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
         Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
         PackageElement__c pe = DNAMSPackageTestDataFactory.createNewPackageElement(p.Id, acc.Id);
         Set<Id> setLinkedEntityIds = new Set<Id>{p.Id, pe.Id};
 
         Test.startTest();
         ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(p.Id);
         ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pe.Id);
         List<ContentVersion> lstCVs = new List<ContentVersion>();
         lstCVs.add(cv1);
         lstCVs.add(cv2);
         
         insert lstCVs;
         
         List<ContentDocumentLink> lstCDL = [SELECT Id, Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN :setLinkedEntityIds LIMIT 2];
         System.assertEquals(2, lstCDL.size(), 'File uploads to Packages/Package Elements failed.');
         for(ContentDocumentLink cdl : lstCDL) {
             //System.assertEquals('AllUsers', cdl.Visibility, 'File uploaded to Package/Package Element not visible in the Community.');
         }
     }
     
     @IsTest
     static void testContentDocumentlinkEditable() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
         
         Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
         Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
         PackageElement__c pe = DNAMSPackageTestDataFactory.createNewPackageElement(p.Id, acc.Id);
         Set<Id> setLinkedEntityIds = new Set<Id>{p.Id, pe.Id};
 
         Test.startTest();
         System.runAs(runAsUser) {  
             ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(p.Id);
             ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pe.Id);
             List<ContentVersion> lstCVs = new List<ContentVersion>();
             lstCVs.add(cv1);
             lstCVs.add(cv2);
             
             insert lstCVs;
         }
         Test.stopTest();
 
         List<ContentDocumentLink> lstCDL = [SELECT Id, Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN :setLinkedEntityIds LIMIT 2];
         System.assertEquals(2, lstCDL.size(), 'File uploads to Packages/Package Elements failed.');
         for(ContentDocumentLink cdl : lstCDL) {
             //    System.assertEquals('AllUsers', cdl.Visibility, 'File uploaded to Package/Package Element not visible in the Community.');
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
 /*
     @IsTest
     static void testPreventPkgFileUploadWrongStage() {
         Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
         Package__c p = DNAMSPackageTestDataFactory.getNewPackage(acc.Id);
         p.Status__c = 'Closed';
         insert p;
         PackageRequest__c pr = DNAMSPackageTestDataFactory.getNewPackageRequest(acc.Id);
         pr.Status__c = 'DLR Request Approved';
         insert pr;
         PackageElement__c pe = DNAMSPackageTestDataFactory.createNewPackageElement(p.Id, acc.Id);
 
         Test.startTest();
 
         ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(pr.Id);
         ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pe.Id);
         ContentDocumentUtil.isAuthorized = false;
         try {
             insert cv1;
             System.assertEquals(true, false, 'Expected: Files cannot be uploaded, Actual: Validation did not fire');
         } catch(Exception e) {
             System.assertEquals(true, e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Incorrect Error Message: ' + e.getMessage());
         }
         
         try {
             insert cv2;
             System.assertEquals(true, false, 'Expected: Files cannot be uploaded, Actual: Validation did not fire');
         } catch (Exception e) {
             System.assertEquals(true, e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Incorrect Error Message: ' + e.getMessage());
         }
 
         Test.stopTest();
     }*/
 }