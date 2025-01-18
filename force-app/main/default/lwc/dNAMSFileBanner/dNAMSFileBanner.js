import { LightningElement, wire, api } from 'lwc';
import fetchFields from '@salesforce/apex/DNAMSFileBannerController.fetchFields';
import {NavigationMixin} from 'lightning/navigation';
//import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

//import filetype_field from '@salesforce/schema/ContentDocument.FileExtension';

export default class CustomHighlightPanel extends NavigationMixin(LightningElement) {
 
    @api recordId;
    @api objectApiName;
    @api fieldSet;
    nameField = '';
    fieldList = [];
    fileSize;
    fileExtension;
    ownername;
    @api fileownerId;
    isHideOwnername;
    objectApiName = 'ContentDocument';
    doctype;
		
	/*@wire(getRecord, { recordId: '$recordId', fields:[filetype_field] })
    ContentDocument;

    get filetype() {
        var doctype;
        var filetype = getFieldValue(this.ContentDocument.data, filetype_field);
        alert(filetype);
        if(filetype == 'png'){
            doctype = 'doctype:image';
        }
        else if(filetype == 'pdf'){
            doctype = 'doctype:pdf';
        }
        else if(filetype == 'doc'){
            doctype = 'doctype:doc';
        }
        return doctype ;
    }*/

	connectedCallback() {
        
        fetchFields({
            recordId : this.recordId,
            objectName : this.objectApiName,
        }).then(result => {
            if(result) {
                console.log(result);
                if(result.message != undefined) {
                    return;
                }
                var total;
                this.nameField = result.nameField;
                this.fieldList = result.fieldsAPI;
                this.isHideOwnername = result.isHideowner;
                var file = result.fileResult[0];
                var consize = parseInt(file.ContentSize);
                
                if (consize < 1024){
                    total = String(consize) + ' Bytes';
                }    
                else if (consize >= 1024 && consize < (1024*1024))
                {
                    var kb = consize;
                    kb = kb / 1024;
                    total = String(Math.round(kb)) + ' KB';
                }
                else if (consize >= (1024*1024) && consize < (1024*1024*1024))
                {
                    var mb = consize;
                    mb = mb/(1024*1024);
                    total = String(Math.round(mb)) + ' MB';
                }else
                {
                    var gb = consize;
                    gb = gb/(1024*1024*1024);
                    total = String( Math.round(gb)) + ' GB';
                } 
                this.fileSize = total;
                this.fileExtension = file.FileExtension;
                this.ownername = file.Owner.Name;
                this.fileownerId = file.Owner.Id;
                var filetype = file.FileExtension;
                if(filetype == 'png'){
                    this.doctype = 'doctype:image';
                }
                else if(filetype == 'pdf'){
                    this.doctype = 'doctype:pdf';
                }
                else if(filetype == 'doc'){
                    this.doctype = 'doctype:word';
                }
                else if(filetype == 'docx'){
                    this.doctype = 'doctype:word';
                }
                else if(filetype == 'xlsx'){
                    this.doctype = 'doctype:excel';
                }
            }
        }).catch(error => {
            if(error && error.body && error.body.message) {
                alert(error.body.message);
                //this.showToast('Error', 'error', error.body.message);
            }
        });
    }

    handleDownload() {
        if (this.recordId) {
                var contentDocumentId = this.recordId;
                const element = document.createElement('a');
                element.href = `/sfc/servlet.shepherd/document/download/${contentDocumentId}`;
                element.target = '_blank';
                element.style.display = 'none';
                document.body.appendChild(element);
                element.click();
                document.body.removeChild(element);
        }
    }
    onOwnerclick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:'/profile/'+this.fileownerId
            }
        });
    }

    
}