@IsTest
public with sharing class DNAMSPackageTestDataFactory {
    public static Package__c getNewPackage(Id accountId) {
        Package__c p = new Package__c();
        p.Dealer__c = accountId;
        p.RecordTypeId = Schema.Package__c.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('DefaultPackage').recordTypeId;
        p.Status__c = 'Initiated';

        return p;
    }

    public static Package__c createNewPackage(Id accountId) {
        Package__c p = getNewPackage(accountId);
        insert p;

        return p;
    }

    public static PackageElement__c getNewPackageElement(Id packageId, Id accountId) {
        PackageElement__c pe = new PackageElement__c();
        pe.Package__c = packageId;
        pe.Dealer__c = accountId;
        pe.VisibletoDealer__c = true;
        pe.Required__c = true;

        return pe;
    }

    public static PackageElement__c createNewPackageElement(Id packageId, Id accountId) {
        PackageElement__c pe = getNewPackageElement(packageId, accountId);
        insert pe;

        return pe;
    }

    public static PackageRequest__c getNewPackageRequest(Id accountId) {
        PackageRequest__c pr = new PackageRequest__c();
        pr.Dealer__c = accountId;

        return pr;
    }

    public static PackageRequest__c createNewPackageRequest(Id accountId) {
        PackageRequest__c pr = getNewPackageRequest(accountId);
        insert pr;

        return pr;
    }

    public static Account getNewAccount(String accountName) {
        Account a = new Account();
        a.Name = accountName;

        return a;
    }

    public static Account createNewAccount(String accountName) {
        Account a = getNewAccount(accountName);
        insert a;

        return a;
    }

    public static Account getNewDealer(String dealerName, String dealerCode, District__c district, String regionCode) {
        Account a = new Account();
        a.Name = dealerName;
        a.DealerCode__c = dealerCode;
        a.ServiceDistrict__c = district.Id; 
        a.SalesDistrict__c = district.Id;
        a.Region__c = district.Region__c;
        a.RegionCodePicklist__c = regionCode;
        a.Organization__c = district.Organization__c;
        a.Active__c = true;

        return a;
    }

    public static Account createNewDealer(String dealerName, String dealerCode, District__c district, String regionCode) {
        Account a = getNewDealer(dealerName, dealerCode, district, regionCode);
        insert a;

        return a;
    }

    public static Contact getNewDealerContact(String firstName, String lastName, String email, Id accountId) {
        Contact c = new Contact();
        c.FirstName = firstName;
        c.LastName = lastName;
        c.Email = email;
        c.AccountId = accountId;
        c.DNAMS_Role__c = 'Dealer Principal';

        return c;
    }

    public static Contact createNewDealerContact(String firstName, String lastName, String email, Id accountId) {
        Contact c = getNewDealerContact(firstName, lastName, email, accountId);
        insert c;

        return c;
    }
}