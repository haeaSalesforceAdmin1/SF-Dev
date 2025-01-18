/**
     * [Class Description] COPP Project - Save the letter template pdf
     * Created by [MinheeKim] on [2024-08-19] for [DPM-5701]
     * Edited by [MinheeKim] on [2024-10-16] for [DPM-5861] added salutation
     * Edited by [MinheeKim] on [2024-11-18] for [DPM-5916] added download function scorecard
    */

public with sharing class COPPTrackerSaveController {

    public class Request {
        @InvocableVariable(required=true)
        public Id accountId;
        @InvocableVariable(required=true)
        public String letterDate;
        @InvocableVariable(required=true)
        public String regionName;
        @InvocableVariable(required=true)
        public String dealerPrincipalName;
        @InvocableVariable(required=true)
        public String dealershipName;
        @InvocableVariable(required=true)
        public String dealerShipAddress;
        @InvocableVariable(required=true)
        public String cityStateZipCode;
        @InvocableVariable(required=true)
        public String emailAddress;
        @InvocableVariable(required=true)
        public String choosedTemplate;
        @InvocableVariable(required=true)
        public String brandCode;
        @InvocableVariable(required=true)
        public String dealerCode;
        @InvocableVariable(required=true)
        public String regionCode;
        @InvocableVariable(required=false)
        public String salutation;
        @InvocableVariable(required=false)
        public String comments; //Added for scorecard by MinheeKim - DPM-5916 11.18.2024
        @InvocableVariable(required=true)
        public Boolean onlyTracker;

    }
    
    public class Response {
        @InvocableVariable
        public String result;
    }



    @InvocableMethod(label='Save COPP Tracker')
    public static void generatePDFAndSave(List<Request> requests) {
        Request request = requests[0];
        List<ContentVersion> contentVersionList = new List<ContentVersion>();

        //tracker PDF
        String trackerPageUrl = '/apex/COPPMonthlyTracker?recordId=' + EncodingUtil.urlEncode(request.accountId, 'UTF-8');
        PageReference trackerPage = new PageReference(trackerPageUrl);
        Blob trackerBlob;
        try {
            trackerBlob = trackerPage.getContentAsPDF();
        } catch (Exception e) {
            System.debug('Error generating PDF: ' + e.getMessage());
        }

        ContentVersion contentVersionTracker = new ContentVersion();
        contentVersionTracker.VersionData = trackerBlob;
        contentVersionTracker.Title = 'COPP_Tracker_' + request.dealerCode;
        contentVersionTracker.PathOnClient = 'COPP_Tracker_' + request.dealerCode+'.pdf';
        contentVersionList.add(contentVersionTracker);


        //Letter PDF
        if(!request.onlyTracker){
            String pdfPageUrl = '/apex/COPPLetter?LetterDate=' + EncodingUtil.urlEncode(request.letterDate, 'UTF-8') +
            '&regionName=' + EncodingUtil.urlEncode(request.regionName, 'UTF-8') +
            '&DealerPrincipalName=' + EncodingUtil.urlEncode(request.dealerPrincipalName, 'UTF-8') +
            '&DealershipName=' + EncodingUtil.urlEncode(request.dealershipName, 'UTF-8') +
            '&DealerShip_Address=' + EncodingUtil.urlEncode(request.dealerShipAddress, 'UTF-8') +
            '&City_State_Zip_Code=' + EncodingUtil.urlEncode(request.cityStateZipCode, 'UTF-8') +
            '&Email_Address=' + EncodingUtil.urlEncode(request.emailAddress, 'UTF-8') +
            '&ChoosedTemplate=' + EncodingUtil.urlEncode(request.choosedTemplate, 'UTF-8') +
            '&BrandCode=' + EncodingUtil.urlEncode(request.brandCode, 'UTF-8') +
            '&regionCode=' + EncodingUtil.urlEncode(request.regionCode, 'UTF-8') +
            '&Salutation=' + EncodingUtil.urlEncode(request.salutation, 'UTF-8');

            PageReference pdfPage = new PageReference(pdfPageUrl);
            Blob pdfBlob;
            try {
                pdfBlob = pdfPage.getContentAsPDF();
            } catch (Exception e) {
                System.debug('Error generating PDF: ' + e.getMessage());
            }

            
            ContentVersion ContentVersionLetter  = new ContentVersion();
            ContentVersionLetter.VersionData = pdfBlob;
            ContentVersionLetter.Title = 'COPP_Letter_' + request.dealerCode+'_'+request.choosedTemplate;
            ContentVersionLetter.PathOnClient = 'COPP_Letter_' + request.dealerCode+'_'+request.choosedTemplate+'.pdf';
            contentVersionList.add(ContentVersionLetter);

            String MergedPageUrl = '/apex/COPPMergedPDF?LetterDate=' + EncodingUtil.urlEncode(request.letterDate, 'UTF-8') +
            '&recordId=' + + EncodingUtil.urlEncode(request.accountId, 'UTF-8')+
            '&regionName=' + EncodingUtil.urlEncode(request.regionName, 'UTF-8') +
            '&DealerPrincipalName=' + EncodingUtil.urlEncode(request.dealerPrincipalName, 'UTF-8') +
            '&DealershipName=' + EncodingUtil.urlEncode(request.dealershipName, 'UTF-8') +
            '&DealerShip_Address=' + EncodingUtil.urlEncode(request.dealerShipAddress, 'UTF-8') +
            '&City_State_Zip_Code=' + EncodingUtil.urlEncode(request.cityStateZipCode, 'UTF-8') +
            '&Email_Address=' + EncodingUtil.urlEncode(request.emailAddress, 'UTF-8') +
            '&ChoosedTemplate=' + EncodingUtil.urlEncode(request.choosedTemplate, 'UTF-8') +
            '&BrandCode=' + EncodingUtil.urlEncode(request.brandCode, 'UTF-8') +
            '&regionCode=' + EncodingUtil.urlEncode(request.regionCode, 'UTF-8')+
            '&Salutation=' + EncodingUtil.urlEncode(request.salutation, 'UTF-8')+
            '&CommentsValue=' + EncodingUtil.urlEncode(request.comments, 'UTF-8'); //Added for scorecard by MinheeKim - DPM-5916 11.18.2024

            PageReference mergedPage = new PageReference(MergedPageUrl);
            Blob mergedBlob;
            try {
                mergedBlob = mergedPage.getContentAsPDF();
            } catch (Exception e) {
                System.debug('Error generating PDF: ' + e.getMessage());
            }

            
            ContentVersion ContentVersionMerged  = new ContentVersion();
            ContentVersionMerged.VersionData = mergedBlob;
            ContentVersionMerged.Title = 'COPP_Tracker_Letter_' + request.dealerCode+'_'+request.choosedTemplate;
            ContentVersionMerged.PathOnClient = 'COPP_Tracker_Letter_' + request.dealerCode+'_'+request.choosedTemplate+'.pdf';
            contentVersionList.add(ContentVersionMerged);
        
        }

        try {
            insert contentVersionList;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }


    }

  


}