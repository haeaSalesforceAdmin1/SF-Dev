// Test Class: HCUV_InventoryDataController_Test
public with sharing class HCUV_InventoryDataCtrl {

    private static String query;
    private static Map<String, Object> fieldMap = new Map<String, Object> ();
    
    @AuraEnabled(cacheable=true)    
    public static Map<String, Object> getInventories(String searchTerm, String programType, String networkId) {
        //get community name
        String communityName = HCUV_Utility.getCommunityName(networkId);

        Map<String, String> listViewMap = getListViews();
        String listViewName = listViewMap.get(searchTerm) + '_' + programType;
        
        List<ListView> lvObjList = [SELECT Id, Name, DeveloperName, SobjectType FROM ListView 
                                    where SobjectType = :HCUV_Constants.INVENTORY_OBJECT_API_NAME AND DeveloperName = :listViewName];
		        
        Map<String, Object> dataMap = new Map<String, Object> ();
        dataMap.put('SubMenus', getSubMenus(communityName));
        
        if(lvObjList.isEmpty()) {
            return dataMap;
        }
        
        // fetch List_View details
        getListViewDetails(HCUV_Constants.INVENTORY_OBJECT_API_NAME, lvObjList[0].Id);
        
        dataMap.put('Inventories', new List<HCUV_Inventory__c> ());
        dataMap.put('FieldMap', fieldMap);
        
        if(String.isBlank(query)) {
            return dataMap;
        }
            
        // added Inventory_Status__c field if not added
        if(!query.split('FROM')[0].containsIgnoreCase('Inventory_Status__c')) {
            query = query.replace('FROM', ', Inventory_Status__c FROM');
        }
        System.debug('query = ' + query);
        
        String accId = HCUV_Utility.getAccountId();
        
        if(String.isNotBlank(accId)) {
            if(query.containsIgnoreCase('WHERE')) {
                query = query.replace('WHERE', 'WHERE Dealer__c = :accId AND ');
            } else {
                query = query.replace(HCUV_Constants.INVENTORY_OBJECT_API_NAME, 'HCUV_Inventory__c WHERE Dealer__c = :accId ');
            }
        }
        System.debug ('AccountId : ' + accId);
        System.debug ('Final Query: ' + query);
        dataMap.put('Inventories', Database.query(query + ' LIMIT 10000'));
        
        return dataMap;
    }

    public static void getListViewDetails(String objectName, String filterId) {
        HttpRequest req = new HttpRequest();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String endPoinURL = baseUrl + HCUV_Constants.SERVICES_URL + objectName + HCUV_Constants.LIST_VIEWS + filterId + HCUV_Constants.DESCRIBE;
        req.setEndpoint(endPoinURL);
        req.setMethod(HCUV_Constants.GET);
        req.setHeader(HCUV_Constants.AUTHORIZATION, HCUV_Constants.BEARER + UserInfo.getSessionId());
        Http http = new Http();
        HttpResponse response = http.send(req);
         
        if(response.getStatusCode() == HCUV_Constants.STATUS_CODE_SUCCESS) {
            //System.debug('response.getBody() = ' + response.getBody());
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            query = (String)tokenResponse.get('query');
            
            Map<String, Object> colDetails;
            
            for(Object col : (List<Object>)tokenResponse.get('columns')) {
                colDetails = (Map<String, Object>)col;
                if((Boolean)colDetails.get('hidden') == false) {
                    fieldMap.put((String)colDetails.get('label'), (String)colDetails.get('fieldNameOrPath'));
                }
            }
        }
    }
    
    public static Map<String, String> getListViews() {
        List<HCUV_Navigation__mdt> navigations = HCUV_Navigation__mdt.getAll().values();
        List<HCUV_SubMenu__mdt> subMenus = HCUV_SubMenu__mdt.getAll().values();
        
        Map<String, String> listViewMap = new Map<String, String> ();
        
        for(HCUV_Navigation__mdt navigation : navigations) {
            if(String.isNotBlank(navigation.List_View_Name__c)) {
                listViewMap.put(navigation.MasterLabel, navigation.List_View_Name__c);
            }
        }
        
        for(HCUV_SubMenu__mdt subMenu : subMenus) {
            if(String.isNotBlank(subMenu.List_View_Name__c)) {
             	listViewMap.put(subMenu.MasterLabel, subMenu.List_View_Name__c);   
            }
        }
        
        return listViewMap;
    }
    
    public static Map<String, String> getSubMenus(String communityName) {
        List<HCUV_Navigation__mdt> navigations = HCUV_Navigation__mdt.getAll().values();
        List<HCUV_SubMenu__mdt> subMenus = HCUV_SubMenu__mdt.getAll().values();
        
        Map<String, String> subMenuMap = new Map<String, String> ();
        
        for(HCUV_Navigation__mdt navigation : navigations) {
            if(navigation.Site_Name__c == communityName && String.isNotBlank(navigation.Description__c)) {
                subMenuMap.put(navigation.MasterLabel, navigation.Description__c);
            }
        }
        
        for(HCUV_SubMenu__mdt subMenu : subMenus) {
            if(subMenu.Site_Name__c == communityName) {
                subMenuMap.put(subMenu.MasterLabel, subMenu.Description__c);
            }
        }
        
        return subMenuMap;
    }
}