@isTest
public without sharing class ContentDocumentLinkHelperTest {
    @TestSetup
    static void makeData(){
       CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;
    }
    static testMethod void handleContentDocumentLinkTest() {

        Account account = new Account(Name = 'Test Account');
        insert account;

        Action_Plan__c actionPlan = new Action_Plan__c(Account__c = account.Id);
        insert actionPlan;

        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
        insert cv;
        
        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
        

        ContentDocumentLink contentlink = new ContentDocumentLink(LinkedEntityId = actionPlan.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        insert contentlink;
        Test.startTest();
        update contentlink;
        Test.stopTest();
    }
  
    static testMethod void handleContentDocumentLinkTest2() {

        Account account = new Account(Name = 'Test Account');
        insert account;

        Action_Plan__c actionPlan = new Action_Plan__c(Account__c = account.Id);
        insert actionPlan;

        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
        insert cv;
        
        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
        
        ContentDocumentLinkTriggerHandler.run = false;
        ContentDocumentLink contentlink = new ContentDocumentLink(LinkedEntityId = actionPlan.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        insert contentlink;
        Test.startTest();
        update contentlink;

        delete contentlink;
        Test.stopTest();
    }

    static testMethod void handleContentDocumentLinkTest3() {

        Account account = new Account(Name = 'Test Account');
        insert account;

        Action_Plan__c actionPlan = new Action_Plan__c(Account__c = account.Id);
        insert actionPlan;

        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
        insert cv;
        
        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];
        
        ContentDocumentLink contentlink = new ContentDocumentLink(LinkedEntityId = actionPlan.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        insert contentlink;
        Test.startTest();
        update contentlink;

        delete contentlink;



        ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
        //handler.afterUndelete(null);
        Test.stopTest();
    }
    
    static User getIntegrationUser() {
        return [SELECT Id FROM User WHERE FirstName LIKE 'Integration%']?.get(0);
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
static testMethod void handleContentDocumentLinkTest4() {
        HMAReferenceData__c reference = makeReference();
        insert reference;
        Case c = new Case();
        c.Subject = 'Test Subject';
        c.Description = 'Test Description';
        c.CompanyName__c = 'HMA';
        c.CountrySubmitterWorks__c = 'Canada';
        c.SCSCaseRegion__c = 'North America';
        c.Haveyoupreviouslyreportedtheissues__c = 'No';
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('DA').getRecordTypeId();
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
        c.FirstReportSource__c= 'Common SEL';
        c.Engine__c='2.4L I4 GDI Theta II';
        c.Fuel_Type__c='Gas';
        c.VehicleModel__c='Santa Fe';
        c.Common_SEL_Report_Included__c=false;
        insert c;
    
        System.runAs(getIntegrationUser()) {       
        DADocuments__c da = new DADocuments__c();
        da.Name='Sample test data004';
        da.Case__c= c.Id;
        da.Folder__c= 'SIMS Common SEL Report';
        insert da;
  
        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion(FirstPublishLocationID = da.Id,title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
        insert cv;
  }
       
    }
}