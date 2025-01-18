@isTest
private class DNAMSAdditionalEmailsTest {
	@testSetup static void setup() {
        Test.startTest();
            User runAsUser = ContentDocumentTestFactory.makeUser();
            insert runAsUser;
     
            Account acc=new Account(Name='test');
            insert acc;
            Package__c pa=new Package__c();
            pa.Type__c ='Renewal';
            pa.Classification__c='Major';
            pa.Description__c='This is sample package';
            pa.PackageDetail__c='New Dealer';
            pa.Sequence__c=3;
            pa.Status__c='Draft';
            pa.Dealer__c=acc.Id;
            pa.AdditionalCCForInitiateToDealers__c= 'test@email.com';
            insert pa; 
    	Test.stopTest();
    }
    @IsTest static void testAdditionalEmailsMethod() {
        Test.startTest();
            Package__c packageRec = [SELECT Id FROM Package__c LIMIT 1];
            List<String> inputList = new List<String>();
            inputList.add(packageRec.Id);
        	List<List<String>> listOfInputList = new List<List<String>>();
        	listOfInputList.add(inputList);
            List<List<String>> listOfOutputList =DNAMSAdditionalEmails.addAdditionalEmails(listOfInputList);
        	System.assertNotEquals(listOfOutputList.size(),0);
        Test.stopTest();
    }
}