public class DNAMSClonePackageElementsFilesQueueable implements Queueable {
    private String packageRecordId;
    private Set<String> setOfClonnedPackageElementIds = new Set<String>();
    private Set<String> setOfOriginalPackageElementIds = new Set<String>();
    private String ownerId;
    
	public DNAMSClonePackageElementsFilesQueueable(String recordId,Set<String> setOfClonnedPackageElementIds, Set<String> setOfOriginalPackageElementIds, String ownerId) {
        this.packageRecordId = recordId;
        this.setOfClonnedPackageElementIds = setOfClonnedPackageElementIds;
        this.setOfOriginalPackageElementIds = setOfOriginalPackageElementIds;
        this.ownerId = ownerId;
    }

    public void execute(QueueableContext context) {
        // Logic to clone records based on packageRecordId
        Package__c newPackageRecord=[Select Id,OwnerId,RecordType.Name,Name, Status__c,Original_Package__c,Original_Package__r.Name from Package__c where Id =: packageRecordId];
        if(newPackageRecord.Original_Package__c != null){
            Package__c sourcePackageRecord=[Select Id, RecordType.Name,Name, Status__c,Original_Package__c,Original_Package__r.Name from Package__c where Id =: newPackageRecord.Original_Package__c];
        
            Map<Id,PackageElement__c> mapOfNewPackageElements = new Map<Id, PackageElement__c>([Select Id,OriginalPackageElementId__c from PackageElement__c where Package__c=:packageRecordId AND Id IN:setOfClonnedPackageElementIds]);
            if(mapOfNewPackageElements.size() == 0 && Test.isRunningtest()){
                mapOfNewPackageElements = new Map<Id, PackageElement__c>([Select Id,OriginalPackageElementId__c from PackageElement__c where Id IN:setOfClonnedPackageElementIds AND OriginalPackageElementId__c != null]);
            }
            if(newPackageRecord.Original_Package__c != null){
                Map<Id,PackageElement__c> mapOfSourcePackageElements = new Map<Id, PackageElement__c>();
                Boolean isStatusInitiatedForSourcePkg = false;
                for(PackageElement__c sourcePkgElement: [Select Id,OriginalPackageElementId__c,Package__r.Status__c from PackageElement__c where Package__c=:newPackageRecord.Original_Package__c AND Id IN: setOfOriginalPackageElementIds]){
                    if(isStatusInitiatedForSourcePkg  == false && sourcePkgElement.Package__r.Status__c == 'Initiated'){
                        isStatusInitiatedForSourcePkg = true;
                    }
                    mapOfSourcePackageElements.put(sourcePkgElement.Id, sourcePkgElement);
                }
                // Step 1: Clone Files
                //cloneFiles(mapOfNewPackageElements, mapOfSourcePackageElements, ownerId, isStatusInitiatedForSourcePkg, newPackageRecord);
                cloneFiles(mapOfNewPackageElements, mapOfSourcePackageElements);
                //Update owner
                newPackageRecord.OwnerId = this.ownerId;
                update newPackageRecord;
        		
                // Step 2: Clone Content Documents
                System.debug('BR=DNAMSClonePackageElementsFilesQueueable()execute()==isStatusInitiatedForSourcePkg='+isStatusInitiatedForSourcePkg);
                if(isStatusInitiatedForSourcePkg){
                    System.debug('BR=DNAMSClonePackageElementsFilesQueueable()execute()==isStatusInitiatedForSourcePkg='+isStatusInitiatedForSourcePkg);
                    // Schedule the next job to delete the source files
					//System.enqueueJob(new DNAMSDeletePackageRecordQueueable(newPackageRecord.Original_Package__c,mapOfSourcePackageElements));
					System.enqueueJob(new DNAMSDeletePackageRecordQueueable(newPackageRecord.Original_Package__c));
                }
            }
        }
    }
    
