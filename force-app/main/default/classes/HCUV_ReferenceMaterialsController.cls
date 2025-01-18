/**
************************************************************************************************
* @classname         : HCUV_ReferenceMaterialsController; being used in lwc hcuvReferenceMaterials
* @description       : Get the Reference Material records
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       18th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
public with sharing class HCUV_ReferenceMaterialsController {

    /**
    * @description - Fetch Reference Materials
    * @param - networkId
    * @return Map<String, Object>
    */
    @AuraEnabled(cacheable=true)      
    public static Map<String, Object> getReferenceMaterials(String networkId) {
        Map<String, Object> dataMap = new Map<String, Object> ();
        List<String> recordTypeList= HCUV_Utility.getRecordTypeList(HCUV_Constants.RM_Object_API_Name, networkId, HCUV_Constants.RM_Type);
        List<HCUV_Reference_Material__c> rfList;
        //soql preparation for HCUV_Reference_Material__c
        String query = 'Select Id, Name, Material_Type__c, Link__c,';
        query += ' (Select ContentDocumentId, ContentDocument.Title,ContentDocument.FileExtension FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate DESC LIMIT 1)';
        query += ' FROM HCUV_Reference_Material__c';
        query += ' WHERE Material_Type__c IN (\'Document\', \'Link\', \'Video\') AND (Start_Date__c <= Today and End_Date__c >= Today) AND Status__c = \''+HCUV_Constants.Status_Published+'\'';
        query += ' AND RecordType.DeveloperName IN:recordTypeList';
        query += ' ORDER BY createddate desc';
        //fetch records
        rfList = Database.query(query);
        dataMap.put('ReferenceMaterials', rfList);
        
        List<String> docIds = new List<String> ();
        
        for(HCUV_Reference_Material__c rf : rfList) {
            if(!rf.ContentDocumentLinks.isEmpty()){
                docIds.add(rf.ContentDocumentLinks[0].ContentDocumentId);
            }
        }
        
        List<ContentDistribution> cdObjList = [select ContentDocumentId, DistributionPublicUrl 
                                               from ContentDistribution where ContentDocumentId IN :docIds];
        
        Map<String, String> docMap = new Map<String, String> ();
        for(ContentDistribution cdObj : cdObjList) {
            docMap.put(cdObj.ContentDocumentId, cdObj.DistributionPublicUrl);
        }
        dataMap.put('DocMap', docMap);
        
        return dataMap;
    }
}