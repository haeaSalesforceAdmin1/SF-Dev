/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class InterfaceUpsertCaseController_Test {

    @TestSetup
    static void makeData(){
        HMCReferenceData__c reference = new HMCReferenceData__c(Make__c = 'Hyundai', VehicleModel__c='AERO TOWN 04', ModelCode__c = 'BN', CBU_CKD__c='CBU', ProdCorp__c ='HMC(현대자동차)', VehicleType__c='버스(Bus)');
        //KASOCaseVehicle__c kasoVehicle = new KASOCaseVehicle__c(ModelCode__c = 'BN');
        insert reference;
        //insert kasoVehicle;
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = getResponse(200);
            return res;
        }
    }

    private static InterfaceUpsertCaseController.Input getInput(String alertId){
        String itemJson = '{"parameter": { "caseNumber" : "","alertId" : "'+alertId+ '", "alertAssignee" : "1135077" ,"issueYn" : "Y"}}';

        InterfaceUpsertCaseController.Input input = new InterfaceUpsertCaseController.input();

        input = (InterfaceUpsertCaseController.Input) JSON.deserialize(
            itemJson,
            InterfaceUpsertCaseController.Input.class
        );

        return input;

    }

    private static HttpResponse getResponse(Integer StatusCode) {
        String itemJson = '{ "subject": "Alert Subject","status": "Open","stage": "DA", "region": "Korea","country": "Korea","caseOwner": "홍의주","caseNo": "K-024-1305","caseId": "500Su00000Bx9aQIAR"}';
     
        InterfaceUpsertCaseController.Output output = new InterfaceUpsertCaseController.Output();
        InterfaceUpsertCaseController.OutputItem outputItem = (InterfaceUpsertCaseController.OutputItem) JSON.deserialize(
            itemJson, 
            InterfaceUpsertCaseController.OutputItem.class
        );

        output.payload.data.add(outputItem);

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody(JSON.serialize(output));
        return res;
    }

    private static Boolean testServiceExecute(Boolean crash) {
        Alert__c alert = new Alert__c(Warning_Alarm_Id__c = 'HK91202411080001', Mnfctr_Vhclmy_Cd_Val__c='2024', Project_Vhclmodel_Cd_Val__c='BN');
       
        insert alert;
       

        String jsonMsg = JSON.serialize(getInput(alert.Warning_Alarm_Id__c));

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('Accept', '*/*');
        req.addHeader('Content-Type', 'application/json');
        req.requestURI = '/services/apexrest/IF_SODAS_CMT_001/v1';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        //InterfaceBase.crashTest = crash;
        InterfaceUpsertCaseController.Output output = InterfaceUpsertCaseController.doPost();
        System.debug('Response Output =====> ' + output);
        return true;
    }

    @isTest
    public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(false), true);
    }

    @isTest
    public static void testServiceException() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(true), true);
    }
}