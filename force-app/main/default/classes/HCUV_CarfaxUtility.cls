public class HCUV_CarfaxUtility {

  @TestVisible  private static string getAccessToken(){
        String sAccessToken;
        if(String.isBlank(sAccessToken))
        {
            // added by Hemanth
            Map<String, String> carFaxConfigsMap = new Map<String, String> ();
            
            for(HCUV_CarFax_Configuration__mdt cfs : [SELECT DeveloperName, Value__c FROM HCUV_CarFax_Configuration__mdt]) {
                carFaxConfigsMap.put(cfs.DeveloperName, cfs.Value__c);
            }
            
            Http hCarfax=new Http();
            HttpRequest req=new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint('callout:HCUV_Carfax_Access_Token_API');
            
            String clientId='{!$Credential.UserName}';
            String clientSecret=System.label.CUV_Carfax_Client;
            String payload ='';
            if( String.isNotEmpty(carFaxConfigsMap.get('Client_Secret'))){
                payload = 'client_id=' + clientId
                + '&client_secret=' + Encodingutil.urlEncode(carFaxConfigsMap.get('Client_Secret'),'UTF-8')
                + '&audience=' + carFaxConfigsMap.get('Audience')
                + '&response_type=' + carFaxConfigsMap.get('Response_Type')
                + '&grant_type='+carFaxConfigsMap.get('grant_type') 
                + '&redirect_uri=' + carFaxConfigsMap.get('Redirect_URI');
            }
            System.debug('Payload details-'+payload);
            req.setBody(payload);
            HttpResponse res=hCarfax.send(req);
            System.debug(res.getbody());
            if(res.getstatuscode() == 200)
            {            
                CarFaxAccessToken accessTokenWrapper=(CarFaxAccessToken) JSON.deserialize(res.getbody(),CarFaxAccessToken.class);
                if(accessTokenWrapper.access_token!=null)
                    sAccessToken=accessTokenWrapper.access_token;
            }
        }
        return sAccessToken;
        
    }
    
    public static string getCarfaxVehicalHistory(String vin){
       String vinHistoryLink;
        Http hCarfaxApi=new Http();
        HttpRequest carfaxReq=new HttpRequest();
        carfaxReq.setMethod('GET');
        
        String carFaxAccessToken= getAccessToken();
        carfaxReq.setEndpoint('callout:HCUV_Carfax_GraphQL_API');
        carfaxReq.setHeader('Authorization','Bearer '+carFaxAccessToken);
         carfaxReq.setHeader('Content-Type','application/json');
		carfaxReq.setHeader('Aceept','application/json');
       
        string payload='{"query":"query($icrInput: IcrInput!) {icr(icrInput: $icrInput) {... on IcrAvailable {'+
                                'carfaxLink { '+
                                                'url '+
                                                'iconUrl '+
                                                'valueBadgeAltText '+
                                                'expiresAt {rfc} '+
                                            '}'+
                                'ownerHistory {'+
                                                'oneOwner'+
                                            '}}}}",'+
   '"variables":{'+
    '"icrInput": {'+
        '"vin": "'+vin+'"}}}';
        System.debug(payload);
        carfaxReq.setBody(payload);
        HttpResponse res=hCarfaxApi.send(carfaxReq);
        System.debug(res.getbody());
        if(res.getstatuscode() == 200)
        {    HCUV_CarFaxVehicleHistoryWrapper carFaxVehicleHistory=(HCUV_CarFaxVehicleHistoryWrapper) JSON.deserialize(res.getbody(),HCUV_CarFaxVehicleHistoryWrapper.class);
            System.debug(carFaxVehicleHistory);
            if(carFaxVehicleHistory !=null && carFaxVehicleHistory.data!=null && carFaxVehicleHistory.data.icr !=null 
                && carFaxVehicleHistory.data.icr.carfaxLink!=null &&!String.isEmpty(carFaxVehicleHistory.data.icr.carfaxLink.url))  
            vinHistoryLink = carFaxVehicleHistory.data.icr.carfaxLink.url;  
        } 
        return vinHistoryLink;
    }
    
    Public Class CarFaxAccessToken
    {
        String access_token;
        String expires_in;
        String token_type;
    }

    
}