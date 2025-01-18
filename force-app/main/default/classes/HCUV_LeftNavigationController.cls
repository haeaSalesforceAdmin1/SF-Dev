Public with sharing class HCUV_LeftNavigationController {
    
    public static Map<String,sobject> GetMenus(){
        Map<String,sobject> subdata = new Map<String,sobject>();
        string developername;
        List<HCUV_Navigation__mdt> navigation = [Select id,DeveloperName,HasSubMenu__c,Image__c,Options__c,Order__c,(Select id,developername,Icon__c,Navigation__c from SubMenus__r) from HCUV_Navigation__mdt Order By Order__c ASC];
        for(HCUV_Navigation__mdt nav:navigation) {
            developername = nav.DeveloperName;
            for(HCUV_SubMenu__mdt menu : nav.SubMenus__r) {
                subdata.put(developername,menu);
            }
        }
        return subdata;
    }
    
    @AuraEnabled
    public static List<Navigation> GetMenu(String networkId) {  
        //get community name
        String communityName = HCUV_Utility.getCommunityName(networkId);
        
        List<Navigation> navItems = new List<Navigation>();
        
        // get Menus
        for (HCUV_Navigation__mdt item : getMenuList(communityName, 'Left')) {
            Navigation navItem = new Navigation();
            navItem.menuName = item.MasterLabel;
            navItem.image = item.Image__c;
            navItem.hasSubMenu = item.HasSubMenu__c;
            navItem.url = item.Navigation_URL__c;
            navItem.programType= item.Program_Type__c;
            
            if(item.HasSubMenu__c){
                List<SubMenu> subMenusLst = new List<SubMenu>();
                
                // get Sub-Menus
                for (HCUV_SubMenu__mdt subItem : getSubMenuList(communityName, item.Id)) {
                    SubMenu subMenu = new SubMenu();
                    subMenu.subMenuName = subItem.MasterLabel;
                    subMenu.subMenuImage = subItem.Icon__c;
                    subMenu.subMenuProgramType = subItem.Program_Type__c;
                    subMenusLst.add(subMenu);
                }
                navItem.subMenus = subMenusLst;
            }
            navItems.add(navItem);
        }
        return navItems;
    }
    
    private static List<HCUV_Navigation__mdt> getMenuList(String communityName, String menuType){
        return [Select Id, Program_Type__c, MasterLabel, Image__c, Options__c, Order__c,HasSubMenu__c, Navigation_URL__c
                from HCUV_Navigation__mdt 
                where Site_Name__c = :communityName AND Type__c = :menuType
                Order By Order__c ASC];
    }
    
    private static List<HCUV_SubMenu__mdt> getSubMenuList(String communityName, String menuId){
        return [Select Id, Program_Type__c, MasterLabel, Icon__c, Order_Number__c
                from HCUV_SubMenu__mdt 
                where Site_Name__c = :communityName AND Navigation__c = :menuId
                Order By Order_Number__c ASC];
    }
    
    public class Navigation{
        @AuraEnabled  Public String menuName;
        @AuraEnabled  public String image;
        @AuraEnabled  public Boolean hasSubMenu;
        @AuraEnabled  public List<SubMenu> subMenus;
        @AuraEnabled  public String url;
        @AuraEnabled  public String programType;
    }
    
    public class SubMenu {
        @AuraEnabled public String subMenuName;
        @AuraEnabled public String subMenuImage;
        @AuraEnabled  public String subMenuProgramType;
    }
    
}