/**DPM-5633
 * Description: Upload the file in chunk
 * Created Date: 2024.08.01
 * Created By: Minhee Kim
 */

import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadChunkedFile from '@salesforce/apex/FileUploadChunkController.uploadChunkedFile';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
const MAX_FILE_SIZE = 14718592; // 4718592
const CHUNK_SIZE = 250000; // 750000

export default class FileUploadChunk extends LightningElement {
    @api recordId;
    @api contentversionId;
    @api fileName = '';
    @track fileContent = '';
    filesize = 0;
    uploadedsize = 0;
    showSpinner = false;
    showProgress = false;

    handleInputFileChange(event) {
        if(event.target.files.length > 0) {
            this.fileContent = event.target.files[0];
            this.fileName = event.target.files[0].name;
            this.dispatchFlowAttributeChangeEvent('fileName', this.fileName);
            this.uploadFiles();
        }
    }

    uploadFiles() {
        var fileCon = this.fileContent;
        this.filesize = fileCon.size;
        if (fileCon.size > MAX_FILE_SIZE) {
            this.showToast('Error!', 'error', 'File size exceeded the upload size limit.');
        }
        var reader = new FileReader();
        var self = this;
        reader.onload = function() {
            var fileContents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            self.upload(fileCon, fileContents);
        };
        reader.readAsDataURL(fileCon);
    }

    upload(file, fileContents){
        this.fileName = file.name;
        this.showSpinner = true;
        this.showProgress = true;
        var fromIndex = 0;
        var toIndex = Math.min(fileContents.length, fromIndex + CHUNK_SIZE);
        this.uploadChunk(file, fileContents, fromIndex, toIndex, ''); 
    }

    uploadChunk(file, fileContents, fromIndex, toIndex, cvId){
        var chunk = fileContents.substring(fromIndex, toIndex);
        uploadChunkedFile({ 
            recordId: this.recordId,
            fileName: file.name,
            fileContent: encodeURIComponent(chunk),
            contentVersionId: cvId
        }).then(result => {
            cvId = result;
            this.contentversionId = result;
            fromIndex = toIndex;
            toIndex = Math.min(fileContents.length, fromIndex + CHUNK_SIZE);
            this.uploadedsize = toIndex;
            if (fromIndex < toIndex) {
                this.uploadChunk(file, fileContents, fromIndex, toIndex, cvId);  
            } else {
                this.showSpinner = false;
                this.dispatchFlowAttributeChangeEvent('contentversionId', result);
                this.showProgress = false;
                this.showToast('Success', 'success', 'Files Uploaded successfully.');
            }
        }).catch(error => {
            if(error && error.body && error.body.message) {
                this.showToast('Error', 'error', error.body.message);
                this.removeReceiptImage();
            }
            this.showSpinner = false;
            this.showProgress = false;
        });
    }

    get progressBar() {
        if(this.filesize > 0 && this.uploadedsize > CHUNK_SIZE) {
            var uploadedPercent = (this.uploadedsize / (this.filesize + CHUNK_SIZE)) * 100;
            if(uploadedPercent > 100) {
                return 'width: 100% !important';
            } else {
                return 'width: '+ uploadedPercent + '% !important';
            }
        }
    }

    removeReceiptImage() {
        this.fileName = '';
        this.fileContent = '';
    }

    dispatchFlowAttributeChangeEvent(attributeName, value) {
        const attributeChangeEvent = new FlowAttributeChangeEvent(attributeName, value);
        this.dispatchEvent(attributeChangeEvent);
    }
    
    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }
}