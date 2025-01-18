import { LightningElement, wire,api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
const FIELDS = ['Package_Initiation__c.Id'];
export default class CreatePIR extends NavigationMixin(LightningElement) {
    @api recordId;
    pirId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record({ error, data }) {
        if (data) {
            this.pirId = data.fields.Id.value;
            console.log('PIR ID:', this.pirId); 
        } else if (error) {
            console.error('Error retrieving record:', error);
        }
    }

    connectedCallback() {
        console.log('recordId in connectedCallback:', this.recordId);
    }

    get isButtonDisabled() {
        return !this.pirId;
    }
    
    openFormInNewTab() {
        
        var defination={ 
            componentDef:'c:dNAMSEditPIRType',
            attributes: { 
                recordId:this.pirId
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