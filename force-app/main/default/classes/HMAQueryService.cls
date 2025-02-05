public without sharing class HMAQueryService {
    
    public static Map<String, Id> getPublicGroupMapByDeveloperName() {
        Map<String, Id> mapPublicGroups = new Map<String, Id>();

        for(Group publicGroup:[select Id, DeveloperName from Group]) { //DPM-5400 Deleted Limit 1 
            mapPublicGroups.put(publicGroup.DeveloperName, publicGroup.Id); 
        }
        system.debug('getQueries HMAQueryService 9: '+Limits.getQueries());
        return mapPublicGroups;
    }

    public static Map<Id, String> getPublicGroupMapById(Set<Id> publicGroupsIds) {
        Map<Id, String> mapPublicGroups = new Map<Id, String>();

        for(Group publicGroup:[select Id, DeveloperName from Group where Id in :publicGroupsIds]) {
            mapPublicGroups.put(publicGroup.Id, publicGroup.DeveloperName);
        }
        system.debug('getQueries HMAQueryService 16: '+Limits.getQueries());
        return mapPublicGroups;
    }

  /*
  This method commented by neeraj sharma for ticket number 3453
public static Map<Id, List<AreasRegion__c>> getAreaRegionsForGenesisAreas(List<Id> genesisAreas) {
        
        Map<Id, List<AreasRegion__c>> areaRegionMap = new Map<Id, List<AreasRegion__c>>();
        for(AreasRegion__c areaRegion:[select Id, Region__r.Name, Region__r.RegionCode__c, GenesisArea__c from AreasRegion__c where GenesisArea__c in :genesisAreas]) {
            if(!areaRegionMap.containsKey(areaRegion.GenesisArea__c)) {
                areaRegionMap.put(areaRegion.GenesisArea__c, new List<AreasRegion__c>());
            }
            areaRegionMap.get(areaRegion.GenesisArea__c).add(areaRegion);
        }

        return areaRegionMap;
    }*/

    public static Map<String, List<ObjectAccess__mdt>> getObjectAccessTypes(String level, String objectType, List<String> levelCodes) {

        Map<String, List<ObjectAccess__mdt>> objectAccessMap = new Map<String, List<ObjectAccess__mdt>>();

        String keyField = '';
        String sql = '';

        String mainSql = 'select DistrictCode__c,OrganizationName__c, RegionCode__c, MarketCode__c, AccessLevel__c, PublicGroups__c, ObjectAPINames__c from ObjectAccess__mdt ';
        mainSql += 'where Active__c = true ';

        if(level == 'Region') {
            sql = mainSql + ' and RegionCode__c in :levelCodes';
            keyField = 'RegionCode__c';
        }
        else if(level == 'District') { 
            sql = mainSql + ' and DistrictCode__c in :levelCodes';
            keyField = 'DistrictCode__c';
        }
        else if(level == 'Market') {
            sql = mainSql + ' and MarketCode__c in :levelCodes';
            keyField = 'MarketCode__c';
        }

        System.debug(LoggingLevel.ERROR, sql);

        for(ObjectAccess__mdt objectAccess:Database.query(sql)) {
            System.debug(LoggingLevel.ERROR, objectAccess.ObjectAPINames__c);
            System.debug(LoggingLevel.ERROR, objectAccess);
            if(objectAccess.ObjectAPINames__c != null && objectAccess.ObjectAPINames__c.contains(objectType)) {
                String keyValue = (String)objectAccess.get(keyField);
                if(!objectAccessMap.containsKey(keyValue)) {
                    objectAccessMap.put(keyValue, new List<ObjectAccess__mdt>());
                }
                objectAccessMap.get(keyValue).add(objectAccess);
            }
        }system.debug('getQueries HMAQueryService 63: '+Limits.getQueries());
        return objectAccessMap;
    }


    public static Map<Id, Account> getAccountMapFromSetOfAccountIds(Set<Id> accountIds) {
        return new Map<Id, Account>([select Id,
                                            Name,
                                            DealerCode__c,
                                            Organization__c,                                
                                            Organization__r.Name, 
                                            Region__c, 
                                            Region__r.Name, 
                                            Region__r.RegionCode__c,
                                            ServiceDistrict__c,
                                            ServiceDistrict__r.Name,
                                            ServiceDistrict__r.DistrictCode__c,
                                            ServiceDistrict__r.DistrictPartsServiceManager__c,
                                            ServiceDistrict__r.DistrictPartsServiceManagerAlt__c,
                                            ServiceDistrict__r.DistrictPartsServiceManager__r.isactive,
                                            SalesDistrict__c,
                                            SalesDistrict__r.Name,
                                            SalesDistrict__r.DistrictCode__c,
                                            SalesDistrict__r.SalesManager__c,
                                            SalesDistrict__r.DistrictSalesManagerAlt__c,
                                            SalesDistrict__r.SalesManager__r.isactive,
                                            Market__c,
                                            Market__r.Name,
                                            Market__r.DistrictCode__c,
                                     		Market__r.Aftersales_Market_Manager__c,
                                            Market__r.MarketManager__c,
                                            Market__r.GenesisMarketManagerAlt__c,
                                            Market__r.MarketManager__r.isactive,
                                            Market__r.Aftersales_Market_Manager__r.isactive,
                                            /* commented by Neeraj sharma 
                                            GenesisArea__c,
                                            GenesisArea__r.AreaCode__c,
                                            GenesisArea__r.Name,
                                            GenesisArea__r.GenesisAreaManager__c,*/
                                            RecordType.DeveloperName,
                                            GeneralManager__c, 
                                            DealerPrincipal__c,
                                            DistrictManager__c,DistrictManagerAlt__c
                                            /*
                                            GenesisAreaManager__c*/
                                    from Account 
                                    where Id in :accountIds]);
    }
}