/**
* @date 09/28/2020
* @description 
*/
public with sharing class HMAObjectService {

    public static Integer errorCount;
    
    public static Database.SaveResult dbInsert(sObject obj) { 
        return Database.insert (obj); 
    }
    
    public static Database.SaveResult dbUpdate(sObject obj) { 
        return Database.update (obj); 
    }
    
    public static Database.DeleteResult dbDelete(sObject obj) { 
        return Database.delete( obj); 
    }
    
    public static Database.SaveResult[] dbInsert(sObject[] objList) { 
        return Database.insert (objList); 
    }
    
    public static Database.SaveResult[] dbInsert(sObject[] objList,Boolean allOrNone) {
        return Database.insert(objList,allOrNone); 
    }

	public static Database.SaveResult[] dbUpdate(sObject[] objList) { 
        return Database.update (objList); 
    }

	public static Database.SaveResult[] dbUpdate(sObject[] objList, Boolean allOrNone) {
		if(allOrNone){
			return Database.update (objList);
		}
		return Database.update(objList, false); 
    }
    
	public static Database.DeleteResult[] dbDelete(sObject[] objList) { 
        return Database.delete( objList); 
    }

	public static List<SObject> dmlUpdate(List<SObject> sobjList){
		update sobjList;
		return sobjList;
	}

	public static List<SObject> dmlInsert(List<SObject> sobjList){
		insert sobjList;
		return sobjList;
	}


    public static Map<Id,String> updateRecordsAndReturnErrorMap(List<SObject> sobjList){
        List<Database.SaveResult> srList = dbUpdate(sobjList,false);
        Map<Id,String> recordIdErrorMap = new Map<Id,String>();
        for(Integer i = 0; i < sobjList.size(); i++){
            Database.SaveResult sr = srList[i];
            SObject sobj = sobjList[i];
            if(! sr.isSuccess()){
                if(!recordIdErrorMap.containsKey(sobj.Id)){
                    recordIdErrorMap.put(sobj.Id, '');
                }
                for(Database.Error err: sr.getErrors()){
                    String existingErrorMessage = recordIdErrorMap.get(sobj.Id);
                    recordIdErrorMap.put(sobj.Id, existingErrorMessage + err.getMessage());
                }
            } 
        }
        return recordIdErrorMap;
    }

    public static void updateRecordsAndLogErrors(List<SObject> sobjList, Id jobId, String className){
        List<Database.SaveResult> srList = dbUpdate(sobjList, false);
        logErrorsFromSaveResults(srList, sobjList, jobId, className);
    }

    public static void insertRecordsAndLogErrors(List<SObject> sobjList, Id jobId, String className){
        List<Database.SaveResult> srList = dbInsert(sobjList, false);
        logErrorsFromSaveResults(srList, sobjList, jobId, className);
    }

    public static void logErrorsFromSaveResults(List<Database.SaveResult> srList,List<SObject> sobjList, Id jobId, String className ) {
        HMALoggingUtil.initialize();
        List<HMALogs__c> datLogList = new List<HMALogs__c>();
        errorCount = 0;
        for(Integer i = 0; i < sobjList.size(); i++){
            Database.SaveResult sr = srList[i];
            SObject sobj = sobjList[i];
            if(! sr.isSuccess()){
                errorCount++;
                String errorMessage;
                for(Database.Error err: sr.getErrors()){
                    errorMessage = errorMessage + '\n' + err.getMessage() + '\n';
                }
                HMALoggingUtil.addErrorLogListItem(errorMessage, className, sobj.Id, jobId);
            }
        }
        
        if(HMALoggingUtil.logList != null &&  !HMALoggingUtil.logList.isEmpty()){
            HMALoggingUtil.logList();
        }
    }    	
}