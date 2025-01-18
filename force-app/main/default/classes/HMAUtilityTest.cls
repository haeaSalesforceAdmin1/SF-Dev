@isTest
public class HMAUtilityTest {

    @testSetup
    static void setup() {
        // Create test data for CurrentEnvironment__c
        CurrentEnvironment__c currentEnvironment = new CurrentEnvironment__c(
            Environment__c = 'Test'
        );
        insert currentEnvironment;
        
        // Create test data for DPMConfigurationSettings__c
        DPMConfigurationSettings__c dpmConfig = new DPMConfigurationSettings__c(
            Name = 'TestDPMConfig',
            PRODRecordTypeIDAPGenesisService__c  = '0123456789ABCDEF'
        );
        insert dpmConfig;
    }

    @isTest
    static void testGetCurrentEnvironment() {
        Test.startTest();
        
        // Call the method and assert results
        String environment = HMAUtility.getCurrentEnvironment();
        
        System.assertEquals('Test', environment, 'The current environment should be "Test".');
        
        Test.stopTest();
    }

    @isTest
    static void testGetRecordTypeIdForOrg() {
        Test.startTest();
        
        // Define parameters
        String recordTypeName = 'GenesisService';
        String objectPrefix = 'AP'; // Example prefix for Account object
        
        // Call the method and assert results
        String recordTypeId = HMAUtility.getRecordTypeIdForOrg(recordTypeName, objectPrefix);
        
        System.assertEquals('0123456789ABCDEF', recordTypeId, 'The RecordTypeId should be "0123456789ABCDEF".');
        
        Test.stopTest();
    }
}