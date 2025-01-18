// DPM-5633

import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getCommunityBaseUrl from '@salesforce/apex/GenesisActionPlanPDFController.getCommunityBaseUrl';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import MODAL_CHANNEL from '@salesforce/messageChannel/ModalChannel__c';

const FIELDS = ['Evaluation__c.Action_Plan_Status__c', 'Evaluation__c.Id', 'Evaluation__c.ActionPlanFileId__c'];

export default class DownloadActionPlanFormBtn extends NavigationMixin(LightningElement) {
    @api recordId;
    @api contentDocumentId;
    isPending = false;
    isCompleted = false;
    evalId = '';
    baseUrl;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    recordHandler({ error, data }) {
        if (data) {
            const status = data.fields.Action_Plan_Status__c.value;
            this.isPending = (status === 'Pending' || status === 'Late' || status === 'Not Submitted');
            this.isCompleted = (status === 'Completed' && data.fields.ActionPlanFileId__c.value != null);
            
            this.contentDocumentId = data.fields.ActionPlanFileId__c.value;
            this.evalId = data.fields.Id.value;
        } else if (error) {
            console.error('Error fetching record', error);
        }
    }

    @wire(getCommunityBaseUrl)
    wiredBaseUrl({ error, data }) {
        if (data) {
            this.baseUrl =  data.replace('salesforce', 'site');
            console.log('Base URL: ' + this.baseUrl);
        } else if (error) {
            console.error('Error: ' + error);
        }
    }

    @wire(MessageContext)
    messageContext;

    handleButtonClick() {
        const vfPageUrl = `${this.baseUrl}/genesisdealer/s/sfdcpage/%2Fapex%2FGenesisActionPlanPDF%3F%26id%3D${this.evalId}`;
        console.log('vfPageUrl: ' + vfPageUrl);
        window.location.href = vfPageUrl;
    }

    handleViewButtonClick() {
        const payload = {
            fileId: this.contentDocumentId,
            recordId: this.recordId
        };
        publish(this.messageContext, MODAL_CHANNEL, payload);
    }
}