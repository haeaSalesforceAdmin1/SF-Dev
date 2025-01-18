public without sharing class HMATopicService {
 
    public class LevelWrapper {

        public String level;
        public List<Account> accounts; 
        public List<User> users;

        public LevelWrapper() {
            accounts = new List<Account>();
            users = new List<User>();
        }
    }

    public static Map<String, LevelWrapper> getLevelWrapperMapsFromTopics(List<Topic__c> topics) {

        Map<String, LevelWrapper> wrappersByType = new Map<String, LevelWrapper>();

        List<String> organizations = new List<String>();
        List<String> regions = new List<String>();
        List<String> salesDistricts = new List<String>();
        List<String> serviceDistricts = new List<String>();
        List<String> accounts = new List<String>();
        List<String> markets = new List<String>();
        List<String> genArea = new List<String>();
        List<String> hyundaiArea = new List<String>();
        List<String> genesisArea = new List<String>();
        List<String> dealerCodes = new List<String>();

        for(Topic__c topic:topics) {
            if(topic.CreateRecordsFor__c == 'List of Dealer Codes' && topic.DealerCodes__c != null) {
                dealerCodes = topic.DealerCodes__c.split(',');
            }
            else if(topic.Organization__c != null) {
                organizations.add(topic.Organization__c);
                if(topic.Region__c != null) {
                regions.add(topic.Region__c);
            }
            }
            else if(topic.Region__c != null) {
                regions.add(topic.Region__c);
            }
            else if(topic.SalesDistrict__c != null) {
                salesDistricts.add(topic.SalesDistrict__c);
            }
            else if(topic.ServiceDistrict__c != null) {
                serviceDistricts.add(topic.ServiceDistrict__c);
            }
            else if(topic.Account__c != null) {
                accounts.add(topic.Account__c);
            }
            else if(topic.HyundaiArea__c != null) {
                hyundaiArea.add(topic.HyundaiArea__c);
            }
           /*  following line is commented by Neeraj for ticket number 3521, 

            *  else if(topic.GenesisArea__c != null) {
                genesisArea.add(topic.GenesisArea__c);
            }*/
            else if(topic.Market__c != null) {
                genesisArea.add(topic.Market__c);
            }
        }

        if(!dealerCodes.isEmpty()) {
            wrappersByType.putAll(getWrappersByType(dealerCodes, 'dealercodes',null));
        }
        if(!organizations.isEmpty()) {
            if(!regions.isEmpty()) {
            wrappersByType.putAll(getWrappersByType(organizations, 'organization',regions));
        }
            else
            {      wrappersByType.putAll(getWrappersByType(organizations, 'organization',null));}
        }

        if(!regions.isEmpty()) {
            wrappersByType.putAll(getWrappersByType(regions, 'region',null));
        }

        if(!salesDistricts.isEmpty()) {
            wrappersByType.putAll(getWrappersByType(salesDistricts, 'salesDistrict',null));
        }

        if(!serviceDistricts.isEmpty()) {
            wrappersByType.putAll(getWrappersByType(serviceDistricts, 'serviceDistrict',null));
        }

        if(!accounts.isEmpty()) {
            wrappersByType.putAll(getWrappersByType(accounts, 'account',null));
        }

        if(!accounts.isEmpty()) {
            wrappersByType.putAll(getWrappersByType(accounts, 'genesis',null));
        }

        if(!accounts.isEmpty()) {
            wrappersByType.putAll(getWrappersByType(accounts, 'hyundai',null));
        }

        if(!accounts.isEmpty()) {
            wrappersByType.putAll(getWrappersByType(accounts, 'market',null));
        }
        
        return wrappersByType;
    }

    public static Map<String, LevelWrapper> getWrappersByType(List<String> groupings, String type,List<String> region) {
        
        System.debug(LoggingLevel.ERROR, groupings);
        System.debug(LoggingLevel.ERROR, type);

        Map<String, LevelWrapper> wrappersByType = new Map<String, LevelWrapper>();

        //DPM-5633 added BrandCode__c
        String accountSql = 'select Id, Name, Organization__c, Organization__r.Name, ';
        accountSql += ' Region__c, RegionCodePicklist__c, ';
        accountSql += ' SalesDistrict__c, SalesDistrict__r.DistrictCode__c, SalesDistrict__r.Name, SalesDistrictCode__c, DistrictSalesManager__c, SalesDistrict__r.SalesManager__c, ';
        accountSql += ' ServiceDistrict__c, ServiceDistrict__r.Name, DistrictPartsServiceManager__c, ServiceDistrict__r.DistrictCode__c, ';
        accountSql += ' Market__c, MarketCodeGenesisPicklist__c,  MarketManager__c, Aftersales_Market_Manager__c, DealerCode__c, DistrictManagerAlt__c,DistrictSalesManagerAlt__c,DistrictPartsServiceManagerAlt__c,GenesisMarketManagerAlt__c, ';
                   /*  following line is commented by Neeraj for ticket number 3521,  */

        //accountSql += ' HyundaiArea__c, GenesisArea__c, GenesisAreaCodePicklist__c, GenesisAreaManager__c, GenesisArea__r.Name, DistrictManager__c,';
        accountSql += ' HyundaiArea__c,  DistrictManager__c,';
        accountSql += ' DealerPrincipal__c, GeneralManager__c  ';
        accountSql += ' ,BrandCode__c, GBX_Score__c,  GSX_Score__c ';
        accountSql += 'from Account where IsTerminated__c = false ';

        if(type=='dealercodes') {
            accountSql += ' and DealerCode__c in :groupings';
        }
        else if(type == 'organization') {
            if(region!=null){
                 accountSql += ' and Region__c in :region';
            }
            accountSql += ' and Organization__c in :groupings';
        }
        else if(type == 'region') {
            accountSql += ' and Region__c in :groupings';
        }
        else if(type == 'serviceDistrict') {
            accountSql += ' and ServiceDistrict__c in :groupings';
        }
        else if(type == 'salesDistrict') {
            accountSql += ' and SalesDistrict__c in :groupings';
        }
        else if(type == 'account') {
            accountSql += ' and Id in :groupings';
        }
        else if(type == 'market') {
            accountSql += ' and Market__c in :groupings';
        }
                          

        else if(type == 'genesis') {
             /*  following line is commented by Neeraj for ticket number 3521,  
            accountSql += ' and GenesisArea__c in :groupings';
*/
        }
        else if(type == 'hyundai') {
            accountSql += ' and HyundaiArea__c in :groupings';
        }

        System.debug(LoggingLevel.ERROR, Database.query(accountSql));
        System.debug(LoggingLevel.ERROR, accountSql);
        System.debug(LoggingLevel.ERROR, groupings);
        for(Account account:Database.query(accountSql)) {
            String key = '';
            if(type == 'dealercodes') {
                key = 'dealercodes';
            }
            if(type == 'organization') {
                key = account.Organization__c;
            }
            else if(type == 'region') {
                key = account.Region__c;
            }
            else if(type == 'salesDistrict') {
                key = account.SalesDistrict__c;
            }
            else if(type == 'serviceDistrict') {
                key = account.ServiceDistrict__c;
            }
            else if(type == 'account') {
                key = account.Id;
            }
            else if(type == 'market') {
                key = account.Market__c;
            }
            else if(type == 'genesis') {
                /*  following line is commented by Neeraj for ticket number 3521,  */
                
                // key = account.GenesisArea__c;
            }
            else if(type == 'hyundai') {
                key = account.HyundaiArea__c;
            }
            //System.debug(LoggingLevel.ERROR, key);
            if(!wrappersByType.containsKey(key)) {
                wrappersByType.put(key, new LevelWrapper());
            }
            wrappersByType.get(key).accounts.add(account);
        }
        return wrappersByType;
    }

    public static String getKeyFromTopic(Topic__c topic) {

        if(topic.DealerCodes__c != null) {
            return 'dealercodes';
        }
        if(topic.Organization__c != null) {
            return topic.Organization__c;
        }
        if(topic.Region__c != null) {
            return topic.Region__c;
        }
        if(topic.ServiceDistrict__c != null) {
            return topic.ServiceDistrict__c;
        }
        if(topic.SalesDistrict__c != null) {
            return topic.SalesDistrict__c;
        }
        if(topic.Account__c != null) {
            return topic.Account__c;
        }
         /*  following line is commented by Neeraj for ticket number 3521,  
        if(topic.GenesisArea__c != null) {
            return topic.GenesisArea__c;
        }*/
        if(topic.HyundaiArea__c != null) {
            return topic.HyundaiArea__c;
        }
        if(topic.Market__c != null) {
            return topic.Market__c;
        }
        return null;
    }

    public static RecordGeneration__mdt getRecordMappingSettingsForType(String topicType) {

        List<RecordGeneration__mdt> listOfRecordGenerations = [select Id, DeveloperName, TargetObject__c from RecordGeneration__mdt where TriggerFieldValue__c = :topicType and Active__c = true];

        if(listOfRecordGenerations.isEmpty()) {
            return null;
        }
        return listOfRecordGenerations[0];
    }

    public static List<RecordMapping__mdt> getRecordMappingSettingsFromRecordMappingDeveloperName(String developerName) {
        return [select Id, SourceFieldAPIName__c, TargetFieldAPIName__c from RecordMapping__mdt where DPMRecordGeneration__r.DeveloperName = :developerName and Active__c = true];
    }

    public static Date calculateEndDate(Topic__c topic) {

        Date today = Date.today();
        if(topic.CalendarType__c == 'HMA Calendar' || topic.Reoccurence__c == 'Run Once') {

            List<String> hmaCustomSettingStartFields = new List<String>{'Q1StartDateThisYear__c','Q2StartDateThisYear__c','Q3StartDateThisYear__c','Q4StartDateThisYear__c','Q1StartDateNextYear__c' };
            List<String> hmaCustomSettingEndFields = new List<String>{'Q1EndDateThisYear__c','Q2EndDateThisYear__c','Q3EndDateThisYear__c','Q4EndDateThisYear__c','Q1EndDateNextYear__c' };            
            
            HMACalendarQuarters__c calendarQuarters = HMACalendarQuarters__c.getInstance();

            List<Date> quarterEndDates = new List<Date>();

            for(String customSettingEndDateField:hmaCustomSettingEndFields) {
                quarterEndDates.add((Date)calendarQuarters.get(customSettingEndDateField));
            }
            quarterEndDates.sort();

            for(Date quarterEndDate:quarterEndDates) {
                if(quarterEndDate >= today) {
                    return quarterEndDate;
                }
            }
        }
        else {
            Integer monthsToAdd = monthsToAdd(topic.Reoccurence__c);
            return today.addMonths(monthsToAdd).addDays(-1);
        }
        return null;
    }

    public static Date calculateNextRunDate(Topic__c topic) {

        Date today = Date.today();
        if(topic.CalendarType__c == 'HMA Calendar') {
            System.debug(LoggingLevel.ERROR, 'HMA Calendar');
            Set<String> hmaCustomSettingFIelds = new Set<String>{'Q1StartDateThisYear__c','Q2StartDateThisYear__c','Q3StartDateThisYear__c','Q4StartDateThisYear__c','Q1StartDateNextYear__c' };
            
            Date comparisonDate;
            
            HMACalendarQuarters__c calendarQuarters = HMACalendarQuarters__c.getInstance();
            if(topic.LastRunDate__c == null && topic.Topic_Start_Date__c >= today) {
                comparisonDate = topic.Topic_Start_Date__c;
            }
            else if(topic.LastRunDate__c == null && topic.Topic_Start_Date__c < today) {
                comparisonDate = today;
            }
            else if(topic.LastRunDate__c != null) {
                comparisonDate = topic.LastRunDate__c;
            }
            System.debug(LoggingLevel.ERROR, 'HMA Calendar ' + comparisonDate);

            for(String quarter:hmaCustomSettingFIelds) {
                System.debug(LoggingLevel.ERROR, 'HMA Calendar ' + (Date)calendarQuarters.get(quarter));
                if((Date)calendarQuarters.get(quarter) >= comparisonDate) {

                    return (Date) calendarQuarters.get(quarter);
                }
            }
        }
        else {
            Integer monthsToAdd = monthsToAdd(topic.Reoccurence__c);
    
            if(topic.LastRunDate__c == null && topic.Topic_Start_Date__c >= today) {
                return topic.Topic_Start_Date__c;
            }
            else if(topic.LastRunDate__c != null) {
                return topic.LastRunDate__c.addMonths(monthsToAdd);
            }
            else if(topic.Topic_Start_Date__c < today) {
                return topic.Topic_Start_Date__c.addMonths(monthsToAdd);
            }
        }
        return null;    
    }

    public static Integer monthsToAdd(String reoccurence) {

        if(reoccurence == 'Monthly') {
            return 1;
        }
        if(reoccurence == 'Quarterly') {
            return 3;
        }
        if(reoccurence == 'Annually') {
            return 12;
        }
        return 0;
    }

    public static List<Topic__c> getTopicDetailsFromTopicsAndMappings(List<Topic__c> topics, List<List<RecordMapping__mdt>> recordMappingsList) {

        List<Topic__c> topicsWithDetails = new List<Topic__c>();
        Set<String> sourceFields = new Set<String>();
        for(List<RecordMapping__mdt> listOfMappings:recordMappingsList) {
            for(RecordMapping__mdt recordMapping:listOfMappings) {
                if(recordMapping.SourceFieldAPIName__c != null) {
                    sourceFields.add(recordMapping.SourceFieldAPIName__c);
                }
            }
        }

        String queryFields = ' Id,JDP_Evaluation__c, Name, Type__c, Division__c, Region__c, HyundaiArea__c, ServiceDistrict__c, Account__c, SalesDistrict__c, Market__c, HMASurvey__c, ';
        
		queryFields += 'Organization__c, TopicOwner__c, CreateEvaluation__c, CalendarType__c, Reoccurence__c, CreateRecordsFor__c, DealerCodes__c,  ';
        queryFields += 'Topic_Start_Date__c, Topic_End_Date__c, HMASurvey__r.RecordType.DeveloperName, HMASurvey__r.RecordTypeId, ';
        //DPM-5062 added by MH - 10/19/2023
        queryFields += 'HMASurvey__r.DueDate__c,  HMASurvey__r.EndDate__c ';
        
        for(String sourceField:sourceFields) {
            if(!queryFields.contains(sourceField)) {
                queryFields += (queryFields == '' ? '' : ',') + sourceField;
            }
        }

        String query = 'select ' + queryFields + ' from Topic__c where Id in :topics';
        System.debug('query'+ query);
        List<Topic__c> topicsToReturn = Database.query(query);

        return topicsToReturn;
    }

    public static void updateRunDateForTopics(List<Topic__c> topics) {
        for(Topic__c topic:topics) {
            topic.LastRunDate__c = Date.today();
        }
        update topics;
    }   

    public static Id getTopicOwnerFromAccount(Topic__c topic, Account account, Id principalUserId, Id generalManagerId) {
     /*  following line is commented by Neeraj for ticket number 3521,  

        if(topic.TopicOwner__c == 'Genesis Area Manager' && account.GenesisAreaManager__c != null) {
            return account.GenesisAreaManager__c;
        }*/
         if(topic.TopicOwner__c == 'District Parts Service Manager' && account.DistrictPartsServiceManager__c != null) {
            return account.DistrictPartsServiceManager__c;
        }
       /*else if(topic.TopicOwner__c == 'District Parts Service Manager' && account.DistrictPartsServiceManagerAlt__c != null) {
            return account.DistrictPartsServiceManagerAlt__c;
        }*/
        else if(topic.TopicOwner__c == 'District Sales Manager' && account.DistrictSalesManager__c != null) {
            return account.DistrictSalesManager__c;
        }
       /* else if(topic.TopicOwner__c == 'District Sales Manager' && account.DistrictSalesManagerAlt__c != null) {
            return account.DistrictSalesManagerAlt__c;
        }*/
        else if(topic.TopicOwner__c == 'Dealer Principal' && principalUserId != null) {
            return principalUserId;
        }
        else if(topic.TopicOwner__c == 'General Manager' && generalManagerId != null) {
            return generalManagerId;
        }
        else if(topic.TopicOwner__c == 'District Manager' && account.DistrictManager__c != null) {
            return account.DistrictManager__c;
        }
        /*else if(topic.TopicOwner__c == 'District Manager' && account.DistrictManagerAlt__c != null) {
            return account.DistrictManagerAlt__c;
        }*/
        //else if(topic.TopicOwner__c == 'District Parts Service Manager' || topic.TopicOwner__c == 'Dealer Principal' || topic.TopicOwner__c == 'General Manager' && account.DistrictSalesManager__c != null) {
        //    return account.DistrictSalesManager__c;
        //}
        /*else if(topic.TopicOwner__c == 'Hyundai Area Manager' && account.DistrictSalesManager__c != null) {

        }*/
        else if(topic.TopicOwner__c == 'Market Manager' && account.MarketManager__c != null && topic.Division__c == 'Sales') {
            return account.MarketManager__c;
        }
        else if(topic.TopicOwner__c == 'Market Manager' && account.GenesisMarketManagerAlt__c != null && topic.Division__c == 'Sales') {
            return account.GenesisMarketManagerAlt__c;
        }
        else if(topic.TopicOwner__c == 'Aftersales Market Manager' && account.Aftersales_Market_Manager__c != null && topic.Division__c == 'Service') { // DPM-4188
            return account.Aftersales_Market_Manager__c;
        }
        
        //else if(topic.TopicOwner__c == 'Market Manager' && account.MarketManager__c == null && account.GenesisAreaManager__c != null) {
        //    return account.GenesisAreaManager__c;
        //}
        /*else if(topic.TopicOwner__c == 'Region Manager') {

        }*/
       /* List<User> workflowAdminUsers = [select Id from User where UserName like 'sfworkflowadmin%' limit 1];
        if(!workflowAdminUsers.isEmpty()) {
            return workflowAdminUsers[0].Id;
        }*/
       
        return UserInfo.getUserId();
    }

    public static Map<Id, Id> getContactUserMapFromLevelWrapper(List<LevelWrapper> levelWrappers) {

        Set<Id> contactIds = new Set<Id>();
        Map<Id, Id> contactUserMap = new Map<Id, Id>();

        for(LevelWrapper levelWrapper:levelWrappers) {
            for(Account account:levelWrapper.accounts) {
                if(account.DealerPrincipal__c != null) {
                    contactIds.add(account.DealerPrincipal__c);
                }
                if(account.GeneralManager__c != null) {
                    contactIds.add(account.GeneralManager__c);
                }
            }
        }

        for(User user:[select Id, ContactId from User where ContactId in :contactIds]) {
            contactUserMap.put(user.ContactId, user.Id); 
        }        

        return contactUserMap;
    }
    
}