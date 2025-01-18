public with sharing class FuelTypeMappingController {

    @AuraEnabled
    public static List<MappingWrapper> getKASOVinMappingData(String keyword, Boolean Type){
        List<KASO_VIN_Mapping__c> listKASOVin = new List<KASO_VIN_Mapping__c>();
        List<MappingWrapper> listKASOVinReturn= new List<MappingWrapper>();

        String query = '';
        query += 'SELECT Id, FuelType__c, Engine_Interface_Value__c, Transmission_Interface_Value__c, Model_Interface_Value__c, TransmissionDesc__c, EngineDesciption__c, Model__c, LastModifiedDate, LastModifiedBy.Name  ';
        query += ' FROM KASO_VIN_Mapping__c  ';

        if(Type == true || (keyword != null && keyword != '')){
            query += ' WHERE ';
            if(Type) query += ' FuelType__c = NULL ';

            if(Type && keyword != null && keyword !='') query += ' AND ';

            if(keyword != null && keyword != '') query += ' ( EngineDesciption__c LIKE \'%' + keyword + '%\' OR Engine_Interface_Value__c LIKE \'%' + keyword + '%\' OR TransmissionDesc__c LIKE \'%' + keyword + '%\' OR Transmission_Interface_Value__c LIKE \'%' + keyword + '%\' OR Model__c LIKE \'%' + keyword + '%\' OR Model_Interface_Value__c LIKE \'%' + keyword + '%\' OR FuelType__c LIKE \'%' + keyword + '%\' )';

        }

        if(query != null){
            listKASOVin = Database.query(query);
        }

        if(listKASOVin.size() > 0){
            for(KASO_VIN_Mapping__c obj : listKASOVin){
                MappingWrapper objWrapper = new MappingWrapper(obj);
                listKASOVinReturn.add(objWrapper);
            }
        }
        return listKASOVinReturn;
    }

    @AuraEnabled
    public static String saveKASOVinMappingData(String listChangeKASOVinData) {
        String strReturn = '';

        Map<Id, String> mapUpdate = new Map<Id, String>();
        List<MappingWrapper> listWrapper = (List<MappingWrapper>) JSON.deserializeStrict(listChangeKASOVinData, List<MappingWrapper>.class);

        if(listWrapper.size() > 0){
            for(MappingWrapper obj : listWrapper){
                if(obj.fuelType != null && obj.fuelType !=''){
                    mapUpdate.put(obj.wrapperId, obj.fuelType);
                }
            }
        }


        List<KASO_VIN_Mapping__c> listQueryMapping = new List<KASO_VIN_Mapping__c>();
        List<KASO_VIN_Mapping__c> listUpdate = new List<KASO_VIN_Mapping__c>();

        if(mapUpdate.keySet().size() > 0){
            listQueryMapping = [
                    SELECT  Id, FuelType__c
                    FROM    KASO_VIN_Mapping__c
                    WHERE   Id =: mapUpdate.keySet()
            ];

            if(listQueryMapping.size() > 0){
                for(KASO_VIN_Mapping__c obj : listQueryMapping){
                    if(mapUpdate.get(obj.Id) != null){
                        KASO_VIN_Mapping__c target = new KASO_VIN_Mapping__c();
                        target.Id = obj.Id;
                        target.FuelType__c = mapUpdate.get(obj.Id);
                        listUpdate.add(target);
                    }
                }
            }

            if(listUpdate.size() > 0){

                try{
                    update listUpdate;
                    strReturn = 'SUCCESS';
                } catch (Exception e){
                    System.debug('====ERROR=====');
                    System.debug('error message :: ' + e.getMessage());
                    System.debug('error getLineNumber :: ' + e.getLineNumber());
                    System.debug('====ERROR=====');

                    strReturn = e.getMessage();
                }
            }else{
                strReturn = 'No Data';
            }

        }
        return strReturn;
    }

    public class MappingWrapper{
        @AuraEnabled public Id     wrapperId;
        @AuraEnabled public String model;
        @AuraEnabled public String modelIF;
        @AuraEnabled public String engin;
        @AuraEnabled public String enginIF;
        @AuraEnabled public String transmission;
        @AuraEnabled public String transmissionIF;
        @AuraEnabled public String fuelType;
        @AuraEnabled public String lastModifiedDate;
        @AuraEnabled public String lastModifiedName;


        public MappingWrapper(KASO_VIN_Mapping__c obj){
            this.wrapperId = obj.Id;
            this.model = obj.Model__c != null ? obj.Model__c : '';
            this.modelIF = obj.Model_Interface_Value__c != null ? obj.Model_Interface_Value__c : '';
            this.engin = obj.EngineDesciption__c != null ? obj.EngineDesciption__c : '';
            this.enginIF = obj.Engine_Interface_Value__c != null ? obj.Engine_Interface_Value__c : '';
            this.transmission = obj.TransmissionDesc__c != null ? obj.TransmissionDesc__c : '';
            this.transmissionIF = obj.Transmission_Interface_Value__c != null ? obj.Transmission_Interface_Value__c : '';
            this.fuelType = obj.FuelType__c != null ? obj.FuelType__c : '';
            this.lastModifiedDate = obj.LastModifiedDate != null ? obj.LastModifiedDate.format('yyyy. MM. dd a hh:mm') : null;
            this.lastModifiedName = obj.LastModifiedBy.Name != null ? obj.LastModifiedBy.Name : '';

        }
    }


}