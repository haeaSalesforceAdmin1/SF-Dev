/**
************************************************************************************************
* @classname         : UpdateRelatedDMOnDistrictChangeQueueable
* @description       : DPM-133 // Automate Change of District Manager On District
* @author            : JongHoon Kim
* History
* Version      Date                Author               Ticket         Modification
* 1.0       2025-01-22           JongHoon Kim           DPM-133       Initial Version
************************************************************************************************
**/

public with sharing class UpdateRelatedDMOnDistrictChangeQueueable implements Queueable, Database.AllowsCallouts{
    private List<District__c> newList;
    private Map<Id, District__c> oldMap;

    public UpdateRelatedDMOnDistrictChangeQueueable(List<District__c> newList, Map<Id, District__c> oldMap) {
        this.newList = newList;
        this.oldMap = oldMap;
    }

    public void execute(QueueableContext context) {
        Set<Id> districtAccIds = new Set<Id>();
        Set<String> districtAccSalesCodes = new Set<String>();
        Set<String> districtAccServiceCodes = new Set<String>();
        Set<String> districtAccMarketCodes = new Set<String>();
        Map<String, District__c> codeToDistrictMap = new Map<String, District__c>();
        Set<Id> organizationIds = new Set<Id>();
        Map<Id, String> organizationNames = new Map<Id, String>();
        Date today = Date.today(); // DPM-6033

        for (District__c District : newList) {
            codeToDistrictMap.put(District.DistrictCode__c, District);
            organizationIds.add(district.Organization__c);
        }

        
        for (Organization__c org : [SELECT Id, Name FROM Organization__c WHERE Id IN :organizationIds]) {
            organizationNames.put(org.Id, org.Name);
        }

        for (District__c district : newList) {
            District__c olddistrict = oldMap.get(district.Id);
            if (district.SalesManager__c != olddistrict.SalesManager__c) {

                districtAccIds.add(district.Id);
                districtAccSalesCodes.add(district.DistrictCode__c);
            }

            if( district.DistrictPartsServiceManager__c != olddistrict.DistrictPartsServiceManager__c) {

                districtAccIds.add(district.Id);
                districtAccServiceCodes.add(district.DistrictCode__c);
            }

            if(district.MarketManager__c != olddistrict.MarketManager__c || district.Aftersales_Market_Manager__c != olddistrict.Aftersales_Market_Manager__c) {
                districtAccIds.add(district.Id);
                districtAccMarketCodes.add(district.DistrictCode__c);
            }
        }

        // Update Account Start
        Set<Id> accountIdsToUpdate = new Set<Id>();
        List<Account> accountToUpdate = new List<Account>();

        if (!districtAccSalesCodes.isEmpty()) {
            List<Account> accList = [
                SELECT Id, SalesDistrictCode__c, BrandCode__c, DistrictSalesManager__c
                FROM Account 
                WHERE SalesDistrictCode__c IN :districtAccSalesCodes 
                ORDER BY Createddate desc
            ];

            for (Account acc : accList) {
                District__c district = codeToDistrictMap.get(acc.SalesDistrictCode__c);
                if (district != null && acc.DistrictSalesManager__c != district.SalesManager__c) {
                    if (!accountIdsToUpdate.contains(acc.Id)) {
                        acc.DistrictSalesManager__c = district.SalesManager__c;
                        accountToUpdate.add(acc);
                        accountIdsToUpdate.add(acc.Id);
                    } else {
                        acc.DistrictSalesManager__c = district.SalesManager__c;
                    }
                }
            }
        }

        if (!districtAccServiceCodes.isEmpty()) {
            List<Account> accList = [
                SELECT Id, ServiceDistrictCodePicklist__c, BrandCode__c, DistrictPartsServiceManager__c 
                FROM Account 
                WHERE ServiceDistrictCodePicklist__c IN :districtAccServiceCodes 
                ORDER BY Createddate desc
            ];

            for (Account acc : accList) {
                District__c district = codeToDistrictMap.get(acc.ServiceDistrictCodePicklist__c);
                if (district != null && acc.DistrictPartsServiceManager__c != district.DistrictPartsServiceManager__c) {
                    if (!accountIdsToUpdate.contains(acc.Id)) {
                        acc.DistrictPartsServiceManager__c = district.DistrictPartsServiceManager__c;
                        accountToUpdate.add(acc);
                        accountIdsToUpdate.add(acc.Id);
                    } else {
                        acc.DistrictPartsServiceManager__c = district.DistrictPartsServiceManager__c;
                    }
                }
            }
        }

        if (!districtAccMarketCodes.isEmpty()) {
            List<Account> accList = [
                SELECT Id, MarketCodeGenesisPicklist__c, BrandCode__c, MarketManager__c, Aftersales_Market_Manager__c 
                FROM Account 
                WHERE MarketCodeGenesisPicklist__c IN :districtAccMarketCodes 
                ORDER BY Createddate desc
            ];


            for (Account acc : accList) {
                District__c district = codeToDistrictMap.get(acc.MarketCodeGenesisPicklist__c);
                
                if (district != null && acc.Aftersales_Market_Manager__c != district.Aftersales_Market_Manager__c) {
                    if (!accountIdsToUpdate.contains(acc.Id)) {
                        acc.Aftersales_Market_Manager__c = district.Aftersales_Market_Manager__c;
                        accountToUpdate.add(acc);
                        accountIdsToUpdate.add(acc.Id);
                    } else {
                        acc.Aftersales_Market_Manager__c = district.Aftersales_Market_Manager__c;
                    }
                }

                if (district != null && acc.MarketManager__c != district.MarketManager__c) {
                    if (!accountIdsToUpdate.contains(acc.Id)) {
                        acc.MarketManager__c = district.MarketManager__c;
                        accountToUpdate.add(acc);
                        accountIdsToUpdate.add(acc.Id);
                    } else {
                        acc.MarketManager__c = district.MarketManager__c;
                    }
                }
            }
        }

        System.debug('accountToUpdate =>' + accountToUpdate);

        if (!accountToUpdate.isEmpty()) {
            update accountToUpdate;
        }
        // Update Account End

        // Update Action Plan Start
        Set<Id> districtApIds = new Set<Id>();
        Set<String> districtApSalesCodes = new Set<String>();
        Set<String> districtApServiceCodes = new Set<String>();
        Set<String> districtApMarketCodes = new Set<String>();

        for (District__c district : newList) {
            District__c olddistrict = oldMap.get(district.Id);
            String orgName = organizationNames.get(district.Organization__c);
            
            if(orgName == 'Genesis') {
                if (district.MarketManager__c != olddistrict.MarketManager__c ||
                    district.Aftersales_Market_Manager__c != olddistrict.Aftersales_Market_Manager__c) {
                    districtApIds.add(district.Id);
                    districtApMarketCodes.add(district.DistrictCode__c);
                    System.debug('districtApMarketCodes 1 =>' + districtApMarketCodes);
                }
            } else {
                if (district.SalesManager__c != olddistrict.SalesManager__c) {

                    districtApIds.add(district.Id);
                    districtApSalesCodes.add(district.DistrictCode__c);
                }

                if( district.DistrictPartsServiceManager__c != olddistrict.DistrictPartsServiceManager__c) {

                    districtApIds.add(district.Id);
                    districtApServiceCodes.add(district.DistrictCode__c);
                }
            }
        }
        System.debug('districtApMarketCodes =>' + districtApMarketCodes);
        System.debug('districtApSalesCodes =>' + districtApSalesCodes);
        System.debug('districtApServiceCodes =>' + districtApServiceCodes);

        Set<Id> actionPlansIdsToUpdate = new Set<Id>();
        Set<String> validApprovalStatuses = new Set<String>{
            'Submitted for District Approval',
            'District Approved',
            'Sent Back'
        };
        List<Action_Plan__c> actionPlansToUpdate = new List<Action_Plan__c>();
        // if (!districtApMarketCodes.isEmpty()) {
        //     List<Action_Plan__c> actionPlans = [
        //         SELECT Id, MarketCode__c, BrandCode__c, Division__c, MarketManager__c, Aftersales_Market_Manager__c , GenesisMarketManagerAlt__c, ApprovalStatus__c
        //         FROM Action_Plan__c 
        //         WHERE BrandCode__c = 'G' 
        //         AND ApprovalStatus__c != 'Region Approved'
        //         AND MarketCode__c IN :districtApMarketCodes 
        //         ORDER BY Createddate desc
        //     ];


        //     for (Action_Plan__c actionPlan : actionPlans) {
        //         District__c district = codeToDistrictMap.get(actionPlan.MarketCode__c);
                
        //         if (district != null && (actionPlan.MarketManager__c != district.MarketManager__c || actionPlan.Aftersales_Market_Manager__c != district.Aftersales_Market_Manager__c)) {
        //             if(!actionPlansIdsToUpdate.contains(actionPlan.Id)) {
        //                 if (actionPlan.Division__c == 'Sales') {
        //                     actionPlan.MarketManager__c = district.MarketManager__c;
        //                     actionPlan.GenesisMarketManagerAlt__c = district.MarketManager__c;
        //                     if (validApprovalStatuses.contains(actionPlan.ApprovalStatus__c)) {
        //                         actionPlan.OwnerId = district.MarketManager__c;
        //                     }
        //                 } else if (actionPlan.Division__c == 'Service') {
        //                     actionPlan.Aftersales_Market_Manager__c = district.Aftersales_Market_Manager__c;
        //                     actionPlan.GenesisMarketManagerAlt__c = district.Aftersales_Market_Manager__c;
        //                     if (validApprovalStatuses.contains(actionPlan.ApprovalStatus__c)) {
        //                         actionPlan.OwnerId = district.Aftersales_Market_Manager__c;
        //                     }
        //                 }
        //                 actionPlansIdsToUpdate.add(actionPlan.Id);
        //                 actionPlansToUpdate.add(actionPlan); 
        //             }
        //         }
        //     }
        // }

        if (!districtApSalesCodes.isEmpty()) {
            List<Action_Plan__c> actionPlans = [
                SELECT Id, SalesDistrictCode__c, BrandCode__c, Division__c, DistrictSalesManager__c, ApprovalStatus__c
                FROM Action_Plan__c 
                WHERE BrandCode__c = 'H' 
                // AND ApprovalStatus__c != 'Region Approved' // DPM-6033
                AND EndDate__c >= :today
                AND SalesDistrictCode__c IN :districtApSalesCodes 
                ORDER BY Createddate desc
            ];

            for (Action_Plan__c actionPlan : actionPlans) {
                District__c district = codeToDistrictMap.get(actionPlan.SalesDistrictCode__c);
                
                if (district != null  && actionPlan.DistrictSalesManager__c != district.SalesManager__c) {
                        if(!actionPlansIdsToUpdate.contains(actionPlan.Id)) {
                            actionPlan.DistrictSalesManager__c = district.SalesManager__c;
                            actionPlansToUpdate.add(actionPlan);
                            actionPlansIdsToUpdate.add(actionPlan.Id);
                        } else {
                            actionPlan.DistrictSalesManager__c = district.SalesManager__c;
                            actionPlansToUpdate.add(actionPlan);
                        }
                        if (validApprovalStatuses.contains(actionPlan.ApprovalStatus__c) && actionPlan.Division__c == 'Sales') {
                            actionPlan.OwnerId = district.SalesManager__c;
                        }
                    
                }
            }
        }

         if (!districtApServiceCodes.isEmpty()) {
            List<Action_Plan__c> actionPlans = [
                SELECT Id, ServiceDistrictCode__c, BrandCode__c, Division__c, DistrictPartsServiceManager__c, ApprovalStatus__c
                FROM Action_Plan__c 
                WHERE BrandCode__c = 'H' 
                // AND ApprovalStatus__c != 'Region Approved' // DPM-6033
                AND EndDate__c >= :today
                AND ServiceDistrictCode__c IN :districtApServiceCodes 
                ORDER BY Createddate desc
            ];

            for (Action_Plan__c actionPlan : actionPlans) {
                District__c district = codeToDistrictMap.get(actionPlan.ServiceDistrictCode__c);
                
                if (district != null && actionPlan.DistrictPartsServiceManager__c != district.DistrictPartsServiceManager__c) {
                        if(!actionPlansIdsToUpdate.contains(actionPlan.Id)) {
                            actionPlan.DistrictPartsServiceManager__c = district.DistrictPartsServiceManager__c;
                            actionPlansToUpdate.add(actionPlan);
                            actionPlansIdsToUpdate.add(actionPlan.Id);
                        } else {
                            actionPlan.DistrictPartsServiceManager__c = district.DistrictPartsServiceManager__c;
                            actionPlansToUpdate.add(actionPlan);
                        }

                        if (validApprovalStatuses.contains(actionPlan.ApprovalStatus__c) && actionPlan.Division__c == 'Service') {
                            actionPlan.OwnerId = district.DistrictPartsServiceManager__c;
                        }
                }
            }
        }

        if (!actionPlansToUpdate.isEmpty()) {
            update actionPlansToUpdate;
        }
        // // Update Action Plan End

        // // Update Evaluation Start
        Set<Id> districtEvalIds = new Set<Id>();
        Set<String> districtEvalSalesCodes = new Set<String>();
        Set<String> districtEvalServiceCodes = new Set<String>();
        Set<String> districtEvalMarketCodes = new Set<String>();

        for (District__c district : newList) {
            District__c olddistrict = oldMap.get(district.Id);
            String orgName = organizationNames.get(district.Organization__c);
            
            
            if(orgName == 'Genesis') {
                if (district.MarketManager__c != olddistrict.MarketManager__c ||
                    district.Aftersales_Market_Manager__c != olddistrict.Aftersales_Market_Manager__c) {

                    districtEvalIds.add(district.Id);
                    districtEvalMarketCodes.add(district.DistrictCode__c);
                }
            } else {
                if (district.SalesManager__c != olddistrict.SalesManager__c) {

                    districtEvalIds.add(district.Id);
                    districtEvalSalesCodes.add(district.DistrictCode__c);
                }

                if( district.DistrictPartsServiceManager__c != olddistrict.DistrictPartsServiceManager__c) {

                    districtEvalIds.add(district.Id);
                    districtEvalServiceCodes.add(district.DistrictCode__c);
                }
            }
        }

        Set<Id> evaluationsIdsToUpdate = new Set<Id>();
        List<Evaluation__c> evaluationsToUpdate = new List<Evaluation__c>();
        if (!districtEvalMarketCodes.isEmpty()) {
            List<Evaluation__c> evaluationList = [
                SELECT Id, MarketCode__c, BrandCode__c, Type__c, MarketManager__c, Aftersales_Market_Manager__c , GenesisMarketManagerAlt__c, ApprovalStatus__c, RecordType.DeveloperName, Indicator__c, ScheduledTopic__r.TopicOwner__c 
                FROM Evaluation__c 
                WHERE BrandCode__c = 'G' 
                // DPM-6033 start
                // AND Status__c NOT IN ('Closed','Completed')
                // AND Status__c != null
                // AND ApprovalStatus__c != 'Region Approved'
                AND EndDate__c >= :today
                 // DPM-6033 end
                AND JDP_Evaluation__c = true
                AND Indicator__c !='Retailer Refusal'
                AND MarketCode__c IN :districtEvalMarketCodes 
                ORDER BY Createddate desc
            ];


            for (Evaluation__c eval : evaluationList) {
                District__c district = codeToDistrictMap.get(eval.MarketCode__c);
                
                if (district != null && (eval.MarketManager__c != district.MarketManager__c || eval.Aftersales_Market_Manager__c != district.Aftersales_Market_Manager__c)) {
                    if(!evaluationsIdsToUpdate.contains(eval.Id)) {
                        if (eval.Type__c == 'Sales' || eval.ScheduledTopic__r.TopicOwner__c == 'Market Manager') {
                            eval.MarketManager__c = district.MarketManager__c;
                            eval.GenesisMarketManagerAlt__c = district.MarketManager__c;
                            eval.OwnerId = district.MarketManager__c;
                        } else if (eval.Type__c == 'Service' || eval.ScheduledTopic__r.TopicOwner__c == 'Aftersales Market Manager') {
                            eval.Aftersales_Market_Manager__c = district.Aftersales_Market_Manager__c;
                            eval.GenesisMarketManagerAlt__c = district.Aftersales_Market_Manager__c;
                            eval.OwnerId = district.Aftersales_Market_Manager__c;
                        }
                        evaluationsToUpdate.add(eval);
                        evaluationsIdsToUpdate.add(eval.id);
                    } else {
                        if (eval.Type__c == 'Sales' || eval.ScheduledTopic__r.TopicOwner__c == 'Market Manager') {
                            eval.MarketManager__c = district.MarketManager__c;
                            eval.GenesisMarketManagerAlt__c = district.MarketManager__c;
                        } else if (eval.Type__c == 'Service' || eval.ScheduledTopic__r.TopicOwner__c == 'Aftersales Market Manager') {
                            eval.Aftersales_Market_Manager__c = district.Aftersales_Market_Manager__c;
                            eval.GenesisMarketManagerAlt__c = district.Aftersales_Market_Manager__c;
                        }
                        evaluationsToUpdate.add(eval);
                    }

                    // if(validApprovalStatuses.contains(eval.ApprovalStatus__c) || eval.RecordType.DeveloperName.contains('Genesis_Retailer')) {
                    //     if(eval.Type__c == 'Sales') {
                    //         eval.OwnerId = district.MarketManager__c;
                    //     } else if(eval.Type__c == 'Service') {
                    //         eval.OwnerId = district.Aftersales_Market_Manager__c;
                    //     }
                    // }         
                }
            }
        }

        if (!districtEvalSalesCodes.isEmpty()) {
            List<Evaluation__c> evaluationList = [
                SELECT Id, SalesDistrictCode__c, BrandCode__c, Type__c, JDP_Evaluation__c, DistrictSalesManager__c, ApprovalStatus__c, ScheduledTopic__r.TopicOwner__c, RecordType.DeveloperName
                FROM Evaluation__c 
                WHERE BrandCode__c = 'H' 
                // DPM-6033 start
                // AND Status__c NOT IN ('Closed','Completed')
                // AND Status__c != null
                // AND ApprovalStatus__c != 'Region Approved'
                AND EndDate__c >= :today
                // DPM-6033 end
                AND SalesDistrictCode__c IN :districtEvalSalesCodes 
                ORDER BY Createddate desc
            ];


            for (Evaluation__c eval : evaluationList) {
                District__c district = codeToDistrictMap.get(eval.SalesDistrictCode__c);
                
                if (district != null && eval.DistrictSalesManager__c != district.SalesManager__c) {
                    if(!evaluationsIdsToUpdate.contains(eval.Id) ) {
                        if (eval.Type__c == 'Sales' || eval.ScheduledTopic__r.TopicOwner__c == 'District Sales Manager') {
                            eval.DistrictSalesManager__c = district.SalesManager__c;
                            eval.OwnerId = district.SalesManager__c;
                            evaluationsToUpdate.add(eval);
                            evaluationsIdsToUpdate.add(eval.id);
                        } 
                    } else {
                        if (eval.Type__c == 'Sales' || eval.ScheduledTopic__r.TopicOwner__c == 'District Sales Manager') {
                            eval.DistrictSalesManager__c = district.SalesManager__c;
                            eval.OwnerId = district.SalesManager__c;
                        }
                        evaluationsToUpdate.add(eval);
                    }

                    // if(validApprovalStatuses.contains(eval.ApprovalStatus__c) || eval.RecordType.DeveloperName.contains('Warranty')) {
                    //     if(eval.Type__c == 'Sales' || eval.ScheduledTopic__r.TopicOwner__c == 'District Sales Manager') {
                    //         eval.OwnerId = district.SalesManager__c;
                    //     }
                    // }
                         
                }
            }
        }

         if (!districtEvalServiceCodes.isEmpty()) {
            List<Evaluation__c> evaluationList = [
                SELECT Id, ServiceDistrictCode__c, BrandCode__c, Type__c, JDP_Evaluation__c, DistrictPartsServiceManager__c, ApprovalStatus__c, ScheduledTopic__r.TopicOwner__c, RecordType.DeveloperName
                FROM Evaluation__c 
                WHERE BrandCode__c = 'H'
                // AND Status__c NOT IN ('Closed','Completed') //DPM-6033
                // AND Status__c != null //DPM-6033
                // AND ApprovalStatus__c != 'Region Approved'  //DPM-6033
                AND EndDate__c >= :today
                AND ServiceDistrictCode__c IN :districtApServiceCodes 
                ORDER BY Createddate desc
            ];

            for (Evaluation__c eval : evaluationList) {
                District__c district = codeToDistrictMap.get(eval.ServiceDistrictCode__c);
                
                if (district != null && eval.DistrictPartsServiceManager__c != district.DistrictPartsServiceManager__c) {
                    if(!evaluationsIdsToUpdate.contains(eval.id)) {
                        if (eval.Type__c == 'Service' || eval.ScheduledTopic__r.TopicOwner__c == 'District Parts Service Manager') {
                            eval.DistrictPartsServiceManager__c = district.DistrictPartsServiceManager__c;
                            eval.OwnerId = district.DistrictPartsServiceManager__c;
                            evaluationsToUpdate.add(eval);
                            evaluationsIdsToUpdate.add(eval.id);
                        }
                    } else {
                        if(eval.Type__c == 'Service' || eval.ScheduledTopic__r.TopicOwner__c == 'District Parts Service Manager') {
                            eval.DistrictPartsServiceManager__c = district.DistrictPartsServiceManager__c;
                            eval.OwnerId = district.DistrictPartsServiceManager__c;
                        }
                        evaluationsToUpdate.add(eval);
                        
                    } 

                    // if(validApprovalStatuses.contains(eval.ApprovalStatus__c) || eval.RecordType.DeveloperName.contains('Warranty')) {
                    //     if(eval.Type__c == 'Service'  || eval.ScheduledTopic__r.TopicOwner__c == 'District Parts Service Manager') {
                    //         eval.OwnerId = district.DistrictPartsServiceManager__c;
                    //     }
                    // }
                }
            }
        }

        if (!evaluationsToUpdate.isEmpty()) {
            update evaluationsToUpdate;
        }
        // Update Evaluation End 
    }
}