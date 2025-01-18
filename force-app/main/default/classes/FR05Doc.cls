/*
  Author: Hyungsu Kim
  Description : API for retreiving Case record details along with document URL's.
  Add Date: 2022-09-02  Added transfer only files below 100MB to SIMS (jiwon)
*/
@RestResource(urlMapping='/FR05Doc/*')
global with sharing class FR05Doc {
    public static final String API_VERSION = '55.0';
    @HttpPost
    global static void doGet(String caseId, String requestId) {
         RestRequest req = RestContext.request;
         RestResponse res = RestContext.response;
         JSONGenerator gen = JSON.createGenerator(true);
         gen.writeStartObject();

         List<SIMS_Document__c> SIMSDocumentId = [select id from SIMS_Document__c where Folder__c = 'Request' and Case__c = :caseId and Request__c = :requestId ];
         Set<Id> SIMSDocument=new Set<Id>();
         for(SIMS_Document__c c:SIMSDocumentId)
         {
            SIMSDocument.add(c.id);
         }


         /** SIMSDocuments Start **/
         if(!SIMSDocument.isEmpty()){
            List<ContentDocumentLink> VersionDataSIMS = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:SIMSDocument];
            system.debug('data is'+VersionDataSIMS);
            Set<Id> versionSIMS=new Set<Id>();
            for(ContentDocumentLink v:VersionDataSIMS)
            {
               versionSIMS.add(v.ContentDocumentId);
            }
            system.debug('ContentDocumentID of SIMSDocument is'+versionSIMS);

            // Added file size check
            List<ContentVersion> contSIMS = [SELECT Id,ContentUrl,FileExtension,FileType,PathOnClient,ContentSize FROM ContentVersion WHERE ContentDocumentId = :versionSIMS and ContentSize < 104857600];
            Set<Id> contentSizeSIMS = new Set<Id>();
			String instanceURL = System.URL.getSalesforceBaseURL().toExternalForm();
			gen.writeFieldName('SIMS_Files_URLs');
            gen.writeStartArray();
            for(ContentVersion contv : contSIMS){
			String downLoadURL = String.format('{0}/services/data/v{1}/sobjects/ContentVersion/{2}/VersionData', new String[]{ instanceURL, API_VERSION, contv.Id});            
                    
                  //contentSizeSIMS.add(contv.ContentDocumentId);
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
            /*List<ContentDistribution> cv=[select ContentDownloadUrl from ContentDistribution where ContentDocumentId = :contentSizeSIMS];
            List<String> csvFileLines= new List<String>();
            for(ContentDistribution c: cv){
               String FileString =c.ContentDownloadUrl;
               //String FileString= EncodingUtil.base64Encode(FileBody);
               system.debug(FileString);
               csvFileLines.add(FileString);
            }*/
            //gen.writeObjectField('SIMS_Files_URLs',csvFileLines);
         }else {
                gen.writeFieldName('SIMS_Files_URLs');
                gen.writeStartArray();
                gen.writeEndArray();
        }
         /** SIMSDocuments End **/
        
       gen.writeEndObject();
        String jsonStr = gen.getAsString();
        jsonStr = jsonStr.replace('\\"', '"');
        jsonStr = jsonStr.replace('"{', '{');
        jsonStr = jsonStr.replace('}"', '}');
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonStr);
   }
}