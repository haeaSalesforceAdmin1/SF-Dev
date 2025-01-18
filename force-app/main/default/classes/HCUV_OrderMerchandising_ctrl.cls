/**
************************************************************************************************
* @classname         : HCUV_OrderMerchandising_ctrl; being used in lwc hcuvordermerchandisingmaterial 
* @description       : Get the Merchandising material
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       21st Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
public with sharing class HCUV_OrderMerchandising_ctrl {
    /**
    * @description - Fetch Refrence Material records for Order Merchandising based on community
    * @param - networkId
    * @return reference material
    */
    @AuraEnabled(cacheable=true)   
    public static Map<String, Object> getOrderMerchandising(String networkId) {
        Map<String, Object> dataMap = new Map<String, Object> ();
        List<String> recordTypeList= HCUV_Utility.getRecordTypeList(HCUV_Constants.RM_Object_API_Name, networkId, HCUV_Constants.OM_Type);        
        String query = 'Select Id, Name, Material_Type__c, Link__c,';
        query += ' (Select ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate DESC LIMIT 1)';
        query += ' FROM HCUV_Reference_Material__c';
        query += ' WHERE (Start_Date__c <= Today and End_Date__c >= Today) AND Status__c = \''+HCUV_Constants.Status_Published+'\'';        
        query += ' AND RecordType.DeveloperName IN:recordTypeList';
        query += ' ORDER BY createddate desc';
        List<HCUV_Reference_Material__c> rfList = Database.query(query);
        
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