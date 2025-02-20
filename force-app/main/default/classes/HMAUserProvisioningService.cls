/**
* @date 09/28/2020
* @description 
* UpdatedBy : Inho Kim / [10-07-2024] / [CCSOM-67] / [SF] Permissions for Users with "System Admin" Roles not updated by Auto Provisioning - RITM0643562 / If a user had the "System Admin" role prior to the auto-provisioning run, it should be retained. 

*/
public without sharing class HMAUserProvisioningService {
 
    private static final String CLASSNAME = 'HMAUserProvisioningService'; 
    private static final String ACTION_PLAN_DRAFT_STATUS = 'Open';
    private static final String ACTION_PLAN_IN_PROGRESS_STATUS = 'In Progress';
    private static final String EVALUATION_COMPLETED_STATUS = 'Completed';

    // DPM-4973 provise profile by federation Id - by MH - 2023.10.24
    private static final String HYUNDAI = '@hmausa.com'; 
    private static final String GENESIS = '@gma.com';
    private static final String HYUNDAIprofile = 'Hyundai User Internal';
    private static final String GENESISprofile = 'Genesis User Internal';
    private static final List<String> FIELDMANAGER = new List<String>{'District_Sales_Manager',
                                                                    'District_Parts_Service_Manager',
                                                                    'Aftersales_Market_Manager',
                                                                    'Region_Managers',
                                                                    'Market_Manager',
                                                                    'Genesis_Area_Manager',
                                                                    'District_Manager',
                                                                    'Genesis_Region_Manager',
                                                                    'Hyundai_Region_Managers'
                                                                    };
    private static final String HYUNDAIinternalRole = 'Hyundai_National';
    private static final String GENESISinternalRole = 'Genesis_National';
    private static final String SYSTEMADMINRole = 'System_Admin';//Add final string [CCSOM-67] by Inhokim on 24.10.08
    private static final String AccessType_CUVBIZ_H = 'CUV_BizAdmin_H';//Add final string [CCSOM-67] by Inhokim on 24.10.08
    private static final String AccessType_CUVBIZ_G = 'CUV_BizAdmin_G';//Add final string [CCSOM-67] by Inhokim on 24.10.08
    /**
    * @description 
    */
    public static void provisionUsers(List<HMAUserProvisioning__c> userProvisionsToProcess, Boolean processDealerShares) {
        System.debug('Dhiraj provisionUsers called');
        
        Set<String> accessTypes = new Set<String>();
        Set<String> objectAccess = new Set<String>();

        Map<Id, List<String>> mapUserProvisionAccessTypes = new Map<Id, List<String>>();

        for(HMAUserProvisioning__c userProvision:userProvisionsToProcess) {
            List<String> provisionAccessTypes = new List<String>();
            if(userProvision.AccessTypes__c != null && userProvision.AccessTypes__c != '') {
                provisionAccessTypes.addAll(retrieveAccessTypesForUserProvision(userProvision));   
                accessTypes.addAll(provisionAccessTypes);
            }
            mapUserProvisionAccessTypes.put(userProvision.User__c, provisionAccessTypes);
        }        
        
        if(!processDealerShares) {
            provisionPermissionSetGroupAccess(userProvisionsToProcess, mapUserProvisionAccessTypes, accessTypes);
            provisionPermissionSetAccess(userProvisionsToProcess, mapUserProvisionAccessTypes, accessTypes);
            provisionPublicGroupAccess(userProvisionsToProcess, mapUserProvisionAccessTypes, accessTypes);
            removePermissionSetLicensesForUsers(mapUserProvisionAccessTypes.keySet());

            provisionRoleAndProfileOnUsers(userProvisionsToProcess, mapUserProvisionAccessTypes, accessTypes);

            updateUserRegionAndDistrictCodes(userProvisionsToProcess, mapUserProvisionAccessTypes, accessTypes); //DPM-5188 added by AR - 2024.01.12
            provisionRegionManager(userProvisionsToProcess, mapUserProvisionAccessTypes, accessTypes); //DPM-5054 added by MH - 2023.11.27
            if(!Test.isRunningTest()){
                HMAUserProvisioningQueuable userProvisioningQueueable = new HMAUserProvisioningQueuable(userProvisionsToProcess, true);
                System.enqueueJob(userProvisioningQueueable);
            }
        }
        else{
            System.debug('Dhiraj provisionUsers called else part');
        
            System.debug(LoggingLevel.ERROR, 'profile and role');
            List<HMAUserProvisioningDealerWrapper> userProvisionDealerWrappers = getDealerProvisioningWrappers(userProvisionsToProcess, mapUserProvisionAccessTypes);
            removeActionPlanEvaluationSharing(userProvisionDealerWrappers);
            provisionDealerSharing(userProvisionDealerWrappers);

            if(!Test.isRunningTest()){
                HMAUserProvisioningQueuableComplete userProvisioningCompleteQueueable = new HMAUserProvisioningQueuableComplete(userProvisionsToProcess);
                System.enqueueJob(userProvisioningCompleteQueueable);
            }
        }
    }

    private static List<String> retrieveAccessTypesForUserProvision(HMAUserProvisioning__c userProvision) {

        System.debug(LoggingLevel.ERROR, userProvision.AccessTypes__c);
        List<String> userProvisionAccessTypes  = new List<String>();
        for(String userAccessType:userProvision.AccessTypes__c.split(',')) {
            if(userAccessType.contains('/')) {
                userProvisionAccessTypes.add(userAccessType.split('/')[0]);
                userProvisionAccessTypes.add(userAccessType);
            }
            else {
                userProvisionAccessTypes.add(userAccessType);
            }
        }
        return userProvisionAccessTypes;
    }
    
    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [04.08.24] for [DPM-5447]  added exception 
     * Edited by [MinheeKim] on [01.17.25] for [DPM-6005]  added logic to check if the user is the extenal user who has access to temporary account
     * Edited by [MinheeKim] on [01.22.25] for [DPM-6032]  Added condition to check null for userTempAccesstype
    */
    private static void provisionPermissionSetGroupAccess(List<HMAUserProvisioning__c> listOfHMAUserProvisionings, Map<Id, List<String>> mapUserProvisionAccessTypes, Set<String> accessTypes) {
    
        /**DPM-6005 If the user is the extenal user who has access to temporary account,
         * Add DNA_GenesisExt or DNA_HyundaiExt to accessTypeToPermissionSetGroupAPINameMap
        */
        Map<Id, List<String>> userTempAccesstype = getTempAccess(mapUserProvisionAccessTypes).size()>0 ? getTempAccess(mapUserProvisionAccessTypes) : null;
        if(userTempAccesstype!=null && userTempAccesstype.size()>0){ //DPM-6032 Added condition 'userTempAccesstype!=null && ' by MinheeKim 01.22.2025
            for(Id usrId : userTempAccesstype.keySet()){
                for(String accesstype: userTempAccesstype.get(usrId)){
                    accessTypes.add(accesstype);
                }
            }
        }//DPM-6005 end
        Map<String, AccessType__mdt> permissionSetGroupAccessTypes = populateAccessTypes(accessTypes, HMAConstants.METADATA_PERMISSIONSET_GROUP_FIELD);
        Set<String> newPermissionSetGroupsAssigned = new Set<String>();
        List<String> listOfPermissionSetGroupNames = new List<String>();
        Map<String, List<String>> accessTypeToPermissionSetGroupAPINameMap = new Map<String, List<String>>();
        List<String> tmpListOfPermissionSetGroupNames = new List<String>();
    
        for(AccessType__mdt accessType : permissionSetGroupAccessTypes.values()){
            // Soyeon Changes start here for DPM-4650
            tmpListOfPermissionSetGroupNames.addAll(((String)accessType.get(HMAConstants.METADATA_PERMISSIONSET_GROUP_FIELD)).split(','));
            
            for(String permissionSetGroupName : tmpListOfPermissionSetGroupNames){
                if(permissionSetGroupName.equals('Internal_User_GMM_DPM')){
                    tmpListOfPermissionSetGroupNames.set(tmpListOfPermissionSetGroupNames.indexOf('Internal_User_GMM_DPM'), 'Internal_User_MM_DPM');
                }
            }
            
            listOfPermissionSetGroupNames.addAll(tmpListOfPermissionSetGroupNames);
            accessTypeToPermissionSetGroupAPINameMap.put(accessType.DeveloperName, tmpListOfPermissionSetGroupNames);
            // Soyeon Changes end here
            
            // old
            //listOfPermissionSetGroupNames.addAll(((String)accessType.get(HMAConstants.METADATA_PERMISSIONSET_GROUP_FIELD)).split(','));
            //accessTypeToPermissionSetGroupAPINameMap.put(accessType.DeveloperName, ((String)accessType.get(HMAConstants.METADATA_PERMISSIONSET_GROUP_FIELD)).split(','));

        }

        
        System.debug('6005 userTempAccesstype : '+userTempAccesstype);
    
        Map<Id, Map<String, Id>> userIdToPermissionSetGroupNamesMap = getExistingPermissionSetGroupsForUsers(mapUserProvisionAccessTypes.keySet());
        Map<String, Id> permissionSetGroupNameToPermissionIdMap = getPermissionSetGroupMap(listOfPermissionSetGroupNames);
        List<PermissionSetAssignment> listOfPermissionSetGroupAssignments = new List<PermissionSetAssignment>();
        
        for(HMAUserProvisioning__c userProvisionng : listOfHMAUserProvisionings) {
            
            if(mapUserProvisionAccessTypes.containsKey(userProvisionng.User__c)) {
                List<String> userAccessTypes = mapUserProvisionAccessTypes.get(userProvisionng.User__c);
                /**DPM-6005 If the user is the extenal user who has access to temporary account,
                 * Add DNA_GenesisExt or DNA_HyundaiExt to accessTypeToPermissionSetGroupAPINameMap
                */
                if(userTempAccesstype!=null && userTempAccesstype.containsKey(userProvisionng.User__c)){ //DPM-6032 Added condition 'userTempAccesstype!=null && ' by MinheeKim 01.22.2025
                    userAccessTypes.addALL(userTempAccesstype.get(userProvisionng.User__c));
                }//DPM-6005 end
                for(String userAccessType : userAccessTypes) {
                    
                    if(accessTypeToPermissionSetGroupAPINameMap.containsKey(userAccessType)) {
                        
                        for(String permissionSetGroupDeveloperName : accessTypeToPermissionSetGroupAPINameMap.get(userAccessType)) {
                        
                            if(userIdToPermissionSetGroupNamesMap.containsKey(userProvisionng.User__c)) {
                                if(userIdToPermissionSetGroupNamesMap.get(userProvisionng.User__c).containsKey(permissionSetGroupDeveloperName)) {
                                    userIdToPermissionSetGroupNamesMap.get(userProvisionng.User__c).remove(permissionSetGroupDeveloperName);
                                    newPermissionSetGroupsAssigned.add(permissionSetGroupDeveloperName);
                                    continue;
                                }
                            }
                                
                            if(permissionSetGroupNameToPermissionIdMap.containsKey(permissionSetGroupDeveloperName)) {
                                if(!newPermissionSetGroupsAssigned.contains(permissionSetGroupDeveloperName)) {
                                    listOfPermissionSetGroupAssignments.add(new PermissionSetAssignment(
                                        AssigneeId = userProvisionng.User__c, 
                                        PermissionSetGroupId = permissionSetGroupNameToPermissionIdMap.get(permissionSetGroupDeveloperName)
                                    ));
                                    newPermissionSetGroupsAssigned.add(permissionSetGroupDeveloperName);
                                }
                            }
                        }
                    }
                }
            }
        }
    
        if(!listOfPermissionSetGroupAssignments.isEmpty()) {
            try {
                insert listOfPermissionSetGroupAssignments;
            } catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                throw(e);
            }
        }
    
        if(userIdToPermissionSetGroupNamesMap.size() > 0) { //DPM-5447 added exception by MinheeKim - 24.04.08
            removeUnprovisionedPermissionSetAssignments(userIdToPermissionSetGroupNamesMap);
        }
        
    }

    

    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [24.04.08] for [DPM-5447]  added exception
    */
    private static void provisionPermissionSetAccess(List<HMAUserProvisioning__c> listOfHMAUserProvisionings, Map<Id, List<String>> mapUserProvisionAccessTypes, Set<String> accessTypes) {
		
        
        Map<String, AccessType__mdt> permissionSetAccessTypes = populateAccessTypes(accessTypes, HMAConstants.METADATA_PERMISSIONSET_FIELD);
        Set<String> newPermissioinSetsAssigned = new Set<String>();
        
        List<String> listOfPermissionSetNames = new List<String>();
        Map<String, List<String>> accessTypeToPermissionSetAPINameMap = new Map<String, List<String>>();
       
        for(AccessType__mdt accessType:permissionSetAccessTypes.values()){
            listOfPermissionSetNames.addAll(accessType.PermissionSetAPINames__c.split(','));
            accessTypeToPermissionSetAPINameMap.put(accessType.DeveloperName, accessType.PermissionSetAPINames__c.split(','));
        }  

        Map<Id, Map<String, Id>> userIdToPermissionSetNamesMap = getExistingPermissionSetsForUsers(mapUserProvisionAccessTypes.keySet());
        Map<String, Id> permissionSetNameToPermissionIdMap = getPermissionSetMap(listOfPermissionSetNames);

        List<PermissionSetAssignment> listOfPermissionSetAssignments = new List<PermissionSetAssignment>();
        for(HMAUserProvisioning__c userProvisionng:listOfHMAUserProvisionings) {

            if(mapUserProvisionAccessTypes.containsKey(userProvisionng.User__c)) {
                List<String> userAccessTypes = mapUserProvisionAccessTypes.get(userProvisionng.User__c);
            
                //CCSOM-67 boolean flag to check if user has CUV_BizAdmin_G or CUV_BizAdmin_H access types
                Boolean hasCUVBizAccessType = (userAccessTypes.contains(AccessType_CUVBIZ_H) || userAccessTypes.contains(AccessType_CUVBIZ_G)  ) ? true : false;
            
                for(String userAccessType:userAccessTypes) {
                    System.debug(LoggingLevel.ERROR, userAccessType);
                    if(accessTypeToPermissionSetAPINameMap.containsKey(userAccessType)) {
                        System.debug(LoggingLevel.ERROR, 'Processing User Access Type: ' + userAccessType);
                        for(String permissionSetDeveloperName:accessTypeToPermissionSetAPINameMap.get(userAccessType)) {
                            System.debug(LoggingLevel.ERROR, permissionSetDeveloperName);
                            if(userIdToPermissionSetNamesMap.containsKey(userProvisionng.User__c)) {
                                
                                if(userIdToPermissionSetNamesMap.get(userProvisionng.User__c).containsKey(permissionSetDeveloperName)) {
                                    userIdToPermissionSetNamesMap.get(userProvisionng.User__c).remove(permissionSetDeveloperName);
                                    newPermissioinSetsAssigned.add(permissionSetDeveloperName);
                                    continue;
                                }
                            }
                                
                            if(permissionSetNameToPermissionIdMap.containsKey(permissionSetDeveloperName)) {
                                if(!newPermissioinSetsAssigned.contains(permissionSetDeveloperName)) {
                                    newPermissioinSetsAssigned.add(permissionSetDeveloperName);
                                    listOfPermissionSetAssignments.add(new PermissionSetAssignment(AssigneeId = userProvisionng.User__c, PermissionSetId = permissionSetNameToPermissionIdMap.get(permissionSetDeveloperName)));
                                }
                            }
                        }
                    }
                }
                // CCSOM-67 not to remove permissionset assignment 
                //CUV_Community_Hyundai,                    
                // SKIP removing Community Permission
                if(userIdToPermissionSetNamesMap.get(userProvisionng.User__c)!= null){
                    if(hasCUVBizAccessType &&  (userIdToPermissionSetNamesMap.get(userProvisionng.User__c).containsKey('CUV_Community_Hyundai') || userIdToPermissionSetNamesMap.get(userProvisionng.User__c).containsKey('CUV_Community_Genesis'))){
                        userIdToPermissionSetNamesMap.get(userProvisionng.User__c).remove('CUV_Community_Hyundai');
                        userIdToPermissionSetNamesMap.get(userProvisionng.User__c).remove('CUV_Community_Genesis');
                    }
                }                
            }
        }

        if(!listOfPermissionSetAssignments.isEmpty()) {
            System.debug(listOfPermissionSetAssignments);
            //HMAObjectService.insertRecordsAndLogErrors(listOfPermissionSetAssignments, null, CLASSNAME);
            insert listOfPermissionSetAssignments;
        }
        
        
        
        System.debug(LoggingLevel.ERROR, userIdToPermissionSetNamesMap);
        if(userIdToPermissionSetNamesMap.size()>0){ //DPM-5447 added exception by MinheeKim - 24.04.08
            System.debug(userIdToPermissionSetNamesMap);
            removeUnprovisionedPermissionSetAssignments(userIdToPermissionSetNamesMap); 
        }
    } 

    /**
    * @description 
    */
    private static void provisionPublicGroupAccess(List<HMAUserProvisioning__c> listOfHMAUserProvisionings, Map<Id, List<String>> mapUserProvisionAccessTypes, Set<String> accessTypes) {

        Map<String, AccessType__mdt> publicGroupAccessTypes = populateAccessTypes(accessTypes, HMAConstants.METADATA_PUBLIC_GROUP_FIELD);
        
        List<String> listOfPublicGroupNames = new List<String>();
        Map<String, List<String>> accessTypeToPublicGroupAPINameMap = new Map<String, List<String>>();
        for(AccessType__mdt accessType:publicGroupAccessTypes.values()){
            listOfPublicGroupNames.addAll(((String)accessType.get(HMAConstants.METADATA_PUBLIC_GROUP_FIELD)).split(','));
            accessTypeToPublicGroupAPINameMap.put(accessType.DeveloperName, ((String)accessType.get(HMAConstants.METADATA_PUBLIC_GROUP_FIELD)).split(','));
        }  

        Map<Id, Map<String, Id>> userIdToPublicGroupNamesMap = getExistingPublicGroupsForUsers(mapUserProvisionAccessTypes.keySet());
        Map<String, Id> publicGroupNameToPermissionIdMap = getPublicGroupMap(listOfPublicGroupNames);

        List<GroupMember> listOfGroupMembers = new List<GroupMember>();
        for(HMAUserProvisioning__c userProvisionng:listOfHMAUserProvisionings) {
            if(mapUserProvisionAccessTypes.containsKey(userProvisionng.User__c)) {
                List<String> userAccessTypes = mapUserProvisionAccessTypes.get(userProvisionng.User__c);
                for(String userAccessType:userAccessTypes) {
                    if(accessTypeToPublicGroupAPINameMap.containsKey(userAccessType)) {
                        for(String publicGroupDeveloperName:accessTypeToPublicGroupAPINameMap.get(userAccessType)) {
                            if(userIdToPublicGroupNamesMap.containsKey(userProvisionng.User__c)) {
                                // Soyeon Kim changes for DPM-4702 starts
                                if(userIdToPublicGroupNamesMap.get(userProvisionng.User__c).containsKey('DPM_ALL_DPM_USERS')) {
                                    userIdToPublicGroupNamesMap.get(userProvisionng.User__c).remove('DPM_ALL_DPM_USERS');
                                }
                                // Soyeon Kim changes for DPM-4702 ends
                                
                                if(userIdToPublicGroupNamesMap.get(userProvisionng.User__c).containsKey(publicGroupDeveloperName)) {
                                    userIdToPublicGroupNamesMap.get(userProvisionng.User__c).remove(publicGroupDeveloperName);
                                    continue;
                                }
                            }
                                
                            if(publicGroupNameToPermissionIdMap.containsKey(publicGroupDeveloperName)) {
                                listOfGroupMembers.add(new GroupMember(UserOrGroupId = userProvisionng.User__c, GroupId = publicGroupNameToPermissionIdMap.get(publicGroupDeveloperName)));
                            }
                        }
                    }
                }
            }
        }
        if(!listOfGroupMembers.isEmpty()) {
            HMAObjectService.insertRecordsAndLogErrors(listOfGroupMembers, null, CLASSNAME);
        }

        removeUnprovisionedPublicGroups(userIdToPublicGroupNamesMap);
    }

    /**
     * [Method Description] provide profile and role to user
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [12-06-2023] for [DPM-5194]: Added condition to check DPM_JDP_Evaluat to go to not internal logic for role
     * Edited by [Minhee Kim] on [04-11-2024] for [DPM-5015] prevent to change the profile as 'minimum access' when DNAMS internal user has no access type
     * Edited by [Minhee Kim] on [12-02-2024] for [DPM-5934] Insert Role by Access type to use in CRMA Log
     * Edited by [Minhee Kim] on [02-10-2025] for [DPM-6020] Consolidate DNAMS flag fields
     * Edited by [Minhee Kim] on [02-17-2025] for [DPM-6086] added condition not to provide role if there's only DNAMS access(maintain the previous role) 
    */
    public static void provisionRoleAndProfileOnUsers(List<HMAUserProvisioning__c> listOfHMAUserProvisionings, Map<Id, List<String>> mapUserProvisionAccessTypes, Set<String> accessTypes) {
        System.debug('provisionRoleAndProfileOnUsers started');
        //DPM-4973 Change to provision profile by federation Id - by MH - 2023.10.24
        Map<String, AccessType__mdt> profileAccessTypes = populateAccessTypes(accessTypes, HMAConstants.METADATA_PROFILE_FIELD);
        Map<Id, Set<String>> mapUserAppTypes = populateApptypes(mapUserProvisionAccessTypes); //DPM-6086 method to get apptypes in the accesstype on 02-18-2025 by MinheeKim
		Map<String, String> profileMap = populateFederationId();
        System.debug(LoggingLevel.ERROR, profileMap);
        
        Map<String, AccessType__mdt> roleAccessTypes = populateAccessTypes(accessTypes, HMAConstants.METADATA_ROLE_FIELD);
        Map<Id, User> userIdToUserMap = getUserMap(mapUserProvisionAccessTypes.keySet());

        List<String> profilePriorityList = new List<String>();
        List<String> rolePriorityList = new List<String>();
        SecurityBrandMapping__mdt securityBrandMapping = [select ProfilePriority__c, RolePriority__c from SecurityBrandMapping__mdt where DeveloperName = 'DPM'];
        if(securityBrandMapping != null) {
            if(!String.isBlank(securityBrandMapping.ProfilePriority__c)) {
                profilePriorityList = securityBrandMapping.ProfilePriority__c.split(',');
            }

            if(!String.isBlank(securityBrandMapping.RolePriority__c)) {
                rolePriorityList = securityBrandMapping.RolePriority__c.split(',');
            }
        }
        System.debug(LoggingLevel.ERROR, profilePriorityList);
        System.debug(LoggingLevel.ERROR, rolePriorityList);
        System.debug(LoggingLevel.ERROR, userIdToUserMap);

        List<String> listOfRoleDeveloperNames = new List<String>();
        List<String> listOfProfileNames = new List<String>();

        Map<String, String> accessTypeToRoleDeveloperNameMap = new Map<String, String>();
        Map<String, String> accessTypeToProfileNameMap = new Map<String, String>();

        for(AccessType__mdt accessType:profileAccessTypes.values()){
            listOfProfileNames.add((String)accessType.get(HMAConstants.METADATA_PROFILE_FIELD));
            accessTypeToProfileNameMap.put(accessType.DeveloperName, (String)accessType.get(HMAConstants.METADATA_PROFILE_FIELD));
        }  
        System.debug(LoggingLevel.ERROR, listOfProfileNames);

 		//DPM-4973 provise profile by federation Id - by MH - 2023.10.24
        for(String federation:profileMap.values()){
            listOfProfileNames.add((String)federation);
            listOfProfileNames.add((String)federation);
        }  
        System.debug(LoggingLevel.ERROR, listOfProfileNames);
        for(AccessType__mdt accessType:roleAccessTypes.values()){
            listOfRoleDeveloperNames.add((String)accessType.get(HMAConstants.METADATA_ROLE_FIELD));
            accessTypeToRoleDeveloperNameMap.put(accessType.DeveloperName, (String)accessType.get(HMAConstants.METADATA_ROLE_FIELD));
        }
		//DPM-4973 add Internal by MH - 2023.10.24
        listOfRoleDeveloperNames.add(HYUNDAIinternalRole);
        listOfRoleDeveloperNames.add(GENESISinternalRole);
        //////
        System.debug(LoggingLevel.ERROR, listOfRoleDeveloperNames);
        List<User> listOfUsersToUpdate = new List<User>();
        Map<String, Id> profileNameToProfileIdMap = getProfileMap(listOfProfileNames);
        Map<String, Id> minimumProfileLicenseTypeToProfileIdMap = getMinimumProfileMap();
        Map<String, Id> roleDeveloperNameToRoleIdMap = getUserRoleMap(listOfRoleDeveloperNames);
        
        for(HMAUserProvisioning__c userProvisionng:listOfHMAUserProvisionings) {

            if(userIdToUserMap.containsKey(userProvisionng.User__c)){              
                User user = userIdToUserMap.get(userProvisionng.User__c);
        
                //CCSOM-67 String declare currentUserRoleDevName
                String currentUserRoleDevName = (String)user.UserRole.DeveloperName ?? '';String currentUserProfileName = (String)user.Profile.Name ?? '';                
                Id currentUserRoleId;                
                if( !String.isBlank(currentUserRoleDevName) ){ currentUserRoleId = user.UserRoleId ?? '';}
                System.debug('user.Profile.UserLicense.Name: '+userProvisionng.User__c);
                String currentUserProfileLicenseType = user.Profile.UserLicense.Name;
                System.debug('userProvisionng.FederationIdentifier__c: '+userProvisionng.FederationIdentifier__c);
                //DPM-4973 provise profile by federation Id - by MH - 2023.10.24
                String profileName = '';
                if(userProvisionng.FederationIdentifier__c!=null){
                    
                    for(String federation:profileMap.keySet()){
                        if(userProvisionng.FederationIdentifier__c.toLowerCase().contains(federation)){
                            profileName = profileMap.get(federation);
                            System.debug('userProvisionng.FederationIdentifier__c: '+userProvisionng.FederationIdentifier__c);
                        }
                    }
                    if(profileName!=''){
                        user.ProfileId = profileNameToProfileIdMap.get(profileName);
                    }
                }

                user.UserRoleId = null;
                //user.ProfileId = '00e6g000000SIVn';
                Boolean userUpdated = false;
                if(mapUserProvisionAccessTypes.containsKey(userProvisionng.User__c)) {
                    List<String> userAccessTypes = mapUserProvisionAccessTypes.get(userProvisionng.User__c);
                    
                    Integer prioriyIndexProfile;
                    Integer priorityIndexRole;
                    Boolean isFieldmanager=false;//DPM-4973 added by MH
                    Boolean isRegionManager=false;//DPM-5054 added by MH - 2023.11.27 
                    for(String userAccessType:userAccessTypes) {
                        
                        //DPM-4973 changed to comments by MH - 2023.10.24
                        if(accessTypeToProfileNameMap.containsKey(userAccessType) && (profileName=='' || userAccessType=='DPM_JDP_Evaluat')) { //DPM-5194 Added condition to check DPM_JDP_Evaluat by Minhee - 2023.12.06
                            Integer currentProfileIndex = profilePriorityList.indexOf(accessTypeToProfileNameMap.get(userAccessType));
                            System.debug(LoggingLevel.ERROR, currentProfileIndex);
                            if(prioriyIndexProfile == null || (prioriyIndexProfile != null && currentProfileIndex != -1 && currentProfileIndex <= prioriyIndexProfile)) {
                                user.ProfileId = profileNameToProfileIdMap.get(accessTypeToProfileNameMap.get(userAccessType));
                                prioriyIndexProfile = currentProfileIndex;
                            }

                            //DPM-5194 Added condition to check DPM_JDP_Evaluat to go to not internal logic for role - by Minhee - 2023.12.06
                            if(userAccessType=='DPM_JDP_Evaluat'){
                                profileName = '';
                            }//DPM-5194 end
                            
                        }else if(profileName!=''){
                            prioriyIndexProfile=100; ////DPM-4973 added by MH - 2023.11.06 prioriyIndexProfile not to be null
                        }
                    
                        //DPM-4973 check whether the user is intenal or not - by MH - 2023.10.24
                        //DPM-6086 added condition not to provide role if there's only DNAMS access(maintain the previous role) by MinheeKim on 02.17.2025
                        if(profileName.contains('Internal') && !(!mapUserAppTypes.get(user.Id).contains('DPM') && !mapUserAppTypes.get(user.Id).contains('CUV') && mapUserAppTypes.get(user.Id).contains('DNA')) ){
                            Integer currentRoleIndex = rolePriorityList.indexOf(accessTypeToRoleDeveloperNameMap.get(userAccessType));
                            System.debug(LoggingLevel.ERROR, currentRoleIndex);    
                                if(FIELDMANAGER.contains(accessTypeToRoleDeveloperNameMap.get(userAccessType)) && (currentRoleIndex <= priorityIndexRole|| priorityIndexRole==-1 || priorityIndexRole==null)){ 
                                    user.UserRoleId = roleDeveloperNameToRoleIdMap.get(accessTypeToRoleDeveloperNameMap.get(userAccessType));
                                    currentRoleIndex = rolePriorityList.indexOf(accessTypeToRoleDeveloperNameMap.get(userAccessType));
                                    priorityIndexRole = currentRoleIndex;
                                    System.debug(LoggingLevel.ERROR, 'FIELDMANAGER Role is : '+accessTypeToRoleDeveloperNameMap.get(userAccessType));
                                    System.debug(LoggingLevel.ERROR, 'Priority Role is : '+priorityIndexRole);
                                    isFieldmanager = true;
                                }else if(profileName.contains('Hyundai') && !isFieldmanager){
                                    System.debug(LoggingLevel.ERROR, 'profile for Role is : '+profileName);
                                    user.UserRoleId = roleDeveloperNameToRoleIdMap.get('Hyundai_National');
                                    currentRoleIndex = rolePriorityList.indexOf('Hyundai_National');
                                    priorityIndexRole = currentRoleIndex;                    
                                }else if(profileName.contains('Genesis') && !isFieldmanager){
                                    System.debug(LoggingLevel.ERROR, 'profile for Role is : '+profileName);
                                    System.debug(LoggingLevel.ERROR, 'Role is : '+roleDeveloperNameToRoleIdMap);
                                    user.UserRoleId = roleDeveloperNameToRoleIdMap.get('Genesis_National');
                                    currentRoleIndex = rolePriorityList.indexOf('Genesis_National');
                                    priorityIndexRole = currentRoleIndex;                              
                                } 

                                //CCSOM-67 maintain UserRole when profileName contains CUV 

                            //DPM-4973 change end ------------

                            /** DPM-5934 start : Insert Role by Access type to use in CRMA Log*/
                            if(isFieldmanager){
                                user.RoleByAccesstype__c = provisionRoleForCRMALog(accessTypeToRoleDeveloperNameMap);
                            }
                            /**DPM-5934 end*/

                        // profileName not contains 'Intennal' 
                        }else if(accessTypeToRoleDeveloperNameMap.containsKey(userAccessType) 
                        && !(!mapUserAppTypes.get(user.Id).contains('DPM') && !mapUserAppTypes.get(user.Id).contains('CUV') && mapUserAppTypes.get(user.Id).contains('DNA'))) { //DPM-6086 added condition not to provide role if there's only DNAMS access(maintain the previous role) by MinheeKim on 02.17.2025
                            Integer currentRoleIndex = rolePriorityList.indexOf(accessTypeToRoleDeveloperNameMap.get(userAccessType));
                            System.debug(LoggingLevel.ERROR, currentRoleIndex);
                            if((priorityIndexRole == null || (priorityIndexRole != null && currentRoleIndex != -1 && currentRoleIndex <= priorityIndexRole))) {
                                user.UserRoleId = roleDeveloperNameToRoleIdMap.get(accessTypeToRoleDeveloperNameMap.get(userAccessType));
                                priorityIndexRole = currentRoleIndex;
                            }
                        }else if(!mapUserAppTypes.get(user.Id).contains('DPM') && !mapUserAppTypes.get(user.Id).contains('CUV') && mapUserAppTypes.get(user.Id).contains('DNA')){  //DPM-6086 added condition to maintain the previous role when user has only DNAMS access by MinheeKim on 02.17.2025
                            user.UserRoleId = currentUserRoleId;
                        }

                        // CCSOM-67, retain System_Admin Role, use currentUserProfileName,currentUserRoleId which was declared before
                        if(/*currentUserProfileName.contains('CUV') &&*/ currentUserRoleDevName.equalsIgnoreCase(SYSTEMADMINRole)){
                            user.UserRoleId = currentUserRoleId;// BECOME SYSTE ADMIN ROLE AGAIN
                        }

                        //Added by Areum on 11-01-2024 for DNAMS PIR
                        //Changed the condition from (user.DNAMS_User__c == true || user.DNAMS_Internal_User__c == true) to  user.DNAMS_User_Flag__c == true [DPM-6020] by Minhee Kim 01.21.2025
                        /**DPM-6086 change to comment by Minhee on 02-12-2025 */
                        /*if(user.DPM_User__c == false && user.CUV_User__c == false && user.DNAMS_User_Flag__c == true && userAccessTypes.size() == 1) {
                            user.UserRoleId = null;
                        }*/

                        System.debug(LoggingLevel.ERROR, 'RoleId: '+user.UserRoleId);
                        System.debug(LoggingLevel.ERROR, 'NEW RoleId: '+currentUserRoleId);

                    }
                    
                    if(prioriyIndexProfile == null && currentUserProfileLicenseType != null) {
                        // Soyeon Kim changes for DPM-4640
                         //Removed  DNAMS_Internal_User__c, DNAMS_User_Flag__c from query [DPM-6020] by Minhee Kim - 01.21.2025
                        User minimumUser = [select DNAMS_User_Flag__c from User where Id = :user.Id];
                    
                        /*if(!minimumUser.DNAMS_User__c && !minimumUser.DNAMS_Internal_User__c){ //DPM-5015 added '!minimumUser.DNAMS_Internal_User__c' condition by MinheeKim - 24.04.11
                            user.ProfileId = minimumProfileLicenseTypeToProfileIdMap.get(currentUserProfileLicenseType);
                        }
                        //DPM-5015 added else if condition to provide hyundai user internal profile to DNAMS internal user with no access type by  MinheeKim - 24.04.11
                        else if(minimumUser.DNAMS_Internal_User__c && userProvisionng.FederationIdentifier__c!=null){
                            if(userProvisionng.FederationIdentifier__c.toLowerCase().contains(HYUNDAI) || userProvisionng.FederationIdentifier__c.toLowerCase().contains(GENESIS)){
                                user.ProfileId = profileNameToProfileIdMap.get(HYUNDAIprofile);
                            }
                            
                        }*/
                        //DPM-5015 end
                        // Soyeon Kim changes finish

                        if(!minimumUser.DNAMS_User_Flag__c){ //DPM-5015 added '!minimumUser.DNAMS_Internal_User__c' condition by MinheeKim - 24.04.11
                        //Changed the condition from !minimumUser.DNAMS_Internal_User__c && !minimumUser.DNAMS_User__c to !minimumUser.DNAMS_User_Flag__c [DPM-DNAMSUserProvisioningServiceQueueable] by Minhee Kim - 01.21.2025
                            user.ProfileId = minimumProfileLicenseTypeToProfileIdMap.get(currentUserProfileLicenseType); 
                        }
                        //DPM-5015 added else if condition to provide hyundai user internal profile to DNAMS internal user with no access type by  MinheeKim - 24.04.11
                        else if(minimumUser.DNAMS_User_Flag__c && userProvisionng.FederationIdentifier__c!=null){ 
                            //Changed the condition from minimumUser.DNAMS_Internal_User__c to minimumUser.DNAMS_User_Flag__c [DPM-6020] by Minhee Kim - 01.21.2025
                            if(userProvisionng.FederationIdentifier__c.toLowerCase().contains(HYUNDAI) || userProvisionng.FederationIdentifier__c.toLowerCase().contains(GENESIS)){
                                user.ProfileId = profileNameToProfileIdMap.get(HYUNDAIprofile);
                            }
                            
                        }
                    }

                }

                listOfUsersToUpdate.add(user);
            }
        }

        if(!listOfUsersToUpdate.isEmpty()) {
            try {
                UserTriggerHandler.run = false;
                update listOfUsersToUpdate;
                UserTriggerHandler.run = true;

            }
            catch(exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                throw(e);
            }
        }
    }

    /**
     * [Method Description] Check whether the user has Region Manager access type
     * Created by [MinheeKim] on [2023-11-27] for [DPM-5054]
     * Edited by [Minhee Kim] on [2024-03-26] for [DPM-5418] changed user assignment not to get DNAMS only user
    */
    public static void provisionRegionManager(List<HMAUserProvisioning__c> listOfHMAUserProvisionings, Map<Id, List<String>> mapUserProvisionAccessTypes, Set<String> accessTypes) {
        System.debug('provisionRegionManager started');
        Map<String, AccessType__mdt> roleAccessTypes = populateAccessTypes(accessTypes, HMAConstants.METADATA_ROLE_FIELD);
        Map<Id, User> userIdToUserMap = getUserMap(mapUserProvisionAccessTypes.keySet());
        List<User> listOfUsersToUpdate = new List<User>();
        for(HMAUserProvisioning__c userProvisionng:listOfHMAUserProvisionings) {
            if(userIdToUserMap.containsKey(userProvisionng.User__c)){
                User user = userIdToUserMap.get(userProvisionng.User__c);
                
                Boolean userUpdated = false;
                if(mapUserProvisionAccessTypes.containsKey(userProvisionng.User__c)) {
                    List<String> userAccessTypes = mapUserProvisionAccessTypes.get(userProvisionng.User__c);
                    String RegionCodes='';//DPM-5054 added to check region manager's region code by MH - 2023.11.27 
                    Boolean isRegionManager=false;//DPM-5054 added by MH - 2023.11.27 
                    for(String userAccessType:userAccessTypes) {
                        //DPM-5054 Check whether the user has Region Manager access type by Minhee - 2023.11.27
                        if((roleAccessTypes.get(userAccessType))!=null && (roleAccessTypes.get(userAccessType).RoleAPIName__c).contains('Region_Managers')){
                            if(!isRegionManager){
                                isRegionManager=true;
                                user.isRegionManager__c=isRegionManager;
                                System.debug(LoggingLevel.ERROR, 'user.isRegionManager__c RoleAPIName__c: '+roleAccessTypes.get(userAccessType).RoleAPIName__c);
                                System.debug(LoggingLevel.ERROR, 'user.isRegionManager__c: '+user.isRegionManager__c);
                                RegionCodes+=userAccessType.split('_')[2];
                                break;
                            }else{
                                RegionCodes+=','+userAccessType.split('_')[2];
                            }
                                
                        }else{
                            user.isRegionManager__c=isRegionManager;
                            // System.debug(LoggingLevel.ERROR, 'user.isRegionManager__c RoleAPIName__c 2: '+roleAccessTypes.get(userAccessType).RoleAPIName__c);
                            System.debug(LoggingLevel.ERROR, 'user.isRegionManager__c 2: '+user.isRegionManager__c);
                        } // DPM-5054 Change End

                    }
                    user.RM_Region_Codes__c=RegionCodes;
                    System.debug(LoggingLevel.ERROR, 'user.RM_Region_Codes__c: '+user.RM_Region_Codes__c);
                }

                listOfUsersToUpdate.add(user);
            }
        }

        if(!listOfUsersToUpdate.isEmpty()) {
            try {
                UserTriggerHandler.run = false;
                System.debug(LoggingLevel.ERROR, 'user.isRegionManager__c update: '+listOfUsersToUpdate[0].isRegionManager__c);
                update listOfUsersToUpdate;
                UserTriggerHandler.run = true;
            }
            catch(exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                throw(e);
            }
        }
    }

    /**
     * Description: Insert roles according to the access type that user has
     * Created by [MinheeKim] on [12-02-2024] for [DPM-5934]
    */
    private static String provisionRoleForCRMALog(Map<String, String> accessTypeToRoleDeveloperNameMap){
        String roleByAccesstype = '';
        Set<String> roleByAccesstypeSet = new Set<String>();
        if(accessTypeToRoleDeveloperNameMap.size()>0){
            for(String role : accessTypeToRoleDeveloperNameMap.KeySet()){
                List<String> accesstype = role.split('_');
                if (accesstype.size() > 1  && !role.contains('ReadOnly')) {
                    if(!roleByAccesstypeSet.contains(accesstype[1])){
                        if (String.isNotBlank(roleByAccesstype)) {
                            roleByAccesstype += ',';
                        }
                        roleByAccesstype += accesstype[1];
                    }
                    roleByAccesstypeSet.add(accesstype[1]);
                        
                }
            }

        }

        return roleByAccesstype;
    }

    private static List<HMAUserProvisioningDealerWrapper> getDealerProvisioningWrappers(List<HMAUserProvisioning__c> userProvisions,  Map<Id, List<String>> mapUserProvisionAccessTypes) {
        System.debug('Dhiraj getDealerProvisioningWrappers called');
        System.debug(LoggingLevel.ERROR, 'getDealerProvisioningWrappers');

        List<HMAUserProvisioningDealerWrapper> dealerWrappers = new List<HMAUserProvisioningDealerWrapper>();
        Set<String> accessTypes = new Set<String>();

        for(Id userKey:mapUserProvisionAccessTypes.keySet()) {
            accessTypes.addAll(mapUserProvisionAccessTypes.get(userKey));
        }

        Map<String, AccessType__mdt> accessTypeMap = populateAccessTypes(accessTypes, 'ObjectAccessAPINames__c');

        for(HMAUserProvisioning__c userProvision:userProvisions) {
            HMAUserProvisioningDealerWrapper dealerWrapper = new HMAUserProvisioningDealerWrapper(userProvision);
            
            if(mapUserProvisionAccessTypes.containsKey(userProvision.User__c)) {
                for(String accessType:mapUserProvisionAccessTypes.get(userProvision.User__c)) {
                    if(accessType.contains('/')) {
                        String[] dealerSharingAccessType = accessType.split('/');
                        String dealerAccessType = dealerSharingAccessType[0];
                        String dealerCode = dealerSharingAccessType[1];

                        if(accessTypeMap.containskey(dealerAccessType)) {
                            for(String objectAccessType:accessTypeMap.get(dealerAccessType).ObjectAccessAPINames__c.split(',')) {
                                //HMAUserProvisioningDealerWrapper dealerWrapper = new HMAUserProvisioningDealerWrapper(userProvision);
                                dealerWrapper.objectAccessTypes.add(new HMADealerObjectAccessWrapper(dealerCode, objectAccessType));
                                System.debug(LoggingLevel.ERROR, dealerSharingAccessType);
                                System.debug(LoggingLevel.ERROR, objectAccessType);
                                System.debug(LoggingLevel.ERROR, dealerCode);
                                dealerWrappers.add(dealerWrapper);
                            }
                        }
                    }
                }
            }
            else {
                
                
            }
            dealerWrappers.add(dealerWrapper);
        }

        System.debug(LoggingLevel.ERROR, 'dealerWrappers ' + dealerWrappers);
        return dealerWrappers;
    }    



    /**
     * [Method Description] close Evaluation and Action plan which are related to terminated account
     * Edited by [MinheeKim] on [2024-05-20] for [DPM-4455] Unshare the Action plan to dealer when dealer lose the access type
    */  
    private static void provisionDealerSharing(List<HMAUserProvisioningDealerWrapper> dealerProvisionWrappers) {
        
        Set<String> dealerCodes = new Set<String>();
        Set<String> ojbectAccessTypes = new Set<String>();
        Map<String, String> objectAccessDealerCodeMap = new Map<String, String>(); // DPM-4455 added Dealer Code, Object Access type map by MinheeKim - 2024.06.03
        Map<String, List<String>> userIdDealerCodeMap = new Map<String, List<String>>();

        for(HMAUserProvisioningDealerWrapper dealerProvisionWrapper:dealerProvisionWrappers) {
            System.debug(LoggingLevel.ERROR, 'provisionDealerSharing ' + dealerProvisionWrapper);
            if(!userIdDealerCodeMap.containsKey(dealerProvisionWrapper.userProvision.User__c)) {
                userIdDealerCodeMap.put(dealerProvisionWrapper.userProvision.User__c, new List<String>());
            }
            for(HMADealerObjectAccessWrapper dealerWrapper:dealerProvisionWrapper.objectAccessTypes) {
                dealerCodes.add(dealerWrapper.dealerCode);
                ojbectAccessTypes.add(dealerWrapper.objectAccessType);
                userIdDealerCodeMap.get(dealerProvisionWrapper.userProvision.User__c).add(dealerWrapper.dealerCode);
                //DPM-4455 start
                if(objectAccessDealerCodeMap.containsKey(dealerWrapper.dealerCode)){
                    String preObjectAccessList = objectAccessDealerCodeMap.get(dealerWrapper.dealerCode);
                    preObjectAccessList = preObjectAccessList+','+dealerWrapper.objectAccessType;
                    objectAccessDealerCodeMap.put(dealerWrapper.dealerCode, preObjectAccessList);
                }else{
                    objectAccessDealerCodeMap.put(dealerWrapper.dealerCode, dealerWrapper.objectAccessType);
                }//DPM-4455 end
            }
        }

        System.debug(LoggingLevel.ERROR, ojbectAccessTypes);
        Map<String, ObjectAccess__mdt> objectAccessMap = getObjectAccessMap(ojbectAccessTypes);
        System.debug(LoggingLevel.ERROR, objectAccessMap);

        System.debug(LoggingLevel.ERROR, 'provisionDealerSharing ' + userIdDealerCodeMap);
        handleAccountSharingForUserProvisions(dealerProvisionWrappers, dealerCodes, objectAccessMap, userIdDealerCodeMap);

        Map<String, Account> accountDealerMap = getAccountMapFromDealerCodes(dealerCodes);  
        Set<String> accountIds = new Set<String>();
        for(Account account:accountDealerMap.values()) {
            if(objectAccessDealerCodeMap.containsKey(account.DealerCode__c) && (objectAccessDealerCodeMap.get(account.DealerCode__c)).contains('ActionPlan')){ ////DPM-4455 added 
                accountIds.add(account.Id);
            }
        }

        System.debug(LoggingLevel.ERROR, accountDealerMap);
        if(!accountIds.isEmpty()) {
            BatchProcessObjectShares objectSharesBatch = new BatchProcessObjectShares();
            objectSharesBatch.updateAllObjectsSharing = true;
            objectSharesBatch.accountIds = accountIds;
            objectSharesBatch.type = 'Action Plan';
            if(!Test.isRunningTest()) {
                Database.executeBatch(objectSharesBatch, 1);
            }
        }

        /*handleActionPlanSharingForUserProvisions(dealerProvisionWrappers, dealerCodes, objectAccessMap, userIdDealerCodeMap);
        handleEvaluationSharingForUserProvisions(dealerProvisionWrappers, dealerCodes, objectAccessMap, userIdDealerCodeMap);

        BatchProcessDealershipActionPlanShares batchProcessActionPlans = new BatchProcessDealershipActionPlanShares(dealerProvisionWrappers, dealerCodes, objectAccessMap, userIdDealerCodeMap);
        Database.executeBatch(batchProcessActionPlans);*/
    }

    /**
     * [Method Description] Updates the region and district codes on User records based on their AccessType__c value.
     * Created by [Areum Lee] on [2024-01-12] for [DPM-5188]
     * Edited by [Minhee Kim] on [2024-03-26] for [DPM-5418] changed user assignment not to get DNAMS only user
    */
    public static void updateUserRegionAndDistrictCodes(List<HMAUserProvisioning__c> listOfHMAUserProvisionings, Map<Id, List<String>> mapUserProvisionAccessTypes, Set<String> accessTypes) {
        System.debug('updateUserRegionAndDistrictCodes started');

        Map<String, AccessType__mdt> roleAccessTypes = populateAccessTypes(accessTypes, HMAConstants.METADATA_ROLE_FIELD);
        Map<Id, User> userIdToUserMap = getUserMap(mapUserProvisionAccessTypes.keySet());
        List<User> listOfUsersToUpdate = new List<User>();

        for (HMAUserProvisioning__c userProvisionng : listOfHMAUserProvisionings) {
            if(userIdToUserMap.containsKey(userProvisionng.User__c)){
                User user = userIdToUserMap.get(userProvisionng.User__c);
                Boolean isInternal = isInternalUser(user);
                List<String> userAccessTypes = mapUserProvisionAccessTypes.get(userProvisionng.User__c);
                Boolean isRegionManager = isRegionManager(user, userAccessTypes, roleAccessTypes);

                if (isInternal) {
                    handleInternalUser(user, mapUserProvisionAccessTypes.get(userProvisionng.User__c), isRegionManager);
                } else {
                    handleExternalUser(user, mapUserProvisionAccessTypes.get(userProvisionng.User__c));
                }
                
                listOfUsersToUpdate.add(user);
            }
        }
        
        if (!listOfUsersToUpdate.isEmpty()) {
            System.debug('listOfUsersToUpdate before update: ' + listOfUsersToUpdate);
            
            try {
                UserTriggerHandler.run = false;
                update listOfUsersToUpdate;
                UserTriggerHandler.run = true;
                System.debug('listOfUsersToUpdate successfully updated');
            }
            catch(exception e) {
                System.debug(LoggingLevel.ERROR, 'Error updating listOfUsersToUpdate: ' + e.getMessage());
                throw(e);
            }
        }
        
        System.debug('updateUserRegionAndDistrictCodes completed');
    }

    
    /**
     * [Method Description] For internal user logic
     * - Set DistrictCodes__c and RegionCodes__c based on the access type.
     * Created by [Areum Lee] on [2024-01-12] for [DPM-5188]
     * - For Region Managers or Users with 'National' in UserRole.Name, only set the RegionCodes
     * Edited by [Areum Lee] on [2024-02-08] for [DPM-5342]
    */
    public static void handleInternalUser(User user, List<String> accessTypes, Boolean isRegionManager) {
        
        Set<String> districtCodes = extractDistrictCodes(accessTypes);
        Map<String, String> districtInfo = queryDistrictInfo(districtCodes);

        // Condition changed: Check if user is either a Region Manager or has 'National' in UserRole.Name
        if (isRegionManager || isRoleNational(user)) {
            // For Region Managers or Users with 'National' in UserRole.Name, only set the RegionCodes
            // 'DistrictCodes__c' should not be set for these users (it will be set to null)
            user.RegionCodes__c = districtInfo.get('RegionCodes');
            user.DistrictCodes__c = null;
        }
        else if (user.DNAMS_User_Flag__c) { //Added by Areum on 11-01-2024 for DNAMS PIR
            user.RegionCodes__c = districtInfo.get('RegionCodes');
            user.DistrictCodes__c = null;
        }
        else {
            // For other internal users, set both RegionCodes and DistrictCodes
            if (!districtInfo.isEmpty()) {
                user.RegionCodes__c = districtInfo.get('RegionCodes');
                user.DistrictCodes__c = districtInfo.get('DistrictCodes');
            }
            else {
                user.RegionCodes__c = null;
                user.DistrictCodes__c = null;
            }
        }
    }

    /**
     * [Method Description] Check if the user is an internal user
     * Created by [Areum Lee] on [2024-01-12] for [DPM-5188]
    */
    public static Boolean isInternalUser(User user) {
        return user.Profile.Name != null && !user.Profile.Name.contains('Partner');
    }

    /**
     * [Method Description] Check if the user is region manager
     * Created by [Areum Lee] on [2024-01-12] for [DPM-5188]
    */
    private static Boolean isRegionManager(User user, List<String> userAccessTypes, Map<String, AccessType__mdt> roleAccessTypes) {
        Boolean isRegionManager = false;
        
        for (String userAccessType : userAccessTypes) {
            AccessType__mdt roleAccessType = roleAccessTypes.get(userAccessType);
            if(roleAccessType != null && roleAccessType.RoleAPIName__c.contains('Region_Manager')) {
                isRegionManager = true;
                break;
            }
        }

    System.debug(LoggingLevel.DEBUG, isRegionManager);
        return isRegionManager;
    }

    /**
     * [Method Description] Check if the DeveloperName of UserRole contains 'National'
     * Created by [Areum Lee] on [2024-02-08] for [DPM-5342]
     * Edited by [Minhee Kim] on [2024-03-27] for [DPM-5438] added condition to check whether UserRole is null or not
    */
    public static Boolean isRoleNational(User user) {
        try{
            if([SELECT DeveloperName FROM UserRole WHERE Id =: user.UserRoleId].size()>0){ //DPM-5438 added condition to check whether UserRole is null or not by MinheeKim - 24.03.27
                UserRole userRole = [SELECT DeveloperName FROM UserRole WHERE Id =: user.UserRoleId];
                System.debug(userRole.DeveloperName.contains('National'));
                return userRole.DeveloperName.contains('National');
            }
            return false;
        }catch(exception e) {
            System.debug(LoggingLevel.ERROR, 'Error isRoleNational: ' + e.getMessage());
            throw(e);
        }
    }
    
    /**
     * [Method Description] For external user logic
     * - Set DistrictCodes__c and RegionCodes__c based on the access type.
     * Created by [Areum Lee] on [2024-01-12] for [DPM-5188]
    */
    public static void handleExternalUser(User user, List<String> accessTypes) {
        Set<String> dealerCodes = extractDealerCodes(accessTypes);
        
        if (!dealerCodes.isEmpty()) {
            Map<String, String> accountInfo = queryAccountInfo(dealerCodes);

            user.RegionCodes__c = accountInfo.get('RegionCodes');
            user.DistrictCodes__c = accountInfo.get('DistrictCodes');
        }
        else{
            user.RegionCodes__c = null;
            user.DistrictCodes__c = null;
        }
    }

    /**
     * [Method Description] 
     * Created by [Areum Lee] on [2024-01-12] for [DPM-5188]
     * 
     * Areum TODO: Check alternatives
    */
    private static Set<String> extractDistrictCodes(List<String> accessTypes) {
        Set<String> districtCodes = new Set<String>();
        
        for (String accessType : accessTypes) {
            Integer underscoreCount = accessType.countMatches('_');
            
            if (underscoreCount >= 2) {
                Integer firstUnderscoreIndex = accessType.indexOf('_');
                Integer secondUnderscoreIndex = accessType.indexOf('_', firstUnderscoreIndex + 1);
        
                if (secondUnderscoreIndex != -1) {
                    String districtCode = accessType.substring(secondUnderscoreIndex + 1);
                    districtCodes.add(districtCode);
                }
            }
        }
        
        return districtCodes;
    }
    
    /**
     * [Method Description] Extract dealer code from accessType
     * Created by [Areum Lee] on [2024-01-12] for [DPM-5188]
    */
    public static Set<String> extractDealerCodes(List<String> accessTypes) {
        Set<String> dealerCodes = new Set<String>();
        for (String accessType : accessTypes) {
            if (accessType.contains('/')) {
                String dealerCode = accessType.substring(accessType.indexOf('/') + 1);
                dealerCodes.add(dealerCode);
            }
        }
        return dealerCodes;
    }
    
    /**
     * [Method Description] Query for account information using the dealer code
     * Created by [Areum Lee] on [2024-01-12] for [DPM-5188]
    */
    public static Map<String, String> queryAccountInfo(Set<String> codes) {
        List<Account> accounts = new List<Account>();
        List<District__c> districts = new List<District__c>();
        Map<String, String> accountInfo = new Map<String, String> {
            'RegionCodes' => '',
            'DistrictCodes' => ''
        };
        accounts = [SELECT RegionCodePicklist__c, ServiceDistrictCodePicklist__c, MarketCodeGenesisPicklist__c 
                      FROM Account 
                     WHERE DealerCode__c IN :codes];

        Set<String> uniqueRegionCodes = new Set<String>();
        Set<String> uniqueDistrictCodes = new Set<String>();

        for (Account acc : accounts) {
            if (acc.RegionCodePicklist__c != null) {
                uniqueRegionCodes.add(acc.RegionCodePicklist__c);
            }
            if (acc.ServiceDistrictCodePicklist__c != null) {
                uniqueDistrictCodes.add(acc.ServiceDistrictCodePicklist__c);
            }
            if (acc.MarketCodeGenesisPicklist__c != null) {
                uniqueDistrictCodes.add(acc.MarketCodeGenesisPicklist__c);
            }
        }
    
        accountInfo.put('RegionCodes', String.join(new List<String>(uniqueRegionCodes), ','));
        accountInfo.put('DistrictCodes', String.join(new List<String>(uniqueDistrictCodes), ','));

        return accountInfo;
    }
    
    /**
     * [Method Description] Query for district information using DistrictCode__c or RegionCode__c
     * Created by [Areum Lee] on [2024-01-12] for [DPM-5188]
    */
    private static Map<String, String> queryDistrictInfo(Set<String> codes) {
        List<District__c> districts = new List<District__c>();
        Map<String, String> districtInfo = new Map<String, String> {
            'RegionCodes' => '',
            'DistrictCodes' => ''
        };

        List<String> regionCodes = new List<String>();
        List<String> districtCodes = new List<String>();

    System.debug(LoggingLevel.DEBUG, codes);

        // Separate by code length
        for (String code : codes) {
            if(code.length() == 2){
                regionCodes.add(code);
            } else if(code.length() == 3) {
                districtCodes.add(code);
            }
        }

    System.debug(LoggingLevel.DEBUG, regionCodes);
    System.debug(LoggingLevel.DEBUG, districtCodes);

        if(!regionCodes.isEmpty()){
            districts = [SELECT Name, DistrictCode__c, RegionCode__c
            FROM District__c
            WHERE RegionCode__c IN :regionCodes
            ORDER BY RegionCode__c, DistrictCode__c];
        }

        if(!districtCodes.isEmpty()){
            districts = [SELECT Name, DistrictCode__c, RegionCode__c
            FROM District__c
            WHERE DistrictCode__c IN :districtCodes
            ORDER BY RegionCode__c, DistrictCode__c];
        }

    System.debug(LoggingLevel.DEBUG, districts);

        Set<String> uniqueRegionCodes = new Set<String>();
        Set<String> uniqueDistrictCodes = new Set<String>();

        for (District__c dist : districts) {
            if (dist.RegionCode__c != null) {
                uniqueRegionCodes.add(dist.RegionCode__c);
            }
            if (dist.DistrictCode__c != null) {
                uniqueDistrictCodes.add(dist.DistrictCode__c);
            }
        }

        districtInfo.put('RegionCodes', String.join(new List<String>(uniqueRegionCodes), ','));
        districtInfo.put('DistrictCodes', String.join(new List<String>(uniqueDistrictCodes), ','));

    System.debug(LoggingLevel.DEBUG, districtInfo);

        return districtInfo;
    }

    /**
    * @description 
    */
    private static Map<String, AccessType__mdt> populateAccessTypes(Set<String> accessTypes, String metaDataField) {
        Map<String, AccessType__mdt> accessTypeMap = new Map<String, AccessType__mdt>();
        System.debug(LoggingLevel.ERROR, accessTypes);

        String sqlStatement = 'select DeveloperName, PermissionSetAPINames__c, ProfileAPIName__c, PublicGroupAPINames__c, RoleAPIName__c, PermissionSetGroupAPINames__c, ObjectAccessAPINames__c from AccessType__mdt ';
        sqlStatement += ' where Active__c = true ';
        sqlStatement += ' and DeveloperName in :accessTypes ';

        for(AccessType__mdt accessType:Database.query(sqlStatement)) {
            System.debug(LoggingLevel.ERROR, accessType);
            if(accessType.get(metaDataField) != null && accessType.get(metaDataField) != '') {
                accessTypeMap.put(accessType.DeveloperName, accessType);
            }
        }
        
        return accessTypeMap;
    } 

    /**
    * @description 
    DPM-4973 provise profile by federation Id - by MH - 2023.10.24
    */
    private static Map<String, String> populateFederationId() {
        Map<String, String> federationMap = new Map<String, String>();
  
        federationMap.put(HYUNDAI, HYUNDAIprofile);
        federationMap.put(GENESIS, GENESISprofile);
         
        System.debug(LoggingLevel.ERROR, federationMap);
        return federationMap;
    } 

    



    /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [24.04.08] for [DPM-5447]  added exception 
     * Edited by [Inho Kim] on [24.10.07] for [CCSOM-67]  If a user with CUV_BizAdmin_G or CUV_BizAdmin_H access types had CUV_Community_Hyundai/Genesis access, it should be retained.
    */
    private static void removeUnprovisionedPermissionSetAssignments(Map<Id, Map<String, Id>> userIdToPermissionSetNamesMap) {
        
        List<PermissionSetAssignment> permissionSetAssignmentsToDeleteList = new List<PermissionSetAssignment>();
        Set<String> permissionSetDeveloperNames = new Set<String>();

        for(String userKey:userIdToPermissionSetNamesMap.keySet()) {
            Map<String, Id> permissionSetDeveloperNameToPermissionSetAssignmenetIdMap = new  Map<String, Id>();
            if(userIdToPermissionSetNamesMap.containskey(userKey)) {
                permissionSetDeveloperNameToPermissionSetAssignmenetIdMap = userIdToPermissionSetNamesMap.get(userKey);
                for(String permissionSetDeveloperNameKey:permissionSetDeveloperNameToPermissionSetAssignmenetIdMap.keySet()) {
                    System.debug(LoggingLevel.ERROR, permissionSetDeveloperNameKey);
                    permissionSetDeveloperNames.add(permissionSetDeveloperNameKey);
                    permissionSetAssignmentsToDeleteList.add(new PermissionSetAssignment(Id = permissionSetDeveloperNameToPermissionSetAssignmenetIdMap.get(permissionSetDeveloperNameKey)));
                }                
            }
        }
        try{
            if(!permissionSetAssignmentsToDeleteList.isEmpty() ) {
                // delete permissionSetAssignmentsToDeleteList;
                Database.delete(permissionSetAssignmentsToDeleteList, false); //DPM-5447 added exception to prevent deleting error by MinheeKim - 24.04.08
            }
        }catch(exception e) {
            System.debug(LoggingLevel.ERROR, 'Error removeUnprovisionedPermissionSetAssignments: ' + e.getMessage());
            throw(e);
        }
            
    } 

    
    private static void removePermissionSetLicensesForUsers(Set<Id> userIds) {

        Map<String, PermissionSetLicenseAssign> permissionSetLicenseMap = new Map<String, PermissionSetLicenseAssign>();
        Map<Id, PermissionSetAssignment> permissionSetGroupMap = new Map<Id, PermissionSetAssignment>();

        for(PermissionSetLicenseAssign assignedLicense:[select AssigneeId, PermissionSetLicenseId from PermissionSetLicenseAssign where AssigneeId in :userIds and PermissionSetLicenseId != null]) {
            permissionSetLicenseMap.put(assignedLicense.AssigneeId + '-' + assignedLicense.PermissionSetLicenseId, assignedLicense );
        }

        // DPM-4640 : add PermissionSet.Name in query
        for(PermissionSetAssignment assignment:[select AssigneeId, PermissionSet.LicenseId, PermissionSetGroupId, PermissionSet.Name from PermissionSetAssignment where AssigneeId in :userIds ]) {
            if(permissionSetLicenseMap.containsKey(assignment.AssigneeId + '-' + assignment.PermissionSet.LicenseId)) {
                permissionSetLicenseMap.remove(assignment.AssigneeId + '-' + assignment.PermissionSet.LicenseId);
            }
            if(assignment.PermissionSetGroupId != null) {
               //Dhiraj Licence handle here for DPM
                //test it later
                
                if((assignment.PermissionSet.Name).contains('DPM')
                   // CUV Program Changes - Start
                   || (assignment.PermissionSet.Name).contains('CUV')
                   // CUV Program Changes - End
                   || (assignment.PermissionSet.Name).contains('Safety') 
                   || (assignment.PermissionSet.Name).contains('Reports_and_Dash') 
                   || (assignment.PermissionSet.Name).contains('Multi-Factor Authentication') 
                   || (assignment.PermissionSet.Name).contains('Manage')
                   || (assignment.PermissionSet.Name).contains('JDP')
                   || (assignment.PermissionSet.Name).contains('DNAMS') //Added by Areum on 11-01-2024 for DNAMS PIR
                   ){ 
                     
                      permissionSetGroupMap.put(assignment.PermissionSetGroupId, assignment);
                   }
				
                //Dhiraj Changes ends here
                
                //permissionSetGroupMap.put(assignment.PermissionSetGroupId, assignment);
            }
        }

        Map<Id, Set<String>> permissionSetGroupLicenseMap = new Map<Id, Set<String>>();
        for(PermissionSetGroupComponent component:[select Id, PermissionSetId, PermissionSetGroupId, PermissionSet.LicenseId from PermissionSetGroupComponent where PermissionSetGroupId in :permissionSetGroupMap.keySet() and PermissionSet.LicenseId != null]) {
            if(!permissionSetGroupLicenseMap.containsKey(component.PermissionSetGroupId)) {
                permissionSetGroupLicenseMap.put(component.PermissionSetGroupId, new Set<String>());
            }
            permissionSetGroupLicenseMap.get(component.PermissionSetGroupId).add(component.PermissionSet.LicenseId);
        }

        for(PermissionSetAssignment assignment:permissionSetGroupMap.values()) {
            if(permissionSetGroupLicenseMap.containsKey(assignment.PermissionSetGroupId)) {
                for(String permississionSetLicenseId:permissionSetGroupLicenseMap.get(assignment.PermissionSetGroupId)) {
                    if(permissionSetLicenseMap.containsKey(assignment.AssigneeId + '-' + permississionSetLicenseId)) {
                        permissionSetLicenseMap.remove(assignment.AssigneeId + '-' + permississionSetLicenseId);
                    }
                }
            }
        }
        try{
            if(!permissionSetLicenseMap.values().isEmpty()) {
                delete permissionSetLicenseMap.values();
            }
        }catch(exception e) {
            System.debug(LoggingLevel.ERROR, 'Error removePermissionSetLicensesForUsers: ' + e.getMessage());
            throw(e);
        }
    }

    /**
    * @description 
    */
    private static void removeUnprovisionedPublicGroups(Map<Id, Map<String, Id>> userIdToPublicGroupsMap) {
        List<GroupMember> groupMemberToDeleteList = new List<GroupMember>();
    
        for(String userKey:userIdToPublicGroupsMap.keySet()) {
            Map<String, Id> publicGroupDeveloperNameToPublicGroupIdMap = new  Map<String, Id>();
            publicGroupDeveloperNameToPublicGroupIdMap = userIdToPublicGroupsMap.get(userKey);
            for(String publicGroupDeveloperNameKey:publicGroupDeveloperNameToPublicGroupIdMap.keySet()) {
                groupMemberToDeleteList.add(new GroupMember(Id = publicGroupDeveloperNameToPublicGroupIdMap.get(publicGroupDeveloperNameKey)));
            }                
        }

        if(!groupMemberToDeleteList.isEmpty()) {
            delete groupMemberToDeleteList;
        }
    }

    /**
     * [Method Description] Remove action plan/evaluation share when dealer lose the permission of them
     * Created by [MinheeKim] on [24.05.14] for [DPM-4455] 
    */
    public static void removeActionPlanEvaluationSharing(List<HMAUserProvisioningDealerWrapper> dealerProvisionWrappers) {
        
        List<String> rowcause= new List<String>();
        rowcause.add('ImplicitChild');
        rowcause.add('ImplicitParent');
        rowcause.add('Owner');
        rowcause.add('Team');
        rowcause.add('Rule');
        rowcause.add('TerritoryRule');

        Set<String> dealerCodes = new Set<String>();
        Map<String, String> objectAccessTypes = new Map<String, String>(); //  Map of <Dealer Code, Object Access type>
        Map<String, Map<String, String>> userIdDealerCodeMap = new Map<String, Map<String, String>>();
        List<Action_Plan__Share> ActionPlanShareListToRemove = new List<Action_Plan__Share>();
        List<Evaluation__Share> EvaluationShareListToRemove = new List<Evaluation__Share>();

        for(HMAUserProvisioningDealerWrapper dealerProvisionWrapper:dealerProvisionWrappers) {
            System.debug(LoggingLevel.ERROR, 'provisionDealerSharing ' + dealerProvisionWrapper);
            if(!userIdDealerCodeMap.containsKey(dealerProvisionWrapper.userProvision.User__c)) {
                userIdDealerCodeMap.put(dealerProvisionWrapper.userProvision.User__c, new Map<String, String>());
            }
            for(HMADealerObjectAccessWrapper dealerWrapper:dealerProvisionWrapper.objectAccessTypes) {
                if(objectAccessTypes.containsKey(dealerWrapper.dealerCode)){
                    String preObjectAccessList = objectAccessTypes.get(dealerWrapper.dealerCode);
                    preObjectAccessList = preObjectAccessList+','+dealerWrapper.objectAccessType;
                    objectAccessTypes.put(dealerWrapper.dealerCode, preObjectAccessList);
                }else{
                    objectAccessTypes.put(dealerWrapper.dealerCode, dealerWrapper.objectAccessType);
                }

                userIdDealerCodeMap.put(dealerProvisionWrapper.userProvision.User__c, objectAccessTypes);
            }
        }

        List<Action_Plan__Share> actionPlanShare = [SELECT Id, AccessLevel, Parent.Account__r.DealerCode__c, UserOrGroupId FROM Action_Plan__Share WHERE UserOrGroupId IN :userIdDealerCodeMap.keySet() and RowCause NOT IN :rowcause];
        List<Evaluation__Share> evaluationShare = [SELECT Id, AccessLevel, Parent.Account__r.DealerCode__c, UserOrGroupId FROM Evaluation__Share WHERE UserOrGroupId IN :userIdDealerCodeMap.keySet() and RowCause NOT IN :rowcause];
        Map<Id, List<Action_Plan__Share>> ActionPlanShareMapToRemove = new Map<Id, List<Action_Plan__Share>>();
        Map<Id, List<Evaluation__Share>> EvaluationShareMapToRemove = new Map<Id, List<Evaluation__Share>>();
        //Dealer code 별로 action plan share, evaluation share 정리
        for(Action_Plan__Share apShare : actionPlanShare){
            if(ActionPlanShareMapToRemove.containsKey(apShare.UserOrGroupId)){
                List<Action_Plan__Share> preShareList = ActionPlanShareMapToRemove.get(apShare.UserOrGroupId);
                preShareList.add(apShare);
                ActionPlanShareMapToRemove.put(apShare.UserOrGroupId,preShareList);
            }else{
                List<Action_Plan__Share> shareList = new List<Action_Plan__Share>();
                shareList.add(apShare);
                ActionPlanShareMapToRemove.put(apShare.UserOrGroupId,shareList);
            }
        }

        for(Evaluation__Share evalShare : evaluationShare){
            if(EvaluationShareMapToRemove.containsKey(evalShare.UserOrGroupId)){
                List<Evaluation__Share> preShareList = EvaluationShareMapToRemove.get(evalShare.UserOrGroupId);
                preShareList.add(evalShare);
                EvaluationShareMapToRemove.put(evalShare.UserOrGroupId,preShareList);
            }else{
                List<Evaluation__Share> shareList = new List<Evaluation__Share>();
                shareList.add(evalShare);
                EvaluationShareMapToRemove.put(evalShare.UserOrGroupId,shareList);
            }
        }
        
        //현재 있는 Evaluation, Action plan 의 Share 중에서 Dealer가 여전히 Evaluation, Action plan에 대해 권한을 갖고 있는 Account에 대해서는 ShareListToRemove에서 제외 시킴.
        //Among the current Share of Evaluation and Action Plan, Account, which Dealer still has authority over Evaluation and Action Plan, is excluded from ShareListToRemove.
        for(String user : userIdDealerCodeMap.keySet()){
            if(ActionPlanShareMapToRemove.containsKey(Id.valueOf(user)) && userIdDealerCodeMap.containsKey(Id.valueOf(user))){
                for(Action_Plan__Share apShare : ActionPlanShareMapToRemove.get(Id.valueOf(user))){
                    if((userIdDealerCodeMap.get(Id.valueOf(user))).containsKey(apShare.Parent.Account__r.DealerCode__c)
                    && ((userIdDealerCodeMap.get(Id.valueOf(user))).get(apShare.Parent.Account__r.DealerCode__c)).contains('DPM_AP')){
                        continue;
                    }else{
                        ActionPlanShareListToRemove.add(apshare);
                    }
                }
            }

            if(EvaluationShareMapToRemove.containsKey(Id.valueOf(user)) && userIdDealerCodeMap.containsKey(Id.valueOf(user))){
                for(Evaluation__Share evalShare : EvaluationShareMapToRemove.get(Id.valueOf(user))){
                    if((userIdDealerCodeMap.get(Id.valueOf(user))).containsKey(evalShare.Parent.Account__r.DealerCode__c)
                    && ((userIdDealerCodeMap.get(Id.valueOf(user))).get(evalShare.Parent.Account__r.DealerCode__c)).contains('DPM_Eval')){
                        continue;
                    }else{
                        EvaluationShareListToRemove.add(evalShare);
                    }
                }
            }
        }

        // System.debug(LoggingLevel.ERROR, shareMapToRemove);
        if(!ActionPlanShareListToRemove.isEmpty()) {
            delete ActionPlanShareListToRemove;
        }

        if(!EvaluationShareListToRemove.isEmpty()) {
            delete EvaluationShareListToRemove;
        }
    }

    /**
    * @description 
    */
    private static Map<String, Id> getPermissionSetMap(List<String> listOfPermissionSetNames) {

        System.debug(LoggingLevel.ERROR, listOfPermissionSetNames);

        Map<String, Id> permissionSetNameToPermissionIdMap = new Map<String, Id>();
        for(PermissionSet permissionSet:[select Id, Name from PermissionSet where Name in :listOfPermissionSetNames]) {
            permissionSetNameToPermissionIdMap.put(permissionSet.Name, permissionSet.Id);
        }
        return permissionSetNameToPermissionIdMap;
    }

    /**
    * @description 
    */
    private static Map<String, Id> getPermissionSetGroupMap(List<String> listOfPermissionSetGroupNames) {

        System.debug(LoggingLevel.ERROR, listOfPermissionSetGroupNames);

        Map<String, Id> permissionSetGroupNameToPermissionGroupIdMap = new Map<String, Id>();
        for(PermissionSetGroup permissionSetGroup:[select Id, DeveloperName from PermissionSetGroup where DeveloperName in :listOfPermissionSetGroupNames]) {
            permissionSetGroupNameToPermissionGroupIdMap.put(permissionSetGroup.DeveloperName, permissionSetGroup.Id);
        }
        return permissionSetGroupNameToPermissionGroupIdMap;
    } 

    /**
    * @description 
    */
    private static Map<String, Id> getProfileMap(List<String> listOfProfileNames) {

        System.debug(LoggingLevel.ERROR, listOfProfileNames);

        Map<String, Id> profileNameToProfileIdMap = new Map<String, Id>();
        for(Profile profile:[select Id, Name from Profile where Name in :listOfProfileNames]) {
            profileNameToProfileIdMap.put(profile.Name, profile.Id);
        }
        return profileNameToProfileIdMap;
    }

    private static Map<String, Id> getMinimumProfileMap() {

        Map<String, Id> profileNameToProfileIdMap = new Map<String, Id>();
        for(Profile profile:[select Id, Name, UserLicense.Name from Profile where Name like 'Minimum Access%']) {
            profileNameToProfileIdMap.put(profile.UserLicense.Name, profile.Id);
        }
        return profileNameToProfileIdMap;
    }

    /**
    * @description 
    */
    private static Map<String, Id> getUserRoleMap(List<String> listOfRoleNames) {

        System.debug(LoggingLevel.ERROR, listOfRoleNames);

        Map<String, Id> userRoleDeveloperNameToUserRoleIdMap = new Map<String, Id>();
        for(UserRole userRole:[select Id, DeveloperName from UserRole where DeveloperName in :listOfRoleNames]) {
            userRoleDeveloperNameToUserRoleIdMap.put(userRole.DeveloperName, userRole.Id);
        }
        return userRoleDeveloperNameToUserRoleIdMap;
    }

    /**
    * @description 
    */
    private static Map<String, Id> getPublicGroupMap(List<String> listOfPublicGroupNames) {

        System.debug(LoggingLevel.ERROR, listOfPublicGroupNames);

        Map<String, Id> publicGroupNameToPublicGroupIdMap = new Map<String, Id>();
        for(Group publicGroup:[select Id, DeveloperName from Group where DeveloperName in :listOfPublicGroupNames and Type = 'Regular']) {
            publicGroupNameToPublicGroupIdMap.put(publicGroup.DeveloperName, publicGroup.Id);
        }
        return publicGroupNameToPublicGroupIdMap;
    }

    /**
    * @description 
    * 
    * ----- Change Log -----
    * @Author : MinheeKim / Date : 2023.11.27
    * @Ticket Number :  DPM-5054
    * @Change Description : added isRegionManager__c, RM_Region_Codes__c
    * Edited by [Minhee Kim] on [2024-03-26] for [DPM-5418] changed user assignment not to get DNAMS only user
    * Edited by [Minhee Kim] on [2024-04-11] for [DPM-5015] added DNAMS_Internal_User__c to query
    * Edited by Areum on 11-04-2024 for DNAMS PIR
    * Edited by [Minhee Kim] on [2025-01-21] for [DPM-6020] remove DNAMS_Internal_User__c to consolidate the flags
    */
    
    private static Map<Id, User> getUserMap(Set<Id> userIds) {
        try{
            Map<Id, User> userMap = new Map<Id, User>(); 
            //DPM-5015 DNAMS_Internal_User__c
            //Remove DNAMS_Internal_User__c, DNAMS_User__c from query [DPM-6020] by Minhee Kim - 01.21.2025
            for(User user:[select Id, Profile.Name, UserRole.DeveloperName, UserRoleId, Profile.UserLicense.Name, IsActive, DPM_User__c, CUV_User__c,  isRegionManager__c, RM_Region_Codes__c, DNAMS_User_Flag__c from User where Id in :userIds]) {
                //Changes Made by Dhiraj starts here DPM-4466 
                System.debug('user');
                System.debug(user);
                if(!user.DPM_User__c && !user.CUV_User__c && !user.DNAMS_User_Flag__c ){ //DPM-5418 changed the condition from '!user.DNAMS_User__c' to '!user.DPM_User__c && !user.CUV_User__c && user.DNAMS_User__c' by Minhee - 24.03.11 
                continue; 
                }else{
                    userMap.put(user.Id, user); 
                } //DPM-5418 end
                //Changes Made by Dhiraj ends here DPM-4466
                //userMap.put(user.Id, user);
            }
            return userMap;
        }catch(exception e) {
            System.debug(LoggingLevel.ERROR, 'Error getUserMap: ' + e.getMessage());
            throw(e);
        }
    }

    
	/**
    * @description getExistingPermissionSetsForUsers old method uncomment the below comment if you want to use the old code
    */

    private static Map<Id, Map<String, Id>> getExistingPermissionSetsForUsers(Set<Id> userIds) {
        
        
        Map<Id, Map<String, Id>> userIdToPermissionSetNamesMap = new Map<Id, Map<String, Id>>();
        
        for(PermissionSetAssignment assignment:[select Id, PermissionSet.Name, AssigneeId from PermissionSetAssignment where AssigneeId in :userIds and PermissionSetId != null and PermissionSetGroupId = null and PermissionSet.IsOwnedByProfile = false ]) {
            if(!userIdToPermissionSetNamesMap.containsKey(assignment.AssigneeId)) {
                userIdToPermissionSetNamesMap.put(assignment.AssigneeId, new Map<String, Id>());
            }
            //Changes Made by Dhiraj starts here DPM-4466
            if((assignment.PermissionSet.Name).contains('DPM') || (assignment.PermissionSet.Name).contains('Safety') 
               // CUV Program Changes - Start
               || (assignment.PermissionSet.Name).contains('CUV')
               // CUV Program Changes - End
               || (assignment.PermissionSet.Name).contains('Reports_and_Dash') 
               || (assignment.PermissionSet.Name).contains('Multi-Factor Authentication') 
               || (assignment.PermissionSet.Name).contains('Manage')
               || (assignment.PermissionSet.Name).contains('DNAMS') // DNAMS PIR
               ){
               userIdToPermissionSetNamesMap.get(assignment.AssigneeId).put(assignment.PermissionSet.Name, assignment.Id);
            }
            //Changes made by Dhiraj ends here DPM-4466
            
            //userIdToPermissionSetNamesMap.get(assignment.AssigneeId).put(assignment.PermissionSet.Name, assignment.Id);
        }
        
        return userIdToPermissionSetNamesMap;
    }
	

    /**
    * @description 
    */
    private static Map<Id, Map<String, Id>> getExistingPermissionSetGroupsForUsers(Set<Id> userIds) {
        
        Map<Id, Map<String, Id>> userIdToPermissionSetGroupDeveloperNamesMap = new Map<Id, Map<String, Id>>();
        for(PermissionSetAssignment assignment:[select Id, PermissionSetGroup.DeveloperName, AssigneeId from PermissionSetAssignment where AssigneeId in :userIds and PermissionSetGroupId != null and PermissionSet.IsOwnedByProfile = false ]) {
            if(!userIdToPermissionSetGroupDeveloperNamesMap.containsKey(assignment.AssigneeId)) {
                userIdToPermissionSetGroupDeveloperNamesMap.put(assignment.AssigneeId, new Map<String, Id>());
            }
            
            
            //Dhiraj Changes start here
            if((assignment.PermissionSetGroup.DeveloperName).contains('DPM')
               // CUV Program Changes - Start
               ||(assignment.PermissionSetGroup.DeveloperName).contains('CUV')
               // CUV Program Changes - End
               ||(assignment.PermissionSetGroup.DeveloperName).contains('Hyundai') 
               ||(assignment.PermissionSetGroup.DeveloperName).contains('Safety') 
               ||(assignment.PermissionSetGroup.DeveloperName).contains('Genesis') 
               || (assignment.PermissionSetGroup.DeveloperName).contains('JDP')
              || (assignment.PermissionSetGroup.DeveloperName).contains('National')
              || (assignment.PermissionSetGroup.DeveloperName).contains('DNAMS') // DNAMS PIR
              ){
                
                   userIdToPermissionSetGroupDeveloperNamesMap.get(assignment.AssigneeId).put(assignment.PermissionSetGroup.DeveloperName, assignment.Id);
               	
               }
            //Dhiraj Changes ends here
            
            //userIdToPermissionSetGroupDeveloperNamesMap.get(assignment.AssigneeId).put(assignment.PermissionSetGroup.DeveloperName, assignment.Id);
        }

        return userIdToPermissionSetGroupDeveloperNamesMap;
    }

    /**
    * @description 
    */
    private static Map<Id, Map<String, Id>> getExistingPublicGroupsForUsers(Set<Id> userIds) {
        
        Map<Id, Map<String, Id>> userIdToPublicGroupDeveloperNamesMap = new Map<Id, Map<String, Id>>();
        for(GroupMember publicGroupMember:[select Id, UserOrGroupId, GroupId, Group.DeveloperName from GroupMember where UserOrGroupId in :userIds and Group.Type = 'Regular' ]) {
            if(!userIdToPublicGroupDeveloperNamesMap.containsKey(publicGroupMember.UserOrGroupId)) {
                userIdToPublicGroupDeveloperNamesMap.put(publicGroupMember.UserOrGroupId, new Map<String, Id>());
            }
            
            //Dhiraj Changes start here
            if((publicGroupMember.Group.DeveloperName).contains('DPM') 
               ||(publicGroupMember.Group.DeveloperName).contains('GMA') 
               ||(publicGroupMember.Group.DeveloperName).contains('HMA') 
               ||(publicGroupMember.Group.DeveloperName).contains('Hyundai') 
               || (publicGroupMember.Group.DeveloperName).contains('Genesis')
              || (publicGroupMember.Group.DeveloperName).contains('Safety')
              || (publicGroupMember.Group.DeveloperName).contains('JDP')
              ||(publicGroupMember.Group.DeveloperName).contains('National')
              || (publicGroupMember.Group.DeveloperName).contains('DNA') // DNAMS PIR
              || (publicGroupMember.Group.DeveloperName).contains('DND') // DNAMS PIR
              || (publicGroupMember.Group.DeveloperName).contains('DNAMS') // DNAMS PIR
              ){
                
                   userIdToPublicGroupDeveloperNamesMap.get(publicGroupMember.UserOrGroupId).put(publicGroupMember.Group.DeveloperName, publicGroupMember.Id);
       
               }
            //Dhiraj Changes ends here

            
           // userIdToPublicGroupDeveloperNamesMap.get(publicGroupMember.UserOrGroupId).put(publicGroupMember.Group.DeveloperName, publicGroupMember.Id);
        }
        return userIdToPublicGroupDeveloperNamesMap;
    }

    /**
    * @description 
    */
    public static void completeUserProvisioning(List<HMAUserProvisioning__c> userProvisionsToComplete) {

        for(HMAUserProvisioning__c userProvisioning:userProvisionsToComplete) {
            userProvisioning.Status__c = 'Completed';
        }
        update userProvisionsToComplete;
    }
    

    /**
    * @description 
    */
    /*private static void handleActionPlanSharingForUserProvisions(List<HMAUserProvisioningDealerWrapper> dealerProvisionWrappers, Set<String> dealerCodes, Map<String, ObjectAccess__mdt> objectAccessMap, Map<String, List<String>> userIdDealerCodeMap) {
        
        Map<String, Map<String, List<Action_Plan__Share>>> existingActionPlanSharesByDealerCode = getMapOfExistingActionPlanSharesForUserByDealerCode(userIdDealerCodeMap.keySet());
        for(String key:existingActionPlanSharesByDealerCode.keySet()) {
            dealerCodes.addAll(existingActionPlanSharesByDealerCode.get(key).keySet());
        }    

        Map<String, Map<Id, Action_Plan__c>> actionPlanDealerMap = getActionPlanMapFromDealerCodes(dealerCodes);
        HMAApexSharing apexSharing = new HMAApexSharing('Action_Plan__c');

        for(HMAUserProvisioningDealerWrapper dealerProvisionWrapper:dealerProvisionWrappers) {
            for(HMADealerObjectAccessWrapper dealerWrapper:dealerProvisionWrapper.objectAccessTypes) {   
                if(objectAccessMap.containsKey(dealerWrapper.objectAccessType) && objectAccessMap.get(dealerWrapper.objectAccessType).ObjectAPINames__c.contains('Action_Plan__c')) {
                    if(actionPlanDealerMap.containsKey(dealerWrapper.dealerCode)) {
                        for(Action_Plan__c actionPlan:actionPlanDealerMap.get(dealerWrapper.dealerCode).values()) {
                            String accessLevel = objectAccessMap.get(dealerWrapper.objectAccessType).AccessLevel__c;
                            apexSharing.add(actionPlan, dealerProvisionWrapper.userProvision.User__c, accessLevel, Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c );
                        }
                        if(existingActionPlanSharesByDealerCode.containsKey(dealerProvisionWrapper.userProvision.User__c)) {
                            existingActionPlanSharesByDealerCode.get(dealerProvisionWrapper.userProvision.User__c).remove(dealerWrapper.dealerCode);
                        }
                    }
                }
            }
        }
        apexSharing.share();

        for(String existingShareKeyUser:existingActionPlanSharesByDealerCode.keySet()) {
            for(String existingShareKeyDealer:existingActionPlanSharesByDealerCode.get(existingShareKeyUser).keySet()) {
                for(Action_Plan__Share actionPlanShare:existingActionPlanSharesByDealerCode.get(existingShareKeyUser).get(existingShareKeyDealer)) {
                    Action_Plan__c actionPlan = actionPlanDealerMap.get(existingShareKeyDealer).get(actionPlanShare.ParentId);
                    apexSharing.remove(actionPlan, existingShareKeyUser, actionPlanShare.AccessLevel, Schema.Action_Plan__Share.RowCause.Dealer_Action_Plan_Sharing__c);
                }
            }
        }
        apexSharing.unshare();
    }*/

    /**
    * @description 
    */
    private static void handleAccountSharingForUserProvisions(List<HMAUserProvisioningDealerWrapper> dealerProvisionWrappers, Set<String> dealerCodes, Map<String, ObjectAccess__mdt> objectAccessMap, Map<String, List<String>> userIdDealerCodeMap) {
        Map<String, Map<String, AccountShare>> existingSharesForAllAccountsByDealerCode = getMapOfExistingAccountSharesForUserByDealerCode(userIdDealerCodeMap.keySet());

        for(String key:existingSharesForAllAccountsByDealerCode.keySet()) {
            dealerCodes.addAll(existingSharesForAllAccountsByDealerCode.get(key).keySet());
        }        

        Map<String, Account> accountDealerMap = getAccountMapFromDealerCodes(dealerCodes);        
        HMAApexSharing apexSharing = new HMAApexSharing('Account');

        for(HMAUserProvisioningDealerWrapper dealerProvisionWrapper:dealerProvisionWrappers) {
            for(HMADealerObjectAccessWrapper dealerWrapper:dealerProvisionWrapper.objectAccessTypes) {     
                if(objectAccessMap.containsKey(dealerWrapper.objectAccessType) && objectAccessMap.get(dealerWrapper.objectAccessType).ObjectAPINames__c.contains('Account')) {
                    if(accountDealerMap.containsKey(dealerWrapper.dealerCode)) {
                        String accessLevel = objectAccessMap.get(dealerWrapper.objectAccessType).AccessLevel__c;
                        Account account = accountDealerMap.get(dealerWrapper.dealerCode);
                        apexSharing.add(account, dealerProvisionWrapper.userProvision.User__c, accessLevel, null);
                    }
                }
                if(existingSharesForAllAccountsByDealerCode.containsKey(dealerProvisionWrapper.userProvision.User__c)) {
                    if(existingSharesForAllAccountsByDealerCode.get(dealerProvisionWrapper.userProvision.User__c).containsKey(dealerWrapper.dealerCode)) {
                        existingSharesForAllAccountsByDealerCode.get(dealerProvisionWrapper.userProvision.User__c).remove(dealerWrapper.dealerCode);
                    }
                }
            }
        }
        apexSharing.share();

        for(String existingShareKeyUser:existingSharesForAllAccountsByDealerCode.keySet()) {
            for(String existingShareKeyDealer:existingSharesForAllAccountsByDealerCode.get(existingShareKeyUser).keySet()) {
                Account account = accountDealerMap.get(existingShareKeyDealer);
                AccountShare accountShare = existingSharesForAllAccountsByDealerCode.get(existingShareKeyUser).get(existingShareKeyDealer);
                apexSharing.remove(account, existingShareKeyUser, accountShare.AccountAccessLevel, null);
            }
        }
        apexSharing.unshare();
    }

    /**
    * @description 
    */
    /*private static Map<String, Map<Id, Action_Plan__c>> getActionPlanMapFromDealerCodes(Set<String> dealerCodes) {

        Map<String, Map<Id, Action_Plan__c>> actionPlanMapByDealerCodes = new Map<String, Map<Id, Action_Plan__c>>();

        for(Action_Plan__c actionPlan:[select Id, Account__r.DealerCode__c, OwnerId from Action_Plan__c where Account__r.DealerCode__c in :dealerCodes and (Status__c = :ACTION_PLAN_DRAFT_STATUS or Status__c = :ACTION_PLAN_IN_PROGRESS_STATUS)]) {
            if(!actionPlanMapByDealerCodes.containsKey(actionPlan.Account__r.DealerCode__c)) {
                actionPlanMapByDealerCodes.put(actionPlan.Account__r.DealerCode__c, new Map<Id, Action_Plan__c>());
            }
            actionPlanMapByDealerCodes.get(actionPlan.Account__r.DealerCode__c).put(actionPlan.Id, actionPlan);
        }   

        return actionPlanMapByDealerCodes;
    }*/

    /**
    * @description 
    */
    /*private static void handleEvaluationSharingForUserProvisions(List<HMAUserProvisioningDealerWrapper> dealerProvisionWrappers, Set<String> dealerCodes, Map<String, ObjectAccess__mdt> objectAccessMap, Map<String, List<String>> userIdDealerCodeMap) {
        
        Map<String, Map<String, List<Evaluation__Share>>> existingEvaluationSharesByDealerCode = getMapOfExistingEvaluationSharesForUserByDealerCode(userIdDealerCodeMap.keySet());
        for(String key:existingEvaluationSharesByDealerCode.keySet()) {
            dealerCodes.addAll(existingEvaluationSharesByDealerCode.get(key).keySet());
        }    

        Map<String, Map<Id, Evaluation__c>> evaluationDealerMap = getEvaluationMapFromDealerCodes(dealerCodes);
        HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__c');

        for(HMAUserProvisioningDealerWrapper dealerProvisionWrapper:dealerProvisionWrappers) {
            for(HMADealerObjectAccessWrapper dealerWrapper:dealerProvisionWrapper.objectAccessTypes) {   
                if(objectAccessMap.containsKey(dealerWrapper.objectAccessType) && objectAccessMap.get(dealerWrapper.objectAccessType).ObjectAPINames__c.contains('Evaluation__c')) {
                    if(evaluationDealerMap.containsKey(dealerWrapper.dealerCode)) {
                        for(Evaluation__c evaluation:evaluationDealerMap.get(dealerWrapper.dealerCode).values()) {
                            String accessLevel = objectAccessMap.get(dealerWrapper.objectAccessType).AccessLevel__c;
                            apexSharing.add(evaluation, dealerProvisionWrapper.userProvision.User__c, accessLevel, Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c );
                        }
                        if(existingEvaluationSharesByDealerCode.containsKey(dealerProvisionWrapper.userProvision.User__c)) {
                            existingEvaluationSharesByDealerCode.get(dealerProvisionWrapper.userProvision.User__c).remove(dealerWrapper.dealerCode);
                        }
                    }
                }
            }
        }
        apexSharing.share();

        for(String existingShareKeyUser:existingEvaluationSharesByDealerCode.keySet()) {
            for(String existingShareKeyDealer:existingEvaluationSharesByDealerCode.get(existingShareKeyUser).keySet()) {
                for(Evaluation__Share evaluationShare:existingEvaluationSharesByDealerCode.get(existingShareKeyUser).get(existingShareKeyDealer)) {
                    Evaluation__c evaluation = evaluationDealerMap.get(existingShareKeyDealer).get(evaluationShare.ParentId);
                    apexSharing.remove(evaluation, existingShareKeyUser, evaluationShare.AccessLevel, Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c);
                }
            }
        }
        apexSharing.unshare();
    }*/

    /**
    * @description 
    */
    /*private static Map<String, Map<Id, Evaluation__c>> getEvaluationMapFromDealerCodes(Set<String> dealerCodes) {

        Map<String, Map<Id, Evaluation__c>>  evaluationMapByDealerCodes = new Map<String, Map<Id, Evaluation__c>> ();

        for(Evaluation__c evaluation:[select Id, Account__r.DealerCode__c, OwnerId from Evaluation__c where Account__r.DealerCode__c in :dealerCodes and Status__c != :EVALUATION_COMPLETED_STATUS]) {
            if(!evaluationMapByDealerCodes.containsKey(evaluation.Account__r.DealerCode__c)) {
                evaluationMapByDealerCodes.put(evaluation.Account__r.DealerCode__c, new Map<Id, Evaluation__c>());
            }
            evaluationMapByDealerCodes.get(evaluation.Account__r.DealerCode__c).put(evaluation.Id, evaluation);
        }   

        return evaluationMapByDealerCodes;
    }*/


    /**
    * @description 
    */
    private static Map<String, Map<String, AccountShare>> getMapOfExistingAccountSharesForUserByDealerCode(Set<String> userIds) {
        Map<String, Map<String, AccountShare>> existingShareMapForAllAccountShares = new Map<String, Map<String, AccountShare>>();

        System.debug(LoggingLevel.ERROR, userIds);
        List<AccountShare> accountShares = [select Id, Account.DealerCode__c, UserOrGroupId, AccountAccessLevel from AccountShare where UserOrGroupId in :userIds];

        for(AccountShare accountShare:accountShares) {
            if(!existingShareMapForAllAccountShares.containsKey(accountShare.UserOrGroupId)) {
                existingShareMapForAllAccountShares.put(accountShare.UserOrGroupId, new Map<String, AccountShare>());
            }
            existingShareMapForAllAccountShares.get(accountShare.UserOrGroupId).put(accountShare.Account.DealerCode__c, accountShare);
        }

        System.debug(LoggingLevel.ERROR, existingShareMapForAllAccountShares);
        return existingShareMapForAllAccountShares;
    }

    /**
    * @description 
    */    
    /*private static Map<String, Map<String, List<Action_Plan__Share>>> getMapOfExistingActionPlanSharesForUserByDealerCode(Set<String> userIds) {
        Map<String, Map<String, List<Action_Plan__Share>>> existingShareMapForAllActionPlanShares = new Map<String, Map<String, List<Action_Plan__Share>>>();

        System.debug(LoggingLevel.ERROR, userIds);
        List<Action_Plan__Share> actionPlanShares = [select Id, Parent.Account__r.DealerCode__c, UserOrGroupId, AccessLevel from Action_Plan__Share where UserOrGroupId in :userIds and (Parent.Status__c = :ACTION_PLAN_DRAFT_STATUS or Parent.Status__c = :ACTION_PLAN_IN_PROGRESS_STATUS)];

        for(Action_Plan__Share actionPlanShare:actionPlanShares) {
            if(!existingShareMapForAllActionPlanShares.containsKey(actionPlanShare.UserOrGroupId)) {
                existingShareMapForAllActionPlanShares.put(actionPlanShare.UserOrGroupId, new Map<String, List<Action_Plan__Share>>());
            }

            if(!existingShareMapForAllActionPlanShares.get(actionPlanShare.UserOrGroupId).containsKey(actionPlanShare.Parent.Account__r.DealerCode__c)) {
                existingShareMapForAllActionPlanShares.get(actionPlanShare.UserOrGroupId).put(actionPlanShare.Parent.Account__r.DealerCode__c, new List<Action_Plan__Share>());
            }
            existingShareMapForAllActionPlanShares.get(actionPlanShare.UserOrGroupId).get(actionPlanShare.Parent.Account__r.DealerCode__c).add(actionPlanShare);
        }

        System.debug(LoggingLevel.ERROR, existingShareMapForAllActionPlanShares);
        return existingShareMapForAllActionPlanShares;
    }*/


    /**
    * @description 
    */    
    /*private static Map<String, Map<String, List<Evaluation__Share>>> getMapOfExistingEvaluationSharesForUserByDealerCode(Set<String> userIds) {
        Map<String, Map<String, List<Evaluation__Share>>> existingShareMapForAllEvaluationShares = new Map<String, Map<String, List<Evaluation__Share>>>();

        System.debug(LoggingLevel.ERROR, userIds);
        List<Evaluation__Share> evaluationShares = [select Id, Parent.Account__r.DealerCode__c, UserOrGroupId, AccessLevel from Evaluation__Share where UserOrGroupId in :userIds and Parent.Status__c != :EVALUATION_COMPLETED_STATUS ];

        for(Evaluation__Share evaluationShare:evaluationShares) {
            if(!existingShareMapForAllEvaluationShares.containsKey(evaluationShare.UserOrGroupId)) {
                existingShareMapForAllEvaluationShares.put(evaluationShare.UserOrGroupId, new Map<String, List<Evaluation__Share>>());
            }
            if(!existingShareMapForAllEvaluationShares.get(evaluationShare.UserOrGroupId).containsKey(evaluationShare.Parent.Account__r.DealerCode__c)) {
                existingShareMapForAllEvaluationShares.get(evaluationShare.UserOrGroupId).put(evaluationShare.Parent.Account__r.DealerCode__c, new List<Evaluation__Share>());
            }
            existingShareMapForAllEvaluationShares.get(evaluationShare.UserOrGroupId).get(evaluationShare.Parent.Account__r.DealerCode__c).add(evaluationShare);
        }

        System.debug(LoggingLevel.ERROR, existingShareMapForAllEvaluationShares);
        return existingShareMapForAllEvaluationShares;
    }*/

    /**
    * @description 
    */
    private static Map<String, ObjectAccess__mdt> getObjectAccessMap(Set<String> objectAccessDeveloperNames) {
		
        System.debug(LoggingLevel.ERROR, objectAccessDeveloperNames);

        Map<String, ObjectAccess__mdt> objectAccessMap = new Map<String, ObjectAccess__mdt>();
        for(ObjectAccess__mdt objectAccess:[select Id, AccessLevel__c, ObjectAPINames__c, DeveloperName, ObjectAPIName__c from ObjectAccess__mdt where Active__c = true and DeveloperName in :objectAccessDeveloperNames]) {
            objectAccessMap.put(objectAccess.DeveloperName, objectAccess);
        }

        System.debug(LoggingLevel.ERROR, objectAccessMap);

        return objectAccessMap;
    }
 
    /**
    * @description 
    */
    private static Map<String, Account> getAccountMapFromDealerCodes(Set<String> dealerCodes) {

        Map<String, Account> accountMapByDealerCodes = new Map<String, Account>();

        for(Account account:[select Id, DealerCode__c, OwnerId from Account where DealerCode__c in :dealerCodes]) {
            accountMapByDealerCodes.put(account.DealerCode__c, account);
        }   

        return accountMapByDealerCodes;
    }

    /**
     * [Method Description] Check if the external user has 
     * Created by [MinheeKim] on [01.17.25] for [DPM-6005] Created
    */
    private static Map<Id, List<String>> getTempAccess(Map<Id, List<String>> mapUserProvisionAccessTypes){
        Map<Id, List<String>> userTempAccesstype = new Map<Id, List<String>>();
        Map<Id, Id> conUserMap = new Map<Id, Id>();
        List<User> userList = [SELECT Id, ContactId FROM User WHERE Id IN :mapUserProvisionAccessTypes.keySet()];
        for(User usr : userList){
           if(usr.ContactId!=null) conUserMap.put(usr.ContactId,usr.Id);
        }

        Map<Id, List<String>> contactDNAMSMap = new Map<Id, List<String>>();
        if(conUserMap.size()>0){
            for(AccountContactRelation acr : [SELECT ContactId, DNAMSAccountUser__c, Account.Name, Account.Temporary_Dealer__c, Account.BrandCode__c
                                                FROM AccountContactRelation 
                                                WHERE ContactId IN :conUserMap.keySet() 
                                                AND IsActive = true]) {
                    if(acr.Account.Temporary_Dealer__c && acr.DNAMSAccountUser__c) {
                        if(contactDNAMSMap.containsKey(acr.ContactId)) {
                            List<String> accessList = contactDNAMSMap.get(acr.ContactId);
                            if(acr.Account.BrandCode__c=='H'){
                                accessList.add('DNA_HyundaiExt');
                            }else if(acr.Account.BrandCode__c=='G'){
                                accessList.add('DNA_GenesisExt');
                            }
                            contactDNAMSMap.put(acr.ContactId,accessList);
                        }else{
                            List<String> accessList = new List<String>();
                            if(acr.Account.BrandCode__c=='H'){
                                accessList.add('DNA_HyundaiExt');
                            }else if(acr.Account.BrandCode__c=='G'){
                                accessList.add('DNA_GenesisExt');
                            }
                            contactDNAMSMap.put(acr.ContactId,accessList);
                        }
                        
                    }
            }
        }

        if(contactDNAMSMap.size()>0){
            for(Id conId : contactDNAMSMap.keySet()){
                userTempAccesstype.put(conUserMap.get(conId), contactDNAMSMap.get(conId));
            }
        }
        System.debug('6005 userTempAccesstype : '+userTempAccesstype);
        return userTempAccesstype;
        
    }

    /**
     * [Method Description] Get apptypes of the accesstype user has
     * Created by [MinheeKim] on [02-18-2025] for [DPM-6086]
    */
    private static Map<Id, Set<String>> populateApptypes(Map<Id, List<String>> mapUserProvisionAccessTypes){
        Map<Id, Set<String>> mapUserAppTypes = new Map<Id, Set<String>>();
        
        if(mapUserProvisionAccessTypes==null || mapUserProvisionAccessTypes.size()<=0){
            return mapUserAppTypes;
        }

        for(Id user : mapUserProvisionAccessTypes.keySet()){
            Set<String> appTypes = new Set<String>();
            for(String accesstype : mapUserProvisionAccessTypes.get(user)){
                if(accesstype.contains('DPM')){
                    appTypes.add('DPM');
                }else if(accesstype.contains('DNA')){
                    appTypes.add('DNA');
                }else if(accesstype.contains('CUV')){
                    appTypes.add('CUV');
                }
            }

            mapUserAppTypes.put(user, appTypes);
        }

        return mapUserAppTypes;
    }

}