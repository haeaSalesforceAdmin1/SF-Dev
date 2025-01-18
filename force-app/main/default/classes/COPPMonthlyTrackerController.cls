/**
     * [Class Description] COPP Project - Controller for Monthly Tracker pdf
     * Created by [MinheeKim] on [2024-08-19] for [DPM-5701]
    */

    public without sharing class COPPMonthlyTrackerController {

        public Account acc {get; set;}
        public COPPInfo__c coppInfo {get; set;}
        public String dealerName {get; set;}
        public List<COPPKPIWrapper> coppWappers {get; set;}
        public List<SectionWrapper> coppKPIDetailList {get; set;}
        public List<String> mapKey {get; set;}
        public String recordId {get; set;} 
        public String reportMonth {get; set;}
        public String fromMonth {get; set;}
        public String toMonth {get; set;}
        public String month1Label {get; set;}
        public String month2Label {get; set;}
        public String month3Label {get; set;}
        public String month4Label {get; set;}
        public String month5Label {get; set;}
        public String month6Label {get; set;}
        public String month1BrandImage {get; set;}
        public String month2BrandImage {get; set;}
        public String month3BrandImage {get; set;}
        public String month4BrandImage {get; set;}
        public String month5BrandImage {get; set;}
        public String month6BrandImage {get; set;}
        public String responsiblePerson {get; set;}
        public String completionDate {get; set;}
        public String BrandCode {get; set;}
        public String marketName {get; set;}
       
                  
    
        public COPPMonthlyTrackerController(ApexPages.StandardController stdController) {
            recordId = ApexPages.currentPage().getParameters().get('recordId');
            if (recordId == null) {
                recordId = ApexPages.currentPage().getParameters().get('id');
            }
            coppWappers = new List<COPPKPIWrapper>();
            coppKPIDetailList = new List<SectionWrapper>();
        }
    
        public void handleLoad() {
            this.getCOPPKPI();

            
        }
    
        public class SectionWrapper {
            public String sectionName {get; set;}
            public List<COPPKPIWrapper> kpiList {get; set;}
        
            public SectionWrapper(String sectionName, List<COPPKPIWrapper> kpiList) {
                this.sectionName = sectionName;
                this.kpiList = kpiList;
            }
        }

    
        public class COPPKPIWrapper{
            public String category{get;set;}
            public Boolean isPercent{get;set;}
            public Boolean isRank{get;set;}
            public Boolean isPositiveInitialDiff {get;set;} //DPM-5910 added to check if the currentInitialDiff is positive
            public Boolean isPositiveTargetDiff {get;set;} //DPM-5910 added to check if the currentTargetDiff is positive
            public Decimal currentInitialDiff {get;set;}
            public Decimal currentTargetDiff {get;set;}
            public COPPKPIDetail__c kpiDetail{get;set;}
            public Decimal month1 {get; set;}
            public Decimal month2 {get; set;}
            public Decimal month3 {get; set;}
            public Decimal month4 {get; set;}
            public Decimal month5 {get; set;}
            public Decimal month6 {get; set;}
            public Boolean isBranding {get; set;}
    
            public COPPKPIWrapper(COPPKPIDetail__c kpiDetail){
                this.category = kpiDetail.COPP_KPI__r.Section__c;
                this.isPercent = (kpiDetail.COPP_KPI__r.isPercent__c) ? true : false;
                this.isRank = kpiDetail.COPP_KPI__r.Key__c == 'H515' ? true : false;
                this.kpiDetail = kpiDetail;
    
                if(isRank){
                    this.currentInitialDiff = calculateInitialDiff(kpiDetail)!=null? calculateInitialDiff(kpiDetail).setScale(0) : null;
                    this.isPositiveInitialDiff = this.currentInitialDiff>0 ? true : false; //DPM-5910 added to check if the currentInitialDiff is positive
                    this.currentTargetDiff = calculateTargetDiff(kpiDetail)!=null? calculateTargetDiff(kpiDetail).setScale(0) : null;
                    this.isPositiveTargetDiff = this.currentTargetDiff>0 ? true : false; //DPM-5910 added to check if the currentTargetDiff is positive
                }else{
                    this.currentInitialDiff = calculateInitialDiff(kpiDetail)!=null? calculateInitialDiff(kpiDetail).setScale(1) : null;
                    this.currentTargetDiff = calculateTargetDiff(kpiDetail)!=null? calculateTargetDiff(kpiDetail).setScale(1) : null;
                }
                
                if(isPercent){
                    this.month1 = kpiDetail.Month1__c!=null ? Decimal.valueOf(kpiDetail.Month1__c).setscale(1) : null;
                    this.month2 = kpiDetail.Month2__c!=null ? Decimal.valueOf(kpiDetail.Month2__c).setscale(1) : null;
                    this.month3 = kpiDetail.Month3__c!=null ? Decimal.valueOf(kpiDetail.Month3__c).setscale(1) : null;
                    this.month4 = kpiDetail.Month4__c!=null ? Decimal.valueOf(kpiDetail.Month4__c).setscale(1) : null;
                    this.month5 = kpiDetail.Month5__c!=null ?  Decimal.valueOf(kpiDetail.Month5__c.trim()).setscale(1) : null;
                    this.month6 = kpiDetail.Month6__c!=null ? Decimal.valueOf(kpiDetail.Month6__c).setscale(1) : null;
                }else{
                    this.month1 = kpiDetail.Month1__c!=null ? Decimal.valueOf(kpiDetail.Month1__c): null; //.round(System.RoundingMode.HALF_EVEN) 
                    this.month2 = kpiDetail.Month2__c!=null ? Decimal.valueOf(kpiDetail.Month2__c): null;
                    this.month3 = kpiDetail.Month3__c!=null ? Decimal.valueOf(kpiDetail.Month3__c) : null;
                    this.month4 = kpiDetail.Month4__c!=null ? Decimal.valueOf(kpiDetail.Month4__c) : null;
                    this.month5 = kpiDetail.Month5__c!=null ?  Decimal.valueOf(kpiDetail.Month5__c.trim()) : null;
                    this.month6 = kpiDetail.Month6__c!=null ? Decimal.valueOf(kpiDetail.Month6__c) : null;

                    //[DPM-5887] Smoke test error : Added logic to decide whether it's decimal or integer- 24.10.2024
                    if(kpiDetail.COPP_KPI__r.isInteger__c){
                        kpiDetail.Initial_Score__c = kpiDetail.Initial_Score__c!=null ? kpiDetail.Initial_Score__c.setscale(0) : null;
                        kpiDetail.Target_Score__c = kpiDetail.Target_Score__c!=null ? kpiDetail.Target_Score__c.setscale(0) : null;
                    }else{
                        kpiDetail.Initial_Score__c = kpiDetail.Initial_Score__c!=null ? kpiDetail.Initial_Score__c : null;
                        kpiDetail.Target_Score__c = kpiDetail.Target_Score__c!=null ? kpiDetail.Target_Score__c : null;
                    }
                    
                }
                
                this.isBranding = kpiDetail.COPP_KPI__r.Name =='Branding' ? true : false;
                
            }
        }
    
    
        public void getCOPPKPI(){
            Account acc = getAccount(recordId);
            COPPInfo__c coppInformation = getCOPPInfo(recordId);
            
    		this.marketName = acc.BrandCode__c=='H' ? acc.SalesDistrictCode__c+' / '+ toTitleCase(acc.SalesDistrict__r.Name) : acc.MarketCodeGenesisPicklist__c +' / '+ toTitleCase(acc.Market__r.Name);
            this.dealerName = toTitleCase(acc.Doing_Business_As_Name__c);
            acc.PMA_Desc__c = toTitleCase(acc.PMA_Desc__c);
            this.acc = acc;
            this.BrandCode = acc.BrandCode__c;
    
            List<SectionWrapper> coppKPIDetailList = new List<SectionWrapper>();
    		Map<String, SectionWrapper> sectionMap = new Map<String, SectionWrapper>();
            
            //[DPM-5886] Smoke test error : Added COPP_KPI__r.Key__c - 24.10.2024
            //[DPM-5887] Added COPP_KPI__r.isInteger__c to decide whether it's decimal or integer- 25.10.2024
            List<COPPKPIDetail__c> coppKPIs = [SELECT COPP_KPI__r.Name, COPP_KPI__r.Section__c, COPP_KPI__r.isPercent__c, COPP_KPI__r.isInteger__c, COPP_KPI__r.Key__c, Initial_Score__c, Target_Score__c, Month1__c, Month2__c, Month3__c, Month4__c, Month5__c, Month6__c 
                                                FROM COPPKPIDetail__c WHERE Account__c = :recordId AND Visiblity__c = true AND COPP_KPI__r.Key__c != 'H310' AND COPP_KPI__r.Key__c != 'H315' AND COPP_KPI__r.Key__c != 'G310' AND COPP_KPI__r.Key__c != 'G315' ORDER BY COPP_KPI__r.Order__c ASC];
            if(coppKPIs.size()>0){    
               for(COPPKPIDetail__c coppKPI : coppKPIs){
                    COPPKPIWrapper coppWrapper = new COPPKPIWrapper(coppKPI);
                    System.debug('copp KPI: '+coppKPI.COPP_KPI__r.Name);
            
                    if(!sectionMap.containsKey(coppKPI.COPP_KPI__r.Section__c)){
                        List<COPPKPIWrapper> newList = new List<COPPKPIWrapper>();
                        newList.add(coppWrapper);
                        SectionWrapper newSection = new SectionWrapper(coppKPI.COPP_KPI__r.Section__c, newList);
                        coppKPIDetailList.add(newSection);
                        sectionMap.put(coppKPI.COPP_KPI__r.Section__c, newSection);
                    }else{
                        SectionWrapper existingSection = sectionMap.get(coppKPI.COPP_KPI__r.Section__c);
                        existingSection.kpiList.add(coppWrapper);
                    }

               }
                
            }
            this.coppKPIDetailList = coppKPIDetailList;
            if(coppInformation!=null){
                setMonth(coppInformation);
                setBrandImage(coppInformation);
            }
            
            
        }
    
        @AuraEnabled(Cacheable=true)
        public static Account getAccount(String recordId){
            return Test.isRunningTest()? new Account(Name = 'Test Account',
            DealerCode__c = 'D12345',
            BillingCity = 'San Francisco',
            ADI_Description__c = 'ADI Test'
            ) :[SELECT DealerCode__c, Doing_Business_As_Name__c, SalesDistrict__r.Name,SalesDistrictCode__c, Market__r.Name, MarketCodeGenesisPicklist__c, PMA_Desc__c, BillingState, BrandCode__c FROM Account WHERE Id =: recordId LIMIT 1];
        }

        @AuraEnabled(Cacheable=true)
        public static COPPInfo__c getCOPPInfo(String recordId){
            if(Test.isRunningTest()){
                Account acc = getAccount(recordId);
                
                COPPInfo__c coppInfo = new COPPInfo__c(
                    Account__c = acc.Id,
                    Performance_Period__c = '032023',
                    COPP_Performance_Reporting_Month__c = '202309'
                );
                return coppInfo;
            }
            List<COPPInfo__c> coppinfo = [SELECT BrandImageCheckedDate__c, Performance_Period__c, COPP_Performance_Reporting_Month__c FROM COPPInfo__c WHERE Account__c =: recordId LIMIT 1];
            if(coppinfo.size()>0){
                return coppinfo[0];
            }  
            return null;
        }
    
        public static String toTitleCase(String input) {
            if (String.isEmpty(input)) {
                return input;
            }
            
            // Split the input string into words
            List<String> words = input.split(' ');
            List<String> titleCasedWords = new List<String>();
            
            for (String word : words) {
                if (!String.isEmpty(word)) {
                    // Capitalize the first letter and make the rest lowercase
                    String capitalizedWord ='';
                    if(word=='OF'){
                        capitalizedWord = word.toLowerCase();
                    }else{
                        capitalizedWord = word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase();
                    }
                    
                    titleCasedWords.add(capitalizedWord);
                }
            }
            
            // Join the words back into a single string
            return String.join(titleCasedWords, ' ');
        }
    
        /**
         * [Method Description] COPP Project - calculate for the value of Current vs Initial
         * Created by [MinheeKim] on [2024-08-19] for [DPM-5701]
         * Edited by [MinheeKim] on [2024-11-05] for [DPM-5910] change the logic for WOPR Rank : differenciate = Initial - Current
        */
        public static Decimal calculateInitialDiff(COPPKPIDetail__c kpiDetail){
            Decimal result = null;
            //[DPM-5886] Smoke test error : Added decision for COPP_KPI__r.Key__c - 10.24.2024
            //[DPM-5910] change the logic for WOPR Rank : differenciate = Initial - Current - 11.05.2024
            if(kpiDetail.COPP_KPI__r.Key__c == 'H515' ){
                if(kpiDetail.Initial_Score__c!=null){
                    if(kpiDetail.Month6__c!=null){
                        result= kpiDetail.Initial_Score__c - Decimal.valueOf(kpiDetail.Month6__c);
                        return result.setscale(0);
                    }else if(kpiDetail.Month5__c!=null){
                        result= kpiDetail.Initial_Score__c - Decimal.valueOf(kpiDetail.Month5__c);
                        return result.setscale(0);
                    }else if(kpiDetail.Month4__c!=null){
                        result= kpiDetail.Initial_Score__c - Decimal.valueOf(kpiDetail.Month4__c);
                        return result.setscale(0);
                    }else if(kpiDetail.Month3__c!=null){
                        result= kpiDetail.Initial_Score__c - Decimal.valueOf(kpiDetail.Month3__c);
                        return result.setscale(0);
                    }else if(kpiDetail.Month2__c!=null){
                        result= kpiDetail.Initial_Score__c - Decimal.valueOf(kpiDetail.Month2__c);
                        return result.setscale(0);
                    }else if(kpiDetail.Month1__c!=null){
                        result= kpiDetail.Initial_Score__c - Decimal.valueOf(kpiDetail.Month1__c);
                        return result.setscale(0);
                    }
                }
            }else{
                if(kpiDetail.Initial_Score__c!=null){
                    if(kpiDetail.Month6__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month6__c) - kpiDetail.Initial_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month6__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month6__c) - kpiDetail.Initial_Score__c)/kpiDetail.Initial_Score__c * 100;
                        return result.setscale(1);
                    }else if(kpiDetail.Month5__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month5__c) - kpiDetail.Initial_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month5__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month5__c) - kpiDetail.Initial_Score__c)/kpiDetail.Initial_Score__c * 100;
                        return result.setscale(1);
                    }else if(kpiDetail.Month4__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month4__c) - kpiDetail.Initial_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month4__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month4__c) - kpiDetail.Initial_Score__c)/kpiDetail.Initial_Score__c * 100;
                        return result.setscale(1);
                    }else if(kpiDetail.Month3__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month3__c) - kpiDetail.Initial_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month3__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month3__c) - kpiDetail.Initial_Score__c)/kpiDetail.Initial_Score__c * 100;
                        return result.setscale(1);
                    }else if(kpiDetail.Month2__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month2__c) - kpiDetail.Initial_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month2__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month2__c) - kpiDetail.Initial_Score__c)/kpiDetail.Initial_Score__c * 100;
                        return result.setscale(1);
                    }else if(kpiDetail.Month1__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month1__c) - kpiDetail.Initial_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month1__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month1__c) - kpiDetail.Initial_Score__c)/kpiDetail.Initial_Score__c * 100;
                        return result.setscale(1);
                    }
                }

            }
            


            return result;
        }
    
        /**
         * [Method Description] COPP Project - calculate for the value of Current vs Target
         * Created by [MinheeKim] on [2024-08-19] for [DPM-5701]
         * Edited by [MinheeKim] on [2024-11-05] for [DPM-5910] change the logic for WOPR Rank : differenciate = Target - Current
        */
        public static Decimal calculateTargetDiff(COPPKPIDetail__c kpiDetail){
            Decimal result = null;
            //[DPM-5910] change the logic for WOPR Rank : differenciate = Target - Current - 11.05.2024
            if(kpiDetail.COPP_KPI__r.Key__c == 'H515' ){
                if(kpiDetail.Target_Score__c!=null){
                    if(kpiDetail.Month6__c!=null){
                        result= kpiDetail.Target_Score__c - Decimal.valueOf(kpiDetail.Month6__c);
                        return result.setscale(0);
                    }else if(kpiDetail.Month5__c!=null ){
                        result= kpiDetail.Target_Score__c - Decimal.valueOf(kpiDetail.Month5__c);
                        return result.setscale(0);
                    }else if(kpiDetail.Month4__c!=null ){
                        result= kpiDetail.Target_Score__c - Decimal.valueOf(kpiDetail.Month4__c);
                        return result.setscale(0);
                    }else if(kpiDetail.Month3__c!=null ){
                        result= kpiDetail.Target_Score__c - Decimal.valueOf(kpiDetail.Month3__c);
                        return result.setscale(0);
                    }else if(kpiDetail.Month2__c!=null ){
                        result= kpiDetail.Target_Score__c - Decimal.valueOf(kpiDetail.Month2__c);
                        return result.setscale(0);
                    }else if(kpiDetail.Month1__c!=null ){
                        result= kpiDetail.Target_Score__c - Decimal.valueOf(kpiDetail.Month1__c);
                        return result.setscale(0);
                    }
                }    
            }else{
                if(kpiDetail.Target_Score__c!=null){
                    if(kpiDetail.Month6__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month6__c) - kpiDetail.Target_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month6__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month6__c) - kpiDetail.Target_Score__c)/kpiDetail.Target_Score__c * 100;
                        return result.setscale(1);
                    }else if(kpiDetail.Month5__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month5__c) - kpiDetail.Target_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month5__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month5__c) - kpiDetail.Target_Score__c)/kpiDetail.Target_Score__c * 100;
                        return result.setscale(1);
                    }else if(kpiDetail.Month4__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month4__c) - kpiDetail.Target_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month4__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month4__c) - kpiDetail.Target_Score__c)/kpiDetail.Target_Score__c * 100;
                        return result.setscale(1);
                    }else if(kpiDetail.Month3__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month3__c) - kpiDetail.Target_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month3__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month3__c) - kpiDetail.Target_Score__c)/kpiDetail.Target_Score__c * 100;
                        return result.setscale(1);
                    }else if(kpiDetail.Month2__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month2__c) - kpiDetail.Target_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month2__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month2__c) - kpiDetail.Target_Score__c)/kpiDetail.Target_Score__c * 100;
                        return result.setscale(1);
                    }else if(kpiDetail.Month1__c!=null && kpiDetail.COPP_KPI__r.isPercent__c){
                        result=Decimal.valueOf(kpiDetail.Month1__c) - kpiDetail.Target_Score__c;
                        return result.setscale(1);
                    }else if(kpiDetail.Month1__c!=null && !kpiDetail.COPP_KPI__r.isPercent__c){
                        result=(Decimal.valueOf(kpiDetail.Month1__c) - kpiDetail.Target_Score__c)/kpiDetail.Target_Score__c * 100;
                        return result.setscale(1);
                    }
                }    
            }
            return result;
        }
        
        public void setMonth(COPPInfo__c coppInfo){
            String month =  coppInfo.Performance_Period__c !=null ? coppInfo.Performance_Period__c.substring(0, 2) : null;
            String year = coppInfo.Performance_Period__c !=null ? coppInfo.Performance_Period__c.substring(coppInfo.Performance_Period__c.length() - 4) : null;
            String yearLong = coppInfo.Performance_Period__c !=null ? coppInfo.Performance_Period__c.substring(coppInfo.Performance_Period__c.length() - 4) : null;
            List<String> monthText = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul','Aug','Sep','Oct','Nov','Dec'};
			List<String> monthLongText = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July','August','September','October','November','December'};
                if(coppInfo.COPP_Performance_Reporting_Month__c!=null){
                    String reportyear =  coppInfo.COPP_Performance_Reporting_Month__c.substring(0, 4);
                    Integer reportmonth =  Integer.valueOf(coppInfo.COPP_Performance_Reporting_Month__c.substring(4, 6));
                    this.reportMonth = monthLongText[reportmonth-1]+' '+reportyear;
                }
                
            if(coppInfo.Performance_Period__c !=null ){
                for(Integer i = 0; i < 12; i++) {
                    String monthString = String.valueOf(i+1).leftPad(2, '0');
                    if(month ==monthString){
                        Integer monthNum = Integer.valueOf(month);
                        this.fromMonth = monthLongText[monthNum-1]+' '+yearLong;
                        this.month1Label = monthText[monthNum-1]+'\n'+year;
                        this.month2Label = Math.mod( monthNum+1, 13 ) > monthNum ? monthText[Math.mod( monthNum+1, 13 )-1]+'\n'+year : monthText[Math.mod( monthNum+1, 13 )]+'\n'+ String.valueOf((Integer.valueOf(year)+1));
                        this.month3Label = Math.mod( monthNum+2, 13 ) > monthNum ? monthText[Math.mod( monthNum+2, 13 )-1]+'\n'+year : monthText[Math.mod( monthNum+2, 13 )]+'\n'+ String.valueOf((Integer.valueOf(year)+1));
                        this.month4Label = Math.mod( monthNum+3, 13 ) > monthNum ? monthText[Math.mod( monthNum+3, 13 )-1]+'\n'+year : monthText[Math.mod( monthNum+3, 13 )]+'\n'+ String.valueOf((Integer.valueOf(year)+1));
                        this.month5Label = Math.mod( monthNum+4, 13 ) > monthNum ? monthText[Math.mod( monthNum+4, 13 )-1]+'\n'+year : monthText[Math.mod( monthNum+4, 13 )]+'\n'+ String.valueOf((Integer.valueOf(year)+1));
                        this.month6Label = Math.mod( monthNum+5, 13 ) > monthNum ? monthText[Math.mod( monthNum+5, 13 )-1]+'\n'+year : monthText[Math.mod( monthNum+5, 13 )]+'\n'+ String.valueOf((Integer.valueOf(year)+1));
                        this.toMonth = Math.mod( monthNum+5, 13 ) > monthNum ? monthLongText[Math.mod( monthNum+5, 13 )-1]+' '+yearLong : monthLongText[Math.mod( monthNum+5, 13 )]+' '+ String.valueOf((Integer.valueOf(yearLong)+1));
                    }
                }    
            }
        }
        
        public void setBrandImage(COPPInfo__c coppInfo){
         
            String year = coppInfo.BrandImageCheckedDate__c !=null ? String.valueOf(coppInfo.BrandImageCheckedDate__c.year()) : null;
            String month = coppInfo.BrandImageCheckedDate__c!=null ? String.valueOf(coppInfo.BrandImageCheckedDate__c.month()).leftPad(2, '0') : null;
            Integer brandImageDate = coppInfo.BrandImageCheckedDate__c!=null ? Integer.valueOf(year+month) : -1;
            Integer currentStartMonth = coppInfo.Performance_Period__c !=null? Integer.valueOf((coppInfo.Performance_Period__c.substring(coppInfo.Performance_Period__c.length() - 4))+(coppInfo.Performance_Period__c.substring(0, 2))) : 0 ;
            
            Integer Diff = brandImageDate - currentStartMonth;
            String reportyear =  coppInfo.COPP_Performance_Reporting_Month__c!=null ? String.valueOf(coppInfo.COPP_Performance_Reporting_Month__c.substring(0, 4)) : null;
            String reportmonth = coppInfo.COPP_Performance_Reporting_Month__c!=null ? String.valueOf(coppInfo.COPP_Performance_Reporting_Month__c.substring(4, 6)):null;

            Integer reportDate = coppInfo.COPP_Performance_Reporting_Month__c !=null? Integer.valueOf(reportyear+reportmonth) : -1;
            Integer DiffReportDate = reportDate - currentStartMonth;
            if(coppInfo.BrandImageCheckedDate__c!=null && coppInfo.Performance_Period__c!=null){

                if(Diff<=0){
                    this.month1BrandImage = DiffReportDate<0 ? null : 'Y';
                    this.month2BrandImage = DiffReportDate-1<0 ? null : 'Y';
                    this.month3BrandImage = DiffReportDate-2<0 ? null : 'Y';
                    this.month4BrandImage = DiffReportDate-3<0 ? null : 'Y';
                    this.month5BrandImage = DiffReportDate-4<0 ? null : 'Y';
                    this.month6BrandImage = DiffReportDate-5<0 ? null : 'Y';
                }else if(Diff ==1){
                    this.month1BrandImage = DiffReportDate<0 ? null : 'N';
                    this.month2BrandImage = DiffReportDate-1<0 ? null : 'Y';
                    this.month3BrandImage = DiffReportDate-2<0 ? null : 'Y';
                    this.month4BrandImage = DiffReportDate-3<0 ? null : 'Y';
                    this.month5BrandImage = DiffReportDate-4<0 ? null : 'Y';
                    this.month6BrandImage = DiffReportDate-5<0 ? null : 'Y';                
                }else if(Diff ==2){
                    this.month1BrandImage = DiffReportDate<0 ? null : 'N';
                    this.month2BrandImage = DiffReportDate-1<0 ? null : 'N';
                    this.month3BrandImage = DiffReportDate-2<0 ? null : 'Y';
                    this.month4BrandImage = DiffReportDate-3<0 ? null : 'Y';
                    this.month5BrandImage = DiffReportDate-4<0 ? null : 'Y';
                    this.month6BrandImage = DiffReportDate-5<0 ? null : 'Y';                
                }else if(Diff ==3){
                    this.month1BrandImage = DiffReportDate<0 ? null : 'N';
                    this.month2BrandImage = DiffReportDate-1<0 ? null : 'N';
                    this.month3BrandImage = DiffReportDate-2<0 ? null : 'N';
                    this.month4BrandImage = DiffReportDate-3<0 ? null : 'Y';
                    this.month5BrandImage = DiffReportDate-4<0 ? null : 'Y';
                    this.month6BrandImage = DiffReportDate-5<0 ? null : 'Y';                
                }else if(Diff ==4){
                    this.month1BrandImage = DiffReportDate<0 ? null : 'N';
                    this.month2BrandImage = DiffReportDate-1<0 ? null : 'N';
                    this.month3BrandImage = DiffReportDate-2<0 ? null : 'N';
                    this.month4BrandImage = DiffReportDate-3<0 ? null : 'N';
                    this.month5BrandImage = DiffReportDate-4<0 ? null : 'Y';
                    this.month6BrandImage = DiffReportDate-5<0 ? null : 'Y';                
                }else if(Diff ==5){
                    this.month1BrandImage = DiffReportDate<0 ? null : 'N';
                    this.month2BrandImage = DiffReportDate-1<0 ? null : 'N';
                    this.month3BrandImage = DiffReportDate-2<0 ? null : 'N';
                    this.month4BrandImage = DiffReportDate-3<0 ? null : 'N';
                    this.month5BrandImage = DiffReportDate-4<0 ? null : 'N';
                    this.month6BrandImage = DiffReportDate-5<0 ? null : 'Y';                
                }else if(Diff > 5){
                    this.month1BrandImage = DiffReportDate<0 ? null : 'N';
                    this.month2BrandImage = DiffReportDate-1<0 ? null : 'N';
                    this.month3BrandImage = DiffReportDate-2<0 ? null : 'N';
                    this.month4BrandImage = DiffReportDate-3<0 ? null : 'N';
                    this.month5BrandImage = DiffReportDate-4<0 ? null : 'N';
                    this.month6BrandImage = DiffReportDate-5<0 ? null : 'N';                
                }
            }else{
                this.month1BrandImage = DiffReportDate<0 || currentStartMonth==0 ? null : 'N';
                this.month2BrandImage = DiffReportDate-1<0 || currentStartMonth==0 ? null : 'N';
                this.month3BrandImage = DiffReportDate-2<0 || currentStartMonth==0 ? null : 'N';
                this.month4BrandImage = DiffReportDate-3<0 || currentStartMonth==0 ? null : 'N';
                this.month5BrandImage = DiffReportDate-4<0 || currentStartMonth==0 ? null : 'N';
                this.month6BrandImage = DiffReportDate-5<0 || currentStartMonth==0 ? null : 'N'; 
            }
            
            
        }

    
    
    }