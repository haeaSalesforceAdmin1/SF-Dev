/*
  Author: Sumanth
  Description : API for retreiving Case picklist field values.
*/@RestResource(urlMapping='/api/Case/*')
global with sharing class Picklistvalues
{
    @HttpGet
    global static void doGet() 
    {
        RestRequest req = RestContext.request;
        String strPicklistField = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String strObjectName = 'Case';
        List<Schema.PicklistEntry> picklistValues = Schema.getGlobalDescribe().get(strObjectName).getDescribe().fields.getMap().get(strPicklistField).getDescribe().getPicklistValues();
        List<String> values = new List<String>();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeObjectField('Name',strPicklistField);
        for (Schema.PicklistEntry objPickList : picklistValues) {
        //System.debug('Value = ' +objPickList.getValue());
        values.add('{"Value" : '+'"'+objPickList.getValue()+'"}');
        }
        gen.writeObjectField('PickListValues',values); 
        gen.writeEndObject();
        String jsonStr = gen.getAsString();
        jsonStr = jsonStr.replace('\\"', '"');
        jsonStr = jsonStr.replace('"{', '{');
        jsonStr = jsonStr.replace('}"', '}');
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonStr);
        
    }
}