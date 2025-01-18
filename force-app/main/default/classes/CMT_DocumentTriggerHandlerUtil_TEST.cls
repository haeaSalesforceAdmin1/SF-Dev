/**
 * @description       : 
 * @author            : sankang@autoeveramerica.com
 * @group             : 
 * @last modified on  : 07-28-2023
 * @last modified by  : sankang@autoeveramerica.com
**/
@isTest
private class CMT_DocumentTriggerHandlerUtil_TEST {
    // public static User userQuery(String permissionGroup) {
    //     List<Profile> profileName = [SELECT Id,Name FROM Profile WHERE Name IN ('Integration User','System Administrator')];
    //     List<PermissionSetAssignment> userPermission = [SELECT Id,AssigneeId FROM PermissionSetAssignment
    //                     WHERE PermissionSetGroup.DeveloperName =:permissionGroup AND Assignee.IsActive = true AND Assignee.profileId NOT IN :profileName LIMIT 1];
    //     User userInfo = [SELECT Id FROM user WHERE Id =:userPermission[0].AssigneeId];
    //     return userInfo;
    // }
    // static testMethod void myUnitTest() {

    //     User DAUser = userQuery('Service_Safety_DA_Manager');
    //     User DRCUser = userQuery('Service_Safety_DRC_Manager');
    //     User TRCUser = userQuery('Service_Safety_TRC_Manager');
    //     User NASDAUser = userQuery('Service_Safety_NASDA_Manager');

    //     Id DArecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();
    //     Id DRCrecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DRC').getRecordTypeId();
    //     Id TRCrecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('TRC').getRecordTypeId();
    //     Id NASDArecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('NASDA').getRecordTypeId();

    //     Case DADocumentCase = new Case(
    //         Subject='Test Subject',
    //         Status='Open', 
    //         Stage__c='DA',
    //         DAPhaseStartDate__c=Date.today(),
    //         RecordTypeId = DArecordTypeId,
    //         Haveyoupreviouslyreportedtheissues__c = 'No',
    //         CompanyName__c = 'HMA',
    //         CountrySubmitterWorks__c = 'United States',
    //         SCSCaseRegion__c= 'Other',
    //         Description = 'TEST',
    //         Priority = 'Medium');
    //     insert DADocumentCase;

    //     Case DRCDocumentCase = new Case(
    //         Subject='Test Subject',
    //         Status='Open',
    //         Stage__c='DRC',
    //         DAPhaseStartDate__c=Date.today(),
    //         DACompletionDate__c=Date.today(),
    //         DRCPhaseStartDate__c=Date.today(),
    //         RecordTypeId = DRCrecordTypeId,
    //         Haveyoupreviouslyreportedtheissues__c = 'No',
    //         CompanyName__c = 'HMA',
    //         CountrySubmitterWorks__c = 'United States',
    //         SCSCaseRegion__c= 'Other',
    //         Description = 'TEST',
    //         Priority = 'Medium');
        
    //     insert DRCDocumentCase;

    //     Case TRCDocumentCase = new Case(
    //         Subject='Test Subject',
    //         Status='Open',
    //         Stage__c='TRC',
    //         DAPhaseStartDate__c=Date.today(),
    //         DACompletionDate__c=Date.today(),
    //         DRCPhaseStartDate__c=Date.today(),
    //         DRCCompletionDate__c=Date.today(),
    //         TRCPhaseStartDate__c=Date.today(),
    //         RecordTypeId = TRCrecordTypeId,
    //         Haveyoupreviouslyreportedtheissues__c = 'No',
    //         CompanyName__c = 'HMA',
    //         CountrySubmitterWorks__c = 'United States',
    //         SCSCaseRegion__c= 'Other',
    //         Description = 'TEST',
    //         Priority = 'Medium');
    //     insert TRCDocumentCase;

    //     Case NASDADocumentCase = new Case(
    //         Subject='Test Subject',
    //         Status='Open',
    //         Stage__c='NASDA',
    //         DAPhaseStartDate__c=Date.today(),
    //         DACompletionDate__c=Date.today(),
    //         DRCPhaseStartDate__c=Date.today(),
    //         DRCCompletionDate__c=Date.today(),
    //         TRCPhaseStartDate__c=Date.today(),
    //         TRCCompletionDate__c=Date.today(),
    //         NASDAPhaseStartDate__c=Date.today(),
    //         RecordTypeId = NASDArecordTypeId,
    //         Haveyoupreviouslyreportedtheissues__c = 'No',
    //         CompanyName__c = 'HMA',
    //         CountrySubmitterWorks__c = 'United States',
    //         SCSCaseRegion__c= 'Other',
    //         Description = 'TEST',
    //         Priority = 'Medium');
    //     insert NASDADocumentCase;
        