    private static Void cloneFiles(Map<Id,PackageElement__c> mapOfNewPackageElements, Map<Id,PackageElement__c> mapOfSourcePackageElements) {
        Map<String,PackageElement__c> mapOfSourceIdWithNewRecord = new Map<String,PackageElement__c>();
        for(PackageElement__c newRecord:mapOfNewPackageElements.values()){
            mapOfSourceIdWithNewRecord.put(newRecord.OriginalPackageElementId__c,newRecord);
        }
        Set<String> setOfCDI = new Set<String>();
        List<ContentDocumentLink> newContentDocumentLinks= new List<ContentDocumentLink>();
        Map<String,ContentDocumentLink> mapOfSourceCDL= new Map<String,ContentDocumentLink>();
        Map<String,String> mapOfSourceCDIdWithLinkedId= new Map<String,String>();
        for(ContentDocumentLink cdl:[SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: mapOfSourcePackageElements.keySet()]){
            setOfCDI.add(cdl.ContentDocumentId);
            mapOfSourceCDL.put(cdl.LinkedEntityId, cdl);
            mapOfSourceCDIdWithLinkedId.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
        }
        List<ContentVersion> clonedContentVersions = new List<ContentVersion>();
		Map<String,ContentVersion> mapOfSourceContenetDocumentIdWithNewContentversion = new Map<String,ContentVersion>();
        if(setOfCDI.size() > 0){
            for (ContentVersion originalFile : [SELECT Id, Title, VersionData, PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: setOfCDI AND isLatest = true]) {
                ContentVersion clonedContentVersion = new ContentVersion(
                    Title = originalFile.Title,
                    VersionData = originalFile.VersionData,
                    PathOnClient = originalFile.PathOnClient,
                    ExternalKey__c = originalFile.ContentDocumentId+','+System.now()
                );
                clonedContentVersions.add(clonedContentVersion);
                mapOfSourceContenetDocumentIdWithNewContentversion.put(originalFile.ContentDocumentId,clonedContentVersion);
            }
            //try{
            ContentVersionTriggerHandler.run = false;
            ContentDocumentLinkTriggerHandler.run = false;
            insert clonedContentVersions;
            Set<String> clonedContentIds = new Set<String>();
            for(ContentVersion cvRecord:clonedContentVersions){
                clonedContentIds.add(cvRecord.Id);
            }
            Set<String> clonedContentDocumentIds = new Set<String>();
            for(ContentVersion cvRecord:[Select Id,ContentDocumentId,ExternalKey__c From ContentVersion Where Id IN: clonedContentIds]){
                clonedContentDocumentIds.add(cvRecord.ContentDocumentId);
                mapOfSourceContenetDocumentIdWithNewContentversion.put(cvRecord.ContentDocumentId, cvRecord);
            }
            for(ContentDocumentLink cdl: [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN: clonedContentDocumentIds]){
                if(mapOfSourceContenetDocumentIdWithNewContentversion.containsKey(cdl.ContentDocumentId)){
                    ContentVersion cvRecord= mapOfSourceContenetDocumentIdWithNewContentversion.get(cdl.ContentDocumentId);
                    String externalId = cvRecord.ExternalKey__c;
                    List<String> lstString = externalId.split(',');
                    if(lstString.size() > 0){
                        if(mapOfSourceIdWithNewRecord.size()> 0 && mapOfSourceIdWithNewRecord.containsKey(mapOfSourceCDIdWithLinkedId.get(lstString[0]))){
                            PackageElement__c newPkgElement = mapOfSourceIdWithNewRecord.get(mapOfSourceCDIdWithLinkedId.get(lstString[0]));
                            if(newPkgElement != null){
                                ContentDocumentLink newContentDocumentLink = new ContentDocumentLink(
                                    LinkedEntityId = newPkgElement.Id,
                                    ContentDocumentId = cdl.ContentDocumentId,
                                    ShareType = 'V',  
                                    Visibility = 'AllUsers'  // All users can access
                                );
                                newContentDocumentLinks.add(newContentDocumentLink);
                            }
                        }
                    }
                }
            }
            if(newContentDocumentLinks.size() > 0){
                ContentVersionTriggerHandler.run = false;
            	ContentDocumentLinkTriggerHandler.run = false;
                insert newContentDocumentLinks;
            }
        }
    }
}