/**
 * @description       : 
 * @author            : San, Kang
 * @group             : 
 * @last modified on  : 06-27-2023
**/
public without sharing class ChangeOwnerController {
    
    /**
    * @description 
    * @author San, Kang | 06-22-2023 
    * @param recordId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> doInit(String recordId){
        Map<String,Object> userMap = new Map<String,Object>();
        
        try {
            String accId = '';
            Set<String> conSet = new Set<String>();
            List<Evaluation__c> evalList = [SELECT Id, Name, Account__c, OwnerId FROM Evaluation__c WHERE Id =:recordId];
            List<Action_Plan__c> actionList = [SELECT Id, Name, Account__c, OwnerId, ApprovalStatus__c FROM Action_Plan__c WHERE Id=:recordId];
            List<User> userList = new List<User>();
            List<User> partnerList = new List<User>();
            if(evalList.size()>0){
                accId = evalList[0].Account__c;
                userList = [SELECT Id, Name, Email FROM User WHERE Partner_User_Check_Formula__c =false AND DPM_User__c =true AND IsActive = true AND profile.name Like '%internal%'];
                userMap.put('owner',evalList[0].OwnerId);
                userMap.put('obj','Evaluation');
                userMap.put('objName',evalList[0].Name);
            }else if(actionList.size()>0){
                accId = actionList[0].Account__c;
                List<AccountContactRelation> acList = [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE IsActive =true AND DPM_User_Active__c = true AND AccountId =:accId ];
                for(AccountContactRelation ac : acList){
                    conSet.add(ac.ContactId);
                    System.debug('partnercon'+conSet);
                }
                userList = [SELECT Id, Name, Email FROM User WHERE Partner_User_Check_Formula__c =false AND DPM_User__c =true AND IsActive = true AND profile.name Like '%internal%'];
                if(actionList[0].ApprovalStatus__c =='Not Submitted'){
                    System.debug('partner'+conSet);
                    partnerList = [SELECT Id, Name, Email FROM User WHERE ContactId IN :conSet AND Partner_User_Check_Formula__c = true AND IsActive =true];
                    System.debug('partner'+partnerList);
                    userList.clear();
                }
                


                userMap.put('owner',actionList[0].OwnerId);
                userMap.put('obj','Action_Plan');
                userMap.put('objName',actionList[0].Name);
            }

            System.debug('partnerList'+partnerList.size());
            String url = URL.getSalesforceBaseUrl().toString();
            String sendUrl = url.replaceAll('Url:\\[delegate=', '');
            sendUrl = sendUrl.replaceAll('\\]', '');
            sendUrl = sendUrl + '/' + recordId;
            userMap.put('refreshUrl',sendUrl);

            if(userList.size()>0){
                userMap.put('user',userList);
            }
            if(partnerList.size()>0){
                userMap.put('partner',partnerList);
            }

        } catch (Exception e) {
            System.debug('error =>' + e);
        }
        return userMap;
    }

    /**
    * @description 
    * @author San, Kang | 06-22-2023 
    * @param dataGroup 
    **/
    @AuraEnabled
    public static void onSave(Map<String,Object> dataGroup){
        try {


            String senderId = dataGroup.containsKey('owner') ? String.valueOf(dataGroup.get('owner')) : null;
            String targetEmail = dataGroup.containsKey('userEmail') ? String.valueOf(dataGroup.get('userEmail')) : null;
            String targetName = dataGroup.containsKey('userName') ? String.valueOf(dataGroup.get('userName')) : null;
            String targetId = dataGroup.containsKey('userId') ? String.valueOf(dataGroup.get('userId')) : null;
            String targetobj = dataGroup.containsKey('targetobj') ? String.valueOf(dataGroup.get('targetobj')) : null;
            String recordId = dataGroup.containsKey('recordId') ? String.valueOf(String.valueOf(dataGroup.get('recordId'))) : null;
            boolean emailSend = dataGroup.containsKey('sendEmail') ? Boolean.valueOf(Boolean.valueOf(dataGroup.get('sendEmail'))) : false;
            if(emailSend == true){
                String url = URL.getSalesforceBaseUrl().toString();
                System.debug('====================================== stage : ' + url);
                String sendUrl = url.replaceAll('Url:\\[delegate=', '');
                sendUrl = sendUrl.replaceAll('\\]', '');
                sendUrl = sendUrl + '/' + recordId;
                System.debug('====================================== stage : ' + sendUrl);
                List<User> senderList = [SELECT Id, Name FROM User WHERE Id =:senderId];
                Messaging.reserveSingleEmailCapacity(1);
                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                String[] toaddresses = new String[] {targetEmail}; 
                mymail.setToAddresses(toaddresses);
                mymail.setSenderDisplayName(senderList[0].Name);
                mymail.setSubject(targetobj +' transferred to you.');
                mymail.setHtmlBody('<html>'+
                                    '<body>'+
                                    targetobj +' '+ targetName + ' has been assigned to you. Please click on the link below to view the record.'+ 
                                    '<br><br>'+
                                    '<a href=' + sendUrl +'>'+ sendUrl + '</a>'+
                                    '</body>'+
                                    '</html>');
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });
            }
            
            if(targetId != null || targetId != ''){
                List<SObject> objList = new List<SObject>(); 
                String SOQL = ' SELECT '
                            + '     Id '
                            + '     , OwnerId '
                            + ' FROM '
                            +   targetObj + '__c'
                            + ' WHERE '
                            + '     Id = :recordId ';

                objList = Database.query(SOQL);
                if(objList.size()>0){
                    SObject sobj = objList.get(0);
                    sobj.put('OwnerId',targetId);
                    System.debug('sobj'+sobj);
                    update sobj;
                }
            }
        } catch (Exception e) {
            System.debug('error =>' + e);
        }
    }
}