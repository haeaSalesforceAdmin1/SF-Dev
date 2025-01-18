/**
* @date 09/28/2020
* @description 
* SO2 - ALABAMA NORTH
*/
@isTest
public without sharing class TestUtility {

    public static final String DEALER_NAME = 'D0001 - Dealer Test';
    public static final String DEALER_CODE = 'D0001';
    public static final String DISTRICT_NAME = 'SO2 - ALABAMA NORTH';
    public static final String SALES_DISTRICT_NAME = 'SO2 - ALABAMA NORTH';
    public static final String SERVICE_DISTRICT_NAME = 'SO2 - ALABAMA NORTH';
    public static final String REGION_NAME = 'SOUTHERN REGION';
    public static final String HYUNDIA_ORG = 'Hyundai';
    public static final String GENESIS_ORG = 'Genesis';
    public static final String GENESIS_AREA = 'GMA WEST';
    public static final String GENESIS_MARKET = 'SELECT SOUTH 2';

    public static Id getRecordTypeIdForSObjectDeveloperName(String objectName, String recordTypeDeveloperName) {
        return [select Id from RecordType where SObjectType = :objectName and DeveloperName = :recordTypeDeveloperName].Id;
    }

    public static User createExternalUser(String contactId, String firstName, String lastName, String profileName) {

        Profile profile = [Select Id from Profile WHERE NAME = :profileName];
        User user = new User();
        user.FirstName = firstName;
        user.LastName = lastName;
        user.ContactId = contactId;
        user.Username = user.FirstName + '' + user.LastName+'@' + lastName + '.com';
        user.ProfileId = profile.Id;
        user.Email = lastName + 'invalid@acumensolutions.com';
        user.Alias = 'usr123';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.IsActive = true;
        
        HMAObjectService.dbInsert(user);

        return user;
    }

    public static User createExternalUser(String contactId, String firstName, String lastName, String profileName, String accessTypes) {

        Profile profile = [Select Id from Profile WHERE NAME = :profileName];
        User user = new User();
        user.FirstName = firstName;
        user.LastName = lastName;
        user.ContactId = contactId;
        user.Username = user.FirstName + '' + user.LastName+'@' + lastName + '.com';
        user.ProfileId = profile.Id;
        user.Email = lastName + 'invalid@acumensolutions.com';
        user.Alias = 'usr123';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.AccessTypes__c = accessTypes;
        user.IsActive = true;        

        HMAObjectService.dbInsert(user);

        return user;
    }

    public static List<Organization__c> createOrganizations() {

        Organization__c nationalOrg = new Organization__c(Name = 'National');
        insert nationalOrg;

        List<Organization__c> organizations = new List<Organization__c>();
        organizations.add(new Organization__c(Name = 'Hyundai', ParentOrganization__c = nationalOrg.Id));
        organizations.add(new Organization__c(Name = 'Genesis', BrandCode__c = 'G', ParentOrganization__c = nationalOrg.Id));
        insert organizations;

        return organizations;
    }

    public static Organization__c getOrganization(String organizationName) {
        return [select Id, Name, BrandCode__c, ParentOrganization__c from Organization__c where Name = :organizationName limit 1];
    }

    public static List<Region__c> createRegionsForOrganizations(String orgName) {

        Organization__c organization = TestUtility.getOrganization(orgName);

        List<Region__c> regions = new List<Region__c>();
        regions.add(new Region__c(Name = 'SOUTHERN REGION', Organization__c = organization.Id, RegionCode__c = 'SO'));
        regions.add(new Region__c(Name = 'MTN STATES REGION', Organization__c = organization.Id, RegionCode__c = 'MS'));
        regions.add(new Region__c(Name = 'CENTRAL REGION', Organization__c = organization.Id, RegionCode__c = 'CE'));
        insert regions;

        return regions;
    }

    public static Region__c getRegion(String regionName, String organization) {
        return [select Id, Name, RegionCode__c, Organization__c from Region__c where Name = :regionName and Organization__r.Name = :organization limit 1];
    }

    public static List<District__c> createDistrictsForRegions() {
        List<District__c> districts = new List<District__c>();

        Region__c region = TestUtility.getRegion('SOUTHERN REGION', 'Hyundai');
        districts.add(new District__c(Name = 'ALABAMA NORTH', Region__c = region.Id, Organization__c = region.Organization__c, DistrictCode__c = 'SO2', SalesManager__c = UserInfo.getUserId(), DistrictPartsServiceManager__c = UserInfo.getUserId()));
        districts.add(new District__c(Name = 'ATLANTA', Region__c = region.Id, Organization__c = region.Organization__c, DistrictCode__c = 'GS1', SalesManager__c = UserInfo.getUserId(), DistrictPartsServiceManager__c = UserInfo.getUserId()));

        insert districts;

        return districts;
    }


    public static District__c getDistrict(String districtName, String regionName, String organizationName) {
        return [select Id, Organization__c, Region__c, DistrictCode__c from District__c where Name = :districtName and Region__r.Name = :regionName and Organization__r.Name = :organizationName];
    }

  /* This code is Commented by Neeraj sharma for 3453 ticket 
  *  public static GenesisArea__c createGenesisArea(String name, String code, String userId, String organizationId) {

        GenesisArea__c area = new GenesisArea__c(Name = name, AreaCode__c = code, GenesisAreaManager__c = userId, Organization__c = organizationId);
        insert area;

        return area;
    }

    public static AreasRegion__c createAreaRegion(String genesisAreadId, String regionId) {
        AreasRegion__c areaRegion = new AreasRegion__c(GenesisArea__c = genesisAreadId, Region__c = regionId, AreasRegionCode__c = '567');
        insert areaRegion;
        return areaRegion;
    }*/

    public static HyundaiArea__c createHyundaiArea(String name, String code, String organizationId, String regionId) {

        HyundaiArea__c area = new HyundaiArea__c(Name = name, ADICode__c = code, Organization__c = organizationId, Region__c = regionId);
        insert area;

        return area;
    }


    public static User createInternalUser(String firstName, String lastName, String profileName) {
        Profile profile = [Select Id from Profile WHERE NAME = :profileName];
        User user = new User();
        user.FirstName = firstName;
        user.LastName = lastName;
        user.Username = user.FirstName + '' + user.LastName+'@' + lastName + '.com';
        user.ProfileId = profile.Id;
        user.Email = lastName + 'invalid@acumensolutions.com';
        user.Alias = 'usr123';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.RegionCodes__c = '';
        user.DistrictCodes__c = '';
        user.IsActive = true;

        HMAObjectService.dbInsert(user);

        return user;
    }

    public static User createInternalUserObject(String firstName, String lastName, String profileName) {
        Profile profile = [Select Id from Profile WHERE NAME = :profileName];
        User user = new User();
        user.FirstName = firstName;
        user.LastName = lastName;
        user.Username = user.FirstName + '' + user.LastName+'@' + lastName + '.com';
        user.ProfileId = profile.Id;
        user.Email = lastName + 'invalid@acumensolutions.com';
        user.Alias = 'usr123';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';

        return user;
    }

    public static Account createAccountForDistrictRegionOrg(String accountName, String districtName, String regionName, String organizationName, String dealerCode) {
        District__c district = TestUtility.getDistrict('ALABAMA NORTH', 'SOUTHERN REGION', 'Hyundai');

        Account account = new Account(Name = accountName, ServiceDistrict__c = district.Id, SalesDistrict__c = district.Id, Region__c = district.Region__c, Organization__c = district.Organization__c, DealerCode__c = dealerCode, Active__c = true);
        HMAObjectService.dbInsert(account);
        return account;
    }

    public static Account getAccountByName(String accountName) {
        return [select Name, Organization__c, Organization__r.Name, Region__r.Name, SalesDistrict__r.Name, ServiceDistrict__r.Name  from Account where Name = :accountName];
    }

    public static Contact createContact(String firstName, String lastName, String accountId) {
    
        Contact contact = new Contact(FirstName = firstName, LastName = lastName, AccountId = accountId);
        ContactTriggerHandler.run = false;
        HMAObjectService.dbInsert(contact);
        ContactTriggerHandler.run = true;

        return contact;
    }

    public static Topic__c createTopic(String topicName, Date startDate, Date endDate) {

        Topic__c topic = new Topic__c(Name = 'New Topic', Topic_Start_Date__c = startDate, Topic_End_Date__c = endDate);
        HMAObjectService.dbInsert(topic);

        return topic;
    }

    public static Action_Plan__c createActionPlan(String actionPlanName) {

        Action_Plan__c actionPlan = new Action_Plan__c(Name = actionPlanName);
        HMAObjectService.dbInsert(actionPlan);

        return actionPlan;
    }

    public static Evaluation__c createEvaluation(String evaluationName) {
        Evaluation__c eval = new Evaluation__c(Name = 'Test Evaluation');
        HMAObjectService.dbInsert(eval);

        return eval;
    }

    public static PermissionSetAssignment createPermissionSetAssignmentForUser(String userId, String permissionSetName) {

        List<PermissionSet> permissionSets = [select Id from PermissionSet where Name = :permissionSetName];

        if(!permissionSets.isEmpty()) {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permissionSets[0].Id);
            HMAObjectService.dbInsert(permissionSetAssignment);
            return permissionSetAssignment;
        }
        return null;
    }

    public static PermissionSetAssignment createPermissionSetGroupAssignmentForUser(String userId, String permissionSetGroupName) {

        List<PermissionSetGroup> permissionSetGroups = [select Id from PermissionSetGroup where DeveloperName = :permissionSetGroupName];

        if(!permissionSetGroups.isEmpty()) {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = userId, PermissionSetGroupId = permissionSetGroups[0].Id);
            HMAObjectService.dbInsert(permissionSetAssignment);
            return permissionSetAssignment;
        }
        return null;

    }

    public static KPI__c createKPI(String name) {
        KPI__c kpiRecord = new KPI__C(Name = name, Status__c = 'Active');
        insert kpiRecord;

        return kpiRecord;
    }

    public static KPIThreshold__c createKPIThreshold(String kpiId, String accountId, String field) {
        KPIThreshold__c kpiThreshold = new KPIThreshold__c(KPI__c = kpiId);

        insert kpiThreshold;

        return kpiThreshold;
    }

    public static EinsteinKPI__c createEinsteinKPI(String name, String kpiId, Boolean dealerValue) {   

        EinsteinKPI__c einsteinKPI = new EinsteinKPI__c(Name=name, KPI_SAQL_1__c = 'q = load "TestKPI";', KPI_SAQL_2__c = 'q = load "TestKPI";', KPI_SAQL_3__c = 'q = load "TestKPI";', KPI_Level_1__c = 'Dealer', KPI_Level_2__c = 'Sales District', KPI_Level_3__c = 'Region', RunInterval__c = 'Daily', KPI__c = kpiId, Active__c = true, KPILookupKey1__c = 'dealer_cd', KPILookupKey2__c = 'district_cd', KPILookupKey3__c = 'district_cd', Dealer_Value_is_High__c = dealerValue);
        insert einsteinKPI;

        return einsteinKPI;
    }

    // added by Soyeon Kim for DPM-4754
    public static EinsteinKPI__c createAPEinsteinKPI(String name, String kpiId) {

        EinsteinKPI__c einsteinKPI = new EinsteinKPI__c(Name=name, KPI_SAQL_1__c = 'q = load "TestKPI";', KPI_SAQL_2__c = 'q = load "TestKPI";', KPI_SAQL_3__c = 'q = load "TestKPI";', KPI_Level_1__c = 'Dealer', KPI_Level_2__c = 'Sales District', KPI_Level_3__c = 'Region', RunInterval__c = 'Daily', KPI__c = kpiId, Active__c = true, KPILookupKey1__c = 'dealer_cd', KPILookupKey2__c = 'district_cd', KPILookupKey3__c = 'district_cd');
        insert einsteinKPI;

        return einsteinKPI;
    }

    public static List<EinsteinKPIMapping__c> createEinsteinKPIMappings(String einsteinKPIId) {

        List<EinsteinKPIMapping__c> einsteinKPIMappings = new List<EinsteinKPIMapping__c>();
        einsteinKPIMappings.add(new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIId, KPI_Field__c = 'dealer_cd', Object_Field__c = 'DealerCode__c', Type__c = 'Defined'));
        einsteinKPIMappings.add(new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIId, KPI_Field__c = 'A', Object_Field__c = 'Label1_Value_Num__c', Type__c = 'Number', Actual__c = true));
        einsteinKPIMappings.add(new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIId, KPI_Field__c = 'B', Object_Field__c = 'Label2_Value_Num__c', Type__c = 'Number', Objective__c = true));
        einsteinKPIMappings.add(new EinsteinKPIMapping__c(Einstein_KPI__c = einsteinKPIId, KPI_Field__c = 'C', Object_Field__c = 'Label3_Value_Percent__c', Type__c = 'Percent', Objective__c = false , KPIFieldDescription__c='Test Percent'));

        insert einsteinKPIMappings;

        System.debug(LoggingLevel.ERROR, einsteinKPIId);
        System.debug(LoggingLevel.ERROR, einsteinKPIMappings);

        return einsteinKPIMappings;
    }

    public static String getConnectAPIJsonString() {
        return '{"results" : { "records":[ {"dealer_cd": "A0001", "A":1000.00, "B":2000.00, "C":3000.00 }, {"inventory_dealer_cd":"A0002", "A":2000.00, "B":3000.00, "C":4000.00 } ]}}';
    }


    public static void createCurrentEnvironmentCustomSetting() {
        CurrentEnvironment__c settings = CurrentEnvironment__c.getOrgDefaults();
        settings.Environment__c = 'PROD';
        upsert settings CurrentEnvironment__c.Id;
    }

    public static void createQuarterlySettings() {
        HMACalendarQuarters__c settings = HMACalendarQuarters__c.getOrgDefaults();
        settings.Q1StartDateThisYear__c = Date.today().addDays(-10);
        settings.Q1EndDateThisYear__c = Date.today().addDays(-9);

        settings.Q2StartDateThisYear__c = Date.today().addDays(-8);
        settings.Q2EndDateThisYear__c = Date.today().addDays(-7);

        settings.Q3StartDateThisYear__c = Date.today().addDays(-6);
        settings.Q3EndDateThisYear__c = Date.today().addDays(-5);

        settings.Q4StartDateThisYear__c = Date.today();
        settings.Q4EndDateThisYear__c = Date.today().addDays(1);

        settings.Q1StartDateNextYear__c = Date.today().addDays(7);
        settings.Q1EndDateNextYear__c = Date.today().addDays(8);

        upsert settings HMACalendarQuarters__c.Id;
    }

    public static void createDPMConfigurationSettings() {
        List<RecordType> topicRecordTypes = [select Id from RecordType where SObjectType in ('Action_Plan__c') and DeveloperName = 'Other' ];
        
        DPMConfigurationSettings__c settings = DPMConfigurationSettings__c.getOrgDefaults();
        settings.PRODRecordTypeIDAPOther__c = topicRecordTypes[0].Id;
        upsert settings DPMConfigurationSettings__c.Id;
    }

    //CPOCUV, CCSOM-12, inhokim, 24/02/22 
    public static Notice__c createNotice(String title, Boolean isVisible, String appType, String TargetUser){
        Notice__c notice = new Notice__c(Title__c = title , isVisible__c = isVisible, appType__c = appType, TargetUser__c = TargetUser);
        HMAObjectService.dbInsert(notice);
        return notice;
    }
}