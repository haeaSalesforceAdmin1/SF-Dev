import { LightningElement, api } from 'lwc';

export default class ShowPdfById extends LightningElement {
    @api fileId;
    @api heightInRem = "100";

    get pdfHeight() {
        return 'height: ' + this.heightInRem + '%';
    }
    
    get url() {
        return '/sfc/servlet.shepherd/document/download/' + this.fileId;
    }
}