/**
 * Description: [Class EvaluationService]
 * (.....)
 * ----- Change Log -----
 * Author : [jonghoonKim] / [10-01-2024] / [DPM-5814] / [Modify the createEvaluationDealerSharing method to execute only when the IsDealerCommunityVisible__c value is True] 
 * ---------------------------
 */
public without sharing class EvaluationService {

    
     /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] Added parameter Map<Id, Map<String, SObject>> existingSharesMap to reduce the queries 
    */
    public static void createEvaluationSharing(Map<Id, Evaluation__c> newEvaluationMap, Map<Id, Map<String, SObject>> existingSharesMap) { //DPM-5426 added Map<Id, Map<String, SObject>> existingSharesMap by MinheeKim 24.03.19

        String outputString = '';
        try {
            Map<Id, List<ObjectAccess__mdt>> mapOfEvaluationToObjectAccess = buildObjectAccessMap(newEvaluationMap.values());
            Set<String> publicGroups = new Set<String>();
            HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');
            // Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(newevaluationMap.values(), Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c); //DPM-5426 changed to comments by MinheeKim - 24.03.19

            outputString = 'Existing Shares Map\n' + existingSharesMap.toString() +'\n\n'; 
            /*for(Evaluation__c evaluation:newEvaluationMap.values()) {
                for(ObjectAccess__mdt objectAccess:HMAQueryService.getObjectAccessTypes(evaluation, 'Evaluation__c')) {
                    if(!mapOfEvaluationToObjectAccess.containsKey(evaluation.Id)) {
                        mapOfEvaluationToObjectAccess.put(evaluation.Id, new List<ObjectAccess__mdt>());                                             
                    }
                    mapOfEvaluationToObjectAccess.get(evaluation.Id).add(objectAccess);
                    publicGroups.add(objectAccess.PublicGroups__c);
                }
            }*/

            Map<Id, Id> contactIdUserIdMap = getPrimaryContactUserMapFromEvaluations(newEvaluationMap.values());
            Map<String, Id> publicGroupMap = HMAQueryService.getPublicGroupMapByDeveloperName();
            Boolean showDealerCommunity = false; // DPM-5814
            for (Evaluation__c evaluation : newevaluationMap.values()) {
                if (evaluation.IsDealerCommunityVisible__c) {
                    showDealerCommunity = true;
                    break; 
                }
            }


            for(Evaluation__c evaluation:newEvaluationMap.values()) {
                System.debug('EvaluationTest GenesisMarketManagerAlt__c: '+evaluation.GenesisMarketManagerAlt__c);
                System.debug('EvaluationTest OwnerId: '+evaluation.OwnerId);
                System.debug('EvaluationTest .GenesisMarketManagerAlt__r.IsActive: '+evaluation.GenesisMarketManagerAlt__r.IsActive);
                System.debug('EvaluationTest Type__c: '+evaluation.Type__c);
                outputString += 'Evaluation Id: ' + evaluation.Id + '\n\n';
                if(mapOfEvaluationToObjectAccess.containsKey(evaluation.Id)) {
                    for(ObjectAccess__mdt objectAccess:mapOfEvaluationToObjectAccess.get(evaluation.Id)) {
                        if(existingSharesMap.containsKey(evaluation.Id)) {
                            if(existingSharesMap.get(evaluation.Id).containsKey(objectAccess.PublicGroups__c)) {
                                existingSharesMap.get(evaluation.Id).remove(objectAccess.PublicGroups__c);
                                //continue;
                            } 
                            else {
                                Id publicGroupId= publicGroupMap.get(objectAccess.PublicGroups__c);
                                outputString += 'Adding Public Group ' +publicGroupId + '\n\n';
                                apexSharing.add(evaluation, publicGroupId, objectAccess.AccessLevel__c, Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                            }
                        }
                        else {
                            Id publicGroupId= publicGroupMap.get(objectAccess.PublicGroups__c);
                            outputString += 'Adding Public Group ' +publicGroupId + '\n\n';
                            apexSharing.add(evaluation, publicGroupId, objectAccess.AccessLevel__c, Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                }
                if(evaluation.OwnerId != evaluation.CreatedById && evaluation.CreatedBy.IsActive) {
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.CreatedById)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.CreatedById);
                            //continue;
                        }
                        else {
                            outputString += 'Adding CreatedById' +evaluation.CreatedById + '\n\n';
                            apexSharing.add(evaluation, evaluation.CreatedById, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        outputString += 'Adding CreatedById' +evaluation.CreatedById + '\n\n';
                        apexSharing.add(evaluation, evaluation.CreatedById, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }

                
                if(evaluation.OwnerId != evaluation.DistrictPartsServiceManager__c && evaluation.DistrictPartsServiceManager__c != null && evaluation.DistrictPartsServiceManager__r.IsActive) {
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.DistrictPartsServiceManager__c)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.DistrictPartsServiceManager__c);
                        // continue;
                        }
                        else {
                            outputString += 'Adding DistrictPartsServiceManager__c' +evaluation.DistrictPartsServiceManager__c + '\n\n';
                            apexSharing.add(evaluation, evaluation.DistrictPartsServiceManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        outputString += 'Adding DistrictPartsServiceManager__c' +evaluation.DistrictPartsServiceManager__c + '\n\n';
                        apexSharing.add(evaluation, evaluation.DistrictPartsServiceManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
               /* if(evaluation.OwnerId != evaluation.DistrictPartsServiceManagerAlt__c && evaluation.DistrictPartsServiceManagerAlt__c != null && evaluation.DistrictPartsServiceManagerAlt__r.IsActive) {
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.DistrictPartsServiceManagerAlt__c)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.DistrictPartsServiceManagerAlt__c);
                        // continue;
                        }
                        else {
                            outputString += 'Adding DistrictPartsServiceManagerAlt__c' +evaluation.DistrictPartsServiceManagerAlt__c + '\n\n';
                            apexSharing.add(evaluation, evaluation.DistrictPartsServiceManagerAlt__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        outputString += 'Adding DistrictPartsServiceManagerAlt__c' +evaluation.DistrictPartsServiceManagerAlt__c + '\n\n';
                        apexSharing.add(evaluation, evaluation.DistrictPartsServiceManagerAlt__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }*/
                if(evaluation.OwnerId != evaluation.DistrictSalesManager__c && evaluation.DistrictSalesManager__c != null && evaluation.DistrictSalesManager__r.IsActive) {
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.DistrictSalesManager__c)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.DistrictSalesManager__c);
                            //continue;
                        }
                        else {
                            outputString += 'Adding DistrictSalesManager__c' +evaluation.DistrictSalesManager__c + '\n\n';
                            apexSharing.add(evaluation, evaluation.DistrictSalesManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        outputString += 'Adding DistrictSalesManager__c' + evaluation.DistrictSalesManager__c + '\n\n';
                        apexSharing.add(evaluation, evaluation.DistrictSalesManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
              /*  if(evaluation.OwnerId != evaluation.DistrictSalesManagerAlt__c && evaluation.DistrictSalesManagerAlt__c != null && evaluation.DistrictSalesManagerAlt__r.IsActive) {
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.DistrictSalesManagerAlt__c)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.DistrictSalesManagerAlt__c);
                            //continue;
                        }
                        else {
                            outputString += 'Adding DistrictSalesManagerAlt__c' +evaluation.DistrictSalesManagerAlt__c + '\n\n';
                            apexSharing.add(evaluation, evaluation.DistrictSalesManagerAlt__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        outputString += 'Adding DistrictSalesManagerAlt__c' + evaluation.DistrictSalesManagerAlt__c + '\n\n';
                        apexSharing.add(evaluation, evaluation.DistrictSalesManagerAlt__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }*/
                if(evaluation.OwnerId != evaluation.MarketManager__c && evaluation.MarketManager__c != null && evaluation.MarketManager__r.IsActive  && evaluation.Type__c == 'Sales') {
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.MarketManager__c)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.MarketManager__c);
                            //continue;
                        }
                        else {
                            outputString += 'Adding MarketManager__c' +evaluation.MarketManager__c + '\n\n';
                            apexSharing.add(evaluation, evaluation.MarketManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        outputString += 'Adding MarketManager__c' +evaluation.MarketManager__c + '\n\n';
                        apexSharing.add(evaluation, evaluation.MarketManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
                
                //---
				if(evaluation.OwnerId != evaluation.Aftersales_Market_Manager__c && evaluation.Aftersales_Market_Manager__c != null && evaluation.Aftersales_Market_Manager__r.IsActive && evaluation.Type__c == 'Service') {
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.Aftersales_Market_Manager__c)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.Aftersales_Market_Manager__c);
                            //continue;
                        }
                        else {
                            outputString += 'Adding Aftersales_Market_Manager__c' +evaluation.Aftersales_Market_Manager__c + '\n\n';
                            apexSharing.add(evaluation, evaluation.Aftersales_Market_Manager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        outputString += 'Adding Aftersales_Market_Manager__c' +evaluation.Aftersales_Market_Manager__c + '\n\n';
                        apexSharing.add(evaluation, evaluation.Aftersales_Market_Manager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
                //---
                if(evaluation.OwnerId != evaluation.GenesisMarketManagerAlt__c && evaluation.GenesisMarketManagerAlt__c != null && evaluation.GenesisMarketManagerAlt__r.IsActive  && evaluation.Type__c == 'Sales') {
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.GenesisMarketManagerAlt__c)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.GenesisMarketManagerAlt__c);
                            //continue;
                        }
                        else {
                            outputString += 'Adding GenesisMarketManagerAlt__c' +evaluation.GenesisMarketManagerAlt__c + '\n\n';
                            apexSharing.add(evaluation, evaluation.GenesisMarketManagerAlt__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        outputString += 'Adding GenesisMarketManagerAlt__c' +evaluation.GenesisMarketManagerAlt__c + '\n\n';
                        apexSharing.add(evaluation, evaluation.GenesisMarketManagerAlt__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
                if(evaluation.OwnerId != evaluation.DistrictManager__c && evaluation.DistrictManager__c != null && evaluation.DistrictManager__r.IsActive) {
                
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.DistrictManager__c)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.DistrictManager__c);
                            //continue;
                        }
                        else{
                            apexSharing.add(evaluation, evaluation.DistrictManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        apexSharing.add(evaluation, evaluation.DistrictManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
               /* if(evaluation.OwnerId != evaluation.DistrictManagerAlt__c && evaluation.DistrictManagerAlt__c != null && evaluation.DistrictManagerAlt__r.IsActive) {
                
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.DistrictManagerAlt__c)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.DistrictManagerAlt__c);
                            //continue;
                        }
                        else{
                            apexSharing.add(evaluation, evaluation.DistrictManagerAlt__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        apexSharing.add(evaluation, evaluation.DistrictManagerAlt__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }*/

              /*
               * /* following code is commented by neeraj for 3523 ticket   
               *  if(evaluation.OwnerId != evaluation.GenesisAreaManager__c && evaluation.GenesisAreaManager__c != null && evaluation.GenesisAreaManager__r.IsActive) {
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.GenesisAreaManager__c)) {
                            existingSharesMap.get(evaluation.Id).remove(evaluation.GenesisAreaManager__c);
                        }
                        //continue;
                        else {
                            outputString += 'Adding GenesisAreaManager__c' +evaluation.GenesisAreaManager__c + '\n\n';
                            apexSharing.add(evaluation, evaluation.GenesisAreaManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                    else {
                        outputString += 'Adding GenesisAreaManager__c' +evaluation.GenesisAreaManager__c + '\n\n';
                        apexSharing.add(evaluation, evaluation.GenesisAreaManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }*/
                if(showDealerCommunity) {
                    if(evaluation.PrimaryContact__c != null && contactIdUserIdMap.containsKey(evaluation.PrimaryContact__c)) { //5814 
                        String primaryContactUserId = contactIdUserIdMap.get(evaluation.PrimaryContact__c);
                        if(evaluation.OwnerId != primaryContactUserId) {
                            if(existingSharesMap.containsKey(evaluation.Id)) {
                                if(existingSharesMap.get(evaluation.Id).containsKey(primaryContactUserId)) {
                                    existingSharesMap.get(evaluation.Id).remove(primaryContactUserId);
                                    System.debug(LoggingLevel.ERROR, 'Removing Primary Contact');
                                }
                                else {
                                    System.debug(LoggingLevel.ERROR, 'Adding Primary Contact');
                                    outputString += 'Adding PrimaryContact__c' +evaluation.PrimaryContact__c + '\n\n';
                                    apexSharing.add(evaluation, contactIdUserIdMap.get(evaluation.PrimaryContact__c), 'Read', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                                }
                            }
                            else {
                                System.debug(LoggingLevel.ERROR, 'Adding Primary Contact 2');
                                outputString += 'Adding PrimaryContact__c' +evaluation.PrimaryContact__c + '\n\n';
                                apexSharing.add(evaluation, contactIdUserIdMap.get(evaluation.PrimaryContact__c), 'Read', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                            }
                        }
                    }
                }
                
            }
            System.debug(LoggingLevel.ERROR, 'Shares we are going to insert');
            System.debug(LoggingLevel.ERROR, apexSharing.records);

            apexSharing.share();

            if(!existingSharesMap.keySet().isEmpty()) {
                for(Id evaluationId:existingSharesMap.keySet()) {
                    if(!existingSharesMap.get(evaluationId).keySet().isEmpty()) {
                        for(String groupDeveloperName:existingSharesMap.get(evaluationId).keySet()) {
                            Evaluation__Share shareToRemove = (Evaluation__Share) existingSharesMap.get(evaluationId).get(groupDeveloperName);
                            apexSharing.remove(new Evaluation__c(Id = evaluationId), shareToRemove.UserOrGroupId, shareToRemove.AccessLevel, Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                        }
                    }
                }
            }

            apexSharing.unshare();
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            HMALogs__c log = new HMALogs__c(
                Type__c = 'Error',
                FullLog__c = ex.getMessage() + ex.getLineNumber(),
                Origin__c = 'EvaluationService',
                Notes__c = outputString
            );
            insert log;

        }
    }

    public static Map<Id, Id> getPrimaryContactUserMapFromEvaluations(List<Evaluation__c> evaluations) {
        List<Id> primaryContactIds = new List<Id>();
        for(Evaluation__c evaluation:evaluations) {
            if(evaluation.PrimaryContact__c != null) {
                primaryContactIds.add(evaluation.PrimaryContact__c);
            }
        }

        Map<Id, Id> contactIdUserIdMap = new Map<Id, Id>();
        for(User user:[select Id, ContactId from User where ContactId in :primaryContactIds and IsActive = true]) {
            contactIdUserIdMap.put(user.ContactId, user.Id);
        }
        return contactIdUserIdMap;
    }

    public static Map<Id, List<ObjectAccess__mdt>> buildObjectAccessMap(List<Evaluation__c> evaulations) {
        Map<Id, List<ObjectAccess__mdt>> evaluationAccessTypeMap = new Map<Id, List<ObjectAccess__mdt>>();

        List<String> regionCodes = new List<String>();
        List<String> salesDistrictCodes = new List<String>();
        List<String> serviceDistrictCodes = new List<String>();
        List<String> marketCodes = new List<String>();

        Map<String, List<ObjectAccess__mdt>> regionObjectAccessTypes;
        Map<String, List<ObjectAccess__mdt>> serviceDistrictObjectAccessTypes;
        Map<String, List<ObjectAccess__mdt>> salesDistrictObjectAccessTypes;
        Map<String, List<ObjectAccess__mdt>> marketObjectAccessTypes;

        for(Evaluation__c evaluation:evaulations) {
            if(!String.isBlank(evaluation.RegionCode__c)) {
                regionCodes.add(evaluation.RegionCode__c);
            }
            if(!String.isBlank(evaluation.ServiceDistrictCode__c)) {
                serviceDistrictCodes.add(evaluation.ServiceDistrictCode__c);
            }
            if(!String.isBlank(evaluation.SalesDistrictCode__c)) {
                salesDistrictCodes.add(evaluation.SalesDistrictCode__c);
            }
            if(!String.isBlank(evaluation.MarketCode__c)) {
                marketCodes.add(evaluation.MarketCode__c);
            }
        }

        System.debug(LoggingLevel.ERROR, regionCodes);
        System.debug(LoggingLevel.ERROR, serviceDistrictCodes);
        System.debug(LoggingLevel.ERROR, salesDistrictCodes);
        System.debug(LoggingLevel.ERROR, marketCodes);


        if(!regionCodes.isEmpty()) {
            regionObjectAccessTypes = HMAQueryService.getObjectAccessTypes('Region', 'Evaluation__c', regionCodes);
        }

        if(!serviceDistrictCodes.isEmpty()) {
            serviceDistrictObjectAccessTypes = HMAQueryService.getObjectAccessTypes('District', 'Evaluation__c', serviceDistrictCodes);
        }

        if(!salesDistrictCodes.isEmpty()) {
            salesDistrictObjectAccessTypes = HMAQueryService.getObjectAccessTypes('District', 'Evaluation__c', salesDistrictCodes);
        }

        if(!marketCodes.isEmpty()) {
            marketObjectAccessTypes = HMAQueryService.getObjectAccessTypes('Market', 'Evaluation__c', marketCodes);
        }

        System.debug(LoggingLevel.ERROR, regionObjectAccessTypes);
        System.debug(LoggingLevel.ERROR, serviceDistrictObjectAccessTypes);
        System.debug(LoggingLevel.ERROR, salesDistrictObjectAccessTypes);
        System.debug(LoggingLevel.ERROR, marketObjectAccessTypes);
        system.debug('i am at 270');

        for(Evaluation__c evaluation:evaulations) {
            if(!evaluationAccessTypeMap.containsKey(evaluation.Id)) {
                evaluationAccessTypeMap.put(evaluation.Id, new List<ObjectAccess__mdt>());
            }

            //System.debug(LoggingLevel.ERROR, evaluation.RegionCode__c);
            //System.debug(LoggingLevel.ERROR, regionObjectAccessTypes);
            if(!String.isBlank(evaluation.RegionCode__c) && regionObjectAccessTypes.containsKey(evaluation.RegionCode__c)) {
                for(ObjectAccess__mdt objAcc: regionObjectAccessTypes.get(evaluation.RegionCode__c)){
                    if(objAcc.OrganizationName__c!=null && objAcc.OrganizationName__c==evaluation.Organization__c)
                    evaluationAccessTypeMap.get(evaluation.Id).add(objAcc);

                }
               //  evaluationAccessTypeMap.get(evaluation.Id).addAll(regionObjectAccessTypes.get(evaluation.RegionCode__c));
            }
            
            if(!String.isBlank(evaluation.ServiceDistrictCode__c) && serviceDistrictObjectAccessTypes.containsKey(evaluation.ServiceDistrictCode__c)) {
                for(ObjectAccess__mdt objAcc: serviceDistrictObjectAccessTypes.get(evaluation.ServiceDistrictCode__c)){
                    if(objAcc.OrganizationName__c!=null && objAcc.OrganizationName__c==evaluation.Organization__c)
                    evaluationAccessTypeMap.get(evaluation.Id).add(objAcc);

                }
               
               // evaluationAccessTypeMap.get(evaluation.Id).addAll(serviceDistrictObjectAccessTypes.get(evaluation.ServiceDistrictCode__c));
            }

            if(!String.isBlank(evaluation.SalesDistrictCode__c) && salesDistrictObjectAccessTypes.containsKey(evaluation.SalesDistrictCode__c)) {
                for(ObjectAccess__mdt objAcc: salesDistrictObjectAccessTypes.get(evaluation.SalesDistrictCode__c)){
                    if(objAcc.OrganizationName__c!=null && objAcc.OrganizationName__c==evaluation.Organization__c)
                    evaluationAccessTypeMap.get(evaluation.Id).add(objAcc);

                }
               // evaluationAccessTypeMap.get(evaluation.Id).addAll(salesDistrictObjectAccessTypes.get(evaluation.SalesDistrictCode__c));
            }

            if(!String.isBlank(evaluation.MarketCode__c) && marketObjectAccessTypes.containsKey(evaluation.MarketCode__c)) {
                for(ObjectAccess__mdt objAcc: marketObjectAccessTypes.get(evaluation.MarketCode__c)){
                    if(objAcc.OrganizationName__c!=null && objAcc.OrganizationName__c==evaluation.Organization__c)
                    evaluationAccessTypeMap.get(evaluation.Id).add(objAcc);

                }
               
               // evaluationAccessTypeMap.get(evaluation.Id).addAll(marketObjectAccessTypes.get(evaluation.MarketCode__c));
            }
        }
        return evaluationAccessTypeMap;
    }


    /*public static void recalculateEvaluationSharing(List<Evaluation__c> updatedEvaluations) {

        Map<Id, List<ObjectAccess__mdt>> mapOfEvaluationToObjectAccess = buildObjectAccessMap(updatedEvaluations);
        Set<String> publicGroups = new Set<String>();

        HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');
        Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(updatedEvaluations, Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);

        Map<Id, Id> contactIdUserIdMap = getPrimaryContactUserMapFromEvaluations(updatedEvaluations);
        Map<String, Id> publicGroupMap = HMAQueryService.getPublicGroupMapByDeveloperName();
        for(Evaluation__c evaluation:updatedEvaluations) {
            if(mapOfEvaluationToObjectAccess.containsKey(evaluation.Id)) {
                for(ObjectAccess__mdt objectAccess:mapOfEvaluationToObjectAccess.get(evaluation.Id)) {
                    if(existingSharesMap.containsKey(evaluation.Id)) {
                        if(existingSharesMap.get(evaluation.Id).containsKey(objectAccess.PublicGroups__c)) {
                            existingSharesMap.get(evaluation.Id).remove(objectAccess.PublicGroups__c);
                            continue;
                        } 
                    }          
                    Id publicGroupId= publicGroupMap.get(objectAccess.PublicGroups__c);
                    apexSharing.add(evaluation, publicGroupId, objectAccess.AccessLevel__c, Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                }
            }
            if(evaluation.OwnerId != evaluation.CreatedById) {
                if(existingSharesMap.containsKey(evaluation.Id)) {
                    if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.CreatedById)) {
                        existingSharesMap.get(evaluation.Id).remove(evaluation.CreatedById);
                    }
                    else {
                        apexSharing.add(evaluation, evaluation.CreatedById, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
            }
            if(evaluation.OwnerId != evaluation.DistrictPartsServiceManager__c && evaluation.DistrictPartsServiceManager__c != null) {
                if(existingSharesMap.containsKey(evaluation.Id)) {
                    if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.DistrictPartsServiceManager__c)) {
                        existingSharesMap.get(evaluation.Id).remove(evaluation.DistrictPartsServiceManager__c);
                    }
                    else {
                        apexSharing.add(evaluation, evaluation.DistrictPartsServiceManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
            }
            if(evaluation.OwnerId != evaluation.DistrictSalesManager__c && evaluation.DistrictSalesManager__c != null) {
                if(existingSharesMap.containsKey(evaluation.Id)) {
                    if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.DistrictSalesManager__c)) {
                        existingSharesMap.get(evaluation.Id).remove(evaluation.DistrictSalesManager__c);
                    }
                    else {
                        apexSharing.add(evaluation, evaluation.DistrictSalesManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
            }
            if(evaluation.OwnerId != evaluation.MarketManager__c && evaluation.MarketManager__c != null) {
                if(existingSharesMap.containsKey(evaluation.Id)) {
                    if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.MarketManager__c)) {
                        existingSharesMap.get(evaluation.Id).remove(evaluation.MarketManager__c);
                    }
                    else {
                        apexSharing.add(evaluation, evaluation.MarketManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
            }
            if(evaluation.OwnerId != evaluation.GenesisAreaManager__c && evaluation.GenesisAreaManager__c != null) {
                if(existingSharesMap.containsKey(evaluation.Id)) {
                    if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.GenesisAreaManager__c)) {
                        existingSharesMap.get(evaluation.Id).remove(evaluation.GenesisAreaManager__c);
                    }
                    else {
                        apexSharing.add(evaluation, evaluation.GenesisAreaManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
            }

            if(evaluation.OwnerId !=  evaluation.PrimaryContact__c && evaluation.GenesisAreaManager__c != null) {
                if(existingSharesMap.containsKey(evaluation.Id)) {
                    if(existingSharesMap.get(evaluation.Id).containsKey(evaluation.GenesisAreaManager__c)) {
                        existingSharesMap.get(evaluation.Id).remove(evaluation.GenesisAreaManager__c);
                    }
                    else {
                        apexSharing.add(evaluation, evaluation.GenesisAreaManager__c, 'Edit', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
            }

            if(evaluation.PrimaryContact__c != null && contactIdUserIdMap.containsKey(evaluation.PrimaryContact__c)) { 
                if(existingSharesMap.containsKey(evaluation.Id)) {
                    String primaryContactUserId = contactIdUserIdMap.get(evaluation.PrimaryContact__c);
                    if(existingSharesMap.get(evaluation.Id).containsKey(primaryContactUserId)) {
                        existingSharesMap.get(evaluation.Id).remove(primaryContactUserId);
                    }
                    else {
                        apexSharing.add(evaluation, primaryContactUserId, 'Read', Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
            }
        }

        apexSharing.share();

        if(!existingSharesMap.keySet().isEmpty()) {
            for(Id evaluationId:existingSharesMap.keySet()) {
                if(!existingSharesMap.get(evaluationId).keySet().isEmpty()) {
                    for(String groupDeveloperName:existingSharesMap.get(evaluationId).keySet()) {
                        Evaluation__Share shareToRemove = (Evaluation__Share) existingSharesMap.get(evaluationId).get(groupDeveloperName);
                        apexSharing.remove(new Evaluation__c(Id = evaluationId), shareToRemove.UserOrGroupId, shareToRemove.AccessLevel, Schema.Evaluation__Share.RowCause.Evaluation_Sharing__c);
                    }
                }
            }
        }
        apexSharing.unshare();
    }*/

    public static Map<String, AccessType__mdt> getAccessTypeMap() {

        Map<String, AccessType__mdt> accessTypeMap = new Map<String, AccessType__mdt>();
        for(AccessType__mdt accessType:[select Id, DeveloperName, ObjectAccessAPINames__c from AccessType__mdt]) {
            accessTypeMap.put(accessType.DeveloperName, accessType);
        }
        return accessTypeMap;
    }

     /**s
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] Added parameter Map<Id, Map<String, SObject>> existingSharesMap to reduce the queries 
     * Edited by [Jonghoon Kim] on [10-01-2024] for [DPM-5814] Add showDealerCommunity
    */
    public static void createEvaluationDealerSharing(Map<Id, Evaluation__c> newevaluationMap , Map<Id, Map<String, SObject>> existingSharesMap) { //DPM-5426 Map<Id, Map<String, SObject>> existingSharesMap by MinheeKim - 24.03.19
        Boolean showDealerCommunity = false; // DPM-5814
        // DPM - 5814  Add showDealerCommunity
        try {
            for (Evaluation__c evaluation : newevaluationMap.values()) {
                if (evaluation.IsDealerCommunityVisible__c) {
                    showDealerCommunity = true;
                    break; 
                }
            }
            if (showDealerCommunity) {
                
                Map<Id, List<Evaluation__c>> accountEvaluationMap = new  Map<Id, List<Evaluation__c>>();

                for(Evaluation__c evaluation:newevaluationMap.values()) {
                    if(!accountEvaluationMap.containsKey(evaluation.Account__c)) {
                        accountEvaluationMap.put(evaluation.Account__c, new List<Evaluation__c>());
                    }
                    accountEvaluationMap.get(evaluation.Account__c).add(evaluation);
                }

                Map<Id, Account> accountMap = new Map<Id, Account>([select Id, DealerCode__c from Account where Id in :accountEvaluationMap.keyset()]);
                Map<Id, List<User>> accountUserMap = getAccountContactsMap(accountEvaluationMap.keySet());
                Map<String, ObjectAccess__mdt> evaluationAccessTypes = getObjectAccessMapEvaluationPlans();
                Map<String, AccessType__mdt> accessTypesMap = getAccessTypeMap();

                HMAApexSharing apexSharing = new HMAApexSharing('Evaluation__Share');

                // Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(newevaluationMap.values(), Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c); //DPM-5426 changed to comments by MinheeKim - 24.03.19

                for(Evaluation__c evaluation:newevaluationMap.values()) {
                    Account evaluationAccount = accountMap.get(evaluation.Account__c);

                    if(accountUserMap.containsKey(evaluation.Account__c)) {
                        for(User dealerUser:accountUserMap.get(evaluation.Account__c)) {
                            Boolean processed = false;
                            if(dealerUser.AccessTypes__c != null) {
                                for(String accessType:dealerUser.AccessTypes__c.split(',')) {
                                    if(accessType.contains('/') && accessType.contains(evaluationAccount.DealerCode__c) && accessType.contains('DPM_Eval')) {
                                        String[] dealerAccessType = accessType.split('/');

                                        if(accessTypesMap.containsKey(dealerAccessType[0])) {
                                            String objectAccessAPINames = accessTypesMap.get(dealerAccessType[0]).ObjectAccessAPINames__c;
                                            if(!String.isBlank(objectAccessAPINames)) {
                                                for(String objectAccessAPIName:objectAccessAPINames.split(',')) {
                                                    if(evaluationAccessTypes.containsKey(objectAccessAPIName)){
                                                        if(existingSharesMap.containsKey(evaluation.Id)) {
                                                            if(existingSharesMap.get(evaluation.Id).containsKey(dealerUser.Id)) {
                                                                existingSharesMap.get(evaluation.Id).remove(dealerUser.Id);
                                                                processed = true;
                                                                break;
                                                            }
                                                        }
                                                        apexSharing.add(evaluation, dealerUser.Id, evaluationAccessTypes.get(objectAccessAPIName).AccessLevel__c, Schema.Evaluation__Share.RowCause.Dealer_Evaluation_Sharing__c);
                                                        processed = true;
                                                        break;
                                                    }
                                                }
                                                if(processed) {
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                apexSharing.share();
            }
        } catch (Exception e) {
            System.debug('Error occurred while processing dealer sharing: ' + e.getMessage());
        }
    }

    private static Map<String, ObjectAccess__mdt> getObjectAccessMapEvaluationPlans() {

        Map<String, ObjectAccess__mdt> objectAccessMap = new Map<String, ObjectAccess__mdt>();
        for(ObjectAccess__mdt objectAccess:[select Id, AccessLevel__c, ObjectAPINames__c, DeveloperName from ObjectAccess__mdt where Active__c = true]) {
            if(objectAccess.ObjectAPINames__c.contains('Evaluation__c')) {
                objectAccessMap.put(objectAccess.DeveloperName, objectAccess);
            }
        }
        return objectAccessMap;
    }

    private static Map<Id, List<User>> getAccountContactsMap(Set<Id> accountIds) {
        Map<Id, List<User>> accountUserMap = new Map<Id, List<User>>();

        Map<Id, List<Id>> mapContactIdsToAccountIdsList = new Map<Id, List<Id>>();
        for(AccountContactRelation accountContactRelation:[select Id, AccountId, ContactId from AccountContactRelation where AccountId in :accountIds]) {
            if(!mapContactIdsToAccountIdsList.containsKey(accountContactRelation.ContactId)) {
                mapContactIdsToAccountIdsList.put(accountContactRelation.ContactId, new List<Id>());
            }
            mapContactIdsToAccountIdsList.get(accountContactRelation.ContactId).add(accountContactRelation.AccountId);
        }

        for(User user:[select Id, AccountId, Account.DealerCode__c, ContactId, AccessTypes__c from User where ContactId in :mapContactIdsToAccountIdsList.keySet() and IsActive = true]) {
            for(Id accountId:mapContactIdsToAccountIdsList.get(user.ContactId)) {
                if(!accountUserMap.containsKey(accountId)) {
                    accountUserMap.put(accountId, new List<User>());
                }
                accountUserMap.get(accountId).add(user);
            }
        }

        return accountUserMap;
    }
}