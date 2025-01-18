/**
 * Created by dw.lee on 2023-10-16.
 */

@IsTest
public with sharing class HMCReferenceDataInsert_ba_Test {


    @TestSetup
    static void setupData(){

        HMCReferenceData__c objHmcReferenceData = new HMCReferenceData__c();
        objHmcReferenceData.Make__c = 'Hyundai';
        objHmcReferenceData.CBU_CKD__c = 'CBU';
        objHmcReferenceData.ProdCorp__c = 'H201( HMMA / 현대미국생산법인 )';
        objHmcReferenceData.VehicleType__c = '승용';
        objHmcReferenceData.VehicleModel__c = '(YFa) YF SONATA [IN]';
        objHmcReferenceData.ModelCode__c = 'YFA';
        objHmcReferenceData.EngineDescription__c = 'θ-Ⅱ 2.0(TGDI)';
        objHmcReferenceData.TransmissionDescription__c = 'A6MF2';
        insert objHmcReferenceData;

        List<DM1_QM_01_PRJVEHL_D__c> listPrjvehlD = new List<DM1_QM_01_PRJVEHL_D__c>();

        DM1_QM_01_PRJVEHL_D__c objPrjvehlD_A = new DM1_QM_01_PRJVEHL_D__c();
        objPrjvehlD_A.PRDN_CORP_CD__c = 'K6C2';
        objPrjvehlD_A.STD_VEHL_CD__c = 'A7';
        objPrjvehlD_A.PRJ_VEHL_CD__c = 'YD';
        objPrjvehlD_A.PRJ_VEHL_NM__c = '(YD) K3 [A7]';
        objPrjvehlD_A.QLTY_CAR_TYPE_CD__c = 'P';
//        objPrjvehlD_A.SALE_BLND_CD__c = 'K';
        objPrjvehlD_A.SALE_BLND_CD__c = 'H';
        objPrjvehlD_A.CKD_SCN_CD__c = 'CKD';
        objPrjvehlD_A.USE_YN__c = 'Y';
        objPrjvehlD_A.ExternelKey__c = '';
        listPrjvehlD.add(objPrjvehlD_A);

        DM1_QM_01_PRJVEHL_D__c objPrjvehlD_B = objPrjvehlD_A.clone();
        objPrjvehlD_B.QLTY_CAR_TYPE_CD__c = 'S';
        listPrjvehlD.add(objPrjvehlD_B);

        DM1_QM_01_PRJVEHL_D__c objPrjvehlD_C = objPrjvehlD_A.clone();
        objPrjvehlD_C.QLTY_CAR_TYPE_CD__c = 'V';
        listPrjvehlD.add(objPrjvehlD_C);

        DM1_QM_01_PRJVEHL_D__c objPrjvehlD_D = objPrjvehlD_A.clone();
        objPrjvehlD_D.QLTY_CAR_TYPE_CD__c = 'B';
        listPrjvehlD.add(objPrjvehlD_D);

        DM1_QM_01_PRJVEHL_D__c objPrjvehlD_E = objPrjvehlD_A.clone();
        objPrjvehlD_E.QLTY_CAR_TYPE_CD__c = 'T';
        listPrjvehlD.add(objPrjvehlD_E);

        DM1_QM_01_PRJVEHL_D__c objPrjvehlD_F = objPrjvehlD_A.clone();
        objPrjvehlD_F.QLTY_CAR_TYPE_CD__c = 'M';
        listPrjvehlD.add(objPrjvehlD_F);

        DM1_QM_01_PRJVEHL_D__c objPrjvehlD_G = objPrjvehlD_A.clone();
        objPrjvehlD_G.QLTY_CAR_TYPE_CD__c = 'Z';
        listPrjvehlD.add(objPrjvehlD_G);

        DM1_QM_01_PRJVEHL_D__c objPrjvehlD_H = objPrjvehlD_A.clone();
        objPrjvehlD_H.QLTY_CAR_TYPE_CD__c = 'U';
        listPrjvehlD.add(objPrjvehlD_H);
        insert listPrjvehlD;

        DM1_QM_07_QLPRCORPPLNT_D__c objQlprcorpplntD = new DM1_QM_07_QLPRCORPPLNT_D__c();
        objQlprcorpplntD.PRDN_CORP_CD__c = 'K6C2';
        objQlprcorpplntD.STD_PLNT_CD__c = 'KVX3';
        objQlprcorpplntD.PLNT_TYPE_CD__c = 'V';
        objQlprcorpplntD.PRDN_PLNT_NM__c = 'THACO';
        objQlprcorpplntD.PRDN_CORP_A_NM__c = '기아 베트남 쫑하이 CKD';
        objQlprcorpplntD.USE_YN__c = 'Y';
        objQlprcorpplntD.ExternelKey__c = '';
        insert objQlprcorpplntD;

        DM1_QM_01_QLTYVEHLENG_I__c objQltyvehlengI = new DM1_QM_01_QLTYVEHLENG_I__c();
        objQltyvehlengI.PRDN_CORP_CD__c = 'K6C2';
        objQltyvehlengI.STD_VEHL_CD__c = 'A7';
        objQltyvehlengI.ENG_TYMA_CD__c = 'D26';
        objQltyvehlengI.USE_YN__c = 'Y';
        objQltyvehlengI.ExternelKey__c = '';
        insert objQltyvehlengI;

        DM1_QM_01_ENGTYMA_D__c objEngTymaD = new DM1_QM_01_ENGTYMA_D__c();
        objEngTymaD.ENG_TYMA_CD__c = 'D26';
        objEngTymaD.ENG_SCN_CD__c = 'G';
        objEngTymaD.ENG_TYMA_NM__c = 'γ 1.6';
        objEngTymaD.USE_YN__c = 'Y';
        objEngTymaD.ExternelKey__c = '';
        insert objEngTymaD;

        DM1_QM_01_QLTYVEHLTM_I__c objQltyvehltmI = new DM1_QM_01_QLTYVEHLTM_I__c();
        objQltyvehltmI.PRDN_CORP_CD__c = 'K6C2';
        objQltyvehltmI.STD_VEHL_CD__c = 'A7';
        objQltyvehltmI.TM_PRDN_PLNT_CD__c = 'RTP1';
        objQltyvehltmI.TM_PRJ_CD__c = 'A6MF2';
        objQltyvehltmI.USE_YN__c = 'Y';
        objQltyvehltmI.ExternelKey__c = '';
        insert objQltyvehltmI;

        List<HMCReferenceDataMapping__c> listMapping = new List<HMCReferenceDataMapping__c>();
        HMCReferenceDataMapping__c objMapping1 = new HMCReferenceDataMapping__c();
        objMapping1.Field__c = 'VehicleModel__c';
        objMapping1.ChangeValue__c = 'test 1';
        objMapping1.InterfaceValue__c = 'test1';
        listMapping.add(objMapping1);

        HMCReferenceDataMapping__c objMapping2 = new HMCReferenceDataMapping__c();
        objMapping2.Field__c = 'EngineDescription__c';
        objMapping2.ChangeValue__c = 'test 2';
        objMapping2.InterfaceValue__c = 'test2';
        listMapping.add(objMapping2);

        HMCReferenceDataMapping__c objMapping3 = new HMCReferenceDataMapping__c();
        objMapping3.Field__c = 'TransmissionDescription__c';
        objMapping3.ChangeValue__c = 'test 3';
        objMapping3.InterfaceValue__c = 'test3';
        listMapping.add(objMapping3);

        insert listMapping;


        KASO_VIN_Mapping__c objVINMapping = new KASO_VIN_Mapping__c();
        objVINMapping.Model_Interface_Value__c = '(YD) K3 [A7]';
        objVINMapping.Model__c = 'K3';
        objVINMapping.Engine_Interface_Value__c = 'γ 1.6';
        objVINMapping.EngineDesciption__c = '1.6L';
        objVINMapping.Transmission_Interface_Value__c = 'A6MF2';
        objVINMapping.TransmissionDesc__c = 'A6MF2';
        objVINMapping.FuelType__c = 'GAS';
        insert objVINMapping;

    }

    @IsTest
    static void runTest(){

        Test.startTest();

        HMCReferenceDataInsert_ba testBatch = new HMCReferenceDataInsert_ba();
        Database.executeBatch(testBatch, 100);

        Test.stopTest();
    }
}