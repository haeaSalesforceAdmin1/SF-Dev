import {LightningElement, api, track} from 'lwc';
import getNASOData from '@salesforce/apex/CaseVinMismatchController.getNASOData';
import getVehicleData from '@salesforce/apex/CaseVinMismatchController.getVehicleData';
import getFiltervisblity from '@salesforce/apex/CaseVinMismatchController.getFiltervisblity';
import checkCaseOwnOrg from '@salesforce/apex/CaseVinMismatchController.checkCaseOwnOrg';
import acceptBtnClicked from '@salesforce/apex/CaseVinMismatchController.acceptBtnClicked';
import rejectBtnClicked from '@salesforce/apex/CaseVinMismatchController.rejectBtnClicked';
import getNHTSATREADCategory from '@salesforce/apex/CaseVinMismatchController.getNHTSATREADCategory';
import updateMisMatchCase from '@salesforce/apex/CaseVinMismatchController.updateMisMatchCase';
import updateAcceptMisMatchCase from '@salesforce/apex/CaseVinMismatchController.updateAcceptMisMatchCase';
import updateRejectMisMatchCase from '@salesforce/apex/CaseVinMismatchController.updateRejectMisMatchCase';
import {getRecordNotifyChange} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import {reduceErrors} from "c/ldsUtils";

export default class CaseVinMismatchMessage extends LightningElement {
    @api recordId;

    @track isMismatch = false;
    @track filterVisblity = false;
    @track nasoCheck = false;
    @track nextPage = false;
    @track categoryInput = false;
    @track vehicleInfo = {};
    @track getNASODataInfo = {};
    @track showSpinner = false;
    @track buttonLabel= '';
    @track navexStatusAccept= false;
    @api category;
    treadCategory = [];
    subject = '';
    description = '';


