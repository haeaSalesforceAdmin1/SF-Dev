/**
 * Created by baltamimi on 2022-02-13.
 */
public without sharing class PackageElementsViewerController {

    //Retrieves the logged in user's profile name
    @AuraEnabled
    public static String getCurrentUserRole() {
        Boolean isCommunityUser = [SELECT Id, IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId()].IsPortalEnabled;
        if (isCommunityUser) {
            return 'dealer';
        }
        return [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
    }

    //Retrieves the package elements to be displayed in the LWC
    @AuraEnabled(cacheable=false)
    public static String getPackageElements(String packageId, String runAsUser) {
        System.debug('PackageId:: ' + packageId + ', RunAsUser:: ' + runAsUser);
        List<PackageElementWrapper> elementsWrapper = new List<PackageElementWrapper>();

        Package__c sourcePackage = [
                SELECT Status__c
                FROM Package__c
                WHERE Id = :packageId
        ];
        System.debug('Package:: ' + JSON.serializePretty(sourcePackage));

        List<PackageElement__c> packageElements;

        if (runAsUser != null && runAsUser.equalsIgnoreCase('dealer')) {
            //Community users will see only a subset of package elements based on the filter criteria
            //Visible to Dealer = TRUE and Status = Initiated/RMR Returned/Closed
            packageElements = [
                    SELECT
                            Id,
                            Name,
                            Section__c,
                            Type__c,
                            Required__c,
                            VisibletoDealer__c,
                            Status__c,
                            RMAStatus__c,
                            NationalStatus__c,
                            Action_Type__c,
                            (
                            SELECT
                                    Id,
                                    ContentDocumentId,
                                    ContentDocument.Title
                            FROM ContentDocumentLinks
                            LIMIT 1000
                    )
                    FROM PackageElement__c
                    WHERE Package__c = :packageId
                    AND VisibletoDealer__c = TRUE
                    AND Package__r.Status__c IN ('Initiated','RMR Returned') //DNA-648
                    ORDER BY Sequence__c ASC
            ];
        } else {
            //Internal users will be able to see all package elements
            packageElements = [
                    SELECT
                            Id,
                            Name,
                            Section__c,
                            Type__c,
                            Required__c,
                            VisibletoDealer__c,
                            Status__c,
                            RMAStatus__c,
                            NationalStatus__c,
                            Action_Type__c,
                            (
                            SELECT
                                    Id,
                                    ContentDocumentId,
                                    ContentDocument.Title
                            FROM ContentDocumentLinks
                            LIMIT 1000
                    )
                    FROM PackageElement__c
                    WHERE Package__c = :packageId
                    ORDER BY Section__c ASC  //DNA-779
            ];
        }

        //Generate wrapper records
        for (PackageElement__c pe : packageElements) {
            System.debug('record:: ' + JSON.serializePretty(pe));

            PackageElementWrapper viewerWrapper = new PackageElementWrapper();
            viewerWrapper.Id = pe.Id;
            viewerWrapper.Name = pe.Name;
            viewerWrapper.Section = pe.Section__c;
            viewerWrapper.Type = pe.Type__c;
            viewerWrapper.Required = pe.Required__c;
            viewerWrapper.VisibletoDealer = pe.VisibletoDealer__c;
            viewerWrapper.Status = pe.Status__c;
            viewerWrapper.RMRStatus = pe.RMAStatus__c;
            viewerWrapper.DND1Status = pe.NationalStatus__c;
            viewerWrapper.ActionType = pe.Action_Type__c;
            viewerWrapper.strAttachmentCountDisplay = pe.ContentDocumentLinks != null && pe.ContentDocumentLinks.size() > 0 ? '(' + pe.ContentDocumentLinks.size() + ')': '';

            elementsWrapper.add(viewerWrapper);
        }

        return JSON.serialize(elementsWrapper);
    }

    //Method to update the package element flags - Required and Visible to Dealer
    @AuraEnabled
    public static string updatePackageElements(Object data) {

        List<PackageElementWrapper> elementsWrapper = (List<PackageElementWrapper>) JSON.deserialize(
            JSON.serialize(data),
            List<PackageElementWrapper>.class
        );
        System.debug(data);
        try {
            List<PackageElement__c> lstPackageElements = new List<PackageElement__c>();
            for(PackageElementWrapper element: elementsWrapper) {
                PackageElement__c pe = new PackageElement__c();
                pe.Id = element.Id;
                if(element.Required != null) {
                    pe.Required__c = element.Required;
                }
                if(element.VisibletoDealer != null) {
                    pe.VisibletoDealer__c = element.VisibletoDealer;
                }
                lstPackageElements.add(pe);
            }
            if (!Schema.sObjectType.PackageElement__c.isUpdateable()) {
                throw new SecurityException(
                    'Insufficient permissions to update Package Elements'
                );
            }
            update lstPackageElements;
            return 'Success: Package Elements updated!';
        }
        catch (Exception e) {
            throw new AuraHandledException('The following exception has occurred: ' + e.getMessage());
        }
    }

    // ---------------- Wrapper Classes ----------------
    public class PackageElementWrapper {
        public Id Id;
        public String Name;
        public String DND1Status;
        public Boolean Required;
        public String RMRStatus;
        public String RMStatus;
        public String Section;
        public String Status;
        public String Type;
        public String ActionType;
        public Boolean VisibletoDealer;
        public Integer RemainingDays;
        public String FeedbackIcon;
        public String strAttachmentCountDisplay;
        public String attachmentTitle;
        public String attachmentLink;
    }
}