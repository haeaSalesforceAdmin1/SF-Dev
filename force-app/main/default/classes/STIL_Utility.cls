/**
************************************************************************************************
* @classname         : STIL_Utility
* @description       : utility class used for STIL Users 
* @author            : Inho Kim
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       2nd Aug 2024          Inho Kim              OU24-123          Initial Version
* 1.1       19th Aug 2024         Inho Kim              OU24-129          add new method - retrieveRequestorForLRCreationFlow
************************************************************************************************
**/
public class STIL_Utility {  
    
    
    @AuraEnabled
    public static List<Case> getCasesByKeywordInCreationFlow(String keyword){
        try {
            String likeFilter = '\'%'+keyword+'%\'';
            String likeFilterN = '\'%'+'N'+'%\'';
            List<Case> casesListNaso;
            List<Case> casesListOther;
            //casesList = [SELECT Id,CaseNumber,CurrentPhase__c,Region__c FROM Case WHERE CaseNumber LIKE '%:keyword%' OR CaseNumber LIKE ':keyword%' ORDER BY CaseNumber ASC];
            casesListNaso = Database.query('SELECT  Id, Stage__c, SCSCaseRegion__c, SCSCaseNumber__c, 	Subject, Owner.Name, ModelCode__c    FROM Case WHERE SCSCaseNumber__c LIKE '+ likeFilter + ' AND SCSCaseNumber__c LIKE ' + likeFilterN + ' LIMIT 10');
            casesListOther = Database.query('SELECT  Id, Stage__c, SCSCaseRegion__c, SCSCaseNumber__c, 	Subject, Owner.Name, ModelCode__c    FROM Case WHERE SCSCaseNumber__c LIKE '+ likeFilter + ' AND (NOT SCSCaseNumber__c LIKE '+ likeFilterN +') LIMIT 10');
            // Initialize a new list to store combined results
            List<Case> combinedCasesList = new List<Case>();
            // Add from 'casesListNaso'
            for (Case c : casesListNaso) {
                c.Stage__c = c.Stage__c == 'NASDA' ? 'SDA' : c.Stage__c;
                if (combinedCasesList.size() < 10) {                    combinedCasesList.add(c);                } else {                    break;} // Stop adding if we have 10 records already
                }
            // Add from 'casesListOther' only if there's still space
            for (Case c : casesListOther) {
                c.Stage__c = c.Stage__c == 'NASDA' ? 'SDA' : c.Stage__c;
                if (combinedCasesList.size() < 10) {                    combinedCasesList.add(c);                } else {                    break;} // Stop adding if we reach 10 records                

            }

            System.debug(combinedCasesList);            
            return combinedCasesList;

        } catch (Exception e) {
            System.debug('ERR >>' +  e.getMessage() ); 
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** 
     * METHOD : getRequestorsForCreateLRFromLRFlow
     * TICKET : STIL-129
     * 
     */
    @InvocableMethod(label = 'STIL_retrieveRequestorUsersForLRCreationFlow')
    public static List<List<User>> retrieveRequestorForLRCreationFlow(List<String> userIdToExclude){
    
        //created to hold return list of lists    
        List<List<User>> wrapper = new List<List<User>>();   
        List<PermissionSetAssignment> permissionSetAssignmentList; 
        //The data set to be returned    
        Set<Id> userIdList =new Set<Id>();
        String userIdToExcludeStr;
        if(userIdToExclude.size() > 0 ){
            userIdToExcludeStr = userIdToExclude[0];
        }
        if(String.isEmpty(userIdToExcludeStr)){
            permissionSetAssignmentList = [SELECT ID,AssigneeId from PermissionSetAssignment WHERE PermissionSet.Name= 'STIL_Requestor' ORDER BY Assignee.Name ASC ];
        }else{
            userIdList.add(UserInfo.getUserId());// add current userId first. 
            permissionSetAssignmentList = [SELECT ID,AssigneeId from PermissionSetAssignment WHERE PermissionSet.Name= 'STIL_Requestor' AND ( NOT AssigneeId = :userIdToExcludeStr ) ORDER BY Assignee.Name ASC ];
        }
    
    
        for (PermissionSetAssignment item: permissionSetAssignmentList ){       
            userIdList.add(item.AssigneeId);       
        }

        List<User> userList = [SELECT Id,Name,MobilePhone,Phone,Email FROM User WHERE ID IN :userIdList];

        wrapper.add(userList);
    
        return wrapper;
    
    }
    
    


}