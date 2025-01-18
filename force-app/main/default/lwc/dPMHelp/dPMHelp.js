import { LightningElement, api } from 'lwc';
import getDPMLinks from '@salesforce/apex/DPMHelpController.getDPMLinks';
import getDSMDPSM from '@salesforce/apex/DPMHelpController.getDSMANDDPSM';
export default class DPMHelp extends LightningElement {
    @api dpmResources;
    @api salesOrgLabel;
    @api afterSalesOrgLabel;
    @api questionLinksLabel;
    @api cxOrgLabel;
    @api keystoneOrgLabel;
    @api financialOrgLabel;
    @api typeOfScreen;
    @api headerClass;
    dpmResourceLinks;
    questionLinks;
    salesOrgLinks;
    cxOrgLinks;
    keystoneOrgLinks;
    afterSalesOrgLinks;
    financialOrgLinks;
    quickReferenceClass;
    dsm;
    dpsm;
    gmm;
    gamm;
    boolShowPopover;
    isCorporate = false;
    hoverContactDetails;
    showKeystone = false;
    //isGMACorporate = false;

    connectedCallback() {
        //code
        if(this.typeOfScreen === 'HMACorporate' || this.typeOfScreen === 'GMACorporate') {
            this.isCorporate = true;
        } else {
            this.isCorporate = false;
            getDSMDPSM()
            .then( result => {
            	if(result) {
                    console.log('console.log(result.DistrictSalesManager__r' + result[0].DistrictSalesManager__r);
                    console.log('console.log(result.DistrictPartsServiceManager__r' + result[0].DistrictPartsServiceManager__r);
                    if(this.typeOfScreen === 'HMADealer') {
                        this.dsm = result[0].DistrictSalesManager__r;
            		    this.dpsm = result[0].DistrictPartsServiceManager__r;
                    } else if(this.typeOfScreen === 'GMARetailer') {
                        this.gmm = result[0].MarketManager__r;
            		    this.gamm = result[0].Aftersales_Market_Manager__r;
                    }
            		
            	}
            }).
            catch(error => {
            });
        }
        if(this.typeOfScreen === 'HMACorporate' || this.typeOfScreen === 'HMADealer') {
            this.quickReferenceClass = 'borderAroundQuickRefHMA slds-col slds-size_1-of-1';
        } else {
            this.quickReferenceClass = 'borderAroundQuickRef slds-col slds-size_1-of-1';
        }

        this.showKeystone = this.typeOfScreen === ('GMARetailer' || 'GMACorporate') ? true : false; //DPM-4989 added  'GMACorporate' by MH - 2024.01.26

        getDPMLinks({typeOfHeader : this.typeOfScreen})
        .then( result => {
            if(result) {
                const dpmHelpData = JSON.parse(JSON.stringify(result));
                //this.dpmResourceLinks = dpmHelpData['DPM Resources and How To'].sort();
                this.dpmResourceLinks = dpmHelpData['DPM Resources and How To'];
                this.questionLinks = dpmHelpData['Questions?'];
                this.salesOrgLinks = dpmHelpData['Sales QRG'];
                this.cxOrgLinks = dpmHelpData['CX QRG'];
                this.keystoneOrgLinks = dpmHelpData['Keystone'];
                this.afterSalesOrgLinks = dpmHelpData['After Sales QRG'];
                this.financialOrgLinks = dpmHelpData['Financial QRG'];
                
            }
        })
        .catch(error => {
            console.log('Error==>' + JSON.stringify(error));
        })
    }

    togglePopover(event) {
        this.boolShowPopover = !this.boolShowPopover;
    }

    openPopover(event) {
        const questionType = event.currentTarget.dataset.type;
        this.hoverContactDetails = {};
        if(questionType === 'dsm') {
            this.hoverContactDetails = this.dsm;
        } else if(questionType === 'dpsm') {
            this.hoverContactDetails = this.dpsm;
        } else if(questionType === 'gmm') {
            this.hoverContactDetails = this.gmm;
        } else if(questionType === 'gamm') {
            this.hoverContactDetails = this.gamm;
        }
        this.boolShowPopover = true;
    }

    closePopOver(event) {
        new Promise(function(resolve, reject) {
  
            // Setting 2000 ms time
            setTimeout(resolve, 2000);
        }).then(result => {
            this.boolShowPopover = false;
        });
        
    }
}