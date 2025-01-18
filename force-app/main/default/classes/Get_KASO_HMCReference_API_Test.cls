@IsTest
public with sharing class Get_KASO_HMCReference_API_Test {
    

    @TestSetup
    static void setupData(){
        DM1_QM_01_PRJVEHL_D__c objPRJVEHL = new DM1_QM_01_PRJVEHL_D__c();
        objPRJVEHL.ExternelKey__c = 'K6C2A4';
        insert objPRJVEHL;

        DM1_QM_01_QLTYVEHLENG_I__c objQLTYVEHLENG = new DM1_QM_01_QLTYVEHLENG_I__c();
        objQLTYVEHLENG.ExternelKey__c = 'H101WPLM';
        insert objQLTYVEHLENG;

        DM1_QM_01_ENGTYMA_D__c objENGTYMA = new DM1_QM_01_ENGTYMA_D__c();
        objENGTYMA.ExternelKey__c = 'F1';
        insert objENGTYMA;

        DM1_QM_01_QLTYVEHLTM_I__c objQLTYVEHLTM = new DM1_QM_01_QLTYVEHLTM_I__c();
        objQLTYVEHLTM.ExternelKey__c = 'H901H6HTF2M6CF3-1';
        insert objQLTYVEHLTM;

        DM1_QM_07_QLPRCORPPLNT_D__c objQLPRCORPPLNT = new DM1_QM_07_QLPRCORPPLNT_D__c();
        objQLPRCORPPLNT.ExternelKey__c = 'HVX6';
        insert objQLPRCORPPLNT;
    }


//    public static String fake_json1 = '"{\"data\":{\"openApiGlobalCmtPrjVehlDInfos\":[{\"prdnCorpCd\":\"K6C2\",'+
//            '\"stdVehlCd\":\"A4\",\"prjVehlCd\":\"RP\",\"prjVehlNm\":\"CARENS11/12/16\",\"qltyCarTypeCd\":\"V\",\"saleBlndCd\":\"K\",'+
//            '\"ckdScnCd\":\"CKD\"},{\"prdnCorpCd\":\"K6C2\",\"stdVehlCd\":\"A7\",\"prjVehlCd\":\"YD\",\"prjVehlNm\":\"(YD)K3[A7]\",'+
//            '\"qltyCarTypeCd\":\"P\",\"saleBlndCd\":\"K\",\"ckdScnCd\":\"CKD\"}],\"openApiGlobalCmtQltyVehlEngIInfos\":[{\"prdnCorpCd\":\"H101\",'+
//            '\"stdVehlCd\":\"WP\",\"engTymaCd\":\"LM\"},{\"prdnCorpCd\":\"H101\",\"stdVehlCd\":\"WP\",\"engTymaCd\":\"LN\"}],'+
//            '\"openApiGlobalCmtEngTymaDInfos\":[{\"engTymaCd\":\"F1\",\"engScnCd\":\"C\",\"engTymaNm\":\"D4GA(F-ENG14*PS)10EM\"},'+
//            '{\"engTymaCd\":\"F3\",\"engScnCd\":\"C\",\"engTymaNm\":\"D4GA(F-ENG14*PS)\"}],\"openApiGlobalCmtQltyVehlTmIInfos\":[{\"prdnCorpCd\":\"H901\",'+
//            '\"stdVehlCd\":\"H6\",\"tmPrdnPlntCd\":\"HTF2\",\"tmPrjCd\":\"M6CF3-1\"},{\"prdnCorpCd\":\"H101\",\"stdVehlCd\":\"HG\",\"tmPrdnPlntCd\":\"HT11\",'+
//            '\"tmPrjCd\":\"A6LF3\"}],\"openApiGlobalCmtQlPrcCorpPlntDInfos\":[{\"prdnCorpCd\":\"H6C4\",\"plntCd\":\"HVX6\",\"plntTypeCd\":\"V\",'+
//            '\"prdnPlntNm\":\"HCSY\",\"prdnCorpANm\":\"현대대만CKD\"},{\"prdnCorpCd\":\"H101\",\"plntCd\":\"HE11\",\"plntTypeCd\":\"E\",\"prdnPlntNm\":\"HMC\",'+
//            '\"prdnCorpANm\":\"현대자동차\"}]}}"';


    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // You could assert the request content here
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data":{"openApiGlobalCmtPrjVehlDInfos":[{"prdnCorpCd":"K6C2","stdVehlCd":"A4","prjVehlCd":"RP","prjVehlNm":"CARENS11/12/16","qltyCarTypeCd":"V","saleBlndCd":"K","ckdScnCd":"CKD"},{"prdnCorpCd":"K6C2","stdVehlCd":"A7","prjVehlCd":"YD","prjVehlNm":"(YD)K3[A7]","qltyCarTypeCd":"P","saleBlndCd":"K","ckdScnCd":"CKD"}],"openApiGlobalCmtQltyVehlEngIInfos":[{"prdnCorpCd":"H101","stdVehlCd":"WP","engTymaCd":"LM"},{"prdnCorpCd":"H101","stdVehlCd":"WP","engTymaCd":"LN"}],"openApiGlobalCmtEngTymaDInfos":[{"engTymaCd":"F1","engScnCd":"C","engTymaNm":"D4GA(F-ENG14*PS)10EM"},{"engTymaCd":"F3","engScnCd":"C","engTymaNm":"D4GA(F-ENG14*PS)"}],"openApiGlobalCmtQltyVehlTmIInfos":[{"prdnCorpCd":"H901","stdVehlCd":"H6","tmPrdnPlntCd":"HTF2","tmPrjCd":"M6CF3-1"},{"prdnCorpCd":"H101","stdVehlCd":"HG","tmPrdnPlntCd":"HT11","tmPrjCd":"A6LF3"}],"openApiGlobalCmtQlPrcCorpPlntDInfos":[{"prdnCorpCd":"H6C4","plntCd":"HVX6","plntTypeCd":"V","prdnPlntNm":"HCSY","prdnCorpANm":"현대대만CKD"},{"prdnCorpCd":"H101","plntCd":"HE11","plntTypeCd":"E","prdnPlntNm":"HMC","prdnCorpANm":"현대자동차"}]},"message":null,"time":"2023-10-1811:15:21"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void myUnitTest() {
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        Get_KASO_HMCReference_API.Get_KASO_HMCReference_Interface();
        Test.stopTest();
    }

}