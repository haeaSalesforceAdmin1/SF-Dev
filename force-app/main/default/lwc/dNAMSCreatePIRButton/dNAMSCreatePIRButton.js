import { LightningElement, wire,api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
const FIELDS = ['Account.Id'];
export default class CreatePIR extends NavigationMixin(LightningElement) {
    @api recordId;
    accountId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record({ error, data }) {
        if (data) {
            this.accountId = data.fields.Id.value;
            console.log('Account ID:', this.accountId); 
        } else if (error) {
            console.error('Error retrieving record:', error);
        }
    }

    connectedCallback() {
        console.log('recordId in connectedCallback:', this.recordId);
    }

    get isButtonDisabled() {
        return !this.accountId; 
    }
    
    openFormInNewTab() {
    
        var defination={ 
            componentDef:'c:dNAMSPIRFormDocumentTemplate',
            attributes: { 
                recordId:this.accountId
            }
        }
        this[NavigationMixin.Navigate]({ 
            type:'standard__webPage',
            attributes: { 
                url:'/one/one.app#'+btoa(JSON.stringify(defination))
            }
        })
    }
 }