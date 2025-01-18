import { LightningElement, api } from 'lwc';
import getUserTypeAccess from '@salesforce/apex/DPMHelpController.getUserTypeAccess'
export default class DpmParent extends LightningElement {
    @api dpmResources;
    @api salesOrgLabel;
    @api afterSalesOrgLabel;
    @api questionLinksLabel;
    @api cxOrgLabel;
    @api keystoneOrgLabel;
    @api financialOrgLabel;
    showAllTabs = false;
    activeTab = 'HMA';
    activeTabHMA = 'HMACorporate';
    activeTabGMA = 'GMACorporate';
    showHMA = false;
    showGMA = false;
    hasData = false;
    @api
    get userType() {
        return;
    }

    set userType(value) {
        this._typeOfUser = value;
        if(value === "internal") {
            this.showAllTabs = true;
            this.activeTabGMA = 'GMACorporate';
            this.activeTabHMA = 'HMACorporate';
            this.activeTab = 'HMA';
            this.showHMA = true;
            this.showGMA = true;
            this.hasData = true;
        } else if(value === "community") {
            this.showAllTabs = false;
            this.activeTabGMA = 'GMARetailer';
            this.activeTabHMA = 'HMADealer';
            getUserTypeAccess()
            .then((result, error) => {
                if(result) {
                    this.hasData = true;
                    if(value === 'community') {
                        if(result.includes('DPM_GenUserExt') && result.includes('DPM_HyundaiExt')) {
                            this.showHMA = true;
                            this.showGMA = true;
                            this.activeTab = 'HMA';
                        } else if(result.includes('DPM_GenUserExt')) {
                            this.activeTab = 'GMA';
                            this.activeTabGMA = 'GMARetailer';
                            this.showGMA = true;                        
                            this.showHMA = false;
                        } else if(result.includes('DPM_HyundaiExt')) {
                            this.showHMA = true;
                            this.showGMA = false;
                            this.activeTab = 'HMA';
                        }
                    }
                }
            })
            .catch(error => {

            });
        }
    }

    connectedCallback() {
        
    }
}