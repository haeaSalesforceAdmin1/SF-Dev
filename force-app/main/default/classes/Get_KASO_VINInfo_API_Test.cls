@IsTest
public with sharing class Get_KASO_VINInfo_API_Test {

    private static String fake_json1 = '{\"data\":[{\"vin\" : \"KMHJF31MPRU591672\",'+
                            '\"prdnDt\" : \"19931213\",'+
                            '\"saleDt\" : \"20201001\",'+
                            '\"natNm\" : \"S.Korea\",'+
                            '\"saleNatNm\" : \"Germany\",'+
                            '\"prjVehlCd\" : \"@\",'+
                            '\"trimPlntCd\" : \"3\",'+
                            '\"drivetrainDesc\" : \" \",'+
                            '\"plant\" : null,'+
                            '\"stdVehlNm\" : null,'+
                            '\"drivetrainCd\" : \" \",'+
                            '\"engScnCd\" : \"@\",'+
                            '\"mdyY\" : \"2024 YEAR\",'+
                            '\"saleBlndCd\" : null,'+
                            '\"transmissionCd\" : \"@\",'+
                            '\"tmPrjCd\" : \"@\",'+
                            '\"engTymaCd\" : \"28@\",'+
                            '\"pqmsEngNm\" : null,'+
                            '\"engNo\" : \"@\",'+
                            '\"saleNatCd\" : \"C07\",'+
                            '\"engTymaNm\" : null,'+
                            '\"vehicleModel\" : null}]}';
    
    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // You could assert the request content here
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fake_json1);
            res.setStatusCode(200);
            System.debug('res:'+res);
            return res;
        }
    }

    private static String fake_Json2 = '\"data\":[{\"vin\" : \"KMHJF31MPRU591672\",'+
                            '\"prdnDt\" : \"19931213\",'+
                            '\"saleDt\" : \"20201001\",'+
                            '\"natNm\" : \"S.Korea\",'+
                            '\"saleNatNm\" : \"Germany\",'+
                            '\"prjVehlCd\" : \"@\",'+
                            '\"trimPlntCd\" : \"3\",'+
                            '\"drivetrainDesc\" : \" \",'+
                            '\"plant\" : null,'+
                            '\"stdVehlNm\" : null,'+
                            '\"drivetrainCd\" : \" \",'+
                            '\"engScnCd\" : \"@\",'+
                            '\"mdyY\" : \"2024 YEAR\",'+
                            '\"saleBlndCd\" : null,'+
                            '\"transmissionCd\" : \"@\",'+
                            '\"tmPrjCd\" : \"@\",'+
                            '\"engTymaCd\" : \"28@\",'+
                            '\"pqmsEngNm\" : null,'+
                            '\"engNo\" : \"@\",'+
                            '\"saleNatCd\" : \"C07\",'+
                            '\"engTymaNm\" : null,'+
                            '\"vehicleModel\" : null}]';
    
    private class Mock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // You could assert the request content here
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fake_json2);
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static void myUnitTest() {

        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        Get_KASO_VINInfo_API.Get_KASO_VINInfo('KMHJF31MPRU591672');
        Test.stopTest();
    }
}