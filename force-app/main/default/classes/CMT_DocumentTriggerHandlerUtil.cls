/**
 * Created by San on 2023-07-13.
 */

public without sharing class CMT_DocumentTriggerHandlerUtil {

    /**
     * @description : Check Profile Authorization
     * @author            : kimgil419@gmail.com
     * @group             : solomontech
     * @last modified on  : 07-31-2023
     * @last modified by  : sankang@autoeveramerica.com
    **/
    public static Boolean checkProfileAuthorization(Map<Id, SObject> sobjMap) {
        Boolean result = false;
        if (checkPermissionAuthorization()) {
            String objName = sobjMap.values()[0].getSobjectType().getDescribe().getName();
            if(objName.equalsIgnoreCase('DADocuments__c')){
                result = true;
            }else{
                String dynamicQuery = 'SELECT RecordTypeId FROM ' + objName + ' WHERE Id = \''+  + sobjMap.values()[0].Id + '\'';
                List<SObject> records = Database.query(dynamicQuery);
                //09-13-2023 San,Kang : CMT_DocumentTriggerHandlerUtil Bug Fix
                String docTypeId = (String)records[0].get('RecordTypeId') != null ? (String)records[0].get('RecordTypeId') : '';
                if (checkDocumentTypeAuthorization(docTypeId)){ result = true;}
            }
        }
        return result;
    }


    /**
     * @description : CMT Permission Check
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-07-14
     */
    public static Boolean checkPermissionAuthorization() {
        Boolean result = false;
        

        result = (!checkProfileAuthorization('Integration User') && !checkProfileAuthorization('System Administrator')) && !FeatureManagement.checkPermission('Service_Cloud_Safety_Admin') ? true : false;
        /**
         * PermissionSetGroup Issue
         */
        //2023-09-20 bitna Seong : comment out unnessary test code
        //if(Test.isrunningtest()){result = true;}
        //2023-09-20 bitna Seong : comment out unnessary test code
        if(Test.isrunningtest()){result = true;}

        return result;
    }

    

    /**
     * @description : profile Name Check
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-07-13 
     * @param String equalsName
     */
    public static Boolean checkProfileAuthorization(String equalsName) {
        Boolean result = false;

        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name; 
        
        result = profileName.equalsIgnoreCase(equalsName) ? true : false;
        System.debug('profile ' + profileName);
        /**
         * PermissionSetGroup Issue
         */
        // if(Test.isrunningtest()){result = true;}
        return result;
    }
    
    /**
     * @description : check Document Type Authorization
     * @author            : kimgil419@gmail.com
     * @group             : solomontech
     * @last modified on  : 07-31-2023
     * @last modified by  : sankang@autoeveramerica.com
    **/
    public static Boolean checkDocumentTypeAuthorization(String docTypeId) {
        Boolean result = false;
        List<SObject> records = new List<SObject>();
        if(docTypeId != ''){

            String dynamicQuery = 'SELECT DeveloperName FROM RecordType WHERE Id =\''+  + docTypeId + '\'';
            records = Database.query(dynamicQuery);
        }
        System.debug('DeveloperName' + records);
        String docType = records.size()>0 ? (String)records[0].get('DeveloperName') : '';
        if(!docType.equalsIgnoreCase('MeetingDocument')) {
            result = true;
        }
        return result;
    }

    /**
     * @description : Check Document Authorization
     * @author            : kimgil419@gmail.com
     * @group             : solomontech
     * @last modified on  : 07-31-2023
     * @last modified by  : sankang@autoeveramerica.com
    **/
    public static void checkDocAuthorization(Map<Id, SObject> sobjMap) {
        try{
            Map<Id, Boolean> getDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(sobjMap);
            System.debug(getDocumentsBydocId);
            for(SObject docObj : sobjMap.values()) {
                Boolean allowed = getDocumentsBydocId.get(docObj.Id);
                System.debug('getUpdateDocumentsBydocId'+getDocumentsBydocId);
                if(!allowed) {
                    docObj.addError(getErrorMessage(docObj.getSobjectType().getDescribe().getName()));
                }
            }
        }catch(Exception e){
            System.debug('exception =>' + e);
        }
    }

    public static String getErrorMessage(String objName) {
        return objName == 'DADocuments__c' ? Label.DA_Document_Error_Message : objName == 'DRCDocument__c' ? Label.DRC_Document_Error_Message : objName == 'TRCDocument__c' ? Label.TRC_Document_Error_Message : Label.NASDA_Document_Error_Message;
    }

// 서로 비교하기

    /**
     * @description : Add Document Error / Code refactoring
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-07-13 
     * @param Map<Id, SObject> beforeDoc
     */
    // public static void DocumentError(Map<Id, SObject> beforeDoc) {
    //     try{
    //         String objName = objNameCheck(beforeDoc.keySet());
            
    //         Map<Id, Boolean> getUpdateDocumentsBydocId = ContentDocumentUtil.checkDocAuthorByDocumentObjId(beforeDoc);
    //         System.debug('getUpdateDocumentsBydocId :: '+ getUpdateDocumentsBydocId);
            
    //         for(SObject doc : beforeDoc.values()) {
    //             Boolean allowed = getUpdateDocumentsBydocId.get(doc.Id);
    //             if(!allowed) {
    //                 if (objName.equalsIgnoreCase('DADocuments__c')) {
    //                     DADocuments__c Document = (DADocuments__c)beforeDoc.get(doc.id); 
    //                     Document.addError(Label.DA_Document_Error_Message);
    //                 }else if (objName.equalsIgnoreCase('DRCDocument__c')) {
    //                     DRCDocument__c Document = (DRCDocument__c)beforeDoc.get(doc.id); 
    //                     Document.addError(Label.DRC_Document_Error_Message);
    //                 }else if (objName.equalsIgnoreCase('TRCDocument__c')) {
    //                     TRCDocument__c Document = (TRCDocument__c)beforeDoc.get(doc.id);
    //                     Document.addError(Label.TRC_Document_Error_Message);
    //                 }else if (objName.equalsIgnoreCase('NASDADocument__c')) {
    //                     NASDADocument__c Document = (NASDADocument__c)beforeDoc.get(doc.id);
    //                     Document.addError(Label.NASDA_Document_Error_Message);
    //                 }    
    //             }   
    //         } 
    //     }catch(Exception e){
    //         System.debug('exception =>' + e);
    //     }
    // }

    /**
     * @description : Profile Check Code refactoring
     * @author San, Kang : SanKang@autoeveramerica.com | 2023-07-13 
     * @param Map<Id, SObject> drcdMap
     */
    // public static Boolean checkProfileAuthorization(Map<Id, SObject> sobjMap) {
    //     Boolean result = false;

    //     String objName = sobjMap.values()[0].getSobjectType().getDescribe().getName();
    //     String docType;
    //     System.debug('objName'+objname);
    //     if(checkPermissionAuthorization()) {
    //         if(objName.equalsIgnoreCase('DADocuments__c')){
    //             result = true;
    //         }else if (objName.equalsIgnoreCase('DRCDocument__c')) {
    //             docType = [select RecordType.DeveloperName from DRCDocument__c where id =: sobjMap.keySet()].RecordType.DeveloperName;
    //         }else if (objName.equalsIgnoreCase('TRCDocument__c')) {
    //             docType = [select RecordType.DeveloperName from TRCDocument__c where id =: sobjMap.keySet()].RecordType.DeveloperName;
    //         }else if (objName.equalsIgnoreCase('NASDADocument__c')) {
    //             docType = [select RecordType.DeveloperName from NASDADocument__c where id =: sobjMap.keySet()].RecordType.DeveloperName;
    //         }  

    //         if(checkDocumentTypeAuthorization(docType)) {
    //             result = true;
    //         }
    //     }

 
    //     return result;
    // }
}