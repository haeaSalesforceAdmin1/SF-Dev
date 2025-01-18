/**
 * Description: [Class Description]
 * COPP -  Download pdf controller
 * ----- Change Log -----
 * Author : [MinheeKim] / [2024-10-07] / [DPM-5701] / [Created] 
 * Edited : [MinheeKim] / [2024-11-07] / [DPM-5916] / [Added commentsValue variable] 
 * ---------------------------
 */

public class COPPDownloadController {
    @AuraEnabled
    public static String  generateCombined(String recordId, String LetterDate, String regionName, String DealershipName, String DealerShip_Address, 
                                 String City_State_Zip_Code, String Email_Address, String DealerPrincipalName, String ChoosedTemplate, String regionCode, String Salutation, String CommentsValue) {

        PageReference pdfPage = new PageReference('/apex/COPPMergedPDF');
        pdfPage.getParameters().put('LetterDate', LetterDate);
        pdfPage.getParameters().put('recordId', recordId);
        pdfPage.getParameters().put('regionName', regionName);
        pdfPage.getParameters().put('DealershipName', DealershipName);
        pdfPage.getParameters().put('DealerShip_Address', DealerShip_Address);
        pdfPage.getParameters().put('City_State_Zip_Code', City_State_Zip_Code);
        pdfPage.getParameters().put('Email_Address', Email_Address);
        pdfPage.getParameters().put('DealerPrincipalName', DealerPrincipalName);
        pdfPage.getParameters().put('ChoosedTemplate', ChoosedTemplate);
        pdfPage.getParameters().put('regionCode', regionCode);
        pdfPage.getParameters().put('Salutation', Salutation); //DPM-5861 added salutation 10-16-2024 by MinheeKim
        CommentsValue = CommentsValue.replaceAll('\n', '<br/>'); //DPM-5916 added CommentsValue 11-19-2024 by JonghoonKim
        pdfPage.getParameters().put('CommentsValue', CommentsValue); //DPM-5916 added CommentsValue 11-19-2024 by JonghoonKim


        Blob pdfBlob = Test.isRunningTest() ? Blob.valueOf('Unit Test Attachment') : pdfPage.getContentAsPDF();

        String dealerCode = [SELECT DealerCode__c FROM Account WHERE Id =:recordId LIMIT 1].DealerCode__c;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'COPP_Tracker_Letter_' + dealerCode+'_'+Date.Today()+'_'+ChoosedTemplate;
        cv.ContentLocation = 'S';
        cv.PathOnClient = 'COPP_Tracker_Letter_' + dealerCode+'_'+Date.Today()+'_'+ChoosedTemplate+'.pdf';
        cv.VersionData = pdfBlob;
        cv.IsMajorVersion = true;
        insert cv;

        ContentVersion cdl = [
            SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1
        ];

        System.debug('contentDocumentId: '+String.valueOf(cdl.ContentDocumentId));
        return String.valueOf(cdl.ContentDocumentId);
        
    }

    /**
     * Description: [Method Description] 
     * Get values for tracker and GM scorecard
     * Created by [MinheeKim] on [MM-DD-YYYY] for [DPM-5701] 
     * Edited by [JonghoonKim] on [11-18-2024] for [DPM-5916]
    */
    @AuraEnabled
    public static String generateTracker(Id recordId, String coppDownloadName, String CommentsValue) {
        try {
            String pdfFileName ='';
            PageReference pdfPage = null;
            if(coppDownloadName == 'COPP_Tracker') {
                pdfPage = Page.COPPMonthlyTracker; 
            } else if(coppDownloadName == 'GM_Scorecard') {
                pdfPage = Page.GMScorecard; 
            }
            pdfPage.getParameters().put('recordId', recordId);
            CommentsValue = CommentsValue.replaceAll('\n', '<br/>');
            pdfPage.getParameters().put('CommentsValue', CommentsValue);

            Blob pdfBlob =  Test.isRunningTest() ? Blob.valueOf('Unit Test Attachment') : pdfPage.getContentAsPDF();

            String dealerCode = [SELECT DealerCode__c FROM Account WHERE Id =:recordId LIMIT 1].DealerCode__c;

            pdfFileName = coppDownloadName + '_' + dealerCode + '.pdf';
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = pdfFileName;
            contentVersion.PathOnClient = pdfFileName;
            contentVersion.VersionData = pdfBlob;
            contentVersion.IsMajorVersion = true;
            insert contentVersion;

            ContentVersion cdl = [
                SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1
            ];

            return String.valueOf(cdl.ContentDocumentId);

        } catch (Exception e) {
            throw new AuraHandledException('Error generating tracker PDF: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String generateLetter(String LetterDate, String regionName, String DealershipName, String DealerShip_Address, 
                                        String City_State_Zip_Code, String Email_Address, String DealerPrincipalName, 
                                        String ChoosedTemplate, String regionCode, String Salutation, Id recordId) {
        try {
            PageReference pdfPage = Page.COPPLetter; 
            pdfPage.getParameters().put('LetterDate', LetterDate);
            pdfPage.getParameters().put('regionName', regionName);
            pdfPage.getParameters().put('DealershipName', DealershipName);
            pdfPage.getParameters().put('DealerShip_Address', DealerShip_Address);
            pdfPage.getParameters().put('City_State_Zip_Code', City_State_Zip_Code);
            pdfPage.getParameters().put('Email_Address', Email_Address);
            pdfPage.getParameters().put('DealerPrincipalName', DealerPrincipalName);
            pdfPage.getParameters().put('ChoosedTemplate', ChoosedTemplate);
            pdfPage.getParameters().put('regionCode', regionCode);
            pdfPage.getParameters().put('Salutation', Salutation); //DPM-5861 added salutation 10-16-2024 by MinheeKim

            Blob pdfBlob =  Test.isRunningTest() ? Blob.valueOf('Unit Test Attachment') :  pdfPage.getContentAsPDF();

            String dealerCode = [SELECT DealerCode__c FROM Account WHERE Id =:recordId LIMIT 1].DealerCode__c;

            String pdfFileName = 'COPP_Letter_' + dealerCode+'_'+ChoosedTemplate+'.pdf';
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = pdfFileName;
            contentVersion.PathOnClient = pdfFileName;
            contentVersion.VersionData = pdfBlob;
            contentVersion.IsMajorVersion = true;
            insert contentVersion;

            ContentVersion cdl = [
                SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1
            ];

            return String.valueOf(cdl.ContentDocumentId);

        } catch (Exception e) {
            throw new AuraHandledException('Error generating letter PDF: ' + e.getMessage());
        }
    }
}