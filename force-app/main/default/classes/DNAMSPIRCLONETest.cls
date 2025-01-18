@IsTest
public class DNAMSPIRCLONETest {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'AK003 - LITHIA HYUNDAI OF ANCHORAGE');
        insert testAccount;
        
        Id pirrecid= [select Id,SobjectType from RecordType where DeveloperName = 'PIR_Docs_and_Approval_Template' and SobjectType = 'Package_Initiation__c' Limit 1].Id;
        Package_Initiation__c pir = new Package_Initiation__c(Dealer_Name__c = testAccount.Id, Name = 'test', PIR_Status__c = 'Draft', RecordTypeId = pirrecid);
        insert pir;
        
        Provision__c p = new Provision__c();
        //p.Name = 'test Provision__c';
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
        
        List<PIR_Questions__c> questions = [SELECT Section__c, Question__c, PIR_Type__c, Sequence__c FROM PIR_Questions__c ORDER BY Sequence__c];
        System.debug('Questions Retrieved: ' + questions);
        
        List<PIRQnResponse__c> responses = new List<PIRQnResponse__c>{
            new PIRQnResponse__c(Package_Initiation_Request__c = pir.Id, PIR_Question__c = questions[0].Id, Response__c = 'Test response 1'),
                new PIRQnResponse__c(Package_Initiation_Request__c = pir.Id, PIR_Question__c = questions[1].Id, Response__c = 'Yes'),
                new PIRQnResponse__c(Package_Initiation_Request__c = pir.Id, PIR_Question__c = questions[2].Id, Response__c = 'Test response 2'),
                new PIRQnResponse__c(Package_Initiation_Request__c = pir.Id, PIR_Question__c = questions[3].Id, Response__c = '2024-11-01')
                };
                    
        PIR_Element__c element1 = new PIR_Element__c(PIR__c = pir.Id, Name = 'Comprehensive Deck/ Miscellaneous');
        insert element1;  
        System.debug('element inserted :'+element1.id);
    }
    @isTest
    static void testGetSections() {
        
        setupTestData();
        Account acc =[SELECT Id FROM Account LIMIT 1];
        List<String> pirTypes = new List<String>{'Buy/Sell','Ownership/Management Changes'};
        Package_Initiation__c pir = [SELECT Id FROM Package_Initiation__c LIMIT 1];
        
        Test.startTest();
        List<DNAMSPIR_CLONE.SectionData> result = DNAMSPIR_CLONE.getSections(pir.Id, pirTypes);
        DNAMSPIR_CLONE.PIRTypeData asd = DNAMSPIR_CLONE.getPIRTypes(acc.Id);
        Test.stopTest();
        
        DNAMSPIR_CLONE.SectionData section1 = result[0];
        DNAMSPIR_CLONE.QuestionData qnData1 = section1.QuesData[0];
        DNAMSPIR_CLONE.SectionData section2 = result[1];
        DNAMSPIR_CLONE.QuestionData qnData2 = section2.QuesData[0];
        DNAMSPIR_CLONE.SectionData section3 = result[2];
        DNAMSPIR_CLONE.QuestionData qnData4 = section3.QuesData[0];
        
    }
    @isTest
    static void testGetQuestions() {
        
        setupTestData();
        
        Package_Initiation__c pir = [SELECT Id FROM Package_Initiation__c LIMIT 1];
        List<String> pirTypes = new List<String>{'Buy/Sell','Ownership/Management Changes'};
            
        Test.startTest();
        List<DNAMSPIR_CLONE.QuestionData> questions = DNAMSPIR_CLONE.getQuestions(pir.Id, pirTypes);
        Test.stopTest();
        
        DNAMSPIR_CLONE.QuestionData qnData1 = questions[0];
        DNAMSPIR_CLONE.QuestionData qnData2 = questions[1];
        DNAMSPIR_CLONE.QuestionData qnData3 = questions[2];
        DNAMSPIR_CLONE.QuestionData qnData4 = questions[3];
        
    }
    @IsTest
    static void testSaveResponses() {
        
        setupTestData();
        
        Package_Initiation__c pir = [SELECT Id,PIR_Type__c  FROM Package_Initiation__c LIMIT 1];
        
        PIR_Questions__c question1 = [SELECT Id FROM PIR_Questions__c WHERE Question__c = 'How was APA received?' LIMIT 1];
        PIR_Questions__c question2 = [SELECT Id FROM PIR_Questions__c WHERE Question__c = 'Is APA fully executed?' LIMIT 1];
        PIR_Questions__c question3 = [SELECT Id FROM PIR_Questions__c WHERE Question__c = 'Hyundai Current Ownership Structure' LIMIT 1];
        
        Map<String,Object> resmap = new Map<String,Object>();
        resmap.put(question1.Id,'Test response 1');
        resmap.put(question2.Id,'Yes');
        resmap.put(question3.Id,'Test response 2');
        
        String responses = JSON.serialize(resmap); 
        String PIRID = pir.Id;
        String pirTypes = '["Buy/Sell", "Ownership/Management Changes"]';
        
        PIR_Element__c element1 = new PIR_Element__c(PIR__c = pir.Id, Name = '1.Comprehensive Deck/ Miscellaneous');
        insert element1;
        System.debug('element inserted1 :'+element1.id);
        
        System.debug('pir types :' +pirTypes);
        List<PIR_Element__c> elementConfigs = [SELECT Name, Instructions__c,Mapped_Package_Element__c FROM PIR_Element__c WHERE PIR__r.RecordType.DeveloperName  = 'PIR_Docs_and_Approval_Template' ];
        System.debug('elements for '  + ': ' + elementConfigs);
        
        Test.startTest(); 
        String result = DNAMSPIR_CLONE.saveResponses(PIRID, pirTypes, responses);
        Test.stopTest();
        
        List<PIR_Element__c> remainingElements = [SELECT Id, Name FROM PIR_Element__c WHERE PIR__c = :PIRID];
        List<PIR_Element__c> newElements = [SELECT Id, Name FROM PIR_Element__c WHERE PIR__c = :PIRID];
        
        List<PIRQnResponse__c> insertedResponses = [SELECT Id, Response__c,PIR_Question__c FROM PIRQnResponse__c WHERE Package_Initiation_Request__c = :PIRID];
        Map<Id, String> responseMap = new Map<Id, String>();
        for (PIRQnResponse__c response : insertedResponses) {
            responseMap.put(response.PIR_Question__c, response.Response__c);
        }
        
       List<PIRQnResponse__c> oldResponses = [SELECT Id FROM PIRQnResponse__c WHERE Package_Initiation_Request__c = :PIRID];
       List<PIR_Element__c> elements = [SELECT Id FROM PIR_Element__c WHERE PIR__c = :PIRID];
    }
    
     @IsTest
    static void testSaveResponses_error() {
        
        setupTestData();
        
        Package_Initiation__c pir = [SELECT Id,PIR_Type__c  FROM Package_Initiation__c LIMIT 1];
        
        PIR_Questions__c question1 = [SELECT Id FROM PIR_Questions__c WHERE Question__c = 'How was APA received?' LIMIT 1];
        PIR_Questions__c question2 = [SELECT Id FROM PIR_Questions__c WHERE Question__c = 'Is APA fully executed?' LIMIT 1];
        PIR_Questions__c question3 = [SELECT Id FROM PIR_Questions__c WHERE Question__c = 'Hyundai Current Ownership Structure' LIMIT 1];
        
        Map<String,Object> resmap = new Map<String,Object>();
        resmap.put(question1.Id,'Test response 1');
        resmap.put(question2.Id,'Yes');
        resmap.put('','Test response 2');
        
        String responses = JSON.serialize(resmap); 
        String PIRID = pir.Id;
        String pirTypes = '["Buy/Sell", "Ownership/Management Changes"]';
        
        PIR_Element__c element1 = new PIR_Element__c(PIR__c = pir.Id, Name = '1.Comprehensive Deck/ Miscellaneous');
        insert element1;
        System.debug('element inserted1 :'+element1.id);
        
        System.debug('pir types :' +pirTypes);
        List<PIR_Element__c> elementConfigs = [SELECT Name, Instructions__c,Mapped_Package_Element__c FROM PIR_Element__c WHERE PIR__r.RecordType.DeveloperName  = 'PIR_Docs_and_Approval_Template' ];
        System.debug('elements for '  + ': ' + elementConfigs);
        
        Test.startTest(); 
        String result = DNAMSPIR_CLONE.saveResponses(PIRID, pirTypes, responses);
        Test.stopTest();
        
        List<PIR_Element__c> remainingElements = [SELECT Id, Name FROM PIR_Element__c WHERE PIR__c = :PIRID];
        List<PIR_Element__c> newElements = [SELECT Id, Name FROM PIR_Element__c WHERE PIR__c = :PIRID];
        
        List<PIRQnResponse__c> insertedResponses = [SELECT Id, Response__c,PIR_Question__c FROM PIRQnResponse__c WHERE Package_Initiation_Request__c = :PIRID];
        Map<Id, String> responseMap = new Map<Id, String>();
        for (PIRQnResponse__c response : insertedResponses) {
            responseMap.put(response.PIR_Question__c, response.Response__c);
        }
        
       List<PIRQnResponse__c> oldResponses = [SELECT Id FROM PIRQnResponse__c WHERE Package_Initiation_Request__c = :PIRID];
       List<PIR_Element__c> elements = [SELECT Id FROM PIR_Element__c WHERE PIR__c = :PIRID];
    }
    
    // Test getPIRType method
    @isTest
    static void testGetPIRType() {
        Test.startTest();
        List<String> result = DNAMSPIR_CLONE.getPIRType();
        Test.stopTest();
    }
    
    // Test getSelectedPIRType method
    @isTest
    static void testGetSelectedPIRType() {
        setupTestData();
        Package_Initiation__c pir = [SELECT Id, PIR_Type__c FROM Package_Initiation__c LIMIT 1];
        pir.PIR_Type__c = 'Buy/Sell;Ownership/Management Changes';
        update pir;
        
        Test.startTest();
        List<String> result = DNAMSPIR_CLONE.getSelectedPIRType(pir.Id);
        Test.stopTest();
        
    }
}