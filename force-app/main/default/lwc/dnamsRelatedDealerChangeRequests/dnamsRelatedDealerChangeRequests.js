/**
 * Created by Bhavana on 2023-08-30.
 */
/**
 * Dnams Related Dealer Change Requests Component
 */
import {api, LightningElement, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from "lightning/navigation";
import {reduceErrors} from "c/ldsUtils";
import getRecordTypeId from '@salesforce/apex/DNAMSDealerChangeRequestsController.getRecordTypeId';
import getPicklistValues from '@salesforce/apex/DNAMSDealerChangeRequestsController.getPicklistValues';
import getDealerChangeRequests from '@salesforce/apex/DNAMSDealerChangeRequestsController.getDealerChangeRequestsForRelatedList';
import basepath from '@salesforce/community/basePath';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PACKAGEREQUEST_OBJECT from "@salesforce/schema/PackageRequest__c";

export default class DnamsRelatedDealerChangeRequests extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track recordTypeId;
    @track mapData = [];
    @track showRecords = false;
    @track showError = false;
    @track openModel = false;
    @track isSaveAndNew = false;
    @track showOnload = true;
    @track isModalOpen = false; // Track modal visibility
    @track dealerRecords = [];
    @track allDealerRecords = [];
    @track firstFourRecords = [];
    @track showViewAll = true;
    @track showViewLess = false;
    showSpinner = false;
    @track communityBasePath;
    
    @wire(getObjectInfo, { objectApiName: PACKAGEREQUEST_OBJECT })
    objectInfo;
    
    columns = [
        {
            label: 'Change Request #', fieldName: 'packageRequestUrl', type: 'url', wrapText: true, sortable: false,
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_self'
            }
        },
        {label: 'Request Type', fieldName: 'RequestType__c', type: 'text', wrapText: true},
        {label: 'Status', fieldName: 'Status__c', type: 'text', wrapText: true, sortable: false}
    ];

    connectedCallback() {
        this.communityBasePath = basepath;
        this.callGetRecordTypeId();
        this.callGetPicklistValues();
        
    }
    callGetRecordTypeId(){
        getRecordTypeId({nameStr:'Dealer Request'})
            .then(result =>{
                this.recordTypeId = result;
            })
            .catch(error => {
                console.error(error);
                console.error('errors=='+error);
            });
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
                console.error('errors=='+error);
            });
    }
    _initDataset() {
        //Fetch the Package Element page information
        getDealerChangeRequests({
                recordId: this.recordId
            })
            .then(result => {
                if(result === 'Error'){
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
                        record.packageRequestUrl = baseUrl + this.communityBasePath + '/packagerequest/' + record.Id + '/' + record.Name;
                        record.Status__c = this.getValueByKey(this.mapData, record.Status__c);
                        processedResult.push(record);
                    });
                    
                    this.allDealerRecords = processedResult;
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
                    this.dealerRecords = this.firstFourRecords;
                    this.showRecords = true;
                    this.showError = false;
                }
            }).catch(error => {
            console.error(error);
            console.error('errors=='+error);
            this.showRecords = false;
            this.showError = true;
            this.showOnload = false; // Disable the New button
            //this._handleError(error);
        });
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
    
    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault(); // Prevent the default form submission
        this.template.querySelector('lightning-record-edit-form').submit();
        this.showSpinner = false;
    }
    handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.fieldName == 'RequestType__c' || field.fieldName == 'RequestComments__c'){
                    field.reset();
                }
            });
        }
    }
    handleSuccess(event) {
        // Handle successful record creation/update here
        const createdRecordId = event.detail.id;
        const createdRecordName = event.detail.Name;
        // You can perform any actions after the record is created/updated
        // Show a toast message
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Dealer Change Request has been created successfully.',
            variant: 'success',
        });
        this.dispatchEvent(toastEvent);

        // Redirect to the created record
        if(!this.isSaveAndNew){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: createdRecordId,
                    objectApiName: 'PackageRequest__c', // Replace with your object API name
                    actionName: 'view',
                },
            });
            this.isSaveAndNew = false;
        }else{
            this.handleReset();
            this.isSaveAndNew = false;
        }
    }
    handleSaveAndNew(event) {
        // Handle "Save & New" button click event
        const form = this.template.querySelector('lightning-record-edit-form');
        form.submit();
        this.isSaveAndNew = true;
        this.isModalOpen = true;
    }
    viewAll(){
        this.showSpinner = true;
        this.dealerRecords = this.allDealerRecords;
        this.showViewAll = false;
        this.showViewLess = true;
        this.showSpinner = false;
    }

    viewLess(){
        this.showSpinner = true;
        this.dealerRecords = this.firstFourRecords;
        this.showViewAll = true;
        this.showViewLess = false;
        this.showSpinner = false;
    }
    // Open the dialog
    openDialog() {
        this.isModalOpen = true;
    }
    // Close the dialog
    closeDialog() {
        this.isModalOpen = false;
        // Clear input fields if needed
        this.name = '';
        location.reload();
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
    navigateToRecord(event) {
        const recordId = event.detail.row.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'PackageRequest__c',
                actionName: 'view',
            },
        });
    }

}