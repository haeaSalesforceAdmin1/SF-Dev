/* [Component Description] Test class for EvaluationDpmrController
* Created by [Jonghoon Kim] on [2024-08-03] for [DPM-5663]
*/
@isTest
public with sharing class EvaluationDpmrControllerTest {
    @isTest
    static void testSaveEvaluation() {
        // Set up test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        List<RecordType> recordTypes = [SELECT Id, Name, DeveloperName FROM RecordType 
                                        WHERE SObjectType = 'evaluation__c' 
                                        AND DeveloperName LIKE '%DPMR%' 
                                        ORDER BY DeveloperName DESC];
        
        // Prepare parameters
        Map<String, Object> params = new Map<String, Object>();
        params.put('selectedTopics', 'HCUV');
        params.put('accountId', testAccount.Id);
        params.put('recordTypeId', recordTypes[0].Id); // Use an existing RecordTypeId
        params.put('evalStatus', 'Open');
        params.put('evaluationName', 'Test Evaluation');
        params.put('primaryContactId', null);
        params.put('primaryContactName', 'John Doe');
        params.put('primaryContactRole', 'Manager');
        params.put('division', 'Sales');
        params.put('selectedContactType', 'On-Site');
        params.put('contactDate', '');
        params.put('comment', 'Test Comment');
        
        // Test method
        Test.startTest();
        EvaluationDpmrController.saveEvaluation(params);
        Test.stopTest();
        
        // Verify results
        // Evaluation__c evaluation = [SELECT Id, Name, Account__c FROM Evaluation__c WHERE Id = :evaluationId LIMIT 1];
    //     System.assertNotEquals(null, evaluation, 'The Evaluation__c record should be created.');
    //     System.assertEquals('Test Evaluation', evaluation.Name, 'The evaluation name should match.');
    //     System.assertEquals(testAccount.Id, evaluation.Account__c, 'The account ID should match.');
    }

    @isTest
    static void testGetContactOptions() {
        // Set up test data
        Account acct = new Account(Name = 'Test Account', DealerCode__c='CA349');
        insert acct;

        List<Contact> conList = new List<Contact>();
        Contact con =new Contact(AccountId = acct.id,
                LastName = 'testdata',
                FirstName ='testdata1',
                email='test11@gmail.com',
                Active_DPM_User__c = true,
                DNAMS_Active_User__c = false,
                JobCode__c='DB');
        Contact con2 =new Contact(AccountId = acct.id,
                LastName = 'testdata2',
                FirstName ='testdata2',
                email='test12@gmail.com',
                Active_DPM_User__c = true,
                DNAMS_Active_User__c = false,
                JobCode__c='DB');
        conList.add(con);
        conList.add(con2);
        insert conList;

       List<AccountContactRelation> acr = [SELECT Id, AccountId, ContactId, JobCode__c FROM AccountContactRelation WHERE AccountId=:acct.Id];
        
        // Test method
        Test.startTest();
        EvaluationDpmrController.getContactOptions(acct.Id);
        EvaluationDpmrController.getSecondaryContactOptions(acct.Id, acr[0].ContactId);
        Test.stopTest();
        
    }


    @isTest
    static void testSaveImgFile() {
        // Prepare parameters
        String fileName = 'TestImage.png';
        String fileType = 'image/png';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test Image Content'));
        
        // Test method
        Test.startTest();
        EvaluationDpmrController.saveImgFile(fileName, fileType, base64Data);
        Test.stopTest();
        
        // Verify results
        ContentVersion contentVersion = [SELECT Id, Title FROM ContentVersion WHERE Title = :fileName LIMIT 1];
        System.assertNotEquals(null, contentVersion, 'The ContentVersion record should be created.');
        System.assertEquals(fileName, contentVersion.Title, 'The file name should match.');
    }

    @isTest
    static void testUploadFile() {
        // Set up test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        String fileName = 'TestFile.pdf';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        String contentType = 'application/pdf';
        
        // Test method
        Test.startTest();
        EvaluationDpmrController.uploadFile(testAccount.Id, fileName, base64Data, contentType);
        Test.stopTest();
        
        // Verify results
        ContentDocumentLink cdl = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :testAccount.Id LIMIT 1];
        System.assertNotEquals(null, cdl, 'The ContentDocumentLink should be created.');
        ContentVersion cv = [SELECT Id, Title FROM ContentVersion WHERE Title = :fileName LIMIT 1];
        System.assertNotEquals(null, cv, 'The ContentVersion record should be created.');
    }
    
    @isTest
    static void testGetAccountName() {
        // Set up test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Test method
        Test.startTest();
        String accountName = EvaluationDpmrController.getAccountName(testAccount.Id);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(testAccount.Name, accountName, 'The account name should match.');
    }
    
      @isTest
    static void testGetRecordType() {
        // Set up test data
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Evaluation__c' AND DeveloperName LIKE '%DPMR%' LIMIT 1];

        // Test method
        Test.startTest();
        String recordTypeId = EvaluationDpmrController.getRecordType(rt.DeveloperName);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(rt.Id, recordTypeId, 'The RecordType Id should match.');
    }

   @isTest
    static void testCreateEvalName() {
        // Set up test data
        Account testAccount = new Account(Name = 'Test Account', DealerCode__c = 'CA349');
        insert testAccount;
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Evaluation__c' AND DeveloperName LIKE '%DPMR%' LIMIT 1];
        
        Date testDate = Date.today();
        String testDivision = 'Sales';
        String testDivision2 = 'Service';
        String testTopic = 'HCUV';

        // Insert existing Evaluation__c records to check max number logic
        Evaluation__c eval1 = new Evaluation__c(
            Name = 'CA349 - Sales DPMR - Aug 1, 2024 - 1',
            PrimaryContactDate__c = testDate,
            Account__c =testAccount.Id,
            recordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Evaluation__c', 'DPMR_Sales_Dealer_Performance_Management_Report_Internal_Confidential'),
			Type__c ='Sales'        	
        );
        insert eval1;

        Evaluation__c eval2 = new Evaluation__c(
            Name = 'CA349 - Sales DPMR - Aug 1, 2024 - 3',
            PrimaryContactDate__c = testDate,
            Account__c =testAccount.Id,
            recordTypeId = TestUtility.getRecordTypeIdForSObjectDeveloperName('Evaluation__c', 'DPMR_Sales_Dealer_Performance_Management_Report_Internal_Confidential'),
            Type__c ='Sales' 
            
        );
        insert eval2;
        
        
        
        // Test method
        Test.startTest();
        String evalName = EvaluationDpmrController.createEvalName(testAccount.Id, testDate, testDivision, testTopic);
        EvaluationDpmrController.createEvalName(testAccount.Id, testDate, testDivision2, testTopic);
        EvaluationDpmrController.getRelatedFiles(eval1.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateEvalName1() {
        // Set up test data
        Account testAccount = new Account(Name = 'Test Account', DealerCode__c = 'CA349');
        insert testAccount;
        
        Date testDate = Date.today();
        String testDivision = 'Sales';
        String testTopic = 'Financial Performance';

        // Insert existing Evaluation__c records to check max number logic
        Evaluation__c eval1 = new Evaluation__c(
            Name = 'CA349 - Sales DPMR - Aug 1, 2024 - 1'
        );
        insert eval1;

        Evaluation__c eval2 = new Evaluation__c(
            Name = 'CA349 - Sales DPMR - Aug 1, 2024 - 3'
        );
        insert eval2;

        // Test method
        Test.startTest();
        String evalName = EvaluationDpmrController.createEvalName(testAccount.Id, testDate, testDivision, testTopic);
        Test.stopTest();
        
    }
}