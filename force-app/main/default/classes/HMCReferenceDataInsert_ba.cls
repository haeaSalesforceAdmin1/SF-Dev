/**
 * Created by dw.lee on 2023-10-06.
 */
global class HMCReferenceDataInsert_ba implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    /*
        * Make
            DM1_QM_01_PRJVEHL_D

        * CBU/CKD
            DM1_QM_01_PRJVEHL_D

        * Prod. Corp
            DM1_QM_01_PRJVEHL_D (Key Field : PRDN_CORP_CD__c ) => DM1_QM_07_QLPRCORPPLNT_D (Key Field : PRDN_CORP_CD__c )

        * Vehicle Type
            DM1_QM_01_PRJVEHL_D

        * Model
            DM1_QM_01_PRJVEHL_D

        * Model code
            DM1_QM_01_PRJVEHL_D

        * Engine
            DM1_QM_01_PRJVEHL_D (Key Field : PRDN_CORP_CD__c,  STD_VEHL_CD__c) => DM1_QM_01_QLTYVEHLENG_I (Key Field : PRDN_CORP_CD__c,  STD_VEHL_CD__c) => DM1_QM_01_ENGTYMA_D (Key Field : ENG_TYMA_CD__c)

        * Transmission
            DM1_QM_01_PRJVEHL_D (Key Field : PRDN_CORP_CD__c,  STD_VEHL_CD__c) => DM1_QM_01_QLTYVEHLTM_I (Key Field : PRDN_CORP_CD__c,  STD_VEHL_CD__c)
    */

    Map<String, List<DM1_QM_01_QLTYVEHLENG_I__c>> mapQltyvehleng = new Map<String, List<DM1_QM_01_QLTYVEHLENG_I__c>>();

    Map<String, DM1_QM_01_ENGTYMA_D__c> mapEngtyma = new Map<String, DM1_QM_01_ENGTYMA_D__c>();
    Map<String, List<DM1_QM_01_QLTYVEHLTM_I__c>> mapQltyvehltm = new Map<String, List<DM1_QM_01_QLTYVEHLTM_I__c>>();
    Map<String, DM1_QM_07_QLPRCORPPLNT_D__c> mapQlprcorpplnt = new Map<String, DM1_QM_07_QLPRCORPPLNT_D__c>();

    Set<String> setMappingModel = new Set<String>();
    Set<String> setMappingEngine = new Set<String>();
    Set<String> setMappingTransmission = new Set<String>();
    Map<String, HMCReferenceDataMapping__c> mapMappingModel = new Map<String, HMCReferenceDataMapping__c>();
    Map<String, HMCReferenceDataMapping__c> mapMappingEngine = new Map<String, HMCReferenceDataMapping__c>();
    Map<String, HMCReferenceDataMapping__c> mapMappingTransmission = new Map<String, HMCReferenceDataMapping__c>();
    List<HMCReferenceData__c> listHMCReferenceData = new List<HMCReferenceData__c>();
    List<HMCReferenceDataMapping__c> insertMappingTarget = new List<HMCReferenceDataMapping__c>();
    Set<String> newValueField = new Set<String>();
    Boolean fuelTypeNewCheck = false;
    Boolean errorStatus = false;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('HMCReferenceDataInsert_ba Start :: ');

        listHMCReferenceData = new List<HMCReferenceData__c>([
            SELECT  Id
            FROM    HMCReferenceData__c
        ]);

        // DM1_QM_01_QLTYVEHLENG_I__c
        List<DM1_QM_01_QLTYVEHLENG_I__c> list_DM1_QM_01_QLTYVEHLENG_I = new List<DM1_QM_01_QLTYVEHLENG_I__c>([
                SELECT  Id, Name, PRDN_CORP_CD__c, STD_VEHL_CD__c, ENG_TYMA_CD__c, USE_YN__c, ExternelKey__c
                FROM    DM1_QM_01_QLTYVEHLENG_I__c
                WHERE   USE_YN__c = 'Y'
                AND     PRDN_CORP_CD__c != NULL
                AND     STD_VEHL_CD__c != NULL
                AND     ENG_TYMA_CD__c != NULL
                AND     (NOT PRDN_CORP_CD__c LIKE '%@%')
                AND     (NOT STD_VEHL_CD__c LIKE '%@%')
                AND     (NOT ENG_TYMA_CD__c LIKE '%@%')
        ]);
        if(!list_DM1_QM_01_QLTYVEHLENG_I.isEmpty()){
            List<DM1_QM_01_QLTYVEHLENG_I__c> tempList;
            for(DM1_QM_01_QLTYVEHLENG_I__c qltyvehleng : list_DM1_QM_01_QLTYVEHLENG_I){
                String strKey = qltyvehleng.PRDN_CORP_CD__c + qltyvehleng.STD_VEHL_CD__c;
                tempList = mapQltyvehleng.get(strKey) != null ? mapQltyvehleng.get(strKey) : new List<DM1_QM_01_QLTYVEHLENG_I__c>();
                tempList.add(qltyvehleng);
                mapQltyvehleng.put(strKey, tempList);
            }
        }

        // DM1_QM_01_ENGTYMA_D__c
        List<DM1_QM_01_ENGTYMA_D__c> list_DM1_QM_01_ENGTYMA_D = new List<DM1_QM_01_ENGTYMA_D__c>([
                SELECT  Id, Name, ENG_TYMA_CD__c, ENG_SCN_CD__c, ENG_TYMA_NM__c, USE_YN__c, ExternelKey__c
                FROM    DM1_QM_01_ENGTYMA_D__c
                WHERE   USE_YN__c = 'Y'
                AND     ENG_TYMA_CD__c != NULL
                AND     ENG_SCN_CD__c != NULL
                AND     ENG_TYMA_NM__c != NULL
                AND     (NOT ENG_TYMA_CD__c LIKE '%@%')
                AND     (NOT ENG_SCN_CD__c LIKE '%@%')
                AND     (NOT ENG_TYMA_NM__c LIKE '%@%')
        ]);
        if(!list_DM1_QM_01_ENGTYMA_D.isEmpty()){
            for(DM1_QM_01_ENGTYMA_D__c engtyma : list_DM1_QM_01_ENGTYMA_D){
                mapEngtyma.put(engtyma.ENG_TYMA_CD__c, engtyma);
            }
        }

        // DM1_QM_01_QLTYVEHLTM_I__c
        List<DM1_QM_01_QLTYVEHLTM_I__c> list_DM1_QM_01_QLTYVEHLTM_I = new List<DM1_QM_01_QLTYVEHLTM_I__c>([
                SELECT  Id, Name, PRDN_CORP_CD__c, STD_VEHL_CD__c, TM_PRDN_PLNT_CD__c, TM_PRJ_CD__c, USE_YN__c, ExternelKey__c
                FROM    DM1_QM_01_QLTYVEHLTM_I__c
                WHERE   USE_YN__c = 'Y'
                AND     PRDN_CORP_CD__c != NULL
                AND     STD_VEHL_CD__c != NULL
                AND     TM_PRDN_PLNT_CD__c != NULL
                AND     TM_PRJ_CD__c != NULL
                AND     (NOT PRDN_CORP_CD__c LIKE '%@%')
                AND     (NOT STD_VEHL_CD__c LIKE '%@%')
                AND     (NOT TM_PRDN_PLNT_CD__c LIKE '%@%')
                AND     (NOT TM_PRJ_CD__c LIKE '%@%')
        ]);
        if(!list_DM1_QM_01_QLTYVEHLTM_I.isEmpty()){
            List<DM1_QM_01_QLTYVEHLTM_I__c> listTemp;
            for(DM1_QM_01_QLTYVEHLTM_I__c qltyvehltm : list_DM1_QM_01_QLTYVEHLTM_I){
                String strKey = qltyvehltm.PRDN_CORP_CD__c + qltyvehltm.STD_VEHL_CD__c;
                listTemp = mapQltyvehltm.get(strKey) != null ? mapQltyvehltm.get(strKey) : new List<DM1_QM_01_QLTYVEHLTM_I__c>();
                listTemp.add(qltyvehltm);
                mapQltyvehltm.put(strKey, listTemp);
            }
        }

        // DM1_QM_07_QLPRCORPPLNT_D__c
        List<DM1_QM_07_QLPRCORPPLNT_D__c> list_DM1_QM_07_QLPRCORPPLNT_D = new List<DM1_QM_07_QLPRCORPPLNT_D__c>([
                SELECT  Id, Name, PRDN_CORP_CD__c, STD_PLNT_CD__c, PLNT_TYPE_CD__c, PRDN_PLNT_NM__c, PRDN_CORP_A_NM__c
                FROM    DM1_QM_07_QLPRCORPPLNT_D__c
                WHERE   USE_YN__c = 'Y'
                AND     PLNT_TYPE_CD__c = 'V'
                AND     PRDN_CORP_CD__c != NULL
                AND     STD_PLNT_CD__c != NULL
                AND     PLNT_TYPE_CD__c != NULL
                AND     PRDN_PLNT_NM__c != NULL
                AND     PRDN_CORP_A_NM__c != NULL
                AND     (NOT PRDN_CORP_CD__c LIKE '%@%')
                AND     (NOT STD_PLNT_CD__c LIKE '%@%')
                AND     (NOT PLNT_TYPE_CD__c LIKE '%@%')
                AND     (NOT PRDN_PLNT_NM__c LIKE '%@%')
                AND     (NOT PRDN_CORP_A_NM__c LIKE '%@%')
        ]);
        if(!list_DM1_QM_07_QLPRCORPPLNT_D.isEmpty()){
            Set<String> setCode = new Set<String>();
            for(DM1_QM_07_QLPRCORPPLNT_D__c qlprcorpplnt : list_DM1_QM_07_QLPRCORPPLNT_D){
                if(!setCode.contains(qlprcorpplnt.PRDN_CORP_CD__c)){
                    mapQlprcorpplnt.put(qlprcorpplnt.PRDN_CORP_CD__c, qlprcorpplnt);
                    setCode.add(qlprcorpplnt.PRDN_CORP_CD__c);
                }
            }
        }

        // HMCReferenceData Mapping Object Select
        List<HMCReferenceDataMapping__c> listHMCMapping = new List<HMCReferenceDataMapping__c>([
                SELECT  Id, Name, InterfaceValue__c, ChangeValue__c, Field__c
                FROM    HMCReferenceDataMapping__c
        ]);
        if(!listHMCMapping.isEmpty()){
            List<HMCReferenceDataMapping__c> listTemp;
            for(HMCReferenceDataMapping__c obj : listHMCMapping){
                if(obj.Field__c == 'VehicleModel__c') {
                    mapMappingModel.put(obj.InterfaceValue__c, obj);
                }
                else if(obj.Field__c == 'EngineDescription__c'){
                    mapMappingEngine.put(obj.InterfaceValue__c, obj);
                }
                else if(obj.Field__c == 'TransmissionDescription__c'){
                    mapMappingTransmission.put(obj.InterfaceValue__c, obj);
                }
                else {

                }
            }
        }

        // DM1_QM_01_PRJVEHL_D__c - Master Data
        String strQuery = 'SELECT';
        strQuery += ' Id, Name, CreatedDate, PRDN_CORP_CD__c, STD_VEHL_CD__c, PRJ_VEHL_CD__c, PRJ_VEHL_NM__c,';
        strQuery += ' QLTY_CAR_TYPE_CD__c, SALE_BLND_CD__c, CKD_SCN_CD__c, USE_YN__c, ExternelKey__c';
        strQuery += ' FROM';
        strQuery += ' DM1_QM_01_PRJVEHL_D__c';
        strQuery += ' WHERE';
        strQuery += ' USE_YN__c = \'Y\'';
        strQuery += ' AND PRDN_CORP_CD__c != null';
        strQuery += ' AND STD_VEHL_CD__c != null';
        strQuery += ' AND PRJ_VEHL_CD__c != null';
        strQuery += ' AND PRJ_VEHL_NM__c != null';
        strQuery += ' AND QLTY_CAR_TYPE_CD__c != null';
        strQuery += ' AND SALE_BLND_CD__c != null';
        strQuery += ' AND SALE_BLND_CD__c != \'K\'';
        strQuery += ' AND CKD_SCN_CD__c != null';
        strQuery += ' AND (NOT PRDN_CORP_CD__c LIKE \'%@%\')';
        strQuery += ' AND (NOT STD_VEHL_CD__c LIKE \'%@%\')';
        strQuery += ' AND (NOT PRJ_VEHL_CD__c LIKE \'%@%\')';
        strQuery += ' AND (NOT PRJ_VEHL_NM__c LIKE \'%@%\')';
        strQuery += ' AND (NOT QLTY_CAR_TYPE_CD__c LIKE \'%@%\')';
        strQuery += ' AND (NOT SALE_BLND_CD__c LIKE \'%@%\')';
        strQuery += ' AND (NOT CKD_SCN_CD__c LIKE \'%@%\')';

        return DataBase.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<DM1_QM_01_PRJVEHL_D__c> list_DM1_QM_01_PRJVEHL_D) {
        System.debug('HMCReferenceDataInsert_ba execute :: ');
        try{
            if(!list_DM1_QM_01_PRJVEHL_D.isEmpty()){

                // KASO VIN Mapping Object Select
                Set<String> VINMappingKey = new Set<String>();
                List<KASO_VIN_Mapping__c> insertVINMapping = new List<KASO_VIN_Mapping__c>();
                List<KASO_VIN_Mapping__c> listVINMapping = new List<KASO_VIN_Mapping__c>([
                        SELECT  Id, Model_Interface_Value__c, Model__c, Engine_Interface_Value__c, EngineDesciption__c, Transmission_Interface_Value__c, TransmissionDesc__c, FuelType__c
                        FROM    KASO_VIN_Mapping__c
                ]);

                if(!listVINMapping.isEmpty()){
                    for(KASO_VIN_Mapping__c obj : listVINMapping){
                        String vinKey = obj.Model_Interface_Value__c + '_';

                        if(obj.Transmission_Interface_Value__c != null && obj.Transmission_Interface_Value__c != ''){
                            vinKey += obj.Engine_Interface_Value__c + '_';
                            vinKey += obj.Transmission_Interface_Value__c;
                        }
                        else {
                            vinKey += obj.Engine_Interface_Value__c;
                        }

                        VINMappingKey.add(vinKey);
                    }
                }

                HMCReferenceData__c objHMHmcReferenceData;
                List<HMCReferenceData__c> listHmcReferenceData = new List<HMCReferenceData__c>();
//                String recordTypeId = Schema.SObjectType.HMCReferenceData__c.getRecordTypeInfosByDeveloperName().get('VehicleInfo').getRecordTypeId();
                for(DM1_QM_01_PRJVEHL_D__c obj : list_DM1_QM_01_PRJVEHL_D){

                    objHMHmcReferenceData = new HMCReferenceData__c();

                    if(mapQlprcorpplnt.get(obj.PRDN_CORP_CD__c) != null){

//                        objHMHmcReferenceData.RecordTypeId = recordTypeId;

                        String strSALE_BLND_CD = '';
                        if(obj.SALE_BLND_CD__c == 'H'){
                            strSALE_BLND_CD = 'Hyundai';
                        }
                        else if(obj.SALE_BLND_CD__c == 'G'){
                            strSALE_BLND_CD = 'Genesis';
                        }
//                        else if(obj.SALE_BLND_CD__c == 'K'){
//                            strSALE_BLND_CD = 'Kia';
//                        }
                        objHMHmcReferenceData.Make__c = strSALE_BLND_CD;
                        objHMHmcReferenceData.CBU_CKD__c = obj.CKD_SCN_CD__c;
//                        objHMHmcReferenceData.ProdCorp__c = obj.PRDN_CORP_CD__c + '( ' + mapQlprcorpplnt.get(obj.PRDN_CORP_CD__c).PRDN_PLNT_NM__c + ' / '+ mapQlprcorpplnt.get(obj.PRDN_CORP_CD__c).PRDN_CORP_A_NM__c + ' )';
                        objHMHmcReferenceData.ProdCorp__c = mapQlprcorpplnt.get(obj.PRDN_CORP_CD__c).PRDN_PLNT_NM__c  + '(' + mapQlprcorpplnt.get(obj.PRDN_CORP_CD__c).PRDN_CORP_A_NM__c + ')';

                        String strQLTY_CAR_TYPE_CD = '';
                        if(obj.QLTY_CAR_TYPE_CD__c == 'P'){
                            strQLTY_CAR_TYPE_CD = '승용(Passenger)';
                        }
                        else if(obj.QLTY_CAR_TYPE_CD__c == 'S'){
                            strQLTY_CAR_TYPE_CD = '소상(Small Commercial)';
                        }
                        else if(obj.QLTY_CAR_TYPE_CD__c == 'V'){
                            strQLTY_CAR_TYPE_CD = 'MPV';
                        }
                        else if(obj.QLTY_CAR_TYPE_CD__c == 'B'){
                            strQLTY_CAR_TYPE_CD = '버스(Bus)';
                        }
                        else if(obj.QLTY_CAR_TYPE_CD__c == 'T'){
                            strQLTY_CAR_TYPE_CD = '트럭(Truck)';
                        }
                        else if(obj.QLTY_CAR_TYPE_CD__c == 'M'){
                            strQLTY_CAR_TYPE_CD = '군용(Military)';
                        }
                        else if(obj.QLTY_CAR_TYPE_CD__c == 'Z'){
                            strQLTY_CAR_TYPE_CD = 'ETC';
                        }
                        else if(obj.QLTY_CAR_TYPE_CD__c == 'U'){
                            strQLTY_CAR_TYPE_CD = 'SUV';
                        }

                        objHMHmcReferenceData.VehicleType__c = strQLTY_CAR_TYPE_CD;

                        // Model change value mapping
                        if(mapMappingModel.containsKey(obj.PRJ_VEHL_NM__c)){
                            if(mapMappingModel.get(obj.PRJ_VEHL_NM__c).ChangeValue__c != null && mapMappingModel.get(obj.PRJ_VEHL_NM__c).ChangeValue__c != ''){
                                objHMHmcReferenceData.VehicleModel__c = mapMappingModel.get(obj.PRJ_VEHL_NM__c).ChangeValue__c;
                            }
                            else {
                                objHMHmcReferenceData.VehicleModel__c = obj.PRJ_VEHL_NM__c;
                            }
                        }
                        else {
                            if(!setMappingModel.contains(obj.PRJ_VEHL_NM__c)){

                                HMCReferenceDataMapping__c objMapping = new HMCReferenceDataMapping__c();
                                objMapping.InterfaceValue__c = obj.PRJ_VEHL_NM__c;
                                objMapping.Field__c = 'VehicleModel__c';
                                insertMappingTarget.add(objMapping);

                                setMappingModel.add(obj.PRJ_VEHL_NM__c);
                                newValueField.add('Vehicle Model');
                            }
                            objHMHmcReferenceData.VehicleModel__c = obj.PRJ_VEHL_NM__c;
                        }

                        objHMHmcReferenceData.ModelCode__c = obj.PRJ_VEHL_CD__c;

                        if(mapQltyvehleng.get(obj.PRDN_CORP_CD__c + obj.STD_VEHL_CD__c) == null && mapQltyvehltm.get(obj.PRDN_CORP_CD__c + obj.STD_VEHL_CD__c) == null ){
                            listHmcReferenceData.add(objHMHmcReferenceData);
                        }
                        else {

                            if(mapQltyvehleng.get(obj.PRDN_CORP_CD__c + obj.STD_VEHL_CD__c) != null){
                                for(DM1_QM_01_QLTYVEHLENG_I__c aa : mapQltyvehleng.get(obj.PRDN_CORP_CD__c + obj.STD_VEHL_CD__c)) {

                                    HMCReferenceData__c cloneEngine = objHMHmcReferenceData.clone();

                                    if(mapEngtyma.get(aa.ENG_TYMA_CD__c) != null ){

                                        // engine change value mapping
                                        String strEngine = mapEngtyma.get(aa.ENG_TYMA_CD__c).ENG_TYMA_NM__c;
                                        if(mapMappingEngine.containsKey(strEngine)){
                                            if(mapMappingEngine.get(strEngine).ChangeValue__c != null && mapMappingEngine.get(strEngine).ChangeValue__c != ''){
                                                cloneEngine.EngineDescription__c = mapMappingEngine.get(strEngine).ChangeValue__c;
                                            }
                                            else {
                                                cloneEngine.EngineDescription__c = strEngine;
                                            }
                                        }
                                        else {
                                            if(!setMappingEngine.contains(strEngine)) {

                                                HMCReferenceDataMapping__c objMapping = new HMCReferenceDataMapping__c();
                                                objMapping.InterfaceValue__c = strEngine;
                                                objMapping.Field__c = 'EngineDescription__c';
                                                insertMappingTarget.add(objMapping);

                                                setMappingEngine.add(strEngine);
                                                newValueField.add('Engine Description');
                                            }
                                            cloneEngine.EngineDescription__c = strEngine;
                                        }
                                        listHmcReferenceData.add(cloneEngine);
                                    }
                                }
                            }

                            if(mapQltyvehltm.get(obj.PRDN_CORP_CD__c + obj.STD_VEHL_CD__c) != null ){
                                Set<String> setPRJCD = new Set<String>();
                                for(DM1_QM_01_QLTYVEHLTM_I__c bb : mapQltyvehltm.get(obj.PRDN_CORP_CD__c + obj.STD_VEHL_CD__c)){

                                    HMCReferenceData__c cloneTransmission = objHMHmcReferenceData.clone();

                                    if(!setPRJCD.contains(bb.TM_PRJ_CD__c)){
                                        // Transmission change value mapping
                                        if(mapMappingTransmission.containsKey(bb.TM_PRJ_CD__c)){
                                            if(mapMappingTransmission.get(bb.TM_PRJ_CD__c).ChangeValue__c != null && mapMappingTransmission.get(bb.TM_PRJ_CD__c).ChangeValue__c != ''){
                                                cloneTransmission.TransmissionDescription__c = mapMappingTransmission.get(bb.TM_PRJ_CD__c).ChangeValue__c;
                                            }
                                            else {
                                                cloneTransmission.TransmissionDescription__c = bb.TM_PRJ_CD__c;
                                            }
                                        }
                                        else {
                                            if(!setMappingTransmission.contains(bb.TM_PRJ_CD__c)) {

                                                HMCReferenceDataMapping__c objMapping = new HMCReferenceDataMapping__c();
                                                objMapping.InterfaceValue__c = bb.TM_PRJ_CD__c;
                                                objMapping.Field__c = 'TransmissionDescription__c';
                                                insertMappingTarget.add(objMapping);

                                                setMappingTransmission.add(bb.TM_PRJ_CD__c);
                                                newValueField.add('Transmission Description');
                                            }
                                            cloneTransmission.TransmissionDescription__c = bb.TM_PRJ_CD__c;
                                        }
                                        setPRJCD.add(bb.TM_PRJ_CD__c);
                                        listHmcReferenceData.add(cloneTransmission);
                                    }
                                }
                            }


                            KASO_VIN_Mapping__c vinMapping = new KASO_VIN_Mapping__c();

                            vinMapping.Make__c = objHMHmcReferenceData.Make__c;
                            vinMapping.CBU_CKD__c = objHMHmcReferenceData.CBU_CKD__c;
                            vinMapping.ProdCorp__c = objHMHmcReferenceData.ProdCorp__c;
                            vinMapping.VehicleType__c = objHMHmcReferenceData.VehicleType__c;
                            vinMapping.ModelCode__c = objHMHmcReferenceData.ModelCode__c;

                            vinMapping.Model_Interface_Value__c = obj.PRJ_VEHL_NM__c;
                            if(mapMappingModel.containsKey(obj.PRJ_VEHL_NM__c)){
                                if(mapMappingModel.get(obj.PRJ_VEHL_NM__c).ChangeValue__c != null && mapMappingModel.get(obj.PRJ_VEHL_NM__c).ChangeValue__c != ''){
                                    vinMapping.Model__c = mapMappingModel.get(obj.PRJ_VEHL_NM__c).ChangeValue__c;
                                }
                            }

                            // KASO VIN Mapping Data 추가
                            if(mapQltyvehleng.get(obj.PRDN_CORP_CD__c + obj.STD_VEHL_CD__c) != null){
                                for(DM1_QM_01_QLTYVEHLENG_I__c eng : mapQltyvehleng.get(obj.PRDN_CORP_CD__c + obj.STD_VEHL_CD__c)){

                                    if(mapEngtyma.get(eng.ENG_TYMA_CD__c) != null ){

                                        KASO_VIN_Mapping__c cloneEng = vinMapping.clone();


                                        String strEngine = mapEngtyma.get(eng.ENG_TYMA_CD__c).ENG_TYMA_NM__c;

                                        if(mapQltyvehltm.get(obj.PRDN_CORP_CD__c + obj.STD_VEHL_CD__c) != null){

                                            for(DM1_QM_01_QLTYVEHLTM_I__c tm : mapQltyvehltm.get(obj.PRDN_CORP_CD__c + obj.STD_VEHL_CD__c)){

                                                String engKey = obj.PRJ_VEHL_NM__c + '_' + strEngine;
                                                String strKey = obj.PRJ_VEHL_NM__c + '_' + strEngine + '_' + tm.TM_PRJ_CD__c;


                                                if(!VINMappingKey.contains(engKey)){
                                                    KASO_VIN_Mapping__c cloneEngine = cloneEng.clone();

                                                    cloneEngine.Engine_Interface_Value__c = strEngine;
                                                    if(mapMappingEngine.containsKey(strEngine)){
                                                        if(mapMappingEngine.get(strEngine).ChangeValue__c != null && mapMappingEngine.get(strEngine).ChangeValue__c != ''){
                                                            cloneEngine.EngineDesciption__c = mapMappingEngine.get(strEngine).ChangeValue__c;
                                                        }
                                                    }
                                                    insertVINMapping.add(cloneEngine);
                                                    VINMappingKey.add(engKey);
                                                }

                                                if(!VINMappingKey.contains(strKey)){
                                                    KASO_VIN_Mapping__c cloneTm = cloneEng.clone();

                                                    cloneTm.Engine_Interface_Value__c = strEngine;
                                                    if(mapMappingEngine.containsKey(strEngine)){
                                                        if(mapMappingEngine.get(strEngine).ChangeValue__c != null && mapMappingEngine.get(strEngine).ChangeValue__c != ''){
                                                            cloneTm.EngineDesciption__c = mapMappingEngine.get(strEngine).ChangeValue__c;
                                                        }
                                                    }
                                                    cloneTm.Transmission_Interface_Value__c = tm.TM_PRJ_CD__c;
                                                    if(mapMappingTransmission.containsKey(tm.TM_PRJ_CD__c)){
                                                        if(mapMappingTransmission.get(tm.TM_PRJ_CD__c).ChangeValue__c != null && mapMappingTransmission.get(tm.TM_PRJ_CD__c).ChangeValue__c != ''){
                                                            cloneTm.TransmissionDesc__c = mapMappingTransmission.get(tm.TM_PRJ_CD__c).ChangeValue__c;
                                                        }
                                                    }
                                                    insertVINMapping.add(cloneTm);
                                                    VINMappingKey.add(strKey);
                                                }
                                            }
                                        }
                                        else {
                                            String strKey = obj.PRJ_VEHL_NM__c + '_' + strEngine;
                                            if(!VINMappingKey.contains(strKey)){
                                                cloneEng.Engine_Interface_Value__c = strEngine;
                                                if(mapMappingEngine.containsKey(strEngine)){
                                                    if(mapMappingEngine.get(strEngine).ChangeValue__c != null && mapMappingEngine.get(strEngine).ChangeValue__c != ''){
                                                        cloneEng.EngineDesciption__c = mapMappingEngine.get(strEngine).ChangeValue__c;
                                                    }
                                                }
                                                insertVINMapping.add(cloneEng);
                                                VINMappingKey.add(strKey);
                                            }
                                        }
                                    }
                                }
                            }
                            else {
//                                insertVINMapping.add(vinMapping);
                            }
                        }
                    }
                }
                if(!listHmcReferenceData.isEmpty()){
                    insert listHmcReferenceData;
                }

                if(!insertVINMapping.isEmpty()){
                    insert insertVINMapping;
                    fuelTypeNewCheck = true;
                }
            }
        }catch(Exception e) {
            errorStatus = true;
            System.debug('[ERROR][Line: ' + e.getLineNumber() + ' / Message: ' + e.getMessage() + ' / Cause: ' + e.getCause());
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('HMCReferenceDataInsert_ba finish :: ');

        // new Mapping Data insert
        if(!insertMappingTarget.isEmpty()){
            insert insertMappingTarget;

            List<User> listUser = new List<User>([
                    SELECT  Id, Name, Email
                    FROM    User
                    WHERE   Profile.Name = '(KASO) System Admin'
                    AND     (LastName = '박덕진' OR LastName = '고상욱' OR LastName = '김동규' OR LastName = '장영준' OR LastName = '서민수')
            ]);
            List<String> emailTarget = new List<String>();
            if(!listUser.isEmpty()) {
                for (User obj : listUser) {
                    if (obj.Email != null) {
                        emailTarget.add(obj.Email);
                    }
                }

                if (!emailTarget.isEmpty()) {

                    String sendBody = '';
                    sendBody += 'HMC Reference Data 에 새로운 항목이 추가되었습니다.<br/>';
                    sendBody += '아래 목록 확인하시어 매핑값 입력 부탁드립니다.<br/><br/>';
                    sendBody += '항목 : ' + newValueField;

                    List<OrgWideEmailAddress> kasoEmail = new List<OrgWideEmailAddress>([
                            SELECT Id, Address, DisplayName, IsAllowAllProfiles, Purpose
                            FROM OrgWideEmailAddress
                            WHERE DisplayName = 'KASO CMT Administrator'
                    ]);

                    List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setOrgWideEmailAddressId(kasoEmail[0].Id);
                    email.setToAddresses(emailTarget);  // 수신자 이메일 주소
                    email.setSubject('HMC Reference Data 에 새로운 항목이 추가되었습니다.');  // 이메일 제목
                    email.setHtmlBody(sendBody);  // 이메일 내용
                    listEmail.add(email);
                    Messaging.sendEmail(listEmail);
                }
            }
        }

        if(fuelTypeNewCheck){
            List<User> listUser = new List<User>([
                    SELECT  Id, Name, Email
                    FROM    User
                    WHERE   Profile.Name = '(KASO) System Admin'
                    AND     (LastName = '박덕진' OR LastName = '고상욱' OR LastName = '김동규' OR LastName = '장영준' OR LastName = '서민수')
            ]);
            List<String> emailTarget = new List<String>();
            if(!listUser.isEmpty()) {
                for (User obj : listUser) {
                    if (obj.Email != null) {
                        emailTarget.add(obj.Email);
                    }
                }

                if (!emailTarget.isEmpty()) {

                    String sendBody = '<br/>';
                    sendBody += 'Fuel Type Mapping Data 에 새로운 항목이 추가되었습니다.<br/>';
                    sendBody += '매핑값 입력 부탁드립니다.<br/><br/>';
                    sendBody += '감사합니다.';

                    List<OrgWideEmailAddress> kasoEmail = new List<OrgWideEmailAddress>([
                            SELECT Id, Address, DisplayName, IsAllowAllProfiles, Purpose
                            FROM OrgWideEmailAddress
                            WHERE DisplayName = 'KASO CMT Administrator'
                    ]);

                    List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setOrgWideEmailAddressId(kasoEmail[0].Id);
                    email.setToAddresses(emailTarget);  // 수신자 이메일 주소
                    email.setSubject('Fuel Type Mapping Data 신규 추가 건');  // 이메일 제목
                    email.setHtmlBody(sendBody);  // 이메일 내용
                    listEmail.add(email);
                    Messaging.sendEmail(listEmail);
                }
            }
        }

        // Previous ReferenceData Delete
        if(!errorStatus && !listHMCReferenceData.isEmpty()){
            delete listHMCReferenceData;
        }
    }
}