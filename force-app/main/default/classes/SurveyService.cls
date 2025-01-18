public without sharing class SurveyService {

     /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] Added parameter Map<Id, Map<String, SObject>> existingSharesMap to reduce the queries 
    */
    public static void createSurveySharing(Map<Id, Survey__c> newSurveyMap, Map<Id, Map<String, SObject>> existingSharesMap) { //DPM-5426 added Map<Id, Map<String, SObject>> existingSharesMap by MinheeKim - 24.03.19

        Map<Id, List<ObjectAccess__mdt>> mapOfEvaluationToObjectAccess = buildObjectAccessMap(newSurveyMap.values());
        Set<String> publicGroups = new Set<String>();
        HMAApexSharing apexSharing = new HMAApexSharing('Survey__Share');
        // Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(newSurveyMap.values(), Schema.Survey__Share.RowCause.Survey_Sharing__c); //DPM-5426 changed to comments by Minheekim - 24.03.19

        Map<String, Id> publicGroupMap = HMAQueryService.getPublicGroupMapByDeveloperName();
        Map<Id, Id> contactIdUserIdMap = getPrimaryContactUserMapFromSurveys(newSurveyMap.values());
        for(Survey__c survey:newSurveyMap.values()) {
            if(mapOfEvaluationToObjectAccess.containsKey(survey.Id)) {
                for(ObjectAccess__mdt objectAccess:mapOfEvaluationToObjectAccess.get(survey.Id)) {
                    if(existingSharesMap.containsKey(survey.Id)) {
                        if(existingSharesMap.get(survey.Id).containsKey(objectAccess.PublicGroups__c)) {
                            if((survey.OrganizationName__c==objectAccess.OrganizationName__c)|| (objectAccess.OrganizationName__c==null))
                            existingSharesMap.get(survey.Id).remove(objectAccess.PublicGroups__c);
                            //continue;
                        }
                        else {
                            Id publicGroupId= publicGroupMap.get(objectAccess.PublicGroups__c);
                            if((survey.OrganizationName__c==objectAccess.OrganizationName__c)|| (objectAccess.OrganizationName__c==null))
                            apexSharing.add(survey, publicGroupId, objectAccess.AccessLevel__c, Schema.Survey__Share.RowCause.Survey_Sharing__c);
                        }
                    }
                    else {
                        Id publicGroupId= publicGroupMap.get(objectAccess.PublicGroups__c);
                        if((survey.OrganizationName__c==objectAccess.OrganizationName__c)|| (objectAccess.OrganizationName__c==null))
                        apexSharing.add(survey, publicGroupId, objectAccess.AccessLevel__c, Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
            }
            if(survey.OwnerId != survey.CreatedById && survey.CreatedBy.IsActive) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.CreatedById)) {
                        existingSharesMap.get(survey.Id).remove(survey.CreatedById);
                        //continue;
                    }
                    else {
                        apexSharing.add(survey, survey.DistrictSalesManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.CreatedById, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
            }
            if(survey.OwnerId != survey.DistrictPartsServiceManager__c && survey.DistrictPartsServiceManager__c != null && survey.DistrictPartsServiceManager__r.IsActive) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.DistrictPartsServiceManager__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.DistrictPartsServiceManager__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(survey, survey.DistrictPartsServiceManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.DistrictPartsServiceManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
            }        
                if(survey.OwnerId != survey.DistrictPartsServiceManagerAlt__c && survey.DistrictPartsServiceManagerAlt__c != null && survey.DistrictPartsServiceManagerAlt__r.IsActive) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.DistrictPartsServiceManagerAlt__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.DistrictPartsServiceManagerAlt__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(survey, survey.DistrictPartsServiceManagerAlt__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.DistrictPartsServiceManagerAlt__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
            }
            if(survey.OwnerId != survey.DistrictSalesManager__c && survey.DistrictSalesManager__c != null && survey.DistrictSalesManager__r.IsActive) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.DistrictSalesManager__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.DistrictSalesManager__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(survey, survey.DistrictSalesManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.DistrictSalesManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
                
            }
            if(survey.OwnerId != survey.DistrictSalesManagerAlt__c && survey.DistrictSalesManagerAlt__c != null && survey.DistrictSalesManagerAlt__r.IsActive) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.DistrictSalesManagerAlt__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.DistrictSalesManagerAlt__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(survey, survey.DistrictSalesManagerAlt__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.DistrictSalesManagerAlt__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
                
            }
            //DPM-4188 Milind Shinde
            
            if(survey.OwnerId != survey.Aftersales_Market_Manager__c && survey.Aftersales_Market_Manager__c != null && survey.MarketManager__r.IsActive && survey.Division__c == 'Service') {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.Aftersales_Market_Manager__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.Aftersales_Market_Manager__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(survey, survey.Aftersales_Market_Manager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.Aftersales_Market_Manager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
            }
            
            if(survey.OwnerId != survey.MarketManager__c && survey.MarketManager__c != null && survey.MarketManager__r.IsActive  && survey.Division__c == 'Sales') {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.MarketManager__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.MarketManager__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(survey, survey.MarketManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.MarketManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
            }
            
            if(survey.OwnerId != survey.GenesisMarketManagerAlt__c && survey.GenesisMarketManagerAlt__c != null && survey.GenesisMarketManagerAlt__r.IsActive) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.GenesisMarketManagerAlt__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.GenesisMarketManagerAlt__c);
                        //continue;
                    }
                    else {
                        apexSharing.add(survey, survey.GenesisMarketManagerAlt__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.GenesisMarketManagerAlt__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
            }
         /*following code is commented by neeraj sharma for 3522 DPM ticket 
          *    if(survey.OwnerId != survey.GenesisAreaManager__c && survey.GenesisAreaManager__c != null && survey.GenesisAreaManager__r.IsActive) {
                
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.GenesisAreaManager__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.GenesisAreaManager__c);
                        //continue;
                    }
                    else{
                        apexSharing.add(survey, survey.GenesisAreaManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.GenesisAreaManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
            }
*/
            if(survey.OwnerId != survey.DistrictManager__c && survey.DistrictManager__c != null && survey.DistrictManager__r.IsActive) {
                
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.DistrictManager__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.DistrictManager__c);
                        //continue;
                    }
                    else{
                        apexSharing.add(survey, survey.DistrictManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.DistrictManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
            }
            if(survey.OwnerId != survey.DistrictManagerAlt__c && survey.DistrictManagerAlt__c != null && survey.DistrictManagerAlt__r.IsActive) {
                
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.DistrictManagerAlt__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.DistrictManagerAlt__c);
                        //continue;
                    }
                    else{
                        apexSharing.add(survey, survey.DistrictManagerAlt__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
                else {
                    apexSharing.add(survey, survey.DistrictManagerAlt__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
            }
            if(survey.PrimaryContact__c != null && contactIdUserIdMap.containsKey(survey.PrimaryContact__c)) {
                String primaryContactUserId = contactIdUserIdMap.get(survey.PrimaryContact__c);
                if(survey.OwnerId != primaryContactUserId) {
                    if(existingSharesMap.containsKey(survey.Id)) {
                        if(existingSharesMap.get(survey.Id).containsKey(primaryContactUserId)) {
                            existingSharesMap.get(survey.Id).remove(primaryContactUserId);
                            //continue;
                        }
                        else {
                            System.debug(LoggingLevel.ERROR, 'adding primary 1');
                            apexSharing.add(survey, contactIdUserIdMap.get(survey.PrimaryContact__c), 'Read', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                        }
                    }
                    else {
                        System.debug(LoggingLevel.ERROR, 'adding primary 2');
                        apexSharing.add(survey, contactIdUserIdMap.get(survey.PrimaryContact__c), 'Read', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
            }
        }
        System.debug(LoggingLevel.ERROR, 'survey shares');
        System.debug(LoggingLevel.ERROR, apexSharing.records);

        apexSharing.share();

        if(!existingSharesMap.keySet().isEmpty()) {
            for(Id surveyId:existingSharesMap.keySet()) {
                if(!existingSharesMap.get(surveyId).keySet().isEmpty()) {
                    for(String groupDeveloperName:existingSharesMap.get(surveyId).keySet()) {
                        Survey__Share shareToRemove = (Survey__Share) existingSharesMap.get(surveyId).get(groupDeveloperName);
                        apexSharing.remove(new Survey__c(Id = surveyId), shareToRemove.UserOrGroupId, shareToRemove.AccessLevel, Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
            }
        }

        apexSharing.unshare();
    }

    public static Map<Id, Id> getPrimaryContactUserMapFromSurveys(List<Survey__c> surveys) {
        List<Id> primaryContactIds = new List<Id>();
        for(Survey__c survey:surveys) {
            if(survey.PrimaryContact__c != null) {
                primaryContactIds.add(survey.PrimaryContact__c);
            }
        }

        Map<Id, Id> contactIdUserIdMap = new Map<Id, Id>();
        for(User user:[select Id, ContactId from User where ContactId in :primaryContactIds and IsActive = true]) {
            contactIdUserIdMap.put(user.ContactId, user.Id);
        }
        return contactIdUserIdMap;
    }

    public static Map<Id, List<ObjectAccess__mdt>> buildObjectAccessMap(List<Survey__c> surveys) {
        Map<Id, List<ObjectAccess__mdt>> surveyAccessTypeMap = new Map<Id, List<ObjectAccess__mdt>>();

        List<String> regionCodes = new List<String>();
        List<String> salesDistrictCodes = new List<String>();
        List<String> serviceDistrictCodes = new List<String>();
        List<String> marketCodes = new List<String>();

        Map<String, List<ObjectAccess__mdt>> regionObjectAccessTypes;
        Map<String, List<ObjectAccess__mdt>> serviceDistrictObjectAccessTypes;
        Map<String, List<ObjectAccess__mdt>> salesDistrictObjectAccessTypes;
        Map<String, List<ObjectAccess__mdt>> marketObjectAccessTypes;

        for(Survey__c survey:surveys) {
            if(!String.isBlank(survey.RegionCode__c)) {
                regionCodes.add(survey.RegionCode__c);
            }
            if(!String.isBlank(survey.ServiceDistrictCode__c)) {
                serviceDistrictCodes.add(survey.ServiceDistrictCode__c);
            }
            if(!String.isBlank(survey.SalesDistrictCode__c)) {
                salesDistrictCodes.add(survey.SalesDistrictCode__c);
            }
            if(!String.isBlank(survey.MarketCode__c)) {
                marketCodes.add(survey.MarketCode__c);
            }
        }

        if(!regionCodes.isEmpty()) {
            regionObjectAccessTypes = HMAQueryService.getObjectAccessTypes('Region', 'Survey__c', regionCodes);
        }

        if(!regionCodes.isEmpty()) {
            serviceDistrictObjectAccessTypes = HMAQueryService.getObjectAccessTypes('District', 'Survey__c', serviceDistrictCodes);
        }

        if(!regionCodes.isEmpty()) {
            salesDistrictObjectAccessTypes = HMAQueryService.getObjectAccessTypes('District', 'Survey__c', salesDistrictCodes);
        }

        if(!marketCodes.isEmpty()) {
            marketObjectAccessTypes = HMAQueryService.getObjectAccessTypes('Market', 'Survey__c', marketCodes);
        }

        for(Survey__c survey:surveys) {
            if(!surveyAccessTypeMap.containsKey(survey.Id)) {
                surveyAccessTypeMap.put(survey.Id, new List<ObjectAccess__mdt>());
            }

            if(!String.isBlank(survey.RegionCode__c) && regionObjectAccessTypes.containsKey(survey.RegionCode__c)) {
                surveyAccessTypeMap.get(survey.Id).addAll(regionObjectAccessTypes.get(survey.RegionCode__c));
            }
            
            if(!String.isBlank(survey.ServiceDistrictCode__c) && serviceDistrictObjectAccessTypes.containsKey(survey.ServiceDistrictCode__c)) {
                surveyAccessTypeMap.get(survey.Id).addAll(serviceDistrictObjectAccessTypes.get(survey.ServiceDistrictCode__c));
            }

            if(!String.isBlank(survey.SalesDistrictCode__c) && salesDistrictObjectAccessTypes.containsKey(survey.SalesDistrictCode__c)) {
                surveyAccessTypeMap.get(survey.Id).addAll(salesDistrictObjectAccessTypes.get(survey.SalesDistrictCode__c));
            }


            if(!String.isBlank(survey.MarketCode__c) && marketObjectAccessTypes.containsKey(survey.MarketCode__c)) {
                surveyAccessTypeMap.get(survey.Id).addAll(marketObjectAccessTypes.get(survey.MarketCode__c));
            }
        }
        return surveyAccessTypeMap;
    }

    /*public static void recalculateEvaluationSharing(List<Survey__c> updatedSurveys) {

        Map<Id, List<ObjectAccess__mdt>> mapOfSurveyToObjectAccess = buildObjectAccessMap(updatedSurveys);
        Set<String> publicGroups = new Set<String>();

        HMAApexSharing apexSharing = new HMAApexSharing('Survey__Share');
        Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(updatedSurveys, Schema.Survey__Share.RowCause.Survey_Sharing__c);

        Map<String, Id> publicGroupMap = HMAQueryService.getPublicGroupMapByDeveloperName();
        for(Survey__c survey:updatedSurveys) {
            if(mapOfSurveyToObjectAccess.containsKey(survey.Id)) {
                for(ObjectAccess__mdt objectAccess:mapOfSurveyToObjectAccess.get(survey.Id)) {
                    if(existingSharesMap.containsKey(survey.Id)) {
                        if(existingSharesMap.get(survey.Id).containsKey(objectAccess.PublicGroups__c)) {
                            existingSharesMap.get(survey.Id).remove(objectAccess.PublicGroups__c);
                            continue;
                        } 
                    }          
                    Id publicGroupId= publicGroupMap.get(objectAccess.PublicGroups__c);
                    apexSharing.add(survey, publicGroupId, objectAccess.AccessLevel__c, Schema.Survey__Share.RowCause.Survey_Sharing__c);
                }
            }
            if(survey.OwnerId != survey.CreatedById) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.CreatedById)) {
                        existingSharesMap.get(survey.Id).remove(survey.CreatedById);
                    }
                    else {
                        apexSharing.add(survey, survey.CreatedById, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
            }
            if(survey.OwnerId != survey.DistrictPartsServiceManager__c && survey.DistrictPartsServiceManager__c != null) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.DistrictPartsServiceManager__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.DistrictPartsServiceManager__c);
                    }
                    else {
                        apexSharing.add(survey, survey.DistrictPartsServiceManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
            }
            if(survey.OwnerId != survey.DistrictSalesManager__c && survey.DistrictSalesManager__c != null) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.DistrictSalesManager__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.DistrictSalesManager__c);
                    }
                    else {
                        apexSharing.add(survey, survey.DistrictSalesManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
            }
            if(survey.OwnerId != survey.MarketManager__c && survey.MarketManager__c != null) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.MarketManager__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.MarketManager__c);
                    }
                    else {
                        apexSharing.add(survey, survey.MarketManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
            }
            if(survey.OwnerId != survey.GenesisAreaManager__c && survey.GenesisAreaManager__c != null) {
                if(existingSharesMap.containsKey(survey.Id)) {
                    if(existingSharesMap.get(survey.Id).containsKey(survey.GenesisAreaManager__c)) {
                        existingSharesMap.get(survey.Id).remove(survey.GenesisAreaManager__c);
                    }
                    else {
                        apexSharing.add(survey, survey.GenesisAreaManager__c, 'Edit', Schema.Survey__Share.RowCause.Survey_Sharing__c);
                    }
                }
            }
        }

        apexSharing.share();

        if(!existingSharesMap.keySet().isEmpty()) {
            for(Id surveyId:existingSharesMap.keySet()) {
                if(!existingSharesMap.get(surveyId).keySet().isEmpty()) {
                    for(String groupDeveloperName:existingSharesMap.get(surveyId).keySet()) {
                        Survey__Share shareToRemove = (Survey__Share) existingSharesMap.get(surveyId).get(groupDeveloperName);
                        apexSharing.remove(new Survey__c(Id = surveyId), shareToRemove.UserOrGroupId, shareToRemove.AccessLevel, Schema.Survey__Share.RowCause.Survey_Sharing__c);
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

     /**
     * [Method Description] 
     * Created by [Author] on [Date] for [Ticket #]
     * Edited by [MinheeKim] on [2024-03-20] for [DPM-5426] Added parameter Map<Id, Map<String, SObject>> existingSharesMap to reduce the queries 
    */
    public static void createSurveyDealerSharing(Map<Id, Survey__c> newSurveyMap, Map<Id, Map<String, SObject>> existingSharesMap ) { //DPM-5426 added Map<Id, Map<String, SObject>> existingSharesMap by MinheeKim - 24.03.19

        Map<Id, List<Survey__c>> accountSurveyMap = new  Map<Id, List<Survey__c>>();

        for(Survey__c survey:newSurveyMap.values()) {
            if(!accountSurveyMap.containsKey(survey.Dealer__c)) {
                accountSurveyMap.put(survey.Dealer__c, new List<Survey__c>());
            }
            accountSurveyMap.get(survey.Dealer__c).add(survey);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>([select Id, DealerCode__c from Account where Id in :accountSurveyMap.keyset()]);
        Map<Id, List<User>> accountUserMap = getAccountContactsMap(accountSurveyMap.keySet());
        Map<String, ObjectAccess__mdt> surveyAccessTypes = getObjectAccessMapSurveys();
        Map<String, AccessType__mdt> accessTypesMap = getAccessTypeMap();

        System.debug(LoggingLevel.ERROR, 'DPM_Survey_Edit ' + surveyAccessTypes.get('DPM_Survey_Edit'));
        HMAApexSharing apexSharing = new HMAApexSharing('Survey__Share');

        // Map<Id, Map<String, SObject>> existingSharesMap = apexSharing.getExistingSharesForObject(newSurveyMap.values(), Schema.Survey__Share.RowCause.Dealer_Survey_Sharing__c);

        for(Survey__c survey:newSurveyMap.values()) {
            System.debug(LoggingLevel.ERROR, survey);
            System.debug(LoggingLevel.ERROR, accountMap);
            Account surveyAccount = accountMap.get(survey.Dealer__c);
            //System.debug(LoggingLevel.ERROR, surveyAccount);
            //System.debug(LoggingLevel.ERROR, surveyAccount.DealerCode__c);
            if(surveyAccount != null) {
                if(accountUserMap.containsKey( survey.Dealer__c)) {
                    System.debug(LoggingLevel.ERROR, 'Dealer: ' + survey.Dealer__c);
                    for(User dealerUser:accountUserMap.get(survey.Dealer__c)) {
                        Boolean processed = false;
                        System.debug(LoggingLevel.ERROR, 'Dealer User: ' + dealerUser);
                        if(dealerUser.AccessTypes__c != null) {
                            for(String accessType:dealerUser.AccessTypes__c.split(',')) {
                                System.debug(LoggingLevel.ERROR, 'Access Type: ' + accessType);

                                if(accessType.contains('/') && accessType.contains(surveyAccount.DealerCode__c)) {
                                    String[] dealerAccessType = accessType.split('/');
                                    System.debug(LoggingLevel.ERROR, dealerAccessType[0]);
                                    System.debug(LoggingLevel.ERROR, surveyAccessTypes);

                                    if(accessTypesMap.containsKey(dealerAccessType[0])) {
                                        String objectAccessAPINames = accessTypesMap.get(dealerAccessType[0]).ObjectAccessAPINames__c;
                                        if(!String.isBlank(objectAccessAPINames)) {
                                            for(String objectAccessAPIName:objectAccessAPINames.split(',')) {
                                                if(surveyAccessTypes.containsKey(objectAccessAPIName)){
                                                    if(existingSharesMap.containsKey(survey.Id)) {
                                                        if(existingSharesMap.get(survey.Id).containsKey(dealerUser.Id)) {
                                                            existingSharesMap.get(survey.Id).remove(dealerUser.Id);
                                                            processed = true;
                                                            break;
                                                        }
                                                    }
                                                    //System.debug(LoggingLevel.ERROR, 'Adding Sharing');
                                                    //apexSharing.add(survey, dealerUser.Id, surveyAccessTypes.get(objectAccessAPIName).AccessLevel__c, Schema.Survey__Share.RowCause.Dealer_Survey_Sharing__c);
                                                    apexSharing.add(survey, dealerUser.Id, surveyAccessTypes.get(objectAccessAPIName).AccessLevel__c, Schema.Survey__Share.RowCause.Dealer_Survey_Sharing__c);
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
        }
        apexSharing.share();
    }

    private static Map<String, ObjectAccess__mdt> getObjectAccessMapSurveys() {

        Map<String, ObjectAccess__mdt> objectAccessMap = new Map<String, ObjectAccess__mdt>();
        for(ObjectAccess__mdt objectAccess:[select Id, AccessLevel__c, ObjectAPINames__c, DeveloperName from ObjectAccess__mdt where Active__c = true]) {
            if(objectAccess.ObjectAPINames__c.contains('Survey__c')) {
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

        for(User user:[select Name, Id, AccountId, Account.DealerCode__c, ContactId, AccessTypes__c from User where IsActive = true and ContactId in :mapContactIdsToAccountIdsList.keySet()]) {
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