public without sharing class DNAMSHelpController {
   
    
    //Internal user extract
    @AuraEnabled
    public static List<DNAM_Links__mdt> getDNAMLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'How to Assign Dealer Permission' and User_Type__c in ('HMA Dealer','Internal User') ORDER BY Sort_Order__c ASC];
    }
    @AuraEnabled
    public static List<DNAM_Links__mdt> getIntHMAPermissionLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'How to Assign Dealer Permission' and User_Type__c in ('Internal User') ORDER BY Sort_Order__c ASC];
    }
    @AuraEnabled
    public static List<DNAM_Links__mdt> getIntHMAGuideLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'DNAMS Guides' and User_Type__c in ('HMA Dealer','Internal User') ORDER BY Sort_Order__c ASC];
    }
    @AuraEnabled
    public static List<DNAM_Links__mdt> getIntGMAPermissionLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'How to Assign Dealer Permission' and User_Type__c in ('GMA Dealer','Internal User') ORDER BY Sort_Order__c ASC];
    }
    @AuraEnabled
    public static List<DNAM_Links__mdt> getIntGMAGuideLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'DNAMS Guides' and User_Type__c in ('GMA Dealer','Internal User') ORDER BY Sort_Order__c ASC];
    }
    //Dealer extract
    @AuraEnabled
    public static List<DNAM_Links__mdt> getDealerHMAPermissionLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'How to Assign Dealer Permission' and User_Type__c in ('HMA Dealer') ORDER BY Sort_Order__c ASC];
    }
    @AuraEnabled
    public static List<DNAM_Links__mdt> getDealerHMAGuideLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'DNAMS Guides' and User_Type__c in ('HMA Dealer') ORDER BY Sort_Order__c ASC];
    }
    @AuraEnabled
    public static List<DNAM_Links__mdt> getDealerGMAPermissionLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'How to Assign Dealer Permission' and User_Type__c in ('GMA Dealer') ORDER BY Sort_Order__c ASC];
    }
    @AuraEnabled
    public static List<DNAM_Links__mdt> getDealerGMAGuideLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'DNAMS Guides' and User_Type__c in ('GMA Dealer') ORDER BY Sort_Order__c ASC];
    }
    //DNA-993-Start
    @AuraEnabled
    public static List<DNAM_Links__mdt> getIntHMAGuidesPermissionLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'DNAMS Internal Guides' and User_Type__c in ('Internal User') ORDER BY Sort_Order__c ASC];
    }
    @AuraEnabled
    public static List<DNAM_Links__mdt> getIntGMAGuidesPermissionLinks() {
        return [SELECT DNAMS_Header__c,Sort_Order__c, Text_to_Display__c, URL__c,User_Type__c  FROM DNAM_Links__mdt where DNAMS_Header__c = 'DNAMS Internal Guides' and User_Type__c in ('Internal User') ORDER BY Sort_Order__c ASC];
    }
    //DNA-99-End
}