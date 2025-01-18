import { LightningElement, api, wire } from 'lwc';
import getRelatedFiles from '@salesforce/apex/EvaluationDpmrController.getRelatedFiles';

export default class EvalDpmrFileRelatedList extends LightningElement {
    @api recordId;  
    columns = [
        {
            label: 'File Name',
            fieldName: 'FileUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'FileName' },
                target: '_blank'
            }
        },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'text'
        },
        {
            label: 'File Size',
            fieldName: 'FileSize',
            type: 'text'
        },
        {
            label: 'File Extension',
            fieldName: 'FileExtension',
            type: 'text'
        }
    ];

    get fileCount() {
        return this.fileList?.data?.length || 0;
    }

    @wire(getRelatedFiles, { evalId: '$recordId' })
    fileList;
}