public with sharing class EinsteinKPIDetailTriggerHelper {

    public static List<EinsteinKPIDetail__c> einsteinKPIDetailsToCreateActionPlans = new List<EinsteinKPIDetail__c>();

    public static void handleBeforeInsertUpdate(List<EinsteinKPIDetail__c> newEinsteinKPIDetails) {

        for(EinsteinKPIDetail__c einsteinKPIDetail:newEinsteinKPIDetails) {
            String kpiSummary = '';
            Integer i = 1;
            while(i<16) {
                String labelField = 'Label' + i + '__c'; 
                if(!String.isBlank((String)einsteinKPIDetail.get(labelField))) {
                    kpiSummary += '<b>' + einsteinKPIDetail.get(labelField) + '</b>: ';

                    String numberField = 'Label' + i + '_Value_Num__c';
                    if(einsteinKPIDetail.get(numberField) != null) {
                        kpiSummary += ((Decimal)einsteinKPIDetail.get(numberField)).format();
                    } 

                    String textField = 'Label' + i + '_Value_Txt__c';
                    if(einsteinKPIDetail.get(textField) != null) {
                        kpiSummary += einsteinKPIDetail.get(textField);
                    } 
                    
                    String currencyField = 'Label' + i + '_Value_Curr__c';
                    if(einsteinKPIDetail.get(currencyField) != null) {
                        kpiSummary += '$' + ((Decimal)einsteinKPIDetail.get(currencyField)).format();
                    } 
                    
                    String percentField = 'Label' + i + '_Value_Percent__c';
                    if(einsteinKPIDetail.get(percentField) != null) {
                        kpiSummary += einsteinKPIDetail.get(percentField) + '%';
                    } 
                    kpiSummary +=  '<br/><br/>';
                }
                i++;
            }
            einsteinKPIDetail.KPISummary__c = kpiSummary;
            if(!String.isBlank(einsteinKPIDetail.Key_Value_1__c)) {
                einsteinKPIDetail.Key_Value__c = einsteinKPIDetail.Key_Value_1__c;
            } 
            if(!String.isBlank(einsteinKPIDetail.Key_Value_2__c)) {
                einsteinKPIDetail.Key_Value__c += '\n' + einsteinKPIDetail.Key_Value_2__c;
            } 
            if(!String.isBlank(einsteinKPIDetail.Key_Value_3__c)) {
                einsteinKPIDetail.Key_Value__c += '\n' + einsteinKPIDetail.Key_Value_3__c;
            } 
            if(!String.isBlank(einsteinKPIDetail.Key_Value_4__c)) {
                einsteinKPIDetail.Key_Value__c += '\n' + einsteinKPIDetail.Key_Value_4__c;
            } 
            if(!String.isBlank(einsteinKPIDetail.Key_Value_5__c)) {
                einsteinKPIDetail.Key_Value__c += '\n' + einsteinKPIDetail.Key_Value_5__c;
            } 

        }
    }

    public static void handleBeforeUpdateCheckCreateActionPlans(List<EinsteinKPIDetail__c> newEinsteinKPIDetails, Map<Id, EinsteinKPIDetail__c> oldEinsteinKPIDetailsMap) {
        for(EinsteinKPIDetail__c einsteinKPIDetail:newEinsteinKPIDetails) {
            if(einsteinKPIDetail.CreateActionPlan__c && !oldEinsteinKPIDetailsMap.get(einsteinKPIDetail.Id).CreateActionPlan__c) {
                einsteinKPIDetail.CreateActionPlan__c = false;
                einsteinKPIDetailsToCreateActionPlans.add(einsteinKPIDetail);
            }
        }
    }

    public static void handleUpldatingReportingPeriod(List<EinsteinKPIDetail__c> details) {

        ReportingPeriodSetting__c setting = ReportingPeriodSetting__c.getInstance('reporting_period');

        for(EinsteinKPIDetail__c detail:details) {
            setting.Value__c = detail.Label1_Value_Txt__c;
        }
        update setting;
    }

    public static void handleAfterUpdateCreateActionPlans( ) {
        if(!einsteinKPIDetailsToCreateActionPlans.isEmpty()) {
            createActionPlansForEinsteinKPIDetails();
        }   
    }

    private static void createActionPlansForEinsteinKPIDetails() {
        Set<String> accountIds = new Set<String>();
        Set<String> kpiIds = new Set<String>();
        List<Action_PLan__c> actionPlansToCreate = new List<Action_Plan__c>();

        for(EinsteinKPIDetail__c einsteinKPIDetail:einsteinKPIDetailsToCreateActionPlans) {
            accountIds.add(einsteinKPIDetail.Account__c);
            kpiIds.add(einsteinKPIDetail.KPI__c);
        }

        Map<String, List<String>> mapOfAccountsWithOpenActionPlansForKPI = EinsteinService.getOpenActionPlansForAccountAndKPIs(kpiIds, accountIds);
        
        for(EinsteinKPIDetail__c einsteinKPIDetail:einsteinKPIDetailsToCreateActionPlans) {
            if(!mapOfAccountsWithOpenActionPlansForKPI.containsKey(einsteinKPIDetail.KPI__c) || (mapOfAccountsWithOpenActionPlansForKPI.containsKey(einsteinKPIDetail.KPI__c) && !mapOfAccountsWithOpenActionPlansForKPI.get(einsteinKPIDetail.KPI__c).contains(einsteinKPIDetail.Account__c))) {
                actionPlansToCreate.add(EinsteinService.createActionPlanFromFailedEinsteinKPIDetail(einsteinKPIDetail, null, ''));
            }
        }

        if(!actionPlansToCreate.isEmpty()) {
            insert actionPlansToCreate;
        }
    }
}