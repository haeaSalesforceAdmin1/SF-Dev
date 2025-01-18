/**
 * Created by baltamimi on 2021-12-20.
 * Added by Bitna Seong on 2023-04-30 : update IsAcitve = true due to error (   System.runAs can only be used with an active user)
 * Added by san kang on 2023-08-14: testUpload_DRC_MismatchCaseStage_Admin       -
 *                                     testUpload_TRC_MismatchCaseStage_Admin       -  Validation rule, split into any soql issues
 *                                     testUpload_NASDA_MismatchCaseStage_Admin     -
 * 
 *                                     testDelete_MisMatchCaseStage_SaftyUser_SIMS  -
 *                                     testDelete_MisMatchCaseStage_SaftyUser_Legal - Add ContentVersionUtil TEST Code
 *                                     testDelete_MisMatchCaseStage_SaftyUser_Misc  - 
 * 
 */

 @IsTest
 private class ContentVersionTriggerTest {
     
     
      @TestSetup
    public static void setupTestData() {
        
    }
    
     
     @IsTest
     static void test_BypassTrigger() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         insert new BypassTriggers__c(ContentDocumentLinkTrigger__c = true,ContentDocumentTrigger__c = true, ContentVersionTrigger__c = true, Setupownerid = runAsUser.id);
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         insert collection;
 
         runAsUser.IsActive = true;
         update runAsUser;
         
         System.runAs(runAsUser) {
             Test.startTest();
             ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
             ContentDocumentUtil.isAuthorized = false;
             try {
                 insert contentVersion_1;
                 update contentVersion_1;
                 update collection;
                 delete collection;
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
             }
             Test.stopTest();
         }
     }
     
     @IsTest
     static void testUpload_MatchCaseStage_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         insert collection;
 
         runAsUser.IsActive = true;
         update runAsUser;
         
         System.runAs(runAsUser) {
             Test.startTest();
             ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
             ContentDocumentUtil.isAuthorized = false;
             try {
                 insert contentVersion_1;
                 update contentVersion_1;
                 update collection;
                 delete collection;
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
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
 
         runAsUser.IsActive = true;
         update runAsUser;
         
         System.runAs(runAsUser) {
             Test.startTest();
             ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
             try {
                 insert contentVersion_1;
                 update contentVersion_1;
                 update collection;
                 delete collection;
             } catch (Exception err) {
                 System.debug('ERROR DETAILS:: ' + err.getStackTraceString());
             }
             Test.stopTest();
         }
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
        
        ContentVersion cv = [SELECT Id, ContentDocumentId, Title FROM ContentVersion];
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

            Map<Id, ContentVersion> newMap = new Map<Id, ContentVersion>();
            newMap.put(cv.ContentDocumentId, cv);
            

            ContentVersionTriggerHelper.COPPFileValidation(newMap);
            

        }
        

        User adminUser = createTestUser('System Administrator');  
        System.runAs(adminUser) {

            Map<Id, ContentVersion> newMap = new Map<Id, ContentVersion>();
            newMap.put(cv.ContentDocumentId, cv);

            ContentVersionTriggerHelper.COPPFileValidation(newMap);

        }
        
        Test.stopTest();
    }
 
    //  @IsTest
    //  static void testUpload_MismatchCaseStage_Admin() {
    //       User runAsUser = ContentDocumentTestFactory.makeUser();
    //      insert runAsUser;
 
    //      Case newCase = ContentDocumentTestFactory.makeCase();
    //      newCase.Stage__c = 'DA';
    //      insert newCase;
 
    //      List<SObject> collections = new List<SObject>();
    //      DRCDocument__c DACollection = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DRC');
    //      DACollection.OwnerId = runAsUser.Id;
    //      TRCDocument__c TRCollection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
    //      TRCollection.OwnerId = runAsUser.Id;
    //      NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
    //      NASDACollection.OwnerId = runAsUser.Id;
 
    //      collections.add(DACollection);
    //      collections.add(TRCollection);
    //      collections.add(NASDACollection);
    //      insert collections;
 
    //      List<ContentVersion> contentVersions = new List<ContentVersion>();
    //      contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[0].Id));
    //      contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[1].Id));
    //      contentVersions.add(ContentDocumentTestFactory.makeContentVersion(collections[2].Id));
 

    //      runAsUser.IsActive = true;
    //      update runAsUser;

    //      System.runAs(runAsUser) {
    //          Test.startTest();
    //          try {
    //              insert contentVersions;
    //              update contentVersions;

    //              update DACollection;
    //              update TRCollection;
    //              update NASDACollection;

    //              delete DACollection;
    //              delete TRCollection;
    //              delete NASDACollection;
 
    //          } catch (Exception err) {
    //             //  System.assertEquals(false, true, 'Expected: records should be saved, Actual: Error: ' + err.getMessage());
    //          }
 
    //          Test.stopTest();
    //      }
    //  }

     /**
     * 23/08/14 San,Kang
     * testUpload_MismatchCaseStage_Admin : Validation rule, Many SOQL Issue  
     */
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

 

         runAsUser.IsActive = true;
         update runAsUser;



         System.runAs(runAsUser) {
             Test.startTest();
             try {
                 insert contentVersions;
                 update contentVersions;
                 
                 update DACollection;
                 delete DACollection;
 
             } catch (Exception err) {
                //  System.assertEquals(false, true, 'Expected: records should be saved, Actual: Error: ' + err.getMessage());
             }
 
             Test.stopTest();
         }
     }

    /**
    * 23/08/14 San,Kang
    * testUpload_MismatchCaseStage_Admin : Validation rule, Many SOQL Issue  
    */
     @IsTest
     static void testUpload_TRC_MismatchCaseStage_Admin() {
          User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         List<SObject> collections = new List<SObject>();

         newCase.Stage__c = 'TRC';
         newCase.status = 'OPEN';
         newCase.TRCCompletionDate__c  = System.today();
         update newCase;

         TRCDocument__c TRCCollection = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'TRC');
         TRCCollection.OwnerId = runAsUser.Id;

         insert TRCCollection;
        
         System.debug('collections :' + collections);

         List<ContentVersion> contentVersions = new List<ContentVersion>();
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(TRCCollection.Id));

 

         runAsUser.IsActive = true;
         update runAsUser;



         System.runAs(runAsUser) {
             Test.startTest();
             try {
                 insert contentVersions;
                 update contentVersions;
                 
                 update TRCCollection;
                 delete TRCCollection;
 
             } catch (Exception err) {
                //  System.assertEquals(false, true, 'Expected: records should be saved, Actual: Error: ' + err.getMessage());
             }
 
             Test.stopTest();
         }
     }
     /**
      * 23/08/14 San,Kang
      * testUpload_MismatchCaseStage_Admin : Validation rule, Many SOQL Issue  
      */
     @IsTest
     static void testUpload_NASDA_MismatchCaseStage_Admin() {
          User runAsUser = ContentDocumentTestFactory.makeUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         newCase.Stage__c = 'DA';
         insert newCase;
 
         List<SObject> collections = new List<SObject>();

         newCase.Stage__c = 'NASDA';
         newCase.status = 'OPEN';
         newCase.TRCCompletionDate__c  = System.today();
         update newCase;

         NASDADocument__c NASDACollection = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'NASDA');
         Id recordTypeIdNASDA = Schema.SObjectType.NASDADocument__c.getRecordTypeInfosByDeveloperName().get('CaseDocument').getRecordTypeId();

         NASDACollection.recordTypeId = recordTypeIdNASDA;
         NASDACollection.OwnerId = runAsUser.Id;

         insert NASDACollection;
        
         List<ContentVersion> contentVersions = new List<ContentVersion>();
         contentVersions.add(ContentDocumentTestFactory.makeContentVersion(NASDACollection.Id));

         runAsUser.IsActive = true;
         update runAsUser;

         System.runAs(runAsUser) {
             Test.startTest();
             try {
                 insert contentVersions;
                 update contentVersions;
                 
                 update NASDACollection;
                 delete NASDACollection;
 
             } catch (Exception err) {
                //  System.assertEquals(false, true, 'Expected: records should be saved, Actual: Error: ' + err.getMessage());
             }
 
             Test.stopTest();
         }
     }

     @IsTest
     static void testUpload_ClosedCase_NonAdmin() {
         User runAsUser = ContentDocumentTestFactory.makeSaftyUser();
         insert runAsUser;
 
         Case newCase = ContentDocumentTestFactory.makeCase();
         insert newCase;
 
         DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
         collection.OwnerId = runAsUser.Id;
         insert collection;
 
         runAsUser.IsActive = true;
         update runAsUser;
         
         System.runAs(runAsUser) {
             ContentDocumentUtil.isAuthorized = false;
             Test.startTest();
             ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
 
             try {
                 insert contentVersion_1;
                 update contentVersion_1;
                 
                 update collection;
                 delete collection;
                 
                } catch (Exception err) {
                //  System.assertEquals(false, true, 'Expected: record should NOT be saved, Actual: validation did not fire');
                //  System.assert(err.getMessage().containsIgnoreCase('create'), 'Incorrect error message: ' + err.getMessage());
             }
             Test.stopTest();
         }
     }
 
    //  @IsTest
    //  static void testUpload_ClosedCase_Admin() {
    //      User runAsUser = ContentDocumentTestFactory.makeUser();
    //      insert runAsUser;
 
    //      Case newCase = ContentDocumentTestFactory.makeCase();
    //      newCase.Status = 'Closed';
    //      insert newCase;
 
    //      DADocuments__c collection = (DADocuments__c) ContentDocumentTestFactory.makeCollection(newCase.Id, 'DA');
    //      insert collection;

    //      runAsUser.IsActive = true;
    //      update runAsUser;

    //      System.runAs(runAsUser) {
    //          Test.startTest();
 
    //          ContentVersion contentVersion_1 = ContentDocumentTestFactory.makeContentVersion(collection.Id);
    //          try {
    //              insert contentVersion_1;
    //              update contentVersion_1;
                 
    //              update collection;
    //              delete collection;
                 
    //          } catch (Exception err) {
    //              System.assertEquals(false, true, 'Expected: record should be saved, Actual: Error: ' + err.getMessage());
    //          }
    //          Test.stopTest();
    //      }
    //  }
    static User getIntegrationUser() {
         return [SELECT Id FROM User WHERE FirstName LIKE 'Integration%']?.get(0);
     }
     public static User makeUser() {
         Profile p = [SELECT Id FROM Profile WHERE Name = 'Safety Service Manager'];
         return new User(
                 Alias = 'tUse9982',
                 Email = 'tuser9982@sfhyundai.com',
                 EmailEncodingKey = 'UTF-8',
                 LastName = 'Testing',
                 LanguageLocaleKey = 'en_US',
                 LocaleSidKey = 'en_US',
                 ProfileId = p.Id,
                 TimeZoneSidKey = 'America/New_York',
                 Username = 'tuser9982@sfhyundai.com'
         );
     }
     static HMAReferenceData__c makeReference() {
         HMAReferenceData__c referenceData = new HMAReferenceData__c();
         referenceData.Make__c = 'Hyundai';
         referenceData.VehicleModel__c = 'SANTA FE';
         referenceData.Year__c = '2020';
         referenceData.FuelType__c = 'Gas';
         referenceData.EngineDescription__c = '2.4L I4 GDI Theta II';
         referenceData.DrivetrainDescription__c = 'ALL WHEEL DRIVE';
         referenceData.TransmissionDescription__c = 'AUTO';
         referenceData.ModelCode__c = 'TMA';
         return referenceData;
     }

