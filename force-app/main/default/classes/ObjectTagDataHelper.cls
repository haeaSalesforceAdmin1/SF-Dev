public class ObjectTagDataHelper {
    private static List<Object_Tag_Setting__mdt> mdtData = new List<Object_Tag_Setting__mdt>();
    private static Map<String, String> fieldNamesWithSaparator = new Map<String, String>();
    public static List<Object_Tag_Setting__mdt> getObjectTagSettings(String objectName){
        for(Object_Tag_Setting__mdt mdt: Object_Tag_Setting__mdt.getAll().values()){
            if(mdt.Object__c.equalsIgnoreCase(objectName)){
                mdtData.add(mdt);
                fieldNamesWithSaparator.put(mdt.Field_Name__c, mdt.Separator__c);
            }
        }
        return mdtData;
    }

    public static Map<String, String> getFieldNamesWithSaparator(){
        return fieldNamesWithSaparator;
    }
}