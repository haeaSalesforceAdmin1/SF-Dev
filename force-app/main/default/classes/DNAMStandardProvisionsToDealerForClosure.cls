/*
 * _______________________________________________________________________________________________________
 * Description: Invocable class to Provide Standard Provisions to dealer package closure. This will be called from DNAMS-Standard Provisions to Dealer After Package Closure flow
 * _______________________________________________________________________________________________________
 * @author          Bhavana
 * @version         1.0
 * @created         31/10/2024
 * @input			String recordId
 * @output			NA
 * @TestClass		DNAMStandardProvisionsToDealerTest
 * ________________________________________________________________________________________________________
 */
public class DNAMStandardProvisionsToDealerForClosure {
	@InvocableMethod(label='Provide Standard Provisions to dealer package closure Invocable Apex' description='Invocable apex to Provide Standard Provisions to dealer package closure' iconName='slds:standard:output')
    public static void copyFileToAccount(List<InvocableInput> requests){
        String originalContentDocumentId = requests[0].contentDocuementId;
        String accountId = requests[0].accountId;
        String packageId = requests[0].recordId;
        // Step 1: Retrieve the original ContentDocument
        ContentDocument originalDocument = [SELECT Id, Title, LatestPublishedVersionId 
                                            FROM ContentDocument 
                                            WHERE Id = :originalContentDocumentId 
                                            LIMIT 1];
		// Step 2: Retrieve the latest ContentVersion of the original document
        ContentVersion originalVersion = [SELECT Id, Title, VersionData,ContentDocumentId,PathOnClient 
                                          FROM ContentVersion 
                                          WHERE Id = :originalDocument.LatestPublishedVersionId 
                                          LIMIT 1];
		// Step 3: Create a new ContentVersion for the copied file
        ContentVersion newVersion = new ContentVersion();
        newVersion.Title = originalVersion.Title;
        newVersion.VersionData = originalVersion.VersionData; // This contains the file data
        newVersion.IsMajorVersion = true; // Set as a major version
        newVersion.PathOnClient = originalVersion.PathOnClient; // Set the path on client to the PathOnClient of the original file
        newVersion.ExternalKey__c = originalVersion.ContentDocumentId+','+System.now();
        ContentVersionTriggerHandler.run = false;
        ContentDocumentLinkTriggerHandler.run = false;
        insert newVersion;// Insert the new ContentVersion
		
       	//Step 4: Get the Inserted Content Versioon Document Id
       	String newCVContentDocumentId= [Select ContentDocumentId From ContentVersion where Id=:newVersion.Id].ContentDocumentId;
        
        // Step 5: Create a new ContentDocumentLink to link it to the Account
        ContentDocumentLink newLink = new ContentDocumentLink();
        newLink.ContentDocumentId = newCVContentDocumentId; 
        newLink.LinkedEntityId = accountId; // Linking to the Account
        newLink.ShareType = 'V'; // Viewer access
		newLink.Visibility = 'AllUsers';  // All users can access
        insert newLink;// Insert the new link
        
    }
    
    public class InvocableInput {
    
        @InvocableVariable(label='Package Record Id')
        public String recordId;
        
        @InvocableVariable(label='Account Record Id')
        public String accountId;
        
        @InvocableVariable(label='Content Docuement Id')
        public String contentDocuementId;
    	
    }
}