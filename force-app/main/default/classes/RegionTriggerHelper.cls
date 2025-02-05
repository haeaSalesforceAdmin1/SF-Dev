/**
************************************************************************************************
* @classname         : RegionTriggerHelper
* @description       : DPM-133 // Automate Change of Regional Manager On Region
* @author            : JongHoon Kim
* History
* Version      Date                Author               Ticket         Modification
* 1.0       2024-09-25           JongHoon Kim           DPM-133       Initial Version
************************************************************************************************
**/
public with sharing class RegionTriggerHelper {
    /**
     * Description: [Automate Change of Regional Manager On Region] 
     * Created by [Jonghoon Kim] on [11-13-2024] for [Ticket DPM-133]
    */
    public static void searchUserManagerUpdate(List<Region__c> newList, Map<Id, Region__c> oldMap) {
        Set<String> empNumSet = new Set<String>();
        for (Region__c region : newList) {
            try {
                if (region.GAFOMEmpNum__c  != oldMap.get(region.Id).GAFOMEmpNum__c  && region.GAFOMEmpNum__c  != null) {
                    empNumSet.add(region.GAFOMEmpNum__c );
                }
                if (region.GSFOMEmpNum__c != oldMap.get(region.Id).GSFOMEmpNum__c && region.GSFOMEmpNum__c != null) {
                    empNumSet.add(region.GSFOMEmpNum__c);
                }
            } catch (Exception e) {
                System.debug('Error processing region ' + region.Id + ': ' + e.getMessage());
            }
        }

        Map<String, User> empNumToUserMap = new Map<String, User>();
        if (!empNumSet.isEmpty()) {
            try {
                for (User user : [SELECT Id, EmployeeNumber FROM User WHERE EmployeeNumber IN :empNumSet AND IsActive = true]) {
                    empNumToUserMap.put(user.EmployeeNumber, user);
                }
            } catch (Exception e) {
                System.debug('Unexpected error when querying User: ' + e.getMessage());
            }
        }


        for (Region__c region : newList) {
            try {
                if(region.GAFOMEmpNum__c  != oldMap.get(region.Id).GAFOMEmpNum__c ) {
                    if (region.GAFOMEmpNum__c  != null) {
                        User user = empNumToUserMap.get(region.GAFOMEmpNum__c );
                        if(user != null) {
                            region.Aftersales_Field_Operations_Manager__c = user.Id;
                        }
                        // region.Aftersales_Field_Operations_Manager__c = (user != null) ?  = user.Id : null;
                    } 
                }
                

                if(region.GSFOMEmpNum__c != oldMap.get(region.Id).GSFOMEmpNum__c) {
                    if (region.GSFOMEmpNum__c != null) {
                        User user = empNumToUserMap.get(region.GSFOMEmpNum__c);
                        if(user != null) {
                            region.Operations_Manager__c = user.Id;
                        }
                        // region.Operations_Manager__c = (user != null) ? user.Id : null;
                    } 
                    // else {
                    //     region.Operations_Manager__c = null;
                    // }
                }
            } catch (Exception e) {
                System.debug('Error processing region ' + region.Id + ': ' + e.getMessage());
            }
              
        }
    }
    
}