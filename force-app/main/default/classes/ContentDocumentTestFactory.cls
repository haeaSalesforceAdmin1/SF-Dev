/**
 * Created by baltamimi on 2021-12-21.
 * Updated by Inhokim / 09-19-2024 / [[SO-440]]
 */

 @IsTest
 public class ContentDocumentTestFactory {
     public static Case makeCase() {
         Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();
 
         return new Case(
                 Subject = 'Test Hyundai G80 Car',
                 Description = 'Hyundai G80',
                 Make__c = 'Hyundai',
                 VehicleModel__c = 'G80',
                 MY__c = '2021',
                 SafetyType__c = 'Vehicle',
                 CompanyName__c = 'HMA',
                 CountrySubmitterWorks__c = 'Canada',
                 SCSCaseRegion__c = 'North America',
                 Haveyoupreviouslyreportedtheissues__c = 'No',
                 RecordTypeId = recordTypeId,
                 SCSCaseNumber__c = 'Test1',
                 MethodofRepair__c = 'Changed Hyundai G80 Engine',
                 IncidentswithFires__c = '10'
         );
     }
 
     public static SObject makeCollection(Id caseId, String documentRelatedStage) {
 
         Id recordTypeIdDRC   = Schema.SObjectType.DRCDocument__c.getRecordTypeInfosByDeveloperName().get('CaseDocument').getRecordTypeId();
         Id recordTypeIdTRC   = Schema.SObjectType.TRCDocument__c.getRecordTypeInfosByDeveloperName().get('CaseDocument').getRecordTypeId();
         Id recordTypeIdNASDA = Schema.SObjectType.NASDADocument__c.getRecordTypeInfosByDeveloperName().get('CaseDocument').getRecordTypeId();
 
         if (documentRelatedStage.equalsIgnoreCase('DA')) {
             return new DADocuments__c(
                     Folder__c = 'Data',
                     Case__c = caseId
             );
         }
         if (documentRelatedStage.equalsIgnoreCase('DRC')) {
             return new DRCDocument__c(
                     RecordTypeId = recordTypeIdDRC,
                     Folder__c = 'Data',
                     Case__c = caseId
             );
         }
         if (documentRelatedStage.equalsIgnoreCase('TRC')) {
             return new TRCDocument__c(
                     Name = 'Test TRC Collection',
                     Folder__c = 'Data',
                     RecordTypeId = recordTypeIdTRC,
                     Case__c = caseId
             );
         }
 
         if (documentRelatedStage.equalsIgnoreCase('SIMS')) {
             return new SIMS_Document__c(
                     Name = 'Test SIMS Collection',
                     Folder__c = 'Response',
                     RecordTypeId = recordTypeIdNASDA,
                     Case__c = caseId
             );
         }
        // <QCMT>[SO-440] / InhoKim / 2024-09-19 : START
         if (documentRelatedStage.equalsIgnoreCase('Q-DRC')) {
             return new Q_DRC_Document__c(
                     Name = 'Test Q-DRC Collection',
                     Folder__c = 'Data',
                     Case__c = caseId
             );
         }
         if (documentRelatedStage.equalsIgnoreCase('Q-TRC')) {
             return new Q_TRC_Document__c(
                     Name = 'Test Q-TRC Collection',
                     Folder__c = 'Data',
                     Case__c = caseId
             );
         }
         if (documentRelatedStage.equalsIgnoreCase('SCDC')) {
             return new SCDC_Document__c(
                     Name = 'Test SCDC Collection',
                     Folder__c = 'Other',
                     Case__c = caseId
             );
         }
         // <QCMT>[SO-440] / InhoKim / 2024-09-19 : END
         // <QCMT>[SO-469] / InhoKim / 2024-09-28 : START
         if (documentRelatedStage.equalsIgnoreCase('Q-DA')) {
            return new DADocuments__c(
                    Folder__c = 'Other',
                    Case__c = caseId
            );
        }
         // <QCMT>[SO-469] / InhoKim / 2024-09-28 : END
         return new NASDADocument__c(
                 Name = 'Test NASDA Collection',
                 Folder__c = 'Other',
                 Case__c = caseId
         );
     }
 
     public static ContentVersion makeContentVersion(Id collectionId) {
         Blob bodyBlob = Blob.valueOf('Test Content');
 
         return new ContentVersion(
                 Title = 'Sample Document',
                 PathOnClient = 'document.jpg',
                 VersionData = bodyBlob,
                 Origin = 'H',
                 FirstPublishLocationId = collectionId
         );
     }
 
     public static ContentDocumentLink makeContentDocumentLink(Id documentId, Id collectionId){
         return new ContentDocumentLink(
                 ContentDocumentId = documentId,
                 LinkedEntityId = collectionId
         );
     }
 
     public static User makeUser() {
         Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
         return new User(
                 Alias = 'tUse9981',
                 Email = 'tuser9981@sfhyundai.com',
                 EmailEncodingKey = 'UTF-8',
                 LastName = 'Testing',
                 LanguageLocaleKey = 'en_US',
                 LocaleSidKey = 'en_US',
                 ProfileId = p.Id,
                 TimeZoneSidKey = 'America/New_York',
                 Username = 'tuser9981@sfhyundai.com'
         );
     }
 
     public static User makeSaftyUser() {
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
 
     // <RRP Project> - Oh, janghun 2024-05-11 : Start
     public static RRP__c makeRRP() {
         return new RRP__c(
                 Name = 'testRRP'
         );
     }
 
     public static SObject makeRRPDocCollection(Id RRPId) {
         return new RRPDocument__c(
                 RRP__c = RRPId,
                 Folder__c = 'Data',
                 Name = 'RRP Test'
         );
     }
 
     public static SObject makeRRPValidDocCollection(Id RRPId) {
         return new RRPValidationDocument__c(
                 RRP__c = RRPId,
                 Folder__c = 'Data',
                 Name = 'RRP Test'
         );
     }
 
     public static SObject makeISQDocCollection(Id RRPId) {
         return new ISEQCDocument__c(
                 RRP__c = RRPId,
                 Folder__c = 'Data',
                 Name = 'RRP Test'
         );
     }
     // <RRP Project> - Oh, janghun 2024-05-11 : End
     // <STIL Project> - San, Kang 2024-06-19 : Start
     public static User makeSTILUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'STIL User'];
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

     public static WorkOrder makeLR() {
         return new WorkOrder(
                 Status = 'New',
                 Subject = 'Test'         
         );
     }

     public static SObject makeSTILReqSecureCol(Id LRId) {
        return new STIL_Lab_Request_Secure_Document__c(
                Lab_Request__c = LRId,
                Folder__c = 'Others',
                Name = 'LR Test'
        );
    }

    public static SObject makeSTILReportCol(Id LRId) {
        return new STIL_Report_Document__c(
                Lab_Request__c = LRId,
                Folder__c = 'Other',
                Name = 'LR Test'
        );
    }

    public static SObject makeSTILRequestCol(Id LRId) {
        return new STIL_Request_Document__c(
                Lab_Request__c = LRId,
                Folder__c = 'Other',
                Name = 'LR Test'
        );
    }

    public static SObject makeSTILTestCol(Id LRId) {
        return new STIL_Test_Document__c(
                Lab_Request__c = LRId,
                Folder__c = 'Other',
                Name = 'LR Test'
        );
    }
     // <STIL Project> - San, Kang 2024-06-19 : End
 }