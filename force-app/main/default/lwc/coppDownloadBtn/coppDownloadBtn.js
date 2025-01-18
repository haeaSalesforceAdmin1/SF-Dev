/**
     * [Class Description] COPP Project - Save the letter template pdf
     * Created by [MinheeKim] on [2024-08-19] for [DPM-5701]
     * Edited by [MinheeKim] on [2024-10-16] for [DPM-5861] added salutation
    */

import { LightningElement, api } from 'lwc';
import generateCombined from '@salesforce/apex/COPPDownloadController.generateCombined';
import generateTracker from '@salesforce/apex/COPPDownloadController.generateTracker'; 
import generateLetter from '@salesforce/apex/COPPDownloadController.generateLetter'; 
import { NavigationMixin } from 'lightning/navigation';


export default class CoppDownloadBtn extends NavigationMixin(LightningElement) {
 
    @api LetterDate;
    @api regionName;
    @api DealerPrincipalName;
    @api DealershipName;
    @api DealerShip_Address;
    @api City_State_Zip_Code;
    @api Email_Address;
    @api ChoosedTemplate;
    @api regionCode;
    @api showLetter;
    @api Salutation; //DPM-5861 added salutation
    @api recordId;
    @api Comments; //DPM-5916 added comments
   
 
    // handleClickLetter() {
    //     window.open(`/apex/COPPLetter?LetterDate=${this.LetterDate}`+`&regionName=${this.regionName}`
    //     +`&DealershipName=${this.DealershipName}`+`&DealerShip_Address=${this.DealerShip_Address}`
    //     +`&City_State_Zip_Code=${this.City_State_Zip_Code}`+`&Email_Address=${this.Email_Address}`
    //     +`&DealerPrincipalName=${this.DealerPrincipalName}`+`&ChoosedTemplate=${this.ChoosedTemplate}`
    //     +`&regionCode=${this.regionCode}`, '_blank');
    // }
 
    // handleClickTracker() {
    //     window.open(`/apex/COPPMonthlyTracker?recordId=${this.recordId}`, '_blank');
    // }
 
    //handleClickCombined() {
        // window.open(`/apex/COPPMergedPDF?LetterDate=${this.LetterDate}`
        //     +`&recordId=${this.recordId}`
        //     +`&regionName=${this.regionName}`
        //     +`&DealershipName=${this.DealershipName}`+`&DealerShip_Address=${this.DealerShip_Address}`
        //     +`&City_State_Zip_Code=${this.City_State_Zip_Code}`+`&Email_Address=${this.Email_Address}`
        //     +`&DealerPrincipalName=${this.DealerPrincipalName}`+`&ChoosedTemplate=${this.ChoosedTemplate}`
        //     +`&regionCode=${this.regionCode}`, '_blank');
 
    //}

