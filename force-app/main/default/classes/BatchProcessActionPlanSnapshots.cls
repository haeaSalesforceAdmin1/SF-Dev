public with sharing class BatchProcessActionPlanSnapshots implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public String query;
    public Set<Id> actionPlanIds;
    public String einsteinKPIId;
    public List<String> kpiIds;

    public BatchProcessActionPlanSnapshots() {

    }

    public BatchProcessActionPlanSnapshots(Set<Id> actionPlanIds) {
        this.actionPlanIds = actionPlanIds;
    }

    public BatchProcessActionPlanSnapshots(String einsteinKPIId) {
        this.einsteinKPIId = einsteinKPIId;
    }

    public BatchProcessActionPlanSnapshots(List<String> kpiIds) {
        this.kpiIds = kpiIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        Date today = Date.today();
        query = 'select Id, DealerCode__c, KPI__c, ';
        query +=' CurrentKPISnapshotValue__c, PreviousKPISnapshotValue__c, InitialKPISnapshotValue__c, EinsteinKPIDetail__r.KPISummary__c from Action_Plan__c where EinsteinKPIDetail__c != null ';
        query += ' and Status__c in (\'Draft - Awaiting Signoff\', \'In Progress - Signed-off\' ) ';

        if(this.actionPlanIds != null && !this.actionPlanIds.isEmpty()) {
            query += ' and Id in :actionPlanIds ';
        }
        else if(einsteinKPIId != null) {
            query += ' and EinsteinKPIDetail__r.EinsteinKPI__c = :einsteinKPIId ';
        }
        else if(kpiIds != null){
            query += ' and KPI__c in :kpiIds and RefreshKPI__c = true ';
        }
        else {
            query += ' and RefreshKPI__c = true ';
        }
        query += ' and EinsteinKPIDetail__r.EinsteinKPI__r.Active__c = true ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Action_Plan__c> actionPlans) {

            for(Action_Plan__c actionPlan:actionPlans) {
                if(actionPlan.InitialKPISnapshotValue__c == null) {
                    actionPlan.InitialKPISnapshotValue__c = actionPlan.EinsteinKPIDetail__r.KPISummary__c;
                    actionPlan.CurrentKPISnapshotValue__c = actionPlan.EinsteinKPIDetail__r.KPISummary__c;
                }   
                else if(actionPlan.CurrentKPISnapshotValue__c != actionPlan.EinsteinKPIDetail__r.KPISummary__c) {
                    actionPlan.PreviousKPISnapshotValue__c = actionPlan.CurrentKPISnapshotValue__c;
                    actionPlan.CurrentKPISnapshotValue__c = actionPlan.EinsteinKPIDetail__r.KPISummary__c;
                }
                actionPlan.RefreshKPI__c = false;
                actionPlan.KPISnapshotRefreshDate__c = Datetime.now();
            }
            update actionPlans;

    }

    public void finish(Database.BatchableContext BC){

    }
}