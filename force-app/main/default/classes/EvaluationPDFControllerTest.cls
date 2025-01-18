@isTest
public without sharing class EvaluationPDFControllerTest {

    @TestSetup
    static void makeData() {
        TestUtility.createInternalUser('TestOwnerUser', 'TestOwnerUser', 'System Administrator');

        TestUtility.createDPMConfigurationSettings();
        TestUtility.createCurrentEnvironmentCustomSetting();

        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations('Hyundai');
        TestUtility.createDistrictsForRegions();
        TestUtility.createQuarterlySettings();

        Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);

        Account account = TestUtility.createAccountForDistrictRegionOrg(TestUtility.DEALER_NAME, TestUtility.DISTRICT_NAME, TestUtility.REGION_NAME, TestUtility.HYUNDIA_ORG, 'A0001');

        ContactTriggerHandler.run = false;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL1', FirstName = 'TestF1', Email='Test1@test.com'));
        contacts.add(new Contact(AccountId = account.Id, LastName = 'TestL2', FirstName = 'TestF2', Email='Test2@test.com'));
        insert contacts;
        ContactTriggerHandler.run = true;

        User userGM = TestUtility.createExternalUser(contacts[0].Id, 'TestL1', 'TestF1', 'DPM Partner Community (Hyundai)');
        User userDP = TestUtility.createExternalUser(contacts[1].Id, 'TestL2', 'TestF2', 'DPM Partner Community (Hyundai)');

        account.GeneralManager__c = contacts[0].Id;
        account.DealerPrincipal__c = contacts[1].Id;
        account.Active__c = true;
        update account;

        List<RecordType> recordTypes = [select Id from RecordType where RecordType.DeveloperName = 'Survey_Topic'];
        //List<RecordType> recordTypeHyundai = [select Id from RecordType where RecordType.DeveloperName = 'Hyundai'];
        //List<RecordType> recordTypeGenesis = [select Id from RecordType where RecordType.DeveloperName = 'Genesis'];
        List<Organization__c> organizations = [select Id, Name from Organization__c where Name = 'Hyundai'];
    }

    static testmethod void testEvaludationPDF() {
        List<Account> accounts = [select Id from Account];

        Survey__c survey = new Survey__c(Dealer__c = accounts[0].Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;
        KPI__c kpi = new KPI__c(Name = 'Test Mandatory KPI');
        insert kpi;

        KPI__c optkpi = new KPI__c(Name = 'Test Optional KPI');
        insert optkpi;

        Evaluation__c evaluation = new Evaluation__c(Account__c = accounts[0].Id, Survey__c = survey.Id, Type__c = 'Service');
        evaluation.Count_of_AP_Carried_Over_to_Next_Quarter__c = 1;
        insert evaluation;

        Action_Plan__c actionPlan = new Action_Plan__c(Evaluation__c = evaluation.Id, Status__c = 'Compliant');

        // insert actionPlan;
        
        Action_Plan__c actionPlan1 = new Action_Plan__c(Evaluation__c = evaluation.Id, Status__c = 'Non-Compliant');
        actionPlan1.Is_Carried_Over__c = TRUE;
        actionPlan1.RelatedSurvey__c = survey.Id;
        actionPlan1.HMASurveyQuestion__c = surveyQuestion.Id;
        actionPlan1.Question_Failed__c = '1';
        actionPlan1.Question_Failed_Official__c = 'Test Question';
        insert actionPlan1;


        List<RecordType> recordTYpes = [select Id from RecordType where DeveloperName = 'Hyundai' and SObjectType = 'EinsteinKPI__c'];

        EinsteinKPI__c einsteinKPI = new EinsteinKPI__c(Name = 'Test Manadatory KPI', KPI__c = kpi.Id, ranking__c = 1, ActionPlanRequirement__c = 'Mandatory', Division__c = 'Sales', Active__c = true, RecordTypeId = recordTYpes[0].Id);
        insert einsteinKPI;

        EinsteinKPI__c einsteinKPIOptional = new EinsteinKPI__c(Name = 'Test Optinal KPI', KPI__c = optkpi.Id, ranking__c = 2, ActionPlanRequirement__c = 'Optional', Division__c = 'Sales', Active__c = true, RecordTypeId = recordTYpes[0].Id);
        insert einsteinKPIOptional;

        EinsteinKPIDetail__c detail = new EinsteinKPIDetail__c(Account__c = accounts[0].Id, EinsteinKPI__c = einsteinKPI.Id, KPI__c = kpi.Id);
        insert detail;

        EinsteinKPIDetail__c detail2 = new EinsteinKPIDetail__c(Account__c = accounts[0].Id, EinsteinKPI__c = einsteinKPIOptional.Id, KPI__c = optkpi.Id);
        insert detail2;

        EvaluationKPIs__c evalKPI = new EvaluationKPIs__c(Evaluation__c = evaluation.Id, KPI__c = kpi.Id, EinsteinKPIDetail__c = detail.Id, Include_in_PDF__c = true);
        insert evalKPI;

        EvaluationKPIs__c evalKPIOptional = new EvaluationKPIs__c(Evaluation__c = evaluation.Id, KPI__c = optkpi.Id, EinsteinKPIDetail__c = detail2.Id);
       // insert evalKPIOptional;
        Test.startTest();
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        //  Survey__c survey = new Survey__c(Dealer__c = account.Id);
        // insert survey;

        //   Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        //   insert surveyQuestion;

        //   Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        //  insert evaluation;
        PageReference pageRef = Page.EvaluationPDF;
        test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id', evaluation.Id);
        pageRef.getParameters().put('showFinancials', 'true');
        pageRef.getParameters().put('showApprovals', 'true');

        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(evaluation.Id));

        EvaluationPDFController cs = new EvaluationPDFController();
        cs.buildCarryOverSurveyQuestionWrapper(new List<id>{
                surveyQuestion.id
        });

        actionPlan1.Status__c = 'Pending';
        update actionPlan1;
       // EvaluationPDFController cs1 = new EvaluationPDFController();
        Test.stopTest();
    }


    static testmethod void testEvaludationPDF2() {

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;

        PageReference pageRef = Page.EvaluationPDF;
        test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id', evaluation.Id);
        pageRef.getParameters().put('showFinancials', 'false');
        pageRef.getParameters().put('showApprovals', 'false');

        Test.startTest();
        Action_Plan__c actionPlan1 = new Action_Plan__c(Evaluation__c = evaluation.Id, Status__c = 'Carry Over');
        actionPlan1.Is_Carried_Over__c = FALSE;
        actionPlan1.Is_Carry_Over_Button_Clicked__c = TRUE;
        actionPlan1.RelatedSurvey__c = survey.Id;
        actionPlan1.HMASurveyQuestion__c = surveyQuestion.Id;
        actionPlan1.Question_Failed__c = '1';
        actionPlan1.Question_Failed_Official__c = 'Test Question';
        insert actionPlan1;
        EvaluationPDFController cs = new EvaluationPDFController();

        Test.stopTest();
    }

    static testmethod void testEvaludationPDF3() {

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;

        PageReference pageRef = Page.EvaluationPDF;
        test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id', evaluation.Id);
        pageRef.getParameters().put('showFinancials', 'false');
        pageRef.getParameters().put('showApprovals', 'false');

        Test.startTest();
        Action_Plan__c actionPlan1 = new Action_Plan__c(Evaluation__c = evaluation.Id, Status__c = 'Compliant');
        actionPlan1.Is_Carried_Over__c = TRUE;
        actionPlan1.Is_Carry_Over_Button_Clicked__c = TRUE;
        actionPlan1.RelatedSurvey__c = survey.Id;
        actionPlan1.HMASurveyQuestion__c = surveyQuestion.Id;
        actionPlan1.Question_Failed__c = '1';
        actionPlan1.Question_Failed_Official__c = 'Test Question';
        insert actionPlan1;
        EvaluationPDFController cs = new EvaluationPDFController();

        Test.stopTest();
    }


    static testmethod void testEvaludationPDFEValGeneration() {

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;

        Test.startTest();
        EvaluationPDFController.launchQueueableForEvaluationGeneration(evaluation.Id);
        Test.stopTest();
    }


    static testmethod void testGetNetworkId() {

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;

        Test.startTest();
        EvaluationPDFController.getNetworkId();
        Test.stopTest();
    }

    static testmethod void testGetEvaluationDetails() {

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;

        Test.startTest();
        EvaluationPDFController.getEvaluationDetails(evaluation.Id);
        Test.stopTest();
    }


    static testmethod void testGetEvaluationDetailsWithActionPlan() {

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id);
        insert evaluation;

        Action_Plan__c actionPlan = new Action_Plan__c(Evaluation__c = evaluation.Id);
        insert actionPlan;

        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient = 'test', VersionData = beforeblob);
        insert cv;

        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];

        ContentDocumentLink contentlinkeval = new ContentDocumentLink(LinkedEntityId = actionPlan.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        insert contentlinkeval;

        PageReference pageRef = Page.EvaluationPDF;
        test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id', evaluation.Id);
        pageRef.getParameters().put('showFinancials', 'true');
        pageRef.getParameters().put('showApprovals', 'true');

        Test.startTest();
        EvaluationPDFController pdfController = new EvaluationPDFController();
        Test.stopTest();
    }


    static testmethod void testGetEvaluationWithSurveyAndSurveyQuestions() {

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id, Table_Columns__c = 'Test1;Test2;Test3');
        insert surveyQuestion;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;

        PageReference pageRef = Page.EvaluationPDF;
        test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id', evaluation.Id);
        pageRef.getParameters().put('showFinancials', 'true');
        pageRef.getParameters().put('showApprovals', 'true');

        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient = 'test', VersionData = beforeblob);
        insert cv;

        List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion where Title LIKE 'test content trigger%' LIMIT 3];

        ContentDocumentLink contentlinkeval = new ContentDocumentLink(LinkedEntityId = evaluation.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        insert contentlinkeval;

        ContentDocumentLink contentlinksurveyquestion = new ContentDocumentLink(LinkedEntityId = surveyQuestion.Id, ContentDocumentId = testContents[0].ContentDocumentId);
        insert contentlinksurveyquestion;

        Test.startTest();
        EvaluationPDFController pdfController = new EvaluationPDFController();
        Test.stopTest();
    }
    
    static testmethod void testsaveEvaluationKPIRecord(){
        //{"Include_in_PDF__c":true,"ActionPlanReviewRequired__c":false,"EvalKPIExternalID__c":"a083I0000014Aq7QAE-a0J3I00000LC2kxUAD","ActionPlan__c":null,"Evaluation__c":"a083I0000014Aq7QAE","KPI__c":"a0J3I00000LC2kxUAD","EinsteinKPIDetail__c":"a0d3I000000e1tNQAQ","Initial_Key_Value__c":"65.4%","Initial_Threshold_Value__c":"70.00"};
       
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Survey__c survey = new Survey__c(Dealer__c = account.Id);
        insert survey;

        Survey_Question__c surveyQuestion = new Survey_Question__c(Survey__c = survey.Id);
        insert surveyQuestion;
        
        KPI__c kpi = new KPI__c(Name = 'Test Mandatory KPI');
        insert kpi;
        
        List<RecordType> recordTYpes = [select Id from RecordType where DeveloperName = 'Hyundai' and SObjectType = 'EinsteinKPI__c'];
        
        EinsteinKPI__c einsteinKPI = new EinsteinKPI__c(Name = 'Test Manadatory KPI', KPI__c = kpi.Id, ranking__c = 1, ActionPlanRequirement__c = 'Mandatory', Division__c = 'Sales', Active__c = true, RecordTypeId = recordTYpes[0].Id,Dealer_Value_is_High__c = false);
        insert einsteinKPI;
        
        EinsteinKPIDetail__c detail = new EinsteinKPIDetail__c(Account__c = account.Id, EinsteinKPI__c = einsteinKPI.Id, KPI__c = kpi.Id);
        insert detail;

        Evaluation__c evaluation = new Evaluation__c(Account__c = account.Id, Survey__c = survey.Id);
        insert evaluation;
        
        EvaluationKPIs__c evalKPI = new EvaluationKPIs__c(Include_in_PDF__c = true, ActionPlanReviewRequired__c = false, ActionPlan__c = null,Evaluation__c = evaluation.Id, KPI__c = Kpi.Id, EinsteinKPIDetail__c = detail.Id, Initial_Key_Value__c = '65.4' , Initial_Threshold_Value__c = '70.00');
        insert evalKPI;
        
        String evaulationKPIJSON = JSON.serialize(evalKPI);
        System.debug('EvalKPi: '+evaulationKPIJSON);
        
        KPISelectorController.saveEvaluationKPIRecord(evaulationKPIJSON); 
    }
    
    static testmethod void TestEvaluationKPIsDetails(){
        EvaluationPDFController.EvaluationKPIsDetails evalPdf = new EvaluationPDFController.EvaluationKPIsDetails();
        system.assertEquals(null, evalPdf.KPIName);
        system.assertEquals(null,evalPdf.Initial_Key_Value);
        system.assertEquals(null, evalPdf.Initial_Threshold_Value);
        system.assertEquals(null, evalPdf.ThresholdStatusIcon);
        system.assertEquals(null, evalPdf.regionValue);
        system.assertEquals(null, evalPdf.districtValue);
        system.assertEquals(null, evalPdf.regionColor);
        system.assertEquals(null, evalPdf.districtColor);
        system.assertEquals(null, evalPdf.dashboardTableData);
    }
    
    /*static testmethod void TesthandleLoad(){
        EinsteinKPIDetail__c einsteinKPIDealer : [SELECT  EinsteinKPI__r.Dealer_Value_is_High__c from EinsteinKPIDetail__c  where Id = :evalKPIdetail.einsteinKPIDetail.Id];
    }*/
}