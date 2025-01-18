/**
 * @description       : [CCSOM-12,CUVCPO]
 * @author            : inhokim
 * @group             : 
 * @last modified on  : 02-20-2024
 * @last modified by  : inhokim
**/
public class NoticeController {


    // get one Notice__c record. / by appLabel and only visible one .
    @AuraEnabled(Cacheable=true)    
    public static Map<String,Object> retrieveNoticeDetail(String appLabel, String targetUser) {

        

        User userInfo = [
            SELECT Id, Name, Profile.Name, Profile.UserLicense.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        try{  
            Map<String, List<String>> targetUserCheckMap = new Map<String,List<String>>{'INTERNAL USER'=> new List<String>{'Salesforce'} , 'EXTERNAL USER'=> new List<String>{'Partner Community'}};
            System.debug(userInfo);
            List<Notice__c> resList = [SELECT Id, Title__c, Content__c,TargetUser__c FROM Notice__c WHERE isVisible__c = true AND appType__c = :appLabel AND TargetUser__c IN ('ALL', :targetUser ) ORDER BY TargetUser__c ASC, LastModifiedDate DESC LIMIT 1 ];
            if(resList[0] != null ){
                if(  resList[0].TargetUser__c =='ALL' ){
                    return new Map<String,Object>{ 'title' => resList[0].Title__c, 'content' => resList[0].Content__c };
                }else if(targetUserCheckMap.get(resList[0].TargetUser__c).contains(userInfo.Profile.UserLicense.Name)){
                    return new Map<String,Object>{ 'title' => resList[0].Title__c, 'content' => resList[0].Content__c };
                }else{
                    return null;
                }
            }else{
                return null;
            }
        }catch(Exception e){
            return null;
        }
    }

    
    //if current page is not a community site, get the appLabel from the user's last entered app. ( such as - CUV, DPM )
    @AuraEnabled(Cacheable=true)    
    public static String getCurrentAppLightningPage() {
        try{    
            UserAppInfo userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
            AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition Where DurableId = :userAppInfo.AppDefinitionId LIMIT 1];
            return appDefinition.Label;
        }catch(Exception e){
            return null;
        }
    }


}



/*

        User userInfo = [
            SELECT Id, Name, Profile.Name, Profile.UserLicense.Name
            FROM User
            WHERE Id =  '0056g000006G3yzAAC'
            LIMIT 1
        ];
System.debug( userInfo.Profile.UserLicense.Name );
*/