    handleClickLetter() {
        generateLetter({
            LetterDate: this.LetterDate,
            regionName: this.regionName,
            DealershipName: this.DealershipName,
            DealerShip_Address: this.DealerShip_Address,
            City_State_Zip_Code: this.City_State_Zip_Code,
            Email_Address: this.Email_Address,
            DealerPrincipalName: this.DealerPrincipalName,
            ChoosedTemplate: this.ChoosedTemplate,
            regionCode: this.regionCode,
            Salutation: this.Salutation,
            recordId: this.recordId 
        })
        .then((pdfUrl) => {
            const userAgent = window.navigator.userAgent;

            if (/Mobi|Android|iPhone|iPad|iPod|Windows Phone/i.test(userAgent)) {
                const pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: pdfUrl,  
                        objectApiName: 'ContentDocument',
                        actionName: 'view'
                    }
                    
                };
                this.navigateToRecord(pageReference);
            } else {
                window.open(`/apex/COPPLetter?LetterDate=${this.LetterDate}`+`&regionName=${this.regionName}`
                +`&DealershipName=${this.DealershipName}`+`&DealerShip_Address=${this.DealerShip_Address}`
                +`&City_State_Zip_Code=${this.City_State_Zip_Code}`+`&Email_Address=${this.Email_Address}`
                +`&DealerPrincipalName=${this.DealerPrincipalName}`+`&ChoosedTemplate=${this.ChoosedTemplate}`
                +`&regionCode=${this.regionCode}`+`&Salutation=${this.Salutation}`, '_blank');
            }
        })
        .catch((error) => {
            console.error('Error generating letter PDF:', error);
        });
    }

    
    handleClickTracker() {
        generateTracker({ recordId: this.recordId, coppDownloadName: 'COPP_Tracker', CommentsValue:'' })
            .then((trackerUrl) => {
                const userAgent = window.navigator.userAgent;

                if (/Mobi|Android|iPhone|iPad|iPod|Windows Phone/i.test(userAgent)) {

                    const pageReference = {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: trackerUrl,  
                            objectApiName: 'ContentDocument',
                            actionName: 'view'
                        }
                        
                    };
                    this[NavigationMixin.Navigate](pageReference);
                } else {
                    window.open(`/apex/COPPMonthlyTracker?recordId=${this.recordId}`, '_blank');
                }
            })
            .catch((error) => {
                console.error('Error generating tracker PDF:', error);
            });
    }

    /**
     * Description: [Method Description] 
     * Added for downloading the GM scorecard
     * Created by [Author] on [MM-DD-YYYY] for [DPM-5701]
     * Edited by [MinheeKim] on [11-18-2024] for [DPM-5916]
    */
    handleClickGMScorecard() {
        generateTracker({ recordId: this.recordId, CommentsValue: (this.Comments || "").replace(/\n/g, '<br/>'), coppDownloadName: 'GM_Scorecard' })
            .then((trackerUrl) => {
                const userAgent = window.navigator.userAgent;

                if (/Mobi|Android|iPhone|iPad|iPod|Windows Phone/i.test(userAgent)) {

                    const pageReference = {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: trackerUrl,  
                            objectApiName: 'ContentDocument',
                            actionName: 'view'
                        }
                        
                    };
                    this[NavigationMixin.Navigate](pageReference);
                } else {
                    console.log('recordId: ' + this.recordId + ' CommentsValue: ' + this.Comments);
                    this.Comments = (this.Comments || "").replace(/\n/g, '<br/>')
                    window.open(`/apex/GMScorecard?recordId=${this.recordId}`+`&CommentsValue=${encodeURIComponent(this.Comments)}`, '_blank');
                }
            })
            .catch((error) => {
                console.error('Error generating tracker PDF:', error);
            });
    }

    handleClickCombined() {
        generateCombined({
            recordId: this.recordId,
            LetterDate: this.LetterDate,
            regionName: this.regionName,
            DealershipName: this.DealershipName,
            DealerShip_Address: this.DealerShip_Address,
            City_State_Zip_Code: this.City_State_Zip_Code,
            Email_Address: this.Email_Address,
            DealerPrincipalName: this.DealerPrincipalName,
            ChoosedTemplate: this.ChoosedTemplate,
            regionCode: this.regionCode,
            Salutation: this.Salutation,
            CommentsValue: this.Comments 
        })
        .then((pdfUrl) => {
 
            const userAgent = window.navigator.userAgent;
        
            if (/Mobi|Android|iPhone|iPad|iPod|Windows Phone/i.test(userAgent)) {
                const pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: pdfUrl,  
                        objectApiName: 'ContentDocument',
                        actionName: 'view'
                    }
                };
        
                 this.navigateToRecord(pageReference);
                //window.open(pdfUrl, '_blank');
            } else {
                this.Comments = (this.Comments || "").replace(/\n/g, '<br/>')
                window.open(`/apex/COPPMergedPDF?LetterDate=${this.LetterDate}`
                    +`&recordId=${this.recordId}`
                    +`&regionName=${this.regionName}`
                    +`&DealershipName=${this.DealershipName}`+`&DealerShip_Address=${this.DealerShip_Address}`
                    +`&City_State_Zip_Code=${this.City_State_Zip_Code}`+`&Email_Address=${this.Email_Address}`
                    +`&DealerPrincipalName=${this.DealerPrincipalName}`+`&ChoosedTemplate=${this.ChoosedTemplate}`
                    +`&CommentsValue=${encodeURIComponent(this.Comments)}`
                    +`&regionCode=${this.regionCode}`+`&Salutation=${this.Salutation}`, '_blank');
            }
        })
        .catch((error) => {
            console.error('Error generating PDF:', error);
        });
    }


    
        navigateToRecord(pageReference) {
            this[NavigationMixin.Navigate](pageReference);
        }

}