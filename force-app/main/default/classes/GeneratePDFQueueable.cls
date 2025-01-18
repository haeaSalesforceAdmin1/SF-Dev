public without sharing class GeneratePDFQueueable implements Queueable, Database.AllowsCallouts {

    private String recordId;
    private String pdfType;
    private List<String> recordIds;
    private String documentType;
    private Integer recordIndex;
    private String recordField;
    private Integer fieldIndex;
    public String networkId;
    private List<String> evaluationFields = new List<String> { 'ExternalPDFFileIDNonFinancial__c' , 'InternalPDFFileIDNonFinancial__c'};
    private List<String> surveyFields = new List<String> { 'ExternalPDFFileIDNonFinancial__c' ,  'InternalPDFFileIDNonFinancial__c'};
    private Boolean singleRun = true;

    public GeneratePDFQueueable(List<String> recordIds, String pdfType, Integer fieldIndex, Integer recordIndex) {
        this.recordIds = recordIds;
        this.pdfType = pdfType;

        this.recordIndex = recordIndex;
        this.fieldIndex = fieldIndex;

        this.recordId = recordIds[recordIndex]; 
        if(pdfType == 'Evaluation') {
            this.recordField = surveyFields[fieldIndex];
        }
        else {
            this.recordField = evaluationFields[fieldIndex];
        }
        this.singleRun = false;
    }

    public void execute(QueueableContext context) {
        PageReference pageReference;
        DateTime currentTime = DateTime.now();
        String contentVersionTitle = 'pdfDocument'; 

        Survey__c survey;
        Evaluation__c evaluation;

        System.debug(LoggingLevel.ERROR, 'Executing Queueable');
        System.debug(LoggingLevel.ERROR, recordId);
        System.debug(LoggingLevel.ERROR, pdfType);
        if(pdfType == 'Survey') {   
            Boolean isInternal = true;
            //DPM-5069 : error fix(SurveyQuestionCompPDF does not exist) - 20231016 - MinheeKim
            pageReference = new PageReference('/apex/SurveyPDF_w_image');
            //pageReference = new PageReference('/apex/SurveyQuestionCompPDF');
            survey = [select Id, Name, Latest_PDF_Version_Id__c, Evaluation__c from Survey__c where Id = :recordId ];
            //contentVersionTitle = pdfType + '-' + recordId + '-' + currentTime.format();
            contentVersionTitle = survey.Name + ' - ';
            if(recordField == 'ExternalPDFFileIDNonFinancial__c' ) {
                isInternal = false;
                contentVersionTitle += 'Dealer - ';
            }
            contentVersionTitle += currentTime.format();
            contentVersionTitle += ' - Survey Complete';

            pageReference.getParameters().put('id', recordId);

            Blob data;
            if(Test.isRunningTest()) { 
                data = blob.valueOf('Unit.Test');
            }
            else {
                data = pageReference.getContent();
            }
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData = data;
            contentVersion.Title = contentVersionTitle;
            contentVersion.PathOnClient = contentVersionTitle + '.pdf';
            contentVersion.Origin = 'H';
            contentVersion.SystemGeneratedPDF__c = true;
            if(networkId != null && networkId != '') {
                contentVersion.NetworkId = networkId;
            }

            //if(survey.Latest_PDF_Version_Id__c != null) {
            //    ContentVersion latestContentVersion = [select Id, ContentDocumentId from ContentVersion where Id = :survey.Latest_PDF_Version_Id__c];
            //    contentVersion.ContentDocumentId = latestContentVersion.ContentDocumentId;
            //    contentVersion.ReasonForChange = 'Document updated by user ' + UserInfo.getUserName();
            //    contentVersion.IsMajorVersion = true;
            //}
            insert contentVersion;

            //if(survey.Latest_PDF_Version_Id__c == null) {
            ContentVersion contentVersionWithDocumentId = [select Id, ContentDocumentId from ContentVersion where Id = :contentVersion.Id limit 1];

            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.LinkedEntityId = recordId;
            contentDocumentLink.ContentDocumentId = contentVersionWithDocumentId.ContentDocumentId;
            contentDocumentLink.ShareType = 'V';
            if(!isInternal) {
                contentDocumentLink.Visibility = 'AllUsers';
            }
            insert contentDocumentLink;

            if(survey.Evaluation__c != null) {
                ContentDocumentLink contentDocumentLinkEval = new ContentDocumentLink();
                contentDocumentLinkEval.LinkedEntityId = survey.Evaluation__c;
                contentDocumentLinkEval.ContentDocumentId = contentVersionWithDocumentId.ContentDocumentId;
                contentDocumentLinkEval.ShareType = 'V';
                if(!isInternal) {
                    contentDocumentLinkEval.Visibility = 'AllUsers';
                }
                insert contentDocumentLinkEval;
            }
            //}

            if(fieldIndex == 1) {
                fieldIndex = 0;
                recordIndex++;
            }
            else {
                fieldIndex++;
            }

            if(recordIndex < recordIds.size()) {
                GeneratePDFQueueable generateQueueable = new GeneratePDFQueueable(recordIds, 'Survey', fieldIndex, recordIndex);
                if(!Test.isRunningTest()){
                    System.enqueueJob(generateQueueable);
                }
                else {
                    generateQueueable.execute(context);
                }
            }

            //survey.Latest_PDF_Version_Date__c = DateTime.now();
            //survey.Latest_PDF_Version_Id__c = contentVersion.Id;
            //update survey;
        }
        else if(pdfType == 'Evaluation') {  
            Boolean isInternal = true;
            Boolean isFinancial = true;
            System.debug(LoggingLevel.ERROR, 'Came Into Evaluation');
            pageReference = new PageReference('/apex/EvaluationPDF');

            if(recordField == 'ExternalPDFFileIDNonFinancial__c' || recordField == 'InternalPDFFileIDNonFinancial__c') {
                pageReference.getParameters().put('showFinancials', 'false');
                isFinancial = false;
            }
            else {
                pageReference.getParameters().put('showFinancials', 'true');
                isFinancial = true;
            }

            if(recordField == 'ExternalPDFFileIDNonFinancial__c' || recordField == 'ExternalPDFFileIDFinancial__c') {
                pageReference.getParameters().put('showApprovals', 'false');
                isInternal = false;
            }
            else {
                isInternal = true;
                pageReference.getParameters().put('showApprovals', 'true');
            }
            //recordName + Internal + Financial
            

            evaluation = [select Id, Name, Latest_PDF_Version_Id__c, ExternalPDFFileIDFinancial__c, ExternalPDFFileIDNonFinancial__c, InternalPDFFileIDFinancial__c, InternalPDFFileIDNonFinancial__c from Evaluation__c where Id = :recordId ];
            System.debug(LoggingLevel.ERROR, 'Evaluation');
        
            contentVersionTitle = evaluation.Name + ' - ';
            if(!isInternal) {
                contentVersionTitle += 'Dealer - ';
            }
            if(!isFinancial) {
                contentVersionTitle += 'Non-Financial - ';
            }
            contentVersionTitle += currentTime.format();
            //contentVersionTitle += pdfType + '-' + recordId + '-' + currentTime.format();
            //contentVersionTitle += pdfType + '-' + recordId + '-' + currentTime.format();

            pageReference.getParameters().put('id', recordId);

            Blob data;
            if(Test.isRunningTest()) { 
                data = blob.valueOf('Unit.Test');
            }
            else {
                data = pageReference.getContent();
            }

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData = data;
            contentVersion.Title = contentVersionTitle;
            contentVersion.PathOnClient = contentVersionTitle + '.pdf';
            contentVersion.Origin = 'H';
            contentVersion.SystemGeneratedPDF__c = true;

            String currentFieldValue = (String)evaluation.get(recordField);
            if(currentFieldValue != null) {
                List<ContentVersion> latestContentVersions = [select Id, ContentDocumentId from ContentVersion where Id = :currentFieldValue];
                if(!latestContentVersions.isEmpty()) {
                    contentVersion.ContentDocumentId = latestContentVersions[0].ContentDocumentId;
                }
                else {
                    currentFieldValue = null;
                }
                contentVersion.ReasonForChange = 'Document updated by user ' + UserInfo.getUserName();
                contentVersion.IsMajorVersion = true;
            }
            insert contentVersion;

            if(currentFieldValue == null) {
                ContentVersion contentVersionWithDocumentId = [select Id, ContentDocumentId from ContentVersion where Id = :contentVersion.Id limit 1];

                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.LinkedEntityId = recordId;
                contentDocumentLink.ContentDocumentId = contentVersionWithDocumentId.ContentDocumentId;
                contentDocumentLink.ShareType = 'V';
                if(!isFinancial && !isInternal) {
                    contentDocumentLink.Visibility = 'AllUsers';
                }
                insert contentDocumentLink;

                /*if(isFinancial && !isInternal) {
                    ContentDocumentLink contentDocumentLink2 = new ContentDocumentLink();
                    contentDocumentLink2.LinkedEntityId = '00G3I000000oVIt';
                    contentDocumentLink2.ContentDocumentId = contentVersionWithDocumentId.ContentDocumentId;
                    contentDocumentLink2.ShareType = 'V';
                    insert contentDocumentLink2;
                }*/
                

            }

            evaluation.put(recordField, contentVersion.Id);

            update evaluation;

            if(fieldIndex == 1) {
                fieldIndex = 0;
                recordIndex++;
            }
            else {
                fieldIndex++;
            }

            if(recordIndex < recordIds.size()) {
                GeneratePDFQueueable generateQueueable = new GeneratePDFQueueable(recordIds, 'Evaluation', fieldIndex, recordIndex);
                if(!Test.isRunningTest()){
                    System.enqueueJob(generateQueueable);
                }
                else {
                    generateQueueable.execute(context);
                }
            }
        }
    }
}