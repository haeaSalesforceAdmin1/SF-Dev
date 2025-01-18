/**
     * [Class Description] COPP Project - To display the copp files 
     * Created by [Minhee Kim] on [2024-10-29] for [DPM-5893]
    */
    
public without sharing class COPPFileComponentController {


    //Retrieves the copp infos to be displayed in the LWC
    @AuraEnabled(cacheable=false)
    public static String getCOPPInfos(String accountId) {
        System.debug('PackageId:: ' + accountId );
        List<COPPInfoWrapper> coppInfoWrappers = new List<COPPInfoWrapper>();

        List<COPPInfo__c> coppInfos;

        coppInfos = [
                    SELECT
                            Id,
                            DealerCode__c,
                            Last_Saved_Time__c,
                            (
                            SELECT
                                    Id,
                                    ContentDocumentId,
                                    ContentDocument.Title
                            FROM ContentDocumentLinks
                            LIMIT 1000
                    )
                    FROM COPPInfo__c
                    WHERE Account__c = :accountId
            ];
        

        //Generate wrapper records
        for (COPPInfo__c ci : coppInfos) {
            System.debug('record:: ' + JSON.serializePretty(ci));

            COPPInfoWrapper COPPInfoWrapper = new COPPInfoWrapper();
            COPPInfoWrapper.Id = ci.Id;
            COPPInfoWrapper.DealerCode = ci.DealerCode__c;
            COPPInfoWrapper.strAttachmentCountDisplay = ci.ContentDocumentLinks != null && ci.ContentDocumentLinks.size() > 0 ? '(' + ci.ContentDocumentLinks.size() + ')': '';
            COPPInfoWrapper.LastmodifiedDate = ci.Last_Saved_Time__c;
            coppInfoWrappers.add(COPPInfoWrapper);
        }

        return JSON.serialize(coppInfoWrappers);
    }


    // ---------------- Wrapper Classes ----------------
    public class COPPInfoWrapper {
        public Id Id;
        public String DealerCode;
        public DateTime LastmodifiedDate;
        public String strAttachmentCountDisplay;

    }
}