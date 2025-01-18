/**
************************************************************************************************
* @classname         : HCUV_CarosuelConfigControllerTest; being used for Code Coverage
* @description       : Test Class for HCUV_CarosuelConfigController
* @author            : Smriti Gupta
* Comments			 : Since we are using criteria based sharing rules, we'll not have test cases specific 
*					   to the external user or internal user. 
*					   Link:  https://help.salesforce.com/s/articleView?id=sf.security_sharing_rule_types.htm&type=5
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       29th Aug 2023          Smriti Gupta         Story HVM-218     Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_CarosuelConfigControllerTest{
     /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void testData(){
        List<HCUV_Carousel__c> cuvList = new List<HCUV_Carousel__c>();
        String hmaRecTypeId = Schema.SObjectType.HCUV_Carousel__c.getRecordTypeInfosByDeveloperName().get('Hyundai').getRecordTypeId();
        String gmaRecTypeId = Schema.SObjectType.HCUV_Carousel__c.getRecordTypeInfosByDeveloperName().get('Genesis').getRecordTypeId();

        cuvList.add(new HCUV_Carousel__c(Active__c = true,IsOpen_InSeperateTab__c = true,Mobile_View__c = true,Start_Date__c = System.today().addDays(-4),Program_Name__c = 'HYUNDAI CERTIFIED USED VEHICLES',Expiration_Date__c = System.today().addDays(4), recordTypeId=hmaRecTypeId));
        cuvList.add(new HCUV_Carousel__c(Active__c = true,IsOpen_InSeperateTab__c = true,Mobile_View__c = false,Start_Date__c = System.today().addDays(-4),Program_Name__c = 'GENESIS CERTIFIED VEHICLES',Expiration_Date__c = System.today().addDays(4), recordTypeId=gmaRecTypeId));
        insert cuvList;  
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        List<ContentDocumentLink> doclinkList = new List<ContentDocumentLink>();
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = cuvList[0].Id;
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        cdl.shareType = 'I';
        cdl.Visibility = 'AllUsers'; 
        doclinkList.add(cdl);
        
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = cuvList[1].Id;
        cdl1.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        cdl1.shareType = 'I';
        cdl1.Visibility = 'AllUsers'; 
        doclinkList.add(cdl1);
        
        Insert doclinkList;     
        
    }
    /**
    * @description - Checking the HMA carousel data
    * 
    */
    @isTest static void testHMACarouselConfigInfo() {
        Test.StartTest();
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.HMA_COMMUNITY_NAME];
            Map<String,HCUV_CarosuelConfigController.DesktopCarouselWrapper> mapVal = new Map<String,HCUV_CarosuelConfigController.DesktopCarouselWrapper>();
            mapVal = HCUV_CarosuelConfigController.fetchCarouselConfigInfo('CUV',netObjList[0].Id);
            system.assert(!mapVal.isEmpty(), 'checking size');
            String res = HCUV_CarosuelConfigController.getLatestModifiedImageInfo();
            system.assert(String.isNotblank(res), 'checking return value');
        Test.StopTest();
    }   
    
    /**
    * @description - Checking the GMA carousel data
    * 
    */
    @isTest static void testGMACarouselConfigInfo() {
        Test.StartTest();
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.GMA_COMMUNITY_NAME];
        Map<String,HCUV_CarosuelConfigController.DesktopCarouselWrapper> mapValue = new Map<String,HCUV_CarosuelConfigController.DesktopCarouselWrapper>();
        mapValue = HCUV_CarosuelConfigController.fetchCarouselConfigInfo('CPO',netObjList[0].Id);
        system.assert(!mapValue.isEmpty(), 'checking size');
        String res = HCUV_CarosuelConfigController.getLatestModifiedImageInfo();
        system.assert(String.isNotblank(res), 'checking return value');
        Test.StopTest();
    }   
}