public class PackageRequestTriggerHandler extends Trigger_Framework.baseHandler {
	public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, PackageRequest__c> oldMap = (Map<Id, PackageRequest__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/
		Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        boolean hasPermission = checkIfUserHasAssignedPermissionSet(userinfo.getUserName(), 'DNAMS_Region_Market_Rep');
        boolean hasPermissionDealer=checkIfUserHasAssignedPermissionSet(userinfo.getUserName(), 'DNAMSBasicExternal');        
        if(!oldMap.isEmpty() &&  profileName != 'System Administrator' && profileName!='Partner Community'){
            for(PackageRequest__c pR: oldMap.values()){
                if( pR.Status__c == 'DLR Request Initiated' ){
                    if(hasPermission==false && hasPermissionDealer==false ){
                        pR.addError('You can not delete this record!');
                    }
                } else {
                    pR.addError('You can not delete this record!');
                }
            }
        }
        /*BEFORE DELETE METHODS END*/
    }
    
    public static Boolean checkIfUserHasAssignedPermissionSet(String userName, String permissionSetName) {
        List<PermissionSetAssignment> psas = [ select Id from PermissionSetAssignment where PermissionSetId IN ( select Id from PermissionSet where Name = :permissionSetName) and AssigneeId IN (select Id from User where UserName = :userName ) ];
        //return psas.size() > 0;
        // DNA-1052 
        Boolean hasInternalUserRMRDNAMSGroup = false;
        String currentUserId = UserInfo.getUserId();
        for(PermissionSetGroup psg : [SELECT Id, DeveloperName 
                                      FROM PermissionSetGroup 
                                      WHERE Id IN (
                                          SELECT PermissionSetGroupId 
                                          FROM PermissionSetAssignment 
                                          WHERE AssigneeId =: currentUserId
                                      )]
           ){
               if(psg.DeveloperName == 'Internal_User_RMR_DNAMS' ){
                   hasInternalUserRMRDNAMSGroup = true;
               }
           }
        //return psas.size() > 0;
        if(psas.size() == 0 && hasInternalUserRMRDNAMSGroup == false){
            return false;
        }
        return true;
		//DNA - 1052
    }
}