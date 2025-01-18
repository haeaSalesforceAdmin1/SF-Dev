@isTest
public class DNAMSDeleteFileHandlerTest {
    @isTest
    static void testGetFiles() {
        Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
        //Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
        //PackageElement__c pe = DNAMSPackageTestDataFactory.createNewPackageElement(p.Id, acc.Id);
        Set<Id> setLinkedEntityIds = new Set<Id>{acc.Id};
            
        Test.startTest();
            ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(acc.Id);
            //ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pe.Id);
            //ContentVersion cv3 = ContentDocumentTestFactory.makeContentVersion(acc.Id);
            List<ContentVersion> lstCVs = new List<ContentVersion>();
            lstCVs.add(cv1);
            //lstCVs.add(cv2);
            //lstCVs.add(cv3);
            insert lstCVs;
            
            List<ContentDocumentLink> lstCDL = [SELECT Id, Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN :setLinkedEntityIds LIMIT 1];
            System.debug('Bhavana=lstCDL='+lstCDL);
            //System.assertEquals(2, lstCDL.size(), 'File uploads to Packages/Package Elements failed.');
            
            List<ContentDocument> resultFiles = DNAMSDeleteFileHandler.getFiles(acc.Id);
            System.debug('Bhavana=resultFiles='+resultFiles);
            // Assert
            System.assertNotEquals(null, resultFiles, 'Result files should not be null');
            System.assertEquals(1, resultFiles.size(), 'There should be one file associated with the account');
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteFiles() {
        Account acc = DNAMSPackageTestDataFactory.createNewAccount('UTOPIA MOUNTAIN HYUNDAI');
        //Package__c p = DNAMSPackageTestDataFactory.createNewPackage(acc.Id);
        //PackageElement__c pe = DNAMSPackageTestDataFactory.createNewPackageElement(p.Id, acc.Id);
        Set<Id> setLinkedEntityIds = new Set<Id>{acc.Id};
            
        Test.startTest();
            ContentVersion cv1 = ContentDocumentTestFactory.makeContentVersion(acc.Id);
            //ContentVersion cv2 = ContentDocumentTestFactory.makeContentVersion(pe.Id);
            //ContentVersion cv3 = ContentDocumentTestFactory.makeContentVersion(acc.Id);
            List<ContentVersion> lstCVs = new List<ContentVersion>();
            lstCVs.add(cv1);
            insert lstCVs;
            
            List<ContentDocumentLink> lstCDL = [SELECT Id, Visibility,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :setLinkedEntityIds LIMIT 1];
            System.debug('Bhavana=lstCDL='+lstCDL);
            //System.assertEquals(2, lstCDL.size(), 'File uploads to Packages/Package Elements failed.');
            System.assertEquals(1, lstCDL.size(), 'There should be one file associated with the account');
        	Set<Id> documentIds = new Set<Id>();
        	for(ContentDocumentLink cdLink:lstCDL){  
                documentIds.add(cdLink.ContentDocumentId);
            }      
            List<ContentDocument> listOfCD= [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];
        	DNAMSDeleteFileHandler.deleteFiles(listOfCD[0].Id);
        	System.debug('Bhavana=lstCDL='+lstCDL);	
        	List<ContentDocumentLink> lstCDLAfterDelete = [SELECT Id, Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN :setLinkedEntityIds LIMIT 1];
            System.assertEquals(0, lstCDLAfterDelete.size(), 'There should not be the file associated with the account');
         Test.stopTest();   
    }
}