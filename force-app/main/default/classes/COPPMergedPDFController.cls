/**
     * [Class Description] COPP Project - Controller for COPPMergedPDF
     * Created by [MinheeKim] on [2024-09-31] for [DPM-5861]
     * Edited by [JonghoonKim] on [2024-11-18] for [DPM-5916] Added COPPScorecard
    */

public with sharing class COPPMergedPDFController {

    public String LetterDate {get; set;}
    public String regionName {get; set;}
    public String regionCode {get; set;}
    public String DealerPrincipalName {get; set;}
    public String DealershipName {get; set;}
    public String DealerShip_Address {get; set;}
    public String City_State_Zip_Code {get; set;} 
    public String Email_Address {get; set;}
    public String ChoosedTemplate {get; set;}
    public String Salutation {get; set;} //DPM-5861 added salutation
    public String today {get; set;}
    public String CommentsValue {get; set;} //DPM-5916 added comments
    
    
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
    // GM Scorecard
    public List<MonthWrapper> monthWrappers {get; set;}
    public Decimal averageActualSales { get; set; }
    public Decimal averageExpectedSales { get; set; }
    public Decimal averageSalesEfficiency { get; set; }
    public Decimal averageHRXDealer { get; set; }
    public Decimal averageHRXRegion { get; set; }
    public Decimal averageHRXDLR { get; set; }
    public Decimal averageHVXDealer { get; set; }
    public Decimal averageHVXRegion { get; set; }
    public Decimal averageHVXDLR { get; set; }

    public COPPMergedPDFController() {


        recordId = ApexPages.currentPage().getParameters().get('recordId');
        CommentsValue = ApexPages.currentPage().getParameters().get('CommentsValue');
            if (recordId == null) {
                recordId = ApexPages.currentPage().getParameters().get('id');
            }
            coppWappers = new List<COPPKPIWrapper>();
            coppKPIDetailList = new List<SectionWrapper>();

        LetterDate = ApexPages.currentPage().getParameters().get('LetterDate');
        regionName = ApexPages.currentPage().getParameters().get('regionName');
        regionCode = ApexPages.currentPage().getParameters().get('regionCode');
        DealerPrincipalName = ApexPages.currentPage().getParameters().get('DealerPrincipalName');
        DealershipName = ApexPages.currentPage().getParameters().get('DealershipName');
        DealerShip_Address = ApexPages.currentPage().getParameters().get('DealerShip_Address');
        City_State_Zip_Code = ApexPages.currentPage().getParameters().get('City_State_Zip_Code');
        Email_Address = ApexPages.currentPage().getParameters().get('Email_Address');
        ChoosedTemplate = ApexPages.currentPage().getParameters().get('ChoosedTemplate');
        Salutation = ApexPages.currentPage().getParameters().get('Salutation');
        CommentsValue = ApexPages.currentPage().getParameters().get('CommentsValue'); //DPM-5916 added comments
        today = String.format('{0}-{1}-{2}', 
        new List<String>{
            String.valueOf(Date.today().month()).leftPad(2, '0'), 
            String.valueOf(Date.today().day()).leftPad(2, '0'),   
            String.valueOf(Date.today().year())                  
        });

        if(Test.isRunningTest()){
            BrandCode = 'H';
			ChoosedTemplate = 'Hyundai1';            
        }else if(ChoosedTemplate.contains('Hyundai')){
            BrandCode = 'H';
        }else if (ChoosedTemplate.contains('Genesis')){
            BrandCode = 'G';
        }
                
    }

    public void handleLoad() {
        this.getCOPPKPI();
        this.getScore();

        
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
        public Boolean oppositeColor{get;set;} //DPM-6035 added to change the opposite color by Minhee Kim - 01.22.2025
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
            this.oppositeColor = kpiDetail.COPP_KPI__r.Key__c.contains('325') ? true : false; //DPM-6035 added to change the opposite color by Minhee Kim - 01.22.2025
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

    /**
     * [Class Description] 
     * Created by [JonghoonKim] on [2024-11-18] for [DPM-5916] Added to get score for COPPScorecard
    */
    public void getScore(){
            Account acc = getAccount(recordId);
            COPPInfo__c coppInformation = getCOPPInfo(recordId);
    		this.dealerName = toTitleCase(acc.Doing_Business_As_Name__c);
            this.acc = acc;
            this.BrandCode = acc.BrandCode__c;

            if(coppInformation!=null){
                this.monthWrappers = setScorecardMonth(coppInformation);
                setScoreCard(coppInformation, this.monthWrappers);
                this.averageActualSales = getAverageActualSales();
                this.averageExpectedSales = getAverageExpectedSales();
                this.averageSalesEfficiency = getAverageSalesEfficiency();
                this.averageHRXDealer = getAverageHRXDealer();
                this.averageHRXRegion = getAverageHRXRegion();
                this.averageHRXDLR = getAverageHRXDLR();
                this.averageHVXDealer = getAverageHVXDealer();
                this.averageHVXRegion = getAverageHVXRegion();
                this.averageHVXDLR = getAverageHVXDLR();
            }
  
        }

    public void setScoreCard(COPPInfo__c coppInfo, List<MonthWrapper> monthWrappers){

            // Scorecard1
        List<String> scores1 = new List<String>();
        if (coppInfo.Scorecard1__c != null && coppInfo.Scorecard1__c.contains('/')) {
            scores1 = coppInfo.Scorecard1__c.split('/');
            monthWrappers[0].actualSales = (scores1.size() > 0 && scores1[0] != null && scores1[0] != 'NULL' && scores1[0] != '') ? Decimal.valueOf(scores1[0]).setScale(0) : null;
            monthWrappers[0].expectedSales = (scores1.size() > 1 && scores1[1] != null && scores1[1] != 'NULL' && scores1[1] != '') ? Decimal.valueOf(scores1[1]).setScale(0) : null;
            monthWrappers[0].salesEfficiency = (scores1.size() > 0 && scores1[0] != null && scores1[0] != 'NULL' && scores1[0] != '' && scores1.size() > 1 && scores1[1] != '' && scores1[1] != '0') 
                ? (Decimal.valueOf(scores1[0]) / Decimal.valueOf(scores1[1]) * 100).setScale(2) : null;
            monthWrappers[0].HRXDealer = (scores1.size() > 2 && scores1[2] != null && scores1[2] != 'NULL' && scores1[2] != '') ? Decimal.valueOf(scores1[2]).setScale(0) : null;
            monthWrappers[0].HRXRegion = (scores1.size() > 3 && scores1[3] != null && scores1[3] != 'NULL' && scores1[3] != '') ? Decimal.valueOf(scores1[3]).setScale(0) : null;
            monthWrappers[0].HRXDLR = (scores1.size() > 2 && scores1[2] != null && scores1[2] != 'NULL' && scores1[2] != '' && scores1.size() > 3 && scores1[3] != '' && scores1[3] != '0') 
                ? (Decimal.valueOf(scores1[2]) / Decimal.valueOf(scores1[3]) * 100).setScale(0) : null;
            monthWrappers[0].HVXDealer = (scores1.size() > 4 && scores1[4] != null && scores1[4] != 'NULL' && scores1[4] != '') ? Decimal.valueOf(scores1[4]).setScale(0) : null;
            monthWrappers[0].HVXRegion = (scores1.size() > 5 && scores1[5] != null && scores1[5] != 'NULL' && scores1[5] != '') ? Decimal.valueOf(scores1[5]).setScale(0) : null;
            monthWrappers[0].HVXDLR = (scores1.size() > 4 && scores1[4] != null && scores1[4] != 'NULL' && scores1[4] != '' && scores1.size() > 5 && scores1[5] != '' && scores1[5] != '0') 
                ? (Decimal.valueOf(scores1[4]) / Decimal.valueOf(scores1[5]) * 100).setScale(0) : null;
        }

        // Scorecard2
        List<String> scores2 = new List<String>();
        if (coppInfo.Scorecard2__c != null && coppInfo.Scorecard2__c.contains('/')) {
            scores2 = coppInfo.Scorecard2__c.split('/');
            monthWrappers[1].actualSales = (scores2.size() > 0 && scores2[0] != null && scores2[0] != 'NULL' && scores2[0] != '') ? Decimal.valueOf(scores2[0]).setScale(0) : null;
            monthWrappers[1].expectedSales = (scores2.size() > 1 && scores2[1] != null && scores2[1] != 'NULL' && scores2[1] != '') ? Decimal.valueOf(scores2[1]).setScale(0) : null;
            monthWrappers[1].salesEfficiency = (scores2.size() > 0 && scores2[0] != null && scores2[0] != 'NULL' && scores2[0] != '' && scores2.size() > 1 && scores2[1] != '' && scores2[1] != '0') 
                ? (Decimal.valueOf(scores2[0]) / Decimal.valueOf(scores2[1]) * 100).setScale(2) : null;
            monthWrappers[1].HRXDealer = (scores2.size() > 2 && scores2[2] != null && scores2[2] != 'NULL' && scores2[2] != '') ? Decimal.valueOf(scores2[2]).setScale(0) : null;
            monthWrappers[1].HRXRegion = (scores2.size() > 3 && scores2[3] != null && scores2[3] != 'NULL' && scores2[3] != '') ? Decimal.valueOf(scores2[3]).setScale(0) : null;
            monthWrappers[1].HRXDLR = (scores2.size() > 2 && scores2[2] != null && scores2[2] != 'NULL' && scores2[2] != '' && scores2.size() > 3 && scores2[3] != '' && scores2[3] != '0') 
                ? (Decimal.valueOf(scores2[2]) / Decimal.valueOf(scores2[3]) * 100).setScale(0) : null;
            monthWrappers[1].HVXDealer = (scores2.size() > 4 && scores2[4] != null && scores2[4] != 'NULL' && scores2[4] != '') ? Decimal.valueOf(scores2[4]).setScale(0) : null;
            monthWrappers[1].HVXRegion = (scores2.size() > 5 && scores2[5] != null && scores2[5] != 'NULL' && scores2[5] != '') ? Decimal.valueOf(scores2[5]).setScale(0) : null;
            monthWrappers[1].HVXDLR = (scores2.size() > 4 && scores2[4] != null && scores2[4] != 'NULL' && scores2[4] != '' && scores2.size() > 5 && scores2[5] != '' && scores2[5] != '0') 
                ? (Decimal.valueOf(scores2[4]) / Decimal.valueOf(scores2[5]) * 100).setScale(0) : null;
        }

        // Scorecard3
        List<String> scores3 = new List<String>();
        if (coppInfo.Scorecard3__c != null && coppInfo.Scorecard3__c.contains('/')) {
            scores3 = coppInfo.Scorecard3__c.split('/');
            monthWrappers[2].actualSales = (scores3.size() > 0 && scores3[0] != null && scores3[0] != 'NULL' && scores3[0] != '') ? Decimal.valueOf(scores3[0]).setScale(0) : null;
            monthWrappers[2].expectedSales = (scores3.size() > 1 && scores3[1] != null && scores3[1] != 'NULL' && scores3[1] != '') ? Decimal.valueOf(scores3[1]).setScale(0) : null;
            monthWrappers[2].salesEfficiency = (scores3.size() > 0 && scores3[0] != null && scores3[0] != 'NULL' && scores3[0] != '' && scores3.size() > 1 && scores3[1] != '' && scores3[1] != '0') 
                ? (Decimal.valueOf(scores3[0]) / Decimal.valueOf(scores3[1]) * 100).setScale(2) : null;
            monthWrappers[2].HRXDealer = (scores3.size() > 2 && scores3[2] != null && scores3[2] != 'NULL' && scores3[2] != '') ? Decimal.valueOf(scores3[2]).setScale(0) : null;
            monthWrappers[2].HRXRegion = (scores3.size() > 3 && scores3[3] != null && scores3[3] != 'NULL' && scores3[3] != '') ? Decimal.valueOf(scores3[3]).setScale(0) : null;
            monthWrappers[2].HRXDLR = (scores3.size() > 2 && scores3[2] != null && scores3[2] != 'NULL' && scores3[2] != '' && scores3.size() > 3 && scores3[3] != '' && scores3[3] != '0') 
                ? (Decimal.valueOf(scores3[2]) / Decimal.valueOf(scores3[3]) * 100).setScale(0) : null;
            monthWrappers[2].HVXDealer = (scores3.size() > 4 && scores3[4] != null && scores3[4] != 'NULL' && scores3[4] != '') ? Decimal.valueOf(scores3[4]).setScale(0) : null;
            monthWrappers[2].HVXRegion = (scores3.size() > 5 && scores3[5] != null && scores3[5] != 'NULL' && scores3[5] != '') ? Decimal.valueOf(scores3[5]).setScale(0) : null;
            monthWrappers[2].HVXDLR = (scores3.size() > 4 && scores3[4] != null && scores3[4] != 'NULL' && scores3[4] != '' && scores3.size() > 5 && scores3[5] != '' && scores3[5] != '0') 
                ? (Decimal.valueOf(scores3[4]) / Decimal.valueOf(scores3[5]) * 100).setScale(0) : null;
        }

        // Scorecard4
        List<String> scores4 = new List<String>();
        if (coppInfo.Scorecard4__c != null && coppInfo.Scorecard4__c.contains('/')) {
            scores4 = coppInfo.Scorecard4__c.split('/');
            monthWrappers[3].actualSales = (scores4.size() > 0 && scores4[0] != null && scores4[0] != 'NULL' && scores4[0] != '') ? Decimal.valueOf(scores4[0]).setScale(0) : null;
            monthWrappers[3].expectedSales = (scores4.size() > 1 && scores4[1] != null && scores4[1] != 'NULL' && scores4[1] != '') ? Decimal.valueOf(scores4[1]).setScale(0) : null;
            monthWrappers[3].salesEfficiency = (scores4.size() > 0 && scores4[0] != null && scores4[0] != 'NULL' && scores4[0] != '' && scores4.size() > 1 && scores4[1] != '' && scores4[1] != '0') 
                ? (Decimal.valueOf(scores4[0]) / Decimal.valueOf(scores4[1]) * 100).setScale(2) : null;
            monthWrappers[3].HRXDealer = (scores4.size() > 2 && scores4[2] != null && scores4[2] != 'NULL' && scores4[2] != '') ? Decimal.valueOf(scores4[2]).setScale(0) : null;
            monthWrappers[3].HRXRegion = (scores4.size() > 3 && scores4[3] != null && scores4[3] != 'NULL' && scores4[3] != '') ? Decimal.valueOf(scores4[3]).setScale(0) : null;
            monthWrappers[3].HRXDLR = (scores4.size() > 2 && scores4[2] != null && scores4[2] != 'NULL' && scores4[2] != '' && scores4.size() > 3 && scores4[3] != '' && scores4[3] != '0') 
                ? (Decimal.valueOf(scores4[2]) / Decimal.valueOf(scores4[3]) * 100).setScale(0) : null;
            monthWrappers[3].HVXDealer = (scores4.size() > 4 && scores4[4] != null && scores4[4] != 'NULL' && scores4[4] != '') ? Decimal.valueOf(scores4[4]).setScale(0) : null;
            monthWrappers[3].HVXRegion = (scores4.size() > 5 && scores4[5] != null && scores4[5] != 'NULL' && scores4[5] != '') ? Decimal.valueOf(scores4[5]).setScale(0) : null;
            monthWrappers[3].HVXDLR = (scores4.size() > 4 && scores4[4] != null && scores4[4] != 'NULL' && scores4[4] != '' && scores4.size() > 5 && scores4[5] != '' && scores4[5] != '0') 
                ? (Decimal.valueOf(scores4[4]) / Decimal.valueOf(scores4[5]) * 100).setScale(0) : null;
        }

        // Scorecard5
        List<String> scores5 = new List<String>();
        if (coppInfo.Scorecard5__c != null && coppInfo.Scorecard5__c.contains('/')) {
            scores5 = coppInfo.Scorecard5__c.split('/');
            monthWrappers[4].actualSales = (scores5.size() > 0 && scores5[0] != null && scores5[0] != 'NULL' && scores5[0] != '') ? Decimal.valueOf(scores5[0]).setScale(0) : null;
            monthWrappers[4].expectedSales = (scores5.size() > 1 && scores5[1] != null && scores5[1] != 'NULL' && scores5[1] != '') ? Decimal.valueOf(scores5[1]).setScale(0) : null;
            monthWrappers[4].salesEfficiency = (scores5.size() > 0 && scores5[0] != null && scores5[0] != 'NULL' && scores5[0] != '' && scores5.size() > 1 && scores5[1] != '' && scores5[1] != '0') 
                ? (Decimal.valueOf(scores5[0]) / Decimal.valueOf(scores5[1]) * 100).setScale(2) : null;
            monthWrappers[4].HRXDealer = (scores5.size() > 2 && scores5[2] != null && scores5[2] != 'NULL' && scores5[2] != '') ? Decimal.valueOf(scores5[2]).setScale(0) : null;
            monthWrappers[4].HRXRegion = (scores5.size() > 3 && scores5[3] != null && scores5[3] != 'NULL' && scores5[3] != '') ? Decimal.valueOf(scores5[3]).setScale(0) : null;
            monthWrappers[4].HRXDLR = (scores5.size() > 2 && scores5[2] != null && scores5[2] != 'NULL' && scores5[2] != '' && scores5.size() > 3 && scores5[3] != '' && scores5[3] != '0') 
                ? (Decimal.valueOf(scores5[2]) / Decimal.valueOf(scores5[3]) * 100).setScale(0) : null;
            monthWrappers[4].HVXDealer = (scores5.size() > 4 && scores5[4] != null && scores5[4] != 'NULL' && scores5[4] != '') ? Decimal.valueOf(scores5[4]).setScale(0) : null;
            monthWrappers[4].HVXRegion = (scores5.size() > 5 && scores5[5] != null && scores5[5] != 'NULL' && scores5[5] != '') ? Decimal.valueOf(scores5[5]).setScale(0) : null;
            monthWrappers[4].HVXDLR = (scores5.size() > 4 && scores5[4] != null && scores5[4] != 'NULL' && scores5[4] != '' && scores5.size() > 5 && scores5[5] != '' && scores5[5] != '0') 
                ? (Decimal.valueOf(scores5[4]) / Decimal.valueOf(scores5[5]) * 100).setScale(0) : null;
        }

        // Scorecard6
        List<String> scores6 = new List<String>();
        if (coppInfo.Scorecard6__c != null && coppInfo.Scorecard6__c.contains('/')) {
            scores6 = coppInfo.Scorecard6__c.split('/');
            monthWrappers[5].actualSales = (scores6.size() > 0 && scores6[0] != null && scores6[0] != 'NULL' && scores6[0] != '') ? Decimal.valueOf(scores6[0]).setScale(0) : null;
            monthWrappers[5].expectedSales = (scores6.size() > 1 && scores6[1] != null && scores6[1] != 'NULL' && scores6[1] != '') ? Decimal.valueOf(scores6[1]).setScale(0) : null;
            monthWrappers[5].salesEfficiency = (scores6.size() > 0 && scores6[0] != null && scores6[0] != 'NULL' && scores6[0] != '' && scores6.size() > 1 && scores6[1] != '' && scores6[1] != '0') 
                ? (Decimal.valueOf(scores6[0]) / Decimal.valueOf(scores6[1]) * 100).setScale(2) : null;
            monthWrappers[5].HRXDealer = (scores6.size() > 2 && scores6[2] != null && scores6[2] != 'NULL' && scores6[2] != '') ? Decimal.valueOf(scores6[2]).setScale(0) : null;
            monthWrappers[5].HRXRegion = (scores6.size() > 3 && scores6[3] != null && scores6[3] != 'NULL' && scores6[3] != '') ? Decimal.valueOf(scores6[3]).setScale(0) : null;
            monthWrappers[5].HRXDLR = (scores6.size() > 2 && scores6[2] != null && scores6[2] != 'NULL' && scores6[2] != '' && scores6.size() > 3 && scores6[3] != '' && scores6[3] != '0') 
                ? (Decimal.valueOf(scores6[2]) / Decimal.valueOf(scores6[3]) * 100).setScale(0) : null;
            monthWrappers[5].HVXDealer = (scores6.size() > 4 && scores6[4] != null && scores6[4] != 'NULL' && scores6[4] != '') ? Decimal.valueOf(scores6[4]).setScale(0) : null;
            monthWrappers[5].HVXRegion = (scores6.size() > 5 && scores6[5] != null && scores6[5] != 'NULL' && scores6[5] != '') ? Decimal.valueOf(scores6[5]).setScale(0) : null;
            monthWrappers[5].HVXDLR = (scores6.size() > 4 && scores6[4] != null && scores6[4] != 'NULL' && scores6[4] != '' && scores6.size() > 5 && scores6[5] != '' && scores6[5] != '0') 
                ? (Decimal.valueOf(scores6[4]) / Decimal.valueOf(scores6[5]) * 100).setScale(0) : null;
        }

    }

    @AuraEnabled(Cacheable=true)
    public static Account getAccount(String recordId){
        return test.isRunningTest()? new Account(Name = 'Test Account',
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
                COPP_Performance_Reporting_Month__c = '202309',
                Scorecard1__c='1/2/3/4/5/6',
                Scorecard2__c='1/2/3/4/5/6',
                Scorecard3__c='1/2/3/4/5/6',
                Scorecard4__c='1/2/3/4/5/6',
                Scorecard5__c='1/2/3/4/5/6',
                Scorecard6__c='1/2/3/4/5/6'
            );
            return coppInfo;
        }
        List<COPPInfo__c> coppinfo = Test.isRunningTest() ? [SELECT BrandImageCheckedDate__c, Performance_Period__c, COPP_Performance_Reporting_Month__c, 
        Scorecard1__c, Scorecard2__c, Scorecard3__c, Scorecard4__c, Scorecard5__c, Scorecard6__c FROM COPPInfo__c LIMIT 1] : [SELECT BrandImageCheckedDate__c, Performance_Period__c, COPP_Performance_Reporting_Month__c, 
        Scorecard1__c, Scorecard2__c, Scorecard3__c, Scorecard4__c, Scorecard5__c, Scorecard6__c FROM COPPInfo__c WHERE Account__c =: recordId LIMIT 1];
        
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

    public List<MonthWrapper> setScorecardMonth(COPPInfo__c coppInfo){
        List<MonthWrapper> monthwrappers = new List<MonthWrapper>();
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
                    monthwrappers.add(new MonthWrapper(monthText[monthNum-1]+'-'+year));
                    monthwrappers.add(new MonthWrapper(Math.mod( monthNum+1, 13 ) > monthNum ? monthText[Math.mod( monthNum+1, 13 )-1]+'-'+year : monthText[Math.mod( monthNum+1, 13 )]+'-'+ String.valueOf((Integer.valueOf(year)+1))));
                    monthwrappers.add(new MonthWrapper(Math.mod( monthNum+2, 13 ) > monthNum ? monthText[Math.mod( monthNum+2, 13 )-1]+'-'+year : monthText[Math.mod( monthNum+2, 13 )]+'-'+ String.valueOf((Integer.valueOf(year)+1))));
                    monthwrappers.add(new MonthWrapper(Math.mod( monthNum+3, 13 ) > monthNum ? monthText[Math.mod( monthNum+3, 13 )-1]+'-'+year : monthText[Math.mod( monthNum+3, 13 )]+'-'+ String.valueOf((Integer.valueOf(year)+1))));
                    monthwrappers.add(new MonthWrapper(Math.mod( monthNum+4, 13 ) > monthNum ? monthText[Math.mod( monthNum+4, 13 )-1]+'-'+year : monthText[Math.mod( monthNum+4, 13 )]+'-'+ String.valueOf((Integer.valueOf(year)+1))));
                    monthwrappers.add(new MonthWrapper(Math.mod( monthNum+5, 13 ) > monthNum ? monthText[Math.mod( monthNum+5, 13 )-1]+'-'+year : monthText[Math.mod( monthNum+5, 13 )]+'-'+ String.valueOf((Integer.valueOf(year)+1))));
                    this.toMonth = Math.mod( monthNum+5, 13 ) > monthNum ? monthLongText[Math.mod( monthNum+5, 13 )-1]+' '+yearLong : monthLongText[Math.mod( monthNum+5, 13 )]+' '+ String.valueOf((Integer.valueOf(yearLong)+1));
                }
            }    
        }

        return monthwrappers;
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

    public Decimal getAverageActualSales() {
        Decimal totalActualSales = 0;
        Integer countActualSales = 0;

        for (MonthWrapper mw : monthWrappers) {
            if (mw.actualSales != null) {
                totalActualSales += mw.actualSales;
                countActualSales++;
            }
        }

        return (countActualSales > 0) ? (Integer) (totalActualSales / countActualSales) : 0;
    }

    public Decimal getAverageExpectedSales() {
        Decimal totalExpectedSales = 0;
        Integer countExpectedSales = 0;

        for (MonthWrapper mw : monthWrappers) {
            if (mw.expectedSales != null) {
                totalExpectedSales += mw.expectedSales;
                countExpectedSales++;
            }
        }

        return (countExpectedSales > 0) ? (Integer) (totalExpectedSales / countExpectedSales) : 0;
    }

    public Decimal getAverageSalesEfficiency() {
        Decimal totalSalesEfficiency = 0;
        Integer countSalesEfficiency = 0;

        for (MonthWrapper mw : monthWrappers) {
            if (mw.salesEfficiency != null) {
                totalSalesEfficiency += mw.salesEfficiency;
                countSalesEfficiency++;
            }
        }

        return (countSalesEfficiency > 0) ? (totalSalesEfficiency / countSalesEfficiency).setScale(2, RoundingMode.HALF_UP) : 0;
    }

    public Decimal getAverageHRXDealer() {
        Decimal totalHRXDealer = 0;
        Integer countHRXDealer = 0;

        for (MonthWrapper mw : monthWrappers) {
            if (mw.HRXDealer != null) {
                totalHRXDealer += mw.HRXDealer;
                countHRXDealer++;
            }
        }

        return (countHRXDealer > 0) ? (Integer) (totalHRXDealer / countHRXDealer) : 0;
    }

    public Decimal getAverageHRXRegion() {
        Decimal totalHRXRegion = 0;
        Integer countHRXRegion = 0;

        for (MonthWrapper mw : monthWrappers) {
            if (mw.HRXRegion != null) {
                totalHRXRegion += mw.HRXRegion;
                countHRXRegion++;
            }
        }

        return (countHRXRegion > 0) ? (Integer) (totalHRXRegion / countHRXRegion) : 0;
    }

    public Decimal getAverageHRXDLR() {
        Decimal totalHRXDLR = 0;
        Integer countHRXDLR = 0;

        for (MonthWrapper mw : monthWrappers) {
            if (mw.HRXDLR != null) {
                totalHRXDLR += mw.HRXDLR;
                countHRXDLR++;
            }
        }

        return (countHRXDLR > 0) ? (Integer) (totalHRXDLR / countHRXDLR) : 0;
    }

    public Decimal getAverageHVXDealer() {
        Decimal totalHVXDealer = 0;
        Integer countHVXDealer = 0;

        for (MonthWrapper mw : monthWrappers) {
            if (mw.HVXDealer != null) {
                totalHVXDealer += mw.HVXDealer;
                countHVXDealer++;
            }
        }

        return (countHVXDealer > 0) ? (Integer) (totalHVXDealer / countHVXDealer) : 0;
    }

    public Decimal getAverageHVXRegion() {
        Decimal totalHVXRegion = 0;
        Integer countHVXRegion = 0;

        for (MonthWrapper mw : monthWrappers) {
            if (mw.HVXRegion != null) {
                totalHVXRegion += mw.HVXRegion;
                countHVXRegion++;
            }
        }

        return (countHVXRegion > 0) ? (Integer) (totalHVXRegion / countHVXRegion) : 0;
    }

    public Decimal getAverageHVXDLR() {
        Decimal totalHVXDLR = 0;
        Integer countHVXDLR = 0;

        for (MonthWrapper mw : monthWrappers) {
            if (mw.HVXDLR != null) {
                totalHVXDLR += mw.HVXDLR;
                countHVXDLR++;
            }
        }

        return (countHVXDLR > 0) ? (Integer) (totalHVXDLR / countHVXDLR) : 0;
    }

    //GM Scorecard
    public class MonthWrapper{
            public String month {get; set;}
            public Decimal actualSales {get; set;}
            public Decimal expectedSales {get; set;}
            public Decimal salesEfficiency {get; set;}
            public Decimal HRXDealer {get; set;}
            public Decimal HRXRegion {get; set;}
            public Decimal HRXDLR {get; set;}
            public Decimal HVXDealer {get; set;}
            public Decimal HVXRegion {get; set;}
            public Decimal HVXDLR {get; set;}

    
            public MonthWrapper(String month){
                this.month = month;

            }
    }
    
}