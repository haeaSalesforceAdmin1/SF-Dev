/**
        * @Discription  Evaluation district update with refrence to Account District
        * @author    Milind Shinde
        * Date       06/05/2022
        * -------------------------
	*/
global class ActionPlanDistrictBatch implements Database.Batchable<sObject> {    

    String query = NULL;
    List<Id> listOfAccToUpd = new List<Id>();
    public ActionPlanDistrictBatch(List<Id> listOfAccId) {
        listOfAccToUpd = listOfAccId;
        String kpiStatus = 'Draft';
        String InactivekpiStatus = 'Inactive';
        String CancelledKpiStatus = 'Cancelled';
        query = 'Select id, Name,MarketRef__c,SalesDistrict__c,ServiceDistrict__c,RegionRef__c,Account__r.Market__c,Account__r.SalesDistrict__c,Account__r.ServiceDistrict__c,Account__r.Region__c from Action_Plan__c where Account__c != NULL AND (KPI__r.status__c !=\''+String.escapeSingleQuotes(kpiStatus)+'\' OR KPI__r.status__c !=\''+String.escapeSingleQuotes(InactivekpiStatus)+'\'  OR KPI__r.status__c !=\''+String.escapeSingleQuotes(CancelledKpiStatus)+'\') AND Account__c IN :listOfAccToUpd';
       
    }
    public ActionPlanDistrictBatch(){}
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (String.isBlank(query)){
        String kpiStatus = 'Draft';
        String InactivekpiStatus = 'Inactive';
        String CancelledKpiStatus = 'Cancelled';
        query = 'Select id, Name,MarketRef__c,SalesDistrict__c,ServiceDistrict__c,RegionRef__c,Account__r.Market__c,Account__r.SalesDistrict__c,Account__r.ServiceDistrict__c,Account__r.Region__c from Action_Plan__c where Account__c != NULL AND (KPI__r.status__c !=\''+String.escapeSingleQuotes(kpiStatus)+'\' OR KPI__r.status__c !=\''+String.escapeSingleQuotes(InactivekpiStatus)+'\'  OR KPI__r.status__c !=\''+String.escapeSingleQuotes(CancelledKpiStatus)+'\')';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Action_Plan__c> evalList) {
        
        for(Action_Plan__c eval : evalList){
            if(eval.MarketRef__c != eval.Account__r.Market__c){
                eval.MarketRef__c = eval.Account__r.Market__c;
            }if(eval.SalesDistrict__c != eval.Account__r.SalesDistrict__c){
                eval.SalesDistrict__c = eval.Account__r.SalesDistrict__c;
            }if(eval.ServiceDistrict__c != eval.Account__r.ServiceDistrict__c){
                eval.ServiceDistrict__c = eval.Account__r.ServiceDistrict__c;
            }if(eval.RegionRef__c != eval.Account__r.Region__c){
                eval.RegionRef__c = eval.Account__r.Region__c;
            }
        }     
        // process each batch of records
            update evalList;
         
    }   
    
    global void finish(Database.BatchableContext BC) {
	// Query the AsyncApexJob object to retrieve the current job's information.
   	  AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob WHERE Id =
      :BC.getJobId()];
        System.debug('ApexJobs Processed: '+a.Id);
  }
}