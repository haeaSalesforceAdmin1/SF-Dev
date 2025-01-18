@RestResource(urlMapping='/SODAS/*')
global with sharing class SODASUpdateCase {
    
    @HttpPost
    global static String doGet(String Alert,String CaseNumber) {
        
        String Id='';
        //List<Case> case = [SELECT id FROM Case WHERE SCSCaseNumber__c = :CaseNumber];
        List<Case> result = [SELECT Id,SODAS_Alert_ID__c FROM Case WHERE SCSCaseNumber__c = :CaseNumber];
        for(Case c: result){c.SODAS_Alert_ID__c=Alert;Id='Update Success';update c;
        }
        return Id;
        
        
}
}