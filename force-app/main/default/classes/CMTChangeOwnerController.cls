/**
 * @description       : Override the Change Owner button
 * @author            : San, Kang
 * @group             : 
    * @author San, Kang | 11-19-2024 **/
public without sharing class CMTChangeOwnerController {
    
    public static final Set<String> CMT_Profile = new Set<String> {'KASO Safety Service Engineer','KASO Safety Service Manager','Safety Service Engineer','Safety Service Manager', '(KASO) System Admin', 'System Administrator'};
    public static final Set<String> CMT_Queue = new Set<String> {'KASOSCSafetyDA','KASOSCSafetyDRC','KASOSCSafetyGlobalDA','KASOSCSafetyGlobalDRC','KASOSCSafetyKASDA','KASOSCSafetyTRC','SCSafetyDA','SCSafetyDRC','SCSafetyNASDA','SCSafetyTRC','SCQuality'};
    
    /**
    * @description : Method with Init function
    * @author San, Kang | 11-19-2024     
    * @param recordId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> doInit(String recordId){
        Map<String,Object> userMap = new Map<String,Object>();
        
        try {
            Set<String> conSet = new Set<String>();
            List<Case> CaseList = [SELECT Id, SCSCaseNumber__c, OwnerId, Owner.Name, Stage__c, IsAutomationBypassed__c, RecordType.DeveloperName FROM Case WHERE Id =:recordId];
            List<User> userList = new List<User>();
            List<User> partnerUserList = new List<User>();
            List<Group> queueList = new List<Group>();
            if(CaseList.size()>0){
                userList = [SELECT Id, Name, Email FROM User WHERE Partner_User_Check_Formula__c =false AND Safety_User__c =true AND IsActive = true AND profile.name IN:CMT_Profile];
                queueList = [SELECT Id, Name FROM Group WHERE DeveloperName IN:CMT_Queue];
                partnerUserList = [SELECT Id, Name, Email FROM User WHERE Partner_User_Check_Formula__c = true AND IsActive = true AND profile.name IN:CMT_Profile AND Safety_User__c =true];
                userMap.put('owner',CaseList[0].OwnerId);
                userMap.put('currentOwnerName',CaseList[0].Owner.Name);
                userMap.put('obj','Case');
                userMap.put('RecordType',CaseList[0].RecordType.DeveloperName);
                userMap.put('IsAutomationBypassed',CaseList[0].IsAutomationBypassed__c);
                userMap.put('Stage',CaseList[0].Stage__c);
                userMap.put('objSCSCaseNumber',CaseList[0].SCSCaseNumber__c);
            }

            String url = URL.getSalesforceBaseUrl().toString();
            String sendUrl = url.replaceAll('Url:\\[delegate=', '');
            sendUrl = sendUrl.replaceAll('\\]', '');
            sendUrl = sendUrl + '/' + recordId;
            userMap.put('refreshUrl',sendUrl);

            if(userList.size()>0){
                userMap.put('user',userList);
            }
            if(queueList.size()>0){
                userMap.put('queue',queueList);
            }
            if(partnerUserList.size()>0){
                userMap.put('partnerUser',partnerUserList);
            }

        } catch (Exception e) {
            System.debug('error =>' + e);
        }
        return userMap;
    }

    /**
    * @description : Change Owner Save Button and Validation Rule 
    * @author San, Kang | 11-26-2024 
    * @param dataGroup 
    **/
    @AuraEnabled
    public static Map<String,Object> onSave(Map<String,Object> dataGroup){
        Map<String,Object> ValidationMap  = new Map<String,Object>();
        try {
            String targetId = dataGroup.containsKey('userId') ? String.valueOf(dataGroup.get('userId')) : null;
            String type = dataGroup.containsKey('type') ? String.valueOf(String.valueOf(dataGroup.get('type'))) : null;
            if(type == 'User'){
                User targetUser = [SELECT Id, SafetyTeamDesignations__c,Profile.Name FROM User WHERE Id =:targetId];
                List<PermissionSetAssignment> PermissionSetAssignList = [SELECT Id, PermissionSet.Name, PermissionSetGroupId, AssigneeId, IsActive FROM PermissionSetAssignment WHERE AssigneeId =:targetId];
                List<GroupMember> MemberGroupList = [SELECT Id, Group.name, UserOrGroupId, SystemModstamp FROM GroupMember WHERE UserOrGroupId =:targetId];
                ValidationMap.put('targetUser',targetUser);
                ValidationMap.put('PermissionSetAssignList',PermissionSetAssignList);
                ValidationMap.put('MemberGroupList',MemberGroupList);
            }
        } catch (Exception e) {
            System.debug('error =>' + e);
        }
        return ValidationMap;
    }

    /**
    * @description : Change Owner Save Button 
    * @author San, Kang | 11-19-2024 
    * @param dataGroup 
    **/
    @AuraEnabled
    public static void updateUser(Map<String,Object> dataGroup){
        try {
            String sender = dataGroup.containsKey('currentOwner') ? String.valueOf(dataGroup.get('currentOwner')) : null;
            String targetEmail = dataGroup.containsKey('userEmail') ? String.valueOf(dataGroup.get('userEmail')) : null;
            String targetName = dataGroup.containsKey('userName') ? String.valueOf(dataGroup.get('userName')) : null;
            String targetId = dataGroup.containsKey('userId') ? String.valueOf(dataGroup.get('userId')) : null;
            String targetobj = dataGroup.containsKey('targetobj') ? String.valueOf(dataGroup.get('targetobj')) : null;
            String recordId = dataGroup.containsKey('recordId') ? String.valueOf(String.valueOf(dataGroup.get('recordId'))) : null;
            boolean emailSend = dataGroup.containsKey('sendEmail') ? Boolean.valueOf(Boolean.valueOf(dataGroup.get('sendEmail'))) : false;
            String type = dataGroup.containsKey('type') ? String.valueOf(String.valueOf(dataGroup.get('type'))) : null;
            String caseNumber = dataGroup.containsKey('caseNumber') ? String.valueOf(String.valueOf(dataGroup.get('caseNumber'))) : null;
            
            if(emailSend == true && type == 'User'){
                String url = URL.getSalesforceBaseUrl().toString();
                System.debug('====================================== stage : ' + url);
                String sendUrl = url.replaceAll('Url:\\[delegate=', '');
                sendUrl = sendUrl.replaceAll('\\]', '');
                sendUrl = sendUrl + '/' + recordId;
                System.debug('====================================== stage : ' + sendUrl);
                System.debug('====================================== stage : ' + caseNumber);
                System.debug('senderId:::'+sender);
                Messaging.reserveSingleEmailCapacity(1);
                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                String[] toaddresses = new String[] {targetEmail}; 
                mymail.setSenderDisplayName(sender);
                mymail.setToAddresses(toaddresses);
                mymail.setSubject(targetobj +' transferred to you.');
                mymail.setHtmlBody('<html>'+
                                    '<body>'+
                                    'CAUTION:This is an external email!' +
                                    '</br>' +
                                    'Do not click on the links or attachments unless you recognize the sender and trust that the content is safe.'+
                                    '</br></br></br>' +
                                    targetobj + ' <a href=' + sendUrl +'>'+ caseNumber + '</a>'+ + ' has been assigned to you. Please click on the link below to view the record.'+ 
                                    '</br></br>' +
                                    '<a href=' + sendUrl +'>'+ sendUrl +
                                    '</body>'+
                                    '</html>');
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });
            }

            System.debug('targetId:::'+targetId);

            if(targetId != null || targetId != ''){
                List<SObject> objList = new List<SObject>(); 
                targetObj = targetObj == 'Case' ? targetObj : targetObj+'__c';
                String SOQL = ' SELECT '
                            + '     Id '
                            + '     , OwnerId '
                            + ' FROM '
                            +   targetObj
                            + ' WHERE '
                            + '     Id = :recordId ';

                objList = Database.query(SOQL);
                System.debug('objList:::'+objList);
                System.debug('objList:::'+objList.size());
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