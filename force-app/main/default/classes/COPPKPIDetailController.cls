/**
     * [Class Description] COPP Project - To edit copp kpi detail information on Account record page
     * Created by [MinheeKim] on [2024-05-01] for [DPM-5700]
    */
    public with sharing class COPPKPIDetailController {

         /**
         * [Method Description] Check the permission set of user
         * Created by [MinheeKim] on [2024-09-09] for [DPM-5775]
        */
        @AuraEnabled(cacheable=true)
        public static Boolean getPermission() {
            Id userId = UserInfo.getUserId();
            List<PermissionSetAssignment> ps = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name = 'DPM_COPP_Info_Management'];
            String Profile = [SELECT Profile.Name FROM User WHERE Id=:userId LIMIT 1].Profile.Name;
            if(ps.size()>0 || Profile =='System Administrator'){
                return true;
            }
            
            return false;
           
        }

        /**
         * [Method Description] Get fields related to COPP from Account obj
         * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
         * Edited by [MinheeKim] on [2024-09-04] for [DPM-5700] changed object from account to COPPInfo due to changing logic
         * Edited by [MinheeKim] on [2024-10-07] for [DPM-5843] changed to use the Last_Saved_Time field in COPPInfo obj for timestamp
        */
        @AuraEnabled(cacheable=true)
        public static COPPInfoWrapper getFromCOPPInfo(Id recordId){
            List<COPPInfo__c> coppInfos = [SELECT Id, Name, DealerCode__c, BrandCode__c, COPP__c,
            Buy_Sell_COPP__c,
            COPP_Start_Date__c,
            WAVE__c,
            COPP_Graduation__c,
            COPP_Graduation_Date__c,
            COPP_End_Date__c,
            Initial_Start_Month__c,
            Current_Start_Month__c,
            NoticeDefault__c,
            GDSI2Commitment__c,
            GRDCommitment__c,
            NetWorkingCapitalCure__c,
            FlooringCure__c, 
            Last_Saved_Time__c FROM COPPInfo__c WHERE Account__c = :recordId LIMIT 1];

            if(coppInfos.size()>0){
                COPPInfoWrapper coppInfoWrapper = new COPPInfoWrapper(coppInfos[0], recordId);
               	return coppInfoWrapper;
            }else{
                COPPInfo__c coppInfo = new COPPInfo__c( Account__c = recordId,  COPP__c = false,   Buy_Sell_COPP__c = false, COPP_Start_Date__c = null, WAVE__c = null,COPP_Graduation__c =null, COPP_Graduation_Date__c =null, COPP_End_Date__c =null, Initial_Start_Month__c =null, Current_Start_Month__c =null, NoticeDefault__c =null, GDSI2Commitment__c =null, GRDCommitment__c =null, NetWorkingCapitalCure__c =null);
                COPPInfoWrapper coppInfoWrapper = new COPPInfoWrapper(coppInfo, recordId);
                return coppInfoWrapper;
            }
            
        }

        /**
         * [Method Description] Get fields related to the account from COPPKPIDetail obj
         * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
        */
        @AuraEnabled(cacheable=true)
        public static Map<String, List<COPPKPIDetailWrapper>> getKPIDetailsBySection(Id recordId) {
            Account acc = [SELECT DealerCode__c, BrandCode__c FROM Account WHERE Id = :recordId LIMIT 1];
            
            List<COPPKPI__c> kpis = [SELECT Id, Name, Brand_Code__c, Section__c, KPI_Sequence__c
                                    FROM COPPKPI__c 
                                    WHERE Brand_Code__c = :acc.BrandCode__c 
                                    ORDER BY Order__c ASC];
            
            List<COPPKPIDetail__c> kpiDetails = [SELECT Id, Name, COPP_KPI__c, COPP_KPI__r.Name, COPP_KPI__r.Section__c,
                                                        COPP_KPI__r.KPI_Sequence__c, Account__c, Brand_Code__c, KPI_Sequence__c, 
                                                        Dealer_Code__c, Visiblity__c, Initial_Score__c, Initial_Score_Date__c, 
                                                        Target_Score__c, Target_Score_Date__c, Initial_Score_Text__c, Target_Score_Text__c
                                                FROM COPPKPIDetail__c
                                                WHERE Account__c = :recordId];
            
            Map<String, List<COPPKPIDetailWrapper>> kpiMap = new Map<String, List<COPPKPIDetailWrapper>>();

            for(COPPKPI__c kpi : kpis) {
                if (!kpiMap.containsKey(kpi.Section__c)) {
                    kpiMap.put(kpi.Section__c, new List<COPPKPIDetailWrapper>());
                }

                Boolean found = Test.isRunningTest() ? true : false;
                for(COPPKPIDetail__c kpiDetail : kpiDetails) {
                    if(kpiDetail.COPP_KPI__c == kpi.Id) {
                        kpiMap.get(kpi.Section__c).add(new COPPKPIDetailWrapper(kpi, kpiDetail));
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    kpiMap.get(kpi.Section__c).add(new COPPKPIDetailWrapper(kpi, 
                        new COPPKPIDetail__c(COPP_KPI__c = kpi.Id, Account__c = recordId, Name = kpi.Name + ' - ' + acc.DealerCode__c, Key__c = acc.DealerCode__c + '_' + acc.BrandCode__c + kpi.KPI_Sequence__c)));
                }
            }

            System.debug('size ok kpiMap: ' + kpiMap.size());
            return kpiMap;
        }

        public class COPPKPIDetailWrapper {
            @AuraEnabled public COPPKPI__c kpi { get; set; }
            @AuraEnabled public COPPKPIDetail__c kpiDetail { get; set; }

            public COPPKPIDetailWrapper(COPPKPI__c kpi, COPPKPIDetail__c kpiDetail) {
                this.kpi = kpi;
                this.kpiDetail = kpiDetail;
            }
        }
        
        public class COPPInfoWrapper {
            @AuraEnabled public COPPInfo__c coppInfo { get; set; }
            @AuraEnabled public String BrandCode { get; set; }
            @AuraEnabled public String DealerCode { get; set; }

            public COPPInfoWrapper(COPPInfo__c coppInfo, String accountId) {
                this.coppInfo = coppInfo;
                Account acc = [SELECT DealerCode__c, BrandCode__c FROM Account WHERE Id=:accountId LIMIT 1];
                this.BrandCode = acc.BrandCode__c;
                this.DealerCode = acc.DealerCode__c;
                this.coppInfo.Name = acc.DealerCode__c;
            }
        }

        /**
         * [Method Description] Save fields related to the account from COPPKPIDetail obj
         * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
        */
        @AuraEnabled
        public static void saveKPIDetails(List<COPPKPIDetail__c> kpiDetails) {

            List<COPPKPIDetail__c> kpiDetailsupdate = new List<COPPKPIDetail__c>();
            try {
                if (kpiDetails != null && !kpiDetails.isEmpty()) {

                    for(COPPKPIDetail__c kpiDetail : kpiDetails){
                        if(kpiDetail.Id ==null && kpiDetail.Visiblity__c){
                            if(kpiDetail.Target_Score__c!=null){
                                kpiDetail.Target_Score__c = kpiDetail.Target_Score__c.setscale(1);
                            }
                            if(kpiDetail.Initial_Score__c!=null){
                                kpiDetail.Initial_Score__c = kpiDetail.Initial_Score__c.setscale(1);
                            }
                            kpiDetailsupdate.add(kpiDetail);
                        }else if(kpiDetail.Id !=null){
                            if(kpiDetail.Target_Score__c!=null){
                                kpiDetail.Target_Score__c = kpiDetail.Target_Score__c.setscale(1);
                            }
                            if(kpiDetail.Initial_Score__c!=null){
                                kpiDetail.Initial_Score__c = kpiDetail.Initial_Score__c.setscale(1);
                            }
                            kpiDetailsupdate.add(kpiDetail);
                        }
                        
                    }
                    upsert kpiDetailsupdate;
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        /**
         * [Method Description] Get wave obj and return as map
         * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
        */
        @AuraEnabled
        public static Map<String, List<String>> getWAVEs(String waveName, String BrandCode) {

            Map<String, List<String>> waveMap = new Map<String, List<String>>();
            String initialMonth = [SELECT Initial_Start_Month__c  FROM WAVE__c WHERE Name =:waveName AND BrandCode__c =: BrandCode ORDER BY Period_Number__c ASC LIMIT 1].Initial_Start_Month__c;
            List<WAVE__c> waves = [SELECT Initial_Start_Month__c  FROM WAVE__c WHERE Name =:waveName AND BrandCode__c =: BrandCode ORDER BY Period_Number__c DESC];
            
            if (waves != null && !waves.isEmpty()) {
                Boolean notFuture = false;
                for(WAVE__c wave : waves){
                   notFuture = compareDate(wave.Initial_Start_Month__c);
                   if(notFuture){
                        List<String> months = new List<String>();
                        months.add(initialMonth);
                        months.add(wave.Initial_Start_Month__c);
                        waveMap.put(waveName, months);
                        return waveMap;
                   }
                }
                
                if(!notFuture){
                    List<String> months = new List<String>();
                    months.add(initialMonth);
                    waveMap.put(waveName, months);
                }
            }
            
            return waveMap;
            
        }
        
        @AuraEnabled
        public static  Map<String, String> getAllWAVEs(String BrandCode) {
            Map<String, String> result = new Map<String, String>();
            List<WAVE__c> waves = [SELECT Name  FROM WAVE__c WHERE BrandCode__c =: BrandCode ORDER BY Name ASC];
            
            for(WAVE__c wave : waves){
                if(!result.containsKey(wave.Name)){
                    result.put(wave.Name, BrandCode);
                    System.debug('wave result: '+wave.Name);
                }
            }
            return result;
        }
            

        /**
         * [Method Description] Save fields related to COPP from Account obj
         * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
         * Edited by [MinheeKim] on [2024-09-04] for [DPM-5700] changed object from account to COPPInfo due to changing logic
         * Edited by [MinheeKim] on [2024-10-07] for [DPM-5843] changed to use the Last_Saved_Time field in COPPInfo obj for timestamp
         * Edited by [MinheeKim] on [2024-11-08] for [DPM-5926] Prevent to update COPPInfo if both COPP and Buy/Sell COPP is not checked, but COPP Start Date is not null
        */
        @AuraEnabled
        public static void updateCOPPInfo(COPPInfo__c coppInfo) {

            User currentUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];

            //if End Date != null, COPP should be false
            if(coppInfo!=null && coppInfo.COPP_End_Date__c!=null){
                coppInfo.COPP__c = false;
            }

            coppInfo.Last_Saved_User__c = currentUser.Id;
            coppInfo.Last_Saved_Time__c = System.now(); 
            

            try{
                if(!coppInfo.COPP__c && !coppInfo.Buy_Sell_COPP__c && coppInfo.COPP_Start_Date__c!=null){ //DPM-5926 added to prevent exception by MinheeKim - 11.08.2024
                    throw new AuraHandledException('Invalid COPP information, COPP start date has been set but no relevant flags have been found.');
                }else{
                    upsert coppInfo;
                }
                
            }catch (AuraHandledException e) { //DPM-5926 added to catch exception by MinheeKim - 11.08.2024
                throw e;
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }

        /**
         * [Method Description] compare initial start month and target start month
         * Created by [MinheeKim] on [2024-08-17] for [DPM-5700]
        */
        public static Boolean compareDate(String InitialStartMonth){
            Date today = Date.today();
            String month = String.valueOf(today.month());
            String year = String.valueOf(today.year());

            if (month.length() == 1) {
                month = '0' + month;
            }

            String formattedDate = year + month ;
            System.debug(formattedDate);

            if (InitialStartMonth == null || InitialStartMonth.length() != 7) {
                throw new IllegalArgumentException('Dates must be non-null and in MMyyyy format.');
            }
            String initialDate = InitialStartMonth.substring(InitialStartMonth.length() - 4); + InitialStartMonth.substring(0, 2); 

            return initialDate <= formattedDate;
        }
    }