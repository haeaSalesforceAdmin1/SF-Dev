import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import {labelList} from 'c/hcuvUtility';

export default class HCUVcarFaxCmp extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: ['Inventory__c.Name'] })
    wiredRecord({error, data}) {
        if(error) {
            if (Array.isArray(error.body)) {
                console.log('error = ' + error.body.map(e => e.message).join(', '));
            } else if (typeof error.body.message === 'string') {
                console.log('error = ' + error.body.message);
            }
        } else if (data) {
            window.open(labelList.CARFAX_NAVIGATE_URL+ data.fields.Name.value + '&source=BUP');

            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

}