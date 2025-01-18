/**
 * Created by Bhavana on 2023-09-12.
 */
/**
 * Dnams Dealer Change Requests List Component
 */
import {api, LightningElement, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {reduceErrors} from "c/ldsUtils";
import getPicklistValues from '@salesforce/apex/DNAMSDealerChangeRequestsController.getPicklistValues';
import getDealerChangeRequests from '@salesforce/apex/DNAMSDealerChangeRequestsController.getDealerChangeRequests';
import basepath from '@salesforce/community/basePath';
import { deleteRecord } from 'lightning/uiRecordApi';

export default class DnamsDealerChangeRequestsList extends LightningElement {
    @api recordId;
    @track recordTypeId;
    @track mapData = [];
    @track showRecords = false;
    @track showError = false;
    @track openModel = false;
    @track isSaveAndNew = false;
    @track showOnload = true;
    @track isModalOpen = false; // Track modal visibility
    @track isErrorModalOpen = false; // Track error modal visibility
    @track dealerRecords = [];
    showSpinner = false;
    @track sortDirection = 'desc';
    @track sortBy = 'packageRequestUrl';
    @track baseUrl='';
    @track communityBasePath;
    @track  deleteId;
    columns = [
        {
            label: 'Change Request #', fieldName: 'packageRequestUrl', type: 'url', wrapText: true, sortable: true,
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_self'
            }
        },
        {
            label: 'Dealer', fieldName: 'packageRequestUrlForDealer', type: 'url', wrapText: true, sortable: true,
            typeAttributes: {
                label: {
                    fieldName: 'DealerName'
                },
                target: '_self'
            }
        },
        {label: 'Request Type', fieldName: 'Type', type: 'text', wrapText: true, sortable: true},
        {label: 'Status', fieldName: 'Status', type: 'text', wrapText: true, sortable: true},
        { label: '', type: 'action', typeAttributes: { rowActions: this.getRowActions } }
    ];

    // Define row actions
    getRowActions(row, doneCallback) {
        const actions = [
            { label: 'Delete', name: 'delete' }
        ];
        doneCallback(actions);
    }

    connectedCallback() {
        this.communityBasePath = basepath;
        this.callGetPicklistValues();
    }
    callGetPicklistValues(){
        getPicklistValues({
                objectName : 'PackageRequest__c',
                fieldName : 'Status__c'
            })
            .then(result =>{
                for (let key in result) {
                    this.mapData.push({value:result[key], key:key});
                }
                this._initDataset();
            })
            .catch(error => {
                console.error(error);
                this._handleError(error);
            });
    }
    // Error Handling with message
    _handleError(error) {
        this._showToast('Error: Something went wrong!', 'An unhandled error has occurred. Error message: ' + reduceErrors(error), 'error');
    }
    _initDataset() {
        //Fetch the Package Element page information
        getDealerChangeRequests()
            .then(result => {
                let baseUrl = 'https://' + location.host;
                let data = JSON.parse(result);
                let processedResult = [];
                data.forEach(record => {
                    record.packageRequestUrl = baseUrl + this.communityBasePath + '/packagerequest/' + record.Id + '/' + record.Name;
                    record.packageRequestUrlForDealer = baseUrl + this.communityBasePath + '/account/' + record.DealerId + '/' + record.DealerName;
                    record.Status = this.getValueByKey(this.mapData, record.Status);
                    processedResult.push(record);
                });
                this.dealerRecords = processedResult;
                this.sortData(this.sortBy, this.sortDirection);
                this.showRecords = true;
                this.showError = false;
            }).catch(error => {
            console.error(error);
            console.error('errors=='+error);
            this.showRecords = false;
            this.showError = true;
            this.showOnload = false; // Disable the New button
            //this._handleError(error);
        });
    }
    handleRowAction(event) {
        this.showSpinner = true;
        const action = event.detail.action.name;
        const deleteRecordId = event.detail.row.Id;
        if (action === 'delete') {
            this.showSpinner = false;
            this.isModalOpen = true;
            this.deleteId = deleteRecordId;
        }
    }
    handleDelete() {
        // Handle "Save & New" button click event
        this.showSpinner = true;
        deleteRecord(this.deleteId).then(() => {
            this.deleteId = ''; //Reset the Delete Id
            this.callGetPicklistValues();
            this.isModalOpen = false;
            this.showSpinner = false;
        }).catch((error) => {
            console.log("error, " + error);
            this.showSpinner = false;
            this.isModalOpen = false;
            this.isErrorModalOpen = true;
            this.deleteId = ''; //Reset the Delete Id
        })
    }
    // Close the dialog
    closeDialog() {
        this.showSpinner = true;
        this.isModalOpen = false;
        this.isErrorModalOpen = false;
        this.showSpinner = false;
        //location.reload();
    }
    // Function to get a single value based on a specific key
    getValueByKey(data, keyToFind) {
        for (let i = 0; i < data.length; i++) {
            if (data[i].key === keyToFind) {
                return data[i].value;
            }
        }
        // Return a default value or handle the case where the key is not found
        return "Not Found";
    }
    // variant: success, error, warning, info
    _showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    /*
     * Client controller to initiate sorting on-click of the data table column headers
     */
    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    /*
     * Sort data table columns by the column header
     */
    sortData(fieldName, sortDirection) {
        if(fieldName == 'packageRequestUrl') {
            fieldName = 'Name';
        }
        let parseData = JSON.parse(JSON.stringify(this.dealerRecords));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldName];
        };
        // cheking reverse direction
        let isReverse = sortDirection === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.dealerRecords = parseData;
    }
    /*
     * Function to capture the current column label on which sorting is performed.
     * this.sortBy stores the column's fieldName attribute. We need column label instead of the fieldName
     */
    get sortByLabel() {
        if(this.sortBy == 'packageRequestUrl')
            return 'Name';
        else if(this.sortBy == 'packageRequestUrlForDealer')
            return 'Dealer';
        else if(this.sortBy == 'Type')
            return 'Type';
        else if(this.sortBy == 'Status')
            return 'Status';
        else
            return this.sortBy;
    }

}