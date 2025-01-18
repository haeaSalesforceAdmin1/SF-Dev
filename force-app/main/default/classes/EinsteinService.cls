public without sharing class EinsteinService {


    public static String getCurrentRunSAQLFieldValue(EinsteinKPI__c einsteinKPI, Integer currentSAQL) {

        String field = 'KPI_SAQL_' + String.valueOf(currentSAQL) + '__c';

        return (String)einsteinKPI.get(field);

    }

    public static String getCurrentRunLevelFieldValue(EinsteinKPI__c einsteinKPI, Integer currentSAQL) {
        String field = 'KPI_Level_' + String.valueOf(currentSAQL) + '__c';

        return (String)einsteinKPI.get(field);
    }

    public static String getCurrentRunLookupKeyFieldValue(EinsteinKPI__c einsteinKPI, Integer currentSAQL) {
        String field = 'KPILookupKey' + String.valueOf(currentSAQL) + '__c';

        return (String)einsteinKPI.get(field);
    }

    public static List<Object> retrieveQueryResultRecords(String query) {
// 202307
        ConnectApi.LiteralJson queryresult;
        if(!Test.isRunningTest()) {
            queryresult = ConnectApi.Wave.executeQuery(query);
        }
        else {
            queryresult = new ConnectApi.LiteralJson();
            queryresult.json = TestUtility.getConnectAPIJsonString();
        }

        String queryResponse = queryresult.json;
        System.debug('#####queryResponse: '+queryResponse);
        Map<String, Object> objectResult = (Map<String, Object>) JSON.deserializeUntyped(queryResponse);
        //System.debug(LoggingLevel.ERROR, objectResult);
        Map<String, Object> results = (Map<String, Object>)objectResult.get('results');
        //System.debug(LoggingLevel.ERROR, results);
        List<Object> records = (List<Object>)results.get('records');
        System.debug(LoggingLevel.ERROR, records);
        return records;
    }

    public static Map<String, DatasetResult> getDataSetsLatestVersions() {

        Map<String, DatasetResult> resultsMap = new Map<String, DatasetResult>();
        HttpRequest req = new HttpRequest();
        // req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v54.0/wave/folders?pageSize=200');
        
        //DPM-5049 : edited by MinheeKim
        // req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v54.0/wave/datasets?pageSize=200&folder​Id=00l6g000000r9ozAAA');
        req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v54.0/wave/datasets?pageSize=200&sort=CreatedDate&order=Ascending');
        
        //req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v54.0/wave/datasets');
        req.setMethod('GET');

        String autho = 'Bearer '+UserInfo.getSessionId();
        req.setHeader('Authorization', autho);
        req.setHeader('Content-type','application/json');
        req.setHeader('Accept','application/json');

        Http http = new Http();
        HTTPresponse res= http.send(req);
        String response = res.getBody();

        System.debug(LoggingLevel.ERROR, response);

        DataSetResults dataSetResults = (DataSetResults)JSON.deserialize(response, DataSetResults.class);
        String labels = '';
        for(DataSetResult datasetResult:dataSetResults.datasets) {
            System.debug(datasetResult);
            resultsMap.put(datasetResult.label, datasetResult);
            System.debug(LoggingLevel.ERROR, datasetResult);
            labels=labels+','+datasetResult.label;
        }
        System.debug(LoggingLevel.ERROR, labels);
        System.debug(LoggingLevel.ERROR, resultsMap);

        return resultsMap;
    }

    public static String buildSAQLQueryForLatestVersion(String saqlQuery, Map<String, DataSetResult> dataSetResultMap) {

        String [] queryLines = saqlQuery.split(';');
        String query = '';
        for(String queryLine:queryLines) {

            if(queryLine.contains('= load "')) {
                System.debug(LoggingLevel.ERROR, 'matched');
                String dataset = queryLine.substringBetween('"', '"');
                System.debug(dataset);
                // SalesKPI
                DatasetResult dataSetCurrentVersion = dataSetResultMap.get(dataset);

                System.debug(LoggingLevel.ERROR, queryLine);
                System.debug(LoggingLevel.ERROR, dataset);
                System.debug(LoggingLevel.ERROR, dataSetCurrentVersion);

                // SalesKPI,
                queryLine = queryLine.replaceAll(dataset, dataSetCurrentVersion.id + '/' +  dataSetCurrentVersion.currentVersionId);
                System.debug(LoggingLevel.ERROR, queryLine);
            }
            query += queryLine + ';';
        }
        return query;
    }

    public static Map<String, List<EinsteinKPIMapping__c>> getKPIFieldMappings(Set<String> einsteinKPI, Integer currentSAQL) {
        Map<String, List<EinsteinKPIMapping__c>> fieldsMappings = new Map<String, List<EinsteinKPIMapping__c>>();

        String mappedSAQL = currentSAQL != null ? 'KPI_SAQL_' + String.valueOf(currentSAQL) + '__c' : null;

        String query = 'select Id, IncludeLabelInKeyValue__c, MultiplyBy100ForPercent__c, Einstein_KPI__c, KPI_Field__c, KPIFieldDescription__c, Object_Field__c, Type__c, Actual__c, Objective__c, Key_Value__c,Show_fields_when_data_not_available__c from EinsteinKPIMapping__c ';
        query += ' where Einstein_KPI__c = :einsteinKPI ';
        if(mappedSAQL != null) {
            query += ' and MappedSAQL__c = :mappedSAQL ';
        }

        for(EinsteinKPIMapping__c mapping:Database.query(query)) {
            if(!fieldsMappings.containsKey(mapping.Einstein_KPI__c)) {
                fieldsMappings.put(mapping.Einstein_KPI__c, new List<EinsteinKPIMapping__c>());
            }
            fieldsMappings.get(mapping.Einstein_KPI__c).add(mapping);
        }

        return fieldsMappings;
    }

    public static Map<String, List<SObject>> getLookupKeyAccountMap(Set<String> lookupKeys, String kpiLevel) {

        Map<String, List<SObject>> lookupKeyObjectMap = new Map<String, List<SObject>>();
        String keyFieldAPI;

        String query = '';
        if(kpiLevel == 'Dealer') {
            query += 'select Id, Name, DealerCode__c, ServiceDistrictCodePicklist__c, RegionCodePicklist__c, SalesDistrictCode__c  from Account ';
            query += 'where DealerCode__c in :lookupKeys';
            keyFieldAPI = 'DealerCode__c';
        }
        else if(kpiLevel == 'Region') {
            query += 'select Id, Name, RegionCode__c from Region__c ';
            query += 'where RegionCode__c in :lookupKeys';
            keyFieldAPI = 'RegionCode__c';
        }
        else if(kpiLevel == 'Sales District' || kpiLevel == 'Service District') {
            query += 'select Id, Name, DistrictCode__c from District__c ';
            query += 'where DistrictCode__c in :lookupKeys';
            keyFieldAPI = 'DistrictCode__c';
        }

        for(SObject objectRecord:Database.query(query)) {
            String keyValue = (String)objectRecord.get(keyFieldAPI);
            if(!lookupKeyObjectMap.containsKey(keyValue)) {
                lookupKeyObjectMap.put(keyValue, new List<SObject>());
            }
            lookupKeyObjectMap.get(keyValue).add(objectRecord);
        }
        return lookupKeyObjectMap;
    }

    public static Boolean checkThreshold(Decimal actual, Decimal objective, String comparator) {
        Boolean breachedThreshold = false;

        if(actual != null && objective != null) {
            if(comparator == 'less than') {
                breachedThreshold = (actual < objective);
            }
            else if(comparator == 'less than or equal to') {
                breachedThreshold = (actual <= objective);
            }
            else if(comparator == 'greater than') {
                breachedThreshold = (actual > objective);
            }
            else if(comparator == 'greater than or equal to') {
                breachedThreshold = (actual >= objective);
            }
            else {
                breachedThreshold = (actual == objective);
            }
        }
        return breachedThreshold;
    }

    public static Map<Id, Map<Id, List<KPIThreshold__c>>> getThresholdsForKPI(Set<String> kpiIds, String level) {

        Map<Id, Map<Id, List<KPIThreshold__c>>> thresholdMap = new Map<Id, Map<Id, List<KPIThreshold__c>>>();
        Date today = Date.today();
        String thresholdKey = '';

        //[DPM-4995] Excluded String Type of EinsteinKPIMapping__r.Type__c
        List<String> type = new List<String>();
        type.add('Text');
        type.add('Defined');

        String query = 'select Id, Account__c, Region__c, Organization__c, District__c, KPI__c, AnalyticThreshold__c, AbsoluteValueNumber__c, ThresholdField__c, AbsoluteValuePercentage__c, ';
        query += ' AcceptableVariance__c, AcceptableVariancePercent__c, ActualObjectiveComparator__c,';
        query += ' EinsteinKPIMapping__r.Object_Field__c, EinsteinKPIMapping__r.Type__c, EinsteinKPIObjectiveMapping__c, EinsteinKPIObjectiveMapping__r.Object_Field__c, AutoGenerateActionPlanForFailure__c ';
        query += ' from KPIThreshold__c where KPI__c in :kpiIds and EffectiveDate__c <= :today and EndDate__c >= :today';
        query += ' and EinsteinKPIMapping__r.Type__c NOT IN :type';

        if(level == 'Account') {
            query += ' and Account__c != null';
            thresholdKey = 'Account__c';
        }
        else if(level == 'Region') {
            query += ' and Region__c != null';
            thresholdKey = 'Region__c';
        }
        else if(level == 'District') {
            query += ' and District__c != null';
            thresholdKey = 'District__c';
        }
        else if(level == 'Organization') {
            query += ' and Organization__c != null';
            thresholdKey = 'Organization__c';
        }

        System.debug(LoggingLevel.ERROR, query);

        List<KPIThreshold__c> kpiThresholds = Database.query(query);
        System.debug(LoggingLevel.ERROR, kpiThresholds);

        for(KPIThreshold__c threshold:Database.query(query)) {
            System.debug(LoggingLevel.ERROR, 'Threshold: ' + threshold);
            String keyValue = (String)threshold.get(thresholdKey);
            System.debug(LoggingLevel.ERROR, 'KeyValue: ' + keyValue);
            if(!thresholdMap.containsKey(threshold.KPI__c)) {
                thresholdMap.put(threshold.KPI__c, new Map<Id, List<KPIThreshold__c>>());

            }
            System.debug(LoggingLevel.ERROR, thresholdMap);

            if(!thresholdMap.get(threshold.KPI__c).containsKey(keyValue)) {
                thresholdMap.get(threshold.KPI__c).put(keyValue, new List<KPIThreshold__c>());
            }
            thresholdMap.get(threshold.KPI__c).get(keyValue).add(threshold);
        }

        return thresholdMap;
    }

    public static Map<String, List<String>> getOpenActionPlansForAccountAndKPIs(Set<String> kpiIds, Set<String> accountIds) {

        Map<String, List<String>> kpiActionPlanMap = new Map<String, List<String>>();

        List<Action_Plan__c> actionPlans = [select Id, Account__c, KPI__c from Action_Plan__c where Account__c in :accountIds and KPI__c in :kpiIds and Status__c in ('Open', 'In Progress' )];

        for(Action_Plan__c actionPlan:actionPlans) {
            if(!kpiActionPlanMap.containsKey(actionPlan.KPI__c)) {
                kpiActionPlanMap.put(actionPlan.KPI__c, new List<String>());
            }
            kpiActionPlanMap.get(actionPlan.KPI__c).add(actionPlan.Account__c);
        }

        return kpiActionPlanMap;
    }


    public static Set<String> getListOfKPIIdsFromDetailRecords(List<EinsteinKPIDetail__c> einsteinKPIDetails) {
        Set<String> kpiIds = new Set<String>();

        for(EinsteinKPIDetail__c einsteinKPIDetail:einsteinKPIDetails) {
            kpiIds.add(einsteinKPIDetail.KPI__c);
        }
        return kpiIds;
    }

    public static Set<String> getListOfEinsteinKPIIdsFromDetailRecords(List<EinsteinKPIDetail__c> einsteinKPIDetails) {
        Set<String> einsteinKPIIds = new Set<String>();

        for(EinsteinKPIDetail__c einsteinKPIDetail:einsteinKPIDetails) {
            einsteinKPIIds.add(einsteinKPIDetail.EinsteinKPI__c);
        }
        return einsteinKPIIds;
    }

    public static Set<String> getListOfAccountIdsFromDetailRecords(List<EinsteinKPIDetail__c> einsteinKPIDetails) {
        Set<String> accountIds = new Set<String>();

        for(EinsteinKPIDetail__c einsteinKPIDetail:einsteinKPIDetails) {
            accountIds.add(einsteinKPIDetail.Account__c);
        }
        return accountIds;
    }

    public static Action_Plan__c createActionPlanFromFailedEinsteinKPIDetail(EinsteinKPIDetail__c einsteinKPIDetail, String thresholdId, String failedThresholdsDescription) {

        Action_Plan__c actionPlan = new Action_Plan__c(Name = einsteinKPIDetail.KPI__r.Name + ' - ' + einsteinKPIDetail.Account__r.Name, Account__c = einsteinKPIDetail.Account__c, KPI__c = einsteinKPIDetail.KPI__c);
        actionPlan.HMAInternalSummary__c = failedThresholdsDescription + '<br/><br/><b>Initial Snapshot Value:</b><br/><br/>' + einsteinKPIDetail.KPISummary__c;
        actionPlan.InitialKPISnapshotValue__c = einsteinKPIDetail.KPISummary__c;
        actionPlan.CurrentKPISnapshotValue__c = einsteinKPIDetail.KPISummary__c;
        actionPlan.EinsteinKPIDetail__c = einsteinKPIDetail.Id;
        actionPlan.KPIThreshold__c = thresholdId;
        return actionPlan;
    }

    public class DataSetResults {
        public List<DataSetResult> datasets {get; set;}
    }

    public class DataSetResult {
        public String id {get; set;}
        public String label {get; set;}
        public String currentVersionId {get; set;}
    }



}

//createActionPlanFromFailedEinsteinKPIThreshold