/**
 * Created by baltamimi on 2022-02-21.
 */

import {api, LightningElement,track, wire} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {reduceErrors} from "c/ldsUtils";
import getPackageElements from '@salesforce/apex/PackageElementsViewerController.getPackageElements';

export default class PackageElementsViewer extends LightningElement {

    columns = [
        {
            label: 'Name', fieldName: 'packageElementUrl', type: 'url', wrapText: true,
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_self'
            }
        },
        {label: 'Section', fieldName: 'Section', type: 'text', wrapText: true},
        //{label: 'Type', fieldName: 'Type', type: 'text', wrapText: true},
        {label: 'Action Type', fieldName: 'ActionType', type: 'text', wrapText: true},
        {label: 'Required', fieldName: 'Required', type: 'boolean'},
        {label: 'Status', fieldName: 'Status', type: 'text'},
       /* {label: 'Dealer Progress', fieldName: 'ProgressDealer', type: 'progressRing',
        typeAttributes: {
            progress: {fieldName: 'RemainingDays'},
            variant: {fieldName: 'FeedbackIcon'}
        }},
        {
            label: 'Liked File', fieldName: 'attachmentLink', type: 'url', clipText: true,
            typeAttributes: {
                label: {
                    fieldName: 'attachmentTitle',
                },
                target: '_blank'
            },
            cellAttributes: {
                iconName: {fieldName: 'attachmentIcon'},
                iconPosition: 'left',
                iconAlternativeText: 'attachment'
            }
        },*/
    ];

    @track showOnloade=true;
    @api recordId;
    @track package;
    @wire(getRecord, {recordId: '$recordId', fields: ['Package__c.Status__c']})
    getPackageStatus({data, error}) {
        if (data) {
            this.package = data;
            this._initDataset();
        } else if (error) {
            console.error(error);
            this._handleError(error);
        }
    }


    @track packageElements = [];

    connectedCallback() {
        this._initDataset();
    }

    handleRefreshView(event) {
        this._initDataset();
    }

    // ------------------ Util Methods ------------------------

    _initDataset() {
        // Get package elements and render it 
        getPackageElements({packageId: this.recordId, runAsUser: 'dealer'})
            .then(result => {
                console.log('result:: ' + (result));
                let data = JSON.parse(result);

                //Fetch the Package Element page information
                data.forEach(packageElement => {
                    packageElement.packageElementUrl = '/packageelement/'+packageElement.Id+'/';
                    if (packageElement.attachmentLink) {
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
}