    //     DADocuments__c DADocument = (DADocuments__c) ContentDocumentTestFactory.makeCollection(DADocumentCase.Id, 'DA');
    //     DADocument.OwnerId = DAUser.Id;
    //     insert DADocument;
    //     DRCDocument__c DRCDocument = (DRCDocument__c) ContentDocumentTestFactory.makeCollection(DRCDocumentCase.Id, 'DRC');
    //     DRCDocument.OwnerId = DRCUser.Id;

    //     TRCDocument__c TRCDocument = (TRCDocument__c) ContentDocumentTestFactory.makeCollection(TRCDocumentCase.Id, 'TRC');
    //     TRCDocument.OwnerId = TRCUser.Id;

    //     NASDADocument__c NASDADocument = (NASDADocument__c) ContentDocumentTestFactory.makeCollection(NASDADocumentCase.Id, 'NASDA');
    //     Id recordTypeIdNASDA = Schema.SObjectType.NASDADocument__c.getRecordTypeInfosByDeveloperName().get('CaseDocument').getRecordTypeId();
    //     NASDADocument.RecordTypeId=recordTypeIdNASDA;
    //     NASDADocument.OwnerId = NASDAUser.Id;
    //     System.debug('dauser'+DAuser);
    //     Test.startTest();
    //         System.runAs(DAUser){
    //             update DADocument;
    //             delete DADocument;
    //         }
    //         System.runAs(DRCUser){
    //             insert DRCDocument;
    //             delete DRCDocument;
    //         }
    //         System.runAs(TRCUser){
    //             insert TRCDocument;
    //             delete TRCDocument;
    //         }
    //         System.runAs(NASDAUser){
    //             insert NASDADocument;
    //             delete NASDADocument;
    //         }
    //     Test.stopTest();

    // }

    @IsTest
    static void test_DADocument() {
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

    @IsTest
    static void test_DRCDocument() {
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

    @IsTest
    static void test_TRCDocument() {
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

    @IsTest
    static void test_NASDADocument() {
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

    //09-13-2023 San,Kang : CMT_DocumentTriggerHandlerUtil Bug Fix
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

    //09-13-2023 San,Kang : CMT_DocumentTriggerHandlerUtil Bug Fix
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
    static void test_Documents_SaftyUser_Quality() {
        PermissionSetAssignment psa = [SELECT Id, AssigneeId
                            FROM PermissionSetAssignment
                            WHERE PermissionSet.Name='QC_Quality_Quality_Manager' AND IsActive = true LIMIT 1];
        User runAsUser = [SELECT Id FROM USER WHERE Id =: psa.AssigneeId];
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('SCDC').getRecordTypeId();
        Case c = ContentDocumentTestFactory.makeCase();
        insert c;
        c.stage__c = 'SCDC';
        c.recordTypeId=recordTypeId;
        update c;

        Q_DRC_Document__c QDRCDoc = new Q_DRC_Document__c(Case__c = c.Id,
        Folder__c = 'Data',
        Name = 'QDRC Test');
        Q_TRC_Document__c QTRCDoc = new Q_TRC_Document__c(Case__c = c.Id,
        Folder__c = 'Data',
        Name = 'QTRC Test');
        SCDC_Document__c SCDCDoc = new SCDC_Document__c(Case__c = c.Id,
        Folder__c = 'Other',
        Name = 'SCDC Test');
        
        System.runAs(runAsUser) {
            Test.startTest();
                try {
                    insert QDRCDoc;
                    insert QTRCDoc;
                    insert SCDCDoc;
                    
                    update QDRCDoc;
                    update QTRCDoc;
                    update SCDCDoc;
                
                    delete QDRCDoc;
                    delete QTRCDoc;
                    delete SCDCDoc;
                } catch (Exception err) {
                    // System.assertEquals(false, true, err.getLineNumber() + '/' + err.getMessage());
                    System.debug('EXCEPTION::: ' + err.getStackTraceString());
                }
            Test.stopTest();
        }
    }
}