    connectedCallback() {
        this.showSpinner = true;
        console.log('Case Vin Mismatch Record ID: ' + this.recordId);

        /**
        * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
        * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
        * @tecket no: SO-311
        */
        getNASOData({caseId: this.recordId})
        .then(result => {
            if ( result != null) {
                let resultObj = JSON.parse(result);
                this.getNASODataInfo = resultObj;
            }
            console.log('getNASOData!!!');
        })
        .catch(error => {
            let reducedError = this.getFriendlyErrorMessage(error);

            const evt = new ShowToastEvent({
                title: 'getNASOData',
                message: reducedError,
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }),

        /**
        * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
        * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
        * @tecket no: SO-311
        */
        getFiltervisblity({caseId: this.recordId})
        .then(result => {
            if ( JSON.parse(result) == true) {
                this.filterVisblity = true;           
            }
            console.log('filterVisblity::',this.filterVisblity);
            console.log('CheckCaseOwnOrg!!!');
        })
        .catch(error => {
            let reducedError = this.getFriendlyErrorMessage(error);

            const evt = new ShowToastEvent({
                title: 'Filtervisblity',
                message: reducedError,
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }),

        /**
        * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
        * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
        * @Last Modified : 2024-03-15 
        * @tecket no: SO-311
        */
        checkCaseOwnOrg({caseId: this.recordId})
        .then(result => {
        if ( JSON.parse(result) == true) {
            this.nasoCheck = true;
            if(this.getNASODataInfo.caseNHTSATREADCategory == undefined && this.nasoCheck && !this.filterVisblity){
                this.categoryInput = true;
            }
        }

        })

        .catch(error => {
        let reducedError = this.getFriendlyErrorMessage(error);

        const evt = new ShowToastEvent({
            title: 'NASOCheck',
            message: reducedError,
            variant: 'warning',
        });

        this.dispatchEvent(evt);
        }),

        getVehicleData({caseId: this.recordId})
            .then(result => {
                if (result == null) {
                    /**
                    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
                    * @author San, Kang : SanKang@autoeveramerica.com | 2024-03-15
                    * @tecket no: SO-311
                    */
                    if(this.getNASODataInfo.caseNHTSATREADCategory == undefined && this.nasoCheck){
                        this.categoryInput = true;
                    }
                    this.isMismatch = false;
                } else {
                    let resultObj = JSON.parse(result);
                    this.vehicleInfo = resultObj;
                    if (resultObj.mismatchFields) {
                        this.isMismatch = true;
                    }
                }
            })
            .catch(error => {
                console.log('Error retrieving case vin fields mismatch: ' + JSON.stringify(error));
                let reducedError = this.getFriendlyErrorMessage(error);

                const evt = new ShowToastEvent({
                    title: 'Error retrieving case vin fields mismatch 2',
                    message: reducedError,
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                this.showSpinner = false;
            })
            
    
            
        /**
        * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
        * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
        * @tecket no: SO-311
        */
        getNHTSATREADCategory({caseId: this.recordId})
        .then(result => {
            this.treadCategory = result.map(item => {
                return {
                    label: item.label,
                    value: item.value
                }
            });
        })
        .catch(error => {
            console.log('getNHTSATREADCategory: ' + JSON.stringify(error));
            let reducedError = this.getFriendlyErrorMessage(error);

            const evt = new ShowToastEvent({
                title: 'getNHTSATREADCategory',
                message: reducedError,
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        })

        this.showSpinner = false;

    }

    handleAcceptBtn(event) {
        this.showSpinner = true;
        acceptBtnClicked({caseId: this.recordId})
            .then(result => {
                // Notify LDS that you've changed the record outside its mechanisms.
                getRecordNotifyChange([{recordId: this.recordId}]);
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    title: 'Navex Fields updated successfully',
                    variant: 'success',
                });
                
                this.dispatchEvent(evt);
                this.isMismatch = false;
                window.location.reload();
            })
            .catch(error => {
                console.log('Error updating Navex Fields: ' + JSON.stringify(error));
                let reducedError = this.getFriendlyErrorMessage(error);

                const evt = new ShowToastEvent({
                    title: 'Failed to update Navex fields',
                    message: reducedError,
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                this.showSpinner = false;
            })
    }

    handleRejectBtn(event) {
        this.showSpinner = true;
        rejectBtnClicked({caseId: this.recordId})
            .then(result => {
                console.log('Case NAVEXValidatorStatus__c is set to Reject');
                // Notify LDS that you've changed the record outside its mechanisms.
                getRecordNotifyChange([{recordId: this.recordId}]);
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    title: 'Record updated Successfully',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.isMismatch = false;
            })
            .catch(error => {
                console.log('Error updating Navex Fields: ' + JSON.stringify(error));
                let reducedError = this.getFriendlyErrorMessage(error);

                const evt = new ShowToastEvent({
                    title: 'Failed to update Navex fields',
                    message: reducedError,
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                this.showSpinner = false;
            })
    }

    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */

    handleToggleClick(event) {
        this.showSpinner = false;
        this.nextPage = !this.nextPage;
        if(event.target.dataset.name == 'Accept'){
            this.navexStatusAccept=true;
        }
        console.log('debug',this.navexStatusAccept);
    }

    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */
    selecttreadCategory(event){
        this.category = event.detail.value;
    }

    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */
    updateRejectMisMatch(event) {
        if(this.category == undefined){
            const evt = new ShowToastEvent({
                title: 'Please select at least one NHTSA TREAD Category.',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }else{
            this.showSpinner = true;
            this.subject = this.template.querySelector('.subject').value;
            this.description = this.template.querySelector('.description').value;
            updateRejectMisMatchCase({category: this.category, subject: this.subject, description: this.description, caseId: this.recordId})
            .then(result => {
                console.log('Navex Fields updated successfully');
                // Notify LDS that you've changed the record outside its mechanisms.
                getRecordNotifyChange([{recordId: this.recordId}]);
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    title: 'Navex Fields updated successfully',
                    variant: 'success',
                });
                this.isMismatch = false;
                window.location.reload();
            })
            .catch(error => {
                console.log('Error updating Navex Fields: ' + JSON.stringify(error));
                let reducedError = this.getFriendlyErrorMessage(error);

                const evt = new ShowToastEvent({
                    title: 'Failed to update Navex fields',
                    message: reducedError,
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                this.showSpinner = false;
            })
        }
        
    }
    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */
    updateAcceptMisMatch(event) {
        if(this.category == undefined){
            const evt = new ShowToastEvent({
                title: 'Please select at least one NHTSA TREAD Category.',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }else{
            this.showSpinner = true;
            this.subject = this.template.querySelector('.subject').value;
            this.description = this.template.querySelector('.description').value;
            updateAcceptMisMatchCase({category: this.category, subject: this.subject, description: this.description, caseId: this.recordId})
            .then(result => {
                console.log('Navex Fields updated successfully');
                // Notify LDS that you've changed the record outside its mechanisms.
                getRecordNotifyChange([{recordId: this.recordId}]);
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    title: 'Navex Fields updated successfully',
                    variant: 'success',
                });
                this.isMismatch = false;
                window.location.reload();
            })
            .catch(error => {
                console.log('Error updating Navex Fields: ' + JSON.stringify(error));
                let reducedError = this.getFriendlyErrorMessage(error);
                const evt = new ShowToastEvent({
                    title: 'Failed to update Navex fields',
                    message: reducedError,
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                this.showSpinner = false;
            })
        }
    }
    /**
    * @description : Add new field called "NHTSA TREAD Category" to CMT only for North America
    * @author San, Kang : SanKang@autoeveramerica.com | 2024-01-17 ~ 2024-01-19
    * @tecket no: SO-311
    */
    handleUpdateBtn(event) {

        if(this.category == undefined){
            const evt = new ShowToastEvent({
                title: 'Please select at least one NHTSA TREAD Category.',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }else{
            this.showSpinner = true;
            this.subject = this.template.querySelector('.subject').value;
            this.description = this.template.querySelector('.description').value;
            updateMisMatchCase({category: this.category, subject: this.subject, description: this.description, caseId: this.recordId})
            .then(result => {
                console.log('Navex Fields updated successfully');
                // Notify LDS that you've changed the record outside its mechanisms.
                getRecordNotifyChange([{recordId: this.recordId}]);
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    title: 'Navex Fields updated successfully',
                    variant: 'success',
                });
                this.isMismatch = false;
                window.location.reload();
            })
            .catch(error => {
                console.log('Error updating Navex Fields: ' + JSON.stringify(error));
                let reducedError = this.getFriendlyErrorMessage(error);
                
                const evt = new ShowToastEvent({
                    title: 'Failed to update Navex fields',
                    message: reducedError,
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                this.showSpinner = false;
            })
        }
        
    }

    getFriendlyErrorMessage(error) {
        let reducedError = reduceErrors(error)[0];
        if (reducedError.includes('first error:')) {
            reducedError = reducedError.substring(reducedError.indexOf('first error:') + 13);
        }
        console.log('Reduced Error: ' + reducedError);

        return reducedError;
    }
}