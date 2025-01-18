/**
        * @Discription  Evaluation district update with refrence to Account District
        * @author    Milind Shinde
        * Date       06/05/2022
        * -------------------------
		EvaluationDistrictBatch be = new EvaluationDistrictBatch();
		database.executeBatch(be);
	*/
global class EvaluationDistrictBatch implements Database.Batchable<sObject> {  

    String query = NULL;
    List<Id> listOfAccToUpd = new List<Id>();
    public EvaluationDistrictBatch(List<Id> listOfAccId){
        listOfAccToUpd = listOfAccId;
        query = 'Select id, Name,MarketRef__c,SalesDistrict__c,ServiceDistrict__c,RegionRef__c,Account__r.Market__c,Account__r.SalesDistrict__c,Account__r.ServiceDistrict__c,Account__r.Region__c from Evaluation__c WHERE Account__c IN :listOfAccToUpd';
       System.debug('query eval -- '+query);
    }  
    
    public EvaluationDistrictBatch(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (String.isBlank(query)){
            query = 'Select id, Name,MarketRef__c,SalesDistrict__c,ServiceDistrict__c,RegionRef__c,Account__r.Market__c,Account__r.SalesDistrict__c,Account__r.ServiceDistrict__c,Account__r.Region__c from Evaluation__c';
       
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Evaluation__c> evalList) {
        List<Evaluation__c> listEvalToUpd = new List<Evaluation__c>();
        for(Evaluation__c eval : evalList){
            if(eval.MarketRef__c != eval.Account__r.Market__c){
                eval.MarketRef__c = eval.Account__r.Market__c;
            }if(eval.SalesDistrict__c != eval.Account__r.SalesDistrict__c){
                eval.SalesDistrict__c = eval.Account__r.SalesDistrict__c;
            }if(eval.ServiceDistrict__c != eval.Account__r.ServiceDistrict__c){
                eval.ServiceDistrict__c = eval.Account__r.ServiceDistrict__c;
            }if(eval.RegionRef__c != eval.Account__r.Region__c){
                eval.RegionRef__c = eval.Account__r.Region__c;
            }
            listEvalToUpd.add(eval);
        }     
        // process each batch of records
        if (listEvalToUpd.size() > 0) {
            update listEvalToUpd;
        }
         
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