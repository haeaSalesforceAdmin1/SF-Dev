import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getRelatedWorkOrders from '@salesforce/apex/RelatedWorkOrdersController.getRelatedWorkOrders';

export default class RelatedWorkOrders extends NavigationMixin(LightningElement) {
    
    // Table Logics
    @api recordId;
    @track workOrders = [];
    @track showSpinner = false;
    @track summaryList = [];
    @track errorList = [];

    connectedCallback(){
        // Load all affected vehicles related to the case
        this.retrieveRelatedWorkOrders();
    }

    retrieveRelatedWorkOrders(){
        this.errorList = [];
        this.showSpinner = true;
        // Load all affected vehicles related to the case
        getRelatedWorkOrders({caseId: this.recordId})
         .then(result => {
             this.workOrders = JSON.parse(result);
             this.hasMultiRows = this.workOrders.length > 1;
             this.showSpinner = false;
         }).catch(error => {
             // TODO: Error Handling
             console.log('Error fetching affected vehicles');
             console.log(JSON.stringify(error));
             this.errorList.push(JSON.stringify(error));
             this.showSpinner = false;
         })
    }

    handleNavigate(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.value,
                objectApiName: 'WorkOrder',
                actionName: 'view'
            }
        });
    }

}