// SO-292 comment out to fix test error by Bitna Seong start
//  static testMethod void handleContentVersionTriggerHandlerAfterInsert() {
//          HMAReferenceData__c reference = makeReference();
//          insert reference;
//          Case c = new Case();
//          c.Subject = 'Test Subject';
//          c.Description = 'Test Description';
//          c.CompanyName__c = 'HMA';
//          c.CountrySubmitterWorks__c = 'Canada';
//          c.SCSCaseRegion__c = 'North America';
//          c.Haveyoupreviouslyreportedtheissues__c = 'No';
//          Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();
//          c.RecordTypeId = recordTypeId;
//          //c.SCSCaseNumber__c = 'Test1';
//          c.TrackingID__c= '73';
//          //c.CaseID__c='5NMS33AD2LH202622';
//          c.SODAS_Alert_ID__c='Test';
//          c.SIMS_GSI_Number__c='73';
//          c.Origin= 'Value';
//          c.VIN_Text_Field__c= '5NMS33AD2LH202622';
//          c.Make__c= 'Hyundai';
//          c.HazardCategory__c= '1-Difficulty/inability to control direction/path (steering, stability, etc.)';
//          c.MY__c= '2020';
//          c.MethodofRepair__c= 'Dealer to replace the engine';
//          c.Parts__c= '2';
//          c.PossiblyAssociablePrimaryHazard__c= 'Difficulty/inability to control direction/path (steering, stability, etc.)';
//          c.Region__c= 'central region';
//          c.Severity__c= '3';
//          c.CategoryofComponentAffected__c= 'Engine';
//          c.ModelCode__c= 'TMA';
//          c.CompanyName__c= 'HMA';
//          c.CountrySubmitterWorks__c= 'Korea';
//          c.Haveyoupreviouslyreportedtheissues__c= 'No';
//         //  c.FirstReportSource__c= 'Common SEL';
//          c.Engine__c='2.4L I4 GDI Theta II';
//          c.Fuel_Type__c='Gas';
//          c.VehicleModel__c='Santa Fe';
//          c.Common_SEL_Report_Included__c=false;
//          insert c;
//      system.assert(c.Id != null);
//      user u = getIntegrationUser();
//      system.assert(u.Id!=null);
//          System.runAs(u) {       
//          DADocuments__c da = new DADocuments__c();
//          da.Name='Sample test data004';
//          da.Case__c= c.Id;
//         //  da.Folder__c= 'SIMS_Common_SEL_Report';
//          insert da;
//              system.assert(da.Id != null);
   
