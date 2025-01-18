/**
************************************************************************************************
* @classname         : HCUV_TestDataFactory; being used for test data
* @description       : Class for test data factory
* @author            : Smriti Gupta
* History
* Version      Date                Author               Story/Bug         Modification
* 1.0       24th Sep 2023          Smriti Gupta         Story HVM-218       Initial Version
************************************************************************************************
**/
@isTest
public class HCUV_TestDataFactory {
    /**
    * @description - Creating test account data
    * @param - num
    * @return List<Account>
    */
    public static List<Account> createAccounts(Integer num) {
        List<Account> accObjList = new List<Account>();
        
        for(Integer i=0;i<num;i++) {
            Account accObj = new Account(Name = 'Test Acc'  + i);
            accObj.DealerCode__c = 'TestCode1';
            accObjList.add(accObj);
        }
        insert accObjList;
        return accObjList;
    }
    
    /**
    * @description - Creating test Contact data
    * @param - num, accId
    * @return List<Contact>
    */
    public static List<Contact> createContacts(Integer num, String accId) {
        List<Contact> conObjList = new List<Contact>();
        
        for(Integer i=0;i<num;i++) {
            Contact conObj = new Contact();
            conObj.AccountId = accId;
            conObj.FirstName = 'TestFN' + i;
            conObj.LastName = 'TestLN' + i;
            conObj.Email = 'Test' + i + '@test.com';
            conObjList.add(conObj);
        }
        insert conObjList;
        return conObjList;
    }
    
    /**
    * @description - Creating test HCUV_Inventory__c data
    * @param - num
    * @return List<HCUV_Inventory__c>
    */
    public static List<HCUV_Inventory__c> createInventories(Integer num) {
        List<HCUV_Inventory__c> invObjList = new List<HCUV_Inventory__c>();
        
        for(Integer i=0;i<num;i++) {
            HCUV_Inventory__c invObj = new HCUV_Inventory__c(Name = 'Test Inv'  + i);
			invObj.Transaction_Date__c = System.today();
            invObjList.add(invObj);
        }
        insert invObjList;
        return invObjList;
    }
    
    /**
    * @description - Creating test HCUV_Quick_Link__c data
    * @param - recordTypeId, num
    * @return List<HCUV_Quick_Link__c>
    */
    public static List<HCUV_Quick_Link__c> createQuickLinks(String recordTypeId, Integer num) {
        List<HCUV_Quick_Link__c> qlObjList = new List<HCUV_Quick_Link__c>();
        for(Integer i=0;i<num;i++) {
            HCUV_Quick_Link__c qlObj = new HCUV_Quick_Link__c(Name = 'Test QL'  + i, Link__c='www.test.com', RecordTypeId = recordTypeId);
            qlObjList.add(qlObj);
        }
        insert qlObjList;
        return qlObjList;
    }
    
    /**
    * @description - Creating test HCUV_Reference_Material__c data
    * @param - num
    * @return List<HCUV_Reference_Material__c>
    */
    public static List<HCUV_Reference_Material__c> createReferenceMaterials(Integer num) {
        List<HCUV_Reference_Material__c> rfObjList = new List<HCUV_Reference_Material__c>();
        
        for(Integer i=0;i<num;i++) {
            HCUV_Reference_Material__c rfObj = new HCUV_Reference_Material__c(Name = 'Test RF'  + i);
            rfObj.Material_Type__c = 'Document';
            rfObj.Status__c = 'Published';
            rfObj.Start_Date__c = System.today();
            rfObj.End_Date__c = System.today();
            rfObjList.add(rfObj);
        }
        insert rfObjList;
        return rfObjList;
    }
    
    /**
    * @description - Creating test HCUV_Contests_Incentives__c data
    * @param - num
    * @return List<HCUV_Contests_Incentives__c>
    */
    public static List<HCUV_Contests_Incentives__c> createContestsIncentives(Integer num) {
        List<HCUV_Contests_Incentives__c> ciObjList = new List<HCUV_Contests_Incentives__c>();
        
        for(Integer i=0;i<num;i++) {
            HCUV_Contests_Incentives__c ciObj = new HCUV_Contests_Incentives__c();
            ciObjList.add(ciObj);
        }
        insert ciObjList;
        return ciObjList;
    }  
    
    /**
    * @description - Creating test HCUV_Dealer_Message__c data
    * @param - num
    * @return List<HCUV_Dealer_Message__c>
    */
    public static List<HCUV_Dealer_Message__c> createDealerMessages(Integer num) {
        List<HCUV_Dealer_Message__c> dmObjList = new List<HCUV_Dealer_Message__c>();
        
        for(Integer i=0;i<num;i++) {
            HCUV_Dealer_Message__c dmObj = new HCUV_Dealer_Message__c();
            dmObjList.add(dmObj);
        }
        insert dmObjList;
        return dmObjList;
    }  
    
    /**
    * @description - Creating test ContentVersion data
    * @param - num
    * @return List<ContentDocument>
    */
    public static List<ContentDocument> createContentDocument(Integer num) {
        List<ContentVersion> cvObjList = new List<ContentVersion>();
        
        for(Integer i=0;i<num;i++) {
            ContentVersion cvObj = new ContentVersion();
            cvObj.Title = 'Test Document' + i;
            cvObj.PathOnClient = 'TestDocument' + i + '.pdf';
            cvObj.VersionData = Blob.valueOf('Test Content');
            cvObj.IsMajorVersion = true;
            cvObjList.add(cvObj);
        }
        insert cvObjList;
        
        return [SELECT Id FROM ContentDocument];
    } 
    
    /**
    * @description - Creating test ContentDocumentLink data
    * @param - num, linEntId, conDocId
    * @return List<ContentDocumentLink>
    */
    public static List<ContentDocumentLink> createContentDocumentLinks(Integer num, String linEntId, String conDocId) {
        List<ContentDocumentLink> cdlObjList = new List<ContentDocumentLink>();
        
        for(Integer i=0;i<num;i++) {
            ContentDocumentLink cdlObj = new ContentDocumentLink();
            cdlObj.LinkedEntityId = linEntId;
            cdlObj.ContentDocumentId = conDocId;
            cdlObj.shareType = 'V';
            cdlObjList.add(cdlObj);
        }
        insert cdlObjList;
        return cdlObjList;
    }
    
    /**
    * @description - Creating test external user data
    * @param - contactId, firstName, lastName, profileName
    * @return User
    */
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
        
        insert user;
        return user;
    }

    /**
    * @description - Creating Group Member records
    * @param - Id, Id
    * @return void
    */
    public static void createGroupMember(Id GroupId, Id UserOrGroupId) {
        GroupMember recMember = new GroupMember();
        recMember.GroupId = GroupId;
        recMember.UserOrGroupId = UserOrGroupId;
        insert recMember;
        System.debug ('MemberId: ' + recMember);
    }
    
    /**
    * @description - Creating test Internal User data
    * @param - firstName, lastName, profileName
    * @return User
    */
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

        insert user;
        return user;
    }
    
}