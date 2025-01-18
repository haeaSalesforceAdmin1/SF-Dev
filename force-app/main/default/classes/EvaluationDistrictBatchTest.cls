@isTest
public without sharing class EvaluationDistrictBatchTest {
    @isTest
    public static void executeTest(){
        //Select id, Name,MarketRef__c,SalesDistrict__c,ServiceDistrict__c,RegionRef__c,Account__r.Market__c,Account__r.SalesDistrict__c,Account__r.ServiceDistrict__c,Account__r.Region__c from Evaluation__c';
        TestUtility.createOrganizations();
		TestUtility.createRegionsForOrganizations('Hyundai');
        Region__c getReg = TestUtility.getRegion('SOUTHERN REGION', 'Hyundai');
        Region__c getAccReg = TestUtility.getRegion('CENTRAL REGION', 'Hyundai');        
        TestUtility.createDistrictsForRegions();
        District__c getDist = TestUtility.getDistrict('ALABAMA NORTH', 'SOUTHERN REGION', 'Hyundai');
        District__c getAccDist = TestUtility.getDistrict('ATLANTA','SOUTHERN REGION', 'Hyundai');
        
        //List<Evaluation__c> evaluation = new List<Evaluation__c>();
        
        Account acc = new Account(Name = 'Cricket', Market__c = getAccDist.Id, SalesDistrict__c = getAccDist.Id, ServiceDistrict__c = getAccDist.Id, Region__c = getAccReg.Id);
        insert acc;
        Evaluation__c evaluation = new Evaluation__c(Name = 'Paris', MarketRef__c = getDist.Id,SalesDistrict__c = getDist.Id,ServiceDistrict__c = getDist.Id,RegionRef__c = getReg.Id,Account__c = acc.Id);
        insert evaluation;
        Evaluation__c ev = [Select id, Name,MarketRef__c,SalesDistrict__c,ServiceDistrict__c,RegionRef__c,Account__r.Market__c,Account__r.SalesDistrict__c,Account__r.ServiceDistrict__c,Account__r.Region__c from Evaluation__c];
        
        Test.startTest();
        EvaluationDistrictBatch edBatch = new EvaluationDistrictBatch();
        Database.executeBatch(edBatch);
        Test.stopTest();
        
        Evaluation__c eval = [Select id, Name,MarketRef__c,SalesDistrict__c,ServiceDistrict__c,RegionRef__c,Account__r.Market__c,Account__r.SalesDistrict__c,Account__r.ServiceDistrict__c,Account__r.Region__c from Evaluation__c];
        
        if(ev.MarketRef__c != ev.Account__r.Market__c){
        	System.assertEquals(eval.Account__r.Market__c, eval.MarketRef__c);
        }
        if(ev.SalesDistrict__c != ev.Account__r.SalesDistrict__c){
        	System.assertEquals(eval.Account__r.SalesDistrict__c, eval.SalesDistrict__c);
        }
        if(ev.ServiceDistrict__c != ev.Account__r.ServiceDistrict__c){
        	System.assertEquals(eval.Account__r.ServiceDistrict__c, eval.ServiceDistrict__c);
        }if(ev.RegionRef__c != ev.Account__r.Region__c){
                System.assertEquals(eval.RegionRef__c, eval.Account__r.Region__c);
        }
    }
}