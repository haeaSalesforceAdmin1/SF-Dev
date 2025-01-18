/**
 * Created by dw.lee on 2023-10-16.
 */

public with sharing class HMCReferenceDataMapping_tr extends KASOTriggerHandler{
    public HMCReferenceDataMapping_tr() {
        mapNew = (Map<Id, HMCReferenceDataMapping__c>) trigger.newMap;
        listNew = (List<HMCReferenceDataMapping__c>) trigger.new;
        mapOld = (Map<Id, HMCReferenceDataMapping__c>) trigger.oldMap;
        listOld = (List<HMCReferenceDataMapping__c>) trigger.old;
    }

    /**
     * TriggerHandler
     */
    private List<HMCReferenceDataMapping__c> listNew { get; set; }
    private Map<Id, HMCReferenceDataMapping__c> mapNew { get; set; }
    private List<HMCReferenceDataMapping__c> listOld { get; set; }
    private Map<Id, HMCReferenceDataMapping__c> mapOld { get; set; }

    public override void beforeInsert() {
    }
    public override void afterInsert() {
    }
    public override void beforeUpdate() {
    }
    public override void afterUpdate() {
        changeValueUpdate();
    }
    public override void beforeDelete() {
    }
    public override void afterDelete() {
    }

    /***********************************************************************************************************
    *  Trigger : after Update
    *  Action  : HMCReferenceDataMapping__c Data 의 IsActive Field 업데이트 시
    *  내용    :  HMCReferenceData__c 의 데이터를 InterfaceValue__c 및 ChangeValue__c 필드의 값으로 업데이트 해준다
    *  작성자   : dw.lee
    ************************************************************************************************************/
    private void changeValueUpdate(){
        System.debug('HMCReferenceDataMapping__c Trigget :: changeValueUpdate');

        String strField = '';
        Set<String> queryTarget = new Set<String>();
        Map<String, String> mapChangeValue = new Map<String, String>();

        for(HMCReferenceDataMapping__c obj : listNew){
            strField = obj.Field__c;

            if(mapOld != null && mapOld.get(obj.Id).ChangeValue__c <> obj.ChangeValue__c){

                if(mapOld.get(obj.Id).ChangeValue__c == null && obj.ChangeValue__c != null){
                    queryTarget.add(obj.InterfaceValue__c);
                    mapChangeValue.put(obj.InterfaceValue__c, obj.ChangeValue__c);
                }
                else if(mapOld.get(obj.Id).ChangeValue__c != null && obj.ChangeValue__c != null){
                    queryTarget.add(mapOld.get(obj.Id).ChangeValue__c);
                    mapChangeValue.put(mapOld.get(obj.Id).ChangeValue__c, obj.ChangeValue__c);
                }
            }
        }

        System.debug('queryTarget :: ' + queryTarget);

        if(!queryTarget.isEmpty()){
            // HMCReferenceData__c 조회
            String strQuery = 'SELECT';
            strQuery += ' Id, VehicleModel__c, EngineDescription__c, TransmissionDescription__c';
            strQuery += ' FROM';
            strQuery += ' HMCReferenceData__c';
            strQuery += ' WHERE ' + strField + ' IN :queryTarget';

            System.debug('strQuery ::' + strQuery);

            List<HMCReferenceData__c> listHmcReferenceData = Database.query(strQuery);

            System.debug('size :: ' + listHmcReferenceData.size());

            if(!listHmcReferenceData.isEmpty()){
                for(HMCReferenceData__c hmc : listHmcReferenceData){
                    if(strField == 'VehicleModel__c'){
                        hmc.VehicleModel__c = mapChangeValue.get(hmc.VehicleModel__c);
                    }
                    else if(strField == 'EngineDescription__c'){
                        hmc.EngineDescription__c = mapChangeValue.get(hmc.EngineDescription__c);
                    }
                    else if(strField == 'TransmissionDescription__c'){
                        hmc.TransmissionDescription__c = mapChangeValue.get(hmc.TransmissionDescription__c);
                    }

                    System.debug('hmc :: ' + hmc);
                }
                update listHmcReferenceData;
            }
        }
    }
}