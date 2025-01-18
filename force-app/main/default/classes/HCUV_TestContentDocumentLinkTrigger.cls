@isTest
public class HCUV_TestContentDocumentLinkTrigger {
	
    // create test data
    @testSetup static void setup() {
        HCUV_TestDataFactory.createReferenceMaterials(1);
        HCUV_TestDataFactory.createContentDocument(1);
    }
    
    @isTest 
    static void testInit() {
        
        Test.startTest();   
        List<HCUV_Reference_Material__c> rmObjList = [Select Id From HCUV_Reference_Material__c];
        List<ContentDocument> cdObjList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdlObj = New ContentDocumentLink();
        cdlObj.LinkedEntityId = rmObjList[0].Id;
        cdlObj.ContentDocumentId = cdObjList[0].Id;
        cdlObj.shareType = 'V';
        insert cdlObj;
            
        Test.stopTest();
    }
    
}