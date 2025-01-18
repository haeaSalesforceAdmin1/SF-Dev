/**
************************************************************************************************
* @classname         : HCUV_ContestsIncentivesDataCtrl_Test; being used for Code Coverage
* @description       : Test Class for HCUV_ContestsIncentivesDataCtrl
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       24th Aug 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_ContestsIncentivesDataCtrl_Test {
    /**
    * @description - Create the Test data
    * 
    */
    @testSetup static void setup() {
        Test.startTest();
        Organization__c nationalOrg = new Organization__c(Name = 'National');
        insert nationalOrg;
        
        Organization__c org = new Organization__c(Name = 'Hyundai', ParentOrganization__c = nationalOrg.Id);
        insert org;
        
        Region__c reg = new Region__c(Name = 'SOUTHERN REGION', Organization__c = org.Id, RegionCode__c = 'SO');
        insert reg;
        
        District__c dis = new District__c(Name = 'ATLANTA', Region__c = reg.Id, Organization__c = reg.Organization__c, DistrictCode__c = 'GS1', SalesManager__c = UserInfo.getUserId(), DistrictPartsServiceManager__c = UserInfo.getUserId());
        insert dis;    
        
        //Get Account Record Type Id
        Id hynAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HyundaiDealer').getRecordTypeId();
        
        Account accRec = new Account(Name = 'Hyundai Test Account', ServiceDistrict__c = dis.Id, SalesDistrict__c = dis.Id, Region__c = dis.Region__c, Organization__c =dis.Organization__c, DealerCode__c = 'A0001', Active__c = true, RecordTypeId = hynAccRecordTypeId);
        Insert accRec;
        
        Contact conRec = new Contact(AccountId = accRec.Id, LastName = 'TestL', FirstName = 'TestF', Email='testH@email.com');
        insert conRec;
        
        HCUV_TestDataFactory.createExternalUser(conRec.Id, 'Community_TestF', 'Community_TestL', HCUV_Constants.communityProfile);
        
        List<HCUV_Contests_Incentives__c> ciObjList = HCUV_TestDataFactory.createContestsIncentives(2);
        String hmaRecTypeId = Schema.SObjectType.HCUV_Contests_Incentives__c.getRecordTypeInfosByDeveloperName().get('Dealer_Group').getRecordTypeId();
        String gmaRecTypeId = Schema.SObjectType.HCUV_Contests_Incentives__c.getRecordTypeInfosByDeveloperName().get('Genesis_Region').getRecordTypeId();

        if(!ciObjList.isEmpty()){
            ciObjList[0].Status__c = 'Published';
            ciObjList[0].Publish_Date__c = System.today();
            ciObjList[0].Expiration_Date__c = System.today().addDays(4);
            ciObjList[0].Region__c = 'SO';
            ciObjList[0].Program_Name__c = 'HYUNDAI CERTIFIED USED VEHICLES';
            ciObjList[0].RecordTypeId = hmaRecTypeId;
            update ciObjList[0];
            
            ciObjList[1].Status__c = 'Published';
            ciObjList[1].Publish_Date__c = System.today();
            ciObjList[1].Expiration_Date__c = System.today().addDays(4);
            ciObjList[1].Region__c = 'SO';
            ciObjList[1].Program_Name__c = 'GENESIS CERTIFIED VEHICLES';
            ciObjList[1].RecordTypeId = gmaRecTypeId;
            update ciObjList[1];
        }
        
        HCUV_Contests_Incentives_Audience_Market__c audRec = new HCUV_Contests_Incentives_Audience_Market__c();
        audRec.Contests_Incentives__c = ciObjList[0].Id;
        audRec.Market__c = dis.Id;
        insert audRec;
        
        List<ContentDocument> cdObjList = HCUV_TestDataFactory.createContentDocument(2);
        HCUV_TestDataFactory.createContentDocumentLinks(1, ciObjList[0].Id, cdObjList[0].Id);
        HCUV_TestDataFactory.createContentDocumentLinks(1, ciObjList[1].Id, cdObjList[1].Id);
        Test.stopTest();
    }
    
    /**
    * @description - Checking the HMA Contests Incentives for Community user
    * 
    */
    @isTest 
    static void testgetHMAcontestIncentive() {
        Test.startTest();
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.HMA_COMMUNITY_NAME];
        user user = [select Id from user where lastName = 'Community_TestL'];
        
        List<Account> accList = [Select Id from Account];
        
        insert new AccountShare(AccountAccessLevel = 'Read', AccountId = accList[0].Id, UserOrGroupId = user.Id,
                                OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read');
        
        system.Runas(user){        
            Map<String, Object> dataMap = HCUV_ContestsIncentivesDataCtrl.getcontestIncentive('CUV',netObjList[0].Id);
            System.assertEquals(2, ((List<HCUV_Contests_Incentives__c>)dataMap.get('ContestsIncentives')).size(),'ContestsIncentives size');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Checking the GMA Contests Incentives for Community user
    * 
    */
    @isTest 
    static void testgetGMAcontestIncentive() {
        Test.startTest();
        List<Network> netObjList = [SELECT Id, Name FROM Network WHERE Name =:HCUV_Constants.GMA_COMMUNITY_NAME];
        user user = [select Id from user where lastName = 'Community_TestL'];
        
        List<Account> accList = [Select Id from Account];
        
        insert new AccountShare(AccountAccessLevel = 'Read', AccountId = accList[0].Id, UserOrGroupId = user.Id,
                                OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read');
        
        system.Runas(user){        
            Map<String, Object> dataMap = HCUV_ContestsIncentivesDataCtrl.getcontestIncentive('CPO',netObjList[0].Id);
            System.assertEquals(1, ((List<HCUV_Contests_Incentives__c>)dataMap.get('ContestsIncentives')).size(),'ContestsIncentives size');
        }
        Test.stopTest();
    }
    
}