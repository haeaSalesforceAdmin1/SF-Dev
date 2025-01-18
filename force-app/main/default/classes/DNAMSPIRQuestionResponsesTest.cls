@isTest(SeeAllData=true) 

public class DNAMSPIRQuestionResponsesTest {

    @isTest
    static void testGetPIRResponses() {
        
        Package_Initiation__c pir = new Package_Initiation__c(Name = 'test',PIR_Status__c ='Draft');
        insert pir;
        PIR_Questions__c pirQuestion = [SELECT Id,Section__c FROM PIR_Questions__c LIMIT 1];
		PIRQnResponse__c response1 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
            Section__c = 'Current Dealer Information'
        );
        insert response1;

        PIRQnResponse__c response2 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
            Section__c = 'Current Dealer Information'
        );
        insert response2;

        Test.startTest();
        List<PIRQnResponse__c> responses = DNAMSPIRQuestionResponses.getPIRResponses(pir.Id);
        Test.stopTest();
	  }
     @isTest
    static void testSaveResponses_Valid() {
      
         Package_Initiation__c pir = new Package_Initiation__c(Name = 'test',PIR_Status__c ='Draft');
        insert pir;
        PIR_Questions__c pirQuestion = [SELECT Id, Section__c FROM PIR_Questions__c LIMIT 1];

        PIRQnResponse__c response1 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
            Section__c = 'Current Dealer Information'
        );
        insert response1;

        PIRQnResponse__c response2 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
    		Section__c = 'Current Dealer Information'
        );
        insert response2;
		 PIRQnResponse__c response3 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
    		Section__c = 'Current Dealer Information'
        );
        //insert response3;

        Test.startTest();
        try{
            DNAMSPIRQuestionResponses.saveResponses(new List<PIRQnResponse__c>{response1, response2});
            DNAMSPIRQuestionResponses.saveResponses(new List<PIRQnResponse__c>{});
           // DNAMSPIRQuestionResponses.saveResponses(new List<PIRQnResponse__c>{response3});
        }
        catch(Exception e){
            
        }
         
        Test.stopTest();
    }
	
    @isTest
     static void testSaveResponses_Valid2() {
      
         Package_Initiation__c pir = new Package_Initiation__c(Name = 'test',PIR_Status__c ='Draft');
        insert pir;
        PIR_Questions__c pirQuestion = [SELECT Id, Section__c FROM PIR_Questions__c LIMIT 1];

        PIRQnResponse__c response1 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
            Section__c = 'Current Dealer Information'
        );
        insert response1;

        PIRQnResponse__c response2 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
    		Section__c = 'Current Dealer Information'
        );
        insert response2;
		 PIRQnResponse__c response3 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
    		Section__c = 'Current Dealer Information'
        );
        //insert response3;

        Test.startTest();
         try{
            DNAMSPIRQuestionResponses.saveResponses(new List<PIRQnResponse__c>{response1, response2});
           // DNAMSPIRQuestionResponses.saveResponses(new List<PIRQnResponse__c>{});
            DNAMSPIRQuestionResponses.saveResponses(new List<PIRQnResponse__c>{response3});
         }
         catch(Exception e){
             
         }
         
        Test.stopTest();
    }
    
     @isTest
     static void testSaveResponses_Valid3() {
      
        Package_Initiation__c pir = new Package_Initiation__c(Name = 'test',PIR_Status__c ='Draft');
        insert pir;
        PIR_Questions__c pirQuestion = [SELECT Id, Section__c FROM PIR_Questions__c LIMIT 1];
		
        PIRQnResponse__c response1 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
            Section__c = 'Current Dealer Information'
        );
        insert response1;
		String s = 'test string Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
            + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
            + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
            + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
            + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
            + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
            + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
            + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
            + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
            + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
            + 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. ';

         String s1 = s+s+s+s+s+s;
        PIRQnResponse__c response2 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
    		Section__c = 'Current Dealer Information'
        );
        insert response2;
		 PIRQnResponse__c response4 = new PIRQnResponse__c(
            Package_Initiation_Request__c = pir.Id,
            PIR_Question__c = pirQuestion.Id,
    		Section__c = 'Current Dealer Information',
            Response__c = s1,
            Id = response2.Id
        );
        //insert response3;
		
         
        Test.startTest();
         try{
           //DNAMSPIRQuestionResponses.saveResponses(new List<PIRQnResponse__c>{response1, response2});
            //DNAMSPIRQuestionResponses.saveResponses(new List<PIRQnResponse__c>{});
            DNAMSPIRQuestionResponses.saveResponses(new List<PIRQnResponse__c>{response4});
         }
         catch(Exception e){
             
         }
         
        Test.stopTest();
    }


}