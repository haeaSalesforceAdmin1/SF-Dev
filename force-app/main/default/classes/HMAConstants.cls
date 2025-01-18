/**
* @description 
*/
public with sharing class HMAConstants {

    public static final String METADATA_PERMISSIONSET_FIELD = 'PermissionSetAPINames__c';  
    public static final String METADATA_PUBLIC_GROUP_FIELD = 'PublicGroupAPINames__c';  
    public static final String METADATA_PERMISSIONSET_GROUP_FIELD = 'PermissionSetGroupAPINames__c';  
    public static final String METADATA_ROLE_FIELD = 'RoleAPIName__c';
    public static final String METADATA_PROFILE_FIELD = 'ProfileAPIName__c';   
    public static final String HYUNDAI_RECORD_TYPE = 'HyundaiDealer'; 

    //DPM-4035 Added to use in HMAUtility by MinheeKim - 2024.06.11 
    public static String HMA_COMMUNITY_NAME = System.label.HMA_Community_Name;
    public static String GMA_COMMUNITY_NAME = System.label.GMA_Community_Name;
    public static String communityProfile = System.label.HCUV_Community_Profile;
    public static String internalProfile = System.label.HCUV_Internal_Profile;
}