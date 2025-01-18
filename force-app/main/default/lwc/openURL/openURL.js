import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class OpenURL extends NavigationMixin(LightningElement) {

    remainingSeconds = 5;

    connectedCallback(){    
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Action_Plan__c',
                actionName: 'list'
            },            
        });
    }

}