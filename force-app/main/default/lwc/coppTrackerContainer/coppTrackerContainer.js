import { LightningElement, api } from 'lwc';

//DPM-5701
export default class CoppTrackerContainer extends LightningElement {
    @api recordId; 

    get vfPageUrl() {
        return `/apex/COPPMonthlyTracker?recordId=${this.recordId}`;
    }
}