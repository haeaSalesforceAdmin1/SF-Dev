public with sharing class VehicleMappingController {
    @AuraEnabled
    public static List<ComboBoxWrapper> getFieldLabelInfo() {
        List<ComboBoxWrapper> listFieldInfo = new List<ComboBoxWrapper>();

        String type = 'HMCReferenceData__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        for (String fieldName : new String[]{
                'VehicleModel__c', 'EngineDescription__c', 'TransmissionDescription__c'
        }) {
            if (fieldMap.containsKey(fieldName)) {
                ComboBoxWrapper objWrapper = new ComboBoxWrapper();
                objWrapper.label = fieldMap.get(fieldName).getDescribe().getLabel();
                objWrapper.value = fieldName;
                listFieldInfo.add(objWrapper);
            }
        }

        return listFieldInfo;
    }


    @AuraEnabled
    public static List<MappingWrapper> getListHMCMappingInfo(String selectedValue, String keyword, Boolean Type) {
        List<HMCReferenceDataMapping__c> listHMCDataMapping = new List<HMCReferenceDataMapping__c>();
        List<MappingWrapper> listReturn = new List<MappingWrapper>();

        String query = '';
        query += ' SELECT   Field__c, InterfaceValue__c, ChangeValue__c, LastModifiedDate, LastModifiedBy.Name ';
        query += ' FROM     HMCReferenceDataMapping__c ';
        query += ' WHERE    Field__c = \'' + selectedValue + '\'' ;

        if(Type != null){
            if(Type){
                query += ' AND ChangeValue__c = NULL ';
            }
        }

        if (keyword != null && keyword != '') {
            query += ' AND (InterfaceValue__c LIKE \'%' + keyword + '%\' OR ChangeValue__c LIKE \'%' + keyword + '%\' )';
        }

        query += ' ORDER BY InterfaceValue__c ASC ';


        if (query != null) {
            listHMCDataMapping = Database.query(query);
        }

        if (listHMCDataMapping.size() > 0) {
            for (HMCReferenceDataMapping__c objMapping : listHMCDataMapping) {
                MappingWrapper objWrapper = new MappingWrapper(objMapping);
                listReturn.add(objWrapper);
            }
        }

        return listReturn;
    }


    @AuraEnabled
    public static String updateMappingData(String listChangeHMCData, String selectedFieldValue) {
        String reActiveResult = '';
        String query = '';
        List<HMCReferenceDataMapping__c> listHMCMapping = new List<HMCReferenceDataMapping__c>();
        List<HMCReferenceDataMapping__c> listUpdateHMCMapping = new List<HMCReferenceDataMapping__c>();
        Map<String, String> mapChangeValue = new Map<String, String>();
        Set<String> setIFValue = new Set<String>();

        List<MappingWrapper> listWrapper = (List<MappingWrapper>) JSON.deserializeStrict(listChangeHMCData, List<MappingWrapper>.class);

        if (listWrapper.size() > 0 && selectedFieldValue != null) {
            for(MappingWrapper obj : listWrapper){
                if(obj.originValue != null && obj.originValue != '' && obj.changeValue != null && obj.changeValue != ''){
                    mapChangeValue.put(obj.originValue, obj.changeValue);
                    setIFValue.add(obj.originValue);
                }
            }

            if (mapChangeValue.size() > 0  && setIFValue.size() > 0 && selectedFieldValue != null) {
                query += ' SELECT   Id, Field__c, ChangeValue__c, InterfaceValue__c ';
                query += ' FROM     HMCReferenceDataMapping__c  ';
                query += ' WHERE    Field__c = \'' + selectedFieldValue + '\'' ;
                query += ' AND      InterfaceValue__c =: setIFValue ';

                if (query != null) {
                    listHMCMapping = Database.query(query);
                }

                if (listHMCMapping.size() > 0) {
                    for (HMCReferenceDataMapping__c obj : listHMCMapping) {
                        HMCReferenceDataMapping__c objUpdate = new HMCReferenceDataMapping__c();
                        objUpdate.Id = obj.Id;
                        objUpdate.ChangeValue__c = mapChangeValue.get(obj.InterfaceValue__c);
                        listUpdateHMCMapping.add(objUpdate);
                    }
                }
            }
        }

        if(listUpdateHMCMapping.size() > 0){
            try{
                update listUpdateHMCMapping;
                reActiveResult = 'SUCCESS';

            }catch (Exception e){
                System.debug('====ERROR=====');
                System.debug('error message :: ' + e.getMessage());
                System.debug('error getLineNumber :: ' + e.getLineNumber());
                System.debug('====ERROR=====');

                reActiveResult = e.getMessage();
            }
        }else{
            reActiveResult = '값이 존재하지 않습니다.';
        }
        return reActiveResult;
    }

    public class ComboBoxWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    public class MappingWrapper {
        @AuraEnabled public String originValue;
        @AuraEnabled public String changeValue;
        @AuraEnabled public String lastModifiedDate;
        @AuraEnabled public String lastModifiedName;

        public MappingWrapper(HMCReferenceDataMapping__c obj){
            this.originValue = obj.InterfaceValue__c;
            this.changeValue = obj.ChangeValue__c != null ? obj.ChangeValue__c : '';
            this.lastModifiedDate = obj.LastModifiedDate != null ? obj.LastModifiedDate.format('yyyy. MM. dd a hh:mm') : null;
            this.lastModifiedName = obj.LastModifiedBy.Name != null ? obj.LastModifiedBy.Name : '';

        }
    }

}