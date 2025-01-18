/**
**/
@isTest
public class KPIPDFExportControllerTest {
    
    
    @TestSetup
    static void makeData(){
         CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;
        TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');

        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');

        KPI__c kpi = TestUtility.createKPI('TestKPI');
        KPI__c kpi2 = TestUtility.createKPI('TestKPI2');
        KPI__c kpi3 = TestUtility.createKPI('TestKPI3');

        EinsteinKPI__c einsteinKPI = TestUtility.createEinsteinKPI('District', kpi.Id, true);
        //RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Account' and name='Hyundai Dealer'];
        einsteinKPI.Division__c ='Sales';
        einsteinKPI.RecordTypeId = Schema.getGlobalDescribe().get('EinsteinKPI__c').getDescribe().getRecordTypeInfosByName().get(TestUtility.HYUNDIA_ORG).getRecordTypeId();
        update einsteinKPI;

        EinsteinKPI__c einsteinKPI1 = TestUtility.createEinsteinKPI('TestKPI Region', kpi2.Id, false);                    
        einsteinKPI1.Parent_Einstein_KPI__c = einsteinKPI.id;                
        update einsteinKPI1;
        
        EinsteinKPI__c einsteinKPI2 = TestUtility.createEinsteinKPI('TestKPI District', kpi3.Id, false);                    
        einsteinKPI1.Parent_Einstein_KPI__c = einsteinKPI1.id;                
        update einsteinKPI2;

        EinsteinKPI__c einsteinKPI3 = new EinsteinKPI__c(Name= 'TestKPI District', KPI_SAQL_1__c = 'q = load "TestKPI";', KPI_SAQL_2__c = 'q = load "TestKPI";', KPI_SAQL_3__c = 'q = load "TestKPI";', KPI_Level_1__c = 'Dealer', KPI_Level_2__c = 'Sales District', KPI_Level_3__c = 'Region', RunInterval__c = 'Daily', KPI__c = kpi.Id, Active__c = true, KPILookupKey1__c = 'dealer_cd', KPILookupKey2__c = 'district_cd', KPILookupKey3__c = 'district_cd', Dealer_Value_is_High__c = false);
        insert einsteinKPI3;
        einsteinKPI3.Parent_Einstein_KPI__c = einsteinKPI1.id;
        update einsteinKPI3;        

        EinsteinKPIDetail__c einsteinKPIDetail = new EinsteinKPIDetail__c(Account__c = account.Id, KPI__c = kpi.Id, EinsteinKPI__c = einsteinKPI.Id, Label1__c = 'Test', Label1_Value_Num__c = 123, Label1_Value_Curr__c = 123, Label1_Value_Percent__c = 100, Label1_Value_Txt__c = '100', Key_Value__c='100.00%');
        // einsteinKPIDetail. = Schema.getGlobalDescribe().get('EinsteinKPI__c').getDescribe().getRecordTypeInfosByName().get(TestUtility.HYUNDIA_ORG).getRecordTypeId();


        einsteinKPIDetail.Region__c = account.Region__c;
        einsteinKPIDetail.DealerCode__c = Account.DealerCode__c;
        insert einsteinKPIDetail;

        EinsteinKPIDetail__c einsteinKPIDetail1 = new EinsteinKPIDetail__c(Account__c = account.Id, KPI__c = kpi.Id, EinsteinKPI__c = einsteinKPI1.Id, Label1__c = 'Test region', Label1_Value_Num__c = 123, Label1_Value_Curr__c = 123, Label1_Value_Percent__c = 100, Label1_Value_Txt__c = '100', Key_Value__c='100.00%');
        // einsteinKPIDetail. = Schema.getGlobalDescribe().get('EinsteinKPI__c').getDescribe().getRecordTypeInfosByName().get(TestUtility.HYUNDIA_ORG).getRecordTypeId();
		
        einsteinKPIDetail1.Region__c = account.Region__c;
        einsteinKPIDetail1.DealerCode__c = Account.DealerCode__c;
        insert einsteinKPIDetail1;
        
        EinsteinKPIDetail__c einsteinKPIDetail2 = new EinsteinKPIDetail__c(Account__c = account.Id, KPI__c = kpi.Id, EinsteinKPI__c = einsteinKPI2.Id, Label1__c = 'Test region', Label1_Value_Num__c = 123, Label1_Value_Curr__c = 123, Label1_Value_Percent__c = 100);
        // einsteinKPIDetail. = Schema.getGlobalDescribe().get('EinsteinKPI__c').getDescribe().getRecordTypeInfosByName().get(TestUtility.HYUNDIA_ORG).getRecordTypeId();
		
        einsteinKPIDetail2.Region__c = account.Region__c;
        einsteinKPIDetail2.DealerCode__c = Account.DealerCode__c;
        insert einsteinKPIDetail2;

    }

    static testMethod void testEinsteinKPIDetailCreateActionPlan() {
        List<EinsteinKPIDetail__c> einsteinKPIDetails = [select Id from EinsteinKPIDetail__c];
        einsteinKPIDetails[0].CreateActionPlan__c = true;

        Test.startTest();
        update einsteinKPIDetails;
        Test.stopTest();

        account acc = [select Id from account];
        //System.assertEquals(1, actionPlans.size());
  
        PageReference pageRef = Page.KPIPDFEXPORT; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);
        KPIPDFExportController tb = new KPIPDFExportController();
        KPIPDFExportController.getNetworkId();
        
        KPIPDFExportController.EvaluationKPIsDetails evalEpiDetail = new KPIPDFExportController.EvaluationKPIsDetails();
    	System.assertEquals(null,evalEpiDetail.ThresholdStatusIcon);
        System.assertEquals(null, evalEpiDetail.KPIName1);
        System.assertEquals(null, evalEpiDetail.evaluationKPI);
        System.assertEquals(null, evalEpiDetail.einsteinKPI);
        System.assertEquals(null, evalEpiDetail.einsteinKPIDetail);
        System.assertEquals(null, evalEpiDetail.regionEinsteinKPIDetail);
        System.assertEquals(null, evalEpiDetail.districtEinsteinKPIDetail);
        System.assertEquals(null, evalEpiDetail.districtValue);
        System.assertEquals(null, evalEpiDetail.regionColor);
        System.assertEquals(null, evalEpiDetail.districtColor);
        KPIPDFExportController.EvaluationWrapper evalWrap = new KPIPDFExportController.EvaluationWrapper();
        System.assertEquals(null, evalWrap.evaluation);
        System.assertEquals(null, evalWrap.evaluationKPIs);
    }
    
    // static testMethod void testhandleLoad(){
        
    //     for (EinsteinKPIDetail__c EK :   [SELECT Id, Key_Value__c,Region__r.Name,RegionCode__c, DistrictCode__c, EinsteinKPIName__c,Region__c, District__c,EinsteinKPI__r.Parent_Einstein_KPI__c,EinsteinKPI__r.Dealer_Value_is_High__c
    //                                                   FROM EinsteinKPIDetail__c]) {                                              
    //                                                       if(EK.EinsteinKPI__r.Dealer_Value_is_High__c == true){
    //                                                           String keyValue = String.valueof(EK.Key_Value__c);
    //                                                           Double keyval= Double.valueof(keyValue);
    //                                                           if(keyval>=keyval){
    //                                                               System.assertEquals('red', 'red');
    //                                                           }
    //                                                       }
    //                                                   }
    // 	}
}