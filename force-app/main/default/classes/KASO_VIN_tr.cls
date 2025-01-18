/**
 * Created by dw.lee on 2023-10-17.
 */

public with sharing class KASO_VIN_tr extends KASOTriggerHandler{
    public KASO_VIN_tr() {
        mapNew = (Map<Id, KASO_VIN__c>) trigger.newMap;
        listNew = (List<KASO_VIN__c>) trigger.new;
        mapOld = (Map<Id, KASO_VIN__c>) trigger.oldMap;
        listOld = (List<KASO_VIN__c>) trigger.old;
    }

    /**
     * TriggerHandler
     */
    private List<KASO_VIN__c> listNew { get; set; }
    private Map<Id, KASO_VIN__c> mapNew { get; set; }
    private List<KASO_VIN__c> listOld { get; set; }
    private Map<Id, KASO_VIN__c> mapOld { get; set; }

    public override void beforeInsert() {
        changeValueInsert();
        setFuelType();
    }
    public override void afterInsert() {
    }
    public override void beforeUpdate() {
    }
    public override void afterUpdate() {
    }
    public override void beforeDelete() {
    }
    public override void afterDelete() {
    }

    /***********************************************************************************************************
    *  Trigger : before Insert
    *  Action  : KASO_VIN__c Data 생성 시
    *  내용    :  HMCReferenceDataMapping__c 오브젝트의 데이터 조회 후 맵핑작업 진행
    *  작성자   : dw.lee
    ************************************************************************************************************/
    private void changeValueInsert(){
        System.debug('KASO_VIN__c Trigget :: changeValueInsert');

        List<HMCReferenceDataMapping__c> listHMCReferenceDataMappings = new List<HMCReferenceDataMapping__c>([
            SELECT  Id, InterfaceValue__c, ChangeValue__c, Field__c
            FROM    HMCReferenceDataMapping__c
        ]);

        if(!listHMCReferenceDataMappings.isEmpty()){

            Map<String, HMCReferenceDataMapping__c> mapChangeModel = new Map<String, HMCReferenceDataMapping__c>();
            Map<String, HMCReferenceDataMapping__c> mapChangeEngine = new Map<String, HMCReferenceDataMapping__c>();
            Map<String, HMCReferenceDataMapping__c> mapChangeTransmission= new Map<String, HMCReferenceDataMapping__c>();

            for(HMCReferenceDataMapping__c hmc : listHMCReferenceDataMappings){
                if(hmc.Field__c == 'VehicleModel__c'){
                    mapChangeModel.put(hmc.InterfaceValue__c, hmc);
                }
                else if(hmc.Field__c == 'EngineDescription__c'){
                    mapChangeEngine.put(hmc.InterfaceValue__c, hmc);
                }
                else if(hmc.Field__c == 'TransmissionDescription__c'){
                    mapChangeTransmission.put(hmc.InterfaceValue__c, hmc);
                }
            }

            for(KASO_VIN__c obj : listNew){

                if(obj.ModelDesc__c != null && mapChangeModel.containsKey(obj.ModelDesc__c) && mapChangeModel.get(obj.ModelDesc__c).ChangeValue__c != null){
                    obj.ModelDesc__c = mapChangeModel.get(obj.ModelDesc__c).ChangeValue__c;
                }

                if(obj.EngineDesc__c != null && mapChangeEngine.containsKey(obj.EngineDesc__c) && mapChangeEngine.get(obj.EngineDesc__c).ChangeValue__c != null) {
                    obj.EngineDesc__c = mapChangeEngine.get(obj.EngineDesc__c).ChangeValue__c;
                }

                if(obj.TransmissionDesc__c != null && mapChangeTransmission.containsKey(obj.TransmissionDesc__c) && mapChangeTransmission.get(obj.TransmissionDesc__c).ChangeValue__c != null) {
                    if(mapChangeTransmission.get(obj.TransmissionDesc__c).ChangeValue__c == 'N/A'){
                        obj.TransmissionDesc__c = '';
                    }
                    else {
                        obj.TransmissionDesc__c = mapChangeTransmission.get(obj.TransmissionDesc__c).ChangeValue__c;
                    }
                }

            }
        }
    }

    /***********************************************************************************************************
    *  Trigger : before Insert
    *  Action  : KASO_VIN__c Data 생성 시
    *  내용    :  KASO_VIN_Mapping__c 오브젝트의 데이터 조회 후 Fuel Type Setting
    *  작성자   : dw.lee
    ************************************************************************************************************/
    private void setFuelType(){
        System.debug('KASO_VIN__c Trigget :: setFuelType');

        List<KASO_VIN_Mapping__c> listMappings = new List<KASO_VIN_Mapping__c>([
                SELECT  Id, Model__c, EngineDesciption__c, TransmissionDesc__c, FuelType__c
                FROM    KASO_VIN_Mapping__c
        ]);

        if(!listMappings.isEmpty()){
            Map<String, KASO_VIN_Mapping__c> mapMapping = new Map<String, KASO_VIN_Mapping__c>();
            for(KASO_VIN_Mapping__c vin : listMappings){
                String strKey = '';
                if(vin.TransmissionDesc__c != null){
                    strKey = vin.Model__c + '_' + vin.EngineDesciption__c + '_' + vin.TransmissionDesc__c;
                }
                else {
                    strKey = vin.Model__c + '_' + vin.EngineDesciption__c;
                }
                if(!mapMapping.keySet().contains(strKey)){
                    mapMapping.put(strKey, vin);
                }
            }

            for(KASO_VIN__c obj : listNew){
                String vinKey = '';
                if(obj.TransmissionDesc__c != null && obj.TransmissionDesc__c != ''){
                    if(obj.TransmissionDesc__c == '@'){
                        obj.TransmissionDesc__c = '';
                        vinKey = obj.ModelDesc__c + '_' + obj.EngineDesc__c;
                    }
                    else {
                        vinKey = obj.ModelDesc__c + '_' + obj.EngineDesc__c + '_' + obj.TransmissionDesc__c;
                        if(!mapMapping.containsKey(vinKey)){
                            vinKey = obj.ModelDesc__c + '_' + obj.EngineDesc__c;
                        }
//                        vinKey = obj.ModelDesc__c + '_' + obj.EngineDesc__c + '_' + obj.TransmissionDesc__c;
                    }
                }
                else {
                    vinKey = obj.ModelDesc__c + '_' + obj.EngineDesc__c;
                }

                if(mapMapping.containsKey(vinKey)){
                    obj.FuelType__c = mapMapping.get(vinKey).FuelType__c;
                }
                else {
                    obj.FuelType__c = '';
                }
            }
        }
    }
}