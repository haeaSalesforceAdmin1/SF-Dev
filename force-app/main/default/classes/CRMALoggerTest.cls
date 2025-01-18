@IsTest
private class CRMALoggerTest {

    @isTest
    private static void TestPost() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/CRMALogger';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        //DPM-5934 added dealerCode by MinheeKim - 12.04.2024
        req.requestBody = Blob.valueOf('{"interactionType":"Goodbye Stranger its been nice", "interaction":"Hope you find your Paradise", "interactionDetail":"Tried to see your point of view", "interactionMetric":"Hope your dreams will all come true", "dealerCode" : "DE001"}');
        RestContext.request = req;
        string sResult = CRMALogger.logCRMAInteraction();
        string sExpected = '{"metadata":{"strings":["all"],"numbers":["Log"],"groups":[]},"data":[{"Log":1,"all":"all"}]}';
        System.assertEquals(sExpected, sResult, 'CRMALoggerTest.TestPost - sResult is incorrect');
        List<CRMALog__c> listLog = [SELECT Id, Name, Interaction_Type__c, Interaction_Value__c, Interaction_Detail__c, Interaction_Metric__c FROM CRMALog__c];
        System.assert(listLog.size()>0, 'CRMALoggerTest.TestPost - listLog is empty');
        if(listLog.size()>0) {
            System.assertEquals('Goodbye Stranger its been nice', listLog[0].Interaction_Type__c, 'CRMALoggerTest.TestPost - listLog[0].Interaction_Type__c is incorrect');
            System.assertEquals('Hope you find your Paradise', listLog[0].Interaction_Value__c, 'CRMALoggerTest.TestPost - listLog[0].Interaction_Value__c is incorrect');
            System.assertEquals('Tried to see your point of view', listLog[0].Interaction_Detail__c, 'CRMALoggerTest.TestPost - listLog[0].Interaction_Detail__c is incorrect');
            System.assertEquals('Hope your dreams will all come true', listLog[0].Interaction_Metric__c, 'CRMALoggerTest.TestPost - listLog[0].Interaction_Metric__c is incorrect');
        }
    }
    
    @isTest
    private static void TestPostException() {
        string sException = CRMALogger.logCRMAInteraction();
        System.assertEquals('', sException, 'CRMALoggerTest.TestPostException - sException should be empty string');
    }

    @isTest
    static void testFetchLogRecord() {
        String interactionType = 'Community';
        String interaction = 'CUV';
        String interactionDetail = 'Hyundai Select Used - Home';
        String interactionMetric = 'HCUV Home Tab';
        String url = 'TestUrl';
        String appType = 'CUV';

        Test.startTest();
        String result = CRMALogger.fetchLogRecord(interactionType, interaction, interactionDetail, interactionMetric, url, appType);

        List<CRMALog__c> listLog = [SELECT Id, Name, Interaction_Type__c, Interaction_Value__c, Interaction_Detail__c, Interaction_Metric__c FROM CRMALog__c];
        System.assert(listLog.size()>0, 'CRMALoggerTest.TestPost - listLog is empty');
        if(listLog.size()>0) {
            System.assertEquals(interactionType, listLog[0].Interaction_Type__c);
            System.assertEquals(interaction, listLog[0].Interaction_Value__c);
            System.assertEquals(interactionDetail, listLog[0].Interaction_Detail__c);
            System.assertEquals(interactionMetric, listLog[0].Interaction_Metric__c);
        }
        Test.stopTest();
    }

}