/**
 * Created by Bhavana on 2023-08-30.
 */
/**
 * Packages Component
 */
import {api, LightningElement, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from "lightning/navigation";
import {reduceErrors} from "c/ldsUtils";
import getPackages from '@salesforce/apex/DNAMSPackagesController.getPackagesForRelated';
import basepath from '@salesforce/community/basePath';

export default class DnamsRelatedPackages extends NavigationMixin(LightningElement) {
    @api recordId;
    @track recordTypeId;
    @track mapData = [];
    @track showRecords = false;
    @track showError = false;
    @track openModel = false;
    @track showOnload = true;
    @track isModalOpen = false; // Track modal visibility
    @track packageRecords = [];
    @track allRecords = [];
    @track firstFourRecords = [];
    @track showViewAll = true;
    @track showViewLess = false;
    @track communityBasePath;
    showSpinner = false;
    columns = [
        {
            label: 'Package Number', fieldName: 'packageElementUrl', type: 'url', wrapText: true, sortable: false,
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_self'
            }
        },
        {label: 'Type', fieldName: 'Type__c', type: 'text', wrapText: true},
        {label: 'Status', fieldName: 'Status_2__c', type: 'text', wrapText: true, sortable: false}
    ];

    connectedCallback() {
        this.communityBasePath = basepath;
        this._initDataset();
    }
    
    _initDataset() {
        //Fetch the Package Element page information
        getPackages({
                recordId: this.recordId
            })
            .then(result => {
                if(result == 'Error'){
                    console.error(error);
                    console.error('Error=='+error);
                    this.showRecords = false;
                    this.showError = true;
                    this.showOnload = false; // Disable the New button
                }else{
                    let baseUrl = 'https://' + location.host + '/';
                    let data = JSON.parse(result);
                    let processedResult = [];
                    data.forEach(record => {
                        record.packageRequestUrl = baseUrl + this.communityBasePath + '/package/' + record.Id + '/' + record.Name;
                        processedResult.push(record);
                    });
                    //this.packageRecords = processedResult;
                    this.allRecords = processedResult;

                    let number;
                    if(processedResult.length > 4){
                        number = 4;
                    }else{
                        number = processedResult.length
                    }
                    for (let i = 0; i < number; i++) {
                        console.log('i======================>'+i);
                        this.firstFourRecords.push(processedResult[i]);
                        console.log('i======================>'+JSON.stringify(processedResult[i]));
                    }
                    this.packageRecords = this.firstFourRecords;

                    this.showRecords = true;
                    this.showError = false;
                }
            }).catch(error => {
            console.error(error);
            console.error('errors=='+error);
            console.error('errors=='+JSON.stringify(error));
            this.showRecords = false;
            this.showError = true;
            this.showOnload = false; // Disable the New button
            //this._handleError(error);
        });
    }
    viewAll(){
        this.showSpinner = true;
        this.packageRecords = this.allRecords;
        this.showViewAll = false;
        this.showViewLess = true;
        this.showSpinner = false;
    }
    viewLess(){
        this.showSpinner = true;
        this.packageRecords = this.firstFourRecords;
        this.showViewAll = true;
        this.showViewLess = false;
        this.showSpinner = false;
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
    
    // Error Handling with message
    _handleError(error) {
        this._showToast('Error: Something went wrong!', 'An unhandled error has occurred. Error message: ' + reduceErrors(error), 'error');
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
}