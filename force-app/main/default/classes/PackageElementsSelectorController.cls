/**
* Created by baltamimi on 2022-02-10.
*/

public with sharing class PackageElementsSelectorController {
    /**
*  This method returns list of packges
*/
    @AuraEnabled
    public static List<PackageElement__c> getPackageElementsFromTemplate(String templatePackageId) {
        try {
            return [
                SELECT
                Id,
                Name,
                Section__c,
                Type__c,
                Required__c,
                VisibletoDealer__c,
                Sequence__c,
                Conga_Template__c, 
                Instructions__c,
                Action_Type__c
                FROM PackageElement__c
                WHERE Package__c = :templatePackageId
                ORDER BY Sequence__c ASC
            ];
        } catch (Exception err) {
            System.debug(err.getMessage());
            System.debug(err.getCause());
            System.debug(err.getLineNumber());
            System.debug(err.getStackTraceString());
            throw new AuraHandledException('Error ' + err.getMessage());
        }
    }
    
    /**
*  This is for createing new package 
*/
    @AuraEnabled
    public static String createNewPackage(String dealerId, String sellingDealerId, Id templatePackageId, String packageName, String packageDescription,
                                          Id primaryContactId, List<PackageElement__c> selectedPackageElementsTemplates) {
        System.debug(dealerId + '|' + sellingDealerId + '|' + templatePackageId + '|' + packageName + '|' + packageDescription + '|' + primaryContactId + '|' + selectedPackageElementsTemplates);
        Package__c originalPackage = [
            SELECT
            Classification__c,
            Dealer__c,
            Description__c,
            Id,
            Name,
            PackageDetail__c,
            Sequence__c,
            Status__c,
            Type__c,
            BMI_Approval_Required__c,
            Legal_Approval_Required__c,
            Planning_Approval_Required__c,
            Performance_Approval_Required__c, //DNA-1026,DNA-1029
            Dealer_Groups_Approval_Required__c //DNA-1026,DNA-1029
            FROM Package__c
            WHERE Id = :templatePackageId
        ];
        
        Package__c newPackage;
        
        try {
            String packageDefaultRecordTypeId = Schema.Package__c.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('DefaultPackage').recordTypeId;
            List<Region__c> lstRegions = new List<Region__c>();
            
            newPackage = originalPackage.clone();
            newPackage.RecordTypeId = packageDefaultRecordTypeId;
            newPackage.PackageTemplate__c = templatePackageId;
            newPackage.Status__c = 'Draft';
            newPackage.PackageName__c = packageName;
            newPackage.Description__c = packageDescription; //Received from the flow. Overrides the template's Package Description
            newPackage.PrimaryContact__c = primaryContactId;
            
            if (!String.isEmpty(dealerId)) {
                newPackage.Dealer__c = dealerId;
                lstRegions = [SELECT Id FROM Region__c WHERE Id IN (SELECT Region__c FROM Account WHERE Id = :dealerId) LIMIT 1];
            }
            if (!String.isEmpty(sellingDealerId)) {
                newPackage.Selling_Dealer__c = sellingDealerId;
            }

            if(!lstRegions.isEmpty()) {
                newPackage.Region__c = lstRegions[0].Id;
            }
            
            insert newPackage;
            
            String packageElementDefaultRecordTypeId = Schema.PackageElement__c.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get('DefaultPackageItem').recordTypeId;        
            List<PackageElement__c> packageElementsToCreate = new List<PackageElement__c>();
            for (PackageElement__c pe : selectedPackageElementsTemplates) {
                pe.TemplatePackageElement__c = pe.Id;
                pe.Id = null;
                pe.RecordTypeId = packageElementDefaultRecordTypeId;
                pe.Package__c = newPackage.Id;
                pe.Status__c = 'Draft';
                pe.RMAStatus__c = 'Under Review';
                pe.Instructions__c=pe.Instructions__c;
                
                if (!String.isEmpty(dealerId)) {
                    pe.Dealer__c = dealerId;
                }         
                if (!String.isEmpty(sellingDealerId)) {
                    pe.Selling_Dealer__c = sellingDealerId;
                }

                if(!lstRegions.isEmpty()) {
                    pe.Region__c = lstRegions[0].Id;
                }

                packageElementsToCreate.add(pe);
            }
            
            if (packageElementsToCreate.size() > 0) {
                insert packageElementsToCreate;
            }
            
            System.debug(JSON.serializePretty(newPackage));
            System.debug(JSON.serializePretty(packageElementsToCreate));
            System.debug(packageElementsToCreate.get(0));
            
        } catch (Exception err) {
            System.debug('An error has occurred! Error Details:');
            System.debug(err.getMessage());
            System.debug(err.getCause());
            System.debug(err.getLineNumber());
            System.debug(err.getStackTraceString());
            throw new AuraHandledException('Error ' + err.getMessage());
        }
        
        return newPackage.Id;
        
    }
    
    public class MissingCustomSettingException extends Exception {
    }
}