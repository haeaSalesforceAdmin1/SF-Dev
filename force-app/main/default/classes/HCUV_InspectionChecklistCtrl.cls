public class HCUV_InspectionChecklistCtrl {
    public string TOKEN;
    public static string getAccessToken(String vin, String dealerCode,String refererURL, String communityName){
        String sAccessToken; 
        String accessType = '';
        if(communityName == HCUV_Constants.HMA_COMMUNITY_NAME) {
            accessType = 'callout:HCUV_Inspection_CheckList_Access_Token';
        }
        else if(communityName == HCUV_Constants.GMA_COMMUNITY_NAME) {
            accessType = 'callout:HCUV_GMA_Inspection_CheckList_Access_Token';
        }
        Http hInspection=new Http();
        HttpRequest req=new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(accessType);
        req.setHeader('Referer', refererURL);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        String user_id='gitadev';
        String payload ='{"VIN_NO":"'+vin+'","DEALER_CODE":"'+ dealerCode+'","USER_ID": "'+user_id+'"}';
        
        req.setBody(payload);
        HttpResponse res=hInspection.send(req);
        InspectionCheckListAccessToken hic = new InspectionCheckListAccessToken();
        if(res.getstatuscode() == 200){ 
            hic = parse(res.getBody());
            sAccessToken= hic.TOKEN;
        }
        return sAccessToken;
    }
    
    @AuraEnabled
    public static String getInspectionChecklistURL(String invId,String communityUrl){
        String result = '';
        String hmaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HCUV_Constants.HMA_Account_RecType).getRecordTypeId();
        String gmaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HCUV_Constants.GMA_Account_RecType).getRecordTypeId();
        
        HCUV_Inventory__c invRecord= [Select Id, Name, Dealer_Code__c, Dealer__r.RecordTypeId from HCUV_Inventory__c Where Id=:invId];
        communityUrl=String.isNotBlank(communityUrl)?URL.getOrgDomainURL().toExternalForm():communityUrl;
        
        String communityName= HCUV_Utility.getCommunityName(Network.getNetworkId());
        if(communityName == HCUV_Constants.HMA_COMMUNITY_NAME || invRecord.Dealer__r.RecordTypeId==hmaRecordTypeId){
            String response = getAccessToken(invRecord.Name, invRecord.Dealer_Code__c,communityUrl, HCUV_Constants.HMA_COMMUNITY_NAME);
            result= System.Label.HCUV_HMA_Service+'?'+System.Label.HCUV_Token+'='+response;
        }
        else if(communityName == HCUV_Constants.GMA_COMMUNITY_NAME || invRecord.Dealer__r.RecordTypeId==gmaRecordTypeId){
            String response = getAccessToken(invRecord.Name, invRecord.Dealer_Code__c,communityUrl, HCUV_Constants.GMA_COMMUNITY_NAME);
            result= System.Label.HCUV_GMA_Service +'?'+System.Label.HCUV_Token+'='+response;           
        }
        return result;
    }
    
    @AuraEnabled
    public static String getInspectionChecklistQA(String invId,String communityUrl){
        String result = '';
        String hmaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HCUV_Constants.HMA_Account_RecType).getRecordTypeId();
        String gmaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HCUV_Constants.GMA_Account_RecType).getRecordTypeId();
        
        HCUV_Inventory__c invRecord= [Select Id, Name, Dealer_Code__c, StatusDescription__c, Dealer__c, Dealer__r.RecordTypeId from HCUV_Inventory__c Where Id=:invId];
        if(invRecord.StatusDescription__c == System.Label.HCUV_Active_Inventory || invRecord.StatusDescription__c == System.Label.HCUV_AgedInventory){
            
            String communityName= HCUV_Utility.getCommunityName(Network.getNetworkId());
            
            if(String.isNotBlank(invRecord.Dealer__c)){
                if(invRecord.Dealer__r.RecordTypeId==hmaRecordTypeId){
                    String response = getAccessToken(invRecord.Name, invRecord.Dealer_Code__c,communityUrl, HCUV_Constants.HMA_COMMUNITY_NAME);
                    result= System.Label.HCUV_HMA_Service+'?'+System.Label.HCUV_Token+'='+response;
                }
                else if(invRecord.Dealer__r.RecordTypeId==gmaRecordTypeId){
                    String response = getAccessToken(invRecord.Name, invRecord.Dealer_Code__c,communityUrl, HCUV_Constants.GMA_COMMUNITY_NAME);
                    result= System.Label.HCUV_GMA_Service +'?'+System.Label.HCUV_Token+'='+response;
                }
            }
            else if(communityName == HCUV_Constants.HMA_COMMUNITY_NAME){
                String response = getAccessToken(invRecord.Name, invRecord.Dealer_Code__c,communityUrl, HCUV_Constants.HMA_COMMUNITY_NAME);
                result= System.Label.HCUV_HMA_Service+'?'+System.Label.HCUV_Token+'='+response;
            }
            else if(communityName == HCUV_Constants.GMA_COMMUNITY_NAME){
                String response = getAccessToken(invRecord.Name, invRecord.Dealer_Code__c,communityUrl, HCUV_Constants.GMA_COMMUNITY_NAME);
                result= System.Label.HCUV_GMA_Service +'?'+System.Label.HCUV_Token+'='+response;
            }
        }
        else{
            throw new AuraHandledException(System.Label.HCUV_Invalid_InspectionCheck_Status);
        }
        
        return result;
    }
    public static InspectionCheckListAccessToken parse(String json) {
        return (InspectionCheckListAccessToken) System.JSON.deserialize(json, InspectionCheckListAccessToken.class);
    }
    
    Public Class InspectionCheckListAccessToken
    {
        String TOKEN;
        String EXPIRES;
    }
    
}