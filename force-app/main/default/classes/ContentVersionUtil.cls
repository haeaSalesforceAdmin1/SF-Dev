/**
 * Created by San on 2023-08-08.
 */

 public with sharing class ContentVersionUtil {

    public static final String WriteListString = Label.CMT_Whitelist_File_Extension;
    public static final List<String> WriteList = new List<String>();
    public static final Set<String> CMT_Profile = new Set<String> {'KASO Safety Service Engineer','KASO Safety Service Manager','Safety Service Engineer','Safety Service Manager','Safety Readonly'};
     /**
     * @description :RRP Project 'RRPDocument__c','ISEQCDocument__c','RRPValidationDocument__c'
     * @author San, Kang : SanKang@autoeveramerica.com | 2024-05-01
     */

    public static final Set<String> Check_CMTObj = new Set<String> {'DADocuments__c','DRCDocument__c','TRCDocument__c','NASDADocument__c','SIMS_Document__c','LegalDocument__c','MiscDocument__c'};
    // SO-443 20240910 San, Kang : Q-CMT-12 History Tracking
    public static final Set<String> Check_Q_CMTObj = new Set<String> {'Q_DRC_Document__c','Q_TRC_Document__c','SCDC_Document__c'};
    public static final Set<String> Check_RRPObj = new Set<String> {'RRPDocument__c','ISEQCDocument__c','RRPValidationDocument__c'};
    // STIL Project 2024-06-19 San, Kang : 'STIL_Lab_Request_Secure_Document__c', 'STIL_Report_Document__c', 'STIL_Request_Document__c', 'STIL_Test_Document__c'
    public static final Set<String> Check_LRObj = new Set<String> {'STIL_Lab_Request_Secure_Document__c','STIL_Report_Document__c','STIL_Request_Document__c','STIL_Test_Document__c'};

    /**
     * @description : CheckCMTFileType 
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-08-08
     */
    // public static Boolean CheckCMTFileType(Map<Id,Sobject> newMap) {
    public static Boolean CheckCMTFileType(List<SObject> newList) {
        Boolean result = false; 
        List<ContentVersion> ContentVersionList = (List<ContentVersion>)newList;
        String[] splitStr = WriteListString.split('\\,');
        for(integer i=0; i<splitStr.size(); i++){
            WriteList.add(splitStr[i]);
        }
        System.debug('WriteList'+WriteList);
        String ExtensionName;
        try{
            for(ContentVersion ContentVersionObj :ContentVersionList){
                ExtensionName = ContentVersionObj.PathOnClient.substring(ContentVersionObj.PathOnClient.lastIndexOf('.')+1,ContentVersionObj.PathOnClient.length());
            }
            for(String WriteFile : WriteList){
                if(WriteFile.equalsIgnoreCase(ExtensionName)){
                    result = true;
                }
            }
        }catch(Exception e){
            System.debug('Exception => ' + e);
        }
        System.debug('res'+result);
        return result;
    }

    /**
    * @description : Quip Document Issue
    * @author San, Kang : SanKang@autoeveramerica.com | 2023-10-19
    * @ticket no: SO-273
    */
    public static Boolean CheckContentVersionQuip(List<SObject> newList) {
        Boolean result = false; 
        List<ContentVersion> ContentVersionList = (List<ContentVersion>)newList;
        Set<Id> ExternalDataSourceSet = new Set<Id>();
        List<String> ExternalDataSourceNameList = new List<String>();
        try {
            for(ContentVersion ContentVersionObj :ContentVersionList){
                if(ContentVersionObj.ExternalDataSourceId != null){
                    ExternalDataSourceSet.add(ContentVersionObj.ExternalDataSourceId);
                }
            }
            if(ExternalDataSourceSet.size()>0){
                List<ExternalDataSource> ExternalDataSourceList = [SELECT Id, DeveloperName FROM ExternalDataSource WHERE Id =:ExternalDataSourceSet];
                
                for(ExternalDataSource ExternalDataSourceObj : ExternalDataSourceList){
                    if(ExternalDataSourceObj.DeveloperName.equalsIgnoreCase('Quip')){
                        ExternalDataSourceNameList.add(ExternalDataSourceObj.DeveloperName);
                    }
                }
                if(ExternalDataSourceNameList.size()>0){
                    result = true;
                }
            }
        } catch (Exception e) {
            System.debug('Exception =>' + e);
        }

        return result;
    }

    /**
     * [When querying ContentVersion in the Apex Class, it is queried with user rights, resulting in a null point exception] 
     * Created by [San,Kang] on [24/07/12] for [Ticket OU24-118]
     * Edited by [San,Kang] on [24/07/12] for [Ticket OU24-118]
    */
    // public static String CheckContentVersion(List<ContentVersion> ContentVersionList) {
    //     String result = '';
    //     Id objId;
    //     System.debug('ContentVersionList' + ContentVersionList[0].ContentDocumentId );
    //     List<ContentVersion> VersionUpdateList = [SELECT FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId =:ContentVersionList[0].ContentDocumentId ];
    //     for(ContentVersion ContentVersionObj : VersionUpdateList){
    //         if(ContentVersionObj.FirstPublishLocationId != null){
    //             objId = ContentVersionObj.FirstPublishLocationId;
    //         }
    //     }
    //     System.debug('VersionUpdateList' + objId );
    //     result = (String)objId.getSObjectType().getDescribe().getName();
    //     System.debug('result!!'+result);

    //     return result;
             
    // }

    public static void CheckNotFileType(List<SObject> newList) {

        List<ContentVersion> ContentVersionList = (List<ContentVersion>) newList; 
        for(ContentVersion ContentVersionObj : ContentVersionList){
            ContentVersionObj.addError(Label.File_Format_Error_Message);
        }
    }

    public static Boolean CheckCMTProfile(Id profileId) {
        Boolean result = false;
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        System.debug('profilename :::'+profileName);
        if(CMT_Profile.contains(profileName)){
            result = true;
        }

        return result;
    }

    public static Boolean CheckCMTObj(List<SObject> newList) {
        Boolean result = false;
        try {
            List<ContentVersion> ContentVersionList = (List<ContentVersion>)newList;
            /**
             * [When querying ContentVersion in the Apex Class, it is queried with user rights, resulting in a null point exception] 
             * Created by [San,Kang] on [24/07/12] for [Ticket OU24-118]
             * Edited by [San,Kang] on [24/07/12] for [Ticket OU24-118]
             * Edited by [Inho,Kim] on [24/09/15] for [Ticket SO-440]
             * Edited by [San,Kang] on [24/09/23] for [Ticket SO-466]
            */
            Id objId;
            List<ContentVersion> VersionUpdateList = [SELECT FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId =:ContentVersionList[0].ContentDocumentId ];
            for(ContentVersion ContentVersionObj : VersionUpdateList){
                if(ContentVersionObj.FirstPublishLocationId != null){
                    objId = ContentVersionObj.FirstPublishLocationId;
                }
            }
            String obj = (String)objId.getSObjectType().getDescribe().getName();
            if(Check_CMTObj.contains(obj) || Check_Q_CMTObj.contains(obj) || Check_RRPObj.contains(obj) || Check_LRObj.contains(obj)){
                result = true;
            }
        } catch (Exception e) {
            System.debug('Exception => ' + e);
        }
        return result;
    }


    /**
    * @description : Create contentversion parameter to use CheckGIRCloned method in contentdocumentlink
    * @author San, Kang : SanKang@autoeveramerica.com | 2023-10-19
    * @ticket no: SO-275
    */
    /**
    * @description : Bug Fix - Clone Handler_ Update ContentVersionUtil.apxc Apex Class ( to pass GIR cloned Case)
    * @author Bitna Seong | 2024-01-04
    * @ticket no: SO-317
    */
    public static Boolean CheckDocumentLinkGIRCloned(List<ContentDocumentLink> ContentDocumentLinkList) {
        // List<ContentVersion> ContentVerisonList = new List<ContentVersion>();
        Boolean result = false;
        Id objId = null;

        try{
            for(ContentDocumentLink contentDocumentLink : ContentDocumentLinkList){
                objId = contentDocumentLink.LinkedEntityId;
            }
            if(objId != null || objId != ''){
                String objName = (String)objId.getSObjectType().getDescribe().getName();
                if(String.isNotBlank(objName) && Check_CMTObj.contains(objName)){

                    String SelectQuery = ' SELECT Case__c, Case__r.Is_GIR_Cloned__c  FROM ';
                    String WhereQuery  = ' WHERE Id =:objId ';
                    
                    List<SObject> DocumentObject = Database.query(SelectQuery + objName + WhereQuery);

                    //SO-328 Error when creating TRC Agenda.(NullPoint Exception) by Bitna Seong -start-
                    // if(DocumentObject.size()>0){
                    if(DocumentObject.size()>0 && DocumentObject[0].get('Case__c') != null ){
                    //SO-328 Error when creating TRC Agenda.(NullPoint Exception) by Bitna Seong -end-
                    
                        if(DocumentObject[0].getSobject('Case__r').get('Is_GIR_Cloned__c') == true){
                            result = true;
                        }
                    }
                }
            }
            // ContentVerisonList = [SELECT FirstPublishLocationId, ContentDocumentId  FROM ContentVersion WHERE ContentDocumentId =:ContentDocumentLinkList[0].ContentDocumentId];
        }catch(Exception e){
            System.debug('Exception => ' + e);
        }
        
        return result; 
    }

    /**
    * @description : GIR Cloned Issue
    * @author San, Kang : SanKang@autoeveramerica.com | 2023-10-19
    * @ticket no: SO-275
    */
    public static Boolean CheckGIRCloned(List<ContentVersion> ContentVersionList) {
        Boolean result = false;
        try{
            Id objId = null;
            for(ContentVersion ContentVersionObj : ContentVersionList){
                objId = ContentVersionObj.FirstPublishLocationId;// only new version has this id. 
            }
            if(objId != null){// CMT-469 24-09-25 INHO KIM 
                String objName = (String)objId.getSObjectType().getDescribe().getName();
                if(Check_CMTObj.contains(objName)){
                    
                    String SelectQuery = ' SELECT Case__c FROM ';
                    String WhereQuery  = ' WHERE Id =:objId ';
                    List<SObject> DocumentObject = Database.query(SelectQuery + objName + WhereQuery);
                    if(DocumentObject.size()>0){
                    String Caseid = String.valueOf(DocumentObject[0].get('Case__c'));
                    Case CaseObj = [SELECT Is_GIR_Cloned__c FROM Case WHERE Id =:Caseid];
                    /**
                     * @description : Modifying conditional statement
                     * @author San, Kang : SanKang@autoeveramerica.com | 2023-11-22 ~ 2023 11-22
                     * @ticket no: SO-292
                     */
                    if(CaseObj.Is_GIR_Cloned__c == true){
                        result = CaseObj.Is_GIR_Cloned__c;
                    }
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception => ' + e);
        }
        
        return result; 
    }

    /**
    * @description : Bug Fix - Clone Handler_ Update ContentVersionUtil.apxc Apex Class ( to pass the logic when SDA Case is closed with 'closed with monitoring')
    * @author Bitna Seong | 2024-01-03
    * @ticket no: SO-317
    */
    public static Boolean checkSDACaseClosedWithMonitoring(List<ContentDocumentLink> ContentDocumentLinkList){
        
        Boolean result = false;
        // List<String> collectionNameList = new List<String>{'DADocuments__c', 'DRCDocument__c', 'TRCDocument__c', 'NASDADocument__c', 'LegalDocument__c', 'MiscDocument__c', 'SIMS_Document__c'};

        system.debug('checkSDACaseClosedWithMonitoring ');
        String collectionObjName = (String)ContentDocumentLinkList[0].LinkedEntityId.getSObjectType().getDescribe().getName();
        Id collectionObjId = ContentDocumentLinkList[0].LinkedEntityId;

        if(String.isNotBlank(collectionObjName) && Check_CMTObj.contains(collectionObjName)){
            String selectQuery = ' SELECT Case__c, Case__r.Stage__c, Case__r.Status, Case__r.NASDA_Decision__c FROM ';
            String whereQuery = ' WHERE Id =:collectionObjId ';
            List<SObject> DocumentObject = Database.query(selectQuery + collectionObjName + whereQuery);
    
            //SO-328 Error when creating TRC Agenda.(NullPoint Exception) by Bitna Seong -start-
            //if(DocumentObject.size()>0 ){
            if(DocumentObject.size()>0 && DocumentObject[0].get('Case__c') != null ){
            //SO-328 Error when creating TRC Agenda.(NullPoint Exception) by Bitna Seong -end-

                String casePhase = String.valueOf(DocumentObject[0].getSobject('Case__r').get('Stage__c'));
                String caseStatus = String.valueOf(DocumentObject[0].getSobject('Case__r').get('Status'));
                String caseSDADecision = String.valueOf(DocumentObject[0].getSobject('Case__r').get('NASDA_Decision__c'));
    
                if(casePhase == 'DRC' && caseStatus == 'Open' && caseSDADecision == 'Closed with monitoring' ) result = true;
            }
        }


        system.debug('checkSDACaseClosedWithMonitoring result : ' + result);

        return result;
    }
}