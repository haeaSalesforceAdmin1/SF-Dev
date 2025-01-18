/**
************************************************************************************************
* @classname         : HCUV_InspectionChecklistMockup; being used for Mock response
* @description       : Mock Class for HCUV_InspectionChecklistCtrl
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       24th Sep 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
global class HCUV_InspectionChecklistMockup implements HttpCalloutMock{
    /**
    * @description - Implement this interface method to create the mock response
    * @param - request
    * @return HTTPResponse
    */
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        String accessToken = '{"TOKEN": "successfully done" }';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(accessToken);
        response.setStatusCode(200);
        return response;
   
    }
}