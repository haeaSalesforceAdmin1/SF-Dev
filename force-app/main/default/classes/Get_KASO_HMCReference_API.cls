// @RestResource(UrlMapping='/cmt/api/HMCReference')
global with sharing class Get_KASO_HMCReference_API {

    global class Input {
        public InputBody data;
        public Input() {
            data = new InputBody();
        }
    }
    global class InputBody {
        public List<InputDataPRJVEHL> openApiGlobalCmtPrjVehlDInfos;
        public List<InputDataQLTYVEHLENG> openApiGlobalCmtQltyVehlEngIInfos;
        public List<InputDataENGTYMA> openApiGlobalCmtEngTymaDInfos;
        public List<InputDataQLTYVEHLTM> openApiGlobalCmtQltyVehlTmIInfos;
        public List<InputDataQLPRCORPPLNT> openApiGlobalCmtQlPrcCorpPlntDInfos;
        public InputBody(){
            openApiGlobalCmtPrjVehlDInfos = new List<InputDataPRJVEHL>();
            openApiGlobalCmtQltyVehlEngIInfos = new List<InputDataQLTYVEHLENG>();
            openApiGlobalCmtEngTymaDInfos = new List<InputDataENGTYMA>();
            openApiGlobalCmtQltyVehlTmIInfos = new List<InputDataQLTYVEHLTM>();
            openApiGlobalCmtQlPrcCorpPlntDInfos = new List<InputDataQLPRCORPPLNT>();
        }
    }
    global class InputDataPRJVEHL {
        public String prdnCorpCd;
        public String stdVehlCd;
        public String prjVehlCd;
        public String prjVehlNm;
        public String qltyCarTypeCd;
        public String saleBlndCd;
        public String ckdScnCd;
    }
    global class InputDataQLTYVEHLENG {
        public String prdnCorpCd;
        public String stdVehlCd;
        public String engTymaCd;
    }
    global class InputDataENGTYMA {
        public String engTymaCd;
        public String engScnCd;
        public String engTymaNm;
    }
    global class InputDataQLTYVEHLTM {
        public String prdnCorpCd;
        public String stdVehlCd;
        public String tmPrdnPlntCd;
        public String tmPrjCd;
    }
    global class InputDataQLPRCORPPLNT {
        public String prdnCorpCd;
        public String plntCd;
        public String plntTypeCd;
        public String prdnPlntNm;
        public String prdnCorpANm;
    }

    @Future(Callout=true)
    global static void Get_KASO_HMCReference_Interface() {
       // String requestBody = RestContext.request.requestBody.toString();

       Http http = new Http();
       HttpRequest req = new HttpRequest();
       HttpResponse res = new HttpResponse();

       req.setEndpoint('https://openapi.sqim.hmckmc.co.kr/openApi/globalCmt/affected/vehicle/info');
       req.setMethod('GET');
       //req.setHeader('Authorization', 'VL7sTefURWOjfrGbwWg/ylz/nyNh/l6zuuM/o7qsxQ/TdrOuTXmnmbqWake9OnnV9ye/fGrsFMwry+ZFEepKW/Wd3tyDR8YKqMFkLU6LXk3cMLIVoi8fO8PGVyTAulAxfh41MA2xIdq0qPZuBpfjeg==');
       //req.setHeader('Authorization', 'VL7sTefURWOjfrGbwWg/yvHzdt/ZZK+t4goaCkHFVoDgKmjCPSirO76RDbXm/WcCX+z+D8AyZStWdFjvtValL/ztccMn1PgIqBtGqW9UXVxz75vj9s8ec00MhMC8pgNIriRvwLq2U0Mi/tKfX8Tw0ckXFee48BZtuVc0grkSfeC+fXEC48Ms7aY1UGZ5tOOpTqgDU53nlq/3Y+8Fsi8m6pV783sj3uQUX+C0LO6G5FWfXlyRRKzTr6egvzXvTDylmeS8ozfyhgopF4/PguqIh6/V/kH2epC3ev0cORUmWxNmulvkK+TaeWHLUYfrl1l1HlJVJVXFYuuuJJX+P3JCEldjtHI5/hOJpY8dqjKLqWdJ2VtFZsxilcdQfCn+7f/aRXXNZKAcHzl8SeMtnTZ1F0AHgfaqkZveSJv+PS/p68gi3/rwpx5Cyf87DIeRr829Oz4siBbbm4qNGucl41otU2PlzdEiyFSAGIQV+3v7vf0=');
       //update key 2024.05.02
       req.setHeader('Authorization', 'QHru5X2QjrNBvYCfk8vVtQpxFh+k5fg8+0Xu4/3qPmpXDaOe9wPgqwRLD8QNqgdcGaIgnk5mDJ9Bpollprky5sMC6EmEuOlg1W+v8Ine0lSj21SGIUSINNfuQZF3qCI9oii6TxVsbiNGy+6AdOAjPA==');
       
       req.setTimeout(110000);

        try{
            res = http.send(req);
            System.debug(res.getBody());
            System.debug(res.getStatusCode());
            Integer statusCode = res.getStatusCode();
            Input objInput = new Input();
            InputBody objInputBody = new InputBody();

            if(statusCode == 200){
                //Map<String, Map<List<Object>>> deserialized = (Map<String, Map<List<Object>>>)JSON.deserializeUntyped(res.getBody());
                objInput = (Input)JSON.deserialize(res.getBody(), Input.class);
                //objInput = (Input)JSON.deserialize(requestBody, Input.class);
                //objInput = (Input)JSON.deserialize(testValue, Input.class);
                objInputBody = objInput.data;
                List<InputDataPRJVEHL> lFListPRJVEHL = objInputBody.openApiGlobalCmtPrjVehlDInfos;
                List<InputDataQLTYVEHLENG> lFListQLTYVEHLENG = objInputBody.openApiGlobalCmtQltyVehlEngIInfos;
                List<InputDataENGTYMA> lFListENGTYMA = objInputBody.openApiGlobalCmtEngTymaDInfos;
                List<InputDataQLTYVEHLTM> lFListQLTYVEHLTM = objInputBody.openApiGlobalCmtQltyVehlTmIInfos;
                List<InputDataQLPRCORPPLNT> lFListQLPRCORPPLNT = objInputBody.openApiGlobalCmtQlPrcCorpPlntDInfos;

                //DM1_QM_01_PRJVEHL_D
                if(!lFListPRJVEHL.isEmpty()){
                    List<DM1_QM_01_PRJVEHL_D__c> upsertPRJVEHLList = new List<DM1_QM_01_PRJVEHL_D__c>();
                    Map<String, DM1_QM_01_PRJVEHL_D__c> mapPRJVEHL = new Map<String, DM1_QM_01_PRJVEHL_D__c>();
                    Set<String> excludeDataList = new Set<String>();
                    List<DM1_QM_01_PRJVEHL_D__c> PRJVEHLList = [ SELECT Id, PRDN_CORP_CD__c, STD_VEHL_CD__c, PRJ_VEHL_CD__c, PRJ_VEHL_NM__c, 
                                                                        QLTY_CAR_TYPE_CD__c, SALE_BLND_CD__c, CKD_SCN_CD__c, USE_YN__c, ExternelKey__c
                                                                    FROM DM1_QM_01_PRJVEHL_D__c ];
                    
                    for(DM1_QM_01_PRJVEHL_D__c PRJVEHL : PRJVEHLList){  
                        mapPRJVEHL.put(PRJVEHL.ExternelKey__c, PRJVEHL);
                    }
                    
                    for(InputDataPRJVEHL PRJVEH : lFListPRJVEHL){
                        if(PRJVEH.prdnCorpCd!=null && PRJVEH.stdVehlCd!=null && PRJVEH.prdnCorpCd!='' && PRJVEH.stdVehlCd!=''){
                            DM1_QM_01_PRJVEHL_D__c upsertPRJVEHL = new  DM1_QM_01_PRJVEHL_D__c();
                            String newExternelKey = PRJVEH.prdnCorpCd + PRJVEH.stdVehlCd;
                            if(!mapPRJVEHL.containsKey(newExternelKey)){                        //신규 데이터의 경우
                                upsertPRJVEHL.PRDN_CORP_CD__c = PRJVEH.prdnCorpCd;
                                upsertPRJVEHL.STD_VEHL_CD__c = PRJVEH.stdVehlCd;
                                upsertPRJVEHL.PRJ_VEHL_CD__c = PRJVEH.prjVehlCd;
                                upsertPRJVEHL.PRJ_VEHL_NM__c = PRJVEH.prjVehlNm;
                                upsertPRJVEHL.QLTY_CAR_TYPE_CD__c = PRJVEH.qltyCarTypeCd;
                                upsertPRJVEHL.SALE_BLND_CD__c = PRJVEH.saleBlndCd;
                                upsertPRJVEHL.CKD_SCN_CD__c = PRJVEH.ckdScnCd;
                                upsertPRJVEHL.ExternelKey__c = newExternelKey;
                                upsertPRJVEHL.USE_YN__c = 'Y';
                                upsertPRJVEHLList.add(upsertPRJVEHL);
                                excludeDataList.add(newExternelKey);
                            } else {                                                            //변경 데이터의 경우
                                upsertPRJVEHL.PRDN_CORP_CD__c = PRJVEH.prdnCorpCd;
                                upsertPRJVEHL.STD_VEHL_CD__c = PRJVEH.stdVehlCd;
                                upsertPRJVEHL.PRJ_VEHL_CD__c = PRJVEH.prjVehlCd;
                                upsertPRJVEHL.PRJ_VEHL_NM__c = PRJVEH.prjVehlNm;
                                upsertPRJVEHL.QLTY_CAR_TYPE_CD__c = PRJVEH.qltyCarTypeCd;
                                upsertPRJVEHL.SALE_BLND_CD__c = PRJVEH.saleBlndCd;
                                upsertPRJVEHL.CKD_SCN_CD__c = PRJVEH.ckdScnCd;
                                upsertPRJVEHL.Id = mapPRJVEHL.get(newExternelKey).Id;
                                upsertPRJVEHL.USE_YN__c = 'Y';
                                upsertPRJVEHLList.add(upsertPRJVEHL);
                                excludeDataList.add(newExternelKey);
                            }
                        }                            
                    }

                    for(DM1_QM_01_PRJVEHL_D__c PRJVEHL : PRJVEHLList){
                        if(!excludeDataList.contains(PRJVEHL.ExternelKey__c)){              //사용하지 않는 데이터의 경우
                            DM1_QM_01_PRJVEHL_D__c upsertPRJVEHL = new  DM1_QM_01_PRJVEHL_D__c();
                            upsertPRJVEHL.Id = PRJVEHL.Id;
                            upsertPRJVEHL.USE_YN__c = 'N';
                            upsertPRJVEHLList.add(upsertPRJVEHL);
                        } 
                    }
                    
                    if(!upsertPRJVEHLList.isEmpty()){
                        upsert upsertPRJVEHLList;
                    }
                }

                //DM1_QM_01_QLTYVEHLENG_I
                if(!lFListQLTYVEHLENG.isEmpty()){
                    List<DM1_QM_01_QLTYVEHLENG_I__c> upsertQLTYVEHLENGList = new List<DM1_QM_01_QLTYVEHLENG_I__c>();
                    Map<String, DM1_QM_01_QLTYVEHLENG_I__c> mapQLTYVEHLENG = new Map<String, DM1_QM_01_QLTYVEHLENG_I__c>();
                    Set<String> excludeDataList = new Set<String>();
                    List<DM1_QM_01_QLTYVEHLENG_I__c> QLTYVEHLENGList = [ SELECT Id, PRDN_CORP_CD__c, STD_VEHL_CD__c, ENG_TYMA_CD__c, 
                                                                            USE_YN__c, ExternelKey__c
                                                                       FROM DM1_QM_01_QLTYVEHLENG_I__c ];

                    for(DM1_QM_01_QLTYVEHLENG_I__c QLTYVEHLENG : QLTYVEHLENGList){  
                        mapQLTYVEHLENG.put(QLTYVEHLENG.ExternelKey__c, QLTYVEHLENG);
                    }  

                    for(InputDataQLTYVEHLENG QLTYVEHLENG : lFListQLTYVEHLENG){
                        if(QLTYVEHLENG.prdnCorpCd!=null && QLTYVEHLENG.stdVehlCd!=null && QLTYVEHLENG.engTymaCd!=null && 
                        QLTYVEHLENG.prdnCorpCd!='' && QLTYVEHLENG.stdVehlCd!='' && QLTYVEHLENG.engTymaCd!=''){
                            DM1_QM_01_QLTYVEHLENG_I__c upsertQLTYVEHLENG = new DM1_QM_01_QLTYVEHLENG_I__c();
                            String newExternelKey = QLTYVEHLENG.prdnCorpCd + QLTYVEHLENG.stdVehlCd + QLTYVEHLENG.engTymaCd;
                            if(!mapQLTYVEHLENG.containsKey(newExternelKey)){
                                upsertQLTYVEHLENG.PRDN_CORP_CD__c = QLTYVEHLENG.prdnCorpCd;
                                upsertQLTYVEHLENG.STD_VEHL_CD__c = QLTYVEHLENG.stdVehlCd;
                                upsertQLTYVEHLENG.ENG_TYMA_CD__c = QLTYVEHLENG.engTymaCd;
                                upsertQLTYVEHLENG.ExternelKey__c = newExternelKey;
                                upsertQLTYVEHLENG.USE_YN__c = 'Y';
                                upsertQLTYVEHLENGList.add(upsertQLTYVEHLENG);
                                excludeDataList.add(newExternelKey);
                            }else{
                                upsertQLTYVEHLENG.PRDN_CORP_CD__c = QLTYVEHLENG.prdnCorpCd;
                                upsertQLTYVEHLENG.STD_VEHL_CD__c = QLTYVEHLENG.stdVehlCd;
                                upsertQLTYVEHLENG.ENG_TYMA_CD__c = QLTYVEHLENG.engTymaCd;
                                upsertQLTYVEHLENG.Id = mapQLTYVEHLENG.get(newExternelKey).Id;
                                upsertQLTYVEHLENG.USE_YN__c = 'Y';
                                upsertQLTYVEHLENGList.add(upsertQLTYVEHLENG);
                                excludeDataList.add(newExternelKey);
                            }
                        }
                    }

                    for(DM1_QM_01_QLTYVEHLENG_I__c QLTYVEHLENG : QLTYVEHLENGList){
                        if(!excludeDataList.contains(QLTYVEHLENG.ExternelKey__c)){
                            DM1_QM_01_QLTYVEHLENG_I__c upsertQLTYVEHLENG = new DM1_QM_01_QLTYVEHLENG_I__c();
                            upsertQLTYVEHLENG.Id = QLTYVEHLENG.Id;
                            upsertQLTYVEHLENG.USE_YN__c = 'N';
                            upsertQLTYVEHLENGList.add(upsertQLTYVEHLENG);
                        }
                    }

                    if(!upsertQLTYVEHLENGList.isEmpty()){
                        upsert upsertQLTYVEHLENGList;
                    }                    
                }


                //DM1_QM_01_ENGTYMA_D__c
                if(!lFListENGTYMA.isEmpty()){
                    List<DM1_QM_01_ENGTYMA_D__c> upsertENGTYMAList = new List<DM1_QM_01_ENGTYMA_D__c>();
                    Map<String, DM1_QM_01_ENGTYMA_D__c> mapENGTYMA = new Map<String, DM1_QM_01_ENGTYMA_D__c>();
                    Set<String> excludeDataList = new Set<String>();
                    List<DM1_QM_01_ENGTYMA_D__c> ENGTYMAList = [ SELECT Id, ENG_TYMA_CD__c, ENG_SCN_CD__c, ENG_TYMA_NM__c, USE_YN__c,
                                                                    ExternelKey__c
                                                               FROM DM1_QM_01_ENGTYMA_D__c ];

                    for(DM1_QM_01_ENGTYMA_D__c ENGTYMA : ENGTYMAList){  
                        mapENGTYMA.put(ENGTYMA.ExternelKey__c, ENGTYMA);
                    }
                    
                    for(InputDataENGTYMA ENGTYMA : lFListENGTYMA){
                        if(ENGTYMA.engTymaCd!=null && ENGTYMA.engTymaCd!=''){
                            DM1_QM_01_ENGTYMA_D__c upsertENGTYMA = new DM1_QM_01_ENGTYMA_D__c();
                            String newExternelKey = ENGTYMA.engTymaCd;
                            if(!mapENGTYMA.containsKey(newExternelKey)){
                                upsertENGTYMA.ENG_TYMA_CD__c = ENGTYMA.engTymaCd;
                                upsertENGTYMA.ENG_SCN_CD__c = ENGTYMA.engScnCd;
                                upsertENGTYMA.ENG_TYMA_NM__c = ENGTYMA.engTymaNm;
                                upsertENGTYMA.ExternelKey__c = newExternelKey;
                                upsertENGTYMA.USE_YN__c = 'Y';
                                upsertENGTYMAList.add(upsertENGTYMA);
                                excludeDataList.add(newExternelKey);
                            }else{
                                upsertENGTYMA.ENG_TYMA_CD__c = ENGTYMA.engTymaCd;
                                upsertENGTYMA.ENG_SCN_CD__c = ENGTYMA.engScnCd;
                                upsertENGTYMA.ENG_TYMA_NM__c = ENGTYMA.engTymaNm;
                                upsertENGTYMA.Id = mapENGTYMA.get(newExternelKey).Id;
                                upsertENGTYMA.USE_YN__c = 'Y';
                                upsertENGTYMAList.add(upsertENGTYMA);
                                excludeDataList.add(newExternelKey);
                            }
                        }
                    }

                    for(DM1_QM_01_ENGTYMA_D__c ENGTYMA : ENGTYMAList){
                        if(!excludeDataList.contains(ENGTYMA.ExternelKey__c)){
                            DM1_QM_01_ENGTYMA_D__c upsertENGTYMA = new DM1_QM_01_ENGTYMA_D__c();
                            upsertENGTYMA.Id = ENGTYMA.Id;
                            upsertENGTYMA.USE_YN__c = 'N';
                            upsertENGTYMAList.add(upsertENGTYMA);
                        }
                    }

                    if(!upsertENGTYMAList.isEmpty()){
                        upsert upsertENGTYMAList;
                    }                    
                }


                //DM1_QM_01_QLTYVEHLTM_I__c
                if(!lFListQLTYVEHLTM.isEmpty()){
                    List<DM1_QM_01_QLTYVEHLTM_I__c> upsertQLTYVEHLTMList = new List<DM1_QM_01_QLTYVEHLTM_I__c>();
                    Map<String, DM1_QM_01_QLTYVEHLTM_I__c> mapQLTYVEHLTM = new Map<String, DM1_QM_01_QLTYVEHLTM_I__c>();
                    Set<String> excludeDataList = new Set<String>();
                    List<DM1_QM_01_QLTYVEHLTM_I__c> QLTYVEHLTMList = [ SELECT Id, PRDN_CORP_CD__c, STD_VEHL_CD__c, TM_PRDN_PLNT_CD__c, TM_PRJ_CD__c,
                                                                           USE_YN__c, ExternelKey__c
                                                                      FROM DM1_QM_01_QLTYVEHLTM_I__c ];

                    for(DM1_QM_01_QLTYVEHLTM_I__c QLTYVEHLTM : QLTYVEHLTMList){
                        mapQLTYVEHLTM.put(QLTYVEHLTM.ExternelKey__c, QLTYVEHLTM);
                    }

                    for(InputDataQLTYVEHLTM QLTYVEHLTM : lFListQLTYVEHLTM){
                        if(QLTYVEHLTM.prdnCorpCd!=null && QLTYVEHLTM.stdVehlCd!=null && QLTYVEHLTM.tmPrdnPlntCd!=null && QLTYVEHLTM.tmPrjCd!=null &&
                        QLTYVEHLTM.prdnCorpCd!='' && QLTYVEHLTM.stdVehlCd!='' && QLTYVEHLTM.tmPrdnPlntCd!='' && QLTYVEHLTM.tmPrjCd!=''){
                            DM1_QM_01_QLTYVEHLTM_I__c upsertQLTYVEHLTM = new DM1_QM_01_QLTYVEHLTM_I__c();
                            String newExternelKey = QLTYVEHLTM.prdnCorpCd + QLTYVEHLTM.stdVehlCd + QLTYVEHLTM.tmPrdnPlntCd + QLTYVEHLTM.tmPrjCd;
                            if(!mapQLTYVEHLTM.containsKey(newExternelKey)){
                                upsertQLTYVEHLTM.PRDN_CORP_CD__c = QLTYVEHLTM.prdnCorpCd;
                                upsertQLTYVEHLTM.STD_VEHL_CD__c = QLTYVEHLTM.stdVehlCd;
                                upsertQLTYVEHLTM.TM_PRDN_PLNT_CD__c = QLTYVEHLTM.tmPrdnPlntCd;
                                upsertQLTYVEHLTM.TM_PRJ_CD__c = QLTYVEHLTM.tmPrjCd;
                                upsertQLTYVEHLTM.ExternelKey__c = newExternelKey;
                                upsertQLTYVEHLTM.USE_YN__c = 'Y';
                                upsertQLTYVEHLTMList.add(upsertQLTYVEHLTM);
                                excludeDataList.add(newExternelKey);
                            }else{
                                upsertQLTYVEHLTM.PRDN_CORP_CD__c = QLTYVEHLTM.prdnCorpCd;
                                upsertQLTYVEHLTM.STD_VEHL_CD__c = QLTYVEHLTM.stdVehlCd;
                                upsertQLTYVEHLTM.TM_PRDN_PLNT_CD__c = QLTYVEHLTM.tmPrdnPlntCd;
                                upsertQLTYVEHLTM.TM_PRJ_CD__c = QLTYVEHLTM.tmPrjCd;
                                upsertQLTYVEHLTM.Id = mapQLTYVEHLTM.get(newExternelKey).Id;
                                upsertQLTYVEHLTM.USE_YN__c = 'Y';
                                upsertQLTYVEHLTMList.add(upsertQLTYVEHLTM);
                                excludeDataList.add(newExternelKey);
                            }
                        }
                    }

                    for(DM1_QM_01_QLTYVEHLTM_I__c QLTYVEHLTM : QLTYVEHLTMList){
                        if(!excludeDataList.contains(QLTYVEHLTM.ExternelKey__c)){
                            DM1_QM_01_QLTYVEHLTM_I__c upsertQLTYVEHLTM = new DM1_QM_01_QLTYVEHLTM_I__c();
                            upsertQLTYVEHLTM.Id = QLTYVEHLTM.Id;
                            upsertQLTYVEHLTM.USE_YN__c = 'N';
                            upsertQLTYVEHLTMList.add(upsertQLTYVEHLTM);
                        }
                    }

                    if(!upsertQLTYVEHLTMList.isEmpty()){
                        upsert upsertQLTYVEHLTMList;
                    }
                }

                if(!lFListQLPRCORPPLNT.isEmpty()){
                    List<DM1_QM_07_QLPRCORPPLNT_D__c> upsertQLPRCORPPLNTList = new List<DM1_QM_07_QLPRCORPPLNT_D__c>();
                    Map<String, DM1_QM_07_QLPRCORPPLNT_D__c> mapQLPRCORPPLNT = new Map<String, DM1_QM_07_QLPRCORPPLNT_D__c>();
                    Set<String> excludeDataList = new Set<String>();
                    List<DM1_QM_07_QLPRCORPPLNT_D__c> QLPRCORPPLNTList = [ SELECT Id, PRDN_CORP_CD__c, STD_PLNT_CD__c, PLNT_TYPE_CD__c, PRDN_PLNT_NM__c,
                                                                              PRDN_CORP_A_NM__c, USE_YN__c, ExternelKey__c
                                                                         FROM DM1_QM_07_QLPRCORPPLNT_D__c ];
                    
                    for(DM1_QM_07_QLPRCORPPLNT_D__c QLPRCORPPLNT : QLPRCORPPLNTList){
                        mapQLPRCORPPLNT.put(QLPRCORPPLNT.ExternelKey__c, QLPRCORPPLNT);
                    }

                    for(InputDataQLPRCORPPLNT QLPRCORPPLNT : lFListQLPRCORPPLNT){
                        if(QLPRCORPPLNT.plntCd!=null && QLPRCORPPLNT.plntCd!=''){
                            DM1_QM_07_QLPRCORPPLNT_D__c upsertQLPRCORPPLNT = new DM1_QM_07_QLPRCORPPLNT_D__c();
                            String newExternelKey = QLPRCORPPLNT.plntCd; 
                            if(!mapQLPRCORPPLNT.containsKey(newExternelKey)){
                                upsertQLPRCORPPLNT.PRDN_CORP_CD__c = QLPRCORPPLNT.prdnCorpCd;
                                upsertQLPRCORPPLNT.STD_PLNT_CD__c = QLPRCORPPLNT.plntCd;
                                upsertQLPRCORPPLNT.PLNT_TYPE_CD__c = QLPRCORPPLNT.plntTypeCd;
                                upsertQLPRCORPPLNT.PRDN_PLNT_NM__c = QLPRCORPPLNT.prdnPlntNm;
                                upsertQLPRCORPPLNT.PRDN_CORP_A_NM__c = QLPRCORPPLNT.prdnCorpANm;
                                upsertQLPRCORPPLNT.ExternelKey__c = newExternelKey;
                                upsertQLPRCORPPLNT.USE_YN__c = 'Y';
                                upsertQLPRCORPPLNTList.add(upsertQLPRCORPPLNT);
                                excludeDataList.add(newExternelKey);
                            }else{
                                upsertQLPRCORPPLNT.PRDN_CORP_CD__c = QLPRCORPPLNT.prdnCorpCd;
                                upsertQLPRCORPPLNT.STD_PLNT_CD__c = QLPRCORPPLNT.plntCd;
                                upsertQLPRCORPPLNT.PLNT_TYPE_CD__c = QLPRCORPPLNT.plntTypeCd;
                                upsertQLPRCORPPLNT.PRDN_PLNT_NM__c = QLPRCORPPLNT.prdnPlntNm;
                                upsertQLPRCORPPLNT.PRDN_CORP_A_NM__c = QLPRCORPPLNT.prdnCorpANm;
                                upsertQLPRCORPPLNT.Id = mapQLPRCORPPLNT.get(newExternelKey).Id;
                                upsertQLPRCORPPLNT.USE_YN__c = 'Y';
                                upsertQLPRCORPPLNTList.add(upsertQLPRCORPPLNT);
                                excludeDataList.add(newExternelKey);
                            }
                        }
                    }

                    for(DM1_QM_07_QLPRCORPPLNT_D__c QLPRCORPPLNT : QLPRCORPPLNTList){
                        if(!excludeDataList.contains(QLPRCORPPLNT.ExternelKey__c)){
                            DM1_QM_07_QLPRCORPPLNT_D__c upsertQLPRCORPPLNT = new DM1_QM_07_QLPRCORPPLNT_D__c();
                            upsertQLPRCORPPLNT.Id = QLPRCORPPLNT.Id;
                            upsertQLPRCORPPLNT.USE_YN__c = 'N';
                            upsertQLPRCORPPLNTList.add(upsertQLPRCORPPLNT);
                        }
                    }

                    if(!upsertQLPRCORPPLNTList.isEmpty()){
                        upsert upsertQLPRCORPPLNTList;
                    }
                }
            }
        }catch(System.CalloutException e){
            System.debug('Callout error: ' + e);
            //System.debug(res.toString());
            System.debug('statusCode error: ' + e.getMessage());

        }catch(System.JSONException j){
            System.debug('Callout error: ' + j);
            //System.debug(res.toString());
            System.debug('statusCode error: ' + j.getMessage());
        }
    }
}