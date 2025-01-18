/**
* KPIPDFExportController Class Fetching KPI detail for KPI PDF Export button on Account page.
* @author Vinit [IBM]
* @creation 18th August 2021
*/
public without sharing class KPIPDFExportController {
    
    public String accountId {get; set;}
    public EvaluationWrapper evaluationWrapper {get; set;}
    public AccountWrapper accountWrpr {get;set;}
    public KPIPDFExportController() {
        accountId = ApexPages.currentPage().getParameters().get('id');
        handleLoad();
    }
    
    /**
* handleLoad fetch KPI details on page load. 
* @param  none  
* @return none     
* @author Vinit [18 August 2021] [IBM]
*/
    public void handleLoad() {
         String myGeneratedFileName = '.pdf';
       //Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+myGeneratedFilename); 
        List<Id> listOfEvalId = new List<Id>();
        if (String.isNotBlank(accountId)) {
            
            Account acc = [SELECT Id, Name,DealerCode__c,Organization__r.Name, Region__c, SalesDistrict__c, Market__c
                           FROM Account 
                           WHERE Id =:accountId ]; 
            myGeneratedFileName=acc.Name+'_'+date.today().format()+'_KPI'+myGeneratedFileName;
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+myGeneratedFilename); 
            system.debug('acc is ' + acc + '  -- dealer code ' + acc.DealerCode__c);
            if (acc != NULL && acc.DealerCode__c != NULL) {
                List<EvaluationKPIsDetails> evalSalesKPIDetailsList = new List<EvaluationKPIsDetails>();
                List<EvaluationKPIsDetails> evalServiceKPIDetailsList = new List<EvaluationKPIsDetails>();
                Map<String, EinsteinKPIDetail__c> mapOfAvgRegionDistrict = new Map<String, EinsteinKPIDetail__c>();
                evaluationWrapper = new EvaluationWrapper();
                accountWrpr = new AccountWrapper(acc);
                if (acc.SalesDistrict__c == NULL && acc.Market__c != NULL) {
                    acc.SalesDistrict__c = acc.Market__c;
                }
                if (acc.Region__c != NULL && (acc.SalesDistrict__c != NULL || acc.Market__c != NULL)) {
                    
                    for (EinsteinKPIDetail__c EK :   [SELECT Id, Key_Value__c,Region__r.Name,RegionCode__c, DistrictCode__c, EinsteinKPIName__c,Region__c, District__c,EinsteinKPI__r.Parent_Einstein_KPI__c,EinsteinKPI__r.Dealer_Value_is_High__c
                                                            // DPM-3937 Last Calculation Date add
                                                            // ,LastCalculationDate__c
                                                      FROM EinsteinKPIDetail__c 
                                                      WHERE District__c  =: acc.SalesDistrict__c
                                                      OR Region__c =:acc.Region__c]) {
                                                           
                                                          if (EK.Region__c != NULL && !mapOfAvgRegionDistrict.containsKey(EK.EinsteinKPIName__c)) {
                                                              mapOfAvgRegionDistrict.put(EK.EinsteinKPIName__c,EK);    
                                                          } else if (EK.District__c != NULL && !mapOfAvgRegionDistrict.containsKey(EK.EinsteinKPIName__c)){
                                                              mapOfAvgRegionDistrict.put(EK.EinsteinKPIName__c,EK);    
                                                          }
                                                      }
                    
                    system.debug(' here  ' +mapOfAvgRegionDistrict);
                }
                
                for (EinsteinKPIDetail__c einsteinKPI : [SELECT Id, EinsteinKPIName__c, ThresholdStatus__c,Subcategory__c,
                                                         EinsteinKPI__r.ActionPlanRequirement__c,EinsteinKPI__c,
                                                         EinsteinKPI__r.KPI__r.Name, Threshold_Value__c,
                                                         Key_Value__c,ThresholdStatusIcon__c, EinsteinKPI__r.Division__c,
                                                         EinsteinKPI__r.Dealer_Value_is_High__c
                                                        // DPM-3937 Last Calculation Date add
                                                        //,LastCalculationDate__c
                                                         FROM EinsteinKPIDetail__c 
                                                         WHERE DealerCode__c =:acc.DealerCode__c
                                                         AND EinsteinKPI__r.RecordType.DeveloperName =:accountWrpr.orgName 
                                                         AND (EinsteinKPI__r.Division__c = 'Sales' 
                                                              OR EinsteinKPI__r.Division__c = 'Service')
                                                              //! DPM-4715 This line must be eliminated later on.
                                                              //! by LJ: 2023-08-14
                                                              AND(NOT EinsteinKPIName__c LIKE'%eMPI%')
                                                            ///////////////////////////////////////////////////////////
                                                        ORDER BY EinsteinKPI__r.Ranking__c ASC/*

                                                         AND (Subcategory__c = 'Sales' OR Subcategory__c = 'Service')*/]) {
                                                             
                                                             EvaluationKPIsDetails evalKPIdetail = new EvaluationKPIsDetails();
                                                             evalKPIdetail.KPIId = einsteinKPI.EinsteinKPI__c;
                                                             evalKPIdetail.KPIName = einsteinKPI.EinsteinKPIName__c;
                                                             evalKPIdetail.Initial_Key_Value = einsteinKPI.Key_Value__c;
                                                             evalKPIdetail.Initial_Threshold_Value = einsteinKPI.Threshold_Value__c;
                                                             // DPM-3937 Last Calculation Date add
                                                            //  evalKPIdetail.Last_Calculation_Date = einsteinKPI.LastCalculationDate__c;
                                                             //evalKPIdetail.DealerStatus = einsteinKPI.EinsteinKPI__r.Dealer_Value_is_High__c;
                                                             
                                                             if (mapOfAvgRegionDistrict != NULL && mapOfAvgRegionDistrict.size() > 0 && String.isNotBlank(evalKPIdetail.KPIName)) {
                                                                 for (String key : mapOfAvgRegionDistrict.keySet()){
                                                                     Id keyId = mapOfAvgRegionDistrict.get(key).EinsteinKPI__r.Parent_Einstein_KPI__c;
                                                                     if (keyId == evalKPIdetail.KPIId) {
                                                                         if (key.contains('Region') ||key.contains('region') ){
                                                                             evalKPIdetail.regionValue = mapOfAvgRegionDistrict.get(key).Key_Value__c;
                                                                             evalKPIdetail.DealerStatus = mapOfAvgRegionDistrict.get(key).EinsteinKPI__r.Dealer_Value_is_High__c;
                                                                         }
                                                                         if (key.contains('District') || key.contains('district')){
                                                                             evalKPIdetail.districtValue = mapOfAvgRegionDistrict.get(key).Key_Value__c;
                                                                             evalKPIdetail.DealerStatus = mapOfAvgRegionDistrict.get(key).EinsteinKPI__r.Dealer_Value_is_High__c;
                                                                         }
                                                                     }
                                                                 }
                                                                 String regionVal = NULL;
                                                                 String districtVal = NULL;
                                                                 String initialKeyVal = NULL;
                                                                 
                                                                 
                                                                 try{
                                                                    String einsteinKPIKeyValueString = String.valueOf(evalKPIdetail.Initial_Key_Value).replaceAll('[^0-9.]', '');
                                                                    Double einsteinKPIKeyValue  = Double.valueOf(einsteinKPIKeyValueString);
                                                                    
                                                                        
                                                                        String regionKPIKeyValueString = String.valueOf(evalKPIdetail.regionValue).replaceAll('[^0-9.]', '');
                                                                        Double regionKPIKeyValue = Double.valueOf(regionKPIKeyValueString);   
                                                                        if(evalKPIdetail.DealerStatus == false){
                                                                            if(einsteinKPIKeyValue > regionKPIKeyValue){
                                                                                evalKPIdetail.regionColor='red';
                                                                            }
                                                                            else{
                                                                                evalKPIdetail.regionColor = 'green';   
                                                                            }
                                                                        }else{
                                                                               if(einsteinKPIKeyValue >= regionKPIKeyValue)
                                                                                evalKPIdetail.regionColor='green';
                                                                                else
                                                                                evalKPIdetail.regionColor = 'red';
                                                                        }
                                                                    
                                                
                                                                        String districtKPIKeyValueString = String.valueOf(evalKPIdetail.districtValue).replaceAll('[^0-9.]', '');
                                                                        Double districtKPIKeyValue = Double.valueOf(districtKPIKeyValueString);
                                                                        
                                                                        if(evalKPIdetail.DealerStatus == false){
                                                                            if(einsteinKPIKeyValue > districtKPIKeyValue)
                                                                            {
                                                                                System.debug('districtKPIKeyValue RED : '+districtKPIKeyValue);
                                                                                evalKPIdetail.districtColor='red';   
                                                                            }
                                                                            else{
                                                                                evalKPIdetail.districtColor = 'green';
                                                                            }
                                                                        }else{
                                                                                if(einsteinKPIKeyValue >= districtKPIKeyValue){
                                                                                    System.debug('districtKPIKeyValue RED : '+districtKPIKeyValue);
                                                                                    evalKPIdetail.districtColor='green';   
                                                                                }
                                                                                else{
                                                                                    evalKPIdetail.districtColor = 'red';
                                                                                }
                                                                        	}
                                                                   
                                                                }catch(Exception e){
                                                                        double	regionKPIKeyValue = 0.0;
                                                                }
                                                                 /*
                                                                 if (String.isNotBlank(evalKPIdetail.regionValue)) {
                                                                    regionVal = (evalKPIdetail.regionValue).replace('$','');
                                                                    regionVal = (regionVal).replace('%','');
                                                                 }

                                                                 if (String.isNotBlank(evalKPIdetail.districtValue)) {
                                                                    districtVal = (evalKPIdetail.districtValue).replace('$','');
                                                                    districtVal = (districtVal).replace('%','');
                                                                 }

                                                                 if (String.isNotBlank(evalKPIdetail.Initial_Key_Value)) {
                                                                    initialKeyVal = (evalKPIdetail.Initial_Key_Value).replace('$','');
                                                                    initialKeyVal = (initialKeyVal).replace('%','');
                                                                 }
                                                                 
                                                                 if(evalKPIdetail.DealerStatus == false){
                                                                     System.debug('###evalKPIdetail.regionValue: '+evalKPIdetail.regionValue);
                                                                  if( String.isNotBlank(evalKPIdetail.regionValue) && Decimal.valueOf(regionVal) >= Decimal.valueOf(initialKeyVal)) {
                                                                     	evalKPIdetail.regionColor = 'green';
                                                                 	} else {
                                                                     	evalKPIdetail.regionColor = 'red';
                                                                 		}   
                                                                 }else{
                                                                     if( String.isNotBlank(evalKPIdetail.regionValue) && Decimal.valueOf(regionVal) >= Decimal.valueOf(initialKeyVal)) {
                                                                     	evalKPIdetail.regionColor = 'red';
                                                                 	} else {
                                                                     	evalKPIdetail.regionColor = 'green';
                                                                 		} 
                                                                 }
                                                                 
                                                                 	if(evalKPIdetail.DealerStatus == false){
                                                                        System.debug('###evalKPIdetail.districtValue: '+evalKPIdetail.districtValue);
                                                                          if(String.isNotBlank(evalKPIdetail.districtValue) && Decimal.valueOf(districtVal) >= Decimal.valueOf(initialKeyVal)) {
                                                                             evalKPIdetail.districtColor = 'green';
                                                                         } else {
                                                                             evalKPIdetail.districtColor = 'red';
                                                                         }   
                                                                     }else{
                                                                         if(String.isNotBlank(evalKPIdetail.districtValue) && Decimal.valueOf(districtVal) >= Decimal.valueOf(initialKeyVal)) {
                                                                             evalKPIdetail.districtColor = 'red';
                                                                         } else {
                                                                             evalKPIdetail.districtColor = 'green';
                                                                         }
                                                                     }*/
                                                                 
                                                             }                                                                           
                                                             
                                                             evalKPIdetail.ThresholdStatus = einsteinKPI.ThresholdStatus__c;
                                                             if (String.isNotBlank(einsteinKPI.EinsteinKPI__r.Division__c) && einsteinKPI.EinsteinKPI__r.Division__c == 'Sales') {
                                                                 evalSalesKPIDetailsList.add(evalKPIdetail);                                  
                                                             }  else if (String.isNotBlank(einsteinKPI.EinsteinKPI__r.Division__c) && einsteinKPI.EinsteinKPI__r.Division__c == 'Service'){
                                                                 evalServiceKPIDetailsList.add(evalKPIdetail);
                                                             }                                          
                                                         } 
                
                System.debug('###evalServiceKPIDetailsList: '+evalServiceKPIDetailsList);
                System.debug('###evalSalesKPIDetailsList: '+evalSalesKPIDetailsList);
                evaluationWrapper.evalSalesKPIDetails = evalSalesKPIDetailsList;
                evaluationWrapper.evalServiceKPIDetails = evalServiceKPIDetailsList;
                
            }
        }
    }
    
    /**
* Fetching network Id to show PDF. 
* @param  none  
* @return network Id.     
* @author Vinit [18 August 2021] [IBM]
*/
    @AuraEnabled
    public static string getNetworkId(){
        
        String networkId =  Network.getNetworkId();
        
        DPMConfigurationSettings__c setting = DPMConfigurationSettings__c.getInstance();
        
        System.debug(LoggingLevel.ERROR, setting);
        System.debug(LoggingLevel.ERROR, networkId);
        
        if(networkId == null) {
            return '';
        }
        else if(networkId.left(15) == setting.HyundaiNetworkId__c.left(15)){
            //Hyundai
            System.debug(LoggingLevel.ERROR, setting.HyundaiNetworkId__c );
            System.debug(LoggingLevel.ERROR, setting.HyundaiCommunityURL__c );
            return setting.HyundaiCommunityURL__c;
        }
        else {
            //Genesis
            System.debug(LoggingLevel.ERROR, setting.GenesisCommunityURL__c );
            return setting.GenesisCommunityURL__c;
        }
    }
    
    public class EvaluationWrapper {
        public Evaluation__c evaluation {get; set;}
        public List<EvaluationKPIs__c> evaluationKPIs {get; set;}
        public Account dealer {get;set;}
        
        public List<EvaluationKPIsDetails> evalSalesKPIDetails{get;set;}
        public List<EvaluationKPIsDetails> evalServiceKPIDetails{get;set;}
        public EvaluationWrapper() {
            evalSalesKPIDetails = new List<EvaluationKPIsDetails>();
            evalServiceKPIDetails = new List<EvaluationKPIsDetails>();
            dealer = new Account();
        }
        
    }
    
    public class AccountWrapper {
        
        public String dealerName {get;set;}
        public String orgName {get;set;}
        public String dealerCode {get;set;}
        
        public AccountWrapper(Account acc){
            dealerName =  acc.Name;
            orgName =  acc.Organization__r.Name;
            dealerCode =  acc.DealerCode__c;
        }
    }
    
    
    public class EvaluationKPIsDetails {
        public String KPIName {get; set;}
        public String Initial_Key_Value {get; set;}
        public String Initial_Threshold_Value {get; set;}
        public String ThresholdStatusIcon {get; set;}
        public String ThresholdStatus {get; set;}
        public String regionValue {get; set;}
        public String districtValue {get; set;}
        public String regionColor {get; set;}
        public String districtColor {get; set;}
        public Id KPIId {get;set;}
        public Boolean DealerStatus{get;set;}
        // DPM-3937 Last Calculation Date add
        // public Datetime Last_Calculation_Date {get; set;}
        
        @AuraEnabled
        public String KPIName1 {get; set;} 
        
        @AuraEnabled 
        public EvaluationKPIs__c evaluationKPI {get; set;} 
        
        @AuraEnabled 
        public EinsteinKPI__c einsteinKPI {get; set;} 
        
        @AuraEnabled
        public EinsteinKPIDetail__c einsteinKPIDetail {get; set;}
        
        @AuraEnabled
        public EinsteinKPIDetail__c regionEinsteinKPIDetail {get; set;}
        
        @AuraEnabled
        public EinsteinKPIDetail__c districtEinsteinKPIDetail {get; set;}
        
        
    }
}