/**
************************************************************************************************
* @classname         : HCUV_Constants; being used for constant
* @description       : Constant Class
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       18th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
* 2.0       26th Oct 2023          Smriti Gupta/Chaitanya Story HVM-389     Included RDR
************************************************************************************************
**/
public class HCUV_Constants {
    public static String POST = 'POST';
    public static String PATCH = 'PATCH';
    public static String GET = 'GET';
    public static String AUTHORIZATION ='Authorization';
    public static String BEARER = 'Bearer ';
    public static String BASIC = 'Basic ';
    public static String Message_QuickTip='Quick Tip';
    public static String Status_Published='Published';
    
    /*
    public static String Inventory_Prefix = 'a3E';
    public static String Reference_Material_Prefix = 'a3G';
    public static String Contests_Incentives_Prefix = 'a3Q';
    public static String Message_Prefix = 'a3D';*/
    public static String ContentDocument_Visibility_AllUsers ='AllUsers';
    public static String Status_Expired ='Expired';

    public static String Contests_Incentives_API_Name ='HCUV_Contests_Incentives__c';
    public static String Dealer_Message_API_Name ='HCUV_Dealer_Message__c';
    public static String Inventory_CarFax_Invalid_Msg=System.label.HCUV_CarFax_Report_Error_Msg;
    public static String Inventory_CarFax_Invalid_Status=System.label.HCUV_Invalid_Carfax_Inv_Status;
    public static String WindowSticker_WebDcsURL = System.label.WindowSticker_WebDcsURL; 
    public static String Inventory_WindowSticker_Invalid_Status=System.label.HCUV_Invalid_WindowStr_Inv_Status;
    public static set<String> InventoryStatus_CARFax = new Set<String>{'C0','C1','C93'};
    public static set<String> InventoryStatus_WindowSticker = new Set<String>{'C0','C1'};
        
    public static Integer DEFAULT_TTL = 28800;
    public static String CONST_PARTITIONKEY = 'local.CUVSession';
    public static String HMA_COMMUNITY_NAME = system.label.HCUV_HMACPO;
    public static String GMA_COMMUNITY_NAME = system.label.HCUV_GMACPO;
    public static String communityProfile = system.label.HCUV_Community_Profile;
    public static String internalProfile = system.label.HCUV_Internal_Profile;
    
    public static String HMA_Account_RecType = 'HyundaiDealer';
    public static String GMA_Account_RecType = 'GenesisRetailer';
    
    public static String CI_Object_API_Name ='HCUV_Contests_Incentives__c';
    public static String DM_Object_API_Name ='HCUV_Dealer_Message__c';
    public static String QL_Object_API_Name ='HCUV_Quick_Link__c';
    public static String RM_Object_API_Name ='HCUV_Reference_Material__c';
    public static String Carosuel_Object_API_Name ='HCUV_Carousel__c';
    
    public static String RM_Type ='Reference Material';
    public static String OM_Type ='Order Merchandise';
    
    public static String INVENTORY_OBJECT_API_NAME = 'HCUV_Inventory__c';
    public static String SERVICES_URL = '/services/data/v37.0/sobjects/';
    public static String LIST_VIEWS = '/listviews/';
    public static String DESCRIBE = '/describe';
    public static Integer STATUS_CODE_SUCCESS = 200;
    
    public static String Dashboard_Text = 'Dashboard';
    public static String ExternalId_Text = '_External_ID__c';
    public static String HMACommunityType = 'HMA';
    public static String GMACommunityType = 'GMA';
    public static String HMADefaultInspectionType = 'CUV';
    public static String GMADefaultInspectionType = 'CPO';
    
    public static String SalesRecTypeRDR = 'RDR';
    public static String ReportVehSaleLeftMenuItem = 'REPORT VEHICLE SALE';
}