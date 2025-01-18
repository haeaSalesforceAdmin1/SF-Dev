@isTest
public class GenesisActionPlanPDFContollerTest {
    

    @testSetup
    static void setup() {
        
        User sysUser = TestUtility.createInternalUser('System22','Admin','System Administrator');
        CurrentEnvironment__c CE = new CurrentEnvironment__c();
        CE.Name='STAGE';
        CE.Environment__c = 'STAGE';
        insert CE;

        TestUtility.createOrganizations();
        // List<Region__c> regions = TestUtility.createRegionsForOrganizations(TestUtility.GENESIS_ORG);
        // TestUtility.createDistrictsForRegions();

        //Organization__c hyundaiOrg = TestUtility.getOrganization(TestUtility.HYUNDIA_ORG);
        Organization__c genOrg = TestUtility.getOrganization(TestUtility.GENESIS_ORG);

        Account acc = new Account(
            	Name = 'Test Account',
            	Organization__c = genOrg.Id,
                DealerCode__c = 'NY701'
        );
        insert acc;

        Survey__c surveyService = new Survey__c(
            Status__c = 'Completed'
        );
        insert surveyService;

        Survey__c surveySales = new Survey__c(
            Status__c = 'Completed'
        );
        insert surveySales;
        
            RecordType serviceEvalRec = [SELECT Id FROM RecordType WHERE Name ='Genesis Retailer Eval Service' LIMIT 1];
            Evaluation__c evalService = new Evaluation__c(
                Account__c = acc.Id,
                DueDate__c = Date.today().addDays(30),
                Survey__c = surveyService.Id,
                Status__c = 'Completed',
                Type__c = 'Service'
                //,
                //RecordTypeId = serviceEvalRec.Id
            );
        System.runAs(sysUser){
            insert evalService;
        }
            RecordType salesEvalRec = [SELECT Id FROM RecordType WHERE Name ='Genesis Retailer Eval Sales' LIMIT 1];
            Evaluation__c evalSales = new Evaluation__c(
                Account__c = acc.Id,
                DueDate__c = Date.today().addDays(30),
                Survey__c = surveySales.Id,
                Status__c = 'Completed'
                //,
                //RecordTypeId = salesEvalRec.Id
            );
        System.runAs(sysUser){
            insert evalSales;
        }
		RecordType surveyQuestionRecord = [SELECT Id FROM RecordType WHERE  DeveloperName = 'Genesis_Retailer_Eval_Service_Template_Question' LIMIT 1];
        
        
        
        // Create Survey Questions for Service Evaluation
        List<Survey_Question__c> serviceQuestions = new List<Survey_Question__c>();
        for(Integer i = 1; i <= 5; i++) {
            serviceQuestions.add(new Survey_Question__c(
                Evaluation__c = evalService.Id,
                Question_Number_Text__c = 'Q' + i,
                Question_Text__c = 'Service Question ' + i,
                Response__c = Math.mod( i, 2 ) == 0 ? 'Yes' : 'No',
                Remarks__c = 'Remark ' + i,
                Is_Parent__c = true,
                Priority__c = 'Y',
                Category_Type__c = 'Facility',
                Category_Order__c = i,
                RecordType = surveyQuestionRecord,
                Survey__c = surveyService.Id
            ));
        }
        insert serviceQuestions;

        // Create Survey Questions for Sales Evaluation
        List<Survey_Question__c> salesQuestions = new List<Survey_Question__c>();
        for(Integer i = 1; i <= 5; i++) {
            salesQuestions.add(new Survey_Question__c(
                Evaluation__c = evalSales.Id,
                Question_Number_Text__c = 'Q' + i,
                Question_Text__c = 'Sales Question ' + i,
                Response__c = Math.mod( i, 2 ) == 0 ? 'Yes' : 'No',
                Remarks__c = 'Remark ' + i,
                Is_Parent__c = true,
                Priority__c =Math.mod( i, 2 )  == 0 ? null : 'Y',
                Category_Type__c = 'Facility',
                Category_Order__c = i,
                Survey__c = surveySales.Id
            ));
        }
        insert salesQuestions;

        // Create Child Survey Questions
        List<Survey_Question__c> childQuestions = new List<Survey_Question__c>();
        for(Survey_Question__c parentQuestion : serviceQuestions) {
            if(parentQuestion.Response__c == 'No') {
                childQuestions.add(new Survey_Question__c(
                    DependentQuestion__c = parentQuestion.Id,
                    Question_Text__c = 'Child Question for ' + parentQuestion.Question_Number_Text__c,
                    Response__c = 'No',
                    Category_Type__c = parentQuestion.Category_Type__c,
                    Survey__c = surveyService.Id
                ));
            }
        }
        insert childQuestions;
    }

    @isTest
    static void testGetSurveyQuestions_Service() {
        Evaluation__c eval = [SELECT Id FROM Evaluation__c WHERE Type__c = 'Service' LIMIT 1];
        
        PageReference pageRef = Page.GenesisActionPlanPDF; // replace with the actual VF page name
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', eval.Id);
        
        GenesisActionPlanPDFController controller = new GenesisActionPlanPDFController(new ApexPages.StandardController(eval));
        controller.handleLoad();

       // System.assertNotEquals(0, controller.surveyQuestionWappers.size(), 'Survey Questions should not be empty');
       // System.assertEquals('Service', controller.evaluation.Type__c, 'Evaluation Type should be Service');
    }



    @isTest
    static void testGetEvaluation() {
        Evaluation__c eval = [SELECT Id FROM Evaluation__c LIMIT 1];
        
        Evaluation__c retrievedEval = GenesisActionPlanPDFController.getEvaluation(eval.Id);
        
        System.assertEquals(eval.Id, retrievedEval.Id, 'Retrieved Evaluation ID should match the original Evaluation ID');
    }
    
    @IsTest
    static void testGetCommunityBaseUrl() {
        String testUrl = 'https://testcommunity.force.com';

        Test.startTest();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            PageReference pr = new PageReference(testUrl);
            pr.getParameters().put('c', 'testCommunity');
            Test.setCurrentPageReference(pr);
        }
        String result = GenesisActionPlanPDFController.getCommunityBaseUrl();
        Test.stopTest();
    
    }
}