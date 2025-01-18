/* Code for getting all picklist fields with values from Case object */
@RestResource(urlMapping='/api/PicklistValues/Case/*')
global with sharing class CasePicklistValues
{
    @HttpGet
    global static void doGet() 
    { 
        RestRequest req = RestContext.request;
        String strObjectName = 'Case';
        List<String> values = new List<String>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        Set<String> fieldnames = mapFields.keySet();   
        List<String> fieldList = new List<String>();  
        fieldList.addAll(fieldNames);
        List<String> accountFieldResult = new List<String>();
        List<Schema.PicklistEntry> lstPickListValues = new List<Schema.PicklistEntry>();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        for(integer i=0; i<fieldList.size(); i++){
        lstPickListValues = mapFields.get(fieldList[i]).getDescribe().getPickListValues();
        if(mapFields.get(fieldList[i]).getDescribe().getType() == DisplayType.PICKLIST){
               
        gen.writeObjectField('Name',FieldList[i]);
         for (Schema.PicklistEntry objPickList : lstPickListValues) {
             accountFieldResult.add('{"Value" : '+'"'+objPickList.getValue()+'"}');
          System.debug(fieldList[i] +'---'+objPickList.getValue());
      }
          gen.writeObjectField('PickListValues',accountFieldResult);      
           }
            accountFieldResult.clear();
       }
        gen.writeEndObject();
        String jsonStr = gen.getAsString();
        jsonStr = jsonStr.replace('\\"', '"');
        jsonStr = jsonStr.replace('"{', '{');
        jsonStr = jsonStr.replace('}"', '}');
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonStr);   
    }
}