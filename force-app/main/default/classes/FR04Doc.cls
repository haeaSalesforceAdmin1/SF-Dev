/*
  Author: Sumanth and Hyungsu Kim
  Description : API for retreiving Case record details along with document URL's.
  Add Date: 2022-09-02  Added transfer only files below 100MB to SIMS (jiwon)
*/
@RestResource(urlMapping='/FR04Doc/*')
global with sharing class FR04Doc {
    public static final String API_VERSION = '55.0';
    @HttpPost
    global static void doGet(String caseId) {
         RestRequest req = RestContext.request;
         RestResponse res = RestContext.response;
         JSONGenerator gen = JSON.createGenerator(true);
         gen.writeStartObject();

         List<DADocuments__c> DADocumentId = [select id from DADocuments__c where Case__c= :caseId];
         Set<Id> daDocument=new Set<Id>();
         for(DADocuments__c c:DADocumentId)
         {
            daDocument.add(c.id);
         }
         system.debug('daDocument id is'+daDocument);
         List<DRCDocument__c> DRCDocumentId = [select id from DRCDocument__c where Case__c= :caseId];
         Set<Id> drcDocument=new Set<Id>();
         for(DRCDocument__c drc:DRCDocumentId)
         {
            drcDocument.add(drc.id);
         }
         system.debug('drcDocument id is'+drcDocument);
         List<TRCDocument__c> TRCDocumentId = [select id from TRCDocument__c where Case__c= :caseId];
         Set<Id> trcDocument=new Set<Id>();
         for(TRCDocument__c trc:TRCDocumentId)
         {
            trcDocument.add(trc.id);
         }
         system.debug('trcDocument id is'+trcDocument);
        List<NASDADocument__c> NASDADocumentId = [select id from NASDADocument__c where Case__c= :caseId];
         Set<Id> nasdaDocument=new Set<Id>();
         for(NASDADocument__c nasda:NASDADocumentId)
         {
            nasdaDocument.add(nasda.id);
         }
         system.debug('nasdaDocument id is'+nasdaDocument);

         /** DADocuments Start **/
         if(!daDocument.isEmpty()){
            List<ContentDocumentLink> VersionDataDA = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:daDocument];
            system.debug('data is'+VersionDataDA);
            Set<Id> versionDA=new Set<Id>();
            for(ContentDocumentLink v:VersionDataDA)
            {
               versionDA.add(v.ContentDocumentId);
            }
            //system.debug('ContentDocumentID of DADocument is'+versionDA);
            // Added file size check
            List<ContentVersion> contDA = [SELECT Id,ContentUrl,FileExtension,FileType,PathOnClient,ContentSize FROM ContentVersion WHERE ContentDocumentId = :versionDA and ContentSize < 104857600];
            Set<Id> contentSizeDA = new Set<Id>();
			List<String> fileLinks= new List<String>();
			String instanceURL = System.URL.getSalesforceBaseURL().toExternalForm();
			gen.writeFieldName('DA_Files_URLs');
            gen.writeStartArray();
            for(ContentVersion contv : contDA){
			String downLoadURL = String.format('{0}/services/data/v{1}/sobjects/ContentVersion/{2}/VersionData', new String[]{ instanceURL, API_VERSION, contv.Id});            
                    //system.debug(downLoadURL);
					//fileLinks.add(downLoadURL);
                  //contentSizeDA.add(contv.ContentDocumentId);
				  if(contv.FileExtension!=null){
				  gen.writeStartObject();
                    gen.writeObjectField('FileExtension', contv.FileExtension);               
                    gen.writeObjectField('FileType', contv.FileType);
                    gen.writeObjectField('PathOnClient', contv.PathOnClient);
                    gen.writeObjectField('ContentSize', contv.ContentSize );
                    gen.writeObjectField('DownLoadURL', downLoadURL );
                    gen.writeEndObject();
					}
            }
                gen.writeEndArray();
            /*List<ContentDistribution> cv = [select ContentDownloadUrl from ContentDistribution where ContentDocumentId = :contentSizeDA];
            List<String> csvFileLines= new List<String>();
            for(ContentDistribution c: cv){
            String FileString =c.ContentDownloadUrl;
            //String FileString= EncodingUtil.base64Encode(FileBody);
            system.debug(FileString);
            csvFileLines.add(FileString);
            }*/
            //gen.writeObjectField('DA_Files_URLs',fileLinks);
         } else {
                gen.writeFieldName('DA_Files_URLs');
                gen.writeStartArray();
                gen.writeEndArray();
        }
         /** DADocuments End **/

         /** DRCDocument Start **/
         if(!drcDocument.isEmpty()){
            List<ContentDocumentLink> VersionDataDRC = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:drcDocument];
            system.debug('data is'+VersionDataDRC);
            Set<Id> versionDRC=new Set<Id>();
            for(ContentDocumentLink v1:VersionDataDRC)
            {
               versionDRC.add(v1.ContentDocumentId);
            }
            //system.debug('ContentDocumentID of DRCDocument is'+versionDRC);

            // add by jiwon
            List<ContentVersion> contDRC = [SELECT Id,ContentUrl,FileExtension,FileType,PathOnClient,ContentSize FROM ContentVersion WHERE ContentDocumentId = :versionDRC and ContentSize < 104857600];
            Set<Id> contentSizeDRC = new Set<Id>();
			List<String> fileLinks= new List<String>();
			String instanceURL = System.URL.getSalesforceBaseURL().toExternalForm();
			gen.writeFieldName('DRC_Files_URLs');
            gen.writeStartArray();
            for(ContentVersion contv : contDRC){
			String downLoadURL = String.format('{0}/services/data/v{1}/sobjects/ContentVersion/{2}/VersionData', new String[]{ instanceURL, API_VERSION, contv.Id});            
                    //system.debug(downLoadURL);
					//fileLinks.add(downLoadURL);
                  //contentSizeDRC.add(contv.ContentDocumentId);
				  if(contv.FileExtension!=null){
				  gen.writeStartObject();
                    gen.writeObjectField('FileExtension', contv.FileExtension);               
                    gen.writeObjectField('FileType', contv.FileType);
                    gen.writeObjectField('PathOnClient', contv.PathOnClient);
                    gen.writeObjectField('ContentSize', contv.ContentSize );
                    gen.writeObjectField('DownLoadURL', downLoadURL );
                    gen.writeEndObject();
					}
            }
           gen.writeEndArray();
           /* List<ContentDistribution> cv1=[select ContentDownloadUrl from ContentDistribution where ContentDocumentId = :contentSizeDRC];
            List<String> csvFileLines1= new List<String>();
            for(ContentDistribution c1: cv1){
               String FileString1 =c1.ContentDownloadUrl;
               //String FileString= EncodingUtil.base64Encode(FileBody);
               system.debug(FileString1);
               csvFileLines1.add(FileString1);
            }  */
            //gen.writeObjectField('DRC_Files_URLs',fileLinks);
        } else {
                gen.writeFieldName('DRC_Files_URLs');
                gen.writeStartArray();
                gen.writeEndArray();
        }
        /** DRCDocument End **/

        /** TRCCDocument Start **/
        if(!trcDocument.isEmpty()){
            List<ContentDocumentLink> VersionDataTRC = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:trcDocument];
            system.debug('data is'+VersionDataTRC);
            Set<Id> versionTRC=new Set<Id>();
            for(ContentDocumentLink v2:VersionDataTRC)
            {
               versionTRC.add(v2.ContentDocumentId);
            }
            system.debug('ContentDocumentID of TRCDocument is'+versionTRC);

            // add by jiwon
            List<ContentVersion> contTRC = [SELECT Id,ContentUrl,FileExtension,FileType,PathOnClient,ContentSize FROM ContentVersion WHERE ContentDocumentId = :versionTRC and ContentSize < 104857600];
            Set<Id> contentSizeTRC = new Set<Id>();
			List<String> fileLinks= new List<String>();
			String instanceURL = System.URL.getSalesforceBaseURL().toExternalForm();
			gen.writeFieldName('TRC_Files_URLs');
            gen.writeStartArray();
            for(ContentVersion contv : contTRC){
			String downLoadURL = String.format('{0}/services/data/v{1}/sobjects/ContentVersion/{2}/VersionData', new String[]{ instanceURL, API_VERSION, contv.Id});            
                    //system.debug(downLoadURL);
					//fileLinks.add(downLoadURL);
                  //contentSizeTRC.add(contv.ContentDocumentId);
				  if(contv.FileExtension!=null){
				  gen.writeStartObject();
                    gen.writeObjectField('FileExtension', contv.FileExtension);               
                    gen.writeObjectField('FileType', contv.FileType);
                    gen.writeObjectField('PathOnClient', contv.PathOnClient);
                    gen.writeObjectField('ContentSize', contv.ContentSize );
                    gen.writeObjectField('DownLoadURL', downLoadURL );
                    gen.writeEndObject();
					}
            }
            gen.writeEndArray();
            /*List<ContentDistribution> cv2=[select ContentDownloadUrl from ContentDistribution where ContentDocumentId = :contentSizeTRC];
            List<String> csvFileLines2= new List<String>();
            for(ContentDistribution c2: cv2){
               String FileString2 =c2.ContentDownloadUrl;
               //String FileString= EncodingUtil.base64Encode(FileBody);
               system.debug(FileString2);
               csvFileLines2.add(FileString2);
            }*/ 
            //gen.writeObjectField('TRC_Files_URLs',fileLinks);

        } else {
                gen.writeFieldName('TRC_Files_URLs');
                gen.writeStartArray();
                gen.writeEndArray();
        }
        /** TRCDocument End **/
        
        /** NASDADocument Start **/
        if(!nasdaDocument.isEmpty()){
            List<ContentDocumentLink> VersionDataNASDA = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:nasdaDocument];
            system.debug('data is'+VersionDataNASDA);
            Set<Id> versionNASDA=new Set<Id>();
            for(ContentDocumentLink v3:VersionDataNASDA)
            {
               versionNASDA.add(v3.ContentDocumentId);
            }
            system.debug('ContentDocumentID of NASDADocument is'+versionNASDA);

            // add by jiwon
            List<ContentVersion> contTRC = [SELECT Id,ContentUrl,FileExtension,FileType,PathOnClient,ContentSize FROM ContentVersion WHERE ContentDocumentId = :versionNASDA and ContentSize < 104857600];
            Set<Id> contentSizeNASDA = new Set<Id>();
			List<String> fileLinks= new List<String>();
			String instanceURL = System.URL.getSalesforceBaseURL().toExternalForm();
			gen.writeFieldName('NASDA_Files_URLs');
            gen.writeStartArray();
            for(ContentVersion contv : contTRC){
			String downLoadURL = String.format('{0}/services/data/v{1}/sobjects/ContentVersion/{2}/VersionData', new String[]{ instanceURL, API_VERSION, contv.Id});            
                    //system.debug(downLoadURL);
					//fileLinks.add(downLoadURL);
                  //contentSizeTRC.add(contv.ContentDocumentId);
				  if(contv.FileExtension!=null){
				  gen.writeStartObject();
                    gen.writeObjectField('FileExtension', contv.FileExtension);               
                    gen.writeObjectField('FileType', contv.FileType);
                    gen.writeObjectField('PathOnClient', contv.PathOnClient);
                    gen.writeObjectField('ContentSize', contv.ContentSize );
                    gen.writeObjectField('DownLoadURL', downLoadURL );
                    gen.writeEndObject();
					}
            }
            gen.writeEndArray();
            /*List<ContentDistribution> cv2=[select ContentDownloadUrl from ContentDistribution where ContentDocumentId = :contentSizeTRC];
            List<String> csvFileLines2= new List<String>();
            for(ContentDistribution c2: cv2){
               String FileString2 =c2.ContentDownloadUrl;
               //String FileString= EncodingUtil.base64Encode(FileBody);
               system.debug(FileString2);
               csvFileLines2.add(FileString2);
            }*/ 
            //gen.writeObjectField('NASDA_Files_URLs',fileLinks);

        } else {
                gen.writeFieldName('NASDA_Files_URLs');
                gen.writeStartArray();
                gen.writeEndArray();
        }
        /** NASDADocument End **/
        
       gen.writeEndObject();
        String jsonStr = gen.getAsString();
        jsonStr = jsonStr.replace('\\"', '"');
        jsonStr = jsonStr.replace('"{', '{');
        jsonStr = jsonStr.replace('}"', '}');
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonStr);
   }
}