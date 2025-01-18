/**
     * [Class Description] COPP Project - Queueable to attach the tracker pdf to copp evaluation
     * Created by [MinheeKim] on [2024-09-25] for [DPM-5709]
    */

    public class GenerateQueueableCOPPEvaluation implements Queueable, Database.AllowsCallouts {
    
        private List<Evaluation__c> evaluations; 
    
        public GenerateQueueableCOPPEvaluation(List<Evaluation__c> evaluations) {
            this.evaluations = evaluations;
        }
    
        public void execute(QueueableContext context) {
    
            
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            Map<String, Id> accountTracker = new Map<String, Id>();
            List<ContentDocumentLink> evalDocLinks = new List<ContentDocumentLink>();
    
            for(Evaluation__c evaluation : evaluations) {
                if (evaluation.Account__c != null && evaluation.DealerCode__c != null) {
                    String trackerPageUrl = '/apex/COPPMonthlyTracker?recordId=' + EncodingUtil.urlEncode(evaluation.Account__c, 'UTF-8');
                    PageReference trackerPage = new PageReference(trackerPageUrl);
                    Blob trackerBlob;
                    try {
                        if(!Test.isRunningTest()){
                            trackerBlob = trackerPage.getContentAsPDF();
                        }else if(Test.isRunningTest()){
                            trackerBlob = Blob.valueOf('Unit Test PDF');
                        }
                        
                    } catch (Exception e) {
                        System.debug('Error generating PDF for ' + evaluation.DealerCode__c + ': ' + e.getMessage());
                        continue; 
                    }
                    if (trackerBlob != null) {
                        ContentVersion contentVersionTracker = new ContentVersion();
                        contentVersionTracker.VersionData = trackerBlob;
                        contentVersionTracker.Title = 'COPP_Tracker_' + evaluation.DealerCode__c;
                        contentVersionTracker.PathOnClient = 'COPP_Tracker_' + evaluation.DealerCode__c + '.pdf';
                        contentVersionList.add(contentVersionTracker);
                        accountTracker.put(contentVersionTracker.Title, evaluation.Id );
                    }
                }
            }
            
            if (!contentVersionList.isEmpty()) {
                insert contentVersionList;
            }
    
              //Get Content Document Id
            for(ContentVersion contentVersion : [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN: contentVersionList]){
                if(accountTracker.containsKey(contentVersion.Title)){
                    ContentDocumentLink evalDocLink = new ContentDocumentLink();
                    evalDocLink.ContentDocumentId = contentVersion.ContentDocumentId;
                    evalDocLink.LinkedEntityId = accountTracker.get(contentVersion.Title);
                    evalDocLink.ShareType = 'V';
                    evalDocLinks.add(evalDocLink);
                }
            }
            
        
           if(evalDocLinks.size()>0){
                try {
                    insert evalDocLinks;
                } catch(Exception e) {
                    System.debug(e.getMessage());
                }
           }
        }
    }