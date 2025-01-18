@IsTest
public class DNAMSPIRQuestionsFormTest {
    
    
    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(Name = 'AK003 - LITHIA HYUNDAI OF ANCHORAGE',DealerCode__c = '12345');
        insert testAccount;
        
        List<PIR_Questions__c> questions = new List<PIR_Questions__c>();
      
         questions.add(new PIR_Questions__c(
            Section__c = 'Current Dealer Information',
            Question__c = 'Reason that dealer is selling',
            Type__c = 'Text',
            PIR_Type__c = 'Buy/Sell',
            Is_Readonly__c = false,
            Is_Required__c = true,
            Sequence__c = 1
        ));

         questions.add(new PIR_Questions__c(
            Section__c = 'Parties to APA',
            Question__c = 'How was APA received?',
            Type__c = 'Text',
            PIR_Type__c = 'Buy/Sell',
            Is_Readonly__c = false,
            Is_Required__c = true,
            Sequence__c = 2
        ));
       
        questions.add(new PIR_Questions__c(
            Section__c = 'Current Dealer Information',
            Question__c = 'Is APA fully executed?',
            Type__c = 'Picklist',
            PIR_Type__c = 'Buy/Sell',
            Options__c = 'Yes, No',
            Is_Readonly__c = false,
            Is_Required__c = true,
            Sequence__c = 3
        ));
      
         questions.add(new PIR_Questions__c(
            Section__c = 'Purchaser Information',
            Question__c = 'Hyundai Current Ownership Structure',
            Type__c = 'Text Area',
            PIR_Type__c = 'Ownership/Management Changes',
            Is_Readonly__c = false,
            Is_Required__c = false,
            Sequence__c = 4
        ));
               
        questions.add(new PIR_Questions__c(
            Section__c = 'Current Dealer Information',
            Question__c = 'Date APA received',
            Type__c = 'Date',
            PIR_Type__c = 'Buy/Sell',
            Is_Readonly__c = false,
            Is_Required__c = true,
            Sequence__c = 5
        ));
        insert questions;
        
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
    }
    
    @IsTest
    static void testGetSections(){
        Account acc =[SELECT Id,DealerCode__c FROM Account LIMIT 1];
        List<String> PIRTypesList = new List<String>{'Buy/Sell','Ownership/Management Changes'};
        Test.startTest();
        List<DNAMSPIRQuestionsForm.SectionData> sections = DNAMSPIRQuestionsForm.getSections(acc.Id, PIRTypesList);
        DNAMSPIRQuestionsForm.PIRTypeData asd = DNAMSPIRQuestionsForm.getPIRTypes(acc.Id);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testGetQuestions() {
       Account acc = [SELECT Id FROM Account LIMIT 1];
       List<String> PIRTypesList = new List<String>{'Buy/Sell','Ownership/Management Changes'};
           
       Test.startTest();
       List<DNAMSPIRQuestionsForm.QuestionData> questions = DNAMSPIRQuestionsForm.getQuestions(acc.Id, PIRTypesList);
       Test.stopTest();
        
    }
    
    
    
    @IsTest
    static void testSaveResponses() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Provision__c> provisionRecords = [SELECT Provision_Description__c, Effective_From_Date__c, Effective_To_Date__c 
                                               FROM Provision__c 
                                               WHERE Dealer__c = :acc.Id 
                                               AND Provision_Type__c = '*****' 
                                               ORDER BY Effective_From_Date__c DESC  
                                               LIMIT 1];
        List<PIR_Questions__c> questions = [SELECT Id FROM PIR_Questions__c];
        
        System.debug('Questions Recieved: '+questions);
        System.debug('Number of questions retrieved: ' + questions.size());
        
        String responses = '{"' + questions[0].Id + '": "test response 1", "'
            + questions[1].Id + '": "test response 2", "'
            + questions[2].Id + '": "Yes", "'
            + questions[3].Id + '": "10-2-1990", "'
            + questions[4].Id + '": "testing"}';
        
        List<String> pirTypes = new List<String>{'Buy/Sell','Ownership/Management Changes'};
            
        Test.startTest();
        String pirRecordId = DNAMSPIRQuestionsForm.saveResponses(acc.Id, JSON.serialize(pirTypes), responses);
        Test.stopTest();
        Package_Initiation__c pirRecord = [SELECT Id, Dealer_Name__c FROM Package_Initiation__c WHERE Id = :pirRecordId LIMIT 1];
        
    }
    
    @IsTest
    static void testSaveResponsesWithError() {
         Account acc = [SELECT Id FROM Account LIMIT 1];
        
        
        List<PIR_Questions__c> questions = new List<PIR_Questions__c>();
        String responses = '{"INVALID_QUESTION_ID": "test response"}'; 
        List<String> pirTypes = new List<String>{'Buy/Sell', 'Ownership/Management Changes'};
        Test.startTest();
        
        try {
          String pirRecordId = DNAMSPIRQuestionsForm.saveResponses(acc.Id, JSON.serialize(pirTypes), responses);
        } 
        catch (Exception e) {
           System.debug('Error caught: ' + e.getMessage());
        }
        
        Test.stopTest();
       
    }
    
}