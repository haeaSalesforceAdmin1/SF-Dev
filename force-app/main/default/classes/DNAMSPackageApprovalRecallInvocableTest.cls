@IsTest
private class DNAMSPackageApprovalRecallInvocableTest {
    private static final String HYUNDAI_ORG = 'Hyundai';
    private static final String DEALER_NAME = 'UTOPIA MOUNTAIN SUNRISE HYUNDAI';
    private static final String DISTRICT_NAME = 'ATLANTA';
    private static final String REGION_NAME = 'SOUTHERN REGION';
    private static final String REGION_CODE = 'SO';
    private static final String DEALER_CODE = 'GA999';

    @TestSetup
    static void setupData() {
        TestUtility.createOrganizations();
        TestUtility.createRegionsForOrganizations(HYUNDAI_ORG);
        TestUtility.createDistrictsForRegions();
        District__c district = TestUtility.getDistrict(DISTRICT_NAME, REGION_NAME, HYUNDAI_ORG);
        Account dealer = DNAMSPackageTestDataFactory.createNewDealer(DEALER_NAME, DEALER_CODE, district, REGION_CODE);

        Package__c pack = DNAMSPackageTestDataFactory.createNewPackage(dealer.Id);

        List<Package_Approval__c> packageApprovalsList = new List<Package_Approval__c>{
            new Package_Approval__c(Approval_Type__c = 'RMR', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = false),
           	new Package_Approval__c(Approval_Type__c = 'RGM', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = false),
           	new Package_Approval__c(Approval_Type__c = 'DND 1', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = true),
            new Package_Approval__c(Approval_Type__c = 'DND 2', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = true),
            new Package_Approval__c(Approval_Type__c = 'DND 3', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = true),
            new Package_Approval__c(Approval_Type__c = 'Legal', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = false),
            new Package_Approval__c(Approval_Type__c = 'BMI', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = false),
            new Package_Approval__c(Approval_Type__c = 'Planning', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = false),
            //DNA-1026, DNA-1029-Start
            new Package_Approval__c(Approval_Type__c = 'Performance', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = false),
            new Package_Approval__c(Approval_Type__c = 'Dealer Groups', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = false),
            //DNA-1026, DNA-1029-End
            new Package_Approval__c(Approval_Type__c = 'Executive', Decision__c = 'Pending', Package__c = pack.id, Legal_BMI_Planning_Created__c = false)
        };
        insert packageApprovalsList;     
    }

    @IsTest static void testRecallMethod() {
        Package__c packageRec = [SELECT Id FROM Package__c LIMIT 1];
        Package_Approval__c dnd1Approval = [SELECT Id, OwnerId, Approval_Type__c,CreatedDate,Decision__c, Package__c, Legal_BMI_Planning_Created__c 
                                                      FROM Package_Approval__c
                                                      WHERE Package__c = :packageRec.id and Approval_Type__c = 'DND 1' LIMIT 1];
        List<DNAMSPackageApprovalRecallInvocable.InvocableInput> inputList = new List<DNAMSPackageApprovalRecallInvocable.InvocableInput>();
        DNAMSPackageApprovalRecallInvocable.InvocableInput input = new DNAMSPackageApprovalRecallInvocable.InvocableInput();
        input.packageApproval = dnd1Approval;
        input.legal = true;
        input.bmi = true;
        input.planning = true;
        //DNA-1026, DNA-1029-Start
        input.performance = true;
        input.dealerGroups = true;
        //DNA-1026, DNA-1029-End
        inputList.add(input);
        DNAMSPackageApprovalRecallInvocable.recallApprovals(inputList);
    }

    @IsTest static void testValidateMethod() {
        Package__c packageRec = [SELECT Id FROM Package__c LIMIT 1];
        Package_Approval__c dnd1Approval = [SELECT Id, OwnerId, Approval_Type__c,CreatedDate,Decision__c, Package__c, Legal_BMI_Planning_Created__c 
                                                      FROM Package_Approval__c
                                                      WHERE Package__c = :packageRec.id and Approval_Type__c = 'DND 1' LIMIT 1];
        List<DNAMSPackageApprovalRecallInvocable.InvocableInput> inputList = new List<DNAMSPackageApprovalRecallInvocable.InvocableInput>();
        DNAMSPackageApprovalRecallInvocable.InvocableInput input = new DNAMSPackageApprovalRecallInvocable.InvocableInput();
        input.packageApproval = dnd1Approval;
        input.legal = false;
        input.bmi = false;
        input.planning = false;
        //DNA-1026, DNA-1029-Start
        input.performance = false;
        input.dealerGroups = false;
        //DNA-1026, DNA-1029-End
        inputList.add(input);
        DNAMSPackageApprovalRecallInvocable.recallApprovals(inputList);
    }
    
    @IsTest static void testValidateDND2Method() {
        Package__c packageRec = [SELECT Id FROM Package__c LIMIT 1];
        Package_Approval__c dnd1Approval = [SELECT Id, OwnerId, Approval_Type__c,CreatedDate,Decision__c, Package__c, Legal_BMI_Planning_Created__c 
                                                      FROM Package_Approval__c
                                                      WHERE Package__c = :packageRec.id and Approval_Type__c = 'DND 2' LIMIT 1];
        List<DNAMSPackageApprovalRecallInvocable.InvocableInput> inputList = new List<DNAMSPackageApprovalRecallInvocable.InvocableInput>();
        DNAMSPackageApprovalRecallInvocable.InvocableInput input = new DNAMSPackageApprovalRecallInvocable.InvocableInput();
        input.packageApproval = dnd1Approval;
        input.legal = false;
        input.bmi = false;
        input.planning = false;
        //DNA-1026, DNA-1029-Start
        input.performance = false;
        input.dealerGroups = false;
        //DNA-1026, DNA-1029-End
        inputList.add(input);
        DNAMSPackageApprovalRecallInvocable.recallApprovals(inputList);
    }
    
    @IsTest static void testValidateDND3Method() {
        Package__c packageRec = [SELECT Id FROM Package__c LIMIT 1];
        Package_Approval__c dnd1Approval = [SELECT Id, OwnerId, Approval_Type__c,CreatedDate,Decision__c, Package__c, Legal_BMI_Planning_Created__c 
                                                      FROM Package_Approval__c
                                                      WHERE Package__c = :packageRec.id and Approval_Type__c = 'DND 3' LIMIT 1];
        List<DNAMSPackageApprovalRecallInvocable.InvocableInput> inputList = new List<DNAMSPackageApprovalRecallInvocable.InvocableInput>();
        DNAMSPackageApprovalRecallInvocable.InvocableInput input = new DNAMSPackageApprovalRecallInvocable.InvocableInput();
        input.packageApproval = dnd1Approval;
        input.legal = false;
        input.bmi = false;
        input.planning = false;
        //DNA-1026, DNA-1029-Start
        input.performance = false;
        input.dealerGroups = false;
        //DNA-1026, DNA-1029-End
        inputList.add(input);
        DNAMSPackageApprovalRecallInvocable.recallApprovals(inputList);
    }
}