/**
 * Created by baltamimi on 2021-12-21.
 * 
 * UPDATED AT 24.09.13  / [SO-440] / INHO KIM 
 */

 public without sharing class ContentDocumentUtil {

    public static Map<Id, String> getCaseCurrentStageByDocumentId(List<SObject> contents) {

        Map<Id, SObject> documentsByIdMap = getDocumentsByIds(contents);
        if(documentsByIdMap == null){
            System.debug('ContentDocumentUtil/getCaseCurrentStageByDocumentId INFO:: could not find a related document');
            return new Map<Id, String>();
        }
        Map<Id, String> currentCaseStageByDocumentId = new Map<Id, String>();

        for (SObject content : contents) {
            Id documentId = getDocumentId(content);

            String documentType = documentId.getSobjectType().getDescribe().getName();
            String stageName;            
            Boolean isPersonalLibraryDocument = false;
            switch on documentType {
                when 'DADocuments__c' {
                    DADocuments__c document = (DADocuments__c) documentsByIdMap.get(documentId);
                    stageName = (document.Case__r.IsClosed ? 'Closed' : document.Case__r.Stage__c);
                }
                when 'DRCDocument__c' {
                    DRCDocument__c document = (DRCDocument__c) documentsByIdMap.get(documentId);
                    Integer numberOfDays = Integer.valueOf(getSafetyConfigurationSettings().DRCDocumentUploadDays__c);
                    if (document.Case__r.IsClosed) {
                        if (document.Case__r.ClosedDate.addDays(numberOfDays) >= System.today()) {
                            stageName = 'Allowed';
                        } else {
                            stageName = 'Closed';
                        }
                    } else {
                        stageName = document.Case__r.Stage__c;
                    }
                }
                when 'TRCDocument__c' {
                    TRCDocument__c document = (TRCDocument__c) documentsByIdMap.get(documentId);
                    stageName = (document.Case__r.IsClosed ? 'Closed' : document.Case__r.Stage__c);
                }
                when 'NASDADocument__c' {
                    NASDADocument__c document = (NASDADocument__c) documentsByIdMap.get(documentId);
                    Integer numberOfDays = Integer.valueOf(getSafetyConfigurationSettings().NASDADocumentUploadDays__c);

                    if (document.Case__r.IsClosed) {
                        if (document.Case__r.ClosedDate.addDays(numberOfDays) >= System.today()) {
                            stageName = 'Allowed';
                        } else {
                            stageName = 'Closed';
                        }
                    } else {
                        stageName = document.Case__r.Stage__c;
                    }
                }
                //Need to add Package object as well
                when 'PackageElement__c' {
                    PackageElement__c request = (PackageElement__c) documentsByIdMap.get(documentId);

                    if (request.Package__r.Status__c == 'Closed' || request.Package__r.Status__c == 'Canceled') {
                        stageName = 'Package Closed or Canceled';
                    }
                }
                when 'PackageRequest__c' {
                    PackageRequest__c request = (PackageRequest__c) documentsByIdMap.get(documentId);

                    if (request.Status__c == 'DLR Request Rejected' || request.Status__c == 'DLR Request Approved' || request.Package__r.Status__c == 'Assigned to Dealer') {
                        stageName = 'Request Closed';
                    }
                }
                when else {
                    System.debug('Document ' + documentId + ' of type [' + documentType + '] could be part of personal library');
                    isPersonalLibraryDocument = true;
                }

            }
            if (!isPersonalLibraryDocument) {
                currentCaseStageByDocumentId.put(documentId, stageName);
            }
        }
        return currentCaseStageByDocumentId;
    }

     /* 
      * date 03.14.23
    * Added by Minhee Kim for SO-85
    * Prevent document creation, modification, deletion in cases that do not meet the conditions
      * Updated by Semy Lee for SO-85(date 03.17.23)
    */
    public static Map<Id, Boolean> checkDocAuthorByDocumentObjId(Map<Id, SObject> documentMap) {

        Map<Id, Boolean> result = new Map<Id, Boolean>();
        Map<Id, SObject> documentsByIdMap = new Map<Id, SObject>();     // for data storage
        String docType;
        Boolean allowed = false;
        String  stage;
        Boolean closed;
        Integer dayDiff;
        Boolean isPersonalLibraryDocument = false;

        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name; 
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Service_Cloud_Safety_Admin');
        for (Id docId : documentMap.keySet()) {
            docType = docId.getSobjectType().getDescribe().getName();
        }
        if (docType.equalsIgnoreCase('DADocuments__c')) {
            documentsByIdMap.putAll([SELECT Id, Case__c, Case__r.IsClosed,  Case__r.Status, Case__r.Stage__c FROM DADocuments__c WHERE Id IN:documentMap.keySet()]);
        }
        if (docType.equalsIgnoreCase('DRCDocument__c')) {
            documentsByIdMap.putAll([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate, Case__r.Stage__c, Case__r.Status, Case__r.DRCCompletionDate__c FROM DRCDocument__c WHERE Id IN:documentMap.keySet()]);
        }
        if (docType.equalsIgnoreCase('TRCDocument__c')) {
            documentsByIdMap.putAll([SELECT Id, Case__c, Case__r.IsClosed, Case__r.Stage__c, Case__r.Status, Case__r.TRCCompletionDate__c FROM TRCDocument__c WHERE Id IN:documentMap.keySet()]);
        }
        if (docType.equalsIgnoreCase('NASDADocument__c')) {
            documentsByIdMap.putAll([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c, Case__r.NASDACompletionDate__c FROM NASDADocument__c WHERE Id IN:documentMap.keySet()]);
        }
                    
        for (Id docId : documentMap.keySet()) {
            System.debug('isAuthorizedUser : ' + ContentDocumentUtil.isAuthorizedUser(UserInfo.getUserId(), UserInfo.getProfileId()));
            System.debug(  '====ContentDocumentUtil.checkDocAuthorByDocumentObjId    '   );
            System.debug(  '====documentsByIdMap'   );
            System.debug(  documentsByIdMap   );
            switch on docType {
                when  'DADocuments__c' {
                    DADocuments__c daDoc = (DADocuments__c)documentsByIdMap.get(docId);
                    
                    if(daDoc.Case__r != null) {
                        // ADD Q-DA Stage Condition - Detected during QA SO-440
                        if( (daDoc.Case__r.Stage__c.equalsIgnoreCase('DA')||daDoc.Case__r.Stage__c.equalsIgnoreCase('Q-DA')) && !daDoc.Case__r.IsClosed) { allowed = true;
                        } else allowed = false;
                        result.put(docId, allowed);
                    }
                }
                when 'DRCDocument__c' {
                    DRCDocument__c drcDoc = (DRCDocument__c)documentsByIdMap.get(docId);
                    if(drcDoc.Case__r != null) {
                        dayDiff = drcDoc.Case__r.DRCCompletionDate__c == null ? 121 : drcDoc.Case__r.DRCCompletionDate__c.daysBetween(date.today());
                        stage   = drcDoc.Case__r.Stage__c;
                        closed  = drcDoc.Case__r.IsClosed; // true : closed, false : open
    
                        if(stage.equalsIgnoreCase('DRC') && !closed) { allowed = true;  }
                        else if(stage.equalsIgnoreCase('DRC')  && closed  && dayDiff <= 120) { allowed = true;  }
                        else if(stage.equalsIgnoreCase('TRC')  && !closed && dayDiff <= 120) { allowed = true;  }
                        else { allowed = false; }
                        result.put(docId, allowed);
                    }
                }
                when 'TRCDocument__c' {
                    TRCDocument__c trcDoc = (TRCDocument__c)documentsByIdMap.get(docId);
                    if(trcDoc.Case__r != null) {
                        dayDiff = trcDoc.Case__r.TRCCompletionDate__c == null ? 31 : trcDoc.Case__r.TRCCompletionDate__c.daysBetween(date.today());
                        stage   = trcDoc.Case__r.Stage__c;
                        closed  = trcDoc.Case__r.IsClosed; 
    
                        if(stage.equalsIgnoreCase('TRC') && (!closed || !trcDoc.Case__r.Status.equalsIgnoreCase('Closed')))        { allowed = true; }
                        else if((stage.equalsIgnoreCase('NASDA') || stage.equalsIgnoreCase('KASDA')) && !closed && dayDiff <= 30) { allowed = true; }
                        else { allowed = false; }
                        result.put(docId, allowed);
                    }
                }
                when 'NASDADocument__c' {
                    NASDADocument__c nasdaDoc = (NASDADocument__c)documentsByIdMap.get(docId);
                    if(nasdaDoc.Case__r != null) {
                        stage  = nasdaDoc.Case__r.Stage__c;
                        closed = nasdaDoc.Case__r.IsClosed; 
    
                        if(nasdaDoc.Case__r.ClosedDate != null) {
                            //Datetime closedDateTime = nasdaDoc.Case__r.closedDate;
                            //SO-112 Bitna Seong : change closedDate to NASDACompletionDate__c
                            Datetime closedDateTime = nasdaDoc.Case__r.NASDACompletionDate__c;
                            Date closedDate         = date.newInstance(closedDateTime.year(), closedDateTime.month(), closedDateTime.day());
                            dayDiff                 = nasdaDoc.Case__r.ClosedDate == null ? 121 : closedDate.daysBetween(date.today());
                        }
    
                        if((stage.equalsIgnoreCase('NASDA') || stage.equalsIgnoreCase('KASDA')) && !closed)        { allowed = true; }
                        else if((stage.equalsIgnoreCase('NASDA') || stage.equalsIgnoreCase('KASDA')) && closed && dayDiff <= 120) { allowed = true; }
                        else { allowed = false; }
                        result.put(docId, allowed);
                    }

                }
                when else {
                    System.debug('Document ' + docId + ' of type [' + docType + '] could be part of personal library');
                    isPersonalLibraryDocument = true;
                }
            } // switch
            
        }

       return result;
    }

    /**
     * 
     * @param contents 
     * @return         `Map<Id, Map<String,Boolean>>`
     * Used IN  - 
     * 1) ContentVersionTrigger - BEFORE INSERT / BEFORE UPDATE
     * 2) ContentDocuemntTrigger - BEFORE DELETE
     */
    public static Map<Id, Map<String,Boolean>> checkDocAuthorByDocumentId(List<SObject> contents) {

        Map<Id, SObject> documentsByIdMap = getDocumentsByIds(contents);
        if(documentsByIdMap == null){
            System.debug('ContentDocumentUtil/checkDocAuthorByDocumentId INFO:: could not find a related document');
            return new Map<Id, Map<String,Boolean>>();
        }

        System.debug('documentsByIdMap:::'+documentsByIdMap);
        Map<Id, Map<String,Boolean>> checkDocAuthorByDocumentId = new Map<Id, Map<String,Boolean>>();
        Map<String,Boolean> result = new Map<String,Boolean>();

        try {

            for (SObject content : contents) {
                Id documentId       = getDocumentId(content);
                Boolean allowed     = false;
                String documentType = documentId.getSobjectType().getDescribe().getName();
                String stageName;
                String status;
                String devName;
                String phaseName;  // <RRP Project> - Oh, janghun 2024-05-11
                String contentApprovalFlag;   // <RRP Project> - Oh, janghun 2024-06-01
                Boolean isPersonalLibraryDocument = false;

                Boolean hasLRManagerPermission = FeatureManagement.checkPermission('STIL_Lab_Manager');    // STIL Project 240704 - San, Kang
                Boolean hasTestLeadPermission = FeatureManagement.checkPermission('STIL_Test_Lead');    // STIL Project 240704 - San, Kang
 

                Boolean isQualityCase;// <QCMT>[SO-440] / InhoKim / 2024-09-13 
                Boolean hasQualityPermission;// <QCMT>[SO-440] / InhoKim / 2024-09-13 
                Boolean isUnlocked = false;
                //NOTETO: NEED TO CHECK QCMT PERMISSION? 
                
                System.debug('docType SWITCH STARTED :::     '+  documentType  );//@@
                switch on documentType {
                    when 'DADocuments__c' {
                        DADocuments__c document = (DADocuments__c) documentsByIdMap.get(documentId);
                        if(document.Case__r != null) {
                            stageName = document.Case__r.Stage__c;
                            status    = document.Case__r.Status;
                            Boolean checkCaseStage4DADoc = stageName.equalsIgnoreCase('DA'); // [SO-443] Q-CMT-12 History Tracking - InhoKim , Only DA
                            isQualityCase = checkQualityCase(document);
                            //if(! document.Case__r.IsClosed && isQualityCase && document.Case__r.Q_DA_Start_Date__c != null && document.Case__r.Q_DA_Completion_Date__c == null   ) {allowed = true;} // Archived__<QCMT>[SO-440] lock files / InhoKim / 2024-09-13
                            if(! document.Case__r.IsClosed && isQualityCase && hasProperPermWithQualityCase() ) {allowed = true;} // <QCMT>[SO-440] lock files / InhoKim / 2024-09-13
                            else if(! document.Case__r.IsClosed && checkCaseStage4DADoc){allowed = true; }
                            else { allowed = false;}
                            System.debug('1' + String.valueOf(! document.Case__r.IsClosed && isQualityCase && hasProperPermWithQualityCase() ));
                            System.debug('2' + String.valueOf(! document.Case__r.IsClosed && checkCaseStage4DADoc ) );
                            System.debug('3' + String.valueOf(allowed) );
                            System.debug('DADocuments__c allowed :::     '+  allowed  );//@@
                            result.put(documentType, allowed);
                        }
                    }
                    when 'DRCDocument__c' {
                        DRCDocument__c document = (DRCDocument__c) documentsByIdMap.get(documentId);
                        if(document.RecordType.DeveloperName == null) devName = '';
                        else devName = document.RecordType.DeveloperName;
                        if(!devName.equalsIgnoreCase('MeetingDocument')) {
                            stageName               = document.Case__r.Stage__c;
                            status                  = document.Case__r.Status;
                            Integer dayDiff         = document.Case__r.DRCCompletionDate__c == null ? 121 : document.Case__r.DRCCompletionDate__c.daysBetween(date.today());
                            if(stageName.equalsIgnoreCase('DRC') && !document.Case__r.IsClosed) { allowed = true;  }
                            else if(stageName.equalsIgnoreCase('DRC') && document.Case__r.IsClosed  && dayDiff <= 120) { allowed = true;  }
                            else if(stageName.equalsIgnoreCase('TRC') && !document.Case__r.IsClosed && dayDiff <= 120) { allowed = true;  }
                            else { allowed = false; }
                            result.put(documentType, allowed);
                        }
                    }
                    when 'TRCDocument__c' {
                        TRCDocument__c doc = (TRCDocument__c)documentsByIdMap.get(documentId);
                        if(doc.RecordType.DeveloperName == null) devName = '';
                        else devName = doc.RecordType.DeveloperName;
                        if(!devName.equalsIgnoreCase('MeetingDocument')) {
                            Integer dayDiff    = doc.Case__r.TRCCompletionDate__c == null ? 31 : doc.Case__r.TRCCompletionDate__c.daysBetween(date.today());
                            if((doc.Case__r.Stage__c).equalsIgnoreCase('TRC') && (!doc.Case__r.IsClosed || !doc.Case__r.Status.equalsIgnoreCase('Closed'))) { allowed = true; }
                            else if(((doc.Case__r.Stage__c).equalsIgnoreCase('NASDA') || (doc.Case__r.Stage__c).equalsIgnoreCase('KASDA')) && !doc.Case__r.IsClosed && dayDiff <= 30) { allowed = true; }
                            else { allowed = false; }
                            result.put(documentType, allowed);
                        }
                    }
                    when 'NASDADocument__c' {
                        
                        NASDADocument__c doc = (NASDADocument__c) documentsByIdMap.get(documentId);
                        if(doc.RecordType.DeveloperName == null) devName = '';
                        else devName = doc.RecordType.DeveloperName;
                        if(!devName.equalsIgnoreCase('MeetingDocument')) {
                            Integer dayDiff;
                            if(doc.Case__r.ClosedDate != null) {
                                // Datetime closedDateTime = doc.Case__r.closedDate;
                                //SO-112 Bitna Seong : change closedDate to NASDACompletionDate__c
                                Datetime closedDateTime = doc.Case__r.NASDACompletionDate__c;
                                Date closedDate         = date.newInstance(closedDateTime.year(), closedDateTime.month(), closedDateTime.day());
                                dayDiff         = doc.Case__r.ClosedDate == null ? 121 : closedDate.daysBetween(date.today());
                            }
                            if((doc.Case__r.Stage__c.equalsIgnoreCase('NASDA') || doc.Case__r.Stage__c.equalsIgnoreCase('KASDA')) && !doc.Case__r.IsClosed)        { allowed = true; }
                            else if((doc.Case__r.Stage__c.equalsIgnoreCase('NASDA') || doc.Case__r.Stage__c.equalsIgnoreCase('KASDA')) && doc.Case__r.IsClosed && dayDiff <= 120) { allowed = true; }
                            else { allowed = false; }
                            result.put(documentType, allowed);
                        }
                    }
                    //Added for DNA: Start here
                    when 'Package__c' {
                        Package__c doc = (Package__c) documentsByIdMap.get(documentId);
                        if(doc.Status__c != null) {
                            if(doc.Status__c.equalsIgnoreCase('Closed') || doc.Status__c.equalsIgnoreCase('Canceled'))  { allowed = false; }
                            else { allowed = true; }
                            result.put(documentType, allowed);
                        }
                    }
                    when 'PackageElement__c' {
                        PackageElement__c doc = (PackageElement__c) documentsByIdMap.get(documentId);
                        if(doc.Package__r.Status__c != null) {
                            if(doc.Package__r.Status__c.equalsIgnoreCase('Closed') || doc.Package__r.Status__c.equalsIgnoreCase('Canceled'))  { allowed = false; }
                            else { allowed = true; }
                            result.put(documentType, allowed);
                        }
                    }
                    when 'PackageRequest__c' {
                        PackageRequest__c doc = (PackageRequest__c) documentsByIdMap.get(documentId);
                        if(doc.Status__c != null) {
                            if(doc.Status__c.equalsIgnoreCase('DLR Request Submitted') || doc.Status__c.equalsIgnoreCase('DLR Request Approved') || doc.Status__c.equalsIgnoreCase('Cancelled'))  { allowed = false; }
                            else { allowed = true; }
                            result.put(documentType, allowed);
                        }
                    }
                    // <RRP Project> - Oh, janghun 2024-05-11 : For RRP Related Document File Validation
                    when 'RRPDocument__c' {
                        RRPDocument__c document = (RRPDocument__c) documentsByIdMap.get(documentId);
                        if(document.RRP__c != null) {
                            phaseName = document.RRP__r.Phase__c;
                            status    = document.RRP__r.Status__c;
                            contentApprovalFlag = document.RRP__r.Content_Approval_Flag__c;
                            System.debug('contentApprovalFlag ::::::' + contentApprovalFlag);
                            allowed = false;
                            if(!phaseName.equalsIgnoreCase('Closed') && !status.equalsIgnoreCase('Closed') && contentApprovalFlag != 'Submitted') { allowed = true; }
                            result.put(documentType, allowed);
                        }
                    }
                    when 'RRPValidationDocument__c' {
                        RRPValidationDocument__c document = (RRPValidationDocument__c) documentsByIdMap.get(documentId);
                        if(document.RRP__c != null) {
                            phaseName = document.RRP__r.Phase__c;
                            status    = document.RRP__r.Status__c;
                            contentApprovalFlag = document.RRP__r.Content_Approval_Flag__c;
                            allowed = false;
                            if(!phaseName.equalsIgnoreCase('Closed') && !status.equalsIgnoreCase('Closed') && contentApprovalFlag != 'Submitted') { allowed = true; }
                            result.put(documentType, allowed);
                        }
                    }
                    when 'ISEQCDocument__c' {
                        ISEQCDocument__c document = (ISEQCDocument__c) documentsByIdMap.get(documentId);
                        if(document.RRP__c != null) {
                            phaseName = document.RRP__r.Phase__c;
                            status    = document.RRP__r.Status__c;
                            contentApprovalFlag = document.RRP__r.Content_Approval_Flag__c;
                            allowed = false;
                            if(!phaseName.equalsIgnoreCase('Closed') && !status.equalsIgnoreCase('Closed') && contentApprovalFlag != 'Submitted') { allowed = true; }
                            result.put(documentType, allowed);
                        }
                    }
                    // <RRP Project> - Oh, janghun 2024-05-11 : End
                    //End here
                    // <STIL Project> - San, Kang 2024-06-19 : Start
                    when 'STIL_Lab_Request_Secure_Document__c' {
                        STIL_Lab_Request_Secure_Document__c document = (STIL_Lab_Request_Secure_Document__c) documentsByIdMap.get(documentId);
                        String ownerId = String.valueOf(document.Lab_Request__r.OwnerId);
                        String strUserId = '';   // 2024-07-10 STIL Project : To distinguish between the user and the queue
                        if (ownerId.startsWith('005')) { 
                            User userInfo = [SELECT Id, Name FROM User WHERE Id = :ownerId];
                            strUserId = userInfo.Id; 
                        }
                        System.debug(strUserId);
                        String currentUserId = System.UserInfo.getUserId();                        
                        if(document.Lab_Request__c != null) {
                            phaseName = document.Lab_Request__r.Phase__c;
                            status    = document.Lab_Request__r.Status;
                            allowed = false;
                            if(!phaseName.equalsIgnoreCase('Complete') && !status.equalsIgnoreCase('Closed') && ((strUserId == currentUserId && hasTestLeadPermission) || hasLRManagerPermission)) { allowed = true; }
                            // else if (!phaseName.equalsIgnoreCase('Complete') && !status.equalsIgnoreCase('Closed') && (String.valueOf(userInfo.Id) == currentUserId || hasLRManagerPermission)) { allowed = true; }
                            result.put(documentType, allowed);
                        }
                    }
                    when 'STIL_Report_Document__c' {
                        STIL_Report_Document__c document = (STIL_Report_Document__c) documentsByIdMap.get(documentId);
                        String ownerId = String.valueOf(document.Lab_Request__r.OwnerId);
                        String strUserId = '';   // 2024-07-10 STIL Project : To distinguish between the user and the queue
                        if (ownerId.startsWith('005')) { 
                            User userInfo = [SELECT Id, Name FROM User WHERE Id = :ownerId];
                            strUserId = userInfo.Id; 
                        }
                        System.debug(strUserId);
                        String currentUserId = System.UserInfo.getUserId();  
                        if(document.Lab_Request__c != null) {
                            phaseName = document.Lab_Request__r.Phase__c;
                            status    = document.Lab_Request__r.Status;
                            allowed = false;
                            if(!phaseName.equalsIgnoreCase('Complete') && !status.equalsIgnoreCase('Closed') && ((strUserId == currentUserId && hasTestLeadPermission) || hasLRManagerPermission)) { allowed = true; }
                            result.put(documentType, allowed);
                        }
                    }
                    when 'STIL_Request_Document__c' {
                        STIL_Request_Document__c document = (STIL_Request_Document__c) documentsByIdMap.get(documentId);
                        if(document.Lab_Request__c != null) {
                            phaseName = document.Lab_Request__r.Phase__c;
                            status    = document.Lab_Request__r.Status;
                            allowed = false;
                            // if(!phaseName.equalsIgnoreCase('Complete') && !status.equalsIgnoreCase('Closed')) { allowed = true; }
                            result.put(documentType, allowed);
                        }
                    }
                    when 'STIL_Test_Document__c' {
                        STIL_Test_Document__c document = (STIL_Test_Document__c) documentsByIdMap.get(documentId);
                        String ownerId = String.valueOf(document.Lab_Request__r.OwnerId);
                        String strUserId = '';   // 2024-07-10 STIL Project : To distinguish between the user and the queue
                        if (ownerId.startsWith('005')) { 
                            User userInfo = [SELECT Id, Name FROM User WHERE Id = :ownerId];
                            strUserId = userInfo.Id; 
                        }
                        System.debug(strUserId);
                        String currentUserId = System.UserInfo.getUserId();  
                        if(document.Lab_Request__c != null) {
                            phaseName = document.Lab_Request__r.Phase__c;
                            status    = document.Lab_Request__r.Status;
                            allowed = false;
                            if(!phaseName.equalsIgnoreCase('Complete') && !status.equalsIgnoreCase('Closed') && ((strUserId == currentUserId && hasTestLeadPermission) || hasLRManagerPermission)) { allowed = true; }
                            result.put(documentType, allowed);
                        }
                    }
                    // <STIL Project> - San, Kang 2024-06-19 : End

                    // <QCMT>[SO-440] / InhoKim / 2024-09-13 : START
                    when 'Q_DRC_Document__c' {
                        Q_DRC_Document__c document = (Q_DRC_Document__c) documentsByIdMap.get(documentId);
                        isUnlocked = checkIfDocIsUnlocked(document);
                        if(document.Case__c != null) {
                            result.put(documentType, isUnlocked);
                        }
                    }
                    when 'Q_TRC_Document__c' {
                        Q_TRC_Document__c document = (Q_TRC_Document__c) documentsByIdMap.get(documentId);
                        isUnlocked = checkIfDocIsUnlocked(document);
                        if(document.Case__c != null) {
                            result.put(documentType, isUnlocked);
                        }
                    }
                    when 'SCDC_Document__c' {
                        SCDC_Document__c document = (SCDC_Document__c) documentsByIdMap.get(documentId);
                        isUnlocked = checkIfDocIsUnlocked(document);
                        if(document.Case__c != null) {
                            result.put(documentType, isUnlocked);
                        }
                    }
                    // <QCMT>[SO-440] / InhoKim / 2024-09-13 : END

                    when else {
                        System.debug('Document ' + documentId + ' of type [' + documentType + '] could be part of personal library');
                        isPersonalLibraryDocument = true;
                    }
    
                }
                if (!isPersonalLibraryDocument) {
                    checkDocAuthorByDocumentId.put(documentId, result);
                }
                System.debug('checkDocAuthorByDocumentId :::: ' + checkDocAuthorByDocumentId);
            }
        } catch(Exception e) {
            System.debug('==EXCEPTION:::'+ e);
        }
        return checkDocAuthorByDocumentId;
    }// END OF METHOD - checkDocAuthorByDocumentId()


    // the following private variables are to be used as a fallback for unit test only
    @TestVisible
    private static Boolean isAuthorized { get; set; }

    public static Boolean isAuthorizedUser(Id userId, Id profileId) {

        if (Test.isRunningTest() && isAuthorized != null) {
            return isAuthorized;
        }

        // Check if the user is a System Administrator or Integration User
        /**
         * @description : KASO Admin Profile check
         * @author San, Kang : SanKang@autoeveramerica.com | 2023-10-19
         * @ticket no: SO-273
         */
        String profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
        if (profileName.equalsIgnoreCase('System Administrator') || profileName.equalsIgnoreCase('Integration User') || profileName.equalsIgnoreCase('(KASO) System Admin')) {
            return true;
        }

        // Check if the user has 'SC - Safety Admin' Permission Set
        String permissionSetName = 'SC_Safety_Admin';
        Integer hasSCPermissionSet = Database.countQuery('SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name = :permissionSetName');
        return hasSCPermissionSet == 1 ? true : false;
    }

    public static String getDocumentRelatedStage(SObject content) {
        Id documentId = getDocumentId(content);
        if(documentId == null){
            System.debug('getDocumentRelatedStage INFO:: Unknown content');
            return 'Unknown';
        }
        String documentType = documentId.getSobjectType().getDescribe().getName();
        return documentType.substringBefore('Document');
    }
    
      /* 
      * date 03.16.23
    * Added by Soyeon Kim for DPM-4602
    * ContentDocuments attached to Evaluation should be visible to Experience users
    */
     public static Boolean getDocumentRelatedObj(SObject content){
         Id documentId = getDocumentId(content);
         if(documentId == null){
             return false;
         }
         String documentType = documentId.getSobjectType().getDescribe().getName();
         if(documentType == 'Survey_Question__c') return true;
         else return false;
     }

    // ----------------- Private Methods -----------------

    private static Map<Id, SObject> getDocumentsByIds(List<SObject> contents) {
        //System.debug('getDocumentsByIds:: contents:' + JSON.serializePretty(contents));
        Set<Id> DADocumentIds = new Set<Id>();
        Set<Id> DRCDocumentIds = new Set<Id>();
        Set<Id> TRCDocumentIds = new Set<Id>();
        Set<Id> NASDADocumentIds = new Set<Id>();
        // <RRP Project> - Oh, janghun 2024-05-11 : Start
        Set<Id> RRPDocumentIds = new Set<Id>();
        Set<Id> RRPValidationDocumentIds = new Set<Id>();
        Set<Id> ISEQCDocumentIds = new Set<Id>();
        // <RRP Project> - Oh, janghun 2024-05-11 : End
        // <STIL Project> - San, Kang 2024-06-19 : Start
        Set<Id> STILLabReqSecureIds = new Set<Id>();
        Set<Id> STILReportDocIds = new Set<Id>();
        Set<Id> STILRequestDocIds = new Set<Id>();
        Set<Id> STILTestDocIds = new Set<Id>();
        // <STIL Project> - San, Kang 2024-06-19 : End
        
        Set<Id> PackageRequestIds = new Set<Id>();
        Set<Id> PackageElementsIds = new Set<Id>();
        Set<Id> PackageIds = new Set<Id>(); //Added for DNA

        // <QCMT>[SO-440] / InhoKim / 2024-09-13 : START
        // Set<Id> QC_QdaDocumentIds = new Set<Id>();
        Set<Id> QC_QDRCDocumentIds = new Set<Id>();
        Set<Id> QC_QTRCDocumentIds = new Set<Id>();
        Set<Id> QC_SCDCDocumentIds = new Set<Id>();
        // <QCMT>[SO-440] / InhoKim / 2024-09-13 : END     

        Map<Id, SObject> documentsByIdMap = new Map<Id, SObject>();

        for (SObject content : contents) {

            System.debug('================ content : ' + content);
            Id documentId = getDocumentId(content);
            System.debug('getDocumentsByIds:: docId: ' + documentId);

            if(documentId == null){
                return null;
            }

            String docType = documentId.getSobjectType().getDescribe().getName();
            if (docType.equalsIgnoreCase('DADocuments__c')) {
                DADocumentIds.add(documentId);
            } else if (docType.equalsIgnoreCase('DRCDocument__c')) {
                DRCDocumentIds.add(documentId);
            } else if (docType.equalsIgnoreCase('TRCDocument__c')) {
                TRCDocumentIds.add(documentId);
            } else if (docType.equalsIgnoreCase('NASDADocument__c')) {
                NASDADocumentIds.add(documentId);
            
            } else if (docType.equalsIgnoreCase('PackageRequest__c')) {
                PackageRequestIds.add(documentId);
            } else if (docType.equalsIgnoreCase('PackageElement__c')) {
                PackageElementsIds.add(documentId);
            } else if (docType.equalsIgnoreCase('Package__c')) { //Added for DNA
                PackageIds.add(documentId);
            // <RRP Project> - Oh, janghun 2024-05-11 : Start
            } else if (docType.equalsIgnoreCase('RRPDocument__c')) {
                RRPDocumentIds.add(documentId);
            } else if (docType.equalsIgnoreCase('RRPValidationDocument__c')) {
                RRPValidationDocumentIds.add(documentId);
            } else if (docType.equalsIgnoreCase('ISEQCDocument__c')) {
                ISEQCDocumentIds.add(documentId);
            // <RRP Project> - Oh, janghun 2024-05-11 : End
            // <STIL Project> - San, Kang 2024-06-19 : Start
            } else if (docType.equalsIgnoreCase('STIL_Lab_Request_Secure_Document__c')) {
                STILLabReqSecureIds.add(documentId);
            } else if (docType.equalsIgnoreCase('STIL_Report_Document__c')) {
                STILReportDocIds.add(documentId);
            } else if (docType.equalsIgnoreCase('STIL_Request_Document__c')) {
                STILRequestDocIds.add(documentId);
            } else if (docType.equalsIgnoreCase('STIL_Test_Document__c')) {
                STILTestDocIds.add(documentId);
            
            // <STIL Project> - San, Kang 2024-06-19 : End

            // <QCMT>[SO-440] / InhoKim / 2024-09-13 : START   
            // }else if (docType.equalsIgnoreCase('QA')) {
            //     STILLabReqSecureIds.add(documentId);
            } else if (docType.equalsIgnoreCase('Q_DRC_Document__c')) {
                QC_QDRCDocumentIds.add(documentId);
            } else if (docType.equalsIgnoreCase('Q_TRC_Document__c')) {
                QC_QTRCDocumentIds.add(documentId);
            } else if (docType.equalsIgnoreCase('SCDC_Document__c')) {
                QC_SCDCDocumentIds.add(documentId);
            }
            // <QCMT>[SO-440] / InhoKim / 2024-09-13 : END           
        }

        if (DADocumentIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Case__c, Case__r.IsClosed,  Case__r.Status, Case__r.Stage__c, Case__r.QualityCaseConfirmed__c FROM DADocuments__c WHERE Id IN:DADocumentIds]);
        }
        if (DRCDocumentIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Case__c, RecordType.DeveloperName, Case__r.IsClosed, Case__r.ClosedDate, Case__r.Stage__c, Case__r.Status, Case__r.DRCCompletionDate__c FROM DRCDocument__c WHERE Id IN:DRCDocumentIds]);
        }
        if (TRCDocumentIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Case__c, RecordType.DeveloperName, Case__r.IsClosed, Case__r.Stage__c,  Case__r.Status, Case__r.TRCCompletionDate__c FROM TRCDocument__c WHERE Id IN:TRCDocumentIds]);
        }
        if (NASDADocumentIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Case__c, RecordType.DeveloperName, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c, Case__r.NASDACompletionDate__c FROM NASDADocument__c WHERE Id IN:NASDADocumentIds]);
        }
        
        if (PackageRequestIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Status__c, Package__r.Status__c  FROM PackageRequest__c WHERE Id IN:PackageRequestIds]);
        }
        if (PackageElementsIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Package__r.Status__c  FROM PackageElement__c WHERE Id IN:PackageElementsIds]);
        }
        //Added for DNA
        if (PackageIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Status__c  FROM Package__c WHERE Id IN:PackageIds]);
        }
        // <RRP Project> - Oh, janghun 2024-05-11 : Start
        if (RRPDocumentIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, RRP__c, RRP__r.Status__c, RRP__r.Phase__c, RRP__r.Content_Approval_Flag__c FROM RRPDocument__c WHERE Id IN:RRPDocumentIds]);
        }
        if (RRPValidationDocumentIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, RRP__c, RRP__r.Status__c, RRP__r.Phase__c, RRP__r.Content_Approval_Flag__c FROM RRPValidationDocument__c WHERE Id IN:RRPValidationDocumentIds]);
        }
        if (ISEQCDocumentIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, RRP__c, RRP__r.Status__c, RRP__r.Phase__c, RRP__r.Content_Approval_Flag__c FROM ISEQCDocument__c WHERE Id IN:ISEQCDocumentIds]);
        }
        // <RRP Project> - Oh, janghun 2024-05-11 : Start
        // <STIL Project> - San, Kang 2024-06-19 : Start
        if (STILLabReqSecureIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Lab_Request__c, Lab_Request__r.Status, Lab_Request__r.Phase__c, Lab_Request__r.OwnerId FROM STIL_Lab_Request_Secure_Document__c WHERE Id IN:STILLabReqSecureIds]);
        }
        if (STILReportDocIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Lab_Request__c, Lab_Request__r.Status, Lab_Request__r.Phase__c, Lab_Request__r.OwnerId FROM STIL_Report_Document__c WHERE Id IN:STILReportDocIds]);
        }
        if (STILRequestDocIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Lab_Request__c, Lab_Request__r.Status, Lab_Request__r.Phase__c, Lab_Request__r.OwnerId FROM STIL_Request_Document__c WHERE Id IN:STILRequestDocIds]);
        }
        if (STILTestDocIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Lab_Request__c, Lab_Request__r.Status, Lab_Request__r.Phase__c, Lab_Request__r.OwnerId FROM STIL_Test_Document__c WHERE Id IN:STILTestDocIds]);
        }
        // <STIL Project> - San, Kang 2024-06-19 : End

        // <QCMT>[SO-440] / InhoKim / 2024-09-13 : START   
        if (QC_QDRCDocumentIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c, Case__r.Q_DRC_Start_Date__c, Case__r.Q_DRC_Completion_Date__c FROM Q_DRC_Document__c WHERE Id IN:QC_QDRCDocumentIds]);
        }
        if (QC_QTRCDocumentIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c, Case__r.Q_TRC_Start_Date__c, Case__r.Q_TRC_CompletionDate__c FROM Q_TRC_Document__c WHERE Id IN:QC_QTRCDocumentIds]);
        }
        if (QC_SCDCDocumentIds.size() > 0) {
            documentsByIdMap.putAll([SELECT Id, Case__c, Case__r.IsClosed, Case__r.ClosedDate,  Case__r.Status, Case__r.Stage__c, Case__r.SCDC_Start_Date__c, Case__r.SCDC_Completion_Date__c FROM SCDC_Document__c WHERE Id IN:QC_SCDCDocumentIds]);
        }
        // <QCMT>[SO-440] / InhoKim / 2024-09-13 : END   



        System.debug('documentsByIdMap++++++++++'+documentsByIdMap);
        return documentsByIdMap;
    }

    /**
     * Get the document Id from the given contentVersion or contentDocumentLink
     * @param contVersionOrContLink
     * @return related Document's Record Id / sObject Record Id
     */     
    public static Id getDocumentId(SObject contVersionOrContLink) {
        if (contVersionOrContLink instanceof ContentVersion) {
            return ((ContentVersion) contVersionOrContLink).FirstPublishLocationId;
        } else if (contVersionOrContLink instanceof ContentDocumentLink) {
            return ((ContentDocumentLink) contVersionOrContLink).LinkedEntityId;
        }
        throw new UnknownContentTypeException('Unexpected contVersionOrContLink type for SObject ' + contVersionOrContLink.Id);
    }

    /**
     * Check if the document is unlocked
     * @param docRecord
     * @return Boolean
     * ONLY FOR QUALITY CASE's LinkedEntityDocument Collection ['Q_DRC_Document__c','Q_TRC_Document__c','SCDC_Document__c']
     */
    public static Boolean checkIfDocIsUnlocked(SObject docRecord) {
        // IF SUPERUSER - return True. 
        System.debug('checkIfDocIsUnlocked ================ docRecord');
        System.debug(docRecord);
        String currUserProfileName = [SELECT Profile.Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        List<String> superUserProfileNameList = new List<String>{'System Administrator', 'Integration User','(KASO) System Admin' };// no need to chek '(KASO) System Admin' >> need to include KASO ADMIN 09.19. 
        if (superUserProfileNameList.contains(currUserProfileName) && !Test.isRunningTest()) {// TO MAXIMIZE CODE COVERAGE WHEN RUNNING TEST
            return true;
        }
        // IF NORMAL USER
        // A file is LOCKED WHEN RelCase's Status == 'Closed'.
        // A file is UNLOCKED ONLY IF the start date of the phase is not null and the completion date is null.
        Boolean isQualityCase = checkQualityCase(docRecord);
        String query = 'SELECT Id, IsClosed, Stage__c, Status, Q_DRC_Start_Date__c, Q_DRC_Completion_Date__c, Q_TRC_Start_Date__c, Q_TRC_CompletionDate__c, SCDC_Start_Date__c, SCDC_Completion_Date__c FROM Case WHERE Id = :Case__c';
        Id docId = (Id)docRecord.get('Id');String stageName;String status;
        Case relatedCase = Database.queryWithBinds( query, (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(docRecord)) , AccessLevel.SYSTEM_MODE);
        // Case relatedCase = (Case) docRecord.get('Case__r') ?? null;
        System.debug('================ relatedCase');
        System.debug(relatedCase);
        if( relatedCase == null){return false;}
        else{
            stageName = (String)relatedCase.get('Stage__c') ?? '';
            status =  (String)relatedCase.get('Status') ?? '';
        }
        //file edit allowed only during  Case is Open &&  Case has date value in Phase startDT but not completedDT  
        if( docId.getSobjectType().getDescribe().getName().equalsIgnoreCase('Q_DRC_Document__c')) {if( !relatedCase.IsClosed && isQualityCase && hasProperPermWithQualityCase()  ) { return true; }}
        if( docId.getSobjectType().getDescribe().getName().equalsIgnoreCase('Q_TRC_Document__c')) {if( !relatedCase.IsClosed && isQualityCase && hasProperPermWithQualityCase()   ) { return true; }}
        if( docId.getSobjectType().getDescribe().getName().equalsIgnoreCase('SCDC_Document__c')) {if( !relatedCase.IsClosed && isQualityCase && hasProperPermWithQualityCase()    ) { return true; }}
        // if( docId.getSobjectType().getDescribe().getName().equalsIgnoreCase('Q_DRC_Document__c')) {if( !relatedCase.IsClosed && isQualityCase && relatedCase.Q_DRC_Start_Date__c != null && relatedCase.Q_DRC_Completion_Date__c == null  ) { return true; }}//Archived__
        // if( docId.getSobjectType().getDescribe().getName().equalsIgnoreCase('Q_TRC_Document__c')) {if( !relatedCase.IsClosed && isQualityCase && relatedCase.Q_TRC_Start_Date__c != null && relatedCase.Q_TRC_CompletionDate__c == null  ) { return true; }}//Archived__
        // if( docId.getSobjectType().getDescribe().getName().equalsIgnoreCase('SCDC_Document__c')) {if( !relatedCase.IsClosed && isQualityCase && relatedCase.SCDC_Start_Date__c != null && relatedCase.SCDC_Completion_Date__c == null  ) { return true; }}//Archived__
        return false;
    }

    @TestVisible
    private static SCSConfigurationSettings__c safetyConfig { get; set; }
    public static SCSConfigurationSettings__c getSafetyConfigurationSettings() {
        if (SCSConfigurationSettings__c.getOrgDefaults() == null) {
            throw new MissingConfigurationException('Missing required configuration, please contact your system admin. Error: Missing SCSConfigurationSettings');
        }
        if (safetyConfig != null) {
            return safetyConfig;
        }
        safetyConfig = SCSConfigurationSettings__c.getOrgDefaults();
        return safetyConfig;
    }
    /**
     * CHECK IF CURRENT USER HAS PROPER PERMISSION OR IS SUPERUSER to update Quality Case
     * Created : [SO-469] Additional request 9/24 UAT / 24.09.26 / Inho Kim
     * @return  `Boolean`
     */
    private static Boolean hasProperPermWithQualityCase() {
        if (Test.isRunningTest()) {            return true;        }
        try {
            String profName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
            return FeatureManagement.checkPermission('QC_Quality_Quality_Manager') || ( profName.containsIgnoreCase('System Administrator') || profName.containsIgnoreCase('Integration User') || profName.containsIgnoreCase('(KASO) System Admin')    );
        }catch(Exception e){System.debug('hasProperPermWithQualityCase ERROR:::'+ e);return false;}
    }


    /**
     * Check if the Collection Object record such as DA Document record is related to Quality Case
     * Created : [SO-469] Additional request 9/24 UAT / 24.09.26 / Inho Kim
     * @param docRecord 
     * @return          `Boolean`
     */
    private static Boolean checkQualityCase(Sobject docRecord){
        try {
            if( docRecord.get('Case__c') == null){return false;}
            Id relatedCaseId = (Id)docRecord.get('Case__c') ?? null;
            System.debug('=====checkQualityCase');
            System.debug(relatedCaseId); 
            if( relatedCaseId == null){return false;}
            else{ 
                Case relCase = [SELECT QualityCaseConfirmed__c FROM Case WHERE Id =:relatedCaseId LIMIT 1 ];
                String qualityCaseConfirmedStr = relCase.QualityCaseConfirmed__c ?? '';
                return qualityCaseConfirmedStr.equalsIgnoreCase('YES'); 
            }
            // In case of it is null. QualityCaseConfirmed__c can be NULL / 'Yes' / 'No'
        }catch(Exception e){System.debug('checkQualityCase ERROR:::'+ e);return false;}        
    }


    // ----------------- Custom Exceptions -----------------
    public class UnknownContentTypeException extends Exception {
    }
    public class MissingConfigurationException extends Exception {
    }
}