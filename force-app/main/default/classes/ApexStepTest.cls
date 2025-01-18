@IsTest
private class ApexStepTest {
    @isTest
    static void TestApexStepResponse() {
        ApexStepResponse.Metadata mdt = new ApexStepResponse.Metadata(new List<String>{'Goodbye', 'Stranger'}
                                                                      ,new List<String>{'1','2','3','4'}
                                                                      ,new List<String>{'Avengers', 'Justice League'});
        List<Map<String, Object>> returnItems = new List<Map<String, Object>>();
        Map<String, Object> curRow = new Map<String, Object>();
        curRow.put('all', 'all');
        curRow.put('Log', 1);
        returnItems.add(curRow);
        ApexStepResponse resp = new ApexStepResponse(returnItems, mdt);
        string sExpected = 'ApexStepResponse:[data=({Log=1, all=all}), metadata=Metadata:[groups=(Avengers, Justice League), numbers=(1, 2, 3, 4), strings=(Goodbye, Stranger)]]';
        system.debug('resp:'+resp.toString());
        System.assertEquals(sExpected, resp.toString(), 'ApexStepTest.TestApexStepResponse - sExpected is incorrect');
    }
    
    @isTest
    static void TestApexStepRequest() {
        //string sReq1 = '{"parmStr":"hello dolly", "parmDbl":3.14, "parmList":["1", "2", "3"], "parmData": [[{"val1":"1", "val2":"2"}, {"val1":"3", "val2":"4"}], [{"val1":"5", "val2":"6"}, {"val1":"7", "val2":"8"}]], "parm5":"5", "parm6":"6", "parm7":"7", "parm8":"8", "parm9":"9", "parm10":"10", "parm11":"11"}';
		string sReq = '{"parmStr":"hello dolly", "parmDbl":3.14, "parmList":["a", "b", "c", "d"], "parmData": [["1", "2", "3", "4"], ["5", "6", "7", "8"]], "parm5":"5", "parm6":"6", "parm7":"7", "parm8":"8", "parm9":"9", "parm10":"10", "parm11":"11"}';
        ApexStepRequest stepRequest = new ApexStepRequest(sReq, new ApexStepRequest.Parameter[]{
                new ApexStepRequest.Parameter('parmStr', ApexStepRequest.ParameterType.STRING_PARAM),
                new ApexStepRequest.Parameter('parmDbl', ApexStepRequest.ParameterType.DOUBLE_PARAM),
                new ApexStepRequest.Parameter('parmList', ApexStepRequest.ParameterType.STRING_LIST_PARAM),
                new ApexStepRequest.Parameter('parmData', ApexStepRequest.ParameterType.DATA_PARAM),
                new ApexStepRequest.Parameter('parm5', ApexStepRequest.ParameterType.STRING_PARAM),
                new ApexStepRequest.Parameter('parm6', ApexStepRequest.ParameterType.STRING_PARAM),
                new ApexStepRequest.Parameter('parm7', ApexStepRequest.ParameterType.STRING_PARAM),
                new ApexStepRequest.Parameter('parm8', ApexStepRequest.ParameterType.STRING_PARAM),
                new ApexStepRequest.Parameter('parm9', ApexStepRequest.ParameterType.STRING_PARAM),
                new ApexStepRequest.Parameter('parm10', ApexStepRequest.ParameterType.STRING_PARAM),
                new ApexStepRequest.Parameter('parm11', ApexStepRequest.ParameterType.STRING_PARAM)
            });
        String str = stepRequest.getStringParam('parmStr');
        System.assertEquals('hello dolly', str);
        str = stepRequest.getStringParam('parmStr', 'Hello');
        System.assertEquals('hello dolly', str);
        str = stepRequest.getStringParam('parmStr1');
        System.assertEquals(null, str);
        str = stepRequest.getStringParam('parmStr1', 'Hello');
        System.assertEquals('Hello', str);
        
        Double dbl = stepRequest.getDoubleParam('parmDbl');
        System.assertEquals(Double.valueOf('3.14'), dbl);
        dbl = stepRequest.getDoubleParam('parmDbl', Double.valueOf('2.718'));
        System.assertEquals(Double.valueOf('3.14'), dbl);
        dbl = stepRequest.getDoubleParam('parmDbl1');
        System.assertEquals(null, dbl);
        dbl = stepRequest.getDoubleParam('parmDbl1', Double.valueOf('2.718'));
        System.assertEquals(Double.valueOf('2.718'), dbl);
        
        List<String> listStr = stepRequest.getStringListParam('parmList');
        System.assertEquals(new List<String>{'a', 'b', 'c', 'd'}, listStr);
        listStr = stepRequest.getStringListParam('parmList', new List<String>{'x', 'y', 'z'});
        System.assertEquals(new List<String>{'a', 'b', 'c', 'd'}, listStr);
        listStr = stepRequest.getStringListParam('parmList1');
        System.assertEquals(null, listStr);
        listStr = stepRequest.getStringListParam('parmList1', new List<String>{'x', 'y', 'z'});
        System.assertEquals(new List<String>{'x', 'y', 'z'}, listStr);
        
        List<List<Object>> list2Obj = stepRequest.getDataParam('parmData');
        //for(List<Object> lo :list2Obj) { System.debug('lo:'+lo); }
        //List<List<Object>> testl = new List<List<Object>>{new List<Object>{1,2,3,4}, new List<Object>{5,6,7,8}};
        //System.debug('list2Obj: '+list2Obj); System.debug('testl: '+testl);
        System.assertEquals(2, list2Obj.size());
        System.assertEquals(4, list2Obj[0].size());
        System.assertEquals(4, list2Obj[1].size());
        list2Obj = stepRequest.getDataParam('parmData1');
        System.assertEquals(null, list2Obj);
        
        List<Map<String, Object>> listMapStrToObj = stepRequest.getMappedData('parmData', 'parmList');
        //System.debug('list: '+listMapStrToObj);
        System.assertEquals(2, listMapStrToObj.size());
        System.assertEquals('4', listMapStrToObj[0].get('d').toString());
        System.assertEquals('7', listMapStrToObj[1].get('c').toString());
    }
}