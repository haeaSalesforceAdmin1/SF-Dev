/**
 * Description: [EvaluationDpmrController]
 * ----- Change Log -----
 * Author : [JonghoonKim] / [05-08-2024] / [Ticket 5663] / [Created EvaluationDpmrController] 
 * Author : [JonghoonKim] / [12-03-2024] / [Ticket 5946] / [Update createEvalName Method // Modify the logic to add (SI) to the Evaluation Name when the Topic value is 'Survey Integrity'.]
 * Author : [JonghoonKim] / [12-04-2024] / [Ticket 5904] / [Created getSecondaryContactOptions Method And Update saveEvaluation Methoed(Add Secondary Contact)] 
 * ---------------------------
 */

public with sharing class EvaluationDpmrController {
    /**
     * [Method Description] 
     * Create an Evaluation when saving a DPMR
     * Created by [Jonghoon Kim] on [24-08-05] for [Ticket DPM-5663]
     * Edited by [Jonghoon Kim] on [24-12-04] for [Ticket DPM-5904]
    */
    @AuraEnabled
    public static Id saveEvaluation(Map<String, Object> params) {
        try {
            // Parse the map and retrieve each value
            String selectedTopics = (String) params.get('selectedTopics');
            String accountId = (String) params.get('accountId');
            String recordTypeId = (String) params.get('recordTypeId');
            String evalStatus = (String) params.get('evalStatus');
            String evaluationName = (String) params.get('evaluationName');
            String primaryContactId = (String) params.get('primaryContactId');
            String primaryContactName = (String) params.get('primaryContactName');
            String primaryContactRole = (String) params.get('primaryContactRole');
            /**DPM-5904 added by MinheeKim 12.03.2024 */
            String secondaryContactId = (String) params.get('secondaryContactId');
            String secondaryContactName = (String) params.get('secondaryContactName');
            String secondaryContactRole = (String) params.get('secondaryContactRole');
            /**DPM-5904 end */
            String division = (String) params.get('division');
            String selectedContactType = (String) params.get('selectedContactType');
            String contactDateString = (String) params.get('contactDate'); // Get date as string
            String comment = (String) params.get('comment');
            String brandCode = '';
            Date contactDate;
            if(primaryContactId =='OtherContact') {
                primaryContactId = null;
            }
            /**DPM-5904 added by MinheeKim 12.03.2024 */
            else if(primaryContactId!=null){  
                primaryContactName = null;
                primaryContactRole = null;
            }

            if(secondaryContactId =='OtherContact' || secondaryContactId=='N/A') {
                secondaryContactId = null;
            }else if(secondaryContactId!=null){  
                secondaryContactName = null;
                secondaryContactRole = null;
            }
            
            /**DPM-5904 end */

            if (String.isNotEmpty(contactDateString)) {
                contactDate = Date.valueOf(contactDateString); // Convert string to Date
            } else {
                contactDate = null; // Handle null date case if needed
            }
            if(accountId != null ) {
                Account acc = [SELECT BrandCode__c FROM Account WHERE Id = :accountId LIMIT 1];
                brandCode = acc.BrandCode__c;
            }
           
            
            
            // Create a new Evaluation__c record
            Evaluation__c evaluation = new Evaluation__c(
                Name = evaluationName,
                Account__c = accountId,
                RecordTypeId = recordTypeId,
                DPMR_Status__c = evalStatus,
                PrimaryContact__c = primaryContactId,
                PrimaryContactName__c = primaryContactName,
                Primary_Contact_Role__c = primaryContactRole,
                /**DPM-5904 added by MinheeKim 12.03.2024 */
                SecondaryContact__c = secondaryContactId,
                SecondaryContactName__c = secondaryContactName,
                SecondaryContactRole__c = secondaryContactRole,
                /**DPM-5904 end */
                Contact_Type__c = selectedContactType,
                PrimaryContactDate__c = contactDate,
                Type__c = division,
                Comment__c = comment
            );
        

            if(brandCode == 'H' && division == 'Sales') {
                evaluation.topics_HmaSales__c = selectedTopics;
            } else if(brandCode == 'H' && division == 'Service') {
                evaluation.topics_HmaService__c = selectedTopics;
            } else if(brandCode == 'G' && division == 'Sales') {
                evaluation.topics_GmaSales__c = selectedTopics;
            } else if(brandCode == 'G' && division == 'Service') {
                evaluation.topics_GmaService__c = selectedTopics;
            }


            // Insert the record and return the Id
            insert evaluation;
            
            
            return evaluation.Id;
        } catch (Exception e) {
            throw new AuraHandledException('saveEvaluation Error: ' + e.getMessage());
        }
    }

    /**
     * [Method Description] 
     * Retrieve Contacts based on the selected Account and add them to the Options.
     * Created by [Jonghoon Kim] on [24-08-05] for [Ticket DPM-5663]
     * Edited by [Author] on [Date] for [Ticket #]
    */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getContactOptions(String accountId) {
        List<Map<String, String>> options = new List<Map<String, String>>();

        //  AccountContactRelation get Contact Info
        List<AccountContactRelation> relations = [SELECT ContactId, Contact_Name_Job_Code__c FROM AccountContactRelation WHERE AccountId = :accountId ORDER BY Contact_Name_Job_Code__c ASC];

        if (relations.size() > 0) {
            for (AccountContactRelation relation : relations) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', relation.Contact_Name_Job_Code__c);
                option.put('value', relation.ContactId);
                options.add(option);
            }
        }

        // add "Other Contact" 
        Map<String, String> otherContactOption = new Map<String, String>();
        otherContactOption.put('label', 'Other Contact');
        otherContactOption.put('value', 'OtherContact');
        options.add(otherContactOption);

        return options;
    }

    /**
     * [Method Description] 
     * Method to update the options of the Secondary Contact when the Primary Contact is updated.
     * Created by [Jonghoon Kim] on [24-12-04] for [Ticket DPM-5904]
     * Edited by [Author] on [Date] for [Ticket #]
    */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getSecondaryContactOptions(String accountId, String primaryContactId) {
        List<Map<String, String>> options = new List<Map<String, String>>();

        //  AccountContactRelation get Contact Info
        List<AccountContactRelation> relations = [SELECT ContactId, Contact_Name_Job_Code__c 
                                                FROM AccountContactRelation 
                                                WHERE AccountId = :accountId 
                                                AND ContactId != :primaryContactId
                                                ORDER BY Contact_Name_Job_Code__c ASC];

        if (relations.size() > 0) {
            for (AccountContactRelation relation : relations) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', relation.Contact_Name_Job_Code__c);
                option.put('value', relation.ContactId);
                options.add(option);
            }
        }

        // add "Other Contact" 
        Map<String, String> otherContactOption = new Map<String, String>();
        otherContactOption.put('label', 'Other Contact');
        otherContactOption.put('value', 'OtherContact');
        options.add(otherContactOption);

        return options;
    }

    

    /**
     * [Method Description] 
     * Retrieve the Account Name value (no need to process with a List or Map as no further Account-related queries are expected).
     * Created by [Jonghoon Kim] on [24-08-05] for [Ticket DPM-5663]
     * Edited by [Author] on [Date] for [Ticket #]
    */
    @AuraEnabled(cacheable=true)
    public static String getAccountName(Id accountId) {
        try {
            Account acc = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
            return acc.Name;
        } catch (Exception e) {
            // Log and handle unexpected errors
            System.debug('Error in getAccountBrandCode: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while retrieving the account brand code: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordType(String recordTypeName) {
        try{
            RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName LIMIT 1];
            return rt.Id;
        } catch (Exception e) {
            // Log and handle unexpected errors
            System.debug('Error in getRecordType: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while retrieving the recordType : ' + e.getMessage());
        }
    }

	/**
     * [Method Description] 
     * Create Evaluation Name // dealer Code + division + Contact Date + count 
     * Created by [Jonghoon Kim] on [24-08-05] for [Ticket DPM-5663]
     * Edited by [Jonghoon Kim] on [24-12-03] for [Ticket 5946]
    */
    @AuraEnabled(cacheable=true)
    public static String createEvalName(String recordId, Date contactDate, String division, String topic) {
        // Query the Account record to retrieve the dealerCode.
        List<Account> accList = [SELECT DealerCode__c, BrandCode__c  FROM Account WHERE Id = :recordId];
        Integer evalCount = 0;
        
        // Convert the Date object to a DateTime object and apply the date format
        DateTime dateTimeForFormatting = DateTime.newInstance(contactDate, Time.newInstance(0, 0, 0, 0));
        String formattedDate = dateTimeForFormatting.format('MMM d, yyyy');
        
        String evalName = '';
        String dealerCode = '';
        String brandCode = '';
        
        if (accList.size() > 0) {
            dealerCode = accList[0].DealerCode__c;
        }
        
        
        // DPM - 5946 - Add 'Survey Integrity' logic
        if(division == 'Sales') {
            if(topic.contains('Financial Performance') && topic.contains('Survey Integrity')) { 
                evalName = dealerCode + ' - Sales DPMR (FIN, SI) - ' + formattedDate + ' - ';
            } else if(topic.contains('Survey Integrity') && !topic.contains('Financial Performance')) {
                evalName = dealerCode + ' - Sales DPMR (SI) - ' + formattedDate + ' - ';
            } else if(topic.contains('Financial Performance') && !topic.contains('Survey Integrity')) {
                evalName = dealerCode + ' - Sales DPMR (FIN) - ' + formattedDate + ' - ';
            } else {
                evalName = dealerCode + ' - Sales DPMR - ' + formattedDate + ' - ';
            }
            
        } else {
            if(topic.contains('Financial Performance') && topic.contains('Survey Integrity')) {
                evalName = dealerCode + ' - Aftersales DPMR (FIN, SI) - ' + formattedDate + ' - ';
            } else if(topic.contains('Survey Integrity') && !topic.contains('Financial Performance')) {
                evalName = dealerCode + ' - Aftersales DPMR (SI) - ' + formattedDate + ' - ';
            } else if(topic.contains('Financial Performance') && !topic.contains('Survey Integrity')) {
                evalName = dealerCode + ' - Aftersales DPMR (FIN) - ' + formattedDate + ' - ';
            } else {
                evalName = dealerCode + ' - Aftersales DPMR - ' + formattedDate + ' - ';
            }
        }
        
        
 
        // List<Evaluation__c> evaluations = [SELECT Name FROM Evaluation__c WHERE Name LIKE :  + '%'];


        List<Evaluation__c> evaluations = [
                                            SELECT Name 
                                            FROM Evaluation__c 
                                            WHERE RecordType.DeveloperName LIKE '%DPMR%'
                                            AND PrimaryContactDate__c = :contactDate 
                                            AND Account__r.DealerCode__c = :dealerCode
                                            AND Type__c =:division
                                            ];

        if (evaluations.size() > 0) {
            Integer maxNumber = 0;
            for (Evaluation__c eval : evaluations) {
                String[] parts = eval.Name.split(' - ');
                if (parts.size() > 2) {
                    String numberPart = parts[parts.size() - 1];
                    Integer num;
                    try {
                        num = Integer.valueOf(numberPart);
                        if (num > maxNumber) {
                            maxNumber = num;
                        }
                    } catch (Exception e) {
                       
                    }
                }
            }
            // Add 1 to the highest number
            evalName += (maxNumber + 1);
        } else {
            // Use the default number 1 if there is no existing Eval.
            evalName += '1';
        }
        
        return evalName;
    }
    /**
     * [Method Description] 
     * Associate the saved File with the Evaluation.
     * Created by [Jonghoon Kim] on [24-08-05] for [Ticket DPM-5663]
     * Edited by [Author] on [Date] for [Ticket #]
    */
    @AuraEnabled
    public static void uploadFile(Id recordId, String fileName, String base64Data, String contentType) {
        try {
            // Create ContentVersion object to handle file upload
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            // Set FileExtension if needed
            // cv.FileExtension = contentType; // Uncomment if file type is needed
    
            // Insert ContentVersion
            insert cv;
    
            // Retrieve the ContentDocumentId from the inserted ContentVersion
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V'; // 'V' for Viewer
    
            // Insert ContentDocumentLink
            insert cdl;
            
            System.debug('File uploaded and linked successfully.');
    
        } catch (Exception e) {
            // Handle and log the exception
            System.debug('Error uploading file: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while uploading the file: ' + e.getMessage());
        }
    }


    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getRelatedFiles(Id evalId) {
        if (String.isEmpty(evalId)) {
            return new List<Map<String, Object>>();
        }

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :evalId
        ];
        
        List<Map<String, Object>> fileList = new List<Map<String, Object>>();
        
        if (!links.isEmpty()) {
            for (ContentDocumentLink link : links) {
                ContentDocument doc = link.ContentDocument;
                // URL for viewing the file
                String fileUrl = '/sfc/servlet.shepherd/document/download/' + link.ContentDocumentId;
                // URL for thumbnail image
                
                // Query the file version to get the file size and created date
                ContentVersion version = [SELECT CreatedDate, ContentSize 
                                        FROM ContentVersion 
                                        WHERE Id = :doc.LatestPublishedVersionId 
                                        LIMIT 1];
                
                fileList.add(new Map<String, Object>{
                    'Id' => doc.Id,
                    'FileName' => doc.Title,
                    'FileUrl' => fileUrl,
                    'CreatedDate' => version.CreatedDate.format(),
                    'FileSize' => version.ContentSize / 1024 + ' KB', // Size in KB
                    'FileExtension' => doc.FileExtension
                });
            }
        }

        return fileList;
    }
   
    /**
     * [Method Description] 
     * File saved
     * Created by [Jonghoon Kim] on [24-08-05] for [Ticket DPM-5663]
     * Edited by [Author] on [Date] for [Ticket #]
    */
    @AuraEnabled
    public static void saveImgFile(String fileName, String fileType, String base64Body) {
        Blob fileBody = EncodingUtil.base64Decode(base64Body);
        
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.VersionData = fileBody;
        cv.IsMajorVersion = true;
        insert cv;
        

}
}