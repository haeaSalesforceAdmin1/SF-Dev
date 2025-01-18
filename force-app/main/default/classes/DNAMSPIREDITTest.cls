@IsTest
public class DNAMSPIREDITTest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'AK003 - LITHIA HYUNDAI OF ANCHORAGE');
        insert testAccount;
        
        Package_Initiation__c pir = new Package_Initiation__c(Dealer_Name__c = testAccount.Id, Name = 'test', PIR_Status__c = 'Draft', PIR_Type__c = 'Buy/Sell');
        insert pir;
        
        Provision__c p = new Provision__c();
        p.Dealer__c = testAccount.Id;
        p.Effective_To__c = String.valueOf(system.today() + 10);
        p.Effective_From_Date__c = system.today() - 10;
        p.Agreement_Term__c = '234';
        p.Provision_Description__c = 'No';
        //p.Provision_Type__c = 'No';
        p.Provision_Type__c ='*****';
        insert p;
        
        Address__c a = new Address__c();
        a.Address_Name__c = 'test';
        a.Contact_Type__c = '9';
        a.Dealer__c = testAccount.Id;
        insert a;
        
        // Create test PIR_Questions__c records
        List<PIR_Questions__c> question = new List<PIR_Questions__c>();
        
        question.add(new PIR_Questions__c(
            Section__c = 'Parties to APA',
            Question__c = 'How was APA received?',
            Type__c = 'Text',
            PIR_Type__c = 'Buy/Sell',
            Is_Readonly__c = false,
            Is_Required__c = true,
            Sequence__c = 1
        ));
        
        question.add(new PIR_Questions__c(
            Section__c = 'Current Dealer Information',
            Question__c = 'Is APA fully executed?',
            Type__c = 'Picklist',
            PIR_Type__c = 'Buy/Sell',
            Options__c = 'Yes, No',
            Is_Readonly__c = false,
            Is_Required__c = true,
            Sequence__c = 2
        ));
        
        question.add(new PIR_Questions__c(
            Section__c = 'Purchaser Information',
            Question__c = 'Hyundai Current Ownership Structure',
            Type__c = 'Text Area',
            PIR_Type__c = 'Ownership/Management Changes',
            Is_Readonly__c = false,
            Is_Required__c = false,
            Sequence__c = 3
        ));
        question.add(new PIR_Questions__c(
            Section__c = 'Current Dealer Information',
            Question__c = 'Date APA received',
            Type__c = 'Date',
            PIR_Type__c = 'Buy/Sell',
            Is_Readonly__c = false,
            Is_Required__c = true,
            Sequence__c = 4
        ));
        
        insert question;
        List<PIR_Questions__c> questions = [  SELECT Section__c, Question__c, PIR_Type__c, Sequence__c  FROM PIR_Questions__c ORDER BY Sequence__c];
        System.debug('Questions Retrieved: ' + questions);
        
        PIR_Element__c element1 = new PIR_Element__c(PIR__c = pir.Id, Name = 'PIR Element 1');
        PIR_Element__c element2 = new PIR_Element__c(PIR__c = pir.Id, Name = 'PIR Element 2');
        
        insert new List<PIR_Element__c>{element1, element2};
            
            }
    @isTest
    static void testGetSections() {
        
        setupTestData();
        Account acc =[SELECT Id FROM Account LIMIT 1];
        List<String> pirTypes = new List<String>{'Buy/Sell','Ownership/Management Changes'};
            Package_Initiation__c pir = [SELECT Id FROM Package_Initiation__c LIMIT 1];
        
        Test.startTest();
        List<DNAMSPIR_EDIT.SectionData> result = DNAMSPIR_EDIT.getSections(pir.Id, pirTypes);
        DNAMSPIR_EDIT.PIRTypeData asd = DNAMSPIR_EDIT.getPIRTypes(acc.Id);
        Test.stopTest();
        
        DNAMSPIR_EDIT.SectionData section1 = result[0];
        DNAMSPIR_EDIT.QuestionData qnData1 = section1.QuesData[0];
        DNAMSPIR_EDIT.SectionData section2 = result[1];
        DNAMSPIR_EDIT.QuestionData qnData2 = section2.QuesData[0];
        DNAMSPIR_EDIT.SectionData section3 = result[2];
        DNAMSPIR_EDIT.QuestionData qnData4 = section3.QuesData[0];
        
    }
    @isTest
    static void testGetQuestions() {
        setupTestData();
        Package_Initiation__c pir = [SELECT Id FROM Package_Initiation__c LIMIT 1];
        List<String> pirTypes = new List<String>{'Buy/Sell', 'Ownership/Management Changes'};
            
            Test.startTest();
        List<DNAMSPIR_EDIT.QuestionData> questions = DNAMSPIR_EDIT.getQuestions(pir.Id, pirTypes);
        Test.stopTest();
        
        DNAMSPIR_EDIT.QuestionData qnData1 = questions[0];
        DNAMSPIR_EDIT.QuestionData qnData2 = questions[1];
        DNAMSPIR_EDIT.QuestionData qnData3 = questions[2];
        DNAMSPIR_EDIT.QuestionData qnData4 = questions[3];
        
    }
    @IsTest
    static void testSaveResponses() {
        
        setupTestData();
        
        Package_Initiation__c pir = [SELECT Id,PIR_Type__c  FROM Package_Initiation__c LIMIT 1];
        
        PIR_Questions__c question1 = [SELECT Id FROM PIR_Questions__c WHERE Question__c = 'How was APA received?' LIMIT 1];
        PIR_Questions__c question2 = [SELECT Id FROM PIR_Questions__c WHERE Question__c = 'Is APA fully executed?' LIMIT 1];
        PIR_Questions__c question3 = [SELECT Id FROM PIR_Questions__c WHERE Question__c = 'Hyundai Current Ownership Structure' LIMIT 1];
        
        
        String PIRID = pir.Id;
        String pirTypes = '["Buy/Sell","Ownership/Management Changes"]';
        String responses = '{ "' + question1.Id + '": "New response for question 1", "' + question2.Id + '": "No", "' + question3.Id + '": "Updated response for question 3" }'; 
        
        PIR_Element__c element1 = new PIR_Element__c(PIR__c = pir.Id, Name = 'PIR Element 1');
        PIR_Element__c element2 = new PIR_Element__c(PIR__c = pir.Id, Name = 'PIR Element 1');
        PIR_Element__c element3 = new PIR_Element__c(PIR__c = pir.Id, Name = 'PIR Element 2');
        insert new List<PIR_Element__c>{element1, element2,element3};
            
        Test.startTest();
        String recid = [select id from RecordType where SobjectType = 'Package_Initiation__c' and DeveloperName ='PIR_Docs_and_Approval_Template' Limit 1].Id;
        Package_Initiation__c pirtemplate = new Package_Initiation__c(Name = 'test', PIR_Type__c = 'Ownership/Management Changes',RecordTypeId = recid );
        insert pirtemplate;
        PIR_Element__c temelement1 = new PIR_Element__c(PIR__c = pirtemplate.Id, Name = 'PIR Element 3');
        PIR_Element__c temelement2 = new PIR_Element__c(PIR__c = pirtemplate.Id, Name = 'PIR Element 4');
        insert new List<PIR_Element__c>{temelement1, temelement2};
            
        String result = DNAMSPIR_EDIT.saveResponses(PIRID, pirTypes, responses);
        
        Test.stopTest();
        
        List<PIR_Element__c> remainingElements = [SELECT Id, Name FROM PIR_Element__c WHERE PIR__c = :PIRID];
        List<PIR_Element__c> deletedElements = [SELECT Id FROM PIR_Element__c WHERE Id = :element2.Id];
        List<PIR_Element__c> newElements = [SELECT Id, Name FROM PIR_Element__c WHERE PIR__c = :PIRID];
        
        List<PIRQnResponse__c> insertedResponses = [SELECT Id/*, Response__c*/,PIR_Question__c FROM PIRQnResponse__c WHERE Package_Initiation_Request__c = :PIRID];
        Map<Id, String> responseMap = new Map<Id, String>();
        List<PIRQnResponse__c> oldResponses = [SELECT Id FROM PIRQnResponse__c WHERE Package_Initiation_Request__c = :PIRID];
        List<PIR_Element__c> elements = [SELECT Id FROM PIR_Element__c WHERE PIR__c = :PIRID];
    }
    
    @IsTest
    static void testSaveResponses_error() {
        setupTestData();
        Package_Initiation__c pir = [SELECT Id,PIR_Type__c  FROM Package_Initiation__c LIMIT 1];
       
        String PIRID = pir.Id;
        String pirTypes = '["Buy/Sell","Ownership/Management Changes"]';
        String responses = '{ "' + 'invalidQuestionId' + '": "Invalid response" }';
        
      
        PIR_Element__c element1 = new PIR_Element__c(PIR__c = pir.Id, Name = 'PIR Element 1');
        PIR_Element__c element2 = new PIR_Element__c(PIR__c = pir.Id, Name = 'PIR Element 1');
        PIR_Element__c element3 = new PIR_Element__c(PIR__c = pir.Id, Name = 'PIR Element 2');
        insert new List<PIR_Element__c>{element1, element2,element3};
            
        Test.startTest();
        try{
        String recid = [select id from RecordType where SobjectType = 'Package_Initiation__c' and DeveloperName ='PIR_Docs_and_Approval_Template' Limit 1].Id;
        Package_Initiation__c pirtemplate = new Package_Initiation__c(Name = 'test', PIR_Type__c = 'Ownership/Management Changes',RecordTypeId = recid );
        insert pirtemplate;
        PIR_Element__c temelement1 = new PIR_Element__c(PIR__c = pirtemplate.Id, Name = 'PIR Element 3');
        PIR_Element__c temelement2 = new PIR_Element__c(PIR__c = pirtemplate.Id, Name = 'PIR Element 4');
        insert new List<PIR_Element__c>{temelement1, temelement2};
            
        String result = DNAMSPIR_EDIT.saveResponses(PIRID, pirTypes, responses);
        }
        catch(Exception e){ 
            System.debug('Error caught: ' + e.getMessage());
        }
         Test.stopTest();
    }
    
    
    
    
    @isTest
    static void testGetPIRType() {
        Test.startTest();
        List<String> result = DNAMSPIR_EDIT.getPIRType();
        Test.stopTest();
    }
    
    
    @isTest
    static void testGetSelectedPIRType() {
        setupTestData();
        Package_Initiation__c pir = [SELECT Id, PIR_Type__c FROM Package_Initiation__c LIMIT 1];
        pir.PIR_Type__c = 'Buy/Sell;Ownership/Management Changes';
        update pir;
        
        Test.startTest();
        List<String> result = DNAMSPIR_EDIT.getSelectedPIRType(pir.Id);
        Test.stopTest();
        
    }
}