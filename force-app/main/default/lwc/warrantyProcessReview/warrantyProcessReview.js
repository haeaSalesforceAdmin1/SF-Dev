import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from '@salesforce/schema/Account.Id';
import Last_Warranty_Process_Date from '@salesforce/schema/Account.Last_Warranty_Process_Date__c';
import Warranty_Process_Review_Path from '@salesforce/schema/Account.Warranty_Process_Review_Path__c';
import Warranty_Review_Help_Text from '@salesforce/label/c.Warranty_Review_Help_Text';

const FIELDS = [
    'Account.Last_Warranty_Process_Date__c',
    'Account.Warranty_Process_Review_Path__c',
];

export default class WarrantyProcessReview extends LightningElement {
    @api recordId;
    record;
    error;
    warrantyDate;
    warrantyPath;
    warrantyDateToUpdate;
    warrantyPathToUpdate;
    isModalOpen = false;
    isLoading = false;

    label = {
        Warranty_Review_Help_Text
    };
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredAccount({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }
    get warrantyProcessDate() {
        var tmpDate = this.record.fields.Last_Warranty_Process_Date__c.value;
        if (tmpDate != undefined && tmpDate != null && tmpDate != ''){
            this.warrantyDate = tmpDate.split('/')[2]+'-'+tmpDate.split('/')[0]+'-'+tmpDate.split('/')[1];
        }
        
        return this.record.fields.Last_Warranty_Process_Date__c.value;
    }

    get warrantyProcessReviewPath(){
        this.warrantyPath = this.record.fields.Warranty_Process_Review_Path__c.value;
        return this.record.fields.Warranty_Process_Review_Path__c.value;
    }

    closeModal(){
        this.isModalOpen = false;
    }

    openModal(){
        this.isModalOpen = true;
        this.isLoading = false;
    }

    submitDetails(){
        this.isLoading = true;
        var tmpDate = this.warrantyDateToUpdate.split('-')[1]+'/'+this.warrantyDateToUpdate.split('-')[2]+'/'+this.warrantyDateToUpdate.split('-')[0];
        

        const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[Last_Warranty_Process_Date.fieldApiName] = tmpDate;
            fields[Warranty_Process_Review_Path.fieldApiName] = this.warrantyPathToUpdate;

            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record updated Successfully',
                            variant: 'success'
                        })
                    );
                    this.isModalOpen = false;
                    
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    this.isModalOpen = false;
                });
    }

    valChange(event){
        if(event.target.name == 'warrantyDate') {

        this.warrantyDateToUpdate = event.target.value;
     }
    if(event.target.name == 'warrantyPath'){

        this.warrantyPathToUpdate = event.target.value;
     }
    }
}