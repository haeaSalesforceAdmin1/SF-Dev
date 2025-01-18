public class DNAMSUserPermissionsetCheck {
    @AuraEnabled
    public static Boolean checkPermissionSet() {
        String currentUserId = UserInfo.getUserId();
        List<PermissionSetAssignment> listPsa = [select id from PermissionSetAssignment where (PermissionSet.Name = 'DNAMS_National_User_DND1'or PermissionSet.Name = 'DNAMS_Region_Market_Rep') and AssigneeId =:currentUserId];
        //DNA-1052
		Boolean hasInternalUserRMROrDND1DNAMSOrAdminGroup = false;
        for(PermissionSetGroup psg : [SELECT Id, DeveloperName 
                                      FROM PermissionSetGroup 
                                      WHERE Id IN (
                                          SELECT PermissionSetGroupId 
                                          FROM PermissionSetAssignment 
                                          WHERE AssigneeId =: currentUserId
                                      )]
           ){
               if(psg.DeveloperName == 'Internal_User_RMR_DNAMS' || psg.DeveloperName == 'Internal_User_DND1_DNAMS' || psg.DeveloperName == 'Internal_User_DND1Admin_DNAMS'){//DNA-1092 Added Internal_User_DND1Admin_DNAMS
                   hasInternalUserRMROrDND1DNAMSOrAdminGroup = true;
               }
           }
        if(listPsa.size() == 0 && hasInternalUserRMROrDND1DNAMSOrAdminGroup == false){
            return false;
        }
    // DNA-1052
        return true;
    }
}