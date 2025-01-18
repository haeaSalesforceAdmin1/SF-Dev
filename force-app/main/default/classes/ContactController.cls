public without sharing class ContactController {

    @AuraEnabled(cacheable=true)
    public static List<ContactWrapper> getRelatedContacts(String accId) {
		System.debug('####accId:'+accId);
        List<AccountContactRelation> relatedCon = [Select id,Contact.Name,Account.Name,IsDirect,Contact.Email,Contact.JobCode__c,Contact.Active_DPM_User__c,Roles,JobCode__c
            from AccountContactRelation where AccountId = :accId AND Contact.Active_DPM_User__c = true WITH SECURITY_ENFORCED];
		List<ContactWrapper> aconwrapList = new List<ContactWrapper>();	
        System.debug('relatedCon: '+relatedCon.size());
        
        if (!relatedCon.isEmpty()) {
            for (AccountContactRelation con : relatedCon) {
                ContactWrapper aconwrap = new ContactWrapper();
                aconwrap.AccountName = con.Account.Name;
                aconwrap.ContactName = con.Contact.Name;
                aconwrap.Email = con.Contact.Email; 
                aconwrap.Role = con.Roles;
                aconwrap.JobCode = con.JobCode__c;
                aconwrap.Direct = con.IsDirect;
                aconwrap.IsActive = con.Contact.Active_DPM_User__c;
                aconwrapList.add(aconwrap);           
            }
        }
        return aconwrapList;
    }
    public class ContactWrapper{
    @AuraEnabled 
    public String AccountName{get;set;}
    @AuraEnabled 
    public String ContactName{get;set;}
    @AuraEnabled 
    public String Email{get;set;}
    @AuraEnabled 
    public String Role{get;set;}
    @AuraEnabled 
    public String JobCode{get;set;}
    @AuraEnabled
    public Boolean Direct{get;set;}
    @AuraEnabled
    public Boolean IsActive{get;set;}
    }
}