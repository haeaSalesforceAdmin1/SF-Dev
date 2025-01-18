/**
************************************************************************************************
* @classname         : HCUV_MessageControllerTest; being used for Code Coverage
* @description       : Test Class for HCUV_MessageController
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       23rd Aug 2023          Smriti Gupta         Story HVM-65       Initial Version
************************************************************************************************
**/
@isTest
public with sharing class HCUV_MessageControllerTest  {
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void testData(){
        
        Organization__c nationalOrg = new Organization__c(Name = 'National');
        insert nationalOrg;
        
        List<Organization__c> organizations = new List<Organization__c>();
        organizations.add(new Organization__c(Name = 'Hyundai', ParentOrganization__c = nationalOrg.Id));
        organizations.add(new Organization__c(Name = 'Genesis', BrandCode__c = 'G', ParentOrganization__c = nationalOrg.Id));
        insert organizations;
        
        List<Region__c> regions = new List<Region__c>();
        regions.add(new Region__c(Name = 'SOUTHERN REGION', Organization__c = organizations[0].Id, RegionCode__c = 'SO'));
        insert regions;
        
        List<District__c> district = new List<District__c>();
        district.add(new District__c(Name = 'KENTUCKY', Region__c = regions[0].Id, Organization__c = regions[0].Organization__c, DistrictCode__c = 'CE4', SalesManager__c = UserInfo.getUserId(), DistrictPartsServiceManager__c = UserInfo.getUserId()));
        
        insert district;
        
        //Get Account Record Type Id
        Id hynAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HyundaiDealer').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account', ServiceDistrict__c = district[0].Id, SalesDistrict__c = district[0].Id, Region__c = district[0].Region__c, Organization__c = district[0].Organization__c, DealerCode__c = 'A0001', Active__c = true, RecordTypeId = hynAccRecordTypeId);
        Insert account;
        
        List<Contact> lstcontact = new List<Contact>();
        lstcontact.add(new Contact(AccountId = account.Id, LastName = 'TestL', FirstName = 'TestF', Email='test2@email.com'));
        insert lstcontact;
        
        HCUV_TestDataFactory.createExternalUser(lstcontact[0].Id, 'Community_TestF', 'Community_TestL', HCUV_Constants.communityProfile);
        String hmaRecTypeId = Schema.SObjectType.HCUV_Dealer_Message__c.getRecordTypeInfosByDeveloperName().get('Dealer_Group').getRecordTypeId();
        String gmaRecTypeId = Schema.SObjectType.HCUV_Dealer_Message__c.getRecordTypeInfosByDeveloperName().get('Region').getRecordTypeId();
        
        List<HCUV_Dealer_Message__c> lstMessage = new List<HCUV_Dealer_Message__c>();
        HCUV_Dealer_Message__c hmaMessage = new HCUV_Dealer_Message__c();
        hmaMessage.Priority__c = 'High';
        hmaMessage.Start_Date__c = System.today();
        hmaMessage.Expiration_Date__c  = System.today().addDays(4);
        hmaMessage.Message_Type__c = 'Message Center';
        hmaMessage.Status__c = 'Published';
//        hmaMessage.District__c = 'CE4';
        hmaMessage.Program_Name__c = 'HYUNDAI CERTIFIED USED VEHICLES';
        hmaMessage.RecordTypeId = hmaRecTypeId;
        lstMessage.add(hmaMessage);
/*        
        HCUV_Dealer_Message__c gmaMessage = new HCUV_Dealer_Message__c();
        gmaMessage.Priority__c = 'High';
        gmaMessage.Start_Date__c = System.today();
        gmaMessage.Expiration_Date__c  = System.today().addDays(4);
        gmaMessage.Message_Type__c = 'Message Center';
        gmaMessage.Status__c = 'Published';
        gmaMessage.Program_Name__c = 'GENESIS CERTIFIED VEHICLES';
        gmaMessage.RecordTypeId = gmaRecTypeId;
        gmaMessage.District__c = 'CE4';
        lstMessage.add(gmaMessage);
*/        
        Insert lstMessage;
        
        HCUV_Message_Audience_Market__c msgAud = new HCUV_Message_Audience_Market__c();
        msgAud.Dealer_Message__c = hmaMessage.Id;
        msgAud.Market__c = district[0].Id;
        insert msgAud;
        
        List<ContentDocument> cdObjList = HCUV_TestDataFactory.createContentDocument(1);
        HCUV_TestDataFactory.createContentDocumentLinks(1, lstMessage[0].Id, cdObjList[0].Id);
    }
    
    /**
    * @description - Checking the HMA messages data
    * 
    */
    @isTest 
    static void testGetHMAMessages() {
        Test.startTest(); 
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.HMA_COMMUNITY_NAME];
        user user = [select Id from user where lastName = 'Community_TestL'];
        system.Runas(user){
            List<HCUV_Dealer_Message__c> hmaMessages= HCUV_MessageController.getMessages('CUV',netObjList[0].Id); 
            system.assert(hmaMessages.size()>0, 'Checking size');
        }
        Test.stopTest(); 
    }
    
    /**
    * @description - Checking the HMA quick tip data
    * 
    */
    @isTest 
    static void testGetHMAQuickTip() {
        Test.startTest(); 
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.HMA_COMMUNITY_NAME];
        user user = [select Id from user where lastName = 'Community_TestL'];
        system.Runas(user){
            Map<String, Object> mapresult= HCUV_MessageController.getQuickTip('CUV',netObjList[0].Id);
            system.assert(mapresult!=null, 'Checking null');
        }
        Test.stopTest(); 
        
    }
    
    /**
    * @description - Checking the GMA quick tip data
    * 
    */
    @isTest 
    static void testGetGMAQuickTip() {
        Test.startTest();
        Id gynAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GenesisRetailer').getRecordTypeId();
        Account accRec = [Select Id, RecordTypeId from Account limit 1];  
        accRec.RecordTypeId=gynAccRecordTypeId;
        update accRec;
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.GMA_COMMUNITY_NAME];
        user user = [select Id from user where lastName = 'Community_TestL'];
        system.Runas(user){
            Map<String, Object> mapresult= HCUV_MessageController.getQuickTip('CPO',netObjList[0].Id);
            system.assert(mapresult!=null, 'Checking null');
        } 
        Test.stopTest(); 
        
    }
    
    /**
    * @description - Checking the GMA messages data
    * 
    static void testGetGMAMessages() {
        Test.startTest(); 
        Id gynAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GenesisRetailer').getRecordTypeId();
        Account accRec = [Select Id, RecordTypeId from Account limit 1];  
        accRec.RecordTypeId=gynAccRecordTypeId;
        update accRec;
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.GMA_COMMUNITY_NAME];
        user user = [select Id from user where lastName = 'Community_TestL'];
        system.Runas(user){
            List<HCUV_Dealer_Message__c> gmaMessages= HCUV_MessageController.getMessages('CPO',netObjList[0].Id ); 
            system.assert(gmaMessages.size()>0, 'Checking null');
        }
        Test.stopTest(); 
    }
    */
    /**
    * @description - Checking the HMA messages data
    * 
    */
    @isTest 
    
    static void testHMAGetMessagesFilesInfo(){
        Test.startTest();
        user user = [select Id from user where lastName = 'Community_TestL'];
        HCUV_Dealer_Message__c msgRec = [Select Id From HCUV_Dealer_Message__c where Program_Name__c = 'HYUNDAI CERTIFIED USED VEHICLES'];
        system.Runas(user){
            system.assert(HCUV_MessageController.getMessagesFilesInfo(msgRec.Id )!=null, 'Checking not null');
        }
        Test.stopTest(); 
    }
    
    /**
    * @description - Checking the GMA messages data
    * 
    @isTest 
    static void testGMAGetMessagesFilesInfo(){
        Test.startTest();
        user user = [select Id from user where lastName = 'Community_TestL'];
        HCUV_Dealer_Message__c msgRec = [Select Id From HCUV_Dealer_Message__c where Program_Name__c = 'GENESIS CERTIFIED VEHICLES'];
        system.Runas(user){
            system.assert(HCUV_MessageController.getMessagesFilesInfo(msgRec.Id )!=null, 'Checking not null');
        }
        Test.stopTest(); 
    }
    */
}