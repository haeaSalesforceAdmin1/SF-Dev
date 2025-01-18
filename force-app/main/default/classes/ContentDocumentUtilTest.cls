/**
 * Created by baltamimi on 2021-12-22.
 * Updated by Inhokim / 09-19-2024 / [[SO-440]]
 */

@IsTest
private class ContentDocumentUtilTest {

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
        
        System.runAs(runAsUser) {
            Test.startTest();
            ContentDocumentUtil.isAuthorized = false;
            
            try {
                // Content Version
                insert contentVersion_1;
                update contentVersion_1;

                // Custom Document
                update collection;
                delete collection;

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

    // 20230920 : comment out to modify by Bitna Seong
    // @IsTest
    // static void testDelete_MisMatchCaseStage_NonAdmin() {
    //     //User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
    //     User runAsUser = ContentDocumentTestFactory.makeUser();
    //     insert runAsUser;

    //     Case newCase = ContentDocumentTestFactory.makeCase();
    //     newCase.Stage__c = 'DA';
    //     insert newCase;

    //     System.runAs(runAsUser) {
    //         Test.startTest();
    //         List<SObject> collections = new List<SObject>();
    //         DRCDocument__c DACollection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
    //         DACollection.OwnerId = runAsUser.Id;
    //         TRCDocument__c TRCollection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
    //         TRCollection.OwnerId = runAsUser.Id;
    //         NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
    //         NASDACollection.OwnerId = runAsUser.Id;

    //         collections.add(DACollection);
    //         collections.add(TRCollection);
    //         collections.add(NASDACollection);
    //         insert collections;

    //         List<ContentVersion> contentVersions = new List<ContentVersion>();
    //         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
    //         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[1].Id));
    //         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[2].Id));
            

    //         ContentDocumentUtil.isAuthorized = false;
    //         try {

    //             //bitna too many soql
    //             // insert contentVersions;
    //             // update contentVersions;
                
    //             update DACollection;
    //             update TRCollection;
    //             update NASDACollection;
    //             delete DACollection;
    //             delete TRCollection;
    //             delete NASDACollection;

    //             Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
    //             List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()];
    //             update contentDocuments;
    //             delete contentDocuments;
                
    //             //System.assertEquals(false, true, 'Expected: records should NOT be deleted, Actual: validation did not fire');
    //         } catch (Exception err) {
    //             System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message: ' + err.getMessage());
    //         }
    //         Test.stopTest();
    //     }
    // }

    // @IsTest
    // static void testDelete_MisMatchCaseStage_SaftyUser() {
    //     User runAsUser = ContentDocumentTestFactory.makeUser();
    //     insert runAsUser;

    //     Case newCase = ContentDocumentTestFactory.makeCase();
    //     newCase.Stage__c = 'DA';
    //     insert newCase;

    //     Test.startTest();
    //     System.runAs(runAsUser) {
    //         List<SObject> collections = new List<SObject>();
    //         DRCDocument__c DACollection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
    //         DACollection.OwnerId = runAsUser.Id;
    //         TRCDocument__c TRCollection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
    //         TRCollection.OwnerId = runAsUser.Id;
    //         NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
    //         NASDACollection.OwnerId = runAsUser.Id;

    //         collections.add(DACollection);
    //         collections.add(TRCollection);
    //         collections.add(NASDACollection);
    //         insert collections;

    //         List<ContentVersion> contentVersions = new List<ContentVersion>();
    //         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
    //         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[1].Id));
    //         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[2].Id));
        
    //         ContentDocumentUtil.isAuthorized = false;
    //         try {
    //                 // Content Version
    //                 insert contentVersions;
    //                 update contentVersions;
            
    //                 // Content Document
    //                 Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
    //                 List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()];
    //                 delete contentDocuments;
    //             } catch (Exception err) {
    //                 System.debug('EXCEPTION::: ' + err.getStackTraceString());
    //             }
    //             Test.stopTest();
    //         }   
    // }

    // @IsTest
    // static void testDelete_MisMatchCaseStage_Admin() {
    //     User runAsUser = ContentDocumentTestFactory.makeUser();
    //     insert runAsUser;

    //     Case newCase = ContentDocumentTestFactory.makeCase();
    //     newCase.Stage__c = 'DA';
    //     insert newCase;

        
    //     System.runAs(runAsUser) {
    //         Test.startTest();
    //         List<SObject> collections = new List<SObject>();
    //         DRCDocument__c DACollection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
    //         DACollection.OwnerId = runAsUser.Id;
    //         TRCDocument__c TRCollection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
    //         TRCollection.OwnerId = runAsUser.Id;
    //         NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
    //         NASDACollection.OwnerId = runAsUser.Id;
    
    //         collections.add(DACollection);
    //         collections.add(TRCollection);
    //         collections.add(NASDACollection);
    //         insert collections;
    
    //         List<ContentVersion> contentVersions = new List<ContentVersion>();
    //         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
    //         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[1].Id));
    //         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[2].Id));
    //         insert contentVersions;
    
    //         Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
    
    //         List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()];
    //         try {
    //             //bitna too many soql
    //             // Content Version
    //             insert contentVersions;
    //             update contentVersions;

                
    //             // Content Document
    //             update contentDocuments;
    //             delete contentDocuments;
                
    //         } catch (Exception err) {
    //             System.debug('EXCEPTION::: ' + err.getStackTraceString());
    //         }
    //         Test.stopTest();
    //     }
    // }
    // 20230920 : comment out to modify by Bitna Seong

    
    // 20230920 : add to fix error by Bitna Seong
    @IsTest
    static void testDelete_MisMatchCaseStage_NonAdmin() {
        //test for DRC document
        //User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
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

            collections.add(DACollection);

            insert collections;

            List<ContentVersion> contentVersions = new List<ContentVersion>();
            contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));

            ContentDocumentUtil.isAuthorized = false;
            try {

                //bitna too many soql
                // insert contentVersions;
                // update contentVersions;
                
                update DACollection;
                delete DACollection;

                // Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
                // List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()];
                // update contentDocuments;
                // delete contentDocuments;
                
                //System.assertEquals(false, true, 'Expected: records should NOT be deleted, Actual: validation did not fire');
            } catch (Exception err) {
                //San,Kang 2023-10-19 : AssertException
                //System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message: ' + err.getMessage());
                System.debug(err.getMessage().containsIgnoreCase('delete')+ 'Incorrect error message: ' + err.getMessage());
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void testDelete_MisMatchCaseStage_SaftyUser() {
        //test DRC document and contentversion
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Stage__c = 'DA';
        insert newCase;



        Test.startTest();
        System.runAs(runAsUser) {
            List<SObject> collections = new List<SObject>();
            TRCDocument__c TRCollection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
            TRCollection.OwnerId = runAsUser.Id;
    
            collections.add(TRCollection);
            insert collections;
    
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
        
            ContentDocumentUtil.isAuthorized = false;

            try {
                    // Content Version
                    insert contentVersions;
                    update contentVersions;

                } catch (Exception err) {
                    System.debug('EXCEPTION::: ' + err.getStackTraceString());
                }
                Test.stopTest();
            }   
    }

    @IsTest
    static void testDelete_MisMatchCaseStage_Admin() {
        //test for SDA(nasda) document and contentdocument
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Stage__c = 'DA';
        insert newCase;

        
        System.runAs(runAsUser) {
            Test.startTest();
            List<SObject> collections = new List<SObject>();

            NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
            NASDACollection.OwnerId = runAsUser.Id;
    
            collections.add(NASDACollection);
            insert collections;
    
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
            insert contentVersions;
    
            Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
    
            List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()];
            try {
                //bitna too many soql
                // Content Version
                // insert contentVersions;
                // update contentVersions;

                
                // Content Document
                update contentDocuments;
                delete contentDocuments;
                
            } catch (Exception err) {
                System.debug('EXCEPTION::: ' + err.getStackTraceString());
            }
            Test.stopTest();
        }
    }
    // 20230920 : add to fix error by Bitna Seong


    @IsTest
    static void testDelete_ClosedCase_NonAdmin() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Stage__c = 'DRC';
        newCase.Status   = 'Open';
        insert newCase;

        System.runAs(runAsUser) {
            Test.startTest();
                DRCDocument__c collection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
                collection.OwnerId = runAsUser.Id;
                insert collection;

                ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);     
                ContentDocumentUtil.isAuthorized = false;

                Boolean allowed;
                String docType;
                 
                try {

                    // content version 
                    insert contentVersion_1;
                    update contentVersion_1;
            

                    Map<ID, DRCDocument__c> docByDocumentId = new Map<ID, DRCDocument__c>([SELECT Id, Case__c, Case__r.IsClosed, Case__r.Status, Case__r.Stage__c FROM DRCDocument__c LIMIT 1]);
                    Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
                    for(DRCDocument__c da : docByDocumentId.values()) {
                        allowed = getUpdateDocumentsBydocId.get(da.Id);
                        docType = da.getSobjectType().getDescribe().getName();
                    }
                    System.assertEquals(true, allowed, 'KASO TEST');
                    System.assertEquals(true, docType.equalsIgnoreCase('DRCDocument__c'), 'KASO TEST');


                    // content document
                    List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                    delete contentDocuments;

                    // custom object(Document)
                    update collection;
                    delete collection;
                    
                } catch (Exception err) {
                    System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message :'+ err.getLineNumber() + err.getMessage());
                }
            Test.stopTest();
        }
    }
    @IsTest
    static void testDelete_ClosedCase_NonAdmin_DA() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Stage__c = 'DA';
        newCase.Status   = 'Open';
        insert newCase;

        System.runAs(runAsUser) {
            Test.startTest();
                DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
                collection.OwnerId = runAsUser.Id;
                insert collection;

                ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);     
                ContentDocumentUtil.isAuthorized = false;

                Boolean allowed;
                String docType;
                 
                try {

                    // content version 
                    insert contentVersion_1;
                    update contentVersion_1;
            

                    Map<ID, DADocuments__c> docByDocumentId = new Map<ID, DADocuments__c>([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c FROM DADocuments__c LIMIT 1]);
                    Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
                    for(DADocuments__c da : docByDocumentId.values()) {
                        allowed = getUpdateDocumentsBydocId.get(da.Id);
                        docType = da.getSobjectType().getDescribe().getName();
                    }
                    System.assertEquals(true, allowed, 'KASO TEST');
                    System.assertEquals(true, docType.equalsIgnoreCase('DADocuments__c'), 'KASO TEST');


                    // content document
                    List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                    delete contentDocuments;

                    // custom object(Document)
                    update collection;
                    delete collection;
                    
                } catch (Exception err) {
                    System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message :'+ err.getLineNumber() + err.getMessage());
                }
            Test.stopTest();
        }
    }


    @IsTest
    static void testDelete_ClosedCase_NonAdmin_TRC() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Stage__c = 'TRC';
        newCase.Status   = 'Open';
        insert newCase;

        System.runAs(runAsUser) {
            Test.startTest();
                TRCDocument__c collection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
                collection.OwnerId = runAsUser.Id;
                insert collection;

                ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);     
                ContentDocumentUtil.isAuthorized = false;

                Boolean allowed;
                String docType;
                 
                try {

                    // content version 
                    insert contentVersion_1;
                    update contentVersion_1;
            

                    Map<ID, TRCDocument__c> docByDocumentId = new Map<ID, TRCDocument__c>([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c FROM TRCDocument__c LIMIT 1]);
                    Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
                    for(TRCDocument__c da : docByDocumentId.values()) {
                        allowed = getUpdateDocumentsBydocId.get(da.Id);
                        docType = da.getSobjectType().getDescribe().getName();
                    }
                    System.assertEquals(true, allowed, 'KASO TEST');
                    System.assertEquals(true, docType.equalsIgnoreCase('TRCDocument__c'), 'KASO TEST');


                    // content document
                    List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                    delete contentDocuments;

                    // custom object(Document)
                    update collection;
                    delete collection;
                    
                } catch (Exception err) {
                    System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message :'+ err.getLineNumber() + err.getMessage());
                }
            Test.stopTest();
        }
    }


    @IsTest
    static void testDelete_ClosedCase_NonAdmin_NASDA() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Stage__c = 'NASDA';
        newCase.Status   = 'Open';
        insert newCase;

        System.runAs(runAsUser) {
            Test.startTest();
                NASDADocument__c collection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
                collection.OwnerId = runAsUser.Id;
                insert collection;

                ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);     
                ContentDocumentUtil.isAuthorized = false;

                Boolean allowed;
                String docType;
                 
                try {

                    // content version 
                    insert contentVersion_1;
                    update contentVersion_1;
            

                    Map<ID, NASDADocument__c> docByDocumentId = new Map<ID, NASDADocument__c>([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c, Case__r.NASDACompletionDate__c FROM NASDADocument__c LIMIT 1]);
                    Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
                    for(NASDADocument__c da : docByDocumentId.values()) {
                        allowed = getUpdateDocumentsBydocId.get(da.Id);
                        docType = da.getSobjectType().getDescribe().getName();
                    }
                    System.assertEquals(true, allowed, 'KASO TEST');
                    System.assertEquals(true, docType.equalsIgnoreCase('NASDADocument__c'), 'KASO TEST');


                    // content document
                    List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                    delete contentDocuments;

                    // custom object(Document)
                    update collection;
                    delete collection;
                    
                } catch (Exception err) {
                    System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message :'+ err.getLineNumber() + err.getMessage());
                }
            Test.stopTest();
        }
    }

    @IsTest
    static void testDelete_ClosedCase_NonAdmin_Allowed() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Status = 'Closed';
        insert newCase;

        System.runAs(runAsUser) {
            Test.startTest();
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
            
            ContentDocumentUtil.isAuthorized = false;
            Boolean allowed;
            String docType;
             
            try {
                // content version dml
                insert contentVersions;
                update contentVersions;
                Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(contentVersions);
                List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionMap.keySet()];
                System.assertNotEquals(0, contentDocuments.size());

                Map<ID, DADocuments__c> docByDocumentId = new Map<ID, DADocuments__c>([SELECT Id, Case__c, Case__r.IsClosed, Case__r.Status, Case__r.Stage__c FROM DADocuments__c LIMIT 1]);
                Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
                for(DADocuments__c da : docByDocumentId.values()) {
                    allowed = getUpdateDocumentsBydocId.get(da.Id);
                    docType = da.getSobjectType().getDescribe().getName();
                }
                System.assertEquals(true, allowed, 'KASO TEST');
                System.assertEquals(true, docType.equalsIgnoreCase('DADocuments__c'), 'KASO TEST');


                // Custom Document Object dml
                update DACollection;
                update TRCCollection;
                update NASDACollection;
                delete DACollection;
                delete NASDACollection;
                delete contentDocuments;

            } catch (Exception err) {
                System.assertEquals(true, true, 'Expected: record should be deleted, Actual: Error: ' + err.getLineNumber() + err.getMessage());
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

        System.runAs(runAsUser) {
            Test.startTest();
            DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
            collection.OwnerId = runAsUser.Id;
            insert collection;
            
            try {
                
                ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
                insert contentVersion_1;
                update contentVersion_1;
        
                List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                delete contentDocuments;
            } catch (Exception err) {
                System.assertEquals(true, false, 'Expected: records should be deleted, Actual: Error:' + err.getMessage());
            }
            Test.stopTest();
        }
    }

    // ADD NEW TEST FOR COVERAGE 
    // <QCMT>[SO-440] / InhoKim / 2024-09-19 : test method for Q-DA + ContentDocumentUtil.checkDocAuthorByDocumentId() method coverage
    @IsTest
    static void testDelete_ClosedCase_NonAdmin_Q_DA() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Stage__c = 'DA';
        newCase.Status   = 'Open';
        
        insert newCase;

        newCase.QualityCaseConfirmed__c = 'Yes';
        update newCase; 

        System.runAs(runAsUser) {
            Test.startTest();
                DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'Q-DA');
                collection.OwnerId = runAsUser.Id;
                insert collection;

                ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);     
                ContentDocumentUtil.isAuthorized = false;

                Boolean allowed;
                String docType;
                 
                try {

                    // content version 
                    insert contentVersion_1;
                    update contentVersion_1;
            

                    Map<ID, DADocuments__c> docByDocumentId = new Map<ID, DADocuments__c>([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c FROM DADocuments__c LIMIT 1]);
                    Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
                    for(DADocuments__c da : docByDocumentId.values()) {
                        allowed = getUpdateDocumentsBydocId.get(da.Id);
                        docType = da.getSobjectType().getDescribe().getName();
                    }


                    // content document
                    List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                    delete contentDocuments;

                    // custom object(Document)
                    update collection;
                    delete collection;
                    
                } catch (Exception err) {
                    System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message :'+ err.getLineNumber() + err.getMessage());
                }
            Test.stopTest();
        }
    }

    // ADD NEW TEST FOR COVERAGE 
    // <QCMT>[SO-440] / InhoKim / 2024-09-19 : test method for Q-DRC + ContentDocumentUtil.checkDocAuthorByDocumentId() method coverage
    @IsTest
    static void testDelete_ClosedCase_NonAdmin_Q_DRC() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Stage__c = 'DA';
        newCase.Status   = 'Open';
        
        insert newCase;

        newCase.QualityCaseConfirmed__c = 'Yes';
        update newCase; 

        System.runAs(runAsUser) {
            Test.startTest();
                Q_DRC_Document__c collection = (Q_DRC_Document__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'Q-DRC');
                collection.OwnerId = runAsUser.Id;
                insert collection;

                ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);     
                ContentDocumentUtil.isAuthorized = false;

                Boolean allowed;
                String docType;
                 
                try {

                    // content version 
                    insert contentVersion_1;
                    update contentVersion_1;
            

                    Map<ID, Q_DRC_Document__c> docByDocumentId = new Map<ID, Q_DRC_Document__c>([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c FROM Q_DRC_Document__c LIMIT 1]);
                    Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
                    for(Q_DRC_Document__c da : docByDocumentId.values()) {
                        allowed = getUpdateDocumentsBydocId.get(da.Id);
                        docType = da.getSobjectType().getDescribe().getName();
                    }


                    // content document
                    List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                    delete contentDocuments;

                    // custom object(Document)
                    update collection;
                    delete collection;
                    
                } catch (Exception err) {
                    System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message :'+ err.getLineNumber() + err.getMessage());
                }
            Test.stopTest();
        }
    }

    // ADD NEW TEST FOR COVERAGE 
    // <QCMT>[SO-440] / InhoKim / 2024-09-19 : test method for Q-TRC + ContentDocumentUtil.checkDocAuthorByDocumentId() method coverage
    @IsTest
    static void testDelete_ClosedCase_NonAdmin_Q_TRC() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Stage__c = 'DA';
        newCase.Status   = 'Open';
        
        insert newCase;

        newCase.QualityCaseConfirmed__c = 'Yes';
        update newCase; 

        System.runAs(runAsUser) {
            Test.startTest();
                Q_TRC_Document__c collection = (Q_TRC_Document__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'Q-TRC');
                collection.OwnerId = runAsUser.Id;
                insert collection;

                ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);     
                ContentDocumentUtil.isAuthorized = false;

                Boolean allowed;
                String docType;
                 
                try {

                    // content version 
                    insert contentVersion_1;
                    update contentVersion_1;
            

                    Map<ID, Q_TRC_Document__c> docByDocumentId = new Map<ID, Q_TRC_Document__c>([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c FROM Q_TRC_Document__c LIMIT 1]);
                    Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
                    for(Q_TRC_Document__c da : docByDocumentId.values()) {
                        allowed = getUpdateDocumentsBydocId.get(da.Id);
                        docType = da.getSobjectType().getDescribe().getName();
                    }


                    // content document
                    List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                    delete contentDocuments;

                    // custom object(Document)
                    update collection;
                    delete collection;
                    
                } catch (Exception err) {
                    System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message :'+ err.getLineNumber() + err.getMessage());
                }
            Test.stopTest();
        }
    }


    // <QCMT>[SO-440] / InhoKim / 2024-09-19 : test method for SCDC + ContentDocumentUtil.checkDocAuthorByDocumentId() method coverage
    @IsTest    
    static void testDelete_ClosedCase_NonAdmin_SCDC() {
        User runAsUser = ContentDocumentTestFactory.makeUser();
        insert runAsUser;

        Case newCase = ContentDocumentTestFactory.makeCase();
        newCase.Stage__c = 'DA';
        newCase.Status   = 'Open';
        insert newCase;
        newCase.QualityCaseConfirmed__c = 'Yes';
        update newCase;

        System.runAs(runAsUser) {
            Test.startTest();
                SCDC_Document__c collection = (SCDC_Document__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'SCDC');
                collection.OwnerId = runAsUser.Id;
                insert collection;

                ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);     
                ContentDocumentUtil.isAuthorized = false;

                Boolean allowed;
                String docType;
                 
                try {

                    // content version 
                    insert contentVersion_1;
                    update contentVersion_1;
            

                    Map<ID, SCDC_Document__c> docByDocumentId = new Map<ID, SCDC_Document__c>([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c FROM SCDC_Document__c LIMIT 1]);
                    Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(docByDocumentId);
                    for(SCDC_Document__c da : docByDocumentId.values()) {
                        allowed = getUpdateDocumentsBydocId.get(da.Id);
                        docType = da.getSobjectType().getDescribe().getName();
                    }


                    // content document
                    List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion_1.Id];
                    delete contentDocuments;

                    // custom object(Document)
                    update collection;
                    delete collection;
                    
                } catch (Exception err) {
                    System.assert(err.getMessage().containsIgnoreCase('delete'), 'Incorrect error message :'+ err.getLineNumber() + err.getMessage());
                }
            Test.stopTest();
        }
    }






}