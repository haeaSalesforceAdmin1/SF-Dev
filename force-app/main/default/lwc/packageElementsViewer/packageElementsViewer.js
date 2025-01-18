/**
 * Created by baltamimi on 2022-02-13.
 */
/**
 * Package Elements Viewer Component
 */
import {api, LightningElement, track, wire} from 'lwc';
import {getRecord, updateRecord} from 'lightning/uiRecordApi';
import {getRecordNotifyChange} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from "lightning/navigation";
import {reduceErrors} from "c/ldsUtils";
import {refreshApex} from '@salesforce/apex';
import getPackageElements from '@salesforce/apex/PackageElementsViewerController.getPackageElements';
import runAsUser from '@salesforce/apex/PackageElementsViewerController.getCurrentUserRole';
import isDNDUser from '@salesforce/customPermission/DNAMSNationalUser';
import isRMRUser from '@salesforce/customPermission/DNAMSRegionMarketAdmin';
import updatePackageElements from '@salesforce/apex/PackageElementsViewerController.updatePackageElements';

export default class PackageElementsViewer extends NavigationMixin(LightningElement) {

    columns = [
        {
            label: 'Name', fieldName: 'packageElementUrl', type: 'url', wrapText: true, sortable: true,
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_self'
            }
        },
        {label: 'Action Type', fieldName: 'ActionType', type: 'text', wrapText: true},
        {label: 'Section', fieldName: 'Section', type: 'text', wrapText: true, sortable: true},
        {label: 'Required', fieldName: 'Required', type: 'boolean', editable: false, sortable: true},
        {label: 'Visible to Dealer', fieldName: 'VisibletoDealer', type: 'boolean', editable: false, sortable: true},
        {label: 'Status', fieldName: 'Status', type: 'text', wrapText: true, sortable: true},
        {label: 'RMR Status', fieldName: 'RMRStatus', type: 'text', wrapText: true, sortable: true},
        {label: 'DND 1 Status', fieldName: 'DND1Status', type: 'text', wrapText: true, sortable: true},
        {
            label: 'Attachments', fieldName: 'strAttachmentCountDisplay', type: 'text', clipText: true,
            cellAttributes: {
                iconName: {fieldName: 'attachmentIcon'},
                iconPosition: 'left',
                iconAlternativeText: 'attachment'
            }
        }
    ];

    @api recordId;
    @track package;
    @wire(getRecord, {recordId: '$recordId', fields: ['Package__c.Status__c']})
    getPackageStatus({data, error}) {
        if (data) {
            this.package = data;
            console.log('Package Status: ' + data.fields.Status__c.value);
            this.checkPackageStatus(data.fields.Status__c.value);
            this._initDataset();
        } else if (error) {
            console.error(error);
            this._handleError(error);
        }
    }

    @track packageElements = [];
    @track runAsUser;
    @track isStepOwner = false;
    showSpinner = false;
    draftValues = [];
    @track showOnload = true;
    @track sortDirection = 'asc';
    @track sortBy = 'packageElementUrl';

    connectedCallback() {
        this._initDataset();
        runAsUser()
            .then(result => {
                this.runAsUser = result;
                if(this.runAsUser === 'System Administrator' || isDNDUser === true || isRMRUser === true) {
                    this.isStepOwner = true;
                    this.columns[3].editable = true;
                    this.columns[4].editable = true;
                }
            })
            .catch(error => {
                console.error(error);
                this._handleError(error);
            });
    }

    _initDataset() {
        //Fetch the Package Element page information
        getPackageElements({packageId: this.recordId, runAsUser: this.runAsUser})
            .then(result => {
                console.log('result:: ' + (result));
                let baseUrl = 'https://' + location.host + '/';
                let data = JSON.parse(result);
                data.forEach(packageElement => {
                    packageElement.packageElementUrl = baseUrl + packageElement.Id;
                    if (packageElement.strAttachmentCountDisplay) {
                        packageElement.attachmentIcon = 'utility:attach';
                    }
                });

                this.packageElements = data;
            }).catch(error => {
            console.error(error);
            this._handleError(error);
        });
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

    async handleSave(event) {
        this.showSpinner = true;
        
        const updatedFields = event.detail.draftValues;
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
        console.log(notifyChangeIds);

        try {
            // Pass edited fields to the updatePackageElements Apex controller
            const result = await updatePackageElements({data: updatedFields});
            console.log(JSON.stringify("Apex update result: "+ result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Package Elements updated!',
                    variant: 'success'
                })
            );
    
            // Refresh LDS cache and wires
            getRecordNotifyChange(notifyChangeIds);
            
            // Display fresh data in the datatable
            await refreshApex(this._initDataset());

            // Clear all draft values in the datatable
            this.draftValues = [];
            
        }
        catch(error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        };
        this.showSpinner = false;
    }
 
     // Call Add Documents Flow 
     openFlow() {
        console.log('---'+this.recordId);
        this[ NavigationMixin.Navigate ]( {
            type: 'standard__webPage',
            attributes: {
                url: '/flow/DNA_Add_Documents?recordId=' + this.recordId + '&retURL=' + this.recordId
            }
        },
        true // Replaces the current page in your browser history with the URL if set to true
        );
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
        if(fieldName == 'packageElementUrl') {
            fieldName = 'Name';
        }
        console.log('Sorting package elements by: ' + fieldName);
        let parseData = JSON.parse(JSON.stringify(this.packageElements));
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
        this.packageElements = parseData;
    }

    /*
     * Function to capture the current column label on which sorting is performed.
     * this.sortBy stores the column's fieldName attribute. We need column label instead of the fieldName
     */
    get sortByLabel() {
        if(this.sortBy == 'packageElementUrl')
            return 'Name';
        else if(this.sortBy == 'VisibletoDealer')
            return 'Visible to Dealer';
        else if(this.sortBy == 'RMRStatus')
            return 'RMR Status';
        else if(this.sortBy == 'DND1Status')
            return 'DND 1 Status';
        else
            return this.sortBy;
    }

    /*
     * Function to check status of the package and control button visibilities
     */
    checkPackageStatus(packageStatus) {
        if(packageStatus === 'Closed' || packageStatus === 'Canceled') {
            this.showOnload = false;
        }
    }
}