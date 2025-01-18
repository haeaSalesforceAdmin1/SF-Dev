import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationPauseEvent, FlowNavigationFinishEvent, FlowNavigationCancelEvent    } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import uploadFile from '@salesforce/apex/FileUploadController.uploadFile'

export default class flowFooter extends NavigationMixin(LightningElement) {
    @api evalId;
    @api availableActions = [];
    @api fileIdsToDelete; // Receives file IDs from the Flow
    @api base64;
    @api filename
    @api contentDocumentId;
    @api disableButton=false;

    handleSuccess(event) {
        this.evalId = event.detail.id;
        this.NavigateToRecord();
    }


    handleNext() {
        if (this.availableActions.includes('NEXT') ) {
            console.log('NEXT');
            console.log('contentDocumentId', this.contentDocumentId);
           // if( this.contentDocumentId!=null && this.contentDocumentId!='' && this.contentDocumentId!='undefined' && this.contentDocumentId!=undefined){
                
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);  
          // }else{
          //     this.toast("Please attach file.");
          // }
        }
    }



    NavigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.evalId,
                objectApiName: 'Evaluation__c',
                actionName: 'view'
            }
        });
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"error"
        })
        this.dispatchEvent(toastEvent)
    }
}