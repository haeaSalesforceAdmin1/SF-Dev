@isTest
public class DNAMSPackageCloneTransmittalTest {
	@isTest
    static void testClonePackages() {
        // Step 1: Create an original Package__c record with sample data
        Package__c originalPkg = new Package__c(
            Current_Hyundai_Dealer_Code__c = 'D123',
            Prepared_By__c = 'John Doe',
            Genesis_Facility_Configuration__c = 'LTC',
            Addenda_Included__c = 'true',
            // Include other fields as needed
            Package_Description__c = 'Original Package'
        );
        insert originalPkg;

        // Step 2: Create a cloned Package__c record
        Package__c clonedPkg = new Package__c(
            Current_Hyundai_Dealer_Code__c = 'D456', // Different value to test update
            Prepared_By__c = 'Jane Smith',
            Genesis_Facility_Configuration__c = 'LTC',
            Addenda_Included__c = 'false',
            // Include other fields as needed
            Package_Description__c = 'Cloned Package'
        );
        insert clonedPkg; 

        // Step 3: Prepare the input for the invocable method
        DNAMSPackageCloneUpdateTransmittalFields.InvocableInput input = new DNAMSPackageCloneUpdateTransmittalFields.InvocableInput();
        input.recordId = originalPkg.Id;
        input.clonedRecordId = clonedPkg.Id;

        // Step 4: Call the method
        Test.startTest();
        DNAMSPackageCloneUpdateTransmittalFields.clonePackages(new List<DNAMSPackageCloneUpdateTransmittalFields.InvocableInput> { input });
        Test.stopTest();

        // Step 5: Verify the results
        clonedPkg = [SELECT Current_Hyundai_Dealer_Code__c, Prepared_By__c, Genesis_Facility_Configuration__c, Addenda_Included__c, Package_Description__c FROM Package__c WHERE Id = :clonedPkg.Id];

        // Assert that the cloned package fields were updated correctly
        System.assertEquals('D123', clonedPkg.Current_Hyundai_Dealer_Code__c);
        System.assertEquals('John Doe', clonedPkg.Prepared_By__c);
        //System.assertEquals('Config A', clonedPkg.Genesis_Facility_Configuration__c);
        System.assertEquals('true', clonedPkg.Addenda_Included__c);
        System.assertEquals('Original Package', clonedPkg.Package_Description__c); // Should changed to original
    }	
}