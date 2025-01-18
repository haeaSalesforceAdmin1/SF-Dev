import { LightningElement } from 'lwc';
import lastLoginDetail from '@salesforce/apex/LastLoginLwcPopup.getLastLoginDetail';
export default class LwcModalPopup extends LightningElement {
    openModal = false;

    connectedCallback() {
        lastLoginDetail().then(result=>{
        if(result != null && result != undefined && result == 1){
            console.log('lastLoginDetail: ',result);
                this.openModal = true;
            } 
        });
    }
    closeModal() {
                this.openModal = false;
            }
    
}