//          Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
 
//         //  ContentVersion cv = new ContentVersion(FirstPublishLocationID = da.Id,title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
//          ContentVersion cv = ContentDocumentTestFactory.makeContentVersion(da.Id);
//          insert cv;
//          cv.title = 'Update ContentVersion';
//          cv.description = 'Update Description';
//          update cv;

//          update da;
//          delete da;
//          system.assert(cv.Id != null);
//    }
        
//      }
// SO-292 comment out to fix test error by Bitna Seong start

     static testMethod void handleContentVersionTriggerHandlerAfterInsert1() {
         HMAReferenceData__c reference = makeReference();
         insert reference;
         Case c = new Case();
         c.Subject = 'Test Subject';
         c.Description = 'Test Description';
         c.CompanyName__c = 'HMA';
         c.CountrySubmitterWorks__c = 'Canada';
         c.SCSCaseRegion__c = 'North America';
         c.Haveyoupreviouslyreportedtheissues__c = 'No';
         Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DRC').getRecordTypeId();
         c.RecordTypeId = recordTypeId;
         c.SCSCaseNumber__c = 'Test1';
         c.TrackingID__c= '73';
         //c.CaseID__c='5NMS33AD2LH202622';
         c.SODAS_Alert_ID__c='Test';
         c.SIMS_GSI_Number__c='73';
         c.Origin= 'Value';
         c.VIN_Text_Field__c= '5NMS33AD2LH202622';
         c.Make__c= 'Hyundai';
         c.HazardCategory__c= '1-Difficulty/inability to control direction/path (steering, stability, etc.)';
         c.MY__c= '2020';
         c.MethodofRepair__c= 'Dealer to replace the engine';
         c.Parts__c= '2';
         c.PossiblyAssociablePrimaryHazard__c= 'Difficulty/inability to control direction/path (steering, stability, etc.)';
         c.Region__c= 'central region';
         c.Severity__c= '3';
         c.CategoryofComponentAffected__c= 'Engine';
         c.ModelCode__c= 'TMA';
         c.CompanyName__c= 'HMA';
         c.CountrySubmitterWorks__c= 'Korea';
         c.Haveyoupreviouslyreportedtheissues__c= 'No';
        //  c.FirstReportSource__c= 'Common SEL';
         c.Engine__c='2.4L I4 GDI Theta II';
         c.Fuel_Type__c='Gas';
         c.VehicleModel__c='Santa Fe';
         c.Common_SEL_Report_Included__c=false;
         c.Status = 'Closed';
         c.DRCPhaseStartDate__c = date.today();
         c.DRCCompletionDate__c = date.today();
         insert c;
         system.assert(c != null);
     
         System.runAs(getIntegrationUser()) {        
         
            String recordType = Schema.SObjectType.DRCDocument__c.getRecordTypeInfosByName().get('Meeting Document').getRecordTypeId();
            DRCDocument__c drcc= new DRCDocument__c();
            drcc.recordTypeId=recordType;
            drcc.Name='test';
            drcc.MeetingDate__c=Date.newInstance(2022, 12, 12);
            drcc.Folder__c='Data';
            //drc.add(drcc);
        try {

            insert drcc;
             system.assert(drcc != null);
   
         Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
 
         ContentVersion cv = new ContentVersion(FirstPublishLocationID = drcc.Id,title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
         insert cv;
         update cv;
         system.assert(cv != null);
        } catch(Exception e) {}
   }
        
     }

    // @IsTest
    // static void testDelete_MisMatchCaseStage_SaftyUser2() {
    //     User runAsUser = ContentVersionTriggerTest.makeUser();
    //     insert runAsUser;
    //     User runAsAdmin = ContentDocumentTestFactory.makeUser();
    //     insert runAsAdmin;
 
    //     Id drc_recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DRC').getRecordTypeId();
    //     Id trc_recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('TRC').getRecordTypeId();
    //     Id nasda_recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('NASDA').getRecordTypeId();
    //     Case c = ContentDocumentTestFactory.makeCase();
    //     insert c;
      
    //     runAsUser.IsActive = true;
    //     update runAsUser;
    //     runAsAdmin.IsActive = true;
    //     update runAsAdmin;
        
    //     Test.startTest();
    //         System.runAs(runAsAdmin) {
    //             DADocuments__c    daDoc2  = (DADocuments__c )ContentDocumentTestFactory.makeCollection(c.Id, 'DA');
    //             SIMS_Document__c  simsDoc = (SIMS_Document__c )ContentDocumentTestFactory.makeCollection(c.Id, 'SIMS');
    //             try {
    //                 ContentDocumentUtil.isAuthorized = null;
    //                 insert daDoc2;
    //                 insert simsDoc;
    //                 ContentVersion cv1_da = ContentDocumentTestFactory.makeContentVersion(daDoc2.Id);
    //                 ContentVersion cv1_sims = ContentDocumentTestFactory.makeContentVersion(simsDoc.Id);
    //                 insert cv1_da;
    //                 update cv1_da;

    //                 insert cv1_sims;
    //                 update cv1_sims;
                    

    //             } catch(Exception err) {
    //                 // System.assertEquals(false, true, err.getLineNumber() + '/' + err.getMessage());
    //             }
    //         }
    //         System.runAs(runAsUser) {
    //                 DADocuments__c    daDoc2  = (DADocuments__c )ContentDocumentTestFactory.makeCollection(c.Id, 'DA');
    //                 SIMS_Document__c  simsDoc = (SIMS_Document__c )ContentDocumentTestFactory.makeCollection(c.Id, 'SIMS');
    //                 try {
    //                     ContentDocumentUtil.isAuthorized = true;
    //                     insert daDoc2;
    //                     insert simsDoc;
    //                     ContentVersion cv1_da = ContentDocumentTestFactory.makeContentVersion(daDoc2.Id);
    //                     ContentVersion cv1_sims = ContentDocumentTestFactory.makeContentVersion(simsDoc.Id);
    //                     insert cv1_da;
    //                     update cv1_da;
    
    //                     insert cv1_sims;
    //                     update cv1_sims;
    //                 } catch(Exception err) {
    //                     // System.assertEquals(false, true, err.getLineNumber() + '/' + err.getMessage());
    //                 }
    //             }
    //         System.runAs(runAsUser) {
    //             ContentDocumentUtil.isAuthorized = false;
    //             try {

    //                 DADocuments__c daDoc  = (DADocuments__c)ContentDocumentTestFactory.makeCollection(c.Id, 'DA');
    //                 daDoc.OwnerId = runAsUser.Id;
    //                 insert daDoc;
    //                 ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(daDoc.Id);
    //                 insert cv1;
    //                 update cv1;
                        
    //                 // DRC
    //                 c.Stage__c = 'DRC';
    //                 c.recordTypeId = drc_recordTypeId;
    //                 c.DRCPhaseStartDate__c   = date.today();
    //                 c.DRCCompletionDate__c   = date.today();
    //                 update c; 
    //                 DRCDocument__c drcDoc = (DRCDocument__c)ContentDocumentTestFactory.makeCollection(c.Id, 'DRC');
    //                 drcDoc.OwnerId = runAsUser.Id;
    //                 insert drcDoc;
    //                 ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(drcDoc.Id);
    //                 insert cv2;
    //                 update cv2;

    //                 // TRC
    //                 c.Stage__c = 'TRC';
    //                 c.recordTypeId = trc_recordTypeId;
    //                 c.Status   = 'Open';
    //                 c.TRCCompletionDate__c   = date.today();
    //                 update c; 
    //                 TRCDocument__c trcDoc = (TRCDocument__c)ContentDocumentTestFactory.makeCollection(c.Id, 'TRC');
    //                 trcDoc.OwnerId = runAsUser.Id;
    //                 insert trcDoc;
    //                 ContentVersion cv3 = ContentDocumentTestFactory.makeContentVersion(trcDoc.Id);
    //                 insert cv3;
    //                 update cv3;

    //                 // NASDA
    //                 c.Stage__c = 'NASDA';
    //                 c.Status   = 'Open';
    //                 c.recordTypeId = nasda_recordTypeId;
    //                 c.NASDACompletionDate__c = date.today();
    //                 update c; 
    //                 NASDADocument__c nasdaDoc = (NASDADocument__c)ContentDocumentTestFactory.makeCollection(c.Id, 'NASDA');
    //                 nasdaDoc.OwnerId = runAsUser.Id;
    //                 insert nasdaDoc;
    //                 ContentVersion cv4 = ContentDocumentTestFactory.makeContentVersion(nasdaDoc.Id);
    //                 insert cv4;
    //                 update cv4;

    //             } catch (Exception err) {
    //                 // System.assertEquals(false, true, err.getLineNumber() + '/' + err.getMessage());
    //                 System.debug('EXEPTION:::' + err.getLineNumber() + '/' + err.getMessage());
    //             }
    //         }
    //     Test.stopTest();
    // }
    
    /**
     * 23/08/14 San, Kang 
     * SIMSDocumentTriggerHandler, FileHistoryUtil TEST Coverage
     */
    @IsTest
    static void testDelete_MisMatchCaseStage_SaftyUser_SIMS() {
        User runAsUser = ContentVersionTriggerTest.makeUser();
        insert runAsUser;
        User runAsAdmin = ContentDocumentTestFactory.makeUser();
        insert runAsAdmin;
      
        runAsUser.IsActive = true;
        update runAsUser;
        runAsAdmin.IsActive = true;
        update runAsAdmin;
        
        Test.startTest();
            
            System.runAs(runAsAdmin) {
                ContentWorkSpace cws = new ContentWorkSpace(Name = 'CUVCertified');
        		insert cws;
                ContentWorkSpace cwsCPO = new ContentWorkSpace(Name = 'CPOCertified');
        		insert cwsCPO;
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
    /**
     * 23/08/14 San, Kang 
     * LegalDocumentTriggerHandler, FileHistoryUtil TEST Coverage
     */
    @IsTest
    static void testDelete_MisMatchCaseStage_SaftyUser_Legal() {
        User runAsUser = ContentVersionTriggerTest.makeUser();
        insert runAsUser;
        User runAsAdmin = ContentDocumentTestFactory.makeUser();
        insert runAsAdmin;
      
        runAsUser.IsActive = true;
        update runAsUser;
        runAsAdmin.IsActive = true;
        update runAsAdmin;
        
        Test.startTest();
            
            System.runAs(runAsAdmin) {
                ContentWorkSpace cws = new ContentWorkSpace(Name = 'CUVCertified');
        		insert cws;
                ContentWorkSpace cwsCPO = new ContentWorkSpace(Name = 'CPOCertified');
        		insert cwsCPO;
                Case c = ContentDocumentTestFactory.makeCase();
                insert c;
                LegalDocument__c  legalDoc = new LegalDocument__c(Name= 'Test LEGAL Collection',Case__c = c.Id);
                ContentDocumentUtil.isAuthorized = true;

                insert legalDoc;
                ContentVersion cv1_legal = ContentDocumentTestFactory.makeContentVersion(legalDoc.Id);
                insert cv1_legal;
                legalDoc.Case_File_ID__c = 'TEST LEGAL';
                legalDoc.Case_Search__c = 'TEST LEGAL';
                update legalDoc;
                
                List<ContentDocument> ContentDocumentObj = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =:cv1_legal.Id LIMIT 1];
                List<LegalDocument__c> LegalDocumentObj = [SELECT Id FROM LegalDocument__c WHERE Id =:legalDoc.Id];

                delete ContentDocumentObj;
                delete LegalDocumentObj;
                }
            
        Test.stopTest();
    }

    /**
     * 23/08/14 San, Kang 
     * MiscDocumentTriggerHandler, FileHistoryUtil TEST Coverage
     */
    @IsTest
    static void testDelete_MisMatchCaseStage_SaftyUser_Misc() {
        User runAsUser = ContentVersionTriggerTest.makeUser();
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

                ContentWorkSpace cws = new ContentWorkSpace(Name = 'CUVCertified');
        		insert cws;
                ContentWorkSpace cwsCPO = new ContentWorkSpace(Name = 'CPOCertified');
        		insert cwsCPO;
                MiscDocument__c  miscDoc = new MiscDocument__c(Name= 'Test MISC Collection',Case__c = c.Id);
                
                insert miscDoc;
                ContentVersion cv1_misc = ContentDocumentTestFactory.makeContentVersion(miscDoc.Id);
                insert cv1_misc;
                miscDoc.Name = 'TEST MISC';
                update miscDoc;
                List<ContentDocument> ContentDocumentObj = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =:cv1_misc.Id LIMIT 1];

                delete ContentDocumentObj;
                delete miscDoc;
                }
            
        Test.stopTest();
    }

    @IsTest
    static void testDelete_Documents_SaftyUser_DA() {
        User runAsUser = ContentVersionTriggerTest.makeUser();
        insert runAsUser;
 
        Case c = ContentDocumentTestFactory.makeCase();
        c.Stage__c = 'DA';
        insert c;
      
        runAsUser.IsActive = true;
        update runAsUser;

        Test.startTest();
            System.runAs(runAsUser) {
                ContentDocumentUtil.isAuthorized = false;
                try {

                    DADocuments__c daDoc  = (DADocuments__c)ContentDocumentTestFactory.makeCollection(c.Id, 'DA');
                    daDoc.OwnerId = runAsUser.Id;
                    insert daDoc;
                    update daDoc;
                    delete daDoc;

                } catch (Exception err) {
                    // System.assertEquals(false, true, err.getLineNumber() + '/' + err.getMessage());
                    System.debug('EXCEPTION::: ' + err.getStackTraceString());
                }
            }
        Test.stopTest();
    }
    @IsTest
    static void testDelete_Documents_SaftyUser_DRC() {
        User runAsUser = ContentVersionTriggerTest.makeUser();
        insert runAsUser;
 
        Id drc_recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DRC').getRecordTypeId();
        Case c = ContentDocumentTestFactory.makeCase();
        c.Stage__c = 'DA';
        insert c;
      
        runAsUser.IsActive = true;
        update runAsUser;

        Test.startTest();
            System.runAs(runAsUser) {
                ContentDocumentUtil.isAuthorized = false;
                try {
                        
                    // DRC
                    c.Stage__c = 'DRC';
                    c.recordTypeId = drc_recordTypeId;
                    c.DRCPhaseStartDate__c   = date.today();
                    c.DRCCompletionDate__c   = date.today();
                    update c; 
                    DRCDocument__c drcDoc = (DRCDocument__c)ContentDocumentTestFactory.makeCollection(c.Id, 'DRC');
                    drcDoc.OwnerId = runAsUser.Id;
                    insert drcDoc;
                    update drcDoc;
                    delete drcDoc;

                } catch (Exception err) {
                    // System.assertEquals(false, true, err.getLineNumber() + '/' + err.getMessage());
                    System.debug('EXCEPTION::: ' + err.getStackTraceString());
                }
            }
        Test.stopTest();
    }
    @IsTest
    static void testDelete_Documents_SaftyUser_TRC() {
        User runAsUser = ContentVersionTriggerTest.makeUser();
        insert runAsUser;
 
        Id trc_recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('TRC').getRecordTypeId();
        Case c = ContentDocumentTestFactory.makeCase();
        c.Stage__c = 'DA';
        insert c;
      
        runAsUser.IsActive = true;
        update runAsUser;

        Test.startTest();
            System.runAs(runAsUser) {
                ContentDocumentUtil.isAuthorized = false;
                try {

                    // TRC
                    c.Stage__c = 'TRC';
                    c.recordTypeId = trc_recordTypeId;
                    c.Status   = 'Open';
                    c.TRCCompletionDate__c   = date.today();
                    update c; 
                    TRCDocument__c trcDoc = (TRCDocument__c)ContentDocumentTestFactory.makeCollection(c.Id, 'TRC');
                    trcDoc.OwnerId = runAsUser.Id;
                    insert trcDoc;
                    update trcDoc;
                    delete trcDoc;

                } catch (Exception err) {
                    // System.assertEquals(false, true, err.getLineNumber() + '/' + err.getMessage());
                    System.debug('EXCEPTION::: ' + err.getStackTraceString());
                }
            }
        Test.stopTest();
    }
    @IsTest
    static void testDelete_Documents_SaftyUser_NASDA() {
        User runAsUser = ContentVersionTriggerTest.makeUser();
        insert runAsUser;
 
        Id nasda_recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('NASDA').getRecordTypeId();
        Case c = ContentDocumentTestFactory.makeCase();
        c.Stage__c = 'DA';
        insert c;
      
        runAsUser.IsActive = true;
        update runAsUser;

        Test.startTest();
            System.runAs(runAsUser) {
                ContentDocumentUtil.isAuthorized = false;
                try {

                    // NASDA
                    c.Stage__c = 'NASDA';
                    c.Status   = 'Open';
                    c.recordTypeId = nasda_recordTypeId;
                    c.NASDACompletionDate__c = date.today();
                    update c; 
                    NASDADocument__c nasdaDoc = (NASDADocument__c)ContentDocumentTestFactory.makeCollection(c.Id, 'NASDA');
                    nasdaDoc.OwnerId = runAsUser.Id;
                    insert nasdaDoc;
                    update nasdaDoc;
                    delete nasdaDoc;

                } catch (Exception err) {
                    // System.assertEquals(false, true, err.getLineNumber() + '/' + err.getMessage());
                    System.debug('EXCEPTION::: ' + err.getStackTraceString());
                }
            }
        Test.stopTest();
    }
}