/**
 * Description: Displays buttons on the LR creation screen. 
 * When moving to the next step, a modal is shown to inform the user that the LR will be created, but they can continue to add vehicle information.
 * Created by Areum on 10-15-2024 for STIL-124
 */

import { LightningElement, track, api } from 'lwc';  
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class LRWarningPopup extends LightningElement {
    @track isModalOpen = false;
    _SCSCaseNumber = '';

    @api
    set SCSCaseNumber(value) {
        this._SCSCaseNumber = value ? value : '';
        console.log('SCSCaseNumber changed:', this._SCSCaseNumber);
    }

    get SCSCaseNumber() {
        return this._SCSCaseNumber;
    }
    
    get hasSCSCaseNumber() {
        return typeof this.SCSCaseNumber === 'string' && this.SCSCaseNumber.trim() !== '';
    }    

    // cancel
    handleFlowCancel() {
        window.location.href = '/lightning/n/LR_Home';
    }

    // next
    handleFlowNext() {
        this.isModalOpen = true;
    }

    // (modal) close: X button 
    handleCloseModal() {
        this.isModalOpen = false;
    }

    // (modal) previous
    handleModalPrevious() {
        this.isModalOpen = false;
    }

    // (modal) cancel
    handleModalCancel() {
        window.location.href = '/lightning/n/LR_Home';
    }

    // (modal) Next
    handleModalNext() {
        const nextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextEvent); 
        this.isModalOpen = false;
    }
}