public with sharing class ListviewChangeOwnerController {

    @AuraEnabled
    public static Boolean isSystemAdmin() {

        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.debug('Profile : '+currentUser.Profile.Name );
        Boolean isSystemAdmin = false;
        if(currentUser.Profile.Name == 'System Administrator') isSystemAdmin = true;
        return isSystemAdmin;
    }

    // 동적으로 오브젝트의 Owner 변경
    @AuraEnabled
    public static void changeOwner(List<Id> recordIds, Id newOwnerId, String objectApiName) {
        // 동적으로 객체 타입을 가져오기
        sObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
        if (objType == null) {
            throw new AuraHandledException('Invalid object API name.');
        }

        // OwnerId 필드를 동적으로 가져오기
        Schema.SObjectField ownerField = objType.getDescribe().fields.getMap().get('OwnerId');
        if (ownerField == null) {
            throw new AuraHandledException('OwnerId field not found.');
        }

        // 레코드 업데이트 준비
        List<sObject> recordsToUpdate = new List<sObject>();
        for (Id recordId : recordIds) {
            sObject record = objType.newSObject();
            record.put('Id', recordId);
            record.put('OwnerId', newOwnerId);
            recordsToUpdate.add(record);
        }

        // 레코드 업데이트 수행
        try {
            update recordsToUpdate;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating records: ' + e.getMessage());
        }
    }
}