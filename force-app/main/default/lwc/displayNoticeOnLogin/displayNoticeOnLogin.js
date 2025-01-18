import { LightningElement } from 'lwc';
import Display_Notice_Heading from '@salesforce/label/c.Display_Notice_Heading';
import Display_Notice_Message from '@salesforce/label/c.Display_Notice_Message';
import Display_Notice_Visibility from '@salesforce/label/c.Display_Notice_Visibility';

export default class DisplayNoticeOnLogin extends LightningElement {
    isModalOpen = true;

    label = {
        Display_Notice_Heading,
        Display_Notice_Message,
        Display_Notice_Visibility
    };

    connectedCallback(){

        if (this.label.Display_Notice_Visibility != null && this.label.Display_Notice_Visibility != undefined 
            && this.label.Display_Notice_Visibility != '' &&  (this.label.Display_Notice_Visibility).toUpperCase() == 'TRUE'){
                this.isModalOpen = true;
            } else if (this.label.Display_Notice_Visibility != null && this.label.Display_Notice_Visibility != undefined 
                && this.label.Display_Notice_Visibility != '' &&  (this.label.Display_Notice_Visibility).toUpperCase() == 'FALSE') {
                this.isModalOpen = false;
            }
    }

    closeModal() {
        this.isModalOpen = false;